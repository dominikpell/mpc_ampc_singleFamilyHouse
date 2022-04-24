import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import os
import plotly.express as px
import pandas as pd
import json
import parameters
import make_txt_from_time_series

MPC_horizon = 350*24  # hours (days)
prediction_horizon = 8750  # hours
control_horizon = 1.0  # hours
time_step = 15/60  # hours
year = "warm"  # alternatives: "warm"=warm, "kalt"=cold, "normal"=normal
date = '2015-01-01'  # Set point: when does the MPC begin

day_of_year = pd.Timestamp(date).day_of_year
hour_of_year = (day_of_year - 1) * 24
start_time = hour_of_year * 3600

"""Define options and some additional overall parameters"""
options = {
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
    "tariff": 1,
    # alternatives: 1:fixed, 2:TimeOfUse
}

# Load overall parameters and input data for first iteration
params, devs, initials = parameters.load_parameters(options, prediction_horizon, time_step)  # initials only for current time steps
demand, time_series = parameters.load_demands_and_time_series(options, start_time, devs,
                                                                          prediction_horizon, time_step,
                                                                          year, int(hour_of_year))


make_txt_from_time_series.make_txt(str(os.path.dirname(os.path.realpath(__file__))), demand["dem_dhw_T"], "dem_dhw_T" + "_long")



import matplotlib
# plot settings
# matplotlib.rcParams['mathtext.fontset'] = 'custom'
# matplotlib.rcParams['mathtext.rm'] = 'Bitstream Vera Sans'
# matplotlib.rcParams['mathtext.it'] = 'Bitstream Vera Sans:italic'
# matplotlib.rcParams['mathtext.bf'] = 'Bitstream Vera Sans:bold'
#
# matplotlib.rcParams['mathtext.fontset'] = 'stix'
# matplotlib.rcParams['font.family'] = 'STIXGeneral'
# matplotlib.rcParams['font.size'] = 9
# matplotlib.rcParams['lines.linewidth'] = 0.75
# matplotlib.rcParams['savefig.dpi'] = 200
# matplotlib.rcParams['figure.dpi'] = 200

# file_format = 'pgf'
# if file_format == 'pgf':
#     matplotlib.use("pgf")
#     matplotlib.rcParams.update({
#         "pgf.texsystem": "pdflatex",
#         'text.usetex': True,
#         'pgf.rcfonts': False,
#     })

# =====================================================================================================================
#                                               Imports
# =====================================================================================================================
#Locale settings
# import locale
# # Set to German locale to get comma decimal separater
# locale.setlocale(locale.LC_NUMERIC, "de_DE")
# import pathlib
# # import matplotlib
# # matplotlib.use("pgf")
# import matplotlib
# import matplotlib.pyplot as plt
# plt.rcdefaults()
# from matplotlib import font_manager
#
# import tikzplotlib as tkz
# import pandas as pd
# from ebcpy import TimeSeriesData as tsd
# import numpy as np
#
# def main(
#
# ):
#
#     unterordner = "results_hp_set_point_temp_water"
#     dat1 = pd.read_csv(pathlib.Path(__file__).parent.joinpath(unterordner, "Results for Simulation set_point_temp_water_=50 dict.csv"), sep=',', skiprows=[1, 2])
#     dat2 = pd.read_csv(pathlib.Path(__file__).parent.joinpath(unterordner, "Results for Simulation set_point_temp_water_=60 dict.csv"), sep=',', skiprows=[1, 2])
#     dat3 = pd.read_csv(pathlib.Path(__file__).parent.joinpath(unterordner, "Results for Simulation set_point_temp_water_=70 dict.csv"), sep=',', skiprows=[1, 2])
#     dat4 = pd.read_csv(pathlib.Path(__file__).parent.joinpath(unterordner, "Results for Simulation set_point_temp_water_=80 dict.csv"), sep=',', skiprows=[1, 2])
#     #dat5 = pd.read_csv(pathlib.Path(__file__).parent.joinpath(unterordner, "Results for Simulation set_point_temp_water_=80 dict.csv"), sep=',', skiprows=[1, 2])
#
#     """
#     plt.rcParams['axes.formatter.use_locale'] = True
#     ax=plt.gca()
#     """
#     parameter1="thPowerHP"
#     parameter2="COP_HP"
#     parameter3="ExEfficiencyHP_waterSide"
#
#     labels = ["zeroth_entry", "$T_\mathrm{VL}=50 \mathrm{°C}$", "$T_\mathrm{VL}=60 \mathrm{°C}$",
#               "$T_\mathrm{VL}=70 \mathrm{°C}$", "$T_\mathrm{VL}=80 \mathrm{°C}$"]
#
#     x=dat1.iloc[2:, 0]
#     print("this is x:", x)
#     dict1={}
#
#     dict1[1] = dat1.loc[2:, parameter1]
#     dict1[2] = dat2.loc[2:, parameter1]
#     dict1[3] = dat3.loc[2:, parameter1]
#     dict1[4] = dat4.loc[2:, parameter1]
#     #dict[5] = dat5.loc[2:, parameter1]
#
#     dict2={}
#
#     dict2[1] = dat1.loc[2:, parameter2]
#     dict2[2] = dat2.loc[2:, parameter2]
#     dict2[3] = dat3.loc[2:, parameter2]
#     dict2[4] = dat4.loc[2:, parameter2]
#     #dict[5] = dat5.loc[2:, parameter2]
#
#     dict3={}
#
#     dict3[1] = dat1.loc[2:, parameter3]
#     dict3[2] = dat2.loc[2:, parameter3]
#     dict3[3] = dat3.loc[2:, parameter3]
#     dict3[4] = dat4.loc[2:, parameter3]
#     #dict[5] = dat5.loc[2:, parameter3]
#
#     z1=[]
#     for i in range(2, 179):
#         z1.append(x[i])
#
#     stop_time = z1[-1]
#     val_seconds = np.around(np.arange(0, stop_time + 60, 900), 0).tolist()
#     z2 = np.around(np.arange(0, (stop_time + 60) / 3600, 0.25), 2).tolist()
#
#     val_hours=[]
#     for i in range(len(z2)):
#         val_hours.append('{:n}'.format(z2[i]))
#
#     matplotlib.rcParams['mathtext.fontset'] = 'stix'
#     matplotlib.rcParams['font.family'] = 'STIXGeneral'
#     plt.rcParams['axes.formatter.use_locale'] = True
#     plt.rc('font', size=11)
# # ------ parameter 1 -------
#     plt.figure(figsize=(3.05, 2.288), tight_layout=True)
#
#     plt.plot(x, dict1[1], label=labels[1])
#     plt.plot(x, dict1[2], label=labels[2])
#     plt.plot(x, dict1[3], label=labels[3])
#     plt.plot(x, dict1[4], label=labels[4])
#     #plt.plot(x, dict[5], label="$T_\mathrm{VL}=80\mathrm{°C}$")
#
#     plt.xticks(val_seconds, val_hours)
#     plt.yticks([3800, 4000, 4200, 4400], ["3,8", "4,0", "4,2", "4,4"])
#     plt.grid()
#     plt.legend(loc=3, prop={'size': 8}, labelspacing=0.1)
#     plt.axis([0, None, 3800, 4400])
#     plt.xlabel("Zeit [h]")
#     plt.ylabel('$\dot{Q}_\mathrm{nutz} [kW]$')
#     plt.savefig(pathlib.Path(__file__).parent.joinpath("t_vl_" + parameter1 + ".pdf"), bbox_inches = 'tight', pad_inches = 0.01)
#     plt.show()
#
# # ----- parameter 2 ------
#     plt.figure(figsize=(3.05, 2.288), tight_layout=True)
#
#     plt.plot(x, dict2[1], label=labels[1])
#     plt.plot(x, dict2[2], label=labels[2])
#     plt.plot(x, dict2[3], label=labels[3])
#     plt.plot(x, dict2[4], label=labels[4])
#     # plt.plot(x, dict[5], label="$T_\mathrm{VL}=80\mathrm{°C}$")
#
#     plt.xticks(val_seconds, val_hours)
#     plt.grid()
#     # plt.legend(loc=3, prop={'size': 8}, labelspacing=0.1)
#     plt.axis([0, None, 2, 3])
#     plt.xlabel("Zeit [h]")
#     plt.ylabel('COP [-]')
#     plt.savefig(pathlib.Path(__file__).parent.joinpath("t_vl_" + parameter2 + ".pdf"), bbox_inches = 'tight', pad_inches = 0.01)
#     plt.show()
#
# # --------parameter 3 -----------
#     plt.figure(figsize=(3.05, 2.288), tight_layout=True)
#
#     plt.plot(x, dict3[1], label=labels[1])
#     plt.plot(x, dict3[2], label=labels[2])
#     plt.plot(x, dict3[3], label=labels[3])
#     plt.plot(x, dict3[4], label=labels[4])
#     # plt.plot(x, dict[5], label="$T_\mathrm{VL}=80\mathrm{°C}$")
#
#     plt.xticks(val_seconds, val_hours)
#     # plt.yticks([2500, 5000, 7500], ["2,5", "5", "7,5"])
#     plt.grid()
#     # plt.legend(loc=3, prop={'size': 8}, labelspacing=0.1)
#     plt.axis([0, None, 0.47, 0.495])
#     plt.xlabel("Zeit [h]")
#     plt.ylabel('$\eta_\mathrm{ex,WP}$')
#     plt.savefig(pathlib.Path(__file__).parent.joinpath("t_vl_" + parameter3 + ".pdf"), bbox_inches = 'tight', pad_inches = 0.01)
#     plt.show()
#
#
#
# if __name__ == '__main__':
#     main(
#     )
