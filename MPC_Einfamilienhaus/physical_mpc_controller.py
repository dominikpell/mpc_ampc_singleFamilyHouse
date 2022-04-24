import utilities.fmu_handler as fmu_handler
from pyomo.environ import *#
from pyomo.util.infeasible import *
from pyomo.dae import *
import datetime
from utilities.pickle_handler import *
from utilities.modelica_parser import *
from utilities.interpolation import sample
#from casadi import *
import json
import matplotlib.pyplot as plt
import numpy as np
"""
ToDo:
    - make controller more generic for easier coupling with overall problem
    - implement moving horizon estimator (in Simulation I need switches here: after one day of taking the initials using mhe)
"""

class ThermalZone:
    def __init__(self,path_to_mos, N, dt):
        """
        Implementation of a linear MPC to optimize an ERC Thermal Zone

        :param
        path_to_mos: path to model file
        """
        self.sol_opts = {
                          "solver": "ipopt",
                          "opts_ipopt": {"sol_io": "nl",
                                        "exe": "C:/Users/pst/Data/ipopt",
                                        "max_iter": 2500,
                                        "tol": 0.0001,
                                        "linear_solver":"ma57",
                                        "print_level": 2},
                          "opts_gurobi": {"sol_io":"python"},
                          "opt_model": {
                            "lb_q_cca": -5,
                            "ub_q_cca": 5,
                            "lb_T_ahu": 291.15,
                            "ub_T_ahu": 298.15,
                            "q_max_ahu": 5,
                            "obj_ahu": 1,
                            "obj_cca": 1,
                            "A_tabs": 48,
                            "d_tabs": 0.1
                          }
                        }
        self.par = parse_modelica_record(path_to_mos)
        self.calc_resistances()
        self.states = ['T_Air', 'T_ExtWall', 'T_IntWall', 'T_Win', 'T_Tabs']
        self.inputs = ['T_Ahu', 'Q_TabsSet']
        self.disturbances = ['T_amb', 'Q_RadSol', 'T_preTemWin', 'T_preTemWall', 'schedule_human', 'schedule_dev', 'schedule_light', 'm_flow_ahu', 'T_Air_UB', 'T_Air_LB']
        if self.has_roof:
            self.states.append('T_Roof')
            self.disturbances.append('T_preTemRoof')
        if self.has_floor:
            self.states.append('T_Floor')
            self.disturbances.append('T_preTemFloor')
        self.N = N
        self.dt = dt
        self.ncp = 3

    def create_tz(self, m):
        '''Parameters'''

        self.Area_Tabs = self.sol_opts['opt_model']['A_tabs']
        self.d_Tabs = self.sol_opts['opt_model']['d_tabs']
        self.C_Tabs = self.Area_Tabs*self.d_Tabs*2100*1000
        self.alpha_Tabs = 20
        self.k_Tabs_Air = self.Area_Tabs*self.alpha_Tabs
        self.fac_Q_rad = 2
        self.fac_IG = 2

        m.time_steps = ContinuousSet()

        # --- states
        m.T_Air = Var(m.time_steps, initialize=290, bounds=(273.15, 330))
        m.T_Air_dot = DerivativeVar(m.T_Air, initialize=0, wrt=m.time_steps)
        m.T_Roof = Var(m.time_steps, initialize=290, bounds=(273.15, 330))
        if self.has_roof:
            m.T_Roof_dot = DerivativeVar(m.T_Roof, initialize=0, wrt=m.time_steps)
        m.T_Floor = Var(m.time_steps, initialize=290, bounds=(273.15, 330))
        if self.has_floor:
            m.T_Floor_dot = DerivativeVar(m.T_Floor, initialize=0, wrt=m.time_steps)
        m.T_ExtWall = Var(m.time_steps, initialize=290, bounds=(273.15, 330))
        m.T_ExtWall_dot = DerivativeVar(m.T_ExtWall, initialize=0, wrt=m.time_steps)
        m.T_IntWall = Var(m.time_steps, initialize=290, bounds=(273.15, 330))
        m.T_IntWall_dot = DerivativeVar(m.T_IntWall, initialize=0, wrt=m.time_steps)
        m.T_Win = Var(m.time_steps, initialize=290, bounds=(273.15, 330))
        m.T_Win_dot = DerivativeVar(m.T_Win, initialize=0, wrt=m.time_steps)
        m.T_Tabs = Var(m.time_steps, initialize=290, bounds=(273.15, 330))
        m.T_Tabs_dot = DerivativeVar(m.T_Tabs, initialize=0, wrt=m.time_steps)

        # --- algebraic Variables
        m.Q_ig_conv = Var(m.time_steps, initialize=0, bounds=(-1000000, 1000000))
        m.Q_ig_rad = Var(m.time_steps, initialize=0, bounds=(-1000000, 1000000))
        m.eps_Air = Var(m.time_steps, initialize=0, bounds=(0, 10))

        # --- disturbances
        m.Q_RadSol = Param(m.time_steps, mutable=True)
        m.T_WinInit = Param(m.time_steps, mutable=True)
        m.T_WallInit = Param(m.time_steps, mutable=True)
        if self.has_roof:
            m.T_preTemRoof = Param(m.time_steps, mutable=True)
        if self.has_floor:
            m.T_preTemFloor = Param(m.time_steps, mutable=True)
        m.schedule_human = Param(m.time_steps, mutable=True)
        m.schedule_dev = Param(m.time_steps, mutable=True)
        m.schedule_light = Param(m.time_steps, mutable=True)
        m.T_amb = Param(m.time_steps, mutable=True)
        m.m_flow_ahu = Param(m.time_steps, mutable=True)
        m.T_Air_ref = Param(m.time_steps, mutable=True)
        m.T_Air_UB = Param(m.time_steps, mutable=True)
        m.T_Air_LB = Param(m.time_steps, mutable=True)

        m.Q_TabsSet_last = Param(default=0, mutable=True)
        m.T_Ahu_last = Param(default=293, mutable=True)

        # --- control inputs
        m.Q_TabsSet = Var(m.time_steps, initialize=0, bounds=(self.sol_opts['opt_model']['lb_q_cca'],
                                                              self.sol_opts['opt_model']['ub_q_cca']))
        m.Q_TabsSet_dot = DerivativeVar(m.Q_TabsSet, initialize=0, wrt=m.time_steps)
        m.T_Ahu = Var(m.time_steps, initialize=293, bounds=(self.sol_opts['opt_model']['lb_T_ahu'],
                                                            self.sol_opts['opt_model']['ub_T_ahu']))
        m.Q_Ahu = Var(m.time_steps, initialize=0, bounds=(-self.sol_opts['opt_model']['q_max_ahu'],
                                                          self.sol_opts['opt_model']['q_max_ahu']))
        m.Q_Ahu_dot = DerivativeVar(m.Q_Ahu, initialize=0, wrt=m.time_steps)

        # --- algebraic eq:
        def q_ig_conv(m, t):
            return m.Q_ig_conv[t] ==  (((0.865 - (0.025 * (m.T_Air[t] - 273.15))) * (self.activityDegree * 58 * 1.8) + 35) *
                                        self.specPers * self.ARoom * self.ratioConv_human * m.schedule_human[t] +
                                        self.ARoom * self.internalGainsMachinesSpecific * m.schedule_dev[t] * self.ratioConvectiveHeatMachines +
                                        self.ARoom * self.lightingPowerSpecific * m.schedule_light[t] * self.ratioConvectiveHeatLighting)*self.fac_IG
        m.q_ig_conv_con = Constraint(m.time_steps, rule= q_ig_conv)

        def q_ig_rad(m, t):
            return m.Q_ig_rad[t] == (((0.865 - (0.025 * (m.T_Air[t] - 273.15))) * ( self.activityDegree * 58 * 1.8) + 35) *
                                        self.specPers * self.ARoom * self.ratioConv_human * m.schedule_human[t] * (1 - self.ratioConv_human) / self.ratioConv_human +
                                        self.ARoom * self.internalGainsMachinesSpecific * m.schedule_dev[t] * self.ratioConvectiveHeatMachines* (1 - self.ratioConvectiveHeatMachines) / self.ratioConvectiveHeatMachines +
                                        self.ARoom * self.lightingPowerSpecific * m.schedule_light[t] * self.ratioConvectiveHeatLighting* (1 - self.ratioConvectiveHeatLighting) / self.ratioConvectiveHeatLighting)*self.fac_IG
        m.q_ig_rad_con = Constraint(m.time_steps, rule= q_ig_rad)

        def q_ahu(m, t):
            return m.Q_Ahu[t] == m.m_flow_ahu[t]*self.c_spec_Air*(m.T_Ahu[t] - (m.T_amb[t]*1.05+m.T_Air[t]*0.95)/2)/1000  # Correct Cooler Inlet Temperature by HX Characteristics (in kW)
        m.q_ahu_con = Constraint(m.time_steps, rule=q_ahu)

        # --- diff Eq:
        def t_air_con(m,t):
            return m.T_Air_dot[t] == ( 1 / self.CAir ) *((m.T_Roof[t] - m.T_Air[t])*self.k_Roof_Air +
                                     (m.T_ExtWall[t] - m.T_Air[t])*self.k_Ext_Air +
                                     (m.T_IntWall[t] - m.T_Air[t])*self.k_Int_Air +
                                     (m.T_Win[t] - m.T_Air[t])*self.k_Win_Air +
                                     (m.T_Floor[t] - m.T_Air[t]) * self.k_Floor_Air +
                                     m.Q_ig_conv[t] +
                                     m.m_flow_ahu[t] *
                                     self.c_spec_Air*(m.T_Ahu[t] - m.T_Air[t]) +
                                     self.k_Tabs_Air*(m.T_Tabs[t]-m.T_Air[t]))
        m.t_air_con = Constraint(m.time_steps, rule=t_air_con)

        if self.has_roof:
            # set differential equation for Roof if it exits
            def t_roof_con(m,t):
                return m.T_Roof_dot[t] == ( 1 / self.CRoof ) * ( (m.T_Air[t] - m.T_Roof[t])*self.k_Air_Roof
                                        + (m.T_ExtWall[t] - m.T_Roof[t])*self.k_Ext_Roof
                                        + (m.T_IntWall[t] - m.T_Roof[t])*self.k_Int_Roof
                                        + (m.T_preTemRoof[t] - m.T_Roof[t])*self.k_Amb_Roof
                                        + (m.T_Win[t] - m.T_Roof[t])*self.k_Win_Roof
                                        + (m.T_Floor[t] - m.T_Roof[t]) * self.k_Floor_Roof
                                        + self.splitRoofSol * m.Q_RadSol[t]*self.fac_Q_rad
                                        + self.splitRoofIG * m.Q_ig_rad[t])
        else:
            # set Roof temperature to default
            def t_roof_con(m, t):
                return m.T_Roof[t] == 293
        m.t_roof_con = Constraint(m.time_steps, rule=t_roof_con)

        if self.has_floor:
            # set differential equation for Floor if it exists
            def t_floor_con(m,t):
                return m.T_Floor_dot[t] == (1 / self.CFloor) *((m.T_Air[t] - m.T_Floor[t])*self.k_Air_Floor
                                                                + (m.T_ExtWall[t] - m.T_Floor[t])*self.k_Ext_Floor
                                                                + (m.T_Win[t] - m.T_Floor[t])*self.k_Win_Floor
                                                                + (m.T_Roof[t] - m.T_Floor[t])*self.k_Roof_Floor
                                                                + (m.T_IntWall[t] - m.T_Floor[t])*self.k_Int_Floor
                                                                + (m.T_preTemFloor[t] - m.T_Floor[t])*self.k_Soil_Floor
                                                                + self.splitFloorSol * m.Q_RadSol[t]*self.fac_Q_rad
                                                                + self.splitFloorIG * m.Q_ig_rad[t])
        else:
            # set Floor temperature to default
            def t_floor_con(m,t):
                return m.T_Floor[t] ==293
        m.t_floor_con = Constraint(m.time_steps, rule=t_floor_con)

        def t_exWall_con(m,t):
            return m.T_ExtWall_dot[t] == ( 1 / self.CExt) * ((m.T_Air[t] - m.T_ExtWall[t]) * self.k_Air_Ext
                                                             + (m.T_Roof[t] - m.T_ExtWall[t]) * self.k_Roof_Ext
                                                             + (m.T_IntWall[t] - m.T_ExtWall[t]) * self.k_Int_Ext
                                                             + (m.T_WallInit[t] - m.T_ExtWall[t]) * self.k_Amb_Ext
                                                             + (m.T_Win[t] - m.T_ExtWall[t]) * self.k_Win_Ext
                                                             + (m.T_Floor[t] - m.T_ExtWall[t]) * self.k_Floor_Ext
                                                             + self.splitExtSol * m.Q_RadSol[t] * self.fac_Q_rad
                                                             + self.splitExtIG * m.Q_ig_rad[t])
        m.t_exWall_con = Constraint(m.time_steps, rule= t_exWall_con)

        def t_inWall_con(m,t):
            return m.T_IntWall_dot[t] == (1 / self.CInt) * ((m.T_Air[t] - m.T_IntWall[t])*self.k_Air_Int
                                         + (m.T_ExtWall[t] - m.T_IntWall[t])*self.k_Ext_Int
                                         + (m.T_Roof[t] - m.T_IntWall[t])*self.k_Roof_Int
                                         + (m.T_Win[t] - m.T_IntWall[t])*self.k_Win_Int
                                         + (m.T_Floor[t] - m.T_IntWall[t]) * self.k_Floor_Int
                                         + self.splitIntSol*m.Q_RadSol[t]*self.fac_Q_rad
                                         + self.splitIntIG*m.Q_ig_rad[t])
        m.t_inWall_con = Constraint(m.time_steps, rule= t_inWall_con)

        def t_Win_con(m,t):
            return m.T_Win_dot[t] == (1/self.CWin)*((m.T_Air[t] - m.T_Win[t]) * self.k_Win_Air
                                                    + (m.T_Roof[t] - m.T_Win[t]) * self.k_Win_Roof
                                                    + (m.T_ExtWall[t] -m.T_Win[t]) * self.k_Win_Ext
                                                    + (m.T_IntWall[t] - m.T_Win[t]) * self.k_Win_Int
                                                    + (m.T_Floor[t] - m.T_Win[t]) * self.k_Win_Floor
                                                    + (m.T_WinInit[t] - m.T_Win[t]) * self.k_Amb_Win
                                                    + self.splitWinSol * m.Q_RadSol[t] * self.fac_Q_rad
                                                    + self.splitWinIG * m.Q_ig_rad[t])
        m.t_Win_con = Constraint(m.time_steps, rule=t_Win_con)

        def t_tabs_con(m,t):
            return m.T_Tabs_dot[t] == (1/self.C_Tabs)*((m.T_Air[t]-m.T_Tabs[t])*self.k_Tabs_Air
                                 + m.Q_TabsSet[t]*1000)
        m.t_tabs_con = Constraint(m.time_steps, rule=t_tabs_con)

        return m

    def create_economic_constraints(self,m):
        # Set Economic Constraints
        def eco_ub(m, t):
            return m.T_Air[t] - m.eps_Air[t] <= m.T_Air_UB[t]

        m.eco_ub_con = Constraint(m.time_steps, rule=eco_ub)

        def eco_lb(m, t):
            return m.T_Air[t] + m.eps_Air[t] >= m.T_Air_LB[t]

        m.eco_lb_con = Constraint(m.time_steps, rule=eco_lb)
        return m

    def obj_rule(self,instance):
        obj =0
        for i, t in enumerate(instance.time_steps):
            obj += instance.eps_Air[t]**2*750
            obj += (instance.Q_Ahu[t]/
                    self.sol_opts['opt_model']['q_max_ahu'])**2*self.sol_opts['opt_model']['obj_ahu']
            obj += (instance.Q_TabsSet[t]/
                    self.sol_opts['opt_model']['ub_q_cca'])**2*self.sol_opts['opt_model']['obj_cca']

            if i < 1:
                # skip first values (can't be changed anyway)
                t_last = t
            else:
                obj += ((instance.Q_TabsSet[t]-instance.Q_TabsSet[t_last])/5)**2*10
                obj += ((instance.T_Ahu[t] - instance.T_Ahu[t_last]) / 5) ** 10



            # pass last value
            t_last = t


        return obj

    def calc_resistances(self):
        """ Calculate simplified Heat Transfers based on Modelica Model 4 C Model
        """
        # Evaluate Components
        self.has_roof = self.par['ARoof'] > 0
        self.has_floor = self.par['AFloor'] > 0

        # Calculate Total and mean Areas
        AWintot = float(sum(self.par['AWin'])) if type(self.par['AWin'])==list else float(self.par['AWin'])
        AWinMean = float(sum(self.par['AWin'])/len(self.par['AWin'])) if type(self.par['AWin'])==list else 0
        AExttot = float(sum(self.par['AExt'])) if type(self.par['AExt'])==list else float(self.par['AExt'])
        AExtMean = float(sum(self.par['AExt'])/len(self.par['AExt'])) if type(self.par['AExt'])==list else 0
        AInttot = float(sum(self.par['AInt'])) if type(self.par['AInt'])==list else float(self.par['AInt'])
        AIntMean = float(sum(self.par['AInt']) / len(self.par['AInt'])) if type(self.par['AInt']) == list else 0
        ARooftot = float(sum(self.par['ARoof'])) if type(self.par['ARoof'])==list else float(self.par['ARoof'])
        ARoofMean = float(sum(self.par['ARoof']) / len(self.par['ARoof'])) if type(self.par['ARoof']) == list else 0
        AFloortot = float(sum(self.par['AFloor'])) if type(self.par['AFloor'])==list else float(self.par['AFloor'])
        AFloorMean = float(sum(self.par['AFloor']) / len(self.par['AFloor'])) if type(self.par['AFloor']) == list else 0
        Atot = AWintot + AExttot + AInttot + ARooftot + AFloortot
        AMeanTot = AWinMean + AExtMean + AIntMean + ARoofMean + AFloorMean

        # Calculate Splitfactors for Internal Gains
        self.splitIntIG = AInttot / (Atot)
        self.splitRoofIG = ARooftot / (Atot)
        self.splitExtIG = AExttot / (Atot)
        self.splitWinIG = AWintot / (Atot)
        self.splitRoofIG = ARooftot / (Atot)
        self.splitFloorIG = AFloortot / (Atot)

        # Calculate Splitfactors for Solar Radiation
        # (Compared to the Modelica Model we don't calculate n_orientation*n_components Splitfactors, instead we average over all orientations
        # to keep the model simple)
        self.splitIntSol = 0.32#(AInttot - AIntMean)/(Atot - AMeanTot)
        self.splitRoofSol = 0.32#(ARooftot - ARoofMean)/(Atot - AMeanTot)
        self.splitExtSol = 0.36#(AExttot - AExtMean)/(Atot - AMeanTot)
        self.splitWinSol = 0#(AWintot - AWinMean)/(Atot - AMeanTot)
        self.splitFloorSol =0# (AFloortot - AFloorMean)/(Atot - AMeanTot)

        # Pass Factors for Internal Gains
        self.specPers = self.par['specificPeople']
        self.activityDegree = self.par['activityDegree']
        self.fixedHeatFlowRatePersons = self.par['fixedHeatFlowRatePersons']
        self.ratioConv_human = self.par['ratioConvectiveHeatPeople']
        self.internalGainsMoistureNoPeople = self.par['internalGainsMoistureNoPeople']
        self.internalGainsMachinesSpecific = self.par['internalGainsMachinesSpecific']
        self.ratioConvectiveHeatMachines = self.par['ratioConvectiveHeatMachines']
        self.lightingPowerSpecific = self.par['lightingPowerSpecific']
        self.ratioConvectiveHeatLighting = self.par['ratioConvectiveHeatLighting']
        self.ARoom = self.par['AZone']

        # Pass Paramters
        self.c_spec_Air = 1000
        self.CAir = self.par['VAir'] * 1.204 * self.c_spec_Air
        self.VAir = self.par['VAir']
        self.CInt = self.par['CInt']
        self.CFloor = self.par['CFloor']
        self.CRoof = self.par['CRoof']
        self.CExt = self.par['CExt']
        self.TSoil = self.par['TSoil']
        self.CWin = AWintot * 0.01 * 2500 * 720

        """ Calculate Heat transfers """
        # Roof
        if self.has_roof:
            self.k_Amb_Roof = 1 / (1 / ((self.par['hConRoofOut'] + self.par['hRadRoof']) * ARooftot) + self.par['RRoofRem'])
            self.k_Win_Roof = 1 / (1 / (min(AWintot, ARooftot) * self.par['hRad']) + self.par['RRoof'])
            self.k_Air_Roof = 1 / (1 / (self.par['hConRoof'] * ARooftot) + self.par['RRoof'])
            self.k_Int_Roof = 1 / (1 / (self.par['hRad'] * min(AInttot, ARooftot)) + self.par['RInt'] + self.par['RRoof'])
            self.k_Ext_Roof = 1 / (1 / ((self.par['hRad'] * min(AExttot, ARooftot))) + self.par['RExt'] + self.par['RRoof'])
            if self.has_floor:
                self.k_Floor_Roof = 1 / (1 / ((self.par['hRad'] * min(AFloortot, ARooftot))) + self.par['RFloor'] + self.par['RRoof'])
            else:
                self.k_Floor_Roof = 0
        else:
            self.k_Amb_Roof = 0
            self.k_Win_Roof = 0
            self.k_Air_Roof = 0
            self.k_Int_Roof = 0
            self.k_Ext_Roof = 0
            self.k_Floor_Roof = 0

        # Floor
        if self.has_floor:
            self.k_Soil_Floor = 1/self.par['RFloorRem']
            self.k_Roof_Floor = self.k_Floor_Roof
            self.k_Ext_Floor = 1 / (1 / ((self.par['hRad'] * min(AFloortot, AExttot))) + self.par['RExt'] + self.par['RFloor'])
            self.k_Int_Floor = 1 / (1 / ((self.par['hRad'] * min(AFloortot, AInttot))) + self.par['RInt'] + self.par['RFloor'])
            self.k_Air_Floor = 1/(1/(self.par['hConFloor']*AFloortot)+self.par['RFloor'])
            self.k_Win_Floor = 1 / (1 / (min(AWintot, AFloortot) * self.par['hRad']) + self.par['RFloor'])
        else:
            self.k_Soil_Floor = 0
            self.k_Roof_Floor = 0
            self.k_Ext_Floor = 0
            self.k_Int_Floor = 0
            self.k_Air_Floor = 0
            self.k_Win_Floor = 0

        # Exterior Walls
        self.k_Amb_Ext = 1 / (1 / ((self.par['hConWallOut'] + self.par['hRadWall']) * AExttot) + self.par['RExtRem'])
        self.k_Win_Ext = 1 / (1 / (min(AExttot, AWintot) * self.par['hRad']) + self.par['RExt'])
        self.k_Air_Ext = 1 / (1 / (self.par['hConExt'] * AExttot) + self.par['RExt'])
        self.k_Int_Ext = 1 / (1 / (self.par['hRad'] * min(AExttot, AInttot)) + self.par['RInt'] + self.par['RExt'])
        self.k_Roof_Ext = self.k_Ext_Roof
        self.k_Floor_Ext = self.k_Ext_Floor

        # Indoor Air
        self.k_Win_Air = 1 / (1 / (self.par['hConWin'] * AWintot))
        self.k_Roof_Air = self.k_Air_Roof
        self.k_Int_Air = 1 / (1 / (self.par['hConInt'] * AInttot) + self.par['RInt'])
        self.k_Ext_Air = self.k_Air_Ext
        self.k_Floor_Air = self.k_Air_Floor

        # Interior Walls
        self.k_Air_Int = self.k_Int_Air
        self.k_Ext_Int = self.k_Int_Ext
        self.k_Roof_Int = self.k_Int_Roof
        self.k_Win_Int = 1 / (1 / (min(AWintot, AInttot) * self.par['hRad']) + self.par['RInt'])
        self.k_Floor_Int = self.k_Int_Floor

        # Window
        self.k_Amb_Win = 1 / (self.par['RWin'] + 1 / ((self.par['hConWinOut'] + self.par['hRadWall']) * AWintot))

    def create_controller(self):
        m = AbstractModel()
        m.t = ContinuousSet()
        m = self.create_tz(m)
        m = self.create_economic_constraints(m)
        self.m = m

    def get_control(self, x0, u0, disturbances):
        """
        Solves Optimal control Problem based on given inputs, disturbances and references

        :param x0: dict with starting Values for State Variables
        :param u0: dict with starting Value Variables
        :param time: Vector of Prediction horizon in s
        :param ncp: number of collocation points used for discretization
        :param disturbances dict with disturbances (single disturbances as List with len(time))
        :return: vector of decision variables and predicted States
        """
        time = [i * self.dt for i in range(0, self.N)]
        ncp = self.ncp
        # set up optimal control optimization
        instance = self.m.create_instance({None: {'t': {None: time}, }})

        # set initial values
        def _init(instance):
            # Initial Values for States
            for i,state in enumerate(self.states):
                yield instance.component(state)[0] == x0[state]

            # Initial Values for inputs
            for i, input in enumerate(self.inputs):
                yield instance.component(input)[0] == u0[input]

        instance.init_conditions = ConstraintList(rule=_init)

        # apply collocation scheme
        discretizer = TransformationFactory('dae.collocation')
        discretizer.apply_to(instance, ncp=ncp, scheme='LAGRANGE-RADAU', wrt=instance.time_steps)
        #discretizer = TransformationFactory('dae.finite_difference')
        #discretizer.apply_to(instance, nfe=10, wrt=instance.t, scheme='FORWARD')

        # get Grid
        time_col = [t for t in instance.time_steps]
        # Control variables are made constant over each finite element
        for i, input in enumerate(self.inputs):
            discretizer.reduce_collocation_points(instance, var=instance.component(input), contset=instance.time_steps, ncp=1)

        # fit disturbances and Reference to collocation points
        for key in disturbances.keys():
            disturbances[key] = sample(trajectory = pd.Series(data=disturbances[key],index=time), grid=time_col)

        # pass parametes
        for disturbance in self.disturbances:
            for i, t in enumerate(instance.time_steps):
                instance.component(disturbance)[t] = disturbances[disturbance][i]

        #for i, input in enumerate(self.inputs):
        #    instance.component(input + "_last") == u0[input]

        # Objectiv with reference
        instance.obj = Objective(rule=self.obj_rule)

        # Solver Options with path to Ipopt
        if self.sol_opts['solver'] == 'ipopt':
            opt = SolverFactory('ipopt', solver_io=self.sol_opts['opts_ipopt']['sol_io'], executable=self.sol_opts['opts_ipopt']['exe'])
            opt.options['max_iter'] = self.sol_opts['opts_ipopt']['max_iter']
            opt.options['tol'] = self.sol_opts['opts_ipopt']['tol']
            opt.options['linear_solver'] = self.sol_opts['opts_ipopt']['linear_solver']
        elif self.sol_opts['solver'] == 'gurobi':
            opt = SolverFactory('gurobi', solver_io = 'python')
        else:
            print('Warning: Specify Solver!')
        # Solve nlp :
        sol = opt.solve(instance, tee=True)

        # pass results as dataframe
        results = pd.DataFrame()
        for v in instance.component_objects(Var, active=True):
            for index in v:
                results.at[index, v.name] = value(v[index])

        return results, instance, sol

    def create_casadi_model(self):
        """
        Create Casadi Model to simulate the system in python

        :return:
        """
        # --- states
        T_Air = MX.sym('T_Air')
        if self.has_roof:
            T_Roof = MX.sym('T_Roof')
        else:
            T_Roof = 293
        if self.has_floor:
            T_Floor = MX.sym('T_Floor')
        else:
            T_Floor = 293
        T_ExtWall = MX.sym('T_ExtWall')
        T_IntWall = MX.sym('T_IntWall')
        T_Win = MX.sym('T_Win')
        T_Tabs = MX.sym('T_Tabs')

        # --- disturbances
        Q_RadSol = MX.sym('Q_RadSol')
        T_preTemWin = MX.sym('T_preTemWin')
        T_preTemWall = MX.sym('T_preTemWall')
        T_preTemRoof = MX.sym('T_preTemRoof')
        m_flow_ahu = MX.sym('m_flow_ahu')
        schedule_human = MX.sym('schedule_human')
        schedule_dev = MX.sym('schedule_dev')
        schedule_light = MX.sym('schedule_light')

        # --- control inputs
        Q_Tabs_set= MX.sym('Q_Tabs_set')
        T_Ahu = MX.sym('T_ahu')

        # --- algebraic eq:
        heat_humans_conv = ((0.865 - (0.025 * (T_Air - 273.15))) * ( self.activityDegree * 58 * 1.8) + 35) * self.specPers * self.ARoom * self.ratioConv_human * schedule_human
        heat_humans_Rad = heat_humans_conv * (1 - self.ratioConv_human) / self.ratioConv_human
        heat_devices_conv = self.ARoom * self.internalGainsMachinesSpecific * schedule_dev * self.ratioConvectiveHeatMachines  # schedule = int_gains[2]
        heat_devices_Rad = heat_devices_conv * (1 - self.ratioConvectiveHeatMachines) / self.ratioConvectiveHeatMachines
        heat_lights_conv = self.ARoom * self.lightingPowerSpecific * schedule_light * self.ratioConvectiveHeatLighting
        heat_lights_Rad = heat_lights_conv * (1 - self.ratioConvectiveHeatLighting) / self.ratioConvectiveHeatLighting

        Q_ig_conv = (heat_humans_conv + heat_devices_conv + heat_lights_conv)*self.fac_IG
        Q_ig_rad = (heat_humans_Rad + heat_devices_Rad + heat_lights_Rad)*self.fac_IG

        # --- diff Eq:
        T_Air_dot = ( 1 / self.CAir ) *((T_Roof - T_Air)*self.k_Roof_Air +
                                     (T_ExtWall - T_Air)*self.k_Ext_Air +
                                     (T_IntWall - T_Air)*self.k_Int_Air +
                                     (T_Win - T_Air)*self.k_Win_Air +
                                     (T_Floor - T_Air) * self.k_Floor_Air +
                                     Q_ig_conv +
                                     m_flow_ahu *
                                     self.c_spec_Air*(T_Ahu - T_Air) +
                                     self.k_Tabs_Air*(T_Tabs-T_Air))

        if self.has_roof:
            T_Roof_dot = ( 1 / self.CRoof ) * ( (T_Air - T_Roof)*self.k_Air_Roof
                                        + (T_ExtWall - T_Roof)*self.k_Ext_Roof
                                        + (T_IntWall - T_Roof)*self.k_Int_Roof
                                        + (T_preTemRoof - T_Roof)*self.k_Amb_Roof
                                        + (T_Floor - T_Roof) * self.k_Floor_Roof
                                        + (T_Win - T_Roof)*self.k_Win_Roof
                                        + self.splitRoofSol * Q_RadSol*self.fac_Q_rad
                                        + self.splitRoofIG * Q_ig_rad)
        if self.has_floor:
            T_Floor_dot = (1 / self.CFloor) *((T_Air - T_Floor)*self.k_Air_Floor
                                            + (T_ExtWall - T_Floor)*self.k_Ext_Floor
                                            + (T_Win - T_Floor)*self.k_Win_Floor
                                            + (T_Roof - T_Floor)*self.k_Roof_Floor
                                            + (T_IntWall - T_Floor)*self.k_Int_Floor
                                            + self.splitFloorSol * Q_RadSol*self.fac_Q_rad
                                            + self.splitFloorIG * Q_ig_rad)

        T_ExtWall_dot = ( 1 / self.CExt ) * ( (T_Air - T_ExtWall)*self.k_Air_Ext
                                         + (T_Roof - T_ExtWall)*self.k_Roof_Ext
                                         + (T_IntWall - T_ExtWall)*self.k_Int_Ext
                                         + (T_preTemWall - T_ExtWall)*self.k_Amb_Ext
                                         + (T_Win - T_ExtWall)*self.k_Win_Ext
                                         + (T_Floor - T_ExtWall) * self.k_Floor_Ext
                                         + self.splitExtSol * Q_RadSol*self.fac_Q_rad
                                         + self.splitExtIG * Q_ig_rad)


        T_IntWall_dot = ( 1 / self.CInt ) * ( (T_Air - T_IntWall)*self.k_Air_Int
                                         + (T_ExtWall - T_IntWall)*self.k_Ext_Int
                                         + (T_Roof - T_IntWall)*self.k_Roof_Int
                                         + (T_Win -T_IntWall)*self.k_Win_Int
                                         + (T_Floor - T_IntWall) * self.k_Floor_Int
                                         + self.splitIntSol*Q_RadSol*self.fac_Q_rad
                                         + self.splitIntIG*Q_ig_rad)

        T_Win_dot = (1/self.CWin)*((T_Air - T_Win)*self.k_Win_Air
                                   +(T_Roof - T_Win)*self.k_Win_Roof
                                   + (T_ExtWall -T_Win)*self.k_Win_Ext
                                   + (T_IntWall - T_Win)*self.k_Win_Int
                                   + (T_preTemWin - T_Win)*self.k_Amb_Win
                                   + (T_Floor - T_Win) * self.k_Win_Floor
                                   + self.splitWinSol * Q_RadSol*self.fac_Q_rad
                                   + self.splitWinIG * Q_ig_rad)

        T_Tabs_dot = (1 / self.C_Tabs) * ((T_Air - T_Tabs) * self.k_Tabs_Air
                                     + Q_Tabs_set*1000)

        if self.has_roof and self.has_floor:
            self.x_dot = vertcat(T_Air_dot,  T_ExtWall_dot,  T_IntWall_dot,T_Win_dot,T_Tabs_dot,T_Roof_dot,T_Floor_dot)
            self.x = vertcat(T_Air, T_ExtWall, T_IntWall,T_Win,T_Tabs, T_Roof,T_Floor)
        elif self.has_roof and not self.has_floor:
            self.x_dot = vertcat(T_Air_dot,  T_ExtWall_dot,  T_IntWall_dot,T_Win_dot,T_Tabs_dot,T_Roof_dot)
            self.x = vertcat(T_Air, T_ExtWall, T_IntWall,T_Win,T_Tabs, T_Roof)
        elif not self.has_roof and self.has_floor:
            self.x_dot = vertcat(T_Air_dot,  T_ExtWall_dot,  T_IntWall_dot,T_Win_dot,T_Tabs_dot,T_Floor_dot)
            self.x = vertcat(T_Air, T_ExtWall, T_IntWall,T_Win,T_Tabs,T_Floor)
        else:
            self.x_dot = vertcat(T_Air_dot, T_ExtWall_dot,  T_IntWall_dot,T_Win_dot,T_Tabs_dot)
            self.x = vertcat(T_Air, T_ExtWall, T_IntWall,T_Win,T_Tabs)

        if self.has_roof:
            self.p = vertcat(T_Ahu, Q_Tabs_set, Q_RadSol, T_preTemWin, T_preTemWall, T_preTemRoof, m_flow_ahu, schedule_human,
                             schedule_dev, schedule_light)
        else:
            self.p = vertcat(T_Ahu, Q_Tabs_set, Q_RadSol, T_preTemWin, T_preTemWall, m_flow_ahu, schedule_human,
                             schedule_dev, schedule_light)
        self.nx = self.x.shape[0]
        self.nu = 2
        self.nd = 6
        self.np = 0
        self.dae = {'x': self.x, 'p': self.p, 'ode' : self.x_dot}
        return

    def do_step(self, x0, U, dt):
        """
        Performs One Simulation Step using the Casadi Model
        :param x0: List of States x0 : [T_Air, T_Roof, T_ExtWall, T_IntWall,T_Win,T_Tabs]
        :param U: List of Inputs U: [T_Ahu, Q_Tabs_set , Q_RadSol, T_preTemWin, T_preTemWall, T_preTemRoof, m_flow_ahu, schedule_human, schedule_dev, schedule_light]
        :param dt: Time Step Size in s
        :return: vector x1
        """
        self.opts = {'tf': dt}  # interval length
        I = integrator('I', 'idas', self.dae, self.opts)
        result = I(x0=x0, p=vertcat(*U.T.ravel()))
        x = result['xf']
        #z = result['zf']
        return x#,z

    def validate_model(self,path_to_fmu,path_mapping,dt):
        """
        Simulate FMU and Model for Validation
        """
        start_time = 3600*24*150
        stop_time = 3600*24*170
        fmu_step_size = dt
        fmu_tolerance = 0.0001
        instance_name = "Validation_Test"

        with open(path_mapping,'r') as f:
            mapping = json.load(f)


        self.vars = []
        for key in mapping.keys():
            for var in mapping[key].keys():
                self.vars.append(mapping[key][var])

        self.fmu = fmu_handler.fmu_handler(start_time=start_time,
                                      stop_time=stop_time,
                                      step_size=fmu_step_size,
                                      sim_tolerance=fmu_tolerance,
                                      fmu_file=path_to_fmu,
                                      instanceName=instance_name)

        self.fmu.setup()
        self.fmu.initialize()

        self.simulation_data = pd.DataFrame(columns=self.vars + ['SimTime'])
        finished = False
        while not finished:
            res = self.fmu.read_variables(self.vars)
            self.simulation_data = self.simulation_data.append(pd.DataFrame(res, index=[res['SimTime']]))
            finished = self.fmu.do_step()
            print(f"step {res['SimTime']}")

        # Correction of Q_rad
        self.simulation_data["Q_RadSol"] = self.simulation_data[mapping['disturbances']["Q_RadSol_or_1"]] \
                                        + self.simulation_data[mapping['disturbances']["Q_RadSol_or_2"]] \
                                        + self.simulation_data[mapping['disturbances']["Q_RadSol_or_3"]] \
                                        + self.simulation_data[mapping['disturbances']["Q_RadSol_or_4"]]

        # Generate x0
        T_Air = [self.simulation_data[mapping['states']['T_Air']].iloc[0]]
        T_ExtWall= [self.simulation_data[mapping['states']['T_ExtWall']].iloc[0]]
        T_IntWall = [self.simulation_data[mapping['states']['T_IntWall']].iloc[0]]
        T_Win = [self.simulation_data[mapping['states']['T_Win']].iloc[0]]
        T_Tabs = [self.simulation_data[mapping['states']['T_Tabs']].iloc[0]]
        T_Roof = [self.simulation_data[mapping['states']['T_Roof']].iloc[0]]

        # Generate u
        T_Ahu = self.simulation_data[mapping['measurements']["T_ahu_act"]]
        Q_Tabs_set= self.simulation_data[mapping['measurements']["Q_fl_tabs_act"]]
        Q_RadSol = self.simulation_data[["Q_RadSol"]]
        T_preTemWin = self.simulation_data[mapping['disturbances']["T_preTemWin"]]
        T_preTemWall= self.simulation_data[mapping['disturbances']["T_preTemWall"]]
        T_preTemRoof= self.simulation_data[mapping['disturbances']["T_preTemRoof"]]
        m_flow_ahu= 3*129/3600*1.224
        schedule_human= self.simulation_data[mapping['disturbances']["schedule_human"]]
        schedule_dev= self.simulation_data[mapping['disturbances']["schedule_dev"]]
        schedule_light = self.simulation_data[mapping['disturbances']["schedule_light"]]

        self.calc_resistances()
        self.create_controller()
        self.create_casadi_model()

        for i in range(0,len(self.simulation_data)):
            self.u = [T_Ahu.iloc[i], Q_Tabs_set.iloc[i], Q_RadSol.iloc[i], T_preTemWin.iloc[i], T_preTemWall.iloc[i], T_preTemRoof.iloc[i], m_flow_ahu, schedule_human.iloc[i],
                             schedule_dev.iloc[i], schedule_light.iloc[i]]
            x = [T_Air[-1], T_ExtWall[-1], T_IntWall[-1],T_Win[-1],T_Tabs[-1], T_Roof[-1]]

            x = self.do_step(x0=np.array(x),U=np.array(self.u), dt=dt)
            T_Air.append(x[0])
            T_ExtWall.append(x[1])
            T_IntWall.append(x[2])
            T_Win.append(x[3])
            T_Tabs.append(x[4])
            T_Roof.append(x[5])
            print(f"Casadi step {i*dt}")

        self.casadi_data = pd.DataFrame(columns=self.states, index=self.simulation_data.index)
        self.casadi_data['T_Air'] = T_Air[0:-1]
        self.casadi_data['T_ExtWall'] = T_ExtWall[0:-1]
        self.casadi_data['T_IntWall'] = T_IntWall[0:-1]
        self.casadi_data['T_Win'] = T_Win[0:-1]
        self.casadi_data['T_Tabs'] = T_Tabs[0:-1]
        self.casadi_data['T_Roof'] = T_Roof[0:-1]



if __name__ == '__main__':
    path_mapping = r"D:\Git_Repos\MPC_Geothermie\dissemination\evaluation-of-ai-based-control-applications\data\mapping_disturbance_generation.json"
    path_fmu = r"D:\Git_Repos\MPC_Geothermie\dissemination\evaluation-of-ai-based-control-applications\fmu\ashrae140_900_set_point_fmu.fmu"
    path_to_mos ="D:/Git_Repos/AixLib_benchmark/AixLib/Systems/EONERC_MainBuilding/BaseClasses/ASHRAE140_900.mo"
    path_to_sol_opts= "D:/Git_Repos/MPC_Geothermie/dissemination/evaluation-of-ai-based-control-applications/physical_mpc/setup/controller_options.json"

    # validate Model
    Model = ThermalZone(path_to_mos=path_to_mos,path_sol_opts=path_to_sol_opts,N=10,dt=120)
    Model.validate_model(path_to_fmu=path_fmu,path_mapping=path_mapping,dt=120)

    plt.plot(Model.simulation_data['thermalZone1.TAir'],label='Modelica')
    plt.plot(Model.casadi_data['T_Air'],label='Casadi T_Air')
    plt.legend()
    plt.show()

    plt.plot(Model.simulation_data['thermalZone1.ROM.intWallRC.thermCapInt[1].T'],label='Modelica')
    plt.plot(Model.casadi_data['T_IntWall'],label='Casadi Int Wall')
    plt.legend()
    plt.show()

    plt.plot(Model.simulation_data['thermalZone1.ROM.extWallRC.thermCapExt[1].T'],label='Modelica')
    plt.plot(Model.casadi_data['T_ExtWall'],label='Casadi Ext Wall')
    plt.legend()
    plt.show()

    plt.plot(Model.simulation_data['tabs1.heatCapacitor.T'],label='Modelica')
    plt.plot(Model.casadi_data['T_Tabs'],label='Casadi Tabs')
    plt.legend()
    plt.show()

    plt.plot(Model.simulation_data['thermalZone1.ROM.roofRC.thermCapExt[1].T'],label='Modelica')
    plt.plot(Model.casadi_data['T_Roof'],label='Casadi T_Roof')
    plt.legend()
    plt.show()
