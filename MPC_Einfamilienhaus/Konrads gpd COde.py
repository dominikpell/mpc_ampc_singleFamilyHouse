import numpy as np
import matplotlib.pyplot as plt
from pyomo.environ import *
from pyomo.dae import *
import pandas as pd
from pyomo.gdp import *
from pbmpc.utilities.pickle_handler import *
from pbmpc.utilities.interpolation import *
from pyomo.common.tempfiles import TempfileManager
from pbmpc.component_properties import *
import json

TempfileManager.tempdir = 'pyomo_tempfiles'

# todo:
# - consider ,json for mpc settings -> boundaries etc.
# - adjust values for glycol coil and anything else
# - close loop with heat pump system (fmu), use mapping -> see protocol how phillip prefers
# - test producer mpc with random disturbance/demand trajectories

# pyomo model
class producer:
    def __init__(self, Horizon):
        self.Horizon = Horizon
        # read dimensions and available modes
        with open("../pbmpc/prod_dim.json", 'r') as f:
            self.prod_dim = json.load(f)
        self.use_chc = self.prod_dim['chc']  # combined heating and cooling
        self.use_hr = False  # heating rod
        if self.prod_dim['Qf_hr_max'] > 0:
            self.use_hr=True
        # inputs, states and disturbances
        self.inputs = ["n_hp"] # continuous inputs
        if self.use_hr:
            self.inputs.append("Qf_hr")  # continuous inputs

        if self.use_chc:
            self.inputs_bin = ["hp_heat_hs", "hp_cool_cs", "hp_off", "hp_heat_hs_cool_cs"]  # binary inputs
        else:
            self.inputs_bin = ["hp_heat_hs", "hp_cool_cs", "hp_off"]  # binary input
        self.states = ["T_con", "T_ev", "T_hs", "T_cs", "T_rc", "T_as", "T_coil"]  # T_as = temperature outdoor unit air source
        self.disturbances = ["T_amb", "Q_fl_hs_hc", "Q_fl_cc_cs", "P_el_min"]

    def create_heatpump_system(self, m):
        """
        Heat Pump Model using linear approximation for COP calulation (Pel = a*Q_con+b*T_con,out + c*T_Ev,in)
        Appends relevant Variables and Constraints to abstract pyomo model and returns the model
        Simple 1D Storage model
        Simple Cooler Model
        Simple Air source outdoor unit model
        :param m: Pyomo abstract model
        """

        """Parameters"""
        # -------- fluid properties
        self.cp = 4.184  # specific heat capacity water [kJ/kg/K]
        self.cp_gc = 3.434  # specific heat capacity of glycol (mixture) [kJ/kg/K]

        # ---------Heat Pump
        # self.P_el_min_tech = 0  # minimum power if HP is turned on in kW
        self.P_el_min_tech = 15 * self.prod_dim['sf_hp']
        self.n_steps_P_el_min = 4  # TODO: ADJUST IF HORIZON IS MODIFIED
        self.P_el_max = self.prod_dim['sf_hp']*51  # maximum power if HP is turned on in kW
        self.C_ev = 106 * self.cp_gc  # thermal capacity of Evaporator in kJ/K
        self.C_con = 175 * self.cp  # thermal capacity of Condenser in kJ/K
        self.COP_fix = 5  # fixed COP  #
        self.a = 0.1736  # linear Coefficient COP Approximation
        self.b = 0.459  # ||
        self.c = -0.491  # ||

        # ---------Cold Storage
        self.C_cs = get_storage_capacity(inner_diameter=self.prod_dim['d_cs'], height=2.82, specific_heat_cap_in_kJ=self.cp)
        self.U_cs = get_storage_u_value(inner_diameter=self.prod_dim['d_cs'], height=2.82)
        self.T_amb_cs = 298.15  # Ambient Temperature Cold Storage in K

        # ----------Coil in cold storage
        self.k_coil = 20.62  # effective heat transfer from storage to fluid in kJ/K # todo: consider model without T_coil as state since parameter hard to estimate
        self.C_coil = 3000  # thermal capacity of coil

        # ---------Hot Storage
        self.C_hs = get_storage_capacity(inner_diameter=self.prod_dim['d_hs'], height=2.26, specific_heat_cap_in_kJ=self.cp)
        self.U_hs = get_storage_u_value(inner_diameter=self.prod_dim['d_hs'], height=2.26)
        self.T_amb_hs = self.T_amb_cs  # Ambient Temperature Hot Storage in K
        self.Qf_hr_max = self.prod_dim['Qf_hr_max']  # maximum Power of heating rod

        # ---------Recooler
        self.k_rc = 8.340 / 2*5
        self.C_rc = 500 * self.cp  # thermal capacity of glycol cooler kJ/K

        # ---------Air Source outdoor unit
        self.k_as = 8.340/2*10  # Heat transfer Coefficient glycol cooler in kW/K
        self.C_as = 530 * self.cp_gc  # thermal capacity of glycol cooler kJ/K

        """Variables"""
        # -----------Changeable (mutable) Parameters
        m.m_fl_ev = Param(default=8.83, mutable=True)
        m.m_fl_con = Param(default=13.54, mutable=True)
        m.T_amb = Param(m.t, default=285.15, mutable=True)
        m.P_el_min = Param(m.t, default=0, mutable=True)  # minimum power if HP is turned on in kW!
        m.Q_fl_hs_hc = Param(m.t, default=0, mutable=True)  # thermal power hot storage to hot Consumer in kW
        m.Q_fl_cc_cs = Param(m.t, default=0, mutable=True)  # thermal power cold consumer to cold storage in kW

        # --------states
        m.T_con = Var(m.t, initialize=308, bounds=(275, 330))  # Temperature Condenser
        m.T_dot_con = DerivativeVar(m.T_con, initialize=0, wrt=m.t)

        m.T_ev = Var(m.t, initialize=280, bounds=(253.15, 298))  # Temperature Evaporator
        m.T_dot_ev = DerivativeVar(m.T_ev, initialize=0, wrt=m.t)

        m.T_hs = Var(m.t, initialize=308, bounds=(293, 330))  # Temperature Hot Storage
        m.T_dot_hs = DerivativeVar(m.T_hs, initialize=0, wrt=m.t)

        m.T_cs = Var(m.t, initialize=285, bounds=(275, 330))  # Temperature Cold Storage
        m.T_dot_cs = DerivativeVar(m.T_cs, initialize=0, wrt=m.t)

        m.T_rc = Var(m.t, initialize=285, bounds=(273.15, 340))  # Temperature Recooler
        m.T_dot_rc = DerivativeVar(m.T_rc, initialize=0, wrt=m.t)

        m.T_as = Var(m.t, initialize=285, bounds=(253, 340))  # Temperature Air source outdoor unit
        m.T_dot_as = DerivativeVar(m.T_as, initialize=0, wrt=m.t)

        m.T_coil = Var(m.t, initialize=285, bounds=(275, 330))  # Temperature coil in cold storage
        m.T_dot_coil = DerivativeVar(m.T_coil, initialize=0, wrt=m.t)

        # --------algebraic
        m.n_hp = Var(m.t, initialize=0, bounds=(0,1))  # rel. Power consumption Heatpump
        m.P_el_hp = Var(m.t, initialize=0, bounds=(0, self.P_el_max))  # el. Power consumption Heatpump in kW
        # HP Internal
        m.Q_fl_con = Var(m.t, initialize=0, bounds=(-350, 350))  # thermal power Condenser (to HP-fluid) in kW
        m.Q_fl_ev = Var(m.t, initialize=0, bounds=(-300, 300))  # thermal power evaporator (to HP-fluid) in kW
        # Hot Side HP
        if self.use_hr:
            m.Qf_hr = Var(m.t, initialize=0, bounds=(0, self.Qf_hr_max))
        m.Q_fl_con_hp = Var(m.t, initialize=0, bounds=(-350, 350))  # thermal power from hp condenser to X
        m.Q_fl_con_rc = Var(m.t, initialize=0, bounds=(-350, 350))  # thermal power condenser to recooler
        m.Q_fl_con_hs = Var(m.t, initialize=0, bounds=(-350, 350))  # thermal power condenser to hot storage
        # Cold Side HP
        m.Q_fl_ev_hp = Var(m.t, initialize=0, bounds=(-300, 300))  # thermal power to hp evaporator from X
        m.Q_fl_as_ev = Var(m.t, initialize=0, bounds=(-300, 300))  # thermal power air source outdoor unit to evaporator
        m.Q_fl_cs_coil = Var(m.t, initialize=0, bounds=(-300, 300))  # thermal power cold storage to coil
        m.Q_fl_coil_ev = Var(m.t, initialize=0, bounds=(-300, 300))  # thermal power coil to evaporator
        # Recooler
        m.Q_fl_rc_amb = Var(m.t, initialize=0, bounds=(-500, 500))  # thermal power recooling to ambient in kW
        # Air Source outdoor unit
        m.Q_fl_amb_as = Var(m.t, initialize=0, bounds=(-500, 500))  # thermal power ambient to air source outdoor unit in kW

        """ Equations """
        # ----------States
        if self.use_hr:
            m.hps_con_1 = Constraint(m.t, rule=lambda m, t: self.C_hs * m.T_dot_hs[t] == m.Q_fl_con_hs[t] - m.Q_fl_hs_hc[t] + self.U_hs * (self.T_amb_hs - m.T_hs[t]) + m.Qf_hr[t])  # energy balance hot storage
        else:
            m.hps_con_1 = Constraint(m.t,
                                     rule=lambda m, t: self.C_hs * m.T_dot_hs[t] == m.Q_fl_con_hs[t] - m.Q_fl_hs_hc[
                                         t] + self.U_hs * (self.T_amb_hs - m.T_hs[t]))  # energy balance hot storage

        m.hps_con_2 = Constraint(m.t, rule=lambda m, t: self.C_cs * m.T_dot_cs[t] == m.Q_fl_cc_cs[t] - m.Q_fl_cs_coil[
            t] + self.U_cs * (self.T_amb_cs - m.T_cs[t]))  # energy balance cold storage
        m.hps_con_3 = Constraint(m.t, rule=lambda m, t: self.C_ev * m.T_dot_ev[t] == m.Q_fl_ev_hp[t] - m.Q_fl_ev[
            t])  # energy balance evaporator
        m.hps_con_4 = Constraint(m.t, rule=lambda m, t: m.Q_fl_ev_hp[t] == m.Q_fl_coil_ev[t] + m.Q_fl_as_ev[
            t] )  # split evaporator heat
        m.hps_con_5 = Constraint(m.t, rule=lambda m, t: self.C_con * m.T_dot_con[t] == m.Q_fl_con[t] - m.Q_fl_con_hp[
            t])  # energy balance condenser
        m.hps_con_6 = Constraint(m.t, rule=lambda m, t: m.Q_fl_con_hp[t] == m.Q_fl_con_rc[t] + m.Q_fl_con_hs[t])
        # split condenser heat
        m.hps_con_7 = Constraint(m.t,rule=lambda m, t: self.C_rc * m.T_dot_rc[t] == m.Q_fl_con_rc[t] - m.Q_fl_rc_amb[
            t])  # energy balance re-cooler
        m.hps_con_8 = Constraint(m.t, rule=lambda m, t: self.C_as * m.T_dot_as[t] == m.Q_fl_amb_as[t] - m.Q_fl_as_ev[
            t])  # energy balance air source outdoor unit
        m.hps_con_9 = Constraint(m.t, rule=lambda m, t: self.C_coil * m.T_dot_coil[t] == m.Q_fl_cs_coil[t] - m.Q_fl_coil_ev[t])  # energy balance coil
        m.hps_con_10 = Constraint(m.t, rule=lambda m, t: m.Q_fl_cs_coil[t] == self.k_coil * (m.T_cs[t] - m.T_coil[t]))  # constitutive equation heat tranfer from hot sorage to coil
        # internal hp
        m.hps_con_11 = Constraint(m.t, rule=lambda m, t: m.P_el_hp[t] + m.Q_fl_ev[t] == m.Q_fl_con[t])  # energy balance heat pump
        m.hps_con_12 = Constraint(m.t, rule=lambda m, t: m.P_el_hp[t] * self.COP_fix == m.Q_fl_con[t])  # constitutive heat pump
        m.hps_con_13 = Constraint(m.t, rule=lambda m, t: m.P_el_hp[t] == m.n_hp[t] * self.P_el_max)
        return m

    def create_soft_constraints_hps(self, m):
        """
        Create the soft constraints for the Complete System
        :param m:
        :return:
        """

        # Slack Variables
        m.eps_cs = Var(m.t,initialize=0, bounds=(0, 100))  # Slack Variable for Cold Storage
        m.eps_hs = Var(m.t,initialize=0, bounds=(0, 100))  # Slack Variable for Hot Storage
        m.eps_con = Var(m.t, initialize=0, bounds=(0, 100))  # Slack Variable for Condenser
        m.eps_ev = Var(m.t, initialize=0, bounds=(0, 100))  # Slack Variable for Evaporator

        # Parameters
        m.T_hs_ub = Param(m.t, default=313.15, mutable=True)  # Upper Boundary Hot Storage
        m.T_hs_lb = Param(m.t, default=303.15, mutable=True)  # Lower Boundary Hot Storage
        m.T_cs_ub = Param(m.t, default=288.15, mutable=True)  # Upper Boundary Cold Storage
        m.T_cs_lb = Param(m.t, default=279.15, mutable=True)  # Lower Boundary Cold Storage
        m.T_con_ub = Param(m.t, default=318.15, mutable=True)  # Upper Boundary Condenser
        #m.T_ev_lb = Param(m.t, default=276.15, mutable=True)  # Lower Boundary Evaporator
        m.T_ev_lb = Param(m.t, default=256.15, mutable=True)  # Lower Boundary Evaporator # kbe: adjust because glycol cycle

        # Soft Constraints
        m.soft_con_1 = Constraint(m.t, rule=lambda m, t: m.T_hs[t] <= m.T_hs_ub[t] + m.eps_hs[t])
        m.soft_con_2 = Constraint(m.t, rule=lambda m, t: m.T_hs[t] >= m.T_hs_lb[t] - m.eps_hs[t])
        m.soft_con_3 = Constraint(m.t, rule=lambda m, t: m.T_cs[t] <= m.T_cs_ub[t] + m.eps_cs[t])
        m.soft_con_4 = Constraint(m.t, rule=lambda m, t: m.T_cs[t] >= m.T_cs_lb[t] - m.eps_cs[t])
        m.soft_con_7 = Constraint(m.t, rule=lambda m, t: m.T_con[t] <= m.T_con_ub[t] + m.eps_con[t])
        m.soft_con_8 = Constraint(m.t, rule=lambda m, t: m.T_ev[t] >= m.T_ev_lb[t] - m.eps_ev[t])
        return m

    def add_disjuncts_hps(self, m):
        """
        Create Disjunctions to implement heat pump modes
        :param m:
        :return:
        """

        # -----------combinatorics - Using Pyomo Disjunctions
        # Heat pump modes: hp heating hs, hp cooling cs, hp_off
        def hp_heat_hs(disj, t):
            m = disj.model()
            # hot side
            disj.hp_1 = Constraint(expr=m.Q_fl_con_rc[t] == 0)  # no heat from condenser to recooler
            disj.hp_2 = Constraint(expr=m.Q_fl_con_hs[t] == m.m_fl_con * self.cp * (m.T_con[t] - m.T_hs[t]))  # heat exchange condenser/hot sorage
            disj.hp_3 = Constraint(expr=m.Q_fl_rc_amb[t] == 0)  # simple HP model turns off heat flow to avoid freezing
            # cold side
            disj.hp_4 = Constraint(expr=m.Q_fl_coil_ev[t] == 0)  # no heat from coil to evaporator
            disj.hp_5 = Constraint(expr=m.Q_fl_amb_as[t] == self.k_as * (m.T_amb[t] - m.T_as[t] ))  # heat from air to outdoor unit
            disj.hp_6 = Constraint(expr=m.Q_fl_as_ev[t] == m.m_fl_ev * self.cp_gc * (m.T_as[t] - m.T_ev[t]))
            #disj.hp_7 = Constraint(expr=m.T_con[t]>=293)
            disj.hp_7 = Constraint(expr=m.P_el_hp[t] >= m.P_el_min[t])

        m.hp_heat_hs = Disjunct(m.t, rule=hp_heat_hs)

        def hp_cool_cs(disj, t):
            m = disj.model()
            # hot side
            disj.hp_1 = Constraint(expr=m.Q_fl_con_hs[t] == 0)  # no heat from condenser to hs
            disj.hp_2 = Constraint(expr=m.Q_fl_rc_amb[t] == self.k_rc * (m.T_rc[t] - m.T_amb[t]))  # heat from recooler to air
            disj.hp_3 = Constraint(expr=m.Q_fl_con_rc[t] == m.m_fl_con * self.cp * (m.T_con[t] - m.T_rc[t]))  # heat from recooler to air

            # cold side
            disj.hp_4 = Constraint(expr=m.Q_fl_as_ev[t] == 0)  # no heat from air source to evaporator
            disj.hp_5 = Constraint(expr=m.Q_fl_coil_ev[t] == m.m_fl_ev * self.cp_gc * (m.T_coil[t] - m.T_ev[t]))  # heat to evaporator from cold storage coil
            disj.hp_6 = Constraint(expr=m.Q_fl_amb_as[t] == 0)  # simple HP model turns off heat flow to avoid freezing
            disj.hp_7 = Constraint(expr=m.P_el_hp[t] >=  m.P_el_min[t])

        m.hp_cool_cs = Disjunct(m.t, rule=hp_cool_cs)

        # off mode needed since mass-flow in hot + cool circuit only active if hp on, also outdoor unit shuts down to not freeze
        def hp_off(disj, t):
            m = disj.model()
            # hot side
            disj.hp_1 = Constraint(expr=m.Q_fl_con_rc[t] == 0)  # no heat from condenser to recooler
            disj.hp_2 = Constraint(expr=m.Q_fl_con_hs[t] == 0)  # no heat from condenser to hs
            disj.hp_3 = Constraint(expr=m.Q_fl_rc_amb[t] == 0)  # simple HP model turns off heat flow to avoid freezing

            # cold side
            disj.hp_4 = Constraint(expr=m.Q_fl_as_ev[t] == 0)  # no heat from air source to evaporator
            disj.hp_5 = Constraint(expr=m.Q_fl_coil_ev[t] == 0)  # no heat from coil to evaporator
            disj.hp_6 = Constraint(expr=m.Q_fl_amb_as[t] == 0)  # simple HP model turns off heat flow to avoid freezing

            disj.hp_7 = Constraint(expr=m.n_hp[t] == 0)  # force controller to turn hp off -> # fixme: kbe: before, controller tried to turn hp on in standby mode -> is there any chance that it makes sense? by that the internal heat pump temperatures would be adjusted

        m.hp_off = Disjunct(m.t, rule=hp_off)  # kbe: fixme: no effect if commented

        if self.use_chc:
            def hp_heat_hs_cool_cs(disj, t):
                m = disj.model()
                # hot side
                disj.hp_1 = Constraint(expr=m.Q_fl_con_rc[t] == 0)  # no heat from condenser to recooler
                disj.hp_2 = Constraint(expr=m.Q_fl_con_hs[t] == m.m_fl_con * self.cp * (m.T_con[t] - m.T_hs[t]))  # heat exchange condenser/hot sorage
                disj.hp_3 = Constraint(expr=m.Q_fl_rc_amb[t] == 0)  # simple HP model turns off heat flow to avoid freezing
                # cold side
                disj.hp_4 = Constraint(expr=m.Q_fl_as_ev[t] == 0)  # no heat from air source to evaporator
                disj.hp_5 = Constraint(expr=m.Q_fl_coil_ev[t] == m.m_fl_ev * self.cp_gc * (m.T_coil[t] - m.T_ev[t]))  # heat to evaporator from cold storage coil
                disj.hp_6 = Constraint(expr=m.Q_fl_amb_as[t] == 0)  # simple HP model turns off heat flow to avoid freezing
                disj.hp_7 = Constraint(expr=m.P_el_hp[t] >=  m.P_el_min[t])

            m.hp_heat_hs_cool_cs = Disjunct(m.t, rule=hp_heat_hs_cool_cs)

        def hp_states(m, t):
            if self.use_chc:
                return [m.hp_heat_hs[t], m.hp_cool_cs[t], m.hp_off[t], m.hp_heat_hs_cool_cs[t]]
            else:
                return [m.hp_heat_hs[t], m.hp_cool_cs[t], m.hp_off[t]]

        m.hp_states = Disjunction(m.t, rule=hp_states)

        return m

    def obj(self, instance):
        """
        Define objective function to use in MPC Script. For on off MPC no penalization of Massflows
        :param instance:
        :return:
        """
        obj = 0
        for i, t in enumerate(instance.t):
            if i < 1:
                # skip first values (can't be changed anyway)
                t_last = t
            else:
                # change of decision Variables
                obj += ((instance.P_el_hp[t] - instance.P_el_hp[t_last]) / self.P_el_max) ** 2 * 0.001 * (t-t_last)/3600
                # Constraint violation
                obj += instance.eps_cs[t] * 50 * (t-t_last)/3600
                # obj += instance.eps_hs[t] * 50 * (t-t_last)/3600
                obj += instance.eps_hs[t] * 50 * (t - t_last) / 3600  # motivate using heating rod and satisfy heat demand
                obj += instance.eps_con[t] * 50 * (t-t_last)/3600
                obj += instance.eps_ev[t] * 50 * (t-t_last)/3600

                # economic objectives
                obj += instance.P_el_hp[t] * 0.3*(t-t_last)/3600
                if self.use_hr:
                    obj += instance.Qf_hr[t] * 0.3*(t-t_last)/3600
                obj += instance.hp_heat_hs[t].indicator_var.get_associated_binary() * 1.8 * 0.3*(t-t_last)/3600
                obj += instance.hp_cool_cs[t].indicator_var.get_associated_binary() * 1.8 * 0.3*(t-t_last)/3600
                # no cooler cost for combined heating

                # pass last value
                t_last = t

        return obj

    def create_controller(self):
        """
        Create and connect components
        :param m:
        :return:
        """
        m = AbstractModel()
        m.t = ContinuousSet()
        m = self.create_heatpump_system(m)
        m = self.create_soft_constraints_hps(m)

        instance = m.create_instance({None: {'t': {None: self.Horizon}, }})
        #discretizer = TransformationFactory('dae.finite_difference')  # kbe: causes problem
        #discretizer.apply_to(instance, nfe=10, wrt=instance.t, scheme='BACKWARD')
        discretizer = TransformationFactory('dae.collocation')  # kbe: causes problem
        discretizer.apply_to(instance, ncp=1, scheme="LAGRANGE-RADAU", wrt=instance.t)  # todo: add reduce collocation points, once more than 1 ncp is used
        discretizer.reduce_collocation_points(instance, var=instance.P_el_hp, contset=instance.t, ncp=1)
        instance = self.add_disjuncts_hps(instance)
        TransformationFactory('gdp.bigm').apply_to(instance)
        # TransformationFactory('gdp.hull').apply_to(instance)
        # TransformationFactory('gdp.cuttingplane').apply_to(model)
        return instance

    # def get_control(self, x0, u0, u0bin, disturbances):
    def get_control(self, x0, u0,disturbances):
        """
        Solves Optimal control Problem based on given inputs, disturbances and references

        :param x0: dict with starting Values for State Variables
        :param u0: dict with starting Value Variables
        :param u0bin dict with starting Values for binary inputs
        :param disturbances dict with disturbances (single disturbances as pd.Series object with index [0-max(Horizon)] and smallest stepsize)
        :return: vector of decision variables and predicted States
        """
        instance = self.create_controller()

        # set initial values
        def _init(instance):
            # Initial Values for States
            for i,state in enumerate(self.states):
                yield instance.component(state)[0] == x0[state]

            # Initial Values for inputs
            for j, input in enumerate(self.inputs):
                yield instance.component(input)[0] == u0[input]

            # # Initial Values for integer inputs
            # for i, input in enumerate(self.inputs_bin):
            #     yield instance.component(input)[0].indicator_var == u0bin[input]

        instance.init_conditions = ConstraintList(rule=_init)

        # get Grid
        time_col = [t for t in instance.t]

        # ignore SimTime column here since only for debugiing
        del disturbances['SimTime']
        del disturbances['time_of_prediction']

        # fit disturbances and Reference to collocation points
        for key in disturbances.keys():
            disturbances[key] = sample_mean(trajectory = disturbances[key], grid=time_col)

        # align P_el_min on time_col and add as disturbance
        P_el_min_trajectory = []
        for t in time_col:
            if t <= self.Horizon[self.n_steps_P_el_min - 1]:
                P_el_min_trajectory.append(self.P_el_min_tech)
            else:
                P_el_min_trajectory.append(0)
        disturbances['P_el_min'] = P_el_min_trajectory

        self.instance = instance
        # pass parametes
        for disturbance in self.disturbances:
            for i, t in enumerate(instance.t):
                instance.component(disturbance)[t] = disturbances[disturbance][i]

        # Objectiv with reference
        instance.obj = Objective(rule=self.obj)

        opt = SolverFactory('gurobi', solver_io = 'python')

        # Solve nlp :
        sol = opt.solve(instance, keepfiles=True, tee=True) # kbe: fixme, pyomo cant delete the files -> error occurs
        #log_infeasible_constraints(instance)  # todo: is that a useful log? where do I find it

        # pass results as dataframe
        results = self.create_output_from_instance(instance)

        return results, instance, sol

    def create_output_from_instance(self,instance):
        """
        Construct Pandas DataFrame from optimization Results
        :param instance:
        :return:
        """
        #  Pass continous variables
        results = pd.DataFrame()
        for v in instance.component_objects(Var, active=True):
            try:
                for index in v:
                    if index != None:
                        results.at[index, v.name] = value(v[index])
            except:
                continue
        # Pass indicator variables from gdp
        for e in instance.component_objects(Disjunction):
            for index in e:
                for disjunc in e[index].disjuncts:
                    results.at[index, disjunc.name.split('[')[0]] = int(value(disjunc.indicator_var))

        # try to add parameters  # to add disturbances
        for p in instance.component_objects(Param):
            try:
                for index in p:
                    if index != None:
                        results.at[index, p.name] = value(p[index])
            except:
                continue

        return results

if __name__ == '__main__':
    # Testing the script with base parameters
    import time

    Horizon = [0,900,1800,3600,7200,14400,21600,28800,43200,64800,86400,129600,172800]  # MPC Horizon

    # producer energy system
    pes = producer(Horizon)

    # # create instance of controller
    # mpc = pes.create_controller()
    # assert mpc.is_constructed(), 'instance not constructed, check method create_controller'
    # # print model declaration
    # mpc.pprint()

    # dummy disturbances
    Q_hot_demand = pd.Series(data=[20, 20, 20, 20, 20, 0, 0, 0, 0, 0, 0, 0, 0], index=Horizon)
    Q_cold_demand = pd.Series(data=[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], index=Horizon)
    T_amb = pd.Series(data=[278.15, 278.15,278.15,278.15,278.15,278.15,278.15,278.15,278.15,278.15,278.15,278.15,278.15], index=Horizon)


    dist = {'T_amb': T_amb, 'Q_fl_hs_hc': Q_hot_demand, 'Q_fl_cc_cs': Q_cold_demand}

    x0 = {'T_con': 303.1234, 'T_ev': 282, 'T_hs': 308, 'T_cs': 287, 'T_rc': 290, 'T_as': 290, 'T_coil': 287}

    u0 = {'n_hp': 0.1}
    u0bin = {"hp_heat_hs":0,"hp_cool_cs":0, "hp_off":1}

    start = time.time()
    results, instance, sol = pes.get_control(x0=x0, u0=u0, disturbances=dist)
    print(time.time() - start)








































import shutil
import fmpy
import fmpy.fmi2
import ddmpc
import pandas as pd
import numpy as np

from ddmpc.modeling import Model, Control, Controlled, BaseVariable
from ddmpc.plotting import Plotter
from ddmpc.pickle_handler import write_pkl, read_pkl
from ddmpc.training_networks import NetworkTrainer
import ddmpc.formatting as fmt
from os import listdir
from os.path import isfile, join

from pbmpc.run_optimization import ProducerMPC

class FMU:
    def __init__(
            self,
            step_size:      int,
            fmu_name:       str,
            control_producer: bool = False,
            directory:      str = 'stored_data/FMUs',
            sim_tolerance:  float = 0.00001,
            instance_name:  str = 'fmu',
    ):
        """
        Simulate fmu files in Python.\n
        To run the simulation please use the following functions in this order:
        \t 1. setup()\n
        \t 2. run()\n
        \t 3. close()\n

        :param step_size:       The macro time step
        :param path:        The path to the .fmu file
        :param sim_tolerance:   The total simulation tolerance
        :param instance_name:   Name of the instance
        """

        # settings
        self.step_size = step_size
        self.fmu_name = fmu_name
        self.directory = directory
        self.sim_tolerance = sim_tolerance
        self.instance_name = instance_name

        # initialization
        self.fmu = None

        # time
        self.start_time = None
        self.stop_time = None
        self.current_time = None

        # description
        self.description = self._read_description()

        # variables
        self.variable_dict = self._get_variable_dict()

        # control dict
        self.control_dict = {}

        # kbe: external producer controller and FMU including controlled producer required
        self.include_producer = control_producer
        self.producer_mpc = None

    def __str__(self):
        ret = f'\033[1mFMU:\033[0m\n'
        ret += f'\tstep_size = {self.step_size}s \n'
        ret += f'\tfmu_path = "{self.fmu_path}" \n'
        ret += f'\tsim_tolerance = {self.sim_tolerance} \n'
        return ret

    def __repr__(self):
        return f'FMU(path={self.fmu_path}'

    @property
    def fmu_path(self):
        return f'{self.directory}/{self.fmu_name}'

    @property
    def variables(self):
        return self.description.modelVariables

    def get_variable_by_name(self, name: str):
        assert name in self.variable_dict.keys(), f'The variable with name {name} was not found.'
        return self.variable_dict[name]

    def print_summary(self):
        fmpy.dump(self.fmu_path)

    def print_variables(self):
        print('ModelVariables:')
        for variable in self.variables:
            print('\t', variable)

    def setup(self, start_time: int):
        """
        Sets up the simulation for a given start time.
        """
        assert self.fmu is None, 'Please make sure the simulation was closed'
        assert start_time >= 0, 'Please make sure the start time is greater or equal to zero.'

        # start time
        self.current_time = start_time

        # create a slave
        self.fmu = fmpy.fmi2.FMU2Slave(
            guid=self.description.guid,
            unzipDirectory=fmpy.extract(self.fmu_path),
            modelIdentifier=self.description.coSimulation.modelIdentifier,
            instanceName=self.instance_name
        )

        # create an instance of the fmu
        self.fmu.instantiate()

        # reset the fmu
        self.fmu.reset()

        # start new experiment
        self.fmu.setupExperiment(
            startTime=start_time,
            tolerance=self.sim_tolerance
        )
        self.fmu.enterInitializationMode()
        self.fmu.exitInitializationMode()

    def run(self, duration: int, model: Model, controllers: tuple = tuple()) -> pd.DataFrame:
        """
        Runs the fmu file.
        :param duration:    Duration of the simulation.
        :param model:       Model representation.
        :param controllers: Tuple with all controllers.
        :return:
        """

        # store mpc predictions of consumer and producer for quality check:
        store_MPC_prod_traj = False
        store_MPC_cons_traj = False

        if store_MPC_prod_traj:
            prod_30min = pd.DataFrame()
            prod_45min = pd.DataFrame()

        # assertions
        assert self.fmu is not None,\
            'Please make sure to call the function "setup()" first.'
        for controller in controllers:
            assert self.step_size <= controller.dt,\
                f'Please make sure the dt of the controller (dt={controller.dt})' \
                f' is greater or equal to the step_size of the fmu (step_size={self.step_size}).'
            assert controller.dt % self.step_size == 0,\
                f'The dt of the controller (dt={controller.dt}) ' \
                f'must be multiple of the step_size of the fmu (step_size={self.step_size}).'

        # update the start and stop time
        self.start_time = self.current_time
        self.stop_time = self.current_time + duration


        # kbe: initialize producer controller
        if self.include_producer:
            # check if ddmpc consumer controller is active (and not PID's for training)
            assert len(controllers) == 1 and type(controllers[0]) == ddmpc.mpc.ModelPredictive,\
                f'including producer controller only possible for ddmpc- controlled consumer (yet)'

            # initialize producer controller and hand external predefined disturbances
            self.producer_mpc = ProducerMPC(dist_ext=controllers[0].disturbances_df)  # todo: set settings (setup) elsewhere; nessesary to set self for producermpcß
            assert self.producer_mpc.mpc_horizon[-1] <= controllers[0].N * controllers[0].dt, \
                f'make sure consumer time horizon is longer than producer time horizon'
            assert controllers[0].dt % self.producer_mpc.mpc_step_size == 0, \
                f'make sure mpc step of consumer is multiple of mpc_step of producer'

        # extract var_names that are included in the fmu
        var_names = [feature.col_name for feature in model.base_variables]
        var_names = [var_name for var_name in var_names if var_name in self.variable_dict.keys()]

        # initialize data frames of the controlled variables
        for y in model.controlled:
            y.plan_simulation(start_time=self.start_time, stop_time=self.stop_time, step_size=self.step_size)

        # initialize data frame (read values from fmu)
        df = pd.DataFrame(self._read_values(var_names), columns=['SimTime', *var_names], index=[0])

        # initialize control actions of consumer control with default values (write to fmu)
        for control in model.controls:
            self._write_value(control.col_name, control.default)

        # simulation loop
        while self._do_step():

            if self.current_time > 18106800:
                print()
            if self.current_time % self.step_size == 0:
                # print time
                self._display_time(self.current_time)

                # get the current state of the System (read from fmu)
                df = df.append(pd.DataFrame(self._read_values(var_names), index=[0]), ignore_index=True)

                # update the target and bounds dataframe
                for y in model.controlled:
                    y.update(df=df)

                # calculate the consumer controls (and read predicted demand trajectory)
                control_dict = dict()
                for controller in controllers:
                    if self.current_time % controller.dt == 0:
                        # calculate the consumer controls
                        if self.include_producer:  # if producer included, also read trajectory of heat demand prediction
                            controls, demand_dict = controller(df)
                        else:
                            controls = controller(df)

                        # add the controls to the control dictionary  # kbe: todo: why? its already a dict
                        for key, value in controls.items():
                            if key in control_dict.keys():
                                control_dict[key] += value
                            else:
                                control_dict[key] = value

                # write cosumer controls to fmu
                self._write_values(control_dict)

                # control the producer based on the demand predictions
                if self.include_producer:
                    # for case fmu-step < control step  # todo: here the step size of the consumer controller is read and expected to match the step size of producer controller
                    if self.current_time % controllers[0].dt == 0:
                        # read actual producer state from fmu
                        producer_state = self._read_values(var_names=self.producer_mpc.fmu_vars)
                        # convert AHU and Tabs demand into cooling or heating demand
                        demand_df = self.convert_demand(component_demand=demand_dict)
                        # call producer controller
                        producer_ctrls , mpc_prod_traj= self.producer_mpc.calculate_controls(dist_dmd=demand_df, res=producer_state,
                                                                              current_time=self.current_time)

                        if store_MPC_prod_traj:
                            # adjust for varied prediction horizon
                            # add current time and time of prediction

                            mpc_prod_traj['1800'].update({'t_pred_rec': self.current_time,'t_pred_val':self.current_time+1800})
                            mpc_prod_traj['2700'].update({'t_pred_rec': self.current_time,'t_pred_val':self.current_time+2700})

                            prod_30min = prod_30min.append(mpc_prod_traj['1800'], ignore_index=True)
                            prod_45min = prod_45min.append(mpc_prod_traj['2700'], ignore_index=True)


                        # write producer controls to fmu
                        self._write_values(var_dict=producer_ctrls)

                # fixme: Problem: when hp is turned off in ctrl inputs, the bus variable Pel is also set to zero (probably because of switch in dymola -> model equations are rewritten)
                # workaround: store value before it gets overwritten
                if self.include_producer:
                    temp_res = df.iloc[-1]['producerBus.busHP.PelMea']
                    temp_res1 = df.iloc[-1]['producerBus.Q_hr_set']

                # delete last row to append last row with valid control (to store controls in previous row of the resultng state9
                df.drop(df.tail(1).index, inplace=True)

                # read variables (from fmu) and add to the data frame (to cover new control actions)
                res = self._read_values(var_names)
                # # add current time to results
                # res['SimTime'] = self.current_time

               # restore value from before since its not an input and shoulnt be overwritten
                if self.include_producer:
                    res['producerBus.busHP.PelMea']=temp_res  # fixme: check if this applies to cooler Power and others as well!!
                    res['producerBus.Q_hr_set'] = temp_res1
                df = df.append(pd.DataFrame(res, index=[0]), ignore_index=True)
                #df = df.append(pd.DataFrame(self._read_values(var_names), index=[0]), ignore_index=True)  # kbe
                print()
                # kbe: save file each hour
                debug = False
                if debug:
                    # if self.current_time % (4*self.step_size) == 0:
                    if self.current_time % (self.step_size) == 0:
                        write_pkl(data=df, filename='inter_results', directory='stored_data/term_results', override=True)
                        print('interim results saved')


        # write prediction trajectories to file here


        # end line
        print('\n')

        return df

    def convert_demand(self, component_demand: dict) -> pd.DataFrame:
        """
        organize demand trajectories depending on heating/cooling instead of components
        :param component_demand: demand trajectories component based
        :return: demand trajectories sorted by heating/cooling
        """

        # # add zeros for actual values since producer expects Horizon starting with 0
        # # values for time 0 are being overwritten in producer with current value
        # for key in component_demand.keys():
        #     component_demand[key] = [0] + component_demand[key]

        # extract demand and horizon from dict
        plant_list = ['Q_AHU_pred','Q_Tabs_pred']
        time_of_prediction = np.array(component_demand['Horizon'])+self.current_time

        # store demand trajectory in a matrix: each row stands for one component
        demand_list = []
        # for key in component_demand.keys():
        for key in plant_list:
            demand_list.append(component_demand[key])
        demand_matrix = np.array(demand_list)

        # read component based demands and assign them to cooling or hearing
        heating_demand = []
        cooling_demand = []
        for j in range(demand_matrix.shape[1]):
            cool = 0
            heat = 0
            for i in range(demand_matrix.shape[0]):
                if demand_matrix[i, j] >= 0:
                    heat += demand_matrix[i, j]
                else:
                    cool += abs(demand_matrix[i, j])
            heating_demand.append(heat)
            cooling_demand.append(cool)

        demand_df = pd.DataFrame({'Q_fl_hs_hc': heating_demand, 'Q_fl_cc_cs': cooling_demand, 'time_of_prediction': time_of_prediction},  index=time_of_prediction) #index=range(1,len(time_of_prediction)+1))#
        return demand_df

    def close(self):
        """
        Closes the simulation and clears the fmu object.
        """

        self.fmu.terminate()
        self.fmu.freeInstance()
        shutil.rmtree(fmpy.extract(self.fmu_path))

        self.__init__(
            step_size=self.step_size,
            fmu_name=self.fmu_name,
            sim_tolerance=self.sim_tolerance,
            instance_name=self.instance_name,
            control_producer=self.include_producer
        )
        print('FMU released')

    def _do_step(self):
        """
        Simulates one step.
        """

        # return finish status
        if self.current_time < self.stop_time:

            self.fmu.doStep(
                currentCommunicationPoint=self.current_time,
                communicationStepSize=self.step_size
            )

            # increment time
            self.current_time += self.step_size

            return True

        else:
            return False

    def _read_description(self):
        """
        Reads the model description.
        """

        # open fmu file
        if isfile(self.fmu_path):
            file = open(self.fmu_path)

        else:
            raise AttributeError(f'FMU file with path "{self.fmu_path}" does not exist.')

        # read model description
        model_description = fmpy.read_model_description(self.fmu_path)

        # close fmu file
        file.close()

        # return model  description
        return model_description

    def _get_variable_dict(self) -> dict:

        assert self.description is not None, 'Please make sure to read model description first.'

        # collect all variables
        variables = dict()
        for variable in self.description.modelVariables:
            variables[variable.name] = variable

        return variables

    def _read_values(self, var_names: list) -> dict:
        """
        Reads multiple variable values of FMU.
        """

        res = {}
        # read current variable values ans store in dict
        for var_name in var_names:
            res[var_name] = self._read_value(var_name)

        # add current time to results
        res['SimTime'] = self.current_time

        return res

    def _write_values(self, var_dict: dict):
        """
        Sets multiple variables.
        """

        for var_name, value in var_dict.items():
            self._write_value(var_name, value)

    def _read_value(self, var_name: str):
        """
        Get a single variable.
        """

        variable = self.variable_dict[var_name]
        vr = [variable.valueReference]

        if variable.type == 'Real':
            return self.fmu.getReal(vr)[0]
        elif variable.type in ['Integer', 'Enumeration']:
            return self.fmu.getInteger(vr)[0]
        elif variable.type == 'Boolean':
            value = self.fmu.getBoolean(vr)[0]
            return value != 0
        else:
            pass
            raise Exception("Unsupported type: %s" % variable.type)

    def _write_value(self, var_name: str, value):
        """
        Set a single variable.
        """

        variable = self.variable_dict[var_name]
        vr = [variable.valueReference]

        if variable.type == 'Real':
            self.fmu.setReal(vr, [float(value)])
        elif variable.type in ['Integer', 'Enumeration']:
            self.fmu.setInteger(vr, [int(value)])
        elif variable.type == 'Boolean':
            self.fmu.setBoolean(vr, [value == 1.0 or value == True or value == "True"])
        else:
            raise Exception("Unsupported type: %s" % variable.type)

    @staticmethod
    def _display_time(seconds):

        result = []
        if seconds % 60 == 0:
            for name, count in (('weeks', 604800),  # 60 * 60 * 24 * 7
                                ('days', 86400),  # 60 * 60 * 24
                                ('hours', 3600),
                                ('minutes', 60),
                                ):

                value = seconds // count

                if value:
                    seconds -= value * count

                if value == 1:
                    name = name.rstrip('s')

                result.append("{} {}".format(value, name))
            result = ' - '.join(result)
            print(f'\r\tSimulating FMU: {result}', end='',)


class RunFMU:
    """
    Holds information about a single execution of a fmu.
    """

    def __init__(
            self,
            controllers: tuple,
            duration: int,
            tag: str = 'none',
            save_plot: bool = True,
            show_plot: bool = True,
    ):
        """
        :param controllers: [Tuple]     All controllers that are supposed to be used for the simulation.
        :param duration:    [int]       Duration of the simulation.
        :param tag:         [Str]       'Training', 'Testing' or 'validating'.
        :param save_plot:   [Boolean]   Save the plot.
        """
        self.controllers = controllers
        self.duration = duration
        self.tag = tag
        self.save_plot = save_plot
        self.show_plot = show_plot

    def __str__(self):
        return f'RunFMU(duration={self.duration/(60*60)}h, tag={self.tag})'

    @property
    def tag(self):
        return self._tag

    @tag.setter
    def tag(self, value: str):

        value = value.lower()
        assert value in ['training', 'testing', 'validating', 'none']

        self._tag = value


class TrainNetworks:
    """
    Holds information for training ANNs. Should be used for online learning.
    """

    def __init__(
            self,
            *network_trainers: NetworkTrainer,
            epochs: int = 250,
            batch_size: int = 100,
            last_n_containers: int = 1,
            clear_data: bool = True,
            save_ann: bool = True,
            shuffle: bool = True,
    ):
        """

        :param network_trainers:    [tuple] NetworkTrainers that hold the ANNs to train.
        :param epochs:              [int]   Number of epochs.
        :param batch_size:          [int]   Size of one training batch.
        :param last_n_containers:   [int]   Number of last n containers that should be loaded to the NetworkTrainer.
        :param clear_data:          [bool]  Should the data that the NetworkTrainer contains be deleted?
        :param save_ann             [bool]  Should the ann be saved to the hard drive?
        """

        self.network_trainers = network_trainers
        self.last_n_containers = last_n_containers
        self.epochs = epochs
        self.batch_size = batch_size
        self.clear_data = clear_data
        self.save_ann = save_ann
        self.shuffle = shuffle

    def __str__(self):
        return f'TrainNetworks(NetworkCount={len(self.network_trainers)},' \
               f' epochs={self.epochs}, batch_size={self.batch_size})'


class SimulationPlan:
    """
    Defines the concrete order in which the FMU is executed and ANN's are trained.
    """

    def __init__(self,
                 *simulations,
                 start_time: int,
                 repetitions: int = 0,
                 ):
        """
        :param simulations: Instances of RunFMU and TrainNetworks.
        :param start_time:  [int] Start time at which the simulation is supposed to be started.
        :param repetitions: [int] How often should the SimulationPlan be repeated?
        """

        self.start_time = start_time
        self.plan = list(simulations) * (repetitions + 1)

    def __str__(self):
        ret = f'Simulation Plan (start_time={self.start_time / (60 * 60 * 24)} day(s)): \n'

        for index, p in enumerate(self.plan):
            ret += f'{index} \t {p.duration / (60 * 60 * 24)} day(s) - {p.tag} \n'
        return ret

    def __repr__(self):
        return f'SimulationPlan {len(self.plan)}'

    def __iter__(self):
        self.i = 0
        return self

    def __next__(self):
        if self.i < len(self.plan):
            ret = self.plan[self.i]
            self.i += 1
            return ret
        else:
            raise StopIteration

    def add(self, *simulations):
        for simulation in simulations:
            self.plan.append(simulation)


class DataContainer:
    """
    The DataContainer stores simulated training data and additional information.
    """

    def __init__(
            self,
            df:         pd.DataFrame,
            tag:        str,
            directory:  str = 'stored_data\\RawData',
    ):
        """
        :param df:          [pd.DataFrame] Simulated data.
        :param tag:         [Str] 'Training', 'Testing' or 'Validating'.
        """

        self.df = df
        self._tag = tag

        self.directory = directory

    def __str__(self):
        return f'DataContainer({self.info})'

    def __repr__(self):
        return f'DataContainer({self._tag})'

    @property
    def info(self):
        return f"Day {int(self.start_time/(60*60*24))} to {int(self.stop_time/(60*60*24))} - {self._tag}"

    @property
    def tag(self):
        return self._tag

    @tag.setter
    def tag(self, value: str):
        value = value.lower()
        assert value in ['training', 'testing', 'validating', 'none']
        self._tag = value

    @property
    def start_time(self):
        return self.df['SimTime'].iloc[0]

    @property
    def stop_time(self):
        return self.df['SimTime'].iloc[-1]

    @property
    def duration(self):
        return self.stop_time - self.start_time

    def calculate_statistics(self, model: Model):
        """
        Returns a statistic dict with important benchmark information.
        """
        statistics = dict()

        for x in model.X:

            statistics[x] = dict()
            statistics[x]['mean'] = self.df[x.col_name].mean()
            statistics[x]['lb'] = self.df[x.col_name].min()
            statistics[x]['ub'] = self.df[x.col_name].max()

            if f'{x.col_name} error_target' in self.df.columns:

                statistics[x]['target_mae'] = self.df[f'{x.col_name} error_target'].mean()
                statistics[x]['target_mse'] = (self.df[f'{x.col_name} error_target'] ** 2).mean()

            if f'{x.col_name} error_bounds' in self.df.columns:
                statistics[x]['bounds_mae'] = self.df[f'{x.col_name} error_bounds'].mean()
                statistics[x]['bounds_mse'] = (self.df[f'{x.col_name} error_bounds'] ** 2).mean()

            if f'{x.col_name} solver_call' in self.df.columns:
                statistics[x]['average_solver_call'] = self.df[f'{x.col_name} solver_call'].mean()
                statistics[x]['minimum_solver_call'] = self.df[f'{x.col_name} solver_call'].min()
                statistics[x]['maximum_solver_call'] = self.df[f'{x.col_name} solver_call'].max()

        return statistics

    def plot(self, plotter: Plotter, save_plot: bool = True, show_plot: bool = True):

        plotter.plot(df=self.df, name=self.info, save_plot=save_plot, show_plot=show_plot)

    def save_raw(self, override: bool = False):
        write_pkl(self.df, self.__str__(), self.directory, override)

    def save(self, override: bool = False):
        write_pkl(self, self.__str__(), self.directory, override)


class DataSimulator:
    """
    Used to simulate communicate between the FMU and the DataHandler.
    It sets up, runs and closes the simulation.
    """

    def __init__(
            self,
            fmu: FMU,
            model: Model
    ):

        self.fmu = fmu
        self.model = model

    def __str__(self):
        ret = self.fmu.__str__()
        ret += self.model.__str__()
        return ret

    def setup(self, start_time: int):

        if self.fmu.fmu is None:
            self.fmu.setup(start_time=start_time)
        else:
            raise AttributeError('The fmu is already set up.')

    def run(self, controllers: tuple, duration: int) -> pd.DataFrame:
        """
        Runs the simulation.
        :param controllers: Tuple with all Controllers.
        :param duration:    Duration of the simulation in seconds.
        """

        # run the fmu
        df = self.fmu.run(duration=duration, model=self.model, controllers=controllers)

        # feature creation
        df = Model.feature_creation(features=self.model.features, df=df)

        # return the simulated data
        return df

    def close(self):
        """
        Closes the fmu instance.
        """
        self.fmu.close()


class DataHandler:
    """
    Stores the FMU, the Model as well as the simulated Data in DataContainers.
    """

    def __init__(
            self,
            fmu:                    FMU,
            model:                  Model,
            # plotter:                Plotter = None, # kbe: allow multiple plotters
            plotter:                tuple,
            directory:              str = 'stored_data\\DataHandlers',
            disturbances_directory: str = 'stored_data\\Disturbances',
            settings:               dict = {}  # kbe: store settings of FMU, consumer controller and producer controller

    ):
        """
        :param fmu:     Instance of FMU
        :param model:   Instance of Model
        :param plotter: Instance of Plotter
        """

        # The plotter is used to plot the simulated data
        self.plotter = plotter

        # kbe: store all setings in dictionary
        self.settings = settings

        # The data_simulator is used to execute the fmu file
        self.data_simulator = DataSimulator(fmu, model)

        # directories
        self.directory = directory
        self.disturbances_directory = disturbances_directory

        # A list with all simulated data stored in DataContainers
        self.containers = list()

        # Generate a pandas DataFrame that holds the disturbances.
        self.check_disturbances()
        print()

    def __str__(self):

        ret = f'{fmt.BOLD}DataHandler:{fmt.ENDC} \n\t'
        ret += self.data_simulator.fmu.__str__().replace('\n', '\n\t')
        ret += f'{fmt.BOLD}Containers: {fmt.ENDC}\n'
        if len(self.containers) == 0:
            ret += '\t\tNone'
        for container in self.containers:
            ret += f'\t\t{container} \n'

        return ret

    @property
    def model(self):
        return self.data_simulator.model

    @property
    def fmu(self):
        return self.data_simulator.fmu

    @property
    def disturbances_filepath(self):
    # kbe: dont check for internal FMU name
    #     ret = f'{self.disturbances_directory}\\' \
    #           f'{self.data_simulator.fmu.description.modelName}_' \
    #           f'{self.data_simulator.fmu.step_size}'\
    #           f'.pkl'

        ret = f'{self.disturbances_directory}\\' \
              f'dist_step_size_' \
              f'{self.data_simulator.fmu.step_size}' \
              f'.pkl'

        return ret

    def run_FMU(self, run_fmu: RunFMU):
        """
        Runs a single simulation.
        The generated data is stored in a DataContainer.
        """

        # print the simulation
        print(run_fmu)

        # run the simulation
        df = self.data_simulator.run(run_fmu.controllers, duration=run_fmu.duration)

        # merge the data
        for controlled in self.data_simulator.model.controlled:
            df_tracking = controlled.df
            df_tracking.columns = [f'{controlled.col_name} {col}' for col in df_tracking.columns]
            df = pd.concat([df, df_tracking], axis=1)

        # dump the data into a data container
        container = DataContainer(
            df=df,
            tag=run_fmu.tag,
        )

        # plot
        #kbe: allow multiple plotters
        for p in self.plotter:
            #container.plot(plotter=self.plotter, save_plot=run_fmu.save_plot, show_plot=run_fmu.show_plot)
            container.plot(plotter=p, save_plot=run_fmu.save_plot, show_plot=run_fmu.show_plot)

        # append to containers
        self.containers.append(container)

    def reinitialize_FMU(self, fmu_path: str = None):

        if fmu_path is not None:
            self.data_simulator.fmu = FMU(step_size=self.data_simulator.fmu.step_size,
                                          fmu_name=fmu_path,
                                          sim_tolerance=self.data_simulator.fmu.sim_tolerance,
                                          instance_name=self.data_simulator.fmu.instance_name,
                                          control_producer=self.data_simulator.fmu.include_producer,
                                          )
        else:
            self.data_simulator.fmu = FMU(step_size=self.data_simulator.fmu.step_size,
                                          fmu_name=self.data_simulator.fmu.fmu_name,
                                          sim_tolerance=self.data_simulator.fmu.sim_tolerance,
                                          instance_name=self.data_simulator.fmu.instance_name,
                                          control_producer=self.data_simulator.fmu.include_producer,
                                          )

    def train_networks(self, train_networks: TrainNetworks):

        # print
        print(train_networks)

        # select the DataContainers
        containers = self.containers[-train_networks.last_n_containers:]

        # iterate through all network trainers
        for network_trainer in train_networks.network_trainers:
            if train_networks.clear_data:
                network_trainer.clear_data()
            network_trainer.load_data(containers)  # todo 18.2.
            if train_networks.shuffle:
                network_trainer.shuffle_training_data()

            network_trainer.train(epochs=train_networks.epochs, batch_size=train_networks.batch_size)
            network_trainer.test(network_trainer.ann)

            if train_networks.save_ann == True:
                network_trainer.save_ann()

    def simulate_plan(self, simulation_plan: SimulationPlan):
        """
        Runs every simulation that is stored in the simulation plan
        """

        # setup the data simulator
        self.data_simulator.setup(simulation_plan.start_time)

        # iterate over every simulation
        for simulation in simulation_plan:

            if isinstance(simulation, RunFMU):
                self.run_FMU(simulation)
            elif isinstance(simulation, TrainNetworks):
                self.train_networks(simulation)

        # close fmu
        self.data_simulator.close()

    def check_disturbances(self):
        """
        This function checks whether there are already matching disturbances. If not so they must be generated.
        """

        # check if the disturbances already exist.
        if isfile(self.disturbances_filepath):
            print()
            return 0

        # otherwise simulate them.
        else:
            print(f'Disturbances were not found at "{self.disturbances_directory}".'
                  f' Preparing to simulate disturbances...')

            self.simulate_disturbances() #kbe: decide on my own

    def simulate_disturbances(self, start_time: int = 0, stop_time: int = 60*60*24*365):
        """
        Simulates the fmu file without a controller and then extracts only the disturbances from it.
        Afterwards the DataFrame is stroed at the disturbances_filepath
        :param disturbances_filepath:   Filepath at which the disturbances should be stored.
        :param start_time:              Start of the disturbances DataFrame
        :param stop_time:               End of the disturbances DataFrame
        """

        # setup the data simulator
        self.data_simulator.setup(start_time)

        # run the data simulator
        df = self.data_simulator.run(controllers=(), duration=stop_time-start_time)

        # close the fmu
        self.data_simulator.close()

        # features to track
        model = self.data_simulator.model
        disturbances = [feature.col_name for feature in model.t + model.D]
        df = df[disturbances]

        # print
        print(f'{fmt.BOLD}Disturbances were simulated:{fmt.ENDC} \n {df.to_string()}')

        # save as pickle
        write_pkl(df, self.disturbances_filepath)

    def clear_data(self):
        """
        Clears the list with the DataContainers.
        """
        del self.containers
        self.containers = list()

    def print_container_statistics(self):
        """
        Prints the statistics for every DataContainer.
        """
        for container in self.containers:
            print(f'Statistics for {container}:')
            print(f'\t{container.calculate_statistics(model=self.model)}')

    def plot_containers(self, save: int = True):
        """
        Generates a plot for every DataContainer.
        :param save: [bool] Save the plot?
        """
        #kbe: allow multiple plotters
        for p in self.plotter:
            for c in self.containers:
                #c.plot(plotter=self.plotter, save=save)
                c.plot(plotter=p, save=save)

    def save_containers(self, override: bool = True):
        """
        Saves the DataContainers.
        :param override:
        """
        for c in self.containers:
            c.save(override)

    def load_containers(self, container_names: list = None, directory: str = None):
        """
        Load previously saved DataContainers back in.
        :param container_names: [list] List with the name of the DataContainers that should be loaded in.
        :param directory: [str] Directory name.
        """

        if container_names is None:
            container_names = [f for f in listdir(directory) if isfile(join(directory, f))]

        for container_name in container_names:
            container = read_pkl(container_name, directory)
            self.containers.append(container)

    def save(self, filename: str, override: bool = False):
        write_pkl(self, filename, self.directory, override)


def load_DataHandler(filename: str, directory: str = 'stored_data\\DataHandlers') -> DataHandler:
    dh = read_pkl(filename, directory)
    print(dh)
    return dh
