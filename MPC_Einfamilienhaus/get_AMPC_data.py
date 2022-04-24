import pandas as pd
import os
def load_pred(demands, time_series, hour):
    control_var = {}
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
              "ts_T_inside_max", "ts_T_inside_min"]:
        control_var[i] = []

    for key in ["ch_BAT", "ch_DHW", "ch_TES", "dch_TES",
                "heat_rod", "power_use_BAT", "power_to_grid_BAT",
                "PV_Distr_FeedIn", "PV_Distr_ChBat",
                "t_DHW", "t_TES", "T_supply_HP_heat", "T_supply_UFH", "x_HP_heat"]:
        data = pd.read_excel(os.path.join(os.path.dirname(os.path.realpath(__file__)), "Results", key+"_set", "noForecasts_RF_2w_100/Predictions/FinalBaye", "Prediction_rf_predictor_FinalBaye.xlsx"), usecols="B",header=None)
        # print(data.iloc[1, 0])
        # print(data)
        for t in range(5):
            control_var[key].append(data.iloc[1+t+int(hour*4), 0])
        # print(control_var[key])
    for key in demands.keys():
        for t in range(5):
            control_var[key].append(demands[key][t])
    for key in ["ts_T_air", "ts_win_spe", "ts_sol_rad",
                "ts_gains_human", "ts_gains_dev", "ts_gains_light",
                "ts_T_inside_max", "ts_T_inside_min"]:
        for t in range(5):
            control_var[key].append(time_series[key][t])

    control_var["x_HP_on"] = control_var["x_HP_heat"]
    control_var["x_HP_cool"] = [0,0,0,0,0]
    control_var["T_supply_cool"] = [290,290,290,290,290]
    for t in range(5):
        control_var["PV_Distr_Use"].append(1-(control_var["PV_Distr_FeedIn"][t]+control_var["PV_Distr_ChBat"][t]))

    return control_var