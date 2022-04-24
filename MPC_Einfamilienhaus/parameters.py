
import pandas as pd
import numpy as np
from math import *
import os
import devs_params
import simulation.simulate_PV as simulate_PV
import make_txt_from_time_series

def load_demands_and_time_series(options, start_time, devs, prediction_horizon, time_step, year, hour_of_year):
    #### Load demands from txt_files ####
    demand = {}
    demand["dem_elec"] = get_elec_demand_forecast(prediction_horizon, time_step, hour_of_year)  # Electricity demand in W
    demand["dem_e_mob"] = get_elec_mob_demand_forecast(prediction_horizon, time_step, hour_of_year)  # Electricity demand for electric vehicle in W
    demand["dem_dhw_m_flow"], demand["dem_dhw_T"] = get_dhw_demand_forecast(prediction_horizon, time_step, devs, hour_of_year)  # DHW mass flow in kg/s, Temperature in K

    time_series = {}
    time_series["ts_T_air"] = get_T_air_forecast(prediction_horizon, time_step, year, hour_of_year)  # Air temperature K
    time_series["ts_sol_rad"] = get_solar_radiation_forecast(prediction_horizon, time_step, year, hour_of_year)  # Solar radiation W/m²
    time_series["ts_win_spe"] = get_winSpe_forecast(prediction_horizon, time_step, year, hour_of_year)  # wind speed in m/s
    time_series["T_preTemRoof"], time_series["T_preTemFloor"], time_series["T_preTemWall"], time_series["T_preTemWin"] = get_T_preTem_forecast(prediction_horizon, time_step, year, hour_of_year)  # Corrected Temperature in K
    time_series["Q_solar_rad"], time_series["Q_solar_conv"] = get_Q_solar_win_forecast(prediction_horizon, time_step, year, hour_of_year)  # Corrected Temperature in K
    time_series["ts_T_inside_max"], time_series["ts_T_inside_min"] = get_T_inside(21 + 273.15, 3, 0.5, prediction_horizon, time_step, hour_of_year)  # Desried Inside Temperature in K with Night Offset
    time_series["ts_gains_human"], time_series["ts_gains_dev"], time_series["ts_gains_light"] = get_internal_gains(prediction_horizon, time_step, year, hour_of_year)  # Internal Gains (relative values)
    time_series["ts_powerPV"] = simulate_PV.run_PV_sim(start_time, prediction_horizon, time_step, 0.000001, options, devs["PV"], time_series["ts_T_air"], time_series["ts_sol_rad"], time_series["ts_win_spe"])
    if options["tariff"] == 2:
        time_series["ts_price_el"] = get_tariffs(0.346/1000, 0.03/1000, 6, 22, prediction_horizon, time_step, hour_of_year) # represents a simple HT/NT tariff
    if options["tariff"] == 3:
        time_series["ts_price_el"] = get_variable_tariff(prediction_horizon, time_step, year, hour_of_year)  # extracts stock market based data scaled for households
    if options["tariff"] == 1:
        time_series["ts_price_el"] = get_tariffs(0.346/1000, 0.00/1000, 6, 22, prediction_horizon, time_step, hour_of_year) # represents a classic tariff with single el. price
    return demand, time_series

def load_parameters(options, prediction_horizon, time_step):

    #### GENERAL PARAMETERS ####
    parameters = {
        "grid_limit_el": 15000, # W, limits electrical power from grid

        "T_supply_heat_min_heat": 273.15 + 25, # K
        "T_supply_heat_max_heat": 273.15 + 45, # K
        "T_supply_heat_min_cool": 273.15 + 42, # K
        "T_supply_heat_max_cool": 273.15 + 45, # K

        "price_el": 0.346/1000,  # €/Wh, electricity price
        "price_comfort_vio": 1000,  # €/K²h, sanctioned price for discomfort out of tolerance
        "feed_in_revenue_el": 0.064/1000,  # €/Wh, electricity feed in revenue
        "grid_CO2_emission": 0.503,  # t_CO2/MWh, specific CO2 emissions (grid)
        "c_f": 4180,  # J/(kg*K), fluid specific heat capacity
        "rho": 1000,  # kg/m3, fluid density
    }

    ##### LOAD BUILDING EQUIPMENT PARAMETERS ####
    devs = {}

    # HP/Heat pump
    devs["HP"] = {
        "COP_max": 1000,    # -, maximum heat pump COP, practical unlimited (as in simulation model)
        "cap": 7000,        # W, rated heating/cooling power
        "eta_COP": 0.3,     # -, so far dummy value
    }
    # Heating rod
    devs["rod"] = {
        "cap": 2000,  # W, maximum heating power
        "eta": 0.97,  # -, efficiency
    }
    # TES/DHW
    for device in ["TES", "DHW"]:
        devs[device] = {
            "sto_loss": 0.01,       # 1/h,      standby losses over one time step
            "k_loss": 0.0015,       # K/h, Energy loss
            "eta_ch": 0.99,         # -, charging efficiency
            "eta_dch": 0.99,        # -, discharging efficiency
            "t_min": 10 + 273.15,   # K  Min TES temperature
            "t_max": 60 + 273.15,   # K Max TES temperature
            "vol": 300,             # l, storage volume
            "d": 0.60,              # m, storage diameter
            "h": 1.06,              # m, storage height
        }
    # PV
    devs["PV"] = devs_params.load_PV_params(options["PV_type"])
    devs["PV"]["n_mod"] = int(options["roof_area"] / 2 / devs["PV"]["A_module"])
    devs["PV"]["area"] = 2 * devs["PV"]["n_mod"] * devs["PV"]["A_panel"]

    # BAT
    devs["BAT"] = devs_params.load_battery_params(options["battery_type"], options["battery_requested_capacity"])
    devs["BAT"]["nBat"] = (int(options["battery_requested_capacity"] * 1000 / devs["BAT"]["unit_cap"]) + 1)
    devs["BAT"]["cap"] = devs["BAT"]["nBat"] * devs["BAT"]["unit_cap"]

    ##### INITIAL PARAMETERS ####
    initials = {
        'T_Air': 18 + 273.15,  # K, Initial room temperature
        'T_supply': 30 + 273.15,  # K, Initial temperature of HP supply temperature
        'T_supply_HP': 30 + 273.15,  # K, Initial temperature of HP supply temperature
        'T_return': 30 + 273.15,  # K, Initial temperature of HP return temperature
        'T_supply_UFH': 30 + 273.15,  # K, Initial temperature of UFH supply temperature
        'T_return_UFH': 30 + 273.15,  # K, Initial temperature of UFH return temperature
        't_TES': 30 + 273.15,  # K, Initial DHW storage temperature
        't_DHW': 50.0 + 273.15,  # K, Initial DHW storage temperature
        'T_thermalCapacity_top': 25 + 273.15,  # K, Initial temperature of UFH capacities
        'T_thermalCapacity_down': 18 + 273.15,  # K, Initial temperature of UFH capacities
        'T_IntWall': 18 + 273.15,  # K, Initial temperature of walls and stuff
        'T_ExtWall': 18 + 273.15,  # K, Initial temperature of walls and stuff
        'T_Floor': 18 + 273.15,  # K, Initial temperature of walls and stuff
        'T_Roof': 18 + 273.15,  # K, Initial temperature of walls and stuff
        'T_Win': 18 + 273.15,  # K, Initial temperature of walls and stuff
        'T_TES_1': 30.0 + 273.15,  # K, Initial TES storage temperature
        'T_TES_2': 30.0 + 273.15,  # K, Initial TES storage temperature
        'T_TES_3': 30.0 + 273.15,  # K, Initial TES storage temperature
        'T_TES_4': 30.0 + 273.15,  # K, Initial TES storage temperature
        'T_HE_TES_1': 30.0 + 273.15,  # K, Initial TES storage temperature
        'T_HE_TES_2': 30.0 + 273.15,  # K, Initial TES storage temperature
        'T_HE_TES_3': 30.0 + 273.15,  # K, Initial TES storage temperature
        'T_HE_TES_4': 30.0 + 273.15,  # K, Initial TES storage temperature
        'T_DHW_1': 50.0 + 273.15,  # K, Initial TES storage temperature
        'T_DHW_2': 50.0 + 273.15,  # K, Initial TES storage temperature
        'T_DHW_3': 50.0 + 273.15,  # K, Initial TES storage temperature
        'T_DHW_4': 50.0 + 273.15,  # K, Initial TES storage temperature
        'T_HE_DHW_1': 50.0 + 273.15,  # K, Initial TES storage temperature
        'T_HE_DHW_2': 50.0 + 273.15,  # K, Initial TES storage temperature
        'T_HE_DHW_3': 50.0 + 273.15,  # K, Initial TES storage temperature
        'T_HE_DHW_4': 50.0 + 273.15,  # K, Initial TES storage temperature
        'soc_BAT': 0.30,  # - Initial state of charge of Bat
    }

    return parameters, devs, initials

def get_elec_demand_forecast(prediction_horizon, time_step, hour_of_year):
    file = open(os.path.join("input_data", "demands", "SumProfiles.Electricity.csv"), "rb")  # demand in kWh per minute
    res = 60 # data points per hour
    data = np.loadtxt(file, skiprows=hour_of_year*res+1, usecols=(0), unpack=True, max_rows=prediction_horizon*res) * 1000 * 60 # demand in W
    data1 = data.tolist()
    elec = []
    for t in range(int(prediction_horizon/time_step)):
        elec.append(np.mean(data1[int(t*time_step*res) : int(t*time_step*res+time_step*res)]))
    return elec

def get_elec_mob_demand_forecast(prediction_horizon, time_step, hour_of_year):
    file = open(os.path.join("input_data", "demands", "SumProfiles.Electricity for Car Charging.csv"), "rb")  # demand in kWh per minute
    res = 60  # data points per hour
    data = np.loadtxt(file, skiprows=hour_of_year * res + 1, usecols=(0), unpack=True, max_rows=prediction_horizon * res) * 1000 * 60  # demand in W
    data1 = data.tolist()
    emob = []
    for t in range(int(prediction_horizon/time_step)):
        emob.append(np.mean(data1[int(t*time_step*res) : int(t*time_step*res+time_step*res)]))
    return emob

def get_dhw_demand_forecast(prediction_horizon, time_step, devs, hour_of_year):
    file = open(os.path.join("input_data", "demands", "dhw.csv"), "rb") # demand in kg/s and K per minute
    res = 4  # data points per hour
    data = np.loadtxt(file, delimiter=",", skiprows=hour_of_year * res + 1, usecols=(1,2), unpack=True, max_rows=prediction_horizon * res) # demand in kg/s and K
    data1 = data[1].tolist()
    data2 = data[0].tolist()
    m_flow_DHW = []
    T_DHW = []
    for t in range(int(prediction_horizon / time_step)):
        m_flow_DHW.append(np.mean(data1[int(t*time_step*res) : int(t*time_step*res+time_step*res)]))
        T_DHW.append(np.mean(data2[int(t*time_step*res) : int(t*time_step*res+time_step*res)]))
    return m_flow_DHW, T_DHW

def get_internal_gains(prediction_horizon, time_step, year, hour_of_year):
    file = open(os.path.join("input_data", "InternalGains_hourly.txt"), "rb") # internal gains (relative values) per hour
    res = 1 # data points per hour
    data = np.loadtxt(file, delimiter="\t",  skiprows=2 + hour_of_year*res, usecols=(1,2,3), unpack=True, max_rows=prediction_horizon * res+1) # internal gains (relative values)
    if time_step == 1.0:
        schedule_human = data[0].tolist()
        schedule_human.pop()
        schedule_dev = data[1].tolist()
        schedule_dev.pop()
        schedule_light = data[2].tolist()
        schedule_light.pop()
    else:
        schedule_human = []
        schedule_dev = []
        schedule_light = []
        for t in range(int(prediction_horizon/time_step)):
            if t % (1/time_step) == 0:
                schedule_human.append(data[0][int(t*time_step)])
                schedule_dev.append(data[1][int(t*time_step)])
                schedule_light.append(data[2][int(t*time_step)])
            else:
                schedule_human.append(data[0][int(t*time_step)] + (data[0][int(t*time_step) + 1] - data[0][int(t*time_step)]) * (((t % (1 / time_step))*time_step)))
                schedule_dev.append(data[1][int(t*time_step)] + (data[1][int(t*time_step) + 1] - data[1][int(t*time_step)]) * (((t % (1 / time_step))*time_step)))
                schedule_light.append(data[2][int(t*time_step)] + (data[2][int(t*time_step) + 1] - data[2][int(t*time_step)]) * (((t % (1 / time_step))*time_step)))

    return schedule_human, schedule_dev, schedule_light

def get_variable_tariff(prediction_horizon, time_step, year, hour_of_year):
    file = open(os.path.join("input_data", "variable_tariff.txt"),"rb")  # costs €/kWh
    res = 1  # data points per hour
    data = np.loadtxt(file, delimiter="\t", skiprows=2 + hour_of_year * res, usecols=(1), unpack=True, max_rows=prediction_horizon * res + 1)/1000  # costs €/Wh
    if time_step == 1.0:
        costs = data.tolist()
        costs.pop()
    else:
        costs = []
        for t in range(int(prediction_horizon / time_step)):
            if t % (1 / time_step) == 0:
                costs.append(data[int(t * time_step)])
            else:
                costs.append(data[int(t * time_step)] + (
                            data[int(t * time_step) + 1] - data[int(t * time_step)]) * (
                                      ((t % (1 / time_step)) * time_step)))

    return costs


def get_T_air_forecast(prediction_horizon, time_step, year, hour_of_year):
    file = open(os.path.join("input_data", "Temperature_Berlin.csv"), "rb") # temperature in °C
    if year == "normal":
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year, usecols=(1), unpack=True, max_rows=prediction_horizon+1)
    elif year == "warm":
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year, usecols=(2), unpack=True, max_rows=prediction_horizon+1)
    elif year == "kalt":
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year, usecols=(3), unpack=True, max_rows=prediction_horizon+1)
    if time_step == 1.0:
        T_air = data.tolist()
        T_air.pop()
    else:
        T_air = []
        for t in range(int(prediction_horizon/time_step)):
            if t % (1/time_step) == 0:
                T_air.append(data[int(t*time_step)] +273.15)
            else:
                T_air.append(data[int(t*time_step)] + (data[int(t*time_step) + 1] - data[int(t*time_step)]) * (((t % (1 / time_step))*time_step)) +273.15)
    return T_air

def get_solar_radiation_forecast(prediction_horizon, time_step, year, hour_of_year):
    file = open(os.path.join("input_data", "Global_Radiation_Berlin.csv"), "rb") # radiation in Wh/m²
    if year == "normal":
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year, usecols=(1), unpack=True, max_rows=prediction_horizon+1)
    elif year == "warm":
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year, usecols=(2), unpack=True, max_rows=prediction_horizon+1)
    elif year == "kalt":
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year, usecols=(3), unpack=True, max_rows=prediction_horizon+1)
    if time_step == 1.0:
        sol_rad = data.tolist()
        sol_rad.pop()
    else:
        sol_rad = []
        for t in range(int(prediction_horizon/time_step)):
            if t % (1 / time_step) == 0:
                sol_rad.append(data[int(t*time_step)])
            else:
                sol_rad.append(data[int(t*time_step)] + (data[int(t * time_step) + 1] - data[int(t * time_step)]) * (((t % (1 / time_step))*time_step)))
    return sol_rad

def get_winSpe_forecast(prediction_horizon, time_step, year, hour_of_year):
    file = open(os.path.join("input_data", "Wind_Speed_Berlin.csv"), "rb") # in m/s
    if year == "normal":
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year, usecols=(1), unpack=True, max_rows=prediction_horizon+1)
    elif year == "warm":
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year, usecols=(2), unpack=True, max_rows=prediction_horizon+1)
    elif year == "kalt":
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year, usecols=(3), unpack=True, max_rows=prediction_horizon+1)
    if time_step == 1.0:
        winSpe = data.tolist()
        winSpe.pop()
    else:
        winSpe = []
        for t in range(int(prediction_horizon/time_step)):
            if t % (1/time_step) == 0:
                winSpe.append(data[int(t*time_step)])
            else:
                winSpe.append(data[int(t*time_step)] + (data[int(t*time_step) + 1] - data[int(t*time_step)]) * (((t % (1 / time_step))*time_step)))
    return winSpe


def get_Q_solar_win_forecast(prediction_horizon, time_step, year, hour_of_year):
    Qrad =[]
    Qconv =[]
    if year == "normal":
        file = open(os.path.join("input_data", "Q_solar_normal.csv"), "rb")  # Temperature in K
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year*4, usecols=(1,2,3,4,5), unpack=True, max_rows=prediction_horizon*4+1)
    elif year == "warm":
        file = open(os.path.join("input_data", "Q_solar_warm.csv"), "rb")  # Temperature in K
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year*4, usecols=(1,2,3,4,5), unpack=True, max_rows=prediction_horizon*4+1)
    elif year == "kalt":
        file = open(os.path.join("input_data", "Q_solar_kalt.csv"), "rb")  # Temperature in K
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year*4, usecols=(1,2,3,4,5), unpack=True, max_rows=prediction_horizon*4+1)
    datarad = []
    dataconv = data[4]
    for j in range(len(data[0])):
        datarad.append(sum(data[i][j] for i in [0,1,2,3]))
    if time_step == 1.0:
        for t in range(prediction_horizon):
            Qrad.append(np.mean(datarad[t * 4:(t * 4) + 4]))
            Qconv.append(np.mean(datarad[t * 4:(t * 4) + 4]))
    else:
        for t in range(int(prediction_horizon / time_step)):
            if t % ((1/time_step)/4) == 0:
                Qrad.append(datarad[int(t*time_step*4)])
                Qconv.append(dataconv[int(t*time_step*4)])
            else:
                Qrad.append(datarad[int(t*time_step*4)] + (datarad[int(t*time_step*4) + 1] - datarad[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
                Qconv.append(dataconv[int(t*time_step*4)] + (dataconv[int(t*time_step*4) + 1] - dataconv[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
    return Qrad, Qconv

def get_T_preTem_forecast(prediction_horizon, time_step, year, hour_of_year):
    T_preTemWin =[]
    T_preTemWall =[]
    T_preTemFloor =[]
    T_preTemRoof =[]
    if year == "normal":
        file = open(os.path.join("input_data", "T_pre_normal.csv"), "rb")  # Temperature in K
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year*4, usecols=(1,2,3,4), unpack=True, max_rows=prediction_horizon * 4+1)
    elif year == "warm":
        file = open(os.path.join("input_data", "T_pre_warm.csv"), "rb")  # Temperature in K
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year*4, usecols=(1,2,3,4), unpack=True, max_rows=prediction_horizon * 4+1)
    elif year == "kalt":
        file = open(os.path.join("input_data", "T_pre_kalt.csv"), "rb")  # Temperature in K
        data = np.loadtxt(file, delimiter=",", skiprows=1+hour_of_year*4, usecols=(1,2,3,4), unpack=True, max_rows=prediction_horizon * 4+1)
    data1 = data[0]
    data2 = data[1]
    data3 = data[2]
    data4 = data[3]
    if time_step == 1.0:
        for t in range(prediction_horizon):
            T_preTemRoof.append(np.mean(data1[t * 4:(t * 4) + 4]))
            T_preTemFloor.append(np.mean(data2[t * 4:(t * 4) + 4]))
            T_preTemWall.append(np.mean(data3[t * 4:(t * 4) + 4]))
            T_preTemWin.append(np.mean(data4[t * 4:(t * 4) + 4]))
    else:
        for t in range(int(prediction_horizon/time_step)):
            if t % ((1/time_step)/4) == 0:
                T_preTemRoof.append(data1[int(t*time_step*4)])
                T_preTemFloor.append(data2[int(t*time_step*4)])
                T_preTemWall.append(data3[int(t*time_step*4)])
                T_preTemWin.append(data4[int(t*time_step*4)])
            else:
                T_preTemRoof.append(data1[int(t*time_step*4)] + (data1[int(t*time_step*4) + 1] - data1[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
                T_preTemFloor.append(data2[int(t*time_step*4)] + (data2[int(t*time_step*4) + 1] - data2[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
                T_preTemWall.append(data3[int(t*time_step*4)] + (data3[int(t*time_step*4) + 1] - data3[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
                T_preTemWin.append(data4[int(t*time_step*4)] + (data4[int(t*time_step*4) + 1] - data4[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
    return T_preTemRoof, T_preTemFloor,T_preTemWall,T_preTemWin

def get_T_inside(TSetRoomConst, TOffNight, T_tol, prediction_horizon, time_step, hour_of_year):
    T_inside_min = []
    T_inside_max = []

    for t in range(prediction_horizon):
        if (hour_of_year+t)%24 < 8 or (hour_of_year+t)%24 >= 22:
            for k in range(int(1/time_step)):
                T_inside_min.append(TSetRoomConst - TOffNight)
                T_inside_max.append(TSetRoomConst - TOffNight + T_tol)
        else:
            for k in range(int(1 / time_step)):
                T_inside_max.append(TSetRoomConst)
                T_inside_min.append(TSetRoomConst - T_tol)
    return T_inside_max, T_inside_min

def get_tariffs(price_fixed, price_offset, hour_end, hour_begin, prediction_horizon, time_step, hour_of_year):
    price_kWh = []

    for t in range(prediction_horizon):
        if (hour_of_year+t)%24 < hour_end or (hour_of_year+t)%24 >= hour_begin:
            for k in range(int(1/time_step)):
                price_kWh.append(price_fixed - price_offset)
        else:
            for k in range(int(1 / time_step)):
                price_kWh.append(price_fixed + price_offset)
    return price_kWh










def get_testUFH(prediction_horizon, time_step, year, hour_of_year):
    T_supply =[]
    T_return =[]
    T_rad =[]
    T_room =[]

    file = open(os.path.join("input_data", "UFH_test.csv"), "rb")  # Temperature in K
    data = np.loadtxt(file, delimiter=",", skiprows=1, usecols=(1,2,3,4), unpack=True, max_rows=prediction_horizon*4+1)
    data1 = data[0]
    data2 = data[1]
    data3 = data[2]
    data4 = data[3]

    if time_step == 1.0:
        for t in range(prediction_horizon):
            T_supply.append(np.mean(data1[t * 4:(t * 4) + 4]))
            T_return.append(np.mean(data2[t * 4:(t * 4) + 4]))
            T_rad.append(np.mean(data3[t * 4:(t * 4) + 4]))
            T_room.append(np.mean(data4[t * 4:(t * 4) + 4]))
    else:
        for t in range(int(prediction_horizon / time_step)):
            if t % ((1/time_step)/4) == 0:
                T_supply.append(data1[int(t*time_step*4)])
                T_return.append(data2[int(t*time_step*4)])
                T_rad.append(data3[int(t*time_step*4)])
                T_room.append(data4[int(t*time_step*4)])
            else:
                T_supply.append(data1[int(t*time_step*4)] + (data1[int(t*time_step*4) + 1] - data1[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
                T_return.append(data2[int(t*time_step*4)] + (data2[int(t*time_step*4) + 1] - data2[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
                T_rad.append(data3[int(t*time_step*4)] + (data3[int(t*time_step*4) + 1] - data3[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
                T_room.append(data4[int(t*time_step*4)] + (data4[int(t*time_step*4) + 1] - data4[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))

    return T_supply, T_return, T_rad, T_room

def get_Qpanel(prediction_horizon, time_step, year, hour_of_year):

    Seg1 =[]
    Seg2 =[]

    file = open(os.path.join("input_data", "thermCond.csv"), "rb")  # Temperature in K
    data = np.loadtxt(file, delimiter=",", skiprows=1, usecols=(1,2,3), unpack=True, max_rows=prediction_horizon*4+1)
    data3 = data[1]
    data4 = data[2]

    if time_step == 1.0:
        for t in range(prediction_horizon):
            Seg1.append(np.mean(data3[t * 4:(t * 4) + 4]))
            Seg2.append(np.mean(data4[t * 4:(t * 4) + 4]))
    else:
        for t in range(int(prediction_horizon / time_step)):
            if t % ((1/time_step)/4) == 0:
                Seg1.append(data3[int(t*time_step*4)])
                Seg2.append(data4[int(t*time_step*4)])
            else:
                Seg1.append(data3[int(t*time_step*4)] + (data3[int(t*time_step*4) + 1] - data3[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
                Seg2.append(data4[int(t*time_step*4)] + (data4[int(t*time_step*4) + 1] - data4[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))

    return Seg1, Seg2

def get_QUFH(prediction_horizon, time_step, year, hour_of_year):
    Rad =[]
    Conv =[]

    file = open(os.path.join("input_data", "Q_UFH.csv"), "rb")  # Temperature in K
    data = np.loadtxt(file, delimiter=",", skiprows=1, usecols=(1,2), unpack=True, max_rows=prediction_horizon*4+1)
    data3 = data[1]
    data4 = data[0]

    if time_step == 1.0:
        for t in range(prediction_horizon):
            Rad.append(np.mean(data3[t * 4:(t * 4) + 4]))
            Conv.append(np.mean(data4[t * 4:(t * 4) + 4]))
    else:
        for t in range(int(prediction_horizon / time_step)):
            if t % ((1/time_step)/4) == 0:
                Rad.append(data3[int(t*time_step*4)])
                Conv.append(data4[int(t*time_step*4)])
            else:
                Rad.append(data3[int(t*time_step*4)] + (data3[int(t*time_step*4) + 1] - data3[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
                Conv.append(data4[int(t*time_step*4)] + (data4[int(t*time_step*4) + 1] - data4[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))

    return Conv, Rad

def get_Tpanel(prediction_horizon, time_step, year, hour_of_year):
    TCapa1 =[]
    TCapa2 =[]
    T_UFH =[]
    file = open(os.path.join("input_data", "T_Panel.csv"), "rb")  # Temperature in K
    data = np.loadtxt(file, delimiter=",", skiprows=1, usecols=(1,2,3), unpack=True, max_rows=prediction_horizon*4+1)
    data1 = data[0]
    data2 = data[1]
    data3 = data[2]

    if time_step == 1.0:
        for t in range(prediction_horizon):
            TCapa1.append(np.mean(data1[t * 4:(t * 4) + 4]))
            TCapa2.append(np.mean(data2[t * 4:(t * 4) + 4]))
            T_UFH.append(np.mean(data3[t * 4:(t * 4) + 4]))
    else:
        for t in range(int(prediction_horizon / time_step)):
            if t % ((1/time_step)/4) == 0:
                TCapa1.append(data1[int(t*time_step*4)])
                TCapa2.append(data2[int(t*time_step*4)])
                T_UFH.append(data3[int(t*time_step*4)])
            else:
                TCapa1.append(data1[int(t*time_step*4)] + (data1[int(t*time_step*4) + 1] - data1[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
                TCapa2.append(data2[int(t*time_step*4)] + (data2[int(t*time_step*4) + 1] - data2[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
                T_UFH.append(data3[int(t*time_step*4)] + (data3[int(t*time_step*4) + 1] - data3[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
    return TCapa1, TCapa2, T_UFH

def get_QBoden(prediction_horizon, time_step, year, hour_of_year):
    Qboden =[]
    file = open(os.path.join("input_data", "Q_Boden.csv"), "rb")  # Temperature in K
    data = np.loadtxt(file, delimiter=",", skiprows=1, usecols=(1), unpack=True, max_rows=prediction_horizon*4+1)
    if time_step == 1.0:
        for t in range(prediction_horizon):
            Qboden.append(np.mean(data[t * 4:(t * 4) + 4]))
    else:
        for t in range(int(prediction_horizon / time_step)):
            if t % ((1/time_step)/4) == 0:
                Qboden.append(data[int(t*time_step*4)])
            else:
                Qboden.append(data[int(t*time_step*4)] + (data[int(t*time_step*4) + 1] - data[int(t*time_step*4)]) * (t % ((1/time_step)/4)) / ((1/time_step)/4))
    return Qboden





