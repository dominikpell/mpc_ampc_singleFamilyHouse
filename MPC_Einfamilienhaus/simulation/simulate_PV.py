# -*- coding: utf-8 -*-

"""
Author: lku
"""

from simulation.fmu_handler import fmu_handler
#import fmpy as fmpy
import matplotlib.pyplot as plt


def run_PV_sim(start_time, prediction_horizon, time_step, sim_tolerance, options, PV, T_air, sol_rad, win_Spe):
    fmu_file = 'FMUs/PV_FMU.fmu'
    fmu = fmu_handler(
        start_time=start_time,
        stop_time=start_time + (prediction_horizon-time_step)*3600,
        step_size=time_step * 3600,
        sim_tolerance=sim_tolerance,
        fmu_file=fmu_file,
        instanceName='PV_sim')
    fmu.setup()
    # PV
    #fmu.set_value('PV_factor', options['PV']['PV_factor'])
    fmu.set_value('til', options["til"])
    fmu.set_value('azi_1', options["azi_1"])
    fmu.set_value('azi_2', options["azi_2"])
    fmu.set_value('lat', options["lat"])
    fmu.set_value('lon', options["lon"])
    fmu.set_value('n_mod', PV['n_mod'])
    fmu.set_value('IdentifierPV', PV['Identifier'])

    fmu.initialize()
    # Define variables to be saved in simulations
    # flag for while loop
    finished = False

    # Define variables to be saved in simulations
    sim_out = {
        "power_PV": [],
    }

    results = []

    while not finished:
        cur_time_step = int((fmu.current_time - start_time) / (time_step * 3600))
        # set control inputs for current time step
        fmu.set_value("T_air", T_air[cur_time_step])
        fmu.set_value("H_GloHor", sol_rad[cur_time_step])
        fmu.set_value("winSpe", win_Spe[cur_time_step])

        # read result at current time step
        results = fmu.read_variables(sim_out)
        for out in sim_out:
            sim_out[out].append(results[out])

        # do step
        finished = fmu.do_step()

        # close fmu
    fmu.close()
    return sim_out["power_PV"]

if __name__ == '__main__':
    params = {
        'start_time': 0,
        'prediction_horizon':2*24,
        'time_step': 0.25
    }

    sim_results = run_PV_sim(params)

    #plt.plot(sim_results['SOC_bat'])
    plt.plot(sim_results['P_PV_AC'])
    plt.show()
