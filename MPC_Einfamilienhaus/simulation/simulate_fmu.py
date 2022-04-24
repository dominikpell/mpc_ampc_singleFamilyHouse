# -*- coding: utf-8 -*-

"""
Author: lku
"""
from setuptools import sic
from urllib3.util import current_time

from simulation.fmu_handler import fmu_handler
#import fmpy as fmpy
import matplotlib.pyplot as plt
import pickle
import numpy as np

from utilities.snippets import con_rule


def run_sim(year_type, control_parameters, control_variables, initials, start_time, control_horizon, time_step, sim_tolerance):

    fmu_file = 'FMUs/MA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_neu.fmu'

    fmu = fmu_handler(
        start_time=start_time,
        stop_time=start_time + control_horizon*3600,
        step_size= 5,#time_step * 3600,
        sim_tolerance=sim_tolerance,
        fmu_file=fmu_file,
        instanceName='MPC_sim')

    #print(fmu.model_description.modelVariables)

    print('Simulation is running.......')
    fmu.setup()
    # Set overall parameters
    # fmu.set_value("fmi_CommunicationStepSize", 900)
    for para in control_parameters.keys():
        fmu.set_value(para, control_parameters[para])
    # Set Initials
    for key in initials.keys():
        fmu.set_value(key + "_Init", initials[key])


    #fmpy.dump(fmu.fmu_file)
    fmu.initialize()

    # Define variables to be saved in simulations
    sim_out = {}
    for key in ['power_to_grid', 'power_from_grid', 'res_elec',
                    'power_PV',
                    'power_use_PV', 'power_to_grid_PV', 'power_to_BAT_PV',
                    'power_use_BAT', 'power_to_grid_BAT', 'power_to_BAT_from_grid',
                    'ch_BAT', 'dch_BAT', 'soc_BAT',

                    # 'x_HP_on',
                    'heat_HP', 'power_HP',
                    'heat_rod', "power_rod",
                    'T_supply_HP_heat',
                    'T_supply_HP',
                    'T_supply',
                    'T_supply_heat',
                    'T_return_heat',
                    'T_return',

                    'ch_TES', 'dch_TES', 't_TES',
                    'ch_DHW', 'dch_DHW', 't_DHW',
                    "T_TES_1", "T_TES_2", "T_TES_3", "T_TES_4",
                    "T_HE_TES_1", "T_HE_TES_2", "T_HE_TES_3", "T_HE_TES_4",
                    "T_DHW_1", "T_DHW_2", "T_DHW_3", "T_DHW_4",
                    "T_HE_DHW_1", "T_HE_DHW_2", "T_HE_DHW_3", "T_HE_DHW_4",

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

                    "tot_vio_Kh", "costs_tot", "costs_vio", "costs_elec", "rev_elec", "Q_DHW", "Q_err_DHW", "E_from_grid", "E_to_grid"
                ]:
        sim_out[key] = []

    read_vars = {}
    for key in ['power_to_grid', 'power_from_grid', 'res_elec',
                'power_PV',
                'power_use_PV', 'power_to_grid_PV', 'power_to_BAT_PV',
                'power_use_BAT', 'power_to_grid_BAT', 'power_to_BAT_from_grid',
                'ch_BAT', 'dch_BAT', 'soc_BAT',]:
        read_vars["outputs.outputsElec." + key] = []
    for key in [
        # 'x_HP_on',
                'heat_HP', 'power_HP',
                'heat_rod', "power_rod",
                'T_supply_HP_heat',
                'T_supply_HP',
                'T_supply_heat',
                'T_supply',
                'T_return',
                'T_return_heat',]:
        read_vars["outputs.outputsGen." + key] = []
    for key in ['ch_TES', 't_TES',
                'ch_DHW', 't_DHW',
                "T_TES_1", "T_TES_2", "T_TES_3", "T_TES_4",
                "T_HE_TES_1", "T_HE_TES_2", "T_HE_TES_3", "T_HE_TES_4",
                "T_DHW_1", "T_DHW_2", "T_DHW_3", "T_DHW_4",
                "T_HE_DHW_1", "T_HE_DHW_2", "T_HE_DHW_3", "T_HE_DHW_4"
                ]:
        read_vars["outputs.outputsDist." + key] = []
    for key in ['T_return_UFH',
                'T_supply_UFH',
                'Q_conv_UFH',
                'Q_rad_UFH',
                'dch_TES',
                'T_panel_heating1',
                'T_thermalCapacity_down',
                'T_thermalCapacity_top',]:
        read_vars["outputs.outputsTra." + key] = []
    for key in ['T_Air', 't_rad',
                'dT_vio',
                'dch_DHW',
                'T_Roof',
                'T_Floor',
                'T_ExtWall',
                'T_IntWall',
                'T_Win',]:
        read_vars["outputs.outputsDem." + key] = []
    for key in ["tot_vio_Kh", "costs_tot", "costs_vio", "costs_elec", "rev_elec", "Q_DHW", "Q_err_DHW", "E_from_grid", "E_to_grid"]:
        read_vars[key] = []


    # flag for while loop
    finished = False
    time_step_weather_real = 1  # hours, time step of data
    while not finished:
        cur_time_step = int((fmu.current_time-start_time)/(time_step*3600))
        # set control inputs for current time step
        if fmu.current_time-start_time == 5 or (cur_time_step > 0 and fmu.current_time % 900 == 0):
            for k in control_variables.keys():
                fmu.set_value(k, control_variables[k][cur_time_step])

            # read result at current time step
            results = fmu.read_variables(read_vars)

            for key in ['power_to_grid', 'power_from_grid', 'res_elec',
                        'power_PV',

                        'power_use_PV', 'power_to_grid_PV', 'power_to_BAT_PV',
                        'power_use_BAT', 'power_to_grid_BAT', 'power_to_BAT_from_grid',
                        'ch_BAT', 'dch_BAT', 'soc_BAT', ]:
                sim_out[key].append(results["outputs.outputsElec." + key])
            for key in [
                # 'x_HP_on',
                'heat_HP', 'power_HP',
                        'heat_rod', "power_rod",
                        'T_supply_HP_heat',
                        'T_supply_heat',
                        'T_supply_HP',
                        'T_supply',
                        'T_return_heat',
                        'T_return', ]:
                sim_out[key].append(results["outputs.outputsGen." + key])
            for key in ['ch_TES', 't_TES',
                        'ch_DHW', 't_DHW',
                        "T_TES_1", "T_TES_2", "T_TES_3", "T_TES_4",
                        "T_HE_TES_1", "T_HE_TES_2", "T_HE_TES_3", "T_HE_TES_4",
                        "T_DHW_1", "T_DHW_2", "T_DHW_3", "T_DHW_4",
                        "T_HE_DHW_1", "T_HE_DHW_2", "T_HE_DHW_3", "T_HE_DHW_4"
                        ]:
                sim_out[key].append(results["outputs.outputsDist." + key])
            for key in ['T_return_UFH',
                        'T_supply_UFH',
                        'Q_conv_UFH',
                        'Q_rad_UFH',
                        'dch_TES',
                        'T_panel_heating1',
                        'T_thermalCapacity_down',
                        'T_thermalCapacity_top', ]:
                sim_out[key].append(results["outputs.outputsTra." + key])
            for key in ['T_Air', 't_rad',
                        'dT_vio',
                        'dch_DHW',
                        'T_Roof',
                        'T_Floor',
                        'T_ExtWall',
                        'T_IntWall',
                        'T_Win', ]:
                sim_out[key].append(results["outputs.outputsDem." + key])
            for key in ["tot_vio_Kh", "costs_tot", "costs_vio", "costs_elec", "rev_elec", "Q_DHW", "Q_err_DHW",  "E_from_grid", "E_to_grid"]:
                sim_out[key].append(results[key])

            # print(fmu.read_variables(["ts_sol_rad"]))
            # print(fmu.read_variables(["outputs.outputsElec.power_PV"]))
            # print(fmu.read_variables(["heat_rod"]))


        # do step
        finished = fmu.do_step()

    # close fmu
    fmu.close()
    return sim_out


if __name__ == '__main__':
    results_lower = pickle.load(open(
        '../../Results/2020-09-14/8760_Hours_WithDegNEW_WithoutFCR_25_PV2/optim_lower_layer.pkl', "rb"))


    params_sim = {
        'control_horizon': int(len(results_lower['P_bat_control']) - 1) * 0.25,
        # hours, control horizon
        'time_step': 0.25,  # hours, time step
        'start_time': 0,
        # hour, start time of the year Jan:0, Feb:744, Mar:, Apr:2160, Jun:,Jul: 4344, Aug: ,Oct:6552, Nov: ,Dez:
    }


    # Simulate complete fmu Results:
    control_variables = {
            'P_bat_ch': [],
            'P_bat_dis': []
        }
    for t in range(len(results_lower['P_bat_control'])):
        if results_lower['P_bat_control'][t] >= 0:
            control_variables['P_bat_ch'].append(results_lower['P_bat_control'][t])
            control_variables['P_bat_dis'].append(0.0)
        else:
            control_variables['P_bat_ch'].append(0.0)
            control_variables['P_bat_dis'].append(results_lower['P_bat_control'][t])


    devs = pickle.load(open('../../Results/2020-09-14/8760_Hours_WithDegNEW_WithoutFCR_25_PV2/devs.pkl', "rb"))
    options = pickle.load(open('../../Results/2020-09-14/8760_Hours_WithDegNEW_WithoutFCR_25_PV2/options.pkl', "rb"))
    options_lower = options[2]
    initials_sim = {
        'SOC_init': 50.0,  # Initial state of charge   [%]
        'e_bat_init': [],  # Initial energy levels of segments for battery degradation [%]
        'c_cal_init': 0.0,  # Initial coefficient of calendric aging [-]
        'c_cyc_init': 0.0,  # Initial coefficient of cyclic aging [-]
        'T_init': 20.0,  # Initial cell temperature
        'SOC_init_ev': np.zeros(48),  # Initial state of charge of EVs [%]
    }

    sim_results_MPC_total = run_sim(params_sim, control_variables, initials_sim, options_lower, devs)
    sim_results_total_file = '../../Results/2020-09-14/8760_Hours_WithDegNEW_WithoutFCR_25_PV2/sim_results_MPC_total.pkl'
    pickle.dump(sim_results_MPC_total, open(sim_results_total_file, "wb"))
