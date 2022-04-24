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
from ortools.linear_solver import pywraplp
# import gurobipy as gp
import time
# import pdb
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

    # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    start_time = time.time()

    # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Setting up the model

    # Create solver, following Solvers available in OR Tools:
    # - CLP_LINEAR_PROGRAMMING or CLP
    # - CBC_MIXED_INTEGER_PROGRAMMING or CBC
    # - GLOP_LINEAR_PROGRAMMING or GLOP
    # - BOP_INTEGER_PROGRAMMING or BOP
    # - SAT_INTEGER_PROGRAMMING or SAT or CP_SAT
    # - SCIP_MIXED_INTEGER_PROGRAMMING or SCIP
    # - GUROBI_LINEAR_PROGRAMMING or GUROBI_LP
    # - GUROBI_MIXED_INTEGER_PROGRAMMING or GUROBI or GUROBI_MIP
    # - CPLEX_LINEAR_PROGRAMMING or CPLEX_LP
    # - CPLEX_MIXED_INTEGER_PROGRAMMING or CPLEX or CPLEX_MIP
    # - XPRESS_LINEAR_PROGRAMMING or XPRESS_LP
    # - XPRESS_MIXED_INTEGER_PROGRAMMING or XPRESS or XPRESS_MIP
    # - GLPK_LINEAR_PROGRAMMING or GLPK_LP
    # - GLPK_MIXED_INTEGER_PROGRAMMING or GLPK or GLPK_MIP

    solver = "CLP"
    model = pywraplp.Solver.CreateSolver(solver)
    # solver.Parameter.num_search_workers = 8 #soll den Solver schneller machen, klappt aber aus irgendeinem Grund nicht

    # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Create new variables

    # Eletrical power to/from devices
    # Grid maximum transmission power
    grid_limit_el = model.NumVar(0, model.infinity(), name="grid_limit_el")

    # Total energy amounts imported from grid
    from_grid_total = model.NumVar(0, model.infinity(), name="from_grid_total")
    # Total power to grid
    to_grid_total = model.NumVar(0, model.infinity(), name="to_grid_total")

    # %% BUILDING VARIABLES

    # Eletrical power to/from devices
    power = {}
    power_heat = {}
    power_cool = {}
    for device in ["HP"]:
        power[device] = {}
        power_heat[device] = {}
        power_cool[device] = {}
        for t in time_steps:
            power[device][t] = model.NumVar(0, model.infinity(), name="power_" + device + "_t" + str(t))
            power_heat[device][t] = model.NumVar(0, model.infinity(), name="power_heat" + device + "_t" + str(t))
            power_cool[device][t] = model.NumVar(0, model.infinity(), name="power_cool" + device + "_t" + str(t))

    for device in ["PV", "from_grid", "to_grid"]:
        power[device] = {}
        for t in time_steps:
            power[device][t] = model.NumVar(0, model.infinity(), name="power_" + device + "_t" + str(t))

    power_use = {}
    power_to_grid = {}
    for device in ["PV", "BAT"]:
        power_use[device] = {}
        power_to_grid[device] = {}
        for t in time_steps:
            power_use[device][t] = model.NumVar(0, model.infinity(), name="power_use_" + device + "_t" + str(t))
            power_to_grid[device][t] = model.NumVar(0, model.infinity(), name="power_to_grid_" + device + "_t" + str(t))

    power_to_BAT = {}
    for device in ["PV", "from_grid"]:
        power_to_BAT[device] = {}
        for t in time_steps:
            power_to_BAT[device][t] = model.NumVar(0, model.infinity(), name="power_to_BAT_" + device + "_t" + str(t))

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
            cool[device][t] = model.NumVar(0, model.infinity(), name="cool_" + device + "_t" + str(t))
            heat_total[device][t] = model.NumVar(0, model.infinity(), name="heat_" + device + "_t" + str(t))
            heat_to_heating[device][t] = model.NumVar(0, model.infinity(), name="heat_to_heating" + device + "_t" + str(t))
            heat_to_dhw[device][t] = model.NumVar(0, model.infinity(), name="heat_to_dhw" + device + "_t" + str(t))

    # Storage variables (State of charge)
    soc = {}
    ch = {}
    dch = {}

    for device in ["TES", "DHW", "BAT"]:
        soc[device] = {}
        ch[device] = {}
        dch[device] = {}
        for t in time_steps:
            soc[device][t] = model.NumVar(0, model.infinity(), name="soc_" + device + "_t" + str(t))
            ch[device][t] = model.NumVar(0, model.infinity(), name="ch_" + device + "_t" + str(t))
            dch[device][t] = model.NumVar(0, model.infinity(), name="dch_" + device + "_t" + str(t))

    # Node residual loads
    res_thermal = {}
    res_elec = {}
    for t in time_steps:
        res_thermal[t] = model.NumVar(-model.infinity(), model.infinity(), name="residual_thermal_demand" + "_t" + str(t))
        res_elec[t] = model.NumVar(-model.infinity(), model.infinity(), name="residual_electricity_demand" + "_t" + str(t))

    # Total residual network load
    residual = {}
    for k in ["thermal", "electricity"]:
        residual[k] = {}
        for t in time_steps:
            residual[k][t] = model.NumVar(-model.infinity(), model.infinity(), name="residual_" + k + "_t" + str(t))

    # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Define objective function
    obj = model.NumVar(-model.infinity(), model.infinity(), name="obj")
    # Assign objective function
    model.Minimize(obj)

    # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Add constraints

    # %% BUILDING CONSTRAINTS

    # %% LOAD CONSTRAINTS (BUILDINGS)
    for t in time_steps:
        for device in ["HP"]:
            model.Add(heat_total[device][t] <= devs[device]["cap"])
            model.Add(cool[device][t] <= devs[device]["cap"])

        for device in ["PV"]:
            model.Add(power[device][t] <= devs[device]["cap"])

        for device in ["TES", "DHW"]:
            model.Add(soc[device][t] <= devs[device]["cap"])

        for device in ["BAT"]:
            model.Add(soc[device][t] <= devs[device]["cap"])

    # %% INPUT / OUTPUT CONSTRAINTS (BUILDINGS)

    for t in time_steps:
        # Heat Pump
        model.Add(power["HP"][t] == power_heat["HP"][t] + power_cool["HP"][t])
        model.Add(heat_total["HP"][t] == power_heat["HP"][t] * devs["HP"]["COP"][t])
        model.Add(
            heat_total["HP"][t] == heat_to_heating["HP"][t] + heat_to_dhw["HP"][t] + ch["TES"][t] + ch["DHW"][t])
        model.Add(cool["HP"][t] == power_cool["HP"][t] * devs["HP"]["COP"][t])

        # PV
        model.Add(power["PV"][t] == power_use["PV"][t] + power_to_grid["PV"][t] + power_to_BAT["PV"][t])
        model.Add(power["PV"][t] == parameters["sol_rad"][t] * devs["PV"]["max_area"] * devs["PV"]["eta"] / 1000)

        # BAT
        model.Add(dch["BAT"][t] == power_use["BAT"][t] + power_to_grid["BAT"][t])
        model.Add(ch["BAT"][t] == power_to_BAT["PV"][t] + power_to_BAT["from_grid"][t])

    # # Heat Pump blocking times
    # blocking_hours = []
    # for x in [12, 13, 16, 17]:  # 12-13h, 13-14h, 16-17h, 17-18h
    #     if x - hour < 0:
    #         blocking_hours.append(x - hour + prediction_horizon)
    #     else:
    #         blocking_hours.append(x - hour)
    # for t in blocking_hours:
    #     model.Add(power["HP"][t] == 0, name="HP_blocking_time")

    # %% ENERGY BALANCES (BUILDINGS)

    for t in time_steps:
        # Heat balance
        model.Add(demand["heat"][t] == dch["TES"][t] + heat_to_heating["HP"][t])
        model.Add(demand["dhw"][t] == dch["DHW"][t] + heat_to_dhw["HP"][t])

        # Cooling balance
        model.Add(demand["cool"][t] == cool["HP"][t])

        # Electricity demands
        model.Add(
            power_use["PV"][t] + power_use["BAT"][t] + power["from_grid"][t] == demand["elec"][t] + demand["e_mob"][t] +
            power["HP"][t])
        model.Add(power["to_grid"][t] == power_to_grid["PV"][t] + power_to_grid["BAT"][t])

    # %% BUILDING THERMAL STORAGES AND BATTERY
    for device in ["TES", "DHW", "BAT"]:
        # Cyclic condition
        # SOC at 0:00 is equal to last simulation SOC, soc[device][len(time_steps)-1] is also SOC at 0:00
        # model.Add(soc[device][len(time_steps)-1] == soc_data["0"]["TES"])# * devs[device]["cap"])
        model.Add(
            soc[device][0] == soc_data[device] * (1 - devs[device]["sto_loss"]) + devs[device]["eta_ch"] * ch[device][
                0] - 1 / devs[device]["eta_dch"] * dch[device][0])

        for t in np.arange(1, len(time_steps)):
            # Energy balance: soc(t) = soc(t-1) + heat_from/to_storage
            model.Add(
                soc[device][t] == soc[device][t - 1] * (1 - devs[device]["sto_loss"]) + devs[device]["eta_ch"] *
                ch[device][t] - 1 / devs[device]["eta_dch"] * dch[device][t])

    # %% RESIDUAL THERMAL LOADS (BUILDINGS)

    for t in time_steps:
        model.Add(res_thermal[t] == (heat_total["HP"][t] - power["HP"][t]) - cool["HP"][t])

    # %% RESIDUAL ELECTRICITY LOADS (BUILDINGS)

    for t in time_steps:
        model.Add(res_elec[t] == demand["elec"][t] + demand["e_mob"][t] + power["HP"][t])

    # Residual loads
    for t in time_steps:
        model.Add(residual["electricity"][t] == sum(res_elec[t] for t in time_steps))

    # %% BALANCING UNIT CONSTRAINTS

    # %% GRID CONSTRAINTS

    for t in time_steps:
        # Limitation of power from and to grid
        for device in ["from_grid", "to_grid"]:
            model.Add(power[device][t] <= grid_limit_el)

        # Electricity balance
        model.Add(
            from_grid_total == sum(power["from_grid"][t] + power_to_BAT["from_grid"][t] for t in time_steps))
        model.Add(to_grid_total == sum(power["to_grid"][t] for t in time_steps))

    # %% OBJECTIVE

    # Electricity costs
    model.Add(obj == from_grid_total * parameters["price_el"] - to_grid_total * parameters["feed_in_revenue_el"],
                    "sum_up_OPEX")
    # model.Add(obj == from_grid_total * parameters["price_el"] - to_grid_total * parameters["feed_in_rev_el"], "sum_up_OPEX")

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Set model parameters and execute calculation
    print("Precalculation and model set up done in %f seconds." % (time.time() - start_time))

    # # Set solver parameters
    # model.params.MIPGap = 0.01  # ---,         gap for branch-and-bound algorithm

    # Setting Solver TimeLImit to 180 seconds
    model.SetTimeLimit(180000)

    # Execute calculation
    start_time = time.time()
    time_optimization = time.time() - start_time
    time_walltime = model.wall_time()

    # pdb.set_trace()

    result_status = model.Solve()
    print("Optimization done. (%f seconds.)" % (time.time() - start_time))

    # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Check and save results
    optim_results = {}
    # dir_results = "optimization_results"
    # if not os.path.exists(dir_results):
    #    os.makedirs(dir_results)

    # Check if optimal solution was found
    if result_status == model.OPTIMAL:
        print("Optimization was successfull. Objective function is %f" % model.Objective().Value())
        print("Optimization done. (%f seconds.)" % time_optimization)
        print(('Optimal objective value = %f' % model.Objective().Value()))
        print("\n")

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

        optim_results["el_costs"].append(
            power["from_grid"][0].SolutionValue() * parameters["price_el"] - power["to_grid"][0].SolutionValue() * parameters["feed_in_revenue_el"])
        optim_results["Residual Electricity demand"].append(res_elec[0].SolutionValue())
        optim_results["Residual Thermal demand"].append(res_thermal[0].SolutionValue())

        for k in ["TES", "DHW", "BAT"]:
            optim_results["SOC_" + k].append(soc[k][0].SolutionValue())
            optim_results["Charge_" + k].append(ch[k][0].SolutionValue())
            optim_results["Discharge_" + k].append(dch[k][0].SolutionValue())

        for k in ["BAT", "PV"]:
            optim_results["Power (use)" + "_" + k].append(power_use[k][0].SolutionValue())
            optim_results["Power (togrid)" + "_" + k].append(power_to_grid[k][0].SolutionValue())

        for k in ["PV", "from_grid"]:
            optim_results["Power (toBAT)_" + k].append(power_to_BAT[k][0].SolutionValue())

        for k in ["HP"]:
            optim_results["Power_cool_" + k].append(power_cool[k][0].SolutionValue())
            optim_results["Power_heat_" + k].append(power_heat[k][0].SolutionValue())
            optim_results["Heat HP to TES_dem"].append(heat_to_heating[k][0].SolutionValue())
            optim_results["Heat HP to DHW_dem"].append(heat_to_dhw[k][0].SolutionValue())

        optim_results["to_grid"].append(power["to_grid"][0].SolutionValue())
        optim_results["from_grid"].append(power["from_grid"][0].SolutionValue() + power_to_BAT["from_grid"][0].SolutionValue())

        optim_results["el_dem"] += demand["elec"][0] + demand["e_mob"][0]
        optim_results["heat_dem"] += demand["dhw"][0] + demand["heat"][0]

        write_json("Results", "results.json", optim_results)

        return optim_results
        
        
    elif result_status == model.INFEASIBLE or result_status == model.UNBOUNDED:  # "INFEASIBLE" or "INF_OR_UNBD"
        print("Optimization " + str(hour) + " was INFEASIBLE or UNBOUNDED")
        model.write("model.lp")
    elif result_status == model.FEASIBLE:
        print("Optimization is feasible or stopped by limit.")
        try:
            print("Try to calculate IIS.")
            model.computeIIS() #noch kein Befehl in or Tools gefunden
            model.write("model.ilp")
            print("IIS was calculated and saved as model.ilp")
        except:
            print("Could not calculate IIS.")
        return {}
    elif result_status == model.ABNORMAL:
        print(
            "Optimization failed due to Abnormal error. Check on large numerical range among variables and try to shrink it/them.")
        try:
            print("Try to calculate IIS.")
            model.computeIIS()  # noch kein Befehl in or Tools gefunden
            model.write("model.ilp")
            print("IIS was calculated and saved as model.ilp")
        except:
            print("Could not calculate IIS.")
        return {}
    else:
        print("Optimization failed due to unknown error.")
        try:
            print("Try to calculate IIS.")
            model.computeIIS() #noch kein Befehl in or Tools gefunden
            model.write("model.ilp")
            print("IIS was calculated and saved as model.ilp")          
        except:
            print("Could not calculate IIS.")
        return {}


