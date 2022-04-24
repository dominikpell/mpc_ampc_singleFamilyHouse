# -*- coding: utf-8 -*-

"""
Author: lku
"""

import pickle
from Functions.simulation import simulate_fmu as sim
import parameter

params_sim = {
        'control_horizon': 744-0.25,            # hours, control horizon
        'time_step': 0.25,                      # hours, time step
        'start_time': 0,                        # hour, start time of the year Jan:0, Feb:744, Mar:, Apr:2160, Jun:,Jul: 4344, Aug: ,Oct:6552, Nov: ,Dez:
        }

dir_results = '2020_08_07/744_Hours_WithDeg'
file_name = {
    'sim': dir_results+'optim_lower_layer.pkl',
    'options': dir_results+'options.pkl'
}

save_optim_results = pickle.load(open(file_name['sim'], "rb"))
options= pickle.load(open(file_name['options'], "rb"))

control_variables = {}
control_variables['P_bat_ch'] = save_optim_results['P_bat_ch']
control_variables['P_bat_dis'] = save_optim_results['P_bat_dis']
control_variables['P_ev_ch'] = save_optim_results['P_ev_ch']
control_variables['P_ev_dis'] = save_optim_results['P_ev_dis']
control_variables['x_FCR'] = []
if options['Frequency_Control']:
    control_variables['x_FCR'] = save_optim_results['x_FCR']

initials_sim = parameter.params(options)

sim_results_MPC_total = sim.run_sim(params_sim, control_variables, initials_sim, options)
sim_results_total_file = dir_results + '/sim_results_MPC_total.pkl'
pickle.dump(sim_results_MPC_total, open(sim_results_total_file, "wb"))