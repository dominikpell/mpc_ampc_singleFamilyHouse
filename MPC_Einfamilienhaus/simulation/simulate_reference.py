# -*- coding: utf-8 -*-

"""
Author: lku
"""

from Functions.simulation.fmu_handler import fmu_handler
import fmpy as fmpy
import pickle
import matplotlib.pyplot as plt
import parameter
import csv

def run_sim(params, control_variables , options, control_limits):

    if options['Charging_Stations']:
        fmu_file = '../../FMUs/FubicModelica_ElectricalSystem_FUBIC_Reference_FMU.fmu'
    else:
        fmu_file = '../../FMUs/FubicModelica_BatteryAndPV_Reference_FMU.fmu'

    fmu = fmu_handler(
        start_time=params['start_time']*3600,
        stop_time=((params['start_time']+params['control_horizon']-1)*3600),
        step_size=params['time_step']*3600,
        sim_tolerance=0.001,
        fmu_file=fmu_file,
        instanceName='MPC_sim')


    #print(fmu.model_description.modelVariables)

    print('Simulation is running.......')

    fmu.setup()
    #fmpy.dump(fmu.fmu_file)

    # Set initials
    initials = {
        'SOC_init': 20.0,  # Initial state of charge   [%]
        'e_bat_init': [],  # Initial energy levels of segments for battery degradation [%]
        'c_cal_init': 0.0,  # Initial coefficient of calendric aging [-]
        'c_cyc_init': 0.0,  # Initial coefficient of cyclic aging [-]
        'T_init': 20.0,  # Initial cell temperature
        'SOC_init_ev': np.zeros(48),  # Initial state of charge of EVs [%]
    }

    devs = pickle.load(open(dir_name+'/devs.pkl', "rb"))

    # Set parameters for plant sizes
    # PV
    #fmu.set_value('PV_factor', options['PV']['PV_factor'])
    fmu.set_value('PanelsWest', devs['PV']['n_Mod'] / 2)
    fmu.set_value('PanelsEast', devs['PV']['n_Mod'] / 2)
    fmu.set_value('eta_nom_PV', devs['PV']['eta_nom_PV'])
    fmu.set_value('P_Max_PV', devs['PV']['n_Mod'] * options['PV']['PV_factor'] * 330)
    fmu.set_value('P_Min_PV', devs['PV']['P_Min_PV'])
    fmu.set_value('a1_PV', devs['PV']['a_PV'][0])
    fmu.set_value('a2_PV', devs['PV']['a_PV'][1])
    fmu.set_value('a3_PV', devs['PV']['a_PV'][2])

    # Battery
    fmu.set_value('Cap_cell', devs['bat']['cap_cell'])
    fmu.set_value('U_nominal', devs['bat']['U_nominal'])
    fmu.set_value('NumParallel', devs['bat']['NumParallel'])
    fmu.set_value('NumSerial', devs['bat']['NumSerial'])
    fmu.set_value('P_DCDC_bat', devs['bat']['P_DCDC_bat'])

    fmu.set_value('C_relEoL', devs['bat']['c_relEOL'])
    fmu.set_value('DOD1', devs['bat']['DOD1'])
    fmu.set_value('DOD2', devs['bat']['DOD2'])
    fmu.set_value('N1', devs['bat']['N1'])
    fmu.set_value('N2', devs['bat']['N2'])
    fmu.set_value('E_a', devs['bat']['E_a'])
    fmu.set_value('alpha', devs['bat']['alpha'])
    fmu.set_value('T0', devs['bat']['T0'])
    fmu.set_value('t_cal_ref', devs['bat']['t_cal_ref'])
    fmu.set_value('a', devs['bat']['a'])
    fmu.set_value('b_cal', devs['bat']['b_cal'])
    fmu.set_value('b_cyc', devs['bat']['b_cyc'])
    fmu.set_value('f_SOCavg', devs['bat']['f_SOC_avg'])
    fmu.set_value('width', devs['bat']['width'])
    fmu.set_value('SoC_crit', devs['bat']['SOC_crit'])

    fmu.set_value('SOC_max', devs['bat']['SOC_max_Sim'])
    fmu.set_value('SOC_min', devs['bat']['SOC_min_Sim'])
    fmu.set_value('SOC_max_PS', control_limits['SOC_max_PS'])
    fmu.set_value('SOC_min_PS', control_limits['SOC_min_PS'])
    fmu.set_value('SOC_max_SC', control_limits['SOC_max_SC'])
    fmu.set_value('SOC_min_SC', control_limits['SOC_min_SC'])
    fmu.set_value('SOC_max_FCR', control_limits['SOC_max_FCR'])
    fmu.set_value('SOC_min_FCR', control_limits['SOC_min_FCR'])


    fmu.set_value('eta_nom', devs['bat']['eta_nom_Inv'])
    fmu.set_value('P_Nom', devs['bat']['P_nom_Inv'])
    fmu.set_value('P_Min', 0.0)
    fmu.set_value('a1', devs['bat']['a_Inv'][0])
    fmu.set_value('a2', devs['bat']['a_Inv'][0])
    fmu.set_value('a3', devs['bat']['a_Inv'][0])

    if options['Charging_Stations']:
        #fmu.set_value('n_ChargingStations', devs['ev']['n_ChargingStations'])
        fmu.set_value('Cap_cell_EV', devs['ev']['Cap_cell_EV'])
        fmu.set_value('NumParallel_EV', devs['ev']['NumParallel_EV'])
        fmu.set_value('NumSerial_EV', devs['ev']['NumSerial_EV'])
        fmu.set_value('U_nominal_EV', devs['ev']['U_nominal_EV'])
        fmu.set_value('P_DCDC_bat_EV', devs['ev']['P_max_ch'])
        fmu.set_value('SOC_max_EV', devs['ev']['SOC_max'])
        fmu.set_value('SOC_min_EV', devs['ev']['SOC_min'])
        fmu.set_value('eta_Charge_EV', devs['ev']['eta_ch_Inv'])
        #fmu.set_value('MaxPower_Charge_EV', devs['ev']['P_max_ch'])
        #fmu.set_value('MinPower_Charge_EV', devs['ev']['P_min_ch'])
        #fmu.set_value('eta_Discharge_EV', devs['ev']['eta_dis_Inv'])
        #fmu.set_value('MaxPower_Discharge_EV', devs['ev']['P_max_dis'])
        #fmu.set_value('MinPower_Discharge_EV', devs['ev']['P_min_dis'])

    fmu.set_value('PrimaryFrequencyCapacity', devs['bat']['C_FCR'])
    fmu.set_value('MaxFrequencyDeviation', devs['grid']['frequency_delta_max'])

    ############################ Initial values ######################


    # fmu.set_variables(initials)
    fmu.set_value('SOC_init', initials['SOC_init'])
    fmu.set_value('c_cyc_init', initials['c_cyc_init'])
    fmu.set_value('c_cal_init', initials['c_cal_init'])
    fmu.set_value('T_init', initials['T_init'])

    if options['Charging_Stations']:
        for ev in range(48):
            fmu.set_value('SOC_init_EV[' + str(ev + 1) + ']', initials['SOC_init_ev'][ev])
            fmu.set_value('SOC_init_EV[' + str(ev + 1) + ']', 90.0)


    if options['Frequency_Control']:
        fmu.set_value('PrimaryControl', control_variables['PrimaryControl'][0])
    else:
        fmu.set_value('PrimaryControl', 0.0)


    fmu.set_value('PeakShavingON', control_variables['PeakShavingON'][0])
    fmu.set_value('SelfConsumptionON', control_variables['SelfConsumptionON'][0])
    fmu.set_value('PrimaryControlON', control_variables['PrimaryControlON'][0])
    fmu.set_value('PrimaryControl', control_variables['PrimaryControl'][0])


    fmu.initialize()

    # Define variables to be saved in simulations
    sim_out = {
        'P_PV_AC': [],
        'P_Load': [],
        'P_Grid': [],
        'P_Bat': [],
        'SOC_Bat': [],
        'V_Bat': [],
        'P_Bat_loss': [],
        'P_Bat_Bat_DC': [],
        'c_cal': [],
        'c_cyc': [],
        'T_Bat': [],
        'Frequency': [],
        'x_FCR_boolean': [],
        'P_Bat_FCR': [],
        'x_FCR2':[],
        'x_PeakShaving':[],
        'x_SelfConsumption':[],
        'PeakShaving_Ch':[],
        'PeakShaving_Dis':[],
        'SelfConsumption_Ch':[],
        'FCR_Ch':[],
        'FCR_Dis':[],



    }

    sim_out_ev = {
        'P_EV': [],
        'SOC_ev': {},
        'Available_ev': {},
        'P_ev': {}
    }
    for ev in range(48):
        sim_out_ev['SOC_ev'][ev] = []
        sim_out_ev['Available_ev'][ev] = []
        sim_out_ev['P_ev'][ev] = []


    # flag for while loop
    finished = False

    while not finished:

        cur_time_step = int((fmu.current_time-params['start_time']*3600)/(params['time_step']*3600))
        print('cur_time_step',cur_time_step)

        # Set control variables for simulation
        fmu.set_value('GridLimit', control_variables['GridLimit'])
        fmu.set_value('PeakShavingON', control_variables['PeakShavingON'][cur_time_step])
        fmu.set_value('SelfConsumptionON', control_variables['SelfConsumptionON'][cur_time_step])
        fmu.set_value('PrimaryControlON', control_variables['PrimaryControlON'][cur_time_step])
        fmu.set_value('PrimaryControl', control_variables['PrimaryControl'][cur_time_step])

        # read result at current time step
        results = fmu.read_variables(sim_out)

        # save sim results
        for out in sim_out:
            sim_out[out].append(results[out])

        # Set new grid limit if previous limit has been exceeded
        if min(sim_out['P_Grid']) <  control_variables['GridLimit']:
            control_variables['GridLimit'] = min(sim_out['P_Grid'])


        if options['Charging_Stations']:
            sim_out_ev['P_EV'].append(fmu.get_value('P_EV'))
            for ev in range(48):
                sim_out_ev['SOC_ev'][ev].append(fmu.get_value('SOC_ev[' + str(ev + 1) + ']'))
                sim_out_ev['Available_ev'][ev].append(fmu.get_value('Available_ev[' + str(ev + 1) + ']'))
                sim_out_ev['P_ev'][ev].append(fmu.get_value('P_ev[' + str(ev + 1) + ']'))

        # do step
        finished = fmu.do_step()

    # close fmu
    fmu.close()

    sim_out.update(sim_out_ev)
    return sim_out

if __name__ == '__main__':
    import numpy as np

    run_time = 24
    params = {
        'start_time':0 ,
        'control_horizon': run_time,
        'time_step': 0.25,
        'prediction_horizon': run_time
    }

    dir_name = "../../Results/Results_Bat125_PV2/8760_Hours_Bat125_PV2_WithDegWithFCRWithoutEV_StandardTariff"

    Only_SelfConsumption = False
    Only_PeakShaving = False
    Only_FCR = False

    SelfConsumptionAndPeakShaving = True
    WithFCR = True

    control_limits = {
        'SOC_max_PS': 90,
        'SOC_min_PS': 5,
        'SOC_max_SC': 90,
        'SOC_min_SC':15,
        'SOC_max_FCR':90,
        'SOC_min_FCR': 15
    }

    params_time_series = {'start_time':0 ,'control_horizon':8760,'time_step': 0.25, 'prediction_horizon':8760}

    devs = pickle.load(open(dir_name + '/devs.pkl', "rb"))
    options =  {'Charging_Stations': False,
                'Frequency_Control': True,
                'PV':{'PV_factor':2.0}}

    devs = pickle.load(open(dir_name + '/devs.pkl', "rb"))

    x_SelfConsumption = np.zeros(365 * 96)
    x_PeakShaving = np.zeros(365 * 96)


    if Only_SelfConsumption:
        x_SelfConsumption = [1.0 for x in range(run_time*4)]
    elif Only_PeakShaving:
        x_PeakShaving = [1.0 for x in range(run_time * 4)]
    elif SelfConsumptionAndPeakShaving:
        x_SelfConsumption = [0.0 for x in range(0,8640)]+[1.0 for x in range(8640,29184)]+[0.0 for x in range(29184,35040)]
        x_PeakShaving = [1.0 for x in range(0,8640)]+[0.0 for x in range(8640,29184)]+[1.0 for x in range(29184,35040)]


    # Calculate limits with percentage selection method: obtain the value of residual demand below which 99,0 % (98,0 %) of the electricity draws occur
    any_results = pickle.load(open("../../Results/Results_Bat125_PV2/8760_Hours_Bat125_PV2_WithDegWithFCRWithoutEV_StandardTariff"))
    residual = []

    for t in range(len(any_results['P_Load'])):
            residual.append(any_results['P_Load'][t]-any_results['P_PV_AC'][t])
    sorted_residual = sorted(residual[0:35040])
    P_grid_dem_max = -sorted_residual[int(round(len(sorted_residual) * 0.985))]

    # Control variables for FCR; 1.0: FCR offered, 0.0: no participation at FCR market
    if Only_FCR:
        x_FCR = np.zeros(365 * 96)
        for i in range(len(x_FCR)):
            x_FCR[i] = 1.0
    elif WithFCR == False:
        x_FCR = np.zeros(365 * 96)
    else:
        x_FCR_week_winter = []
        x_FCR_week_summer = []
        x_FCR_1_day = np.zeros(96)
        # set FCR products
        FCR_products = [1.0,0.0,0.0,0.0,0.0,1.0]
        # each product horizon of 4 h has 16 timesteps
        for i in range(len(FCR_products)):
            if FCR_products[i] == 1.0:
                for t in range(16):
                    x_FCR_1_day[i*16+t] = 1.0
        print('x_FCR_1_day',x_FCR_1_day)

        for a in range(5):
            # control variable for weekday in winter
            for i in range(96):
                x_FCR_week_winter.append(x_FCR_1_day[i])
        for a in range(2):
            # control variable for weekend in winter
            for i in range(96):
                x_FCR_week_winter.append(x_FCR_1_day[i])
        for a in range(7):
            # control variable for whole week in summer
            for i in range(96):
                x_FCR_week_summer.append(x_FCR_1_day[i])

        if Only_PeakShaving:
            # winter week for combination with peak shaving
            x_FCR = []
            for w in range(52):
                for i in range(672):
                    x_FCR.append(x_FCR_week_winter[i])
            for i in range(96):
                x_FCR.append(x_FCR_1_day[i])

        elif Only_SelfConsumption:
            # summer week for combination with self consumption
            x_FCR = []
            for w in range(52):
                for i in range(672):
                    x_FCR.append(x_FCR_week_summer[i])
            for i in range(96):
                x_FCR.append(x_FCR_1_day[i])

        elif SelfConsumptionAndPeakShaving:
            # both weesk for combination with self consumption and peak shaving
            x_FCR = []
            for w in range(13):
                for i in range(672):
                    x_FCR.append(x_FCR_week_winter[i])
            for w in range(30):
                for i in range(672):
                    x_FCR.append(x_FCR_week_summer[i])
            for w in range(9):
                for i in range(672):
                    x_FCR.append(x_FCR_week_winter[i])
            for i in range(96):
                x_FCR.append(x_FCR_1_day[i])

        print('len of x_FCR',len(x_FCR))


    # Create input for preparation of FCR, right SOC level has to be ensured in time
    x = []

    for i in range(int(len(x_FCR)-1)):
        if x_FCR[i] == 0.0 and x_FCR[i+1] == 1.0:
            x.append(1.0)
        else:
            x.append(0.0)

    x_FCR_Prepare = np.zeros(len(x))
    for i in range(len(x)):
        if x[i] == 1.0:
            x_FCR_Prepare[i-3] = 1.0
            x_FCR_Prepare[i - 2] = 1.0
            x_FCR_Prepare[i - 1] = 1.0
            x_FCR_Prepare[i - 0] = 1.0

    x_FCR_total = []
    for i in range(len(x_FCR)-1):
        if x_FCR[i] == 1.0 or x_FCR_Prepare[i] == 1.0:
            x_FCR_total.append(1.0)
        else:
            x_FCR_total.append(0.0)

    for i in range(len(x_FCR_total)):
        if x_FCR_total[i] == 1:
            x_SelfConsumption[i] = 0
            x_PeakShaving[i] = 0


    control_variables = {
        'GridLimit': P_grid_dem_max,
        'PeakShavingON':x_PeakShaving,
        'SelfConsumptionON':x_SelfConsumption,
        'PrimaryControlON': x_FCR_total,
        'PrimaryControl': x_FCR,
        }

    sim_results = run_sim(params,control_variables,options,control_limits)
    sim_results_file = dir_name + '/sim_results_Reference_OnlyPeakShavingAndSelfConsumption_985.pkl'
    pickle.dump(sim_results, open(sim_results_file, "wb"))

    plt.figure()
    plt.subplot(611)
    plt.plot(sim_results['P_Load'])
    plt.title('P_Load')

    plt.subplot(612)
    plt.plot(sim_results['P_Grid'])
    plt.plot('P_Grid')

    plt.subplot(613)
    plt.plot(sim_results['P_Bat'])
    plt.plot('P_Bat')

    plt.subplot(614)
    plt.plot(sim_results['SOC_Bat'])
    plt.title('SOC_Bat')

    plt.subplot(615)
    plt.plot(sim_results['x_PeakShaving'],'y')
    plt.plot(sim_results['x_SelfConsumption'],'r')
    plt.plot(sim_results['x_FCR2'],'b')

    plt.show()
