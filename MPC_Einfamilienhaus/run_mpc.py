# -*- coding: utf-8 -*-
"""

OPERATION OPTIMIZATION HASSEL

Developed by:  E.ON Energy Research Center, 
               Institute for Energy Efficient Buildings and Indoor Climate, 
               RWTH Aachen University, 
               Germany

Developed in:  2021

"""
from typing import final

from ipython_genutils.py3compat import input

import make_txt_from_time_series
import post_processing
from creator_spec_disj import *
import json
import os
import pickle
import numpy as np
import time
import fmpy
import datetime
import pandas as pd
import parameters as get_params
import ModelTuning as MT
import get_AMPC_data

import pyo_run_optim as run_optim
import simulation.simulate_fmu as sim
# import post_processing
# import excel_compilation

class StartMPC:
    def __init__(self):
        """Define overall parameters"""
        self.MPC_horizon = 7*24  # hours (days)
        self.prediction_horizon = 24  # hours
        self.control_horizon = 1.0  # hours
        self.time_step = 15/60  # hours
        self.year = "warm"  # alternatives: "warm"=warm, "kalt"=cold, "normal"=normal
        self.date = '2015-01-01'  # Set point: when does the MPC begin

        self.day_of_year = pd.Timestamp(self.date).day_of_year
        self.hour_of_year = (self.day_of_year - 1) * 24
        self.start_time = self.hour_of_year * 3600

        """Define options and some additional overall parameters"""
        self.options = {
        ### Location of the Single Family House ###
            "lat": 52.519*2*3.14/360,  # Berlin
            "lon": 13.408*2*3.14/360,  # Berlin
        ### Options for Single Family House ###
            "roof_area": 80,  # m²
            "til": 15*2*3.14/360,  # ° Dachneigung
            "azi_1": 90*(2*3.14)/(360),  #°, orientation of roof sides (0: south, -: East, +: West)
            "azi_2": -90*(2*3.14)/(360),  #°, orientation of roof sides (0: south, -: East, +: West)
            "n_tz": 1,  # number of different thermal zones to be implemented
        ### Options for Battery ###
            "battery_type": "Li-Ion Viessmann/4.7kWh",
            # alternatives: "Lead Acid CLH/2.4kWh", "Lead Acid Generic/2.88kWh", "Lead Acid WP/86.4Wh", "Li-Ion Aquion/25.9kWh", "Li-Ion Tesla1/6.4kWh", "Li-Ion Tesla2/13.5kWh"
            "battery_requested_capacity": 12,  # kWh
        ### Options for PV modules ###
            "PV_type": "ShellSP70",
            # alternatives: "AleoS24185", "CanadianSolarCS6P250P", "SharpNUU235F2", "QPLusBFRG41285", "SchuecoSPV170SME1"
        ### Options for electricity tariff  ###
            "tariff": 3,
            # alternatives: 1:fixed, 2:HT/NT, 3: dynamic
        }

        # Load overall parameters and input data for first iteration
        self.parameters, self.devs, self.initials = get_params.load_parameters(self.options, self.prediction_horizon, self.time_step)  # initials only for current time steps
        # Create SFH model
        self.creator = Creator(options=self.options, start_time=self.start_time, control_horizon=self.control_horizon,
                               prediction_horizon=self.prediction_horizon, time_step=self.time_step,
                               year=self.year, hour_of_year=self.hour_of_year,
                               parameters=self.parameters, devs=self.devs, initials=self.initials)
        self.creator.__buildHouseModel__()


        final_results = {"states": {},
                         "costs": {},
                         "sol_time": [],
                         }
        for key in ['power_to_grid', 'power_from_grid', 'res_elec',
                    'power_PV',
                    'power_use_PV', 'power_to_grid_PV', 'power_to_BAT_PV',
                    'power_use_BAT', 'power_to_grid_BAT', 'power_to_BAT_from_grid',
                    'ch_BAT', 'dch_BAT', 'soc_BAT',

                    # 'x_HP_on',
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
                    'dT_vio',
                    'T_Roof',
                    'T_Floor',
                    'T_ExtWall',
                    'T_IntWall',
                    'T_Win',
                    ]:

            final_results["states"][key] = {
                                            "opti": [],
                                            "sim": [],
                                           }

        for key in ["tot_vio_Kh", "costs_tot", "costs_vio", "costs_elec", "rev_elec", "Q_DHW", "Q_err_DHW", "E_from_grid", "E_to_grid"]:
            final_results["costs"][key] = {"opti": [],
                                           "sim": [],
                                          }
            final_results["costs"][key]["opti"].append(0)
            final_results["costs"][key]["sim"].append(0)


        ampc_training_file = {"opti": {"forecast": {},
                                      "initials": {},
                                      "outs_controls_for_sim": {},
                                      "outs_all_states_opti": {}
                                      },
                             "sim_out": {"outs_all_states_sim": {}
                                         },
                             }

        for key in ["ts_T_air", "ts_win_spe", "ts_sol_rad",
                  "dem_elec", "dem_e_mob", "dem_dhw_m_flow", "dem_dhw_T",
                  "ts_gains_human", "ts_gains_dev", "ts_gains_light",
                  "T_preTemRoof", "T_preTemFloor", "T_preTemWall", "T_preTemWin",
                  "Q_solar_rad", "Q_solar_conv", "ts_powerPV",
                  "ts_T_inside_max", "ts_T_inside_min",]:
            ampc_training_file["opti"]["forecast"][key] = []

        for key in self.initials.keys():
            ampc_training_file["opti"]["initials"][key] = []

        for key in ["PV_Distr_Use", "PV_Distr_FeedIn", "PV_Distr_ChBat",
                  "power_use_BAT", "power_to_grid_BAT", "ch_BAT",
                  "x_HP_heat", "x_HP_cool",
                  "T_supply_UFH", "T_supply_HP_heat", "T_supply_cool",
                  "heat_rod", "ch_DHW", "ch_TES",
                  "x_HP_on", "dch_TES",
                  "t_DHW", "t_TES",]:
            ampc_training_file["opti"]["outs_controls_for_sim"][key] = []

        for key in final_results["states"].keys():
            ampc_training_file["opti"]["outs_all_states_opti"][key] = []
            ampc_training_file["sim_out"]["outs_all_states_sim"][key] = []

        controls = {}
        for i in ["PV_Distr_Use", "PV_Distr_FeedIn", "PV_Distr_ChBat",
                  "power_use_BAT", "power_to_grid_BAT", "ch_BAT",
                  "ts_T_air", "ts_win_spe", "ts_sol_rad",
                  "dem_elec", "dem_e_mob", "dem_dhw_m_flow", "dem_dhw_T",
                  "ts_gains_human", "ts_gains_dev", "ts_gains_light",
                  "x_HP_heat", "x_HP_cool",
                  "T_supply_UFH", "T_supply_HP_heat", "T_supply_cool",
                  "heat_rod", "ch_DHW", "ch_TES",
                  "x_HP_on", "dch_TES",
                  "t_DHW", "t_TES",
                  "ts_T_inside_max", "ts_T_inside_min", ]:
            controls[i] = []

        #### START MPC ####
        # for run in range(5):
        for run in range(int(self.MPC_horizon/self.control_horizon)):
            print(self.hour_of_year)
            for key in self.initials:
                print(key + ":", self.initials[key])

            # LOAD RELEVANT DATA
            demand, time_series = get_params.load_demands_and_time_series(self.options, self.start_time, self.devs,
                                                                          self.prediction_horizon, self.time_step,
                                                                          self.year, int(self.hour_of_year))

            # RUN OPTIMIZATION
            results, instance, sol, sol_time = self.creator.get_control(demand, time_series)

            # SAVE OPTIMIZATION RESULTS FROM CURRENT STEP IN JSON
            path_file = str(os.path.dirname(os.path.realpath(__file__)))
            dir_results = os.path.join(path_file, "Results", "DATA")  # , str(datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")))
            self.write_json(os.path.join(dir_results, "Results"), 'results_' + str(run)+ '.json', results)

            # # WRITE TXT FILES TO FEED MODELICA MODEL WITH (JUST FOR MANUAL TESTING)
            # if self.hour_of_year == 0:
            #     for i in ["dem_elec", "dem_e_mob", "dem_dhw_m_flow", "dem_dhw_T", "ts_T_inside_max", "ts_T_inside_min",
            #               # "ts_price_el",
            #               "ts_T_air", "ts_win_spe", "ts_sol_rad",
            #               "ts_gains_human", "ts_gains_dev", "ts_gains_light",
            #               "PV_Distr_Use", "PV_Distr_FeedIn", "PV_Distr_ChBat", "power_use_BAT", "power_to_grid_BAT",
            #               "ch_BAT", "T_supply_HP_heat", "T_supply_heat", "T_return_heat", "T_supply_cool", "T_supply_UFH", "T_return_UFH",
            #               "x_HP_heat", "x_HP_cool",
            #               # "x_HP_on",
            #               "heat_rod", "ch_DHW", "ch_TES", "dch_TES", "t_TES", "t_DHW"]:
            #         make_txt_from_time_series.make_txt(results[i], i)

            for key in ampc_training_file["opti"]["forecast"].keys():
                for t in range(4):
                    ampc_training_file["opti"]["forecast"][key].append(results[key][t])
            for key in ampc_training_file["opti"]["initials"].keys():
                for t in range(4):
                    ampc_training_file["opti"]["initials"][key].append(self.initials[key])
            for key in ampc_training_file["opti"]["outs_controls_for_sim"].keys():
                for t in range(4):
                    ampc_training_file["opti"]["outs_controls_for_sim"][key].append(results[key][t])
            for key in ampc_training_file["opti"]["outs_all_states_opti"].keys():
                for t in range(4):
                    ampc_training_file["opti"]["outs_all_states_opti"][key].append(results[key][t])



            # WRITE OPTIMIZATION DATA TO FINAL_RESULTS DICTIONARY
            final_results["sol_time"].append(sol_time)

            for key in final_results["states"].keys():
                if run != 0:
                    final_results["states"][key]["opti"].pop()
                for t in range(5):
                    final_results["states"][key]["opti"].append(results[key][t])
            for key in final_results["costs"].keys():
                for t in range(4):
                    final_results["costs"][key]["opti"].append(final_results["costs"][key]["opti"][-1] + results[key][t])

            # WRITE OPTIMIZATION DATA TO DICTIONARY FOR AMPC
            inputs_ampc = {}
            for i in ["ts_T_air", "ts_win_spe", "ts_sol_rad",
                      "dem_elec", "dem_e_mob", "dem_dhw_m_flow", "dem_dhw_T",
                      "T_preTemRoof", "T_preTemFloor", "T_preTemWall", "T_preTemWin",
                      "Q_solar_rad", "Q_solar_conv", "ts_powerPV",
                      "ts_gains_human", "ts_gains_dev", "ts_gains_light",
                      "ts_T_inside_max", "ts_T_inside_min",]:
                inputs_ampc[i] = []
                for j in range(4):
                    inputs_ampc[i].append(results[i][j])
            outputs_ampc = {}
            for i in ["PV_Distr_Use", "PV_Distr_FeedIn", "PV_Distr_ChBat",
                      "power_use_BAT", "power_to_grid_BAT", "ch_BAT",
                      "x_HP_heat", "x_HP_cool",
                      "T_supply_UFH", "T_supply_HP_heat", "T_supply_cool",
                      "heat_rod", "ch_DHW", "ch_TES",
                      "x_HP_on", "dch_TES",
                      "t_DHW", "t_TES",]:
                outputs_ampc[i] = []
                for j in range(4):
                    outputs_ampc[i].append(results[i][j])



            # # RUN AMPC
            # results = get_AMPC_data.load_pred(demand, time_series, self.hour_of_year)
            # control_variables = results
            # MT.main_OnlyPredict()


            # %%%%%%% SIMULATION %%%%%%%%%%%
            # WRITE CONTROL PARAMETERS AND CONTROL VARIABLES AS INPUT FOR SIMULATION
            control_parameters = {}

            if self.year == "warm":
                control_parameters["year"] = 1
            if self.year == "kalt":
                control_parameters["year"] = 2
            if self.year == "normal":
                control_parameters["year"] = 3

            control_parameters["tariff"] = self.options["tariff"]
            control_parameters["azi1"] = self.options["azi_1"]
            control_parameters["azi2"] = self.options["azi_2"]
            control_parameters["lat"] = self.options["lat"]
            control_parameters["lon"] = self.options["lon"]
            control_parameters["n_mod"] = self.devs["PV"]["n_mod"]

            control_parameters["IdentifierPV"] = self.devs["PV"]["Identifier"]
            control_parameters["nBat"] = self.devs["BAT"]["nBat"]
            control_parameters["IdentifierBAT"] = self.devs["BAT"]["Identifier"]
            control_parameters["TSetDHW"] = self.devs["DHW"]["t_max"]
            control_parameters["eta_COP"] = self.devs["HP"]["eta_COP"]
            control_parameters["Q_HP_max"] = self.devs["HP"]["cap"]
            control_parameters["P_HR_max"] = self.devs["rod"]["cap"]
            control_parameters["eta_HR"] = self.devs["rod"]["eta"]

            control_parameters["price_el"] = self.parameters["price_el"]
            control_parameters["price_comfort_vio"] = self.parameters["price_comfort_vio"]
            control_parameters["feed_in_revenue_el"] = self.parameters["feed_in_revenue_el"]

            control_variables = {}
            for i in ["PV_Distr_Use", "PV_Distr_FeedIn", "PV_Distr_ChBat",
                      "power_use_BAT", "power_to_grid_BAT", "ch_BAT",
                      "ts_T_air", "ts_win_spe", "ts_sol_rad",
                      "dem_elec", "dem_e_mob", "dem_dhw_m_flow", "dem_dhw_T",
                      "ts_gains_human", "ts_gains_dev", "ts_gains_light",
                      "x_HP_heat", "x_HP_cool",
                      "T_supply_UFH", "T_supply_HP_heat", "T_supply_cool",
                      "heat_rod", "ch_DHW", "ch_TES",
                      "x_HP_on", "dch_TES",
                      "t_DHW", "t_TES",
                      "ts_T_inside_max", "ts_T_inside_min",]:
                control_variables[i] = []
                for j in range(5):
                    control_variables[i].append(results[i][j])
                for j in range(4):
                    controls[i].append(results[i][j])

            # RUN SIMULATION
            sim_out = sim.run_sim(year, control_parameters, control_variables, self.initials, self.start_time, self.control_horizon, self.time_step, sim_tolerance=0.000001)
            for key in ampc_training_file["sim_out"]["outs_all_states_sim"].keys():
                if run == 0:
                    for t in range(5):
                        ampc_training_file["sim_out"]["outs_all_states_sim"][key].append(sim_out[key][t])
                else:
                    for t in range(4):
                        ampc_training_file["sim_out"]["outs_all_states_sim"][key].append(sim_out[key][t+1])

            # REWRITE INITIALS
            for key in self.initials.keys():
                self.initials[key] = sim_out[key][-1]

            # WRITE SIMULATION DATA TO FINAL_RESULTS DICTIONARY
            for key in final_results["states"].keys():
                if run == 0:
                    for t in range(5):
                        final_results["states"][key]["sim"].append(sim_out[key][t])
                else:
                    for t in range(4):
                        final_results["states"][key]["sim"].append(sim_out[key][t+1])

            for key in final_results["costs"].keys():
                for t in range(4):
                    final_results["costs"][key]["sim"].append(final_results["costs"][key]["sim"][-1] + (sim_out[key][t+1]-sim_out[key][t]))


            # INCREASE HOUR AND START TIME FOR NEXT SIMULATION
            self.hour_of_year += self.control_horizon
            self.start_time += self.control_horizon * 3600
            # post_processing.miniplot('results_' + str(run)+ '.json')

            # SAVE FINAL RESULTS DICTIONARY FOR FURTHER COMPARISON IN JSON FORMAT
            path_file = str(os.path.dirname(os.path.realpath(__file__)))
            dir_results = os.path.join(path_file, "Results", "DATA")  # , str(datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")))
            self.write_json(os.path.join(dir_results, "Results"), 'final_results.json', final_results)
            self.write_json(os.path.join(dir_results, "Results"), 'ampc_training_file.json', ampc_training_file)

            if not os.path.exists(os.path.join(dir_results, "timeSeries")):
                os.makedirs(os.path.join(dir_results, "timeSeries"))
            for key in controls.keys():
                make_txt_from_time_series.make_txt(os.path.join(dir_results, "timeSeries"), controls[key], key)


        # post_processing.miniplot(os.path.join(path_file, "Results", "DATA", "Results"), "results_0.json")
        post_processing.miniplot(os.path.join(path_file, "Results", "DATA", "Results"), "final_results.json")
        # post_processing.miniplot("results_1.json")
        # post_processing.miniplot("results_2.json")
        # post_processing.miniplot("results_3.json")


    def write_json(self, target_path, file_name, data):
        if not os.path.exists(target_path):
            os.makedirs(target_path)
        with open(os.path.join(target_path, file_name), "w") as f:
            json.dump(data, f, indent=4, separators=(", ", ": "), sort_keys=True)

if __name__ == "__main__":

    test = StartMPC()

    # # Define paths and directories
    # self.path_file = str(os.path.dirname(os.path.realpath(__file__)))
    # self.dir_plots = os.path.join(self.path_file, "Results",
    #                          "Plots_")  # + str(datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")))
    # self.dir_results = os.path.join(self.path_file, "Results", "Results_")  # + str(datetime.datetime.now().strftime('%Y-%m-%d')))
    # for dir in [self.dir_plots, self.dir_results]:
    #     if not os.path.exists(dir):
    #         os.makedirs(dir)
    #
    # # Define Arrays to store results
    # self.solving_time = []
    # self.optim_results = {}
    #
    #
    # # %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MPC ITERATIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # #

    # def runMPC():
    #     for run in range(prediction_horizon):
    #         # Plot date of run
    #         days_passed = run // 24
    #         hour = run % 24
    #         time_str = str(pd.Timestamp(date) + pd.to_timedelta(days_passed, unit="d") + pd.to_timedelta(hour, unit="H"))
    #         time_stamp_str = datetime.datetime.strptime(time_str, "%Y-%m-%d %H:%M:%S").strftime("%Y-%m-%d-%H-%M-%S")
    #         print("======================== iteration = " + str(run) + "," + time_stamp_str + "========================")
    #         print('New start time is:', start_time)
    #         print('Hour of year is:', hour_of_year)
    #
    #         # Load demands and time series
    #         demand, time_series = params.load_demands_and_time_series(prediction_horizon, control_horizon, time_step, year, hour_of_year)
    #
    #         # Call optimization model
    #         optim_results, control_parameters, control_variables = run_optim.run_optim(prediction_horizon, control_horizon, time_step, parameters, devs, initials, demand, time_series, run, hour)
    #         #gp_run_optim.write_json(directory_plots, 'results.json', optim_results)
    #
    #     #post_processing.plot(directory_plots, optim_results, prediction_horizon, time_step_length)
    #     #post_processing.miniplot()
    #     # excel_compilation.create_excel_file(optim_results, os.path.join(path_file, "Results", scenario["name"] + ".xlsx"), scenario)
    #
    #     # # Define paths and directories for results
    #     # path_file = str(os.path.dirname(os.path.realpath(__file__)))
    #     # dir_results = path_file + "/Results/" + str(datetime.now().strftime('%Y-%m-%d')) + "/" + str(params_lower['total_run_time']) + "_Hours/"
    #
    #

