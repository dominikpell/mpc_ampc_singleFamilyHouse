import pandas as pd
import numpy as np
import sys
np.set_printoptions(threshold=sys.maxsize)
from math import *
from scipy.constants import *
from pyomo.environ import *
from pyomo.dae import *
import pickle as pk

from interpolation import sample
import parameters as get_params
import LinearRegressionCOP as get_COP

class Creator:
    def __init__(self, device_options, start_time, control_horizon, prediction_horizon, time_step, year, hour_of_year, parameters, devs, initials):
        self.device_options = device_options
        self.start_time = start_time
        self.control_horizon = control_horizon
        self.prediction_horizon = prediction_horizon
        self.time_step = time_step
        self.year = year
        self.hour_of_year = hour_of_year
        self.parameters = parameters
        self.devs = devs
        self.initials = initials

    def __buildHouseModel__(self):

        model = AbstractModel()
        model.time_steps = ContinuousSet()
        model = self.create_model(model)
        # for i in range(self.device_options["n_tz"]):
        self.calc_resistances()
        model = self.create_tz(model)
        model = self.create_ufh(model)
        self.model = model

        return

    def calc_resistances(self):
        """ Calculate simplified Heat Transfers based on Modelica Model 4 C Model
        """
        self.get_par()

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
        self.splitExtIG = AExttot / (Atot)
        self.splitWinIG = AWintot / (Atot)
        self.splitRoofIG = ARooftot / (Atot)
        self.splitFloorIG = AFloortot / (Atot)

        # Calculate Splitfactors for UFH
        self.splitIntUFH = AInttot / (Atot-AFloortot)
        self.splitExtUFH = AExttot / (Atot-AFloortot)
        self.splitWinUFH = AWintot / (Atot-AFloortot)
        self.splitRoofUFH = ARooftot / (Atot-AFloortot)
        self.splitFloorUFH = 0

        # Calculate Splitfactors for Solar Radiation
        # (Compared to the Modelica Model we don't calculate n_orientation*n_components Splitfactors, instead we average over all orientations
        # to keep the model simple)
        self.splitIntSol = (AInttot - AIntMean)/(Atot - AMeanTot)
        self.splitRoofSol = (ARooftot - ARoofMean)/(Atot - AMeanTot)
        self.splitExtSol = (AExttot - AExtMean)/(Atot - AMeanTot)
        self.splitWinSol = (AWintot - AWinMean)/(Atot - AMeanTot)
        self.splitFloorSol = (AFloortot - AFloorMean)/(Atot - AMeanTot)

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

        return

    def create_model(self, model):

        model.time_steps = ContinuousSet()
        model.constraints = ConstraintList()

        # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        """ Parameters and Variables """
        self.T_Air_tol = 1.0
        self.big_M = 1000000
        self.m_flow_nominal_UFH = 9710/4180/7  # kg/s
        self.m_flow_nominal_HP = 0.21 * 1  # kg/s * designfactor
        self.lamda = 0.598
        self.k_HE = 450  # W/m²K
        self.A_HE = 2  # m²

        # demands and time series
        model.dem_elec = Param(model.time_steps, mutable=True)
        model.dem_e_mob = Param(model.time_steps, mutable=True)
        model.dem_dhw_m_flow = Param(model.time_steps, mutable=True)
        model.dem_dhw_T = Param(model.time_steps, mutable=True)

        model.ts_T_air = Param(model.time_steps, mutable=True)
        model.ts_sol_rad = Param(model.time_steps, mutable=True)
        model.ts_win_spe = Param(model.time_steps, mutable=True)
        model.ts_T_inside_max = Param(model.time_steps, mutable=True)
        model.ts_T_inside_min = Param(model.time_steps, mutable=True)
        model.ts_gains_human = Param(model.time_steps, mutable=True)
        model.ts_gains_dev = Param(model.time_steps, mutable=True)
        model.ts_gains_light = Param(model.time_steps, mutable=True)
        model.ts_powerPV = Param(model.time_steps, mutable=True)

        # model.TsUFH = Param(model.time_steps, mutable=True)
        # model.TrUFH = Param(model.time_steps, mutable=True)
        # model.QConvUFH = Param(model.time_steps, mutable=True)
        # model.QRadUFH = Param(model.time_steps, mutable=True)
        # model.TRad = Param(model.time_steps, mutable=True)
        # model.TRaum = Param(model.time_steps, mutable=True)
        # model.QpanelSeg1 = Param(model.time_steps, mutable=True)
        # model.QpanelSeg2 = Param(model.time_steps, mutable=True)
        # model.TCapa1 = Param(model.time_steps, mutable=True)
        # model.TCapa2 = Param(model.time_steps, mutable=True)
        # model.T_UFH = Param(model.time_steps, mutable=True)
        # model.QBoden = Param(model.time_steps, mutable=True)

        # Eletrical power to/from building
        # Grid maximum transmission power
        model.grid_limit_el = Var(initialize=0, within=NonNegativeReals, name="grid_limit_el")
        # Total energy amounts imported from grid
        model.from_grid_total = Var(initialize=0, within=NonNegativeReals, name="from_grid_total")
        # Total power to grid
        model.to_grid_total = Var(initialize=0, within=NonNegativeReals, name="to_grid_total")

        model.el_costs = Var(initialize=0, within=NonNegativeReals, name="el_costs")
        model.el_revenue = Var(initialize=0, within=NonNegativeReals, name="el_revenue")
        model.costs_discomfort = Var(initialize=0, within=NonNegativeReals, name="costs_discomfort")

        # %% BUILDING VARIABLES
        # Eletrical power to/from devices
        model.power_HP = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_HP")
        model.power_HP_heat = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_HP_heat")
        model.power_HP_cool = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_HP_cool")
        model.power_rod = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_rod")
        model.power_PV = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_PV")
        model.power_to_grid = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_to_grid")
        model.power_from_grid = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_from_grid")
        model.power_use_PV = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_use_PV")
        model.PV_Distr_Use = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="PV_Distr_Use")
        model.PV_Distr_FeedIn = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="PV_Distr_FeedIn")
        model.PV_Distr_ChBat = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="PV_Distr_ChBat")
        model.power_use_BAT = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_use_BAT")
        model.power_to_grid_PV = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_to_grid_PV")
        model.power_to_grid_BAT = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_to_grid_BAT")
        model.power_to_BAT_PV = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_to_BAT_PV")
        model.power_to_BAT_from_grid = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="power_to_BAT_from_grid")

        # HP
        model.COP_HP_heat = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="COP_HP_heat")
        model.COP_HP_cool = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="COP_HP_cool")
        model.x_HP_heat = Var(model.time_steps, within=Binary, name='x_HP_heat')
        model.x_HP_cool = Var(model.time_steps, within=Binary, name='x_HP_cool')
        model.cool_HP = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="cool_HP")
        model.heat_HP = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="heat_HP")
        model.T_supply_HP_heat = Var(model.time_steps, initialize=290, bounds=(273.15+25, 273.15+55), name="T_supply_HP_heat")
        model.T_supply_heat = Var(model.time_steps, initialize=290, bounds=(273.15+15, self.devs["TES"]["t_max"] + 10), name="T_supply_heat")
        model.T_return_heat = Var(model.time_steps, initialize=290, bounds=(self.devs["TES"]["t_min"], self.devs["TES"]["t_max"]), name="T_return_heat")
        model.T_supply_cool = Var(model.time_steps, initialize=290, bounds=(273.15+15, self.devs["TES"]["t_max"] + 10), name="T_supply_cool")
        model.T_return_cool = Var(model.time_steps, initialize=290, bounds=(self.devs["TES"]["t_min"], self.devs["TES"]["t_max"]), name="T_return_cool")

        # Heating Rod
        model.heat_rod = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="heat_rod")

        # UFH
        model.T_return_UFH = Var(model.time_steps, initialize=290, bounds=(self.devs["TES"]["t_min"], self.devs["TES"]["t_max"]), name="T_return_UFH")
        model.T_supply_UFH = Var(model.time_steps, initialize=290, bounds=(self.devs["TES"]["t_min"], self.devs["TES"]["t_max"]), name="T_supply_UFH")

        # Storage devices
        model.T_lay4_TES = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_lay4_TES")
        model.T_lay3_TES = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_lay3_TES")
        model.T_lay2_TES = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_lay2_TES")
        model.T_lay1_TES = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_lay1_TES")
        model.T_layHE4_TES = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_layHE4_TES")
        model.T_layHE3_TES = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_layHE3_TES")
        model.T_layHE2_TES = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_layHE2_TES")
        model.T_layHE1_TES = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_layHE1_TES")

        model.Q_he4_TES = Var(model.time_steps, initialize=0, within=Reals, name="Q_he4_TES")
        model.Q_loss4_TES = Var(model.time_steps, initialize=0, within=Reals, name="Q_loss4_TES")
        model.Q_34_TES = Var(model.time_steps, initialize=0, within=Reals, name="Q_34_TES")
        model.Q_he3_TES = Var(model.time_steps, initialize=0, within=Reals, name="Q_he3_TES")
        model.Q_loss3_TES = Var(model.time_steps, initialize=0, within=Reals, name="Q_loss3_TES")
        model.Q_23_TES = Var(model.time_steps, initialize=0, within=Reals, name="Q_23_TES")
        model.Q_he2_TES = Var(model.time_steps, initialize=0, within=Reals, name="Q_he2_TES")
        model.Q_loss2_TES = Var(model.time_steps, initialize=0, within=Reals, name="Q_loss2_TES")
        model.Q_12_TES = Var(model.time_steps, initialize=0, within=Reals, name="Q_12_TES")
        model.Q_he1_TES = Var(model.time_steps, initialize=0, within=Reals, name="Q_he1_TES")
        model.Q_loss1_TES = Var(model.time_steps, initialize=0, within=Reals, name="Q_loss1_TES")

        model.T_lay4_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_lay4_DHW")
        model.T_lay3_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_lay3_DHW")
        model.T_lay2_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_lay2_DHW")
        model.T_lay1_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_lay1_DHW")
        model.T_layHE4_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_layHE4_DHW")
        model.T_layHE3_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_layHE3_DHW")
        model.T_layHE2_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_layHE2_DHW")
        model.T_layHE1_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="T_layHE1_DHW")

        model.Q_he4_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="Q_he4_DHW")
        model.Q_loss4_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="Q_loss4_DHW")
        model.Q_34_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="Q_34_DHW")
        model.Q_he3_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="Q_he3_DHW")
        model.Q_loss3_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="Q_loss3_DHW")
        model.Q_23_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="Q_23_DHW")
        model.Q_he2_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="Q_he2_DHW")
        model.Q_loss2_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="Q_loss2_DHW")
        model.Q_12_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="Q_12_DHW")
        model.Q_he1_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="Q_he1_DHW")
        model.Q_loss1_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="Q_loss1_DHW")


        model.soc_TES = Var(model.time_steps, initialize=0, bounds=(0, 1), name="soc_TES")
        model.x_TES_ch = Var(model.time_steps, within=Binary, name='x_TES_ch')
        model.ch_TES = Var(model.time_steps, initialize=0, within=Reals, name="ch_TES")
        model.dch_TES = Var(model.time_steps, initialize=0, within=Reals, name="dch_TES")
        model.t_TES = Var(model.time_steps, initialize=290, bounds=(self.devs["TES"]["t_min"], self.devs["TES"]["t_max"]), name="t_TES")  # Average Temperature of TES
        model.t_Pinch_TES = Var(model.time_steps, initialize=2, within=Reals, name="t_Pinch_ch_TES_heat")
        model.heat_loss_TES = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="heat_loss_TES")

        model.soc_DHW = Var(model.time_steps, initialize=0, bounds=(0, 1), name="soc_DHW")
        model.x_DHW_ch = Var(model.time_steps, within=Binary, name='x_DHW_ch')
        model.ch_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="ch_DHW")
        model.dch_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="dch_DHW")
        model.t_DHW = Var(model.time_steps, initialize=290, bounds=(self.devs["DHW"]["t_min"], self.devs["DHW"]["t_max"]), name="t_DHW")  # Average Temperature of DHW
        model.t_Pinch_DHW = Var(model.time_steps, initialize=2, within=Reals, name="t_Pinch_DHW")
        model.heat_loss_DHW = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="heat_loss_DHW")

        model.soc_BAT = Var(model.time_steps, initialize=0, bounds=(0, 1), name="soc_BAT")
        model.x_BAT_ch = Var(model.time_steps, within=Binary, name='x_BAT_ch')
        model.x_BAT_dch = Var(model.time_steps, within=Binary, name='x_BAT_dch')
        model.ch_BAT = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="ch_BAT")
        model.dch_BAT = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="dch_BAT")
        model.energy_BAT = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="energy_BAT")

        # residual loads
        model.res_elec = Var(model.time_steps, initialize=0, within=Reals, name="residual_electricity_demand")
        # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        """ Add constraints """
        """ Constraints to disable heating/cooling (HP) and charging/discharging (storage components) at the same time """
        @model.Constraint(model.time_steps)
        def Bin_Heat_Cooling_HP_rule(m, t):
            return (m.x_HP_heat[t] + m.x_HP_cool[t] <= 1) # Either Heating or Cooling with HP

        @model.Constraint(model.time_steps)
        def Bin_ch_TES_or_DHW_rule(m, t):
            return (m.x_TES_ch[t] + m.x_DHW_ch[t] <= m.x_HP_heat[t] + m.x_HP_cool[t]) # if heat pump is active, either charge TES or DHW

        @model.Constraint(model.time_steps)
        def Bin_ch_dch_BAT_rule(m, t):
            return (m.x_BAT_ch[t] + m.x_BAT_dch[t] <= 1) # Either charge or discharge Battery



        """Limits for all components"""
        # HP
        @model.Constraint(model.time_steps)
        def Lim_heat_HP_rule1(m, t):
            return (m.heat_HP[t] <= m.x_HP_heat[t] * self.devs["HP"]["cap"]) # Limits maximum Heat Flow

        @model.Constraint(model.time_steps)
        def Lim_heat_HP_rule2(m, t):
            return (m.heat_HP[t] >= m.x_HP_heat[t]) # Minimum

        @model.Constraint(model.time_steps)
        def Lim_cool_HP_rule1(m, t):
            return (m.cool_HP[t] <= m.x_HP_cool[t] * self.devs["HP"]["cap"]) # Limits maximum Cooling Flow

        @model.Constraint(model.time_steps)
        def Lim_cool_HP_rule2(m, t):
            return (m.cool_HP[t] >= m.x_HP_cool[t]) # Limits maximum Cooling Flow


        # Heating Rod
        @model.Constraint(model.time_steps)
        def Lim_cap_rod_rule(m, t):
            return (m.power_rod[t] <= self.devs["rod"]["cap"]) # Limits Power of the heating rod


        # BAT
        @model.Constraint(model.time_steps)
        def Lim_cap_BAT_rule(m, t):
            return (m.energy_BAT[t] <= self.devs["BAT"]["cap"])  # Limits Energy stored in Battery

        @model.Constraint(model.time_steps)
        def Lim_SOC_min_BAT_rule(m, t):
            return (m.soc_BAT[t] >= self.devs["BAT"]["SOC_min"]) # Minimum SOC

        @model.Constraint(model.time_steps)
        def Lim_Charge_max_BAT_rule(m, t):
            return (m.ch_BAT[t] <= self.devs["BAT"]["P_ch_max"] * m.x_BAT_ch[t]) # Limits discharge power

        @model.Constraint(model.time_steps)
        def Lim_Discharge_max_BAT_rule(m, t):
            return (m.dch_BAT[t] <= self.devs["BAT"]["P_dch_max"] * m.x_BAT_dch[t]) # Limits charge power


        # TES and DHW
        @model.Constraint(model.time_steps)
        def Lim_ch_DHW_rule(m, t):
            return (m.ch_DHW[t] <= m.x_DHW_ch[t] * self.big_M) # Sets limit to 0 if DHW not charged

        @model.Constraint(model.time_steps)
        def Lim_ch_TES_rule1(m, t):
            return (m.ch_TES[t] <= m.x_TES_ch[t] * self.big_M) # Sets limit to 0 if DHW not discharged

        @model.Constraint(model.time_steps)
        def Lim_ch_TES_rule2(m, t):
            return (m.ch_TES[t] >= -m.x_TES_ch[t] * self.big_M) # Sets limit to 0 if DHW not discharged



        """ Energy Balances for all components """
        # Heating Rod
        @model.Constraint(model.time_steps)
        def EB_rod_rule(m, t):
            return (m.heat_rod[t] == m.power_rod[t] * self.devs["rod"]["eta"])


        # HP
        @model.Constraint(model.time_steps)
        def EB_HP_heat_rule(m, t):
            return (m.heat_HP[t] == self.m_flow_nominal_HP * self.parameters["c_f"] * (m.T_supply_HP_heat[t] - m.T_return_heat[t]))

        @model.Constraint(model.time_steps)
        def EB_HP_cool_rule(m, t):
            return (m.cool_HP[t] == self.m_flow_nominal_HP * self.parameters["c_f"] * (m.T_supply_cool[t] - m.T_return_cool[t]))

        # Rod
        @model.Constraint(model.time_steps)
        def EB_HP_rod_heat_rule1(m, t):
            return (m.heat_rod[t] == self.m_flow_nominal_HP * self.parameters["c_f"] * (m.T_supply_heat[t] - m.T_supply_HP_heat[t]))

        # Coupling of HP+Rod and TES/DHW
        @model.Constraint(model.time_steps)
        def EB_HP_rod_heat_rule2(m, t):
            return (m.heat_HP[t] + m.heat_rod[t] - m.cool_HP[t] == m.ch_TES[t] + m.ch_DHW[t])

















        # TES
        @model.Constraint(model.time_steps)
        def dch_TES_rule(m, t):
            return (m.dch_TES[t] == self.m_flow_nominal_UFH * self.parameters["c_f"] * (m.T_supply_UFH[t] - m.T_return_UFH[t]))  # Discharge Heat Flow

        @model.Constraint(model.time_steps)
        def SOC_TES_rule(m, t):
            return (m.soc_TES[t] == (m.t_TES[t] - self.devs["TES"]["t_min"]) / (self.devs["TES"]["t_max"] - self.devs["TES"]["t_min"])) # State of Charge


        # DHW
        @model.Constraint(model.time_steps)
        def Pinch_top_ch_DHW_rule(m, t):
            return (m.T_supply_heat[t] - (m.t_DHW[t] + 1 / 2 * (self.devs["DHW"]["t_max"] - m.t_DHW[t])) >= 2 - (1-m.x_DHW_ch[t])*100) # Pinch Upper Layer

        @model.Constraint(model.time_steps)
        def Pinch_low_ch_DHW_rule(m, t):
            return (m.T_return_heat[t] - (m.t_DHW[t] - 1 / 2 * (m.t_DHW[t] - self.devs["DHW"]["t_min"])) >= 2 - (1-m.x_DHW_ch[t])*100) # Pinch Lower Layer

        @model.Constraint(model.time_steps)
        def Pinch_top_ch_DHW_rule(m, t):
            return (m.T_supply_heat[t] - (m.t_DHW[t] + 2) >= 2 - (1-m.x_DHW_ch[t])*100) # Pinch Upper Layer, 2K in first term is approx. temp difference between avg and top/bot layer

        @model.Constraint(model.time_steps)
        def Pinch_low_ch_DHW_rule(m, t):
            return (m.T_return_heat[t] - (m.t_DHW[t] - 2) >= 2 - (1-m.x_DHW_ch[t])*100) # Pinch Lower Layer, 2K in first term is approx. temp difference between avg and top/bot layer

        @model.Constraint(model.time_steps)
        def T_dch_DHW_rule(m, t):
            return ((m.t_DHW[t] + 2) >= m.dem_dhw_T[t]) # Ensures that DHW is hot enough

        @model.Constraint(model.time_steps)
        def EB_dch_DHW2_rule(m, t):
            return (m.dch_DHW[t] == m.dem_dhw_m_flow[t] * self.parameters["c_f"] * (m.dem_dhw_T[t] - self.devs["DHW"]["t_min"])) # Discharge Heat Flow

        @model.Constraint(model.time_steps)
        def SOC_DHW_rule(m, t):
            return (m.soc_DHW[t] == (m.t_DHW[t] - self.devs["DHW"]["t_min"]) / (self.devs["DHW"]["t_max"] - self.devs["DHW"]["t_min"])) # State of Charge

        @model.Constraint(model.time_steps)
        def T_min_DHW_rule(m, t):
            return (m.t_DHW[t] >= 273.15 + 40)  # To overcome low temperature problem because of averaged dem_dhw_T

        # HP
        @model.Constraint(model.time_steps)
        def EB_HP1_rule(m, t):
            return (m.power_HP[t] == m.power_HP_cool[t] + m.power_HP_heat[t])

        # HP pwl data
        # for heating data
        self.parameters["T_supply_heat_min_heat"] = 25 + 273.15
        self.parameters["T_supply_heat_max_heat"] = 45 + 273.15
        self.parameters["T_supply_heat_min_cool"] = 42 + 273.15
        self.parameters["T_supply_heat_max_cool"] = 45 + 273.15
        if np.mean(get_params.get_T_air_forecast(self.prediction_horizon, self.time_step, self.year, self.hour_of_year))<=273.15+12:
            T_supply_min = 25 + 273.15
            T_supply_max = 45 + 273.15
            T_heat_min = -20 + 273.15
            T_heat_max = 12 + 273.15
        else:
            T_supply_min = 42 + 273.15
            T_supply_max = 45 + 273.15
            T_heat_min = 12 + 273.15
            T_heat_max = 38 + 273.15

        T_supply_points, COP_points = get_COP.LinReg_heat(self.devs["HP"]["eta_COP"], T_supply_min, T_supply_max, T_heat_min, T_heat_max)
        xbreaks = np.array([[np.interp(t, T_supply_points[:, 0], T_supply_points[:, l]) for l in range(1, 4)] for t in get_params.get_T_air_forecast(self.prediction_horizon, self.time_step, self.year, self.hour_of_year)])
        x_breaks = dict(enumerate(xbreaks.tolist()))
        ybreaks = np.array([[np.interp(t, COP_points[:, 0], COP_points[:, l]) for l in range(1, 4)] for t in get_params.get_T_air_forecast(self.prediction_horizon, self.time_step, self.year, self.hour_of_year)])
        y_breaks = dict(enumerate(ybreaks.tolist()))
        # Get COP from PWL relation
        model.pwl_COP1 = Piecewise(model.time_steps, model.COP_HP_heat, model.T_supply_HP_heat, pw_pts=x_breaks, pw_constr_type='EQ', f_rule=y_breaks, pw_repn='SOS2', name="pwlCOP1")

        # for cooling data
        T_supply_min = 15 + 273.15
        T_supply_max = 25 + 273.15
        T_heat_min = 27 + 273.15
        T_heat_max = 45 + 273.15
        T_supply_points, COP_points = get_COP.LinReg_cool(self.devs["HP"]["eta_COP"], T_supply_min, T_supply_max, T_heat_min, T_heat_max)
        xbreaks = np.array([[np.interp(t, T_supply_points[:, 0], T_supply_points[:, l]) for l in range(1, 4)] for t in get_params.get_T_air_forecast(self.prediction_horizon, self.time_step, self.year, self.hour_of_year)])
        x_breaks = dict(enumerate(xbreaks.tolist()))
        ybreaks = np.array([[np.interp(t, COP_points[:, 0], COP_points[:, l]) for l in range(1, 4)] for t in get_params.get_T_air_forecast(self.prediction_horizon, self.time_step, self.year, self.hour_of_year)])
        y_breaks = dict(enumerate(ybreaks.tolist()))


        # Get COP from PWL relation
        model.pwl_COP2 = Piecewise(model.time_steps, model.COP_HP_cool, model.T_supply_cool, pw_pts=x_breaks, pw_constr_type='EQ', f_rule=y_breaks, pw_repn='SOS2', name="pwlCOP2")

        # %% Quadratic transformation
        x_bp = [i for i in np.linspace(1, 20, 6)] # 1.& 2. Range des COP, 3. Anzahl Knickpunkte inkl Start und Endpunkt
        y_bp = [j for j in np.linspace(0, self.devs["HP"]["cap"], 6)] # 1. & 2. Range der HP Power, 3. Anzahl Knickpunkte inkl Start und Endpunkt
        f_xy = np.zeros((len(x_bp), len(y_bp)))
        for i in range(0, len(x_bp)):
            for j in range(0, len(y_bp)):
                f_xy[i, j] = x_bp[i] * y_bp[j]

        # Number of Breakpoints
        n = len(x_bp)
        # X Intervals
        x_int = [i for i in range(-1, n)]
        # Number of Breakpoints
        m = len(y_bp)
        # Y Intervals
        y_int = [i for i in range(0, m)]



        ## HEAT - POWER - COP Relation
        # SOS2 type: two variables > 0 that give the proportion of breakpoints
        model.asos_c_heat = Var(x_int[1:], model.time_steps, within=Reals, bounds=(0.0, 1.0), name="asos_c_heat")
        # Binary that marks the active Interval x
        model.hsos_b_heat = Var(x_int, model.time_steps, within=Binary, name="hsos_b_heat")
        # SOS1 type: Relative position of Y on Interval y
        model.gsos_c_heat = Var(y_int[:-1], model.time_steps, within=Reals, bounds=(0.0, 1.0), name="gsos_c_heat")
        # Binary that marks the active Interval y
        model.bsos_b_heat = Var(y_int[:-1], model.time_steps, within=Binary, name="bsos_b_heat")

        # 4 Only one Interval Binary can be = 1
        @model.Constraint(model.time_steps)
        def pwl_rule41(m, t):
            return (sum(m.hsos_b_heat[i, t] for i in x_int[1:-1]) == 1)

        @model.Constraint(model.time_steps)
        def pwl_rule42(m, t):
            return (m.hsos_b_heat[- 1, t] == 0)

        @model.Constraint(model.time_steps)
        def pwl_rule43(m, t):
            return (m.hsos_b_heat[n - 1, t] == 0)

        # 5 Breakpoint SOS2 Variable can only be active if the Interval before or after is active
        @model.Constraint(model.time_steps, x_int[1:])
        def pwl_rule5(m, t, i):
            return (m.asos_c_heat[i, t] <= m.hsos_b_heat[i - 1, t] + m.hsos_b_heat[i, t])

        # 6 The sum of SOS2 Variables is = 1
        @model.Constraint(model.time_steps)
        def pwl_rule6(m, t):
            return (sum(m.asos_c_heat[i, t] for i in x_int[1:]) == 1)

        # 7 X = a combination of the proportion of 2 SOS2 Variables
        @model.Constraint(model.time_steps)
        def pwl_rule7(m, t):
            return (m.COP_HP_heat[t] == sum(m.asos_c_heat[i, t] * x_bp[i] for i in x_int[1:]))

        # 11 Just one Intervall binary can be = 1
        @model.Constraint(model.time_steps)
        def pwl_rule11(m, t):
            return (sum(m.bsos_b_heat[j, t] for j in y_int[:-1]) == 1)

        # 23 Y = the sum off all y Intervals with only one having bigger values for Beta and Gamma. Y is then = the Interpolation of the to breakpoints
        @model.Constraint(model.time_steps)
        def pwl_rule23(m, t):
            return (m.power_HP_heat[t] == sum(m.bsos_b_heat[j, t] * y_bp[j] + m.gsos_c_heat[j, t] * (y_bp[j + 1] - y_bp[j]) for j in y_int[:-1]))

        # 24 Gamma can only be > in the chosen Interval y, with Binary Beta = 1
        @model.Constraint(model.time_steps, y_int[:-1])
        def pwl_rule24(m, t, j):
            return (m.gsos_c_heat[j, t] <= m.bsos_b_heat[j, t])

        # 25 f(x,y) =
        @model.Constraint(model.time_steps, x_int[1:-1], y_int[:-1])
        def pwl_rule25(m, t, i, j):
            return (m.heat_HP[t] <= sum(m.asos_c_heat[k, t] * f_xy[k, j] for k in x_int[1:])
                    + m.gsos_c_heat[j, t] * np.mean([f_xy[i, j + 1] - f_xy[i, j], f_xy[i + 1, j + 1] - f_xy[i + 1, j]])
                    + self.big_M * (2 - m.bsos_b_heat[j, t] - m.hsos_b_heat[i, t]))

        # 26 f(x,y) =
        @model.Constraint(model.time_steps, y_int[:-1], x_int[1:-1])
        def pwl_rule26(m, t, j, i):
            return (m.heat_HP[t] >= sum(m.asos_c_heat[k, t] * f_xy[k, j] for k in x_int[1:]) + m.gsos_c_heat[
                j, t] * np.mean([f_xy[i, j + 1] - f_xy[i, j], f_xy[i + 1, j + 1] - f_xy[i + 1, j]]) - self.big_M * (
                            2 - m.bsos_b_heat[j, t] - m.hsos_b_heat[i, t]))

        ## COOLING - POWER - COP Relation
        # SOS2 type: two variables > 0 that give the proportion of breakpoints
        model.asos_c_cool = Var(x_int[1:], model.time_steps, within=Reals, bounds=(0.0, 1.0), name="asos_c_cool")
        # Binary that marks the active Interval x
        model.hsos_b_cool = Var(x_int, model.time_steps, within=Binary, name="hsos_b_cool")
        # SOS1 type: Relative position of Y on Interval y
        model.gsos_c_cool = Var(y_int[:-1], model.time_steps, within=Reals, bounds=(0.0, 1.0), name="gsos_c_cool")
        # Binary that marks the active Interval y
        model.bsos_b_cool = Var(y_int[:-1], model.time_steps, within=Binary, name="bsos_b_cool")

        # 4 Only one Interval Binary can be = 1
        @model.Constraint(model.time_steps)
        def pwl_rule412(m, t):
            return (sum(m.hsos_b_cool[i, t] for i in x_int[1:-1]) == 1)

        @model.Constraint(model.time_steps)
        def pwl_rule422(m, t):
            return (m.hsos_b_cool[- 1, t] == 0)

        @model.Constraint(model.time_steps)
        def pwl_rule432(m, t):
            return (m.hsos_b_cool[n - 1, t] == 0)

        # 5 Breakpoint SOS2 Variable can only be active if the Interval before or after is active
        @model.Constraint(model.time_steps, x_int[1:])
        def pwl_rule52(m, t, i):
            return (m.asos_c_cool[i, t] <= m.hsos_b_cool[i - 1, t] + m.hsos_b_cool[i, t])

        # 6 The sum of SOS2 Variables is = 1
        @model.Constraint(model.time_steps)
        def pwl_rule62(m, t):
            return (sum(m.asos_c_cool[i, t] for i in x_int[1:]) == 1)

        # 7 X = a combination of the proportion of 2 SOS2 Variables
        @model.Constraint(model.time_steps)
        def pwl_rule72(m, t):
            return (m.COP_HP_cool[t] == sum(m.asos_c_cool[i, t] * x_bp[i] for i in x_int[1:]))

        # 11 Just one Intervall binary can be = 1
        @model.Constraint(model.time_steps)
        def pwl_rule112(m, t):
            return (sum(m.bsos_b_cool[j, t] for j in y_int[:-1]) == 1)

        # 23 Y = the sum off all y Intervals with only one having bigger values for Beta and Gamma. Y is then = the Interpolation of the to breakpoints
        @model.Constraint(model.time_steps)
        def pwl_rule232(m, t):
            return (m.power_HP_cool[t] == sum(
                m.bsos_b_cool[j, t] * y_bp[j] + m.gsos_c_cool[j, t] * (y_bp[j + 1] - y_bp[j]) for j in y_int[:-1]))

        # 24 Gamma can only be > in the chosen Interval y, with Binary Beta = 1
        @model.Constraint(model.time_steps, y_int[:-1])
        def pwl_rule242(m, t, j):
            return (m.gsos_c_cool[j, t] <= m.bsos_b_cool[j, t])

        # 25 f(x,y) =
        @model.Constraint(model.time_steps, x_int[1:-1], y_int[:-1])
        def pwl_rule252(m, t, i, j):
            return (m.cool_HP[t] <= sum(m.asos_c_cool[k, t] * f_xy[k, j] for k in x_int[1:])
                    + m.gsos_c_cool[j, t] * np.mean([f_xy[i, j + 1] - f_xy[i, j], f_xy[i + 1, j + 1] - f_xy[i + 1, j]])
                    + self.big_M * (2 - m.bsos_b_cool[j, t] - m.hsos_b_cool[i, t]))

        # 26 f(x,y) =
        @model.Constraint(model.time_steps, y_int[:-1], x_int[1:-1])
        def pwl_rule262(m, t, j, i):
            return (m.cool_HP[t] >= sum(m.asos_c_cool[k, t] * f_xy[k, j] for k in x_int[1:]) + m.gsos_c_cool[
                j, t] * np.mean([f_xy[i, j + 1] - f_xy[i, j], f_xy[i + 1, j + 1] - f_xy[i + 1, j]]) - self.big_M * (
                            2 - m.bsos_b_cool[j, t] - m.hsos_b_cool[i, t]))

        # Blocking hours
        # blocking_hours = []
        # for x in [12, 13, 16, 17]:  # 12-13h, 13-14h, 16-17h, 17-18h
        #     if x - hour < 0:
        #         blocking_hours.append(x - hour + prediction_horizon)
        #     else:
        #         blocking_hours.append(x - hour)
        # for t in blocking_hours:
        #     Constr(power["HP"][t] == 0, name="HP_blocking_time")

        # PV
        @model.Constraint(model.time_steps)
        def EB_PV1(m, t):
            return (m.ts_powerPV[t] == m.power_use_PV[t] + m.power_to_grid_PV[t] + m.power_to_BAT_PV[t])

        # BAT
        @model.Constraint(model.time_steps)
        def EB_BAT1(m, t):
            return (m.dch_BAT[t] == m.power_use_BAT[t] + m.power_to_grid_BAT[t])

        @model.Constraint(model.time_steps)
        def EB_BAT2(m, t):
            return (m.ch_BAT[t] == m.power_to_BAT_PV[t] + m.power_to_BAT_from_grid[t])

        @model.Constraint(model.time_steps)
        def SOC_BAT(m, t):
            return (m.soc_BAT[t] == m.energy_BAT[t] / self.devs["BAT"]["cap"])


        """ BALANCING UNIT CONSTRAINTS """
        # GRID CONSTRAINTS
        @model.Constraint(model.time_steps)
        def EB_Grid1(m, t):
            return (m.power_from_grid[t] <= m.grid_limit_el)
        @model.Constraint(model.time_steps)
        def EB_Grid2(m, t):
            return (m.power_to_grid[t] <= m.grid_limit_el)

        """ Energy Balances (Building) """
        # RESIDUAL ELECTRICITY LOAD
        @model.Constraint(model.time_steps)
        def EB_Res_el(m, t):
            return (m.res_elec[t] == m.dem_elec[t] + m.dem_e_mob[t] + m.power_HP[t] + m.power_rod[t])

        @model.Constraint(model.time_steps)
        def EB_Elec1(m, t):
            return (m.power_use_PV[t] + m.power_use_BAT[t] + m.power_from_grid[t] == m.res_elec[t])

        @model.Constraint(model.time_steps)
        def EB_Elec2(m, t):
            return (m.power_to_grid[t] == m.power_to_grid_PV[t] + m.power_to_grid_BAT[t])

        return model

    def create_tz(self, model):
        '''Parameters'''
        self.fac_Q_rad = 1
        self.fac_IG = 1
        self.ventRate = 0.2  # infiltration of 0.2 1/h
        self.rho_Air = 1.25 # density of air
        #model.time_steps = ContinuousSet()

        # --- states
        model.T_Air = Var(model.time_steps, initialize=293.15, bounds=(273.15, 330), name="T_Air")
        model.T_Air_dot = DerivativeVar(model.T_Air, initialize=0, wrt=model.time_steps, name="T_Air_dot")
        model.T_Roof = Var(model.time_steps, initialize=290, bounds=(273.15, 330), name="T_Roof")
        if self.has_roof:
            model.T_Roof_dot = DerivativeVar(model.T_Roof, initialize=0, wrt=model.time_steps, name="T_Roof_dot")
        model.T_Floor = Var(model.time_steps, initialize=290, bounds=(273.15, 330), name="T_Floor")
        if self.has_floor:
            model.T_Floor_dot = DerivativeVar(model.T_Floor, initialize=0, wrt=model.time_steps, name="T_Floor_dot")
        model.T_ExtWall = Var(model.time_steps, initialize=290, bounds=(273.15, 330), name="T_ExtWall")
        model.T_ExtWall_dot = DerivativeVar(model.T_ExtWall, initialize=0, wrt=model.time_steps, name="T_ExtWall_dot")
        model.T_IntWall = Var(model.time_steps, initialize=290, bounds=(273.15, 330), name="T_IntWall")
        model.T_IntWall_dot = DerivativeVar(model.T_IntWall, initialize=0, wrt=model.time_steps, name="T_IntWall_dot")
        model.T_Win = Var(model.time_steps, initialize=290, bounds=(273.15, 330), name="T_Win")
        model.T_Win_dot = DerivativeVar(model.T_Win, initialize=0, wrt=model.time_steps, name="T_Win_dot")
        model.t_rad = Var(model.time_steps, initialize=0, bounds=(273.15, 330), name="t_rad")

        # --- algebraic Variables
        model.Q_ig_conv = Var(model.time_steps, initialize=0, bounds=(-1000000, 1000000), name="Q_ig_conv")
        model.Q_ig_rad = Var(model.time_steps, initialize=0, bounds=(-1000000, 1000000), name="Q_ig_rad")
        model.Q_UFH = Var(model.time_steps, initialize=0, bounds=(-1000000, 1000000), name="Q_UFH")
        model.Q_conv_UFH = Var(model.time_steps, initialize=0, bounds=(-1000000, 1000000), name="Q_UFH")
        model.Q_rad_UFH = Var(model.time_steps, initialize=0, bounds=(-1000000, 1000000), name="Q_UFH")
        model.eps_Air_neg = Var(model.time_steps, initialize=0, bounds=(0, 10), name="eps_Air_neg")
        model.eps_Air_pos = Var(model.time_steps, initialize=0, bounds=(0, 10), name="eps_Air_pos")
        model.vio_Kh = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="vio_Kh")

        # --- disturbances
        model.Q_solar_rad = Param(model.time_steps, mutable=True)
        model.Q_solar_conv = Param(model.time_steps, mutable=True)
        model.T_preTemWin = Param(model.time_steps, mutable=True)
        model.T_preTemWall = Param(model.time_steps, mutable=True)
        if self.has_roof:
            model.T_preTemRoof = Param(model.time_steps, mutable=True)
        if self.has_floor:
            model.T_preTemFloor = Param(model.time_steps, mutable=True)

        # --- algebraic eq:
        def q_ig_conv(m, t):
            return m.Q_ig_conv[t] ==  (((0.865 - (0.025 * (m.T_Air[t] - 273.15))) * (self.activityDegree * 58 * 1.8) + 35) *
                                       self.specPers * self.ARoom * self.ratioConv_human * m.ts_gains_human[t] +
                                       self.ARoom * self.internalGainsMachinesSpecific * m.ts_gains_dev[t] * self.ratioConvectiveHeatMachines +
                                       self.ARoom * self.lightingPowerSpecific * m.ts_gains_light[t] * self.ratioConvectiveHeatLighting)*self.fac_IG
        model.q_ig_conv_con = Constraint(model.time_steps, rule= q_ig_conv)

        def q_ig_rad(m, t):
            return m.Q_ig_rad[t] == (((0.865 - (0.025 * (m.T_Air[t] - 273.15))) * ( self.activityDegree * 58 * 1.8) + 35) *
                                      self.specPers * self.ARoom * self.ratioConv_human * m.ts_gains_human[t] * (1 - self.ratioConv_human) / self.ratioConv_human +
                                      self.ARoom * self.internalGainsMachinesSpecific * m.ts_gains_dev[t] * self.ratioConvectiveHeatMachines* (1 - self.ratioConvectiveHeatMachines) / self.ratioConvectiveHeatMachines +
                                      self.ARoom * self.lightingPowerSpecific * m.ts_gains_light[t] * self.ratioConvectiveHeatLighting* (1 - self.ratioConvectiveHeatLighting) / self.ratioConvectiveHeatLighting)*self.fac_IG
        model.q_ig_rad_con = Constraint(model.time_steps, rule= q_ig_rad)

        # --- diff Eq:
        def t_air_con(m,t):
            return m.T_Air_dot[t] == (1 / self.CAir) * self.time_step * 3600 * ((m.T_Roof[t] - m.T_Air[t]) * self.k_Roof_Air +
                                                         (m.T_ExtWall[t] - m.T_Air[t]) * self.k_Ext_Air +
                                                         (m.T_IntWall[t] - m.T_Air[t]) * self.k_Int_Air +
                                                         (m.T_Win[t] - m.T_Air[t]) * self.k_Win_Air +
                                                         (m.T_Floor[t] - m.T_Air[t]) * self.k_Floor_Air +
                                                         + m.Q_ig_conv[t]
                                                         + m.Q_solar_conv[t]* self.fac_Q_rad
                                                         + m.Q_conv_UFH[t]
                                                         + self.ventRate/3600 * self.VAir * self.c_spec_Air * self.rho_Air * (m.ts_T_air[t] - m.T_Air[t]))
                                                         # - m.ventRate[t]/3600 * self.VAir * c* rho_Air=1.25 * (m.T_Air[t] - m.ts_T_air[t])                         )
        model.t_air_con = Constraint(model.time_steps, rule=t_air_con)

        if self.has_roof:
            # set differential equation for Roof if it exits
            def t_roof_con(m,t):
                return m.T_Roof_dot[t] == ( 1 / self.CRoof ) * self.time_step * 3600 * ((m.T_Air[t] - m.T_Roof[t])*self.k_Air_Roof
                                        + (m.T_ExtWall[t] - m.T_Roof[t])*self.k_Ext_Roof
                                        + (m.T_IntWall[t] - m.T_Roof[t])*self.k_Int_Roof
                                        + (m.T_preTemRoof[t] - m.T_Roof[t])*self.k_Amb_Roof
                                        + (m.T_Win[t] - m.T_Roof[t])*self.k_Win_Roof
                                        + (m.T_Floor[t] - m.T_Roof[t]) * self.k_Floor_Roof
                                        + self.splitRoofSol * m.Q_solar_rad[t]*self.fac_Q_rad
                                        + self.splitRoofIG * m.Q_ig_rad[t]
                                        + self.splitRoofUFH * m.Q_rad_UFH[t])
        else:
            # set Roof temperature to default
            def t_roof_con(m, t):
                return m.T_Roof[t] == 293
        model.t_roof_con = Constraint(model.time_steps, rule=t_roof_con)

        if self.has_floor:
            # set differential equation for Floor if it exists
            def t_floor_con(m,t):
                return m.T_Floor_dot[t] == (1 / self.CFloor) * self.time_step*3600 * ((m.T_Air[t] - m.T_Floor[t])*self.k_Air_Floor
                                                                + (m.T_ExtWall[t] - m.T_Floor[t])*self.k_Ext_Floor
                                                                + (m.T_Win[t] - m.T_Floor[t])*self.k_Win_Floor
                                                                + (m.T_Roof[t] - m.T_Floor[t])*self.k_Roof_Floor
                                                                + (m.T_IntWall[t] - m.T_Floor[t])*self.k_Int_Floor
                                                                + (m.T_preTemFloor[t] - m.T_Floor[t])*self.k_Soil_Floor
                                                                + self.splitFloorSol * m.Q_solar_rad[t]*self.fac_Q_rad
                                                                + self.splitFloorIG * m.Q_ig_rad[t]
                                                                + self.splitFloorUFH * m.Q_rad_UFH[t])
        else:
            # set Floor temperature to default
            def t_floor_con(m,t):
                return m.T_Floor[t] == 287.15
        model.t_floor_con = Constraint(model.time_steps, rule=t_floor_con)

        def t_exWall_con(m,t):
            return m.T_ExtWall_dot[t] == ( 1 / self.CExt) * self.time_step * 3600 *((m.T_Air[t] - m.T_ExtWall[t])*self.k_Air_Ext
                                         + (m.T_Roof[t] - m.T_ExtWall[t])*self.k_Roof_Ext
                                         + (m.T_IntWall[t] - m.T_ExtWall[t])*self.k_Int_Ext
                                         + (m.T_preTemWall[t] - m.T_ExtWall[t])*self.k_Amb_Ext
                                         + (m.T_Win[t] - m.T_ExtWall[t])*self.k_Win_Ext
                                         + (m.T_Floor[t] - m.T_ExtWall[t])*self.k_Floor_Ext
                                         + self.splitExtSol * m.Q_solar_rad[t]*self.fac_Q_rad
                                         + self.splitExtIG * m.Q_ig_rad[t]
                                         + self.splitExtUFH * m.Q_rad_UFH[t])
        model.t_exWall_con = Constraint(model.time_steps, rule= t_exWall_con)

        def t_inWall_con(m,t):
            return m.T_IntWall_dot[t] == (1 / self.CInt) * self.time_step * 3600 *((m.T_Air[t] - m.T_IntWall[t])*self.k_Air_Int
                                         + (m.T_ExtWall[t] - m.T_IntWall[t])*self.k_Ext_Int
                                         + (m.T_Roof[t] - m.T_IntWall[t])*self.k_Roof_Int
                                         + (m.T_Win[t] - m.T_IntWall[t])*self.k_Win_Int
                                         + (m.T_Floor[t] - m.T_IntWall[t]) * self.k_Floor_Int
                                         + self.splitIntSol*m.Q_solar_rad[t]*self.fac_Q_rad
                                         + self.splitIntIG* m.Q_ig_rad[t]
                                         + self.splitIntUFH * m.Q_rad_UFH[t])
        model.t_inWall_con = Constraint(model.time_steps, rule= t_inWall_con)

        def t_Win_con(m,t):
            return m.T_Win_dot[t] == (1/self.CWin)* self.time_step * 3600 * ((m.T_Air[t] - m.T_Win[t])*self.k_Win_Air
                                   + (m.T_Roof[t] - m.T_Win[t])*self.k_Win_Roof
                                   + (m.T_ExtWall[t] -m.T_Win[t])*self.k_Win_Ext
                                   + (m.T_IntWall[t] - m.T_Win[t])*self.k_Win_Int
                                   + (m.T_Floor[t] - m.T_Win[t]) * self.k_Win_Floor
                                   + (m.T_preTemWin[t] - m.T_Win[t])*self.k_Amb_Win
                                   + self.splitWinSol * m.Q_solar_rad[t]*self.fac_Q_rad
                                   + self.splitWinIG * m.Q_ig_rad[t]
                                   + self.splitWinUFH * m.Q_rad_UFH[t])
        model.t_Win_con = Constraint(model.time_steps, rule=t_Win_con)

        def t_rad_rule(m,t):
            return (m.t_rad[t] == m.T_Win[t] * self.splitWinIG
                                + m.T_IntWall[t] * self.splitIntIG
                                + m.T_ExtWall[t] * self.splitExtIG
                                + m.T_Floor[t] * self.splitFloorIG
                                + m.T_Roof[t] * self.splitRoofIG)
        model.t_rad_rule = Constraint(model.time_steps, rule= t_rad_rule)

        # thermal comfort bounds
        def T_Air_rule1(m, t):
            return (m.T_Air[t] <= m.ts_T_inside_max[t] + m.eps_Air_pos[t])
        model.T_Air_rule1 = Constraint(model.time_steps, rule=T_Air_rule1)

        def T_Air_rule2(m, t):
            return (m.T_Air[t] >= m.ts_T_inside_min[t] - m.eps_Air_neg[t])
        model.T_Air_rule2 = Constraint(model.time_steps, rule=T_Air_rule2)

        def vio_Kh_rule(m, t):
            return (m.vio_Kh[t] == self.time_step * (m.eps_Air_pos[t] + m.eps_Air_neg[t]))
        model.vio_Kh_rule = Constraint(model.time_steps, rule=vio_Kh_rule)

        return model


    def create_ufh(self, model):
        '''Parameters'''


        self.spacing = 0.2
        self.diameter = 0.018
        self.A = 99.75
        self.eps = 0.9
        self.tube_length = self.A/self.spacing
        self.k_top = 100 #4.47
        self.k_down = 0.37
        self.A_part = self.tube_length * self.diameter * pi/2
        self.kA_top = self.k_top * self.A_part
        self.kA_down = self.k_down * self.A_part
        self.C_ActivatedElement = 8024814.61230118 # 8024814.61230118
        self.c_top_ratio = 0.15
        self.c_top = self.c_top_ratio * self.C_ActivatedElement
        self.c_down = (1 - self.c_top_ratio) * self.C_ActivatedElement
        self.mcp_top = self.c_top
        self.mcp_down = self.c_down
        self.T_bottom = 8.5 + 273.15

        model.hCon = Var(model.time_steps, initialize=0, within=NonNegativeReals, name="hCon")
        model.T_panel_heating1 = Var(model.time_steps, initialize=293.15, bounds=(273.15, 330), name="T_panel_heating1")

        model.Q_thermalCond1_top = Var(model.time_steps, initialize=0, bounds=(-1000000, 1000000), name="Q_thermalCond1_top")
        model.Q_thermalCond2_top = Var(model.time_steps, initialize=0, bounds=(-1000000, 1000000), name="Q_thermalCond2_top")
        model.Q_thermalCapacity_top = Var(model.time_steps, initialize=0, bounds=(-1000000, 1000000), name="Q_thermalCapacity_top")
        model.T_thermalCapacity_top = Var(model.time_steps, initialize=303.15, bounds=(273.15, 330), name="T_thermalCapacity_top")
        model.T_thermalCapacity_top_dot = DerivativeVar(model.T_thermalCapacity_top,initialize=0, wrt=model.time_steps, name="T_thermalCapacity_top_dot")

        model.Q_thermalCond1_down = Var(model.time_steps, initialize=0, bounds=(-1000000, 1000000), name="Q_thermalCond1_down")
        model.m_flow_UFH = Var(model.time_steps, initialize=0, bounds=(0, self.m_flow_nominal_UFH), name="m_flow_UFH")
        model.Q_thermalCond2_down = Var(model.time_steps, initialize=0, bounds=(-1000000, 1000000), name="Q_thermalCond2_down")
        model.Q_thermalCapacity_down = Var(model.time_steps, initialize=0,bounds=(-1000000, 1000000), name="Q_thermalCapacity_down")
        model.T_thermalCapacity_down = Var(model.time_steps, initialize=303.15, bounds=(273.15, 330), name="T_thermalCapacity_down")
        model.T_thermalCapacity_down_dot = DerivativeVar(model.T_thermalCapacity_down, initialize=0, wrt=model.time_steps, name="T_thermalCapacity_down_dot")


        #### Hardgecodete Wärmeströme oder Temperaturen mit Ergebnissen der Simulation
        # Q_rad_UFH -> QRadUFH
        # Q_conv_UFH -> QConvUFH
        # T_panel_heating1 -> T_UFH
        # t_rad -> TRad
        # T_Air -> TRaum
        # Q_thermalCond2_down -> QBoden
        # T_return_UFH -> TrUFH
        # T_supply_UFH -> TsUFH
        # Q_thermalCond1_top -> QpanelSeg1
        # Q_thermalCond1_down -> QpanelSeg2
        # T_thermalCapacity_top -> TCapa1
        # T_thermalCapacity_down -> TCapa2

        # Panel Heating Teil oben
        # upward heat flow: hCon = 5, bei x_heat_HP =1, downward heat flow: hCon = 0.7, bei x_hp_cool = 1
        self.T_ref = 293.15

        @model.Constraint(model.time_steps)
        def EB_PHS2(m, t):
            return (m.Q_rad_UFH[t] == sigma * self.eps * self.A * 4 * self.T_ref**3 * (m.T_panel_heating1[t] - m.t_rad[t]))

        #Equation for convectice Heat Flow in get_control function

        @model.Constraint(model.time_steps)
        def EB_PHS3(m, t):
            return (m.Q_conv_UFH[t] + m.Q_rad_UFH[t] == m.Q_thermalCond2_top[t])

        @model.Constraint(model.time_steps)
        def EB_PHS4(m, t):
            return (m.Q_thermalCond2_top[t] == 2 * self.kA_top * (m.T_thermalCapacity_top[t] - m.T_panel_heating1[t]))

        @model.Constraint(model.time_steps)
        def EB_PHS51(m, t):
            return (m.Q_thermalCapacity_top[t] == self.mcp_top * m.T_thermalCapacity_top_dot[t] * 1/(self.time_step*3600))

        @model.Constraint(model.time_steps)
        def EB_PHS5(m, t):
            return (m.Q_thermalCapacity_top[t] == m.Q_thermalCond1_top[t] - m.Q_thermalCond2_top[t])

        @model.Constraint(model.time_steps)
        def EB_PHS6(m, t):
            return (m.Q_thermalCond1_top[t] == 2 * self.kA_top * (m.T_return_UFH[t] - m.T_thermalCapacity_top[t]))

        @model.Constraint(model.time_steps)
        def EB_PHS7(m, t):
            return (m.Q_thermalCond1_top[t] + m.Q_thermalCond1_down[t] == m.Q_UFH[t])

        @model.Constraint(model.time_steps)
        def EB_PHS8(m, t):
            return (m.Q_UFH[t] == self.m_flow_nominal_UFH * self.parameters["c_f"] * (m.T_supply_UFH[t] - m.T_return_UFH[t]))

        # Panel Heating Teil unten
        @model.Constraint(model.time_steps)
        def EB_PHS9(m, t):
            return (m.Q_thermalCond1_down[t] == 2 * self.kA_down * (m.T_return_UFH[t] - m.T_thermalCapacity_down[t]))


        @model.Constraint(model.time_steps)
        def EB_PHS10(m, t):
            return (m.Q_thermalCapacity_down[t] == m.Q_thermalCond1_down[t] - m.Q_thermalCond2_down[t])

        @model.Constraint(model.time_steps)
        def EB_PHS11(m, t):
            return (m.Q_thermalCapacity_down[t] == self.mcp_down * (m.T_thermalCapacity_down_dot[t] * 1/(self.time_step*3600)))

        @model.Constraint(model.time_steps)
        def EB_PHS12(m, t):
            return (m.Q_thermalCond2_down[t] == 2 * self.kA_down * (m.T_thermalCapacity_down[t] - self.T_bottom))

        return model



    def get_control(self, demand, time_series):
        """
        Solves Optimal control Problem based on given inputs, disturbances and references
        :return: vector of decision variables and predicted States
        """
        print(self.initials)
        time = [i for i in range(0, int(self.prediction_horizon/self.time_step))]
        # create instance for next optimization
        instance = self.model.create_instance({None: {'time_steps': {None: time}, }})
        # define constraints for t=0 (initials) and scenario based equations
        def _init(instance):
            for t in np.arange(0, len(instance.time_steps)-1):
                yield ((instance.t_TES[t+1] - instance.t_TES[t]) * self.devs["TES"]["vol"] / 1000 * self.parameters["c_f"] * self.parameters["rho"] / 3600
                        == self.time_step * (self.devs["TES"]["eta_ch"] * instance.ch_TES[t] - instance.dch_TES[t] - instance.heat_loss_TES[t]))

                yield ((instance.t_DHW[t+1] - instance.t_DHW[t]) * self.devs["DHW"]["vol"] / 1000 * self.parameters["c_f"] * self.parameters["rho"] / 3600
                        == self.time_step * (self.devs["DHW"]["eta_ch"] * instance.ch_DHW[t] - instance.dch_DHW[t] - instance.heat_loss_DHW[t]))

                yield (instance.energy_BAT[t+1] == instance.energy_BAT[t] * (1 - self.time_step * self.devs["BAT"]["sto_loss"])
                                                   + self.time_step * (self.devs["BAT"]["eta_ch"] * instance.ch_BAT[t]
                                                                       - 1 / self.devs["BAT"]["eta_dch"] * instance.dch_BAT[t]))

            for t in np.arange(0, len(instance.time_steps)):
                yield (instance.heat_loss_TES[t] == (instance.t_TES[t] - self.devs["TES"]["t_min"])
                                                    * self.devs["TES"]["k_loss"] * self.devs["TES"]["vol"] / 1000
                                                    * self.parameters["c_f"] * self.parameters["rho"] / 3600)
                yield (instance.heat_loss_DHW[t] == (instance.t_DHW[t] - self.devs["DHW"]["t_min"])
                       * self.devs["DHW"]["k_loss"] * self.devs["DHW"]["vol"] / 1000
                       * self.parameters["c_f"] * self.parameters["rho"] / 3600)

            yield instance.T_Air[0] == self.initials["T_Air"]
            yield instance.T_thermalCapacity_down[0] == self.initials["T_thermalCapacity_down"]
            yield instance.T_thermalCapacity_top[0] == self.initials["T_thermalCapacity_top"]
            yield instance.T_supply_UFH[0] == self.initials["T_supply_UFH"]
            yield instance.T_Roof[0] == self.initials["T_Roof"]
            yield instance.T_IntWall[0] == self.initials["T_IntWall"]
            yield instance.T_ExtWall[0] == self.initials["T_ExtWall"]
            yield instance.T_Floor[0] == self.initials["T_Floor"]
            yield instance.T_Win[0] == self.initials["T_Win"]
            yield instance.t_TES[0] == self.initials["t_TES"]
            yield instance.t_DHW[0] == self.initials["t_DHW"]
            yield instance.T_lay1_TES[0] == self.initials["T_lay1_TES"]
            yield instance.T_lay2_TES[0] == self.initials["T_lay2_TES"]
            yield instance.T_lay3_TES[0] == self.initials["T_lay3_TES"]
            yield instance.T_lay4_TES[0] == self.initials["T_lay4_TES"]
            yield instance.T_lay1_DHW[0] == self.initials["T_lay1_DHW"]
            yield instance.T_lay2_DHW[0] == self.initials["T_lay2_DHW"]
            yield instance.T_lay3_DHW[0] == self.initials["T_lay3_DHW"]
            yield instance.T_lay4_DHW[0] == self.initials["T_lay4_DHW"]
            yield instance.energy_BAT[0] == self.initials["energy_BAT"]

            if np.mean(time_series["ts_T_air"]) >= 273.15 + 12: # just cooling mode is allowed
                yield instance.T_supply_cool[0] == self.initials["T_supply"]
                # yield instance.T_return_cool[0] == self.initials["T_return"]
                for t in instance.time_steps:

                    yield instance.T_supply_cool[t] >= self.parameters["T_supply_heat_min_cool"]
                    yield instance.T_supply_cool[t] <= self.parameters["T_supply_heat_max_cool"]
                    yield instance.T_return_cool[t] >= instance.T_supply_cool[t]
                    yield instance.T_return_UFH[t] >= instance.T_supply_UFH[t]

                    yield instance.ch_TES[t] <= 0  # Ensures that only DHW can be loaded when heat mode is selected
                    yield instance.T_lay1_TES[t] == instance.T_supply_UFH[t]
                    yield instance.T_supply_cool[t] - (instance.t_TES[t] - 1 / 2 * (instance.t_TES[t] - self.devs["TES"]["t_min"])) <= -2 + (1-instance.x_TES_ch[t]) * 100  # Pinch Lower layer
                    yield instance.T_return_cool[t] - (instance.t_TES[t] + 1 / 2 * (self.devs["TES"]["t_max"] - instance.t_TES[t]))  <= -2 + (1-instance.x_TES_ch[t]) * 100  # Pinch Upper layer

                    yield instance.Q_conv_UFH[t] == 0.7 * self.A * (instance.T_panel_heating1[t] - instance.T_Air[t])

            else: # just heating mode is allowed
                yield instance.T_supply_HP_heat[0] == self.initials["T_supply"]
                # yield instance.T_return_heat[0] == self.initials["T_return"]
                for t in instance.time_steps:
                    yield instance.x_HP_cool[t] == 0
                    yield instance.T_supply_HP_heat[t] >= self.parameters["T_supply_heat_min_heat"]
                    yield instance.T_supply_HP_heat[t] <= self.parameters["T_supply_heat_max_heat"]
                    yield instance.T_return_heat[t] <= instance.T_supply_HP_heat[t]
                    yield instance.T_supply_UFH[t] - instance.T_return_UFH[t] <= 10
                    yield instance.T_supply_UFH[t] >= instance.T_return_UFH[t]

                    yield instance.t_TES[t] + 2 >= instance.T_supply_UFH[t]   # Ensures that TES is hot enough
                    yield instance.T_supply_heat[t] - (instance.t_TES[t] + 2) >= 2 - (1-instance.x_TES_ch[t])*100  # Pinch Upper layer
                    yield instance.T_return_heat[t] - (instance.t_TES[t] - 2) >= 2 - (1-instance.x_TES_ch[t])*100  # Pinch Lower layer

                    yield instance.Q_conv_UFH[t] == 5 * self.A * (instance.T_panel_heating1[t] - instance.T_Air[t])
                    # yield instance.T_thermalCapacity_down[t] <= instance.TrUFH[t]


        #     # Initial Values for States
        #     for i, state in enumerate(self.states):
        #         yield instance.component(state)[0] == x0[state]
        #
        #     # Initial Values for inputs
        #     for i, input in enumerate(self.inputs):
        #         yield instance.component(input)[0] == u0[input]

        instance.init_conditions = ConstraintList(rule=_init)


        # apply collocation scheme
        discretizer = TransformationFactory('dae.collocation')
        discretizer.apply_to(instance, ncp=1, scheme='LAGRANGE-RADAU', wrt=instance.time_steps)
        #discretizer = TransformationFactory('dae.finite_difference')
        #discretizer.apply_to(instance, nfe=10, wrt=instance.t, scheme='FORWARD')

        # get Grid
        time_col = [t for t in instance.time_steps]
        # # Control variables are made constant over each finite element
        # for i, input in enumerate(self.inputs):
        #     discretizer.reduce_collocation_points(instance, var=instance.component(input), contset=instance.time_steps, ncp=1)

        # fit disturbances and Reference to collocation points
        for key in demand.keys():
            demand[key] = sample(trajectory=pd.Series(data=demand[key], index=time), grid=time_col)
            for i, t in enumerate(instance.time_steps):
                instance.component(key)[t] = demand[key][i]

        for key in time_series.keys():
            time_series[key] = sample(trajectory=pd.Series(data=time_series[key], index=time), grid=time_col)
            for i, t in enumerate(instance.time_steps):
                instance.component(key)[t] = time_series[key][i]

        self.create_obj(instance)


        #MINLP
        #sol = SolverFactory('mindtpy').solve(instance, mip_solver='glpk', nlp_solver='ipopt', tee=True)

        # MILP
        opt = SolverFactory('gurobi', solver_io = 'python')
        opt.options['mipgap'] = 0.03
        opt.options['TimeLimit'] = 300

        # if Nonlinear
        opt.options["NonConvex"] = 2
        sol = opt.solve(instance, tee=True, keepfiles=True)

        # pass results as dataframe
        wanted = {
            'power_HP',
            'power_HP_heat',
            'power_HP_cool',
            'power_rod',
            'power_PV',
            'power_to_grid',
            'power_from_grid',
            'power_use_PV',
            'power_use_BAT',
            'power_to_grid_PV',
            'power_to_grid_BAT',
            'power_to_BAT_PV',
            'power_to_BAT_from_grid',
            'COP_HP_heat',
            'COP_HP_cool',
            'x_HP_heat',
            'x_HP_cool',
            'cool_HP',
            'heat_HP',
            'T_supply_HP_heat',
            'T_supply_heat',
            'T_return_heat',
            'T_supply_cool',
            'T_return_cool',
            'heat_rod',

            'T_lay4_DHW',
            'T_lay3_DHW',
            'T_lay2_DHW',
            'T_lay1_DHW',
            'T_lay4_TES',
            'T_lay3_TES',
            'T_lay2_TES',
            'T_lay1_TES',

            'T_layHE4_DHW',
            'T_layHE3_DHW',
            'T_layHE2_DHW',
            'T_layHE1_DHW',
            'T_layHE4_TES',
            'T_layHE3_TES',
            'T_layHE2_TES',
            'T_layHE1_TES',

            "Q_he1_TES", "Q_he2_TES", "Q_he3_TES", "Q_he4_TES",

            'T_return_UFH',
            'T_supply_UFH',
            'soc_TES',
            'x_TES_ch',
            'ch_TES',
            'dch_TES',
            't_TES',
            't_Pinch_TES',
            'heat_loss_TES',
            'soc_DHW',
            'x_DHW_ch',
            'ch_DHW',
            'dch_DHW',
            't_DHW',
            't_Pinch_DHW',
            'heat_loss_DHW',
            'soc_BAT',
            'x_BAT_ch',
            'x_BAT_dch',
            'ch_BAT',
            'dch_BAT',
            'energy_BAT',
            'res_elec',
            'T_Air',
            'T_Air_dot',
            'T_Roof',
            'T_Roof_dot',
            'T_Floor',
            'T_Floor_dot',
            'T_ExtWall',
            'T_ExtWall_dot',
            'T_IntWall',
            'T_IntWall_dot',
            'T_Win',
            'T_Win_dot',
            't_rad',
            'Q_ig_conv',
            'Q_ig_rad',
            'Q_conv_UFH',
            'Q_rad_UFH',
            'eps_Air_pos',
            'eps_Air_neg',
            'vio_Kh',
            'hCon',
            'T_panel_heating1',
            'Q_thermalCond1_top',
            'Q_thermalCond2_top',
            'T_thermalCapacity_top',
            'T_thermalCapacity_top_dot',
            'Q_thermalCapacity_top',
            'Q_UFH',
            'Q_thermalCond1_down',
            'Q_thermalCond2_down',
            'Q_thermalCapacity_down',
            'T_thermalCapacity_down',
            'T_thermalCapacity_down_dot',
            'm_flow_UFH',
                }
        results = {}
        for i in wanted:
            results[i] = []
            for v in instance.component_objects(Var, active=True):
                # print("'" + v.name + "',")
                if v.name == i:
                    for t in instance.time_steps:
                        results[i].append(value(v[t]))
                    break

        for v in instance.component_objects(Param, active=True):
            results[v.name] = []
            for t in instance.time_steps:
                results[v.name].append(value(v[t]))

        results["PV_Distr_Use"] = []
        results["PV_Distr_FeedIn"] = []
        results["PV_Distr_ChBat"] = []
        results["n_rel"] = []
        results["hr_rel"] = []

        for t in instance.time_steps:
            if value(instance.ts_powerPV[t]) > 0.01:
                results["PV_Distr_Use"].append(results["power_use_PV"][t]/value(instance.ts_powerPV[t]))
                results["PV_Distr_FeedIn"].append(results["power_to_grid_PV"][t]/value(instance.ts_powerPV[t]))
                results["PV_Distr_ChBat"].append(results["power_to_BAT_PV"][t]/value(instance.ts_powerPV[t]))
            else:
                results["PV_Distr_Use"].append(0)
                results["PV_Distr_FeedIn"].append(0)
                results["PV_Distr_ChBat"].append(0)
            results["n_rel"].append(min(1, value(instance.power_HP[t])/(5000/(value(instance.COP_HP_heat[t])))))
            results["hr_rel"].append(value(instance.power_rod[t])/self.devs["rod"]["cap"])

        results["from_grid_total"] = value(instance.from_grid_total)
        results["to_grid_total"] = value(instance.to_grid_total)
        results["el_costs"] = value(instance.el_costs)
        results["el_revenue"] = value(instance.el_revenue)
        results["costs_discomfort"] = value(instance.costs_discomfort)
        results["obj"] = (value(instance.el_costs) - value(instance.el_revenue) + value(instance.costs_discomfort))

        return results, instance, sol

    def create_obj(self, instance):
        # %% OBJECTIVE
        # Sum over time
        @instance.Constraint()
        def EB_Elec3(m):
            return (m.from_grid_total == self.time_step * sum(m.power_from_grid[t] + m.power_to_BAT_from_grid[t] for t in instance.time_steps))

        @instance.Constraint()
        def EB_Elec4(m):
            return (m.el_costs == instance.from_grid_total * self.parameters["price_el"])

        @instance.Constraint()
        def EB_Elec5(m):
            return (m.to_grid_total == self.time_step * sum(m.power_to_grid[t] for t in instance.time_steps))

        @instance.Constraint()
        def EB_Elec6(m):
            return (m.el_revenue == instance.to_grid_total * self.parameters["feed_in_revenue_el"])

        @instance.Constraint()
        def EB_Elec7(m):
            return (m.costs_discomfort == sum(instance.eps_Air_pos[t]**2 + instance.eps_Air_neg[t]**2 for t in instance.time_steps) * self.time_step * self.parameters["price_comfort_vio"])

        # Set objective function
        @instance.Objective(sense=minimize)
        def objective_rule(instance):
            return (instance.el_costs - instance.el_revenue + instance.costs_discomfort)



    def get_par(self):
        self.par = {
        'T_start' : 293.15,
        'withAirCap' : True,
        'VAir' : 480.0,
        'AZone' : 150.0,
        'hRad' : 5.0,
        'lat' : 0.88645272708792,
        'nOrientations' : 4,
        'AWin' : [7.5, 7.5, 7.5, 7.5],
        'ATransparent' : [7.5, 7.5, 7.5, 7.5],
        'hConWin' : 2.7,
        'RWin' : 0.011940298507462687,
        'gWin' : 0.67,
        'UWin': 1.8936557576825386,
        'ratioWinConRad' : 0.029999999999999995,
        'AExt' : [33.75, 33.75, 33.75, 33.75],
        'hConExt' : 2.7,
        'nExt' : 1,
        'RExt' : 0.0002022296625696948,
        'RExtRem' : 0.013378017251010553,
        'CExt' : 56749960.15495383,
        'AInt' : 550.0000000000001,
        'hConInt' : 2.4272727272727277,
        'nInt' : 1,
        'RInt' : 0.0001319970403943968,
        'CInt' : 58082478.38670303,
        'AFloor' : 0.01,
        'hConFloor' : 1.7,
        'nFloor' : 1,
        'RFloor' : 2.3128627720345007,
        'RFloorRem' :  158.16332770415596,
        'CFloor' : 804.4926929625199,
        'ARoof' : 99.75,
        'hConRoof' : 1.7000000000000006,
        'nRoof' : 1,
        'RRoof' : 0.00023847706069558312,
        'RRoofRem' : 0.019354880878527013,
        'CRoof' : 36494842.83228058,
        'nOrientationsRoof' : 1,
        'tiltRoof' : 0.0,
        'aziRoof' : 0.0,
        'wfRoof' : 1.0,
        'aRoof' : 0.5,
        'aExt' : 0.5,
        'TSoil' : 286.15,
        'hConWallOut' : 20.0,
        'hRadWall' : 5.0,
        'hConWinOut' : 20.0,
        'hConRoofOut' : 20.000000000000004,
        'hRadRoof' : 5.0,
        'tiltExtWalls' : [1.5707963267948966, 1.5707963267948966, 1.5707963267948966, 1.5707963267948966],
        'aziExtWalls' : [0.0, 1.5707963267948966, 3.141592653589793, -1.5707963267948966],
        'wfWall' : [0.25, 0.25, 0.25, 0.25],
        'wfWin' : [0.25, 0.25, 0.25, 0.25],
        'wfGro' : 0.0,
        'specificPeople' : 0.02,
        'internalGainsMoistureNoPeople' : 0.5,
        'fixedHeatFlowRatePersons' : 70,
        'activityDegree' : 1.2,
        'ratioConvectiveHeatPeople' : 0.5,
        'internalGainsMachinesSpecific' : 2.0,
        'ratioConvectiveHeatMachines' : 0.75,
        'lightingPowerSpecific' : 7.0,
        'ratioConvectiveHeatLighting' : 0.5,
        'useConstantACHrate' : False,
        'baseACH' : 0.2,
        'maxUserACH' : 1.0,
        'maxOverheatingACH' : [3.0, 2.0],
        'maxSummerACH' : [1.0, 283.15, 290.15],
        'winterReduction' : [0.2, 273.15, 283.15],
        'maxIrr' : [100.0, 100.0, 100.0, 100.0],
        'shadingFactor' : [1.0, 1.0, 1.0, 1.0],
        'withAHU' : False,
        'minAHU' : 0.3,
        'maxAHU' : 0.6,
        'hHeat' : 6532.315671669887,
        'lHeat' : 0,
        'KRHeat' : 10000,
        'TNHeat' : 1,
        'HeaterOn' : True,
        'hCool' : 0,
        'lCool' : -6532.315671669887,
        'KRCool' : 10000,
        'TNCool' : 1,
        'CoolerOn' : False,
        'withIdealThresholds' : False,
        'TThresholdHeater' : 288.15,
        'TThresholdCooler' : 295.15,
        }



""" sammle Gleichungen für UFH

        Panel Heating Segment

        A = tubeLength*floorHeatingType.diameter*Modelica.Constants.pi/dis/2 # floor part
        eps=0.9,
        T0 = 30°C
        Vwater = Modelica.Constants.pi * floorHeatingType.diameter ^ 2 * tubeLength / 4 / dis
        kTop_nominal = 4.47 W/(m²K)
        kDown_nominal = 0.37 W/(m²K)
        cTop=cFloorHeating * cTopRatio
        cFloorHeating = C_ActivatedElement = 8024814.61230118 J/K
        c_top_ratio=0.19
        cDown = cFloorHeating*(1 - cTopRatio)
        A_Floor=99.75 # floor area
        hCon_const=2.5 W/(m²K)



        Panel Heating Model

        dis = 5 Number of descretization layers
        spacing = 0.2 m
        Volume_water = Modelica.Constants.pi * floorHeatingType.diameter ^ 2 * tubeLength / 4
        tubeLength=A/Spacing
        A=99.75 # floor area

        Floor Heating Type

        q_dot_nom=9710.1W / 150m²
        k_isolation=4.84
        k_top=4.47
        k_down=0.37
        VolumeWaterPerMeter=0.01,
        self.eps=0.9,
        C_ActivatedElement=8024814.61230118 J/K
        self.c_top_ratio=0.19
        PressureDropExponent=0,
        PressureDropCoefficient=0,
        diameter = 0.018m 
        TFloor = 8.5 °C Soil temperature
        T0 = TAir_start = 30°C
        m_flow_nominal = 0.232 kg/s
        """
