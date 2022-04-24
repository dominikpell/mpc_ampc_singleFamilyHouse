# -*- coding: utf-8 -*-
"""

OPERATION OPTIMIZATION HASSEL

Developed by:  E.ON Energy Research Center, 
                Institute for Energy Efficient Buildings and Indoor Climate, 
                RWTH Aachen University, 
                Germany

Developed in:  2021

"""


# import sys
# print(sys.path)
# from optimization.plot_tool import plot_results
# import matplotlib.pyplot as plt
import numpy as np
from flask import make_response
import gurobipy as gp
import time
import pdb
import json
import os


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
def run_optim(params, run, hour, soc_data):

    # Extract parameters
    prediction_horizon = params["prediction_horizon"]
    time_step_length = params["time_step_length"]
    devs = params["devs"]
    demand = params["demand"]
    parameters = params["parameters"]

    # Initialize time steps
    time_steps = range(int(prediction_horizon / time_step_length))

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    start_time = time.time()

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Setting up the model

    # Create a new model
    model = gp.Model("operation_optim")

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Create new variables

    # Eletrical power to/from devices
    # Grid maximum transmission power
    grid_limit_el = model.addVar(vtype="C", name="grid_limit_el")

    # Total energy amounts imported from grid
    from_grid_total = model.addVar(vtype="C", name="from_grid_total")
    # Total power to grid
    to_grid_total = model.addVar(vtype="C", name="to_grid_total")

    #%% BUILDING VARIABLES

    # Eletrical power to/from devices
    power = {}
    power_heat = {}
    power_cool = {}
    for device in ["HP"]:
        power[device] = {}
        power_heat[device] = {}
        power_cool[device] = {}
        for t in time_steps:
            power[device][t] = model.addVar(vtype="C", name="power_" + device + "_t" + str(t))
            power_heat[device][t] = model.addVar(vtype="C", name="power_heat" + device + "_t" + str(t))
            power_cool[device][t] = model.addVar(vtype="C", name="power_cool" + device + "_t" + str(t))

    for device in ["PV", "from_grid", "to_grid"]:
        power[device] = {}
        for t in time_steps:
            power[device][t] = model.addVar(vtype="C", name="power_" + device + "_t" + str(t))

    power_use = {}
    power_to_grid = {}
    for device in ["PV", "BAT"]:
        power_use[device] = {}
        power_to_grid[device] = {}
        for t in time_steps:
            power_use[device][t] = model.addVar(vtype="C", name="power_use_" + device + "_t" + str(t))
            power_to_grid[device][t] = model.addVar(vtype="C", name="power_to_grid_" + device + "_t" + str(t))


    power_to_BAT = {}
    for device in ["PV", "from_grid"]:
        power_to_BAT[device] = {}
        for t in time_steps:
            power_to_BAT[device][t] = model.addVar(vtype="C", name="power_to_BAT_" + device + "_t" + str(t))

    # Heat to/from devices
    cool = {}
    heat_total = {}
    heat_to_heating = {}
    heat_to_dhw = {}
    for device in ["HP"]:
        cool[device] = {}
        heat_total[device] = {}
        heat_to_heating[device] = {}
        heat_to_dhw[device] = {}
        for t in time_steps:
            cool[device][t] = model.addVar(vtype="C", name="cool_" + device + "_t" + str(t))
            heat_total[device][t] = model.addVar(vtype="C", name="heat_" + device + "_t" + str(t))
            heat_to_heating[device][t] = model.addVar(vtype="C", name="heat_to_heating" + device + "_t" + str(t))
            heat_to_dhw[device][t] = model.addVar(vtype="C", name="heat_to_dhw" + device + "_t" + str(t))

    # Storage variables (State of charge)
    soc = {}
    ch = {}
    dch = {}

    for device in ["TES", "DHW", "BAT"]:
        soc[device] = {}
        ch[device] = {}
        dch[device] = {}
        for t in time_steps:
            soc[device][t] = model.addVar(vtype="C", name="soc_" + device + "_t" + str(t))
            ch[device][t] = model.addVar(vtype="C", name="ch_" + device + "_t" + str(t))
            dch[device][t] = model.addVar(vtype="C", name="dch_" + device + "_t" + str(t))

    # Node residual loads
    res_thermal = {}
    res_elec = {}
    for t in time_steps:
        res_thermal[t] = model.addVar(vtype="C", lb=-gp.GRB.INFINITY, name="residual_thermal_demand" + "_t" + str(t))
        res_elec[t] = model.addVar(vtype="C", lb=-gp.GRB.INFINITY, name="residual_electricity_demand" + "_t" + str(t))

    # Total residual network load
    residual = {}
    for k in ["thermal", "electricity"]:
        residual[k] = {}
        for t in time_steps:
            residual[k][t] = model.addVar(vtype="C", lb=-gp.GRB.INFINITY, name="residual_" + k + "_t" + str(t))

    # Objective functions
    obj = model.addVar(vtype="C", lb=-gp.GRB.INFINITY, name="obj")

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Define objective function
    model.update()

    # Electricity costs
    model.setObjective(obj, gp.GRB.MINIMIZE)

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Add constraints

    #%% BUILDING CONSTRAINTS

    #%% LOAD CONSTRAINTS (BUILDINGS)
    for t in time_steps:
        for device in ["HP"]:
            model.addConstr(heat_total[device][t] <= devs[device]["cap"])
            model.addConstr(cool[device][t] <= devs[device]["cap"])

        for device in ["PV"]:
            model.addConstr(power[device][t] <= devs[device]["cap"])

        for device in ["TES", "DHW"]:
            model.addConstr(soc[device][t] <= devs[device]["cap"])

        for device in ["BAT"]:
            model.addConstr(soc[device][t] <= devs[device]["cap"])

    #%% INPUT / OUTPUT CONSTRAINTS (BUILDINGS)

    for t in time_steps:

        # Heat Pump
        model.addConstr(power["HP"][t] == power_heat["HP"][t] + power_cool["HP"][t])
        model.addConstr(heat_total["HP"][t] == power_heat["HP"][t] * devs["HP"]["COP"][t])
        model.addConstr(heat_total["HP"][t] == heat_to_heating["HP"][t] + heat_to_dhw["HP"][t] + ch["TES"][t] + ch["DHW"][t])
        model.addConstr(cool["HP"][t] == power_cool["HP"][t] * devs["HP"]["COP"][t])

        # PV
        model.addConstr(power["PV"][t] == power_use["PV"][t] + power_to_grid["PV"][t] + power_to_BAT["PV"][t])
        model.addConstr(power["PV"][t] == parameters["sol_rad"][t] * devs["PV"]["max_area"] * devs["PV"]["eta"] / 1000)

        # BAT
        model.addConstr(dch["BAT"][t] == power_use["BAT"][t] + power_to_grid["BAT"][t])
        model.addConstr(ch["BAT"][t] == power_to_BAT["PV"][t] + power_to_BAT["from_grid"][t])

    # # Heat Pump blocking times
    # blocking_hours = []
    # for x in [12, 13, 16, 17]:  # 12-13h, 13-14h, 16-17h, 17-18h
    #     if x - hour < 0:
    #         blocking_hours.append(x - hour + prediction_horizon)
    #     else:
    #         blocking_hours.append(x - hour)
    # for t in blocking_hours:
    #     model.addConstr(power["HP"][t] == 0, name="HP_blocking_time")

    #%% ENERGY BALANCES (BUILDINGS)

    for t in time_steps:
        # Heat balance
        model.addConstr(demand["heat"][t] == dch["TES"][t] + heat_to_heating["HP"][t])
        model.addConstr(demand["dhw"][t] == dch["DHW"][t] + heat_to_dhw["HP"][t])

        # Cooling balance
        model.addConstr(demand["cool"][t] == cool["HP"][t])

        # Electricity demands
        model.addConstr(power_use["PV"][t] + power_use["BAT"][t] + power["from_grid"][t] == demand["elec"][t] + demand["e_mob"][t] + power["HP"][t])
        model.addConstr(power["to_grid"][t] == power_to_grid["PV"][t] + power_to_grid["BAT"][t])

    #%% BUILDING THERMAL STORAGES AND BATTERY
    for device in ["TES", "DHW", "BAT"]:
        # Cyclic condition
        # SOC at 0:00 is equal to last simulation SOC, soc[device][len(time_steps)-1] is also SOC at 0:00
        # model.addConstr(soc[device][len(time_steps)-1] == soc_data["0"]["TES"])# * devs[device]["cap"])
        model.addConstr(soc[device][0] == soc_data[device] * (1 - devs[device]["sto_loss"]) + devs[device]["eta_ch"] * ch[device][0] - 1 / devs[device]["eta_dch"] * dch[device][0])

        for t in np.arange(1, len(time_steps)):
            # Energy balance: soc(t) = soc(t-1) + heat_from/to_storage
            model.addConstr(soc[device][t] == soc[device][t - 1] * (1 - devs[device]["sto_loss"]) + devs[device]["eta_ch"] * ch[device][t] - 1 / devs[device]["eta_dch"] * dch[device][t])

    #%% RESIDUAL THERMAL LOADS (BUILDINGS)

    for t in time_steps:
        model.addConstr(res_thermal[t] == (heat_total["HP"][t] - power["HP"][t]) - cool["HP"][t])

    #%% RESIDUAL ELECTRICITY LOADS (BUILDINGS)

    for t in time_steps:
        model.addConstr(res_elec[t] == demand["elec"][t] + demand["e_mob"][t] + power["HP"][t])

    # Residual loads
    for t in time_steps:
        model.addConstr(residual["electricity"][t] == sum(res_elec[t] for t in time_steps))

    #%% BALANCING UNIT CONSTRAINTS

    #%% GRID CONSTRAINTS

    for t in time_steps:
        # Limitation of power from and to grid
        for device in ["from_grid", "to_grid"]:
            model.addConstr(power[device][t] <= grid_limit_el)

        # Electricity balance
        model.addConstr(from_grid_total == sum(power["from_grid"][t] + power_to_BAT["from_grid"][t] for t in time_steps))
        model.addConstr(to_grid_total == sum(power["to_grid"][t] for t in time_steps))

    #%% OBJECTIVE

    # Electricity costs
    model.addConstr(obj == from_grid_total * parameters["price_el"] - to_grid_total * parameters["feed_in_revenue_el"], "sum_up_OPEX")
    # model.addConstr(obj == from_grid_total * parameters["price_el"] - to_grid_total * parameters["feed_in_rev_el"], "sum_up_OPEX")

    #%% Set model parameters and execute calculation
    print("Precalculation and model set up done in %f seconds." % (time.time() - start_time))

    # Set solver parameters
    model.params.MIPGap = 0.01  # ---,         gap for branch-and-bound algorithm

    # Execute calculation
    start_time = time.time()

    # pdb.set_trace()

    model.optimize()

    print("Optimization done. (%f seconds.)" % (time.time() - start_time))

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Check and save results

    optim_results = {}

    # dir_results = "optimization_results"
    # if not os.path.exists(dir_results):
    #    os.makedirs(dir_results)

    # Check if optimal solution was found
    if model.Status in (3, 4) or model.SolCount == 0:  # "INFEASIBLE" or "INF_OR_UNBD"
        print("Optimization " + str(hour) + " was INFEASIBLE or INF_OR_UNBD")
        model.write("model.lp")

    #        model.computeIIS()

    #       model.write(dir_results + "\\" + "model.ilp")
    #      print('Optimization result: No feasible solution found. Check ilp-File for more information.')

    else:

        # Write Gurobi files
        #         model.write("model_11.lp")
        #        model.write(dir_results + "\model.prm")
        #        model.write(dir_results + "\model.sol")

        # Load time serieses from model.sol file
        #        file_name = os.path.join(dir_results, "model.sol")
        #        optim_results = load_time_series.get_time_series(file_name, time_steps)

        print("Optimization was successfull. Objective function is %f" % obj.X)

        if run == 0:
            initial_json = {}
            ### DATA FOR RESULTS AND FURTHER PROCESSING
            initial_json["el_costs"] = []
            for k in ["TES", "DHW", "BAT"]:
                initial_json["SOC_" + k] = []
                initial_json["Charge_" + k] = []
                initial_json["Discharge_" + k] = []

            ### DATA FOR PLOTS
            initial_json["Residual Electricity demand"] = []
            initial_json["Residual Thermal demand"] = []
            for k in ["BAT", "PV"]:
                initial_json["Power (use)_" + k] = []
                initial_json["Power (togrid)_" + k] = []
            for k in ["PV", "from_grid"]:
                initial_json["Power (toBAT)_" + k] = []
            for k in ["from_grid", "to_grid"]:
                initial_json[k] = []
            initial_json["Power_cool_HP"] = []
            initial_json["Power_heat_HP"] = []
            initial_json["Heat HP to TES_dem"] = []
            initial_json["Heat HP to DHW_dem"] = []
            initial_json["to_grid"] = []
            initial_json["from_grid"] = []
            for k in [
                "el_dem",
                "heat_dem",
            ]:
                initial_json[k] = 0

            write_json("Results", "results.json", initial_json)


        optim_results = load_json("Results", "results.json")

        optim_results["el_costs"].append(power["from_grid"][0].X * parameters["price_el"] - power["to_grid"][0].X * parameters["feed_in_revenue_el"])
        optim_results["Residual Electricity demand"].append(res_elec[0].X)
        optim_results["Residual Thermal demand"].append(res_thermal[0].X)

        for k in ["TES", "DHW", "BAT"]:
            optim_results["SOC_" + k].append(soc[k][0].X)
            optim_results["Charge_" + k].append(ch[k][0].X)
            optim_results["Discharge_" + k].append(dch[k][0].X)

        for k in ["BAT", "PV"]:
            optim_results["Power (use)" + "_" + k].append(power_use[k][0].X)
            optim_results["Power (togrid)" + "_" + k].append(power_to_grid[k][0].X)

        for k in ["PV", "from_grid"]:
            optim_results["Power (toBAT)_" + k].append(power_to_BAT[k][0].X)

        for k in ["HP"]:
            optim_results["Power_cool_"+k].append(power_cool[k][0].X)
            optim_results["Power_heat_"+k].append(power_heat[k][0].X)
            optim_results["Heat HP to TES_dem"].append(heat_to_heating[k][0].X)
            optim_results["Heat HP to DHW_dem"].append(heat_to_dhw[k][0].X)

        optim_results["to_grid"].append(power["to_grid"][0].X)
        optim_results["from_grid"].append(power["from_grid"][0].X + power_to_BAT["from_grid"][0].X)

        optim_results["el_dem"] += demand["elec"][0] + demand["e_mob"][0]
        optim_results["heat_dem"] += demand["dhw"][0] + demand["heat"][0]

        write_json("Results", "results.json", optim_results)

    return optim_results
