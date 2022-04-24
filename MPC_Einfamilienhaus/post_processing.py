# -*- coding: utf-8 -*-
"""

ECTOCONTROL

Developed by:  E.ON Energy Research Center, 
               Institute for Energy Efficient Buildings and Indoor Climate, 
               RWTH Aachen University, 
               Germany

Developed in:  2019

"""
# import sys
# print(sys.path)
import matplotlib.pyplot as plt
import numpy as np
import os
import plotly.express as px
import pandas as pd
import json

def plot(dir_results, optim_results, prediction_horizon, time_step_length):
    # print(sys.path)
    # Create folder for plots
    dir_plots = os.path.join(dir_results)
    if not os.path.exists(dir_plots):
        os.makedirs(dir_plots)

    time_steps = int(prediction_horizon / time_step_length)

    print("Create plots...")

    # Prepare colors
    plot_colors = ["#168213", "#dea900", "#c00000"]

    # Prepare labels
    x_range = range(prediction_horizon)

    #### PLOTS
    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fig = plt.figure()
    ax = fig.add_subplot(2, 1, 1, ylabel="EUR", xlabel="Time (h)")

    # Prepare profiles
    plot_series = np.zeros(time_steps)
    for t in range(time_steps):
        plot_series[t] = sum(optim_results["el_costs"][x] for x in range(t))

    # Prepare sorted profiles
    plot_sorted_series = np.zeros(time_steps)
    for t in range(time_steps):
        plot_sorted_series[t] = sum(optim_results["el_costs"][x] for x in range(len(optim_results["el_costs"])))

    ax.plot(x_range, plot_series, label="Electricity Costs", color="black")
    ax.set_xlim(0, prediction_horizon)
    ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
    ax.set_axisbelow(True)
    ax.grid(color=[0.8, 0.8, 0.8], which="minor", linestyle="-", linewidth=0.5)
    ax.minorticks_on()
    ax.grid(color=[0.6, 0.6, 0.6], which="major", linestyle="-", linewidth=0.8)
    plt.grid(True)

    print(os.path.join(dir_plots, "Total Electricity Cost" + ".png"))
    if os.path.exists(os.path.join(dir_plots, "Total Electricity Cost" + ".png")):
        os.remove(os.path.join(dir_plots, "Total Electricity Cost" + ".png"))
    plt.savefig(fname=os.path.join(dir_plots, "Total Electricity Cost" + ".pdf"), dpi=400, format="png", bbox_inches="tight", pad_inches=0.1)
    #plt.savefig(fname="Total Electricity Cost")
    plt.close(fig)
    print("Check")
    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fig = plt.figure()
    ax = fig.add_subplot(3, 1, 1, ylabel="kWh", xlabel="Time (h)")

    # Prepare profiles
    plot_series = np.zeros(time_steps)
    for t in range(time_steps):
        plot_series[t] = sum(optim_results["Residual Thermal demand"][x] for x in range(t))

    ax.plot(x_range, plot_series, label="Residual Thermal Demand", color="blue")
    ax.set_xlim(0, prediction_horizon)
    ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
    ax.set_axisbelow(True)
    ax.grid(color=[0.8, 0.8, 0.8], which="minor", linestyle="-", linewidth=0.5)
    ax.minorticks_on()
    ax.grid(color=[0.6, 0.6, 0.6], which="major", linestyle="-", linewidth=0.8)
    plt.grid(True)

    # Prepare profiles
    ax = fig.add_subplot(3, 1, 2, ylabel="kW", xlabel="Time (h)")

    plot_series = np.zeros(time_steps)
    for t in range(time_steps):
        plot_series[t] = optim_results["Residual Thermal demand"][t]
    ax.stackplot(x_range, plot_series, step="post", labels=["Residual Thermal demand"], colors=plot_colors)
    ax.set_xlim(0, prediction_horizon)
    ax.set_ylim(-40, 40)
    ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
    ax.set_axisbelow(True)
    ax.grid(color=[0.8, 0.8, 0.8], which="minor", linestyle="-", linewidth=0.5)
    ax.minorticks_on()
    ax.grid(color=[0.6, 0.6, 0.6], which="major", linestyle="-", linewidth=0.8)
    plt.grid(True)

    if os.path.exists(os.path.join(dir_plots, "Residual Thermal demand.png")):
        os.remove(os.path.join(dir_plots, "Residual Thermal demand.png"))
    plt.savefig(fname=os.path.join(dir_plots, "Residual Thermal demand.png"), dpi=400, format="png", bbox_inches="tight", pad_inches=0.1)
    plt.close(fig)

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fig = plt.figure()
    ax = fig.add_subplot(3, 1, 1, ylabel="kWh", xlabel="Time (h)")

    # Prepare profiles
    plot_series = np.zeros(time_steps)
    for t in range(time_steps):
        plot_series[t] = sum(optim_results["Residual Electricity demand"][x] for x in range(t))

    ax.plot(x_range, plot_series, label="Residual Electricity Demand", color="blue")
    ax.set_xlim(0, prediction_horizon)
    ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
    ax.set_axisbelow(True)
    ax.grid(color=[0.8, 0.8, 0.8], which="minor", linestyle="-", linewidth=0.5)
    ax.minorticks_on()
    ax.grid(color=[0.6, 0.6, 0.6], which="major", linestyle="-", linewidth=0.8)
    plt.grid(True)

    # Prepare profiles
    ax = fig.add_subplot(3, 1, 2, ylabel="kW", xlabel="Time (h)")

    plot_series = np.zeros(time_steps)
    for t in range(time_steps):
        plot_series[t] = optim_results["Residual Electricity demand"][t]
    ax.stackplot(x_range, plot_series, step="post", labels=["Residual Electricity demand"], colors=plot_colors)
    ax.set_xlim(0, prediction_horizon)
    ax.set_ylim(0, 20)
    ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
    ax.set_axisbelow(True)
    ax.grid(color=[0.8, 0.8, 0.8], which="minor", linestyle="-", linewidth=0.5)
    ax.minorticks_on()
    ax.grid(color=[0.6, 0.6, 0.6], which="major", linestyle="-", linewidth=0.8)
    plt.grid(True)

    if os.path.exists(os.path.join(dir_plots, "Residual Electricity demand" + ".png")):
        os.remove(os.path.join(dir_plots, "Residual Electricity demand" + ".png"))
    plt.savefig(fname=os.path.join(dir_plots, "Residual Electricity demand" + ".png"), dpi=400, format="png", bbox_inches="tight", pad_inches=0.1)
    plt.close(fig)

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for k in ["grid"]:
        fig = plt.figure()
        # Prepare profiles
        ax = fig.add_subplot(2, 1, 1, ylabel="kW", xlabel="Time (h)")
        for i in ["to_" + k, "from_" + k]:
            plot_series = np.zeros(time_steps)
            for t in range(time_steps):
                plot_series[t] = optim_results[i][t]
            if i == "from_" + k:
                color = "green"
                ax.bar(x_range, -plot_series, label="Electricity " + i, color=color)
            else:
                color = "lime"
                ax.bar(x_range, plot_series, label="Electricity " + i, color=color)
            ax.set_xlim(0, prediction_horizon)
            ax.set_ylim(-15, 15)
            ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
            ax.set_axisbelow(True)
            ax.grid(color=[0.8, 0.8, 0.8], which="minor", linestyle="-", linewidth=0.5)
            ax.minorticks_on()
            ax.grid(color=[0.6, 0.6, 0.6], which="major", linestyle="-", linewidth=0.8)
            plt.grid(True)

        if os.path.exists(os.path.join(dir_plots, "Electricity " + k + ".png")):
            os.remove(os.path.join(dir_plots, "Electricity " + k + ".png"))
        plt.savefig(fname=os.path.join(dir_plots, "Electricity " + k + ".png"), dpi=400, format="png", bbox_inches="tight", pad_inches=0.1)
        plt.close(fig)

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Prepare profiles

    fig = plt.figure()
    ax = fig.add_subplot(2, 1, 1, ylabel="kW", xlabel="Time (h)")
    ax.stackplot(
        x_range,
        optim_results["Power (toBAT)_PV"],
        optim_results["Power (toBAT)_from_grid"],
        optim_results["Power (use)_BAT"],
        optim_results["Power (togrid)_BAT"],
        step="post",
        labels=["Power (charge)_PV", "Power (charge)_from_grid", "Power (use)_BAT", "Power (togrid)_BAT"],
        colors=["blue", "navy", "green", "red"],
    )
    ax.set_xlim(0, prediction_horizon)
    ax.set_ylim(0, 15)
    ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
    ax.set_axisbelow(True)
    ax.grid(color=[0.8, 0.8, 0.8], which="minor", linestyle="-", linewidth=0.5)
    ax.minorticks_on()
    ax.grid(color=[0.6, 0.6, 0.6], which="major", linestyle="-", linewidth=0.8)
    plt.grid(True)

    ax = fig.add_subplot(2, 1, 2, ylabel="kWh", xlabel="Time (h)")
    ax.plot(range(1, prediction_horizon + 1), optim_results["SOC_BAT"], label="SOC", color="black")
    ax.set_xlim(0, prediction_horizon)
    ax.set_ylim(0, 15)
    ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
    ax.set_axisbelow(True)
    ax.grid(color=[0.8, 0.8, 0.8], which="minor", linestyle="-", linewidth=0.5)
    ax.minorticks_on()
    ax.grid(color=[0.6, 0.6, 0.6], which="major", linestyle="-", linewidth=0.8)
    plt.grid(True)

    if os.path.exists(os.path.join(dir_plots, "BAT" + ".png")):
        os.remove(os.path.join(dir_plots, "BAT" + ".png"))
    plt.savefig(fname=os.path.join(dir_plots, "BAT" + ".png"), dpi=400, format="png", bbox_inches="tight", pad_inches=0.1)
    plt.close(fig)

    fig = plt.figure()
    ax = fig.add_subplot(2, 1, 1, ylabel="kW", xlabel="Time (h)")
    ax.stackplot(
        x_range,
        optim_results["Power (toBAT)_PV"],
        optim_results["Power (use)_PV"],
        optim_results["Power (togrid)_PV"],
        step="post",
        labels=["Power (toBAT)_PV", "Power (use)_PV", "Power (togrid)_PV"],
        colors=["blue", "green", "red"],
    )
    ax.set_xlim(0, prediction_horizon)
    ax.set_ylim(0, 15)
    ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
    ax.set_axisbelow(True)
    ax.grid(color=[0.8, 0.8, 0.8], which="minor", linestyle="-", linewidth=0.5)
    ax.minorticks_on()
    ax.grid(color=[0.6, 0.6, 0.6], which="major", linestyle="-", linewidth=0.8)
    plt.grid(True)

    if os.path.exists(os.path.join(dir_plots, "PV" + ".png")):
        os.remove(os.path.join(dir_plots, "PV" + ".png"))
    plt.savefig(fname=os.path.join(dir_plots, "PV" + ".png"), dpi=400, format="png", bbox_inches="tight", pad_inches=0.1)
    plt.close(fig)

    # Prepare profiles
    for k in ["TES", "DHW"]:
        fig = plt.figure()
        ax = fig.add_subplot(2, 1, 1, ylabel="kW", xlabel="Time (h)")

        plot_series = {}
        for technology in ["Charge_" + k, "Discharge_" + k]:
            title, tech = technology.split("_", 1)
            plot_series[title] = np.zeros(time_steps)
            for t in range(time_steps):
                plot_series[title][t] = optim_results[technology][t]
        ax.stackplot(x_range, plot_series["Charge"], plot_series["Discharge"], step="post", labels=["Charge" + k, "Discharge" + k], colors=["green", "red"])
        ax.set_xlim(0, prediction_horizon)
        ax.set_ylim(0, 60)
        ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
        ax.set_axisbelow(True)
        ax.grid(color=[0.8, 0.8, 0.8], which="minor", linestyle="-", linewidth=0.5)
        ax.minorticks_on()
        ax.grid(color=[0.6, 0.6, 0.6], which="major", linestyle="-", linewidth=0.8)
        plt.grid(True)

        ax = fig.add_subplot(2, 1, 2, ylabel="kWh", xlabel="Time (h)")
        ax.plot(range(1, prediction_horizon + 1), optim_results["SOC_" + k], label="SOC", color="black")
        ax.set_xlim(0, prediction_horizon)
        ax.set_ylim(0, 60)
        ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
        ax.set_axisbelow(True)
        ax.grid(color=[0.8, 0.8, 0.8], which="minor", linestyle="-", linewidth=0.5)
        ax.minorticks_on()
        ax.grid(color=[0.6, 0.6, 0.6], which="major", linestyle="-", linewidth=0.8)
        plt.grid(True)

        if os.path.exists(os.path.join(dir_plots, k + ".png")):
            os.remove(os.path.join(dir_plots, k + ".png"))
        plt.savefig(fname=os.path.join(dir_plots, k + ".png"), dpi=400, format="png", bbox_inches="tight", pad_inches=0.1)
        plt.close(fig)

    # Prepare profiles
    fig = plt.figure()
    ax = fig.add_subplot(2, 1, 1, ylabel="kW", xlabel="Time (h)")

    ax.stackplot(x_range, optim_results["Power_cool_HP"], optim_results["Power_heat_HP"], step="post", labels=["Power (Cooling)_HP", "Power (Heating)_HP"], colors=["blue", "red"])
    ax.set_xlim(0, prediction_horizon)
    ax.set_ylim(0, 40)
    ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
    ax.set_axisbelow(True)
    ax.grid(color=[0.8, 0.8, 0.8], which="minor", linestyle="-", linewidth=0.5)
    ax.minorticks_on()
    ax.grid(color=[0.6, 0.6, 0.6], which="major", linestyle="-", linewidth=0.8)
    plt.grid(True)

    if os.path.exists(os.path.join(dir_plots, "HP" + ".png")):
        os.remove(os.path.join(dir_plots, "HP" + ".png"))
    plt.savefig(fname=os.path.join(dir_plots, "HP" + ".png"), dpi=400, format="png", bbox_inches="tight", pad_inches=0.1)
    plt.close(fig)

    print("Reached end of code")

    # #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # for n in range(response_dict["n_nodes"]):
    #     # Create folder for plots
    #     dir_plots = os.path.join("Plots", str(n))
    #     if not os.path.exists(dir_plots):
    #         os.makedirs(dir_plots)

    #     tech_dict = response_dict[str(n)]
    #     for technology in ["Cooling_DRC", tech_dict.keys():
    #         title, tech = technology.split("_", 1)
    #         fig = plt.figure()
    #         ax = fig.add_subplot(2,1,1, ylabel = title + " " + tech + " kW(h)", xlabel="Time (h)")

    #         # Prepare profiles
    #         plot_series = np.zeros(time_steps)
    #         for t in range(time_steps):
    #             plot_series[t] = response_dict[str(n)][technology][t]

    #         # Prepare sorted profiles
    #         plot_sorted_series = np.zeros(time_steps)
    #         for t in range(time_steps):
    #             plot_sorted_series[t] = response_dict[str(n)][technology][t]

    #         ax.stackplot(x_range, plot_series, step="post", labels =  title + " " + tech, colors = plot_colors)
    #         ax.set_xlim(0,prediction_horizon)
    #         ax.legend(bbox_to_anchor=(1.01, 1.0), loc="upper left", fontsize=8)
    #         ax.set_axisbelow(True)
    #         ax.grid(color=[0.8,0.8,0.8], which="minor", linestyle='-', linewidth=0.5)
    #         ax.minorticks_on()
    #         ax.grid(color=[0.6,0.6,0.6], which="major", linestyle='-', linewidth=0.8)
    #         plt.grid(True)

    #         # ### Plots sorted load curves
    #         # ax2 = fig.add_subplot(2,1,2, ylabel="", xlabel="time (h)")
    #         # ax2.stackplot(x_range, plot_sorted_series, step="post", labels = labels, colors = plot_colors)
    #         # ax2.set_xlim(0,8760)
    #         # ax2.set_axisbelow(True)
    #         # ax2.grid(color=[0.8,0.8,0.8], which="minor", linestyle='-', linewidth=0.5)
    #         # ax2.minorticks_on()
    #         # ax2.grid(color=[0.6,0.6,0.6], which="major", linestyle='-', linewidth=0.8)
    #         # plt.grid(True)

    # #    scenario_str = scenarios["district"] + "_p_el-" + str(scenarios["price_supply_el"]) + "_f_el-" + str(scenarios["revenue_feed_in_el"]) + "_p_gas-" + str(scenarios["price_supply_gas"]) + "_cop-" + str(scenarios["HP_COP"])
    #         if os.path.exists(os.path.join(dir_plots, title + " " + tech + ".png")):
    #             os.remove(os.path.join(dir_plots, title + " " + tech + ".png"))
    #         plt.savefig(fname=os.path.join(dir_plots, title + " " + tech + ".png"), dpi = 400, format = "png", bbox_inches="tight", pad_inches=0.1)
    #         plt.close(fig)

def load_json(target_path, file_name):
    with open(os.path.join(target_path, file_name)) as f:
        last_results = json.load(f)

    return last_results

def miniplot(dir_results, title):

    json = load_json(dir_results, title)


    if title == "final_results.json":
        for key in ['power_to_grid', 'power_from_grid', 'res_elec',
                    'power_PV',
                    'power_use_PV', 'power_to_grid_PV', 'power_to_BAT_PV',
                    'power_use_BAT', 'power_to_grid_BAT', 'power_to_BAT_from_grid',
                    'ch_BAT', 'dch_BAT', 'soc_BAT',

                    'heat_HP', 'power_HP',
                    'heat_rod', "power_rod",
                    'T_supply_HP_heat',
                    'T_supply_heat',
                    'T_return_heat',

                    'ch_TES', 'dch_TES', 't_TES',
                    'ch_DHW', 'dch_DHW', 't_DHW',

                    'T_return_UFH',
                    'T_supply_UFH',
                    'Q_conv_UFH',
                    'Q_rad_UFH',
                    'T_panel_heating1',
                    'T_thermalCapacity_down',
                    'T_thermalCapacity_top',

                    'T_Air', 't_rad',
                    'dT_vio',]:
            df = pd.DataFrame(json["states"][key])
            fig = px.line(df, y=["sim"], title=key)
            fig.show()
        for key in json["costs"].keys():
            df = pd.DataFrame(json["costs"][key])
            fig = px.line(df, y=["sim"], title=key)
            fig.show()
        # for key in ["t_TES", "t_DHW", "soc_BAT"]:
        #     df = pd.DataFrame(json[key])
        #     fig = px.line(df, y=["sim"], title=key)
        #     fig.show()
        # for key in json.keys():
        #     df = pd.DataFrame(json[key])
        #     fig = px.line(df, y=["opti", "sim"], title=key)
        #     fig.show()
        # print(0.346 * 0.25/1000 * sum(json["states"]["power_from_grid"]["opti"][t] for t in range(len(json["states"]["power_from_grid"]["opti"]))))

    else:
        df = pd.DataFrame(json)
        ##### SHOW DATA OF ALL PERFECT FORECAST TIME_SERIES
        # fig = px.line(df, y=["dem_elec"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["dem_e_mob"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["dem_dhw_m_flow"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["dem_dhw_T"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ts_T_air"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ts_sol_rad"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ts_win_spe"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["T_preTemRoof"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["T_preTemFloor"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["T_preTemWall"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["Q_solar_rad"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["Q_solar_conv"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ts_T_inside_max"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ts_T_inside_min"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ts_gains_human"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ts_gains_dev"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ts_gains_human"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ts_gains_light"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ts_powerPV", "power_PV"], title="Unsorted Input")
        # fig.show()





        # fig = px.line(df, y=["T_Air", "ts_T_inside_max", "ts_T_inside_min"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["t_TES", "t_DHW"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["T_supply_HP_heat", "T_supply_UFH"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ch_TES", "dch_TES", "ch_DHW", "dch_DHW"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ch_TES", "ch_DHW", "heat_rod"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["power_HP", "power_rod"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["T_return_heat", "T_supply_HP_heat"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["T_panel_heating1", "T_thermalCapacity_top", "T_return_UFH", "T_supply_UFH"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["Q_UFH", "Q_conv_UFH", "Q_rad_UFH"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["dem_dhw_T", ], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["soc_BAT"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ch_BAT", "dch_BAT" ], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["ts_price_el"], title="Unsorted Input")
        # fig.show()
        # fig = px.line(df, y=["power_from_grid"], title="Unsorted Input")
        # fig.show()


    # df = df.sort_values(by="x")
    # fig = px.line(df, x="x", y="y", title="Sorted Input")
    # fig.show()




if __name__ == "__main__":
    path_file = str(os.path.dirname(os.path.realpath(__file__)))
    dir_results = os.path.join(path_file, "Results", "DATA", "Results")  # , str(datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")))

    # miniplot(dir_results, "results_0.json")
    # miniplot(dir_results, "results_6.json")
    # miniplot(dir_results, "results_167.json")
    miniplot(dir_results, "final_results.json")
