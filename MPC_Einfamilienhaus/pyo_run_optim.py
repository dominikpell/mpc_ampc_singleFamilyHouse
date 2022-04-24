# -*- coding: utf-8 -*-
"""

MPC SingleFamilyHouse

Developed by:   Dominik Pell
                E.ON Energy Research Center,
                Institute for Energy Efficient Buildings and Indoor Climate,
                RWTH Aachen University, 
                Germany

Developed in:  2021-2022

"""


# import sys
# print(sys.path)
# from optimization.plot_tool import plot_results
# import matplotlib.pyplot as plt


import string
import ast

import numpy as np
from pyomo.environ import *
from pyomo.dae import *
# import gurobipy as gp
import time
# import pdb
import json
import os
# import physical_mpc_controller


def write_json(target_path, file_name, data):
    if not os.path.exists(target_path):
        os.makedirs(target_path)
    with open(os.path.join(target_path, file_name), "w") as f:
        json.dump(data, f, indent=4, separators=(", ", ": "), sort_keys=True)


def load_json(target_path, file_name):
    with open(os.path.join(target_path, file_name)) as f:
        last_results = json.load(f)
    return last_results


# Run optimization
def run_optim(prediction_horizon, control_horizon, time_step, parameters, devs, initials, demand, time_series, run, hour):

    # Initialize time steps
    time_steps = list(range(int(prediction_horizon / time_step)))

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    start_time = time.time()

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Setting up the model

    # Create a new model
    model = AbstractModel(name="Optimization model")
    model.time_steps = ContinuousSet(bounds=(0,int(prediction_horizon/time_step)))
    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Create new variables

    pow = ["HP", "PV", "to_grid", "from_grid"]
    storage = ["TES", "DHW", "BAT"]

    par = get_par()
    """ Calculate simplified Heat Transfers based on Modelica Model 4 C Model"""
    # Evaluate Components
    has_roof = par['ARoof'] > 0
    has_floor = par['AFloor'] > 0

    # Calculate Total and mean Areas
    AWintot = float(sum(par['AWin'])) if type(par['AWin']) == list else float(par['AWin'])
    AWinMean = float(sum(par['AWin']) / len(par['AWin'])) if type(par['AWin']) == list else 0
    AExttot = float(sum(par['AExt'])) if type(par['AExt']) == list else float(par['AExt'])
    AExtMean = float(sum(par['AExt']) / len(par['AExt'])) if type(par['AExt']) == list else 0
    AInttot = float(sum(par['AInt'])) if type(par['AInt']) == list else float(par['AInt'])
    AIntMean = float(sum(par['AInt']) / len(par['AInt'])) if type(par['AInt']) == list else 0
    ARooftot = float(sum(par['ARoof'])) if type(par['ARoof']) == list else float(par['ARoof'])
    ARoofMean = float(sum(par['ARoof']) / len(par['ARoof'])) if type(par['ARoof']) == list else 0
    AFloortot = float(sum(par['AFloor'])) if type(par['AFloor']) == list else float(par['AFloor'])
    AFloorMean = float(sum(par['AFloor']) / len(par['AFloor'])) if type(par['AFloor']) == list else 0
    Atot = AWintot + AExttot + AInttot + ARooftot + AFloortot
    AMeanTot = AWinMean + AExtMean + AIntMean + ARoofMean + AFloorMean

    # Calculate Splitfactors for Internal Gains
    splitIntIG = AInttot / (Atot)
    splitRoofIG = ARooftot / (Atot)
    splitExtIG = AExttot / (Atot)
    splitWinIG = AWintot / (Atot)
    splitRoofIG = ARooftot / (Atot)
    splitFloorIG = AFloortot / (Atot)

    # Calculate Splitfactors for Solar Radiation
    # (Compared to the Modelica Model we don't calculate n_orientation*n_components Splitfactors, instead we average over all orientations
    # to keep the model simple)
    splitIntSol = 0.32  # (AInttot - AIntMean)/(Atot - AMeanTot)
    splitRoofSol = 0.32  # (ARooftot - ARoofMean)/(Atot - AMeanTot)
    splitExtSol = 0.36  # (AExttot - AExtMean)/(Atot - AMeanTot)
    splitWinSol = 0  # (AWintot - AWinMean)/(Atot - AMeanTot)
    splitFloorSol = 0  # (AFloortot - AFloorMean)/(Atot - AMeanTot)

    # Pass Factors for Internal Gains
    specPers = par['specificPeople']
    activityDegree = par['activityDegree']
    fixedHeatFlowRatePersons = par['fixedHeatFlowRatePersons']
    ratioConv_human = par['ratioConvectiveHeatPeople']
    internalGainsMoistureNoPeople = par['internalGainsMoistureNoPeople']
    internalGainsMachinesSpecific = par['internalGainsMachinesSpecific']
    ratioConvectiveHeatMachines = par['ratioConvectiveHeatMachines']
    lightingPowerSpecific = par['lightingPowerSpecific']
    ratioConvectiveHeatLighting = par['ratioConvectiveHeatLighting']
    ARoom = par['AZone']

    # Pass Paramters
    c_spec_Air = 1000
    CAir = par['VAir'] * 1.204 * c_spec_Air
    VAir = par['VAir']
    CInt = par['CInt']
    CFloor = par['CFloor']
    CRoof = par['CRoof']
    CExt = par['CExt']
    TSoil = par['TSoil']
    CWin = AWintot * 0.01 * 2500 * 720

    """ Calculate Heat transfers """
    # Roof
    if has_roof:
        k_Amb_Roof = 1 / (1 / ((par['hConRoofOut'] + par['hRadRoof']) * ARooftot) + par['RRoofRem'])
        k_Win_Roof = 1 / (1 / (min(AWintot, ARooftot) * par['hRad']) + par['RRoof'])
        k_Air_Roof = 1 / (1 / (par['hConRoof'] * ARooftot) + par['RRoof'])
        k_Int_Roof = 1 / (1 / (par['hRad'] * min(AInttot, ARooftot)) + par['RInt'] + par['RRoof'])
        k_Ext_Roof = 1 / (1 / ((par['hRad'] * min(AExttot, ARooftot))) + par['RExt'] + par['RRoof'])
        if has_floor:
            k_Floor_Roof = 1 / (1 / ((par['hRad'] * min(AFloortot, ARooftot))) + par['RFloor'] + par['RRoof'])
        else:
            k_Floor_Roof = 0
    else:
        k_Amb_Roof = 0
        k_Win_Roof = 0
        k_Air_Roof = 0
        k_Int_Roof = 0
        k_Ext_Roof = 0
        k_Floor_Roof = 0

    # Floor
    if has_floor:
        k_Soil_Floor = 1 / par['RFloorRem']
        k_Roof_Floor = k_Floor_Roof
        k_Ext_Floor = 1 / (1 / ((par['hRad'] * min(AFloortot, AExttot))) + par['RExt'] + par['RFloor'])
        k_Int_Floor = 1 / (1 / ((par['hRad'] * min(AFloortot, AInttot))) + par['RInt'] + par['RFloor'])
        k_Air_Floor = 1 / (1 / (par['hConFloor'] * AFloortot) + par['RFloor'])
        k_Win_Floor = 1 / (1 / (min(AWintot, AFloortot) * par['hRad']) + par['RFloor'])
    else:
        k_Soil_Floor = 0
        k_Roof_Floor = 0
        k_Ext_Floor = 0
        k_Int_Floor = 0
        k_Air_Floor = 0
        k_Win_Floor = 0

    # Exterior Walls
    k_Amb_Ext = 1 / (1 / ((par['hConWallOut'] + par['hRadWall']) * AExttot) + par['RExtRem'])
    k_Win_Ext = 1 / (1 / (min(AExttot, AWintot) * par['hRad']) + par['RExt'])
    k_Air_Ext = 1 / (1 / (par['hConExt'] * AExttot) + par['RExt'])
    k_Int_Ext = 1 / (1 / (par['hRad'] * min(AExttot, AInttot)) + par['RInt'] + par['RExt'])
    k_Roof_Ext = k_Ext_Roof
    k_Floor_Ext = k_Ext_Floor

    # Indoor Air
    k_Win_Air = 1 / (1 / (par['hConWin'] * AWintot))
    k_Roof_Air = k_Air_Roof
    k_Int_Air = 1 / (1 / (par['hConInt'] * AInttot) + par['RInt'])
    k_Ext_Air = k_Air_Ext
    k_Floor_Air = k_Air_Floor

    # Interior Walls
    k_Air_Int = k_Int_Air
    k_Ext_Int = k_Int_Ext
    k_Roof_Int = k_Int_Roof
    k_Win_Int = 1 / (1 / (min(AWintot, AInttot) * par['hRad']) + par['RInt'])
    k_Floor_Int = k_Int_Floor

    # Window
    k_Amb_Win = 1 / (par['RWin'] + 1 / ((par['hConWinOut'] + par['hRadWall']) * AWintot))


    # Eletrical power to/from devices
    # Grid maximum transmission power
    model.grid_limit_el = Var(within=NonNegativeReals, name="grid_limit_el")

    # Total energy amounts imported from grid
    model.from_grid_total = Var(within=NonNegativeReals, name="from_grid_total")
    # Total power to grid
    model.to_grid_total = Var(within=NonNegativeReals, name="to_grid_total")

    #%% BUILDING VARIABLES

    # Eletrical power to/from devices
    model.power = Var(pow, time_steps, within=NonNegativeReals, name="power")
    model.power_heat = Var(["HP"], time_steps, within=NonNegativeReals, name="power_heat")
    model.power_cool = Var(["HP"], time_steps, within=NonNegativeReals, name="power_cool")
    model.power_use = Var(["PV", "BAT"], time_steps, within=NonNegativeReals, name="power_use")
    model.power_to_grid = Var(["PV", "BAT"], time_steps, within=NonNegativeReals, name="power_to_grid")
    model.power_to_BAT = Var(["PV", "from_grid"], time_steps, within=NonNegativeReals, name="power_to_BAT")

    # Heat to/from devices
    model.cool = Var(["HP"], time_steps, within=NonNegativeReals, name="cool")
    model.heat = Var(["HP"], time_steps, within=NonNegativeReals, name="heat")
    model.heat_to_heating = Var(["HP"], time_steps, within=NonNegativeReals, name="heat_to_heating")
    model.heat_to_dhw = Var(["HP"], time_steps, within=NonNegativeReals, name="heat_to_dhw")

    model.soc = Var(storage, time_steps, bounds=(0, 1), name="soc")
    model.ch = Var(storage, time_steps, within=NonNegativeReals, name="ch")
    model.dch = Var(storage, time_steps, within=NonNegativeReals, name="dch")

    # residual loads
    model.res_thermal = Var(time_steps, within=Reals, name="residual_thermal_demand")
    model.res_elec = Var(time_steps, within=Reals, name="residual_electricity_demand")

    # Detailed thermal zone
    model.Q_ig_rad = Var(model.time_steps, within=NonNegativeReals, name="Q_ig_rad")
    model.Q_ig_conv = Var(model.time_steps, within=NonNegativeReals, name="Q_ig_conv")
    model.T_Room_dev = Var(time_steps, initialize=0, bounds=(-10, 10), name="T_Room_dev")
    model.T_Room_dev_tot = Var(time_steps, within=NonNegativeReals, name="T_Room_dev_tot")
    model.eps_T_Room = Var(time_steps, initialize=0, bounds=(0, 10), name="eps_T_Room")

    # --- states
    model.T_Room = Var(model.time_steps, within=NonNegativeReals, name="T_Room")
    model.T_Room_dot = DerivativeVar(model.T_Room, initialize=0, wrt=model.time_steps)
    model.T_Roof = Var(model.time_steps, initialize=290, bounds=(273.15, 330))
    if has_roof:
        model.T_Roof_dot = DerivativeVar(model.T_Roof, initialize=0, wrt=model.time_steps)
    model.T_Floor = Var(model.time_steps, initialize=290, bounds=(273.15, 330))
    if has_floor:
        model.T_Floor_dot = DerivativeVar(model.T_Floor, initialize=0, wrt=model.time_steps)
    model.T_ExtWall = Var(model.time_steps, initialize=290, bounds=(273.15, 330))
    model.T_ExtWall_dot = DerivativeVar(model.T_ExtWall, initialize=0, wrt=model.time_steps)
    model.T_IntWall = Var(model.time_steps, initialize=290, bounds=(273.15, 330))
    model.T_IntWall_dot = DerivativeVar(model.T_IntWall, initialize=0, wrt=model.time_steps)
    model.T_Win = Var(model.time_steps, initialize=290, bounds=(273.15, 330))
    model.T_Win_dot = DerivativeVar(model.T_Win, initialize=0, wrt=model.time_steps)

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Add constraints
    #%% BUILDING CONSTRAINTS
    model.constraints = ConstraintList()
    #%% LOAD CONSTRAINTS (BUILDINGS)
    @model.Constraint(time_steps)
    def cap_HP_rule(m, t):
        return (m.heat["HP", t] <= devs["HP"]["cap"])

    @model.Constraint(time_steps)
    def cap_HP_rule2(m, t):
        return (m.cool["HP", t] <= devs["HP"]["cap"])

    @model.Constraint(time_steps)
    def cap_PV_rule(m, t):
        return (m.power["PV", t] <= parameters["I_0"] * devs["PV"]["area"] * devs["PV"]["eta"])

    for dev in storage:
        for t in time_steps:
           model.constraints.add(model.soc[dev, t] <= devs[dev]["cap"])


    #%% INPUT / OUTPUT CONSTRAINTS (BUILDINGS)

    # Heat Pump
    @model.Constraint(time_steps)
    def EB_HP1(m, t):
        return (m.power["HP", t] == m.power_heat["HP", t] + m.power_cool["HP", t])
    @model.Constraint(time_steps)
    def EB_HP2(m, t):
        return (m.heat["HP", t] == m.power_heat["HP", t] * devs["HP"]["COP"][t])
    @model.Constraint(time_steps)
    def EB_HP3(m, t):
        return (m.heat["HP", t] == m.heat_to_heating["HP", t] + m.heat_to_dhw["HP", t] + m.ch["TES", t] + m.ch["DHW", t] )
    @model.Constraint(time_steps)
    def EB_HP4(m, t):
        return (m.cool["HP", t] == m.power_cool["HP", t] * devs["HP"]["COP"][t])

    # PV
    @model.Constraint(time_steps)
    def EB_PV1(m, t):
        return (m.power["PV", t] == m.power_use["PV", t] + m.power_to_grid["PV", t] + m.power_to_BAT["PV", t])
    @model.Constraint(time_steps)
    def EB_PV2(m, t):
        return (m.power["PV", t] == time_series["sol_rad"][t] * devs["PV"]["area"] * devs["PV"]["eta"])
    # BAT
    @model.Constraint(time_steps)
    def EB_BAT1(m, t):
        return (m.dch["BAT", t] == m.power_use["BAT", t] + m.power_to_grid["BAT", t])

    @model.Constraint(time_steps)
    def EB_BAT2(m, t):
        return (m.ch["BAT", t] == m.power_to_BAT["PV", t] + m.power_to_BAT["from_grid", t])

    @model.Constraint(time_steps)
    def SOC_BAT(m, t):
        return (m.soc["BAT", t] >= devs["BAT"]["SOC_min"])

    @model.Constraint(time_steps)
    def Charge_BAT(m, t):
        return (m.ch["BAT", t] <= devs["BAT"]["P_ch_max"])

    @model.Constraint(time_steps)
    def Discharge_BAT(m, t):
        return (m.dch["BAT", t] <= devs["BAT"]["P_dch_max"])

    # # Heat Pump blocking times
    # blocking_hours = []
    # for x in [12, 13, 16, 17]:  # 12-13h, 13-14h, 16-17h, 17-18h
    #     if x - hour < 0:
    #         blocking_hours.append(x - hour + prediction_horizon)
    #     else:
    #         blocking_hours.append(x - hour)
    # for t in blocking_hours:
    #     Constr(power["HP"][t] == 0, name="HP_blocking_time")

    #%% ENERGY BALANCES (BUILDINGS)

    @model.Constraint(time_steps)
    def EB_Heat1(m, t):
        return (demand["heat"][t] == m.dch["TES", t] + m.heat_to_heating["HP", t])

    @model.Constraint(time_steps)
    def EB_Heat2(m, t):
        return (demand["dhw"][t] == m.dch["DHW", t] + m.heat_to_dhw["HP", t])

    @model.Constraint(time_steps)
    def EB_Cool1(m, t):
        return (demand["cool"][t] == m.cool["HP", t])

    @model.Constraint(time_steps)
    def EB_Elec1(m, t):
        return (m.power_use["PV", t] + m.power_use["BAT", t] + m.power["from_grid", t] == demand["elec"][t] + demand["e_mob"][t] + m.power["HP", t])

    @model.Constraint(time_steps)
    def EB_Elec2(m, t):
        return (m.power["to_grid", t] == m.power_to_grid["PV", t] + m.power_to_grid["BAT", t])

    @model.Constraint(model.time_steps)
    def q_ig_conv(m, t):
        return m.Q_ig_conv[t] == (((0.865 - (0.025 * (m.T_Room[t] - 273.15))) * (devs["ThZo"]["activityDegree"] * 58 * 1.8) + 35) *
                                  devs["ThZo"]["specificPeople"] * devs["ThZo"]["AZone"] * devs["ThZo"]["ratioConvectiveHeatPeople"] * time_series["schedule_human"][t] +
                                  devs["ThZo"]["AZone"] * devs["ThZo"]["internalGainsMachinesSpecific"] * time_series["schedule_dev"][
                                      t] * devs["ThZo"]["ratioConvectiveHeatMachines"] +
                                  devs["ThZo"]["AZone"] * devs["ThZo"]["lightingPowerSpecific"] * time_series["schedule_light"][
                                      t] * devs["ThZo"]["ratioConvectiveHeatLighting"]) * devs["ThZo"]["fac_IG"]

    @model.Constraint(model.time_steps)
    def q_ig_rad(m, t):
        return m.Q_ig_rad[t] == (((0.865 - (0.025 * (m.T_Room[t] - 273.15))) * (devs["ThZo"]["activityDegree"] * 58 * 1.8) + 35) *
                                 devs["ThZo"]["specificPeople"] * devs["ThZo"]["AZone"] * devs["ThZo"]["ratioConvectiveHeatPeople"] * time_series["schedule_human"][t] * (
                                             1 - devs["ThZo"]["ratioConvectiveHeatPeople"]) / devs["ThZo"]["ratioConvectiveHeatPeople"] +
                                 devs["ThZo"]["AZone"] * devs["ThZo"]["internalGainsMachinesSpecific"] * time_series["schedule_dev"][
                                     t] * devs["ThZo"]["ratioConvectiveHeatMachines"] * (
                                             1 - devs["ThZo"]["ratioConvectiveHeatMachines"]) / devs["ThZo"]["ratioConvectiveHeatMachines"] +
                                 devs["ThZo"]["AZone"] * devs["ThZo"]["lightingPowerSpecific"] * time_series["schedule_light"][
                                     t] * devs["ThZo"]["ratioConvectiveHeatLighting"] * (
                                             1 - devs["ThZo"]["ratioConvectiveHeatLighting"]) / devs["ThZo"]["ratioConvectiveHeatLighting"]) * devs["ThZo"]["fac_IG"]

    @model.Constraint(time_steps)
    def T_Room_rule(m, t):
        return m.T_Room[t] + m.T_Room_dev[t] == time_series["T_inside"][t]

    @model.Constraint(time_steps)
    def T_Room_dev_rule(m):
        return (m.T_Room_dev_tot == sum(abs(m.T_Room_dev[t]) for t in time_steps))

    # --- diff Eq:
    @model.Constraint(time_steps)
    def t_room_con(m, t):
        return m.T_Room_dot[t] == (1 / CAir) * ((m.T_Roof[t] - m.T_Room[t]) * k_Roof_Air +
                                                    (m.T_ExtWall[t] - m.T_Room[t]) * k_Ext_Air +
                                                    (m.T_IntWall[t] - m.T_Room[t]) * k_Int_Air +
                                                    (m.T_Win[t] - m.T_Room[t]) * k_Win_Air +
                                                    (m.T_Floor[t] - m.T_Room[t]) * k_Floor_Air +
                                                    m.Q_ig_conv[t] +
                                                    m.m_flow_ahu[t] *
                                                    c_spec_Air * (m.T_Ahu[t] - m.T_Room[t]))


    if has_roof:
        # set differential equation for Roof if it exits
        @model.Constraint(time_steps)
        def t_roof_con(m, t):
            return m.T_Roof_dot[t] == (1 / CRoof) * ((m.T_Room[t] - m.T_Roof[t]) * k_Air_Roof
                                                          + (m.T_ExtWall[t] - m.T_Roof[t]) * k_Ext_Roof
                                                          + (m.T_IntWall[t] - m.T_Roof[t]) * k_Int_Roof
                                                          + (m.T_preTemRoof[t] - m.T_Roof[t]) * k_Amb_Roof
                                                          + (m.T_Win[t] - m.T_Roof[t]) * k_Win_Roof
                                                          + (m.T_Floor[t] - m.T_Roof[t]) * k_Floor_Roof
                                                          + splitRoofSol * m.Q_RadSol[t] * fac_Q_rad
                                                          + splitRoofIG * m.Q_ig_rad[t])
    else:
        # set Roof temperature to default
        @model.Constraint(time_steps)
        def t_roof_con(m, t):
            return m.T_Roof[t] == 293

    if has_floor:
        # set differential equation for Floor if it exists
        @model.Constraint(time_steps)
        def t_floor_con(m, t):
            return m.T_Floor_dot[t] == (1 / CFloor) * ((m.T_Room[t] - m.T_Floor[t]) * k_Air_Floor
                                                            + (m.T_ExtWall[t] - m.T_Floor[t]) * k_Ext_Floor
                                                            + (m.T_Win[t] - m.T_Floor[t]) * k_Win_Floor
                                                            + (m.T_Roof[t] - m.T_Floor[t]) * k_Roof_Floor
                                                            + (m.T_IntWall[t] - m.T_Floor[t]) * k_Int_Floor
                                                            + (m.T_preTemFloor[t] - m.T_Floor[
                        t]) * k_Soil_Floor
                                                            + splitFloorSol * m.Q_RadSol[t] * fac_Q_rad
                                                            + splitFloorIG * m.Q_ig_rad[t])
    else:
        # set Floor temperature to default
        @model.Constraint(time_steps)
        def t_floor_con(m, t):
            return m.T_Floor[t] == 293

    @model.Constraint(time_steps)
    def t_exWall_con(m, t):
        return m.T_ExtWall_dot[t] == (1 / CExt) * ((m.T_Room[t] - m.T_ExtWall[t]) * k_Air_Ext
                                                   + (m.T_Roof[t] - m.T_ExtWall[t]) * k_Roof_Ext
                                                   + (m.T_IntWall[t] - m.T_ExtWall[t]) * k_Int_Ext
                                                   + (m.T_WallInit[t] - m.T_ExtWall[t]) * k_Amb_Ext
                                                   + (m.T_Win[t] - m.T_ExtWall[t]) * k_Win_Ext
                                                   + (m.T_Floor[t] - m.T_ExtWall[t]) * k_Floor_Ext
                                                   + splitExtSol * m.Q_RadSol[t] * fac_Q_rad
                                                   + splitExtIG * m.Q_ig_rad[t])

    @model.Constraint(time_steps)
    def t_inWall_con(m, t):
        return m.T_IntWall_dot[t] == (1 / CInt) * ((m.T_Room[t] - m.T_IntWall[t]) * k_Air_Int
                                                        + (m.T_ExtWall[t] - m.T_IntWall[t]) * k_Ext_Int
                                                        + (m.T_Roof[t] - m.T_IntWall[t]) * k_Roof_Int
                                                        + (m.T_Win[t] - m.T_IntWall[t]) * k_Win_Int
                                                        + (m.T_Floor[t] - m.T_IntWall[t]) * k_Floor_Int
                                                        + splitIntSol * m.Q_RadSol[t] * fac_Q_rad
                                                        + splitIntIG * m.Q_ig_rad[t])

    @model.Constraint(time_steps)
    def t_Win_con(m, t):
        return m.T_Win_dot[t] == (1 / CWin) * ((m.T_Room[t] - m.T_Win[t]) * k_Win_Air
                                               + (m.T_Roof[t] - m.T_Win[t]) * k_Win_Roof
                                               + (m.T_ExtWall[t] - m.T_Win[t]) * k_Win_Ext
                                               + (m.T_IntWall[t] - m.T_Win[t]) * k_Win_Int
                                               + (m.T_Floor[t] - m.T_Win[t]) * k_Win_Floor
                                               + (m.T_WinInit[t] - m.T_Win[t]) * k_Amb_Win
                                               + splitWinSol * m.Q_RadSol[t] * fac_Q_rad
                                               + splitWinIG * m.Q_ig_rad[t])

    # @model.Constraint(time_steps)
    # def eco_ub(m, t):
    #     return m.T_Room[t] - m.eps_T_Room[t] <= m.T_Room_UB[t]
    #
    # @model.Constraint(time_steps)
    # def eco_lb(m, t):
    #     return m.T_Room[t] + m.eps_T_Room[t] >= m.T_Room_LB[t]



    #%% BUILDING THERMAL STORAGES AND BATTERY

    for device in storage:
        model.constraints.add(model.soc[device, 0] * devs[device]["cap"] == initials["SOC_init_"+device]/100 * devs[device]["cap"] * (1 - devs[device]["sto_loss"] * time_step) + devs[device]["eta_ch"] * model.ch[device, 0] * time_step - 1/devs[device]["eta_dch"] * model.dch[device, 0] * time_step)
        # Energy balance: soc(t) = soc(t-1) + heat_from/to_storage
        for t in np.arange(1, len(time_steps)):
            model.constraints.add(model.soc[device, t] * devs[device]["cap"] == model.soc[device, t - 1] * devs[device]["cap"] * (1 - devs[device]["sto_loss"] * time_step) + devs[device]["eta_ch"] * model.ch[device, t] * time_step - 1/devs[device]["eta_dch"] * model.dch[device, t] * time_step)

    #%% RESIDUAL THERMAL LOAD
    @model.Constraint(time_steps)
    def EB_Res_th(m, t):
        return (m.res_thermal[t] == (m.heat["HP", t] - m.power["HP", t]) - m.cool["HP", t])

    #%% RESIDUAL ELECTRICITY LOAD
    @model.Constraint(time_steps)
    def EB_Res_el(m, t):
        return (m.res_elec[t] == demand["elec"][t] + demand["e_mob"][t] + m.power["HP", t])

    #%% BALANCING UNIT CONSTRAINTS
    #%% GRID CONSTRAINTS
    for device in ["from_grid", "to_grid"]:
        for t in time_steps:
            model.constraints.add(model.power[device, t] <= model.grid_limit_el)

    @model.Constraint()
    def EB_Elec3(m):
        return (m.from_grid_total == sum(m.power["from_grid", t] + m.power_to_BAT["from_grid", t] for t in time_steps))

    @model.Constraint()
    def EB_Elec4(m):
        return (m.to_grid_total == sum(m.power["to_grid", t] for t in time_steps))

    #%% OBJECTIVE
    # Set objective function
    @model.Objective(sense=minimize)
    def objective_rule(m):
        return (m.from_grid_total * time_step * parameters["price_el"] - m.to_grid_total * time_step * parameters["feed_in_revenue_el"])


    #%% Set model parameters and execute calculation
    print("Precalculation and model set up done in %f seconds." % (time.time() - start_time))

    # Set solver parameters
    #solver = SolverFactory("gurobi", solver_io="python")
    solver = SolverFactory("glpk")

    try:
        start_time = time.time()
        solver.solve(model, report_timing=True, tee=True)
        # Get solving time
        end_time = time.time() - start_time
        print("Optimization done. (%f seconds.)" % (end_time))

    except SolverStatus.error:
        print("Solver Status: ", SolverStatus)

    # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Save results

    # if run == 0:
    #     initial_json = {}
    #     ### DATA FOR RESULTS AND FURTHER PROCESSING
    #     initial_json["el_costs"] = []
    #     for k in ["TES", "DHW", "BAT"]:
    #         initial_json["SOC_" + k] = []
    #         initial_json["Charge_" + k] = []
    #         initial_json["Discharge_" + k] = []
    #
    #     ### DATA FOR PLOTS
    #     initial_json["Residual Electricity demand"] = []
    #     initial_json["Residual Thermal demand"] = []
    #     for k in ["BAT", "PV"]:
    #         initial_json["Power (use)_" + k] = []
    #         initial_json["Power (togrid)_" + k] = []
    #     for k in ["PV", "from_grid"]:
    #         initial_json["Power (toBAT)_" + k] = []
    #     for k in ["from_grid", "to_grid"]:
    #         initial_json[k] = []
    #     initial_json["Power_cool_HP"] = []
    #     initial_json["Power_heat_HP"] = []
    #     initial_json["Heat HP to TES_dem"] = []
    #     initial_json["Heat HP to DHW_dem"] = []
    #     initial_json["to_grid"] = []
    #     initial_json["from_grid"] = []
    #     for k in ["el_dem", "heat_dem"]:
    #         initial_json[k] = 0
    #
    #     write_json("Results", "results.json", initial_json)
    #
    # optim_results = load_json("Results", "results.json")
    #
    # optim_results["el_costs"].append(
    #     value(model.power["from_grid", 0]) * parameters["price_el"] - value(model.power["to_grid", 0]) * parameters["feed_in_revenue_el"])
    # optim_results["Residual Electricity demand"].append(value(model.res_elec[0]))
    # optim_results["Residual Thermal demand"].append(value(model.res_thermal[0]))
    #
    # for k in ["TES", "DHW", "BAT"]:
    #     optim_results["Charge_" + k].append(value(model.ch[k, 0]))
    #     optim_results["Discharge_" + k].append(value(model.dch[k, 0]))
    #
    # for k in ["BAT", "PV"]:
    #     optim_results["Power (use)" + "_" + k].append(value(model.power_use[k, 0]))
    #     optim_results["Power (togrid)" + "_" + k].append(value(model.power_to_grid[k, 0]))
    #
    # for k in ["PV", "from_grid"]:
    #     optim_results["Power (toBAT)_" + k].append(value(model.power_to_BAT[k, 0]))
    #
    # for k in ["HP"]:
    #     optim_results["Power_cool_" + k].append(value(model.power_cool[k, 0]))
    #     optim_results["Power_heat_" + k].append(value(model.power_heat[k, 0]))
    #     optim_results["Heat HP to TES_dem"].append(value(model.heat_to_heating[k, 0]))
    #     optim_results["Heat HP to DHW_dem"].append(value(model.heat_to_dhw[k, 0]))
    #
    # optim_results["to_grid"].append(value(model.power["to_grid", 0]))
    # optim_results["from_grid"].append(value(model.power["from_grid", 0]) + value(model.power_to_BAT["from_grid", 0]))
    #
    # optim_results["el_dem"] += demand["elec"][0] + demand["e_mob"][0]
    # optim_results["heat_dem"] += demand["dhw"][0] + demand["heat"][0]



    # Save optimization results to pass on to the next simulation
    optim_results = {}
    optim_results["PV_Pow"] = []
    optim_results["PV_Pow_Use"] = []
    optim_results["PV_Pow_FeedIn"] = []
    optim_results["PV_Pow_Ch"] =[]
    optim_results["SOC_BAT"] = []
    optim_results["Q_ig_rad"] = []
    optim_results["Q_ig_conv"] = []
    optim_results["T_Room"] = []

    for t in range(int(prediction_horizon / time_step)):
        optim_results["PV_Pow"].append(value(model.power["PV", t]))
        optim_results["PV_Pow_Use"].append(value(model.power_use["PV", t]))
        optim_results["PV_Pow_FeedIn"].append(value(model.power_to_grid["PV", t]))
        optim_results["PV_Pow_Ch"].append(value(model.power_to_BAT["PV", t]))
        optim_results["SOC_BAT"].append(value(model.soc["BAT", t]))
        optim_results["Q_ig_rad"].append(value(model.Q_ig_rad[t]))
        optim_results["Q_ig_conv"].append(value(model.Q_ig_conv[t]))
        optim_results["T_Room"].append(value(model.T_Room[t]))

    control_parameters = {}
    control_variables = {}

    control_parameters["IdentifierPV"] = devs["PV"]["Identifier"]
    control_parameters["IdentifierBAT"] = devs["BAT"]["Identifier"]
    control_parameters["n_mod"] = devs["PV"]["n_mod"]
    control_parameters["nBat"] = devs["BAT"]["nBat"]

    control_variables["T_air"] = []
    control_variables["H_GloHor"] = []

    control_variables["BAT_Pow_Use"] = []
    control_variables["BAT_Pow_FeedIn"] = []
    control_variables["BAT_Pow_Ch"] = []

    control_variables["PV_Distr_Use"] = []
    control_variables["PV_Distr_FeedIn"] = []
    control_variables["PV_Distr_ChBat"] = []
    control_variables["EVDemand"] = []
    control_variables["ElecDemand"] = []

    for t in range(int((control_horizon / time_step) + 1)):
        control_variables["T_air"].append(time_series["T_air"][t]+273.15)
        control_variables["H_GloHor"].append(time_series["sol_rad"][t])
        control_variables["BAT_Pow_Use"].append(value(model.power_use["BAT", t]))
        control_variables["BAT_Pow_FeedIn"].append(value(model.power_to_grid["BAT", t]))
        control_variables["BAT_Pow_Ch"].append(value(model.ch["BAT", t]))
        control_variables["EVDemand"].append(demand["e_mob"][t])
        control_variables["ElecDemand"].append(demand["elec"][t])

        if value(model.power["PV", t]) > 0.0:
            control_variables["PV_Distr_Use"].append(value(model.power_use["PV", t])/(value(model.power["PV", t])))
            control_variables["PV_Distr_FeedIn"].append(value(model.power_to_grid["PV", t])/(value(model.power["PV", t])))
            control_variables["PV_Distr_ChBat"].append(value(model.power_to_BAT["PV", t])/(value(model.power["PV", t])))
        else:
            control_variables["PV_Distr_Use"].append(0.0)
            control_variables["PV_Distr_FeedIn"].append(0.0)
            control_variables["PV_Distr_ChBat"].append(0.0)

    return optim_results, control_parameters, control_variables



def parse_modelica_record(path):
    constants = {}
    with open(path) as f:
         for i,line in enumerate(f):
             try:
                line=line.translate({ord(c): None for c in string.whitespace})[:-1]
                line = line.replace("{", "[")
                line = line.replace("}", "]")
                name, value = line.split("=")
                if value=='true':                   # Evaluate Booleans
                    constants[name] = True
                elif value == 'false':
                    constants[name] = False
                elif value.startswith('['):
                    value=ast.literal_eval(value)   # Evaluate Lists
                    if len(value)==1:
                        constants[name] = value[0]
                    else:
                        constants[name] = value
                else:
                    constants[name] = float(value)  # Evaluate Floats
             except:
                 continue
         f.close()

    return constants

def get_par():
    par = {
        "T_start" : 293.15,
        "VAir" : 6700.0,
        "AZone" : 1675.0,
        "hRad" : 5,
        "lat" : 0.87266462599716,
        "nOrientations" : 5,
        "AWin" : [108.5, 19.0, 108.5, 19.0, 0],
        "ATransparent" : [108.5, 19.0, 108.5, 19.0, 0],
        "hConWin" : 2.7,
        "RWin" : 0.017727777777,
        "gWin" : 0.78,
        "UWin" : 2.1,
        "ratioWinConRad" : 0.09,
        "AExt" : [244.12, 416.33, 244.12, 416.33, 208.16],
        "hConExt" : 2.19,
        "nExt" : 1,
        "RExt" : 1.4142107968e-05,
        "RExtRem" : 0.000380773816236,
        "CExt" : 492976267.489,
        "AInt" : 5862.5,
        "hConInt" : 2.27,
        "nInt" : 1,
        "RInt" : 1.13047235829e-05,
        "CInt" : 1402628013.98,
        "AFloor" : 0,
        "hConFloor" : 0,
        "nFloor" : 1,
        "RFloor" : 0.001,
        "RFloorRem" : 0.001,
        "CFloor" : 0.001,
        "ARoof" : 0,
        "hConRoof" : 0,
        "nRoof" : 1,
        "RRoof" : 0.001,
        "RRoofRem" : 0.001,
        "CRoof" : 0.001,
        "nOrientationsRoof" : 1,
        "tiltRoof" : 0,
        "aziRoof" : 0,
        "wfRoof" : 1,
        "aRoof" : 0.7,
        "aExt" : 0.7,
        "TSoil" : 283.15,
        "hConWallOut" : 20.0,
        "hRadWall" : 5,
        "hConWinOut" : 20.0,
        "hConRoofOut" : 20,
        "hRadRoof" : 5,
        "tiltExtWalls" : [1.5707963267949, 1.5707963267949, 1.5707963267949, 1.5707963267949, 0],
        "aziExtWalls" : [0, 1.5707963267949, 3.1415926535898, 4.7123889803847, 0],
        "wfWall" : [0.2, 0.2, 0.2, 0.2, 0.1],
        "wfWin" : [0.25, 0.25, 0.25, 0.25, 0],
        "wfGro" : 0.1,
        "specificPeople" : 1 / 14,
        "activityDegree" : 1.2,
        "fixedHeatFlowRatePersons" : 70,
        "ratioConvectiveHeatPeople" : 0.5,
        "internalGainsMoistureNoPeople" : 0.5,
        "internalGainsMachinesSpecific" : 7.0,
        "ratioConvectiveHeatMachines" : 0.6,
        "lightingPowerSpecific" : 12.5,
        "ratioConvectiveHeatLighting" : 0.6,
        "useConstantACHrate" : False,
        "baseACH" : 0.2,
        "maxUserACH" : 1,
        "maxOverheatingACH" : [3.0, 2.0],
        "maxSummerACH" : [1.0, 273.15 + 10, 273.15 + 17],
        "winterReduction" : [0.2, 273.15, 273.15 + 10],
        "withAHU" : True,
        "minAHU" : 0,
        "maxAHU" : 12,
        "maxIrr" : [100, 100, 100, 100, 0],
        "shadingFactor" : [0.7, 0.7, 0.7, 0.7, 0],
        "hHeat" : 167500,
        "lHeat" : 0,
        "KRHeat" : 1000,
        "TNHeat" : 1,
        "HeaterOn" : True,
        "hCool" : 0,
        "lCool" : -1,
        "KRCool" : 1000,
        "TNCool" : 1,
        "CoolerOn" : False,
        "TThresholdHeater" : 273.15 + 15,
        "TThresholdCooler" : 273.15 + 22,
        "withIdealThresholds" : False
    }
    return par