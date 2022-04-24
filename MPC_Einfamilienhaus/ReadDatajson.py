import json
import pandas as pd
import csv

with open(r'D:\01_Modellierung\master-thesis\AMPC_Training_Data\ampc_training_file_week2.json', 'r') as f:
    data = json.load(f)
#print(data)

#df = pd.read_json(r'D:\01_Modellierung\master-thesis\AMPC_Training_Data\ampc_training_file_week1.json')
#df.to_csv(r'D:\01_Modellierung\master-thesis\AMPC_Training_Data\ampc_training_file_week1.csv')
#f = csv.writer(open(r"D:\01_Modellierung\master-thesis\AMPC_Training_Data\test.csv", "wb+"))
#f.writerow(["pk", "model", "codename", "name", "content_type"])

#Forecast
Q_solar_conv = pd.DataFrame(data["opti"]["forecast"]["Q_solar_conv"])
Q_solar_rad = pd.DataFrame(data["opti"]["forecast"]["Q_solar_rad"])
T_preTemFloor = pd.DataFrame(data["opti"]["forecast"]["T_preTemFloor"])
T_preTemRoof = pd.DataFrame(data["opti"]["forecast"]["T_preTemRoof"])
T_preTemWall = pd.DataFrame(data["opti"]["forecast"]["T_preTemWall"])
T_preTemWin = pd.DataFrame(data["opti"]["forecast"]["T_preTemWin"])
dem_dhw_T = pd.DataFrame(data["opti"]["forecast"]["dem_dhw_T"])
dem_dhw_m_flow = pd.DataFrame(data["opti"]["forecast"]["dem_dhw_m_flow"])
dem_e_mob = pd.DataFrame(data["opti"]["forecast"]["dem_e_mob"])
dem_elec = pd.DataFrame(data["opti"]["forecast"]["dem_elec"])
ts_T_air = pd.DataFrame(data["opti"]["forecast"]["ts_T_air"])
ts_T_inside_max = pd.DataFrame(data["opti"]["forecast"]["ts_T_inside_max"])
ts_T_inside_min = pd.DataFrame(data["opti"]["forecast"]["ts_T_inside_min"])
ts_gains_dev = pd.DataFrame(data["opti"]["forecast"]["ts_gains_dev"])
ts_gains_human = pd.DataFrame(data["opti"]["forecast"]["ts_gains_human"])
ts_gains_light = pd.DataFrame(data["opti"]["forecast"]["ts_gains_light"])
ts_powerPV = pd.DataFrame(data["opti"]["forecast"]["ts_powerPV"])
ts_sol_rad = pd.DataFrame(data["opti"]["forecast"]["ts_sol_rad"])
ts_win_spe = pd.DataFrame(data["opti"]["forecast"]["ts_win_spe"])

#Initials
T_Air_init = pd.DataFrame(data["opti"]["initials"]["T_Air"])

#DHW
T_DHW_1_init = pd.DataFrame(data["opti"]["initials"]["T_DHW_1"])
T_DHW_2_init = pd.DataFrame(data["opti"]["initials"]["T_DHW_2"])
T_DHW_3_init = pd.DataFrame(data["opti"]["initials"]["T_DHW_3"])
T_DHW_4_init = pd.DataFrame(data["opti"]["initials"]["T_DHW_4"])

T_HE_DHW_1_init = pd.DataFrame(data["opti"]["initials"]["T_HE_DHW_1"])
T_HE_DHW_2_init = pd.DataFrame(data["opti"]["initials"]["T_HE_DHW_2"])
T_HE_DHW_3_init = pd.DataFrame(data["opti"]["initials"]["T_HE_DHW_3"])
T_HE_DHW_4_init = pd.DataFrame(data["opti"]["initials"]["T_HE_DHW_4"])

#TES
T_TES_1_init = pd.DataFrame(data["opti"]["initials"]["T_TES_1"])
T_TES_2_init = pd.DataFrame(data["opti"]["initials"]["T_TES_2"])
T_TES_3_init = pd.DataFrame(data["opti"]["initials"]["T_TES_3"])
T_TES_4_init = pd.DataFrame(data["opti"]["initials"]["T_TES_4"])

T_HE_TES_1_init = pd.DataFrame(data["opti"]["initials"]["T_HE_TES_1"])
T_HE_TES_2_init = pd.DataFrame(data["opti"]["initials"]["T_HE_TES_2"])
T_HE_TES_3_init = pd.DataFrame(data["opti"]["initials"]["T_HE_TES_3"])
T_HE_TES_4_init = pd.DataFrame(data["opti"]["initials"]["T_HE_TES_4"])

T_IntWall_init = pd.DataFrame(data["opti"]["initials"]["T_IntWall"])
T_Roof_init = pd.DataFrame(data["opti"]["initials"]["T_Roof"])
T_ExtWall_init = pd.DataFrame(data["opti"]["initials"]["T_ExtWall"])
T_Floor_init = pd.DataFrame(data["opti"]["initials"]["T_Floor"])
T_Win_init = pd.DataFrame(data["opti"]["initials"]["T_Win"])
T_return_init = pd.DataFrame(data["opti"]["initials"]["T_return"])
T_return_UFH_init = pd.DataFrame(data["opti"]["initials"]["T_return_UFH"])

T_supply_init = pd.DataFrame(data["opti"]["initials"]["T_supply"])
T_supply_HP_init = pd.DataFrame(data["opti"]["initials"]["T_supply_HP"])
T_supply_UFH_init = pd.DataFrame(data["opti"]["initials"]["T_supply_UFH"])
T_thermalCapacity_down_init = pd.DataFrame(data["opti"]["initials"]["T_thermalCapacity_down"])
T_thermalCapacity_top_init = pd.DataFrame(data["opti"]["initials"]["T_thermalCapacity_top"])

#soc_BAT_init = pd.DataFrame(data["opti"]["initials"]["soc_BAT"])
#gemittelte Speichertemps
#t_DHW_init = pd.DataFrame(data["opti"]["initials"]["t_DHW"])
#t_TES_init = pd.DataFrame(data["opti"]["initials"]["t_TES"])

#Q_conv_UFH_init = pd.DataFrame(data["opti"]["outs_all_states_opti"]["Q_conv_UFH"])
#T_Air_init = pd.DataFrame(data["opti"]["outs_all_states_opti"]["T_Air"])
#Q_rad_UFH_init = pd.DataFrame(data["opti"]["outs_all_states_opti"]["Q_rad_UFH"])

#Outputs measurement sim
#Dopplungen mit initials wurden nicht 2x berücksichtigt
#T_panel_heating1 = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["T_panel_heating1"])
#ch_BAT = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["ch_BAT"])
#ch_DHW = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["ch_DHW"])
#ch_TES = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["ch_TES"])
#Abweichung von Raumtemperatur
#dT_vio = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["dT_vio"])
#dch_BAT = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["dch_BAT"])
#dch_DHW = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["dch_DHW"])
#dch_TES = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["dch_TES"])
#heat_HP = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["heat_HP"])
#heat_rod = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["heat_rod"])
#power_HP = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["power_HP"])
#power_PV = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["power_PV"])
#power_from_grid = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["power_from_grid"])
#power_rod = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["power_rod"])
#power_to_BAT_PV = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["power_to_BAT_PV"])
#power_to_BAT_from_grid = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["power_to_BAT_from_grid"])
#power_to_grid = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["power_to_grid"])
#power_to_grid_BAT = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["power_to_grid_BAT"])
#power_to_grid_PV = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["power_to_grid_PV"])
#power_use_BAT = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["power_use_BAT"])
#power_use_PV = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["power_use_PV"])
#Strombedarf HP und HR
#res_elec = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["res_elec"])
#soc_BAT = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["soc_BAT"])
#t_DHW = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["t_DHW"])
#t_TES = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["t_TES"])
#t_rad = pd.DataFrame(data["sim_out"]["outs_all_states_sim"]["t_rad"])


# Outputs opti for sim
#PV_Distr_ChBat_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["PV_Distr_ChBat"])
#PV_Distr_FeedIn_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["PV_Distr_FeedIn"])
#PV_Distr_Use_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["PV_Distr_Use"])
#T_supply_HP_heat_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["T_supply_HP_heat"])
#T_supply_UFH_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["T_supply_UFH"])
#T_supply_cool_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["T_supply_cool"])
#ch_BAT_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["ch_BAT"])
#ch_DHW_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["ch_DHW"])
#ch_TES_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["ch_TES"])
#dch_TES_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["dch_TES"])
#heat_rod_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["heat_rod"])
#power_to_grid_BAT_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["power_to_grid_BAT"])
#power_use_BAT_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["power_use_BAT"])
#t_DHW_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["t_DHW"])
#t_TES_set = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["t_TES"])
#Generell an oder nicht Heiz-Kühlmodus
#x_HP_heat = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["x_HP_heat"])
#x_HP_cool = pd.DataFrame(data["opti"]["outs_controls_for_sim"]["x_HP_cool"])
#df= pd.DataFrame
df_opti = pd.DataFrame({'x_HP_on':data["opti"]["outs_controls_for_sim"]["x_HP_on"],
                   'x_HP_cool':data["opti"]["outs_controls_for_sim"]["x_HP_cool"],
                   'x_HP_heat': data["opti"]["outs_controls_for_sim"]["x_HP_heat"],
                   't_TES_set': data["opti"]["outs_controls_for_sim"]["t_TES"],
                   't_DHW_set': data["opti"]["outs_controls_for_sim"]["t_DHW"],
                   'power_use_BAT_set': data["opti"]["outs_controls_for_sim"]["power_use_BAT"],
                   'power_to_grid_BAT_set': data["opti"]["outs_controls_for_sim"]["power_to_grid_BAT"],
                   'heat_rod_set': data["opti"]["outs_controls_for_sim"]["heat_rod"],
                   'dch_TES_set': data["opti"]["outs_controls_for_sim"]["dch_TES"],
                   'ch_TES_set': data["opti"]["outs_controls_for_sim"]["ch_TES"],
                   'ch_DHW_set': data["opti"]["outs_controls_for_sim"]["ch_DHW"],
                   'ch_BAT_set': data["opti"]["outs_controls_for_sim"]["ch_BAT"],
                   'T_supply_cool_set': data["opti"]["outs_controls_for_sim"]["T_supply_cool"],
                   'T_supply_UFH_set': data["opti"]["outs_controls_for_sim"]["T_supply_UFH"],
                   'T_supply_HP_heat_set': data["opti"]["outs_controls_for_sim"]["T_supply_HP_heat"],
                   'PV_Distr_Use_set': data["opti"]["outs_controls_for_sim"]["PV_Distr_Use"],
                   'PV_Distr_FeedIn_set': data["opti"]["outs_controls_for_sim"]["PV_Distr_FeedIn"],
                   'PV_Distr_ChBat_set': data["opti"]["outs_controls_for_sim"]["PV_Distr_ChBat"],
                    'Q_conv_UFH_init': data["opti"]["outs_all_states_opti"]["Q_conv_UFH"],
                    'T_Air_opti_init': data["opti"]["outs_all_states_opti"]["T_Air"],
                    'Q_rad_UFH_init': data["opti"]["outs_all_states_opti"]["Q_rad_UFH"],
                    'T_Air_init': data["opti"]["initials"]["T_Air"],
                    'T_DHW_1_init': data["opti"]["initials"]["T_DHW_1"],
                    'T_DHW_2_init': data["opti"]["initials"]["T_DHW_2"],
                    'T_DHW_3_init': data["opti"]["initials"]["T_DHW_3"],
                    'T_DHW_4_init': data["opti"]["initials"]["T_DHW_4"],
                    'T_TES_1_init': data["opti"]["initials"]["T_TES_1"],
                    'T_TES_2_init': data["opti"]["initials"]["T_TES_2"],
                    'T_TES_3_init': data["opti"]["initials"]["T_TES_3"],
                    'T_TES_4_init': data["opti"]["initials"]["T_TES_4"],
                    'T_IntWall_init': data["opti"]["initials"]["T_IntWall"],
                    'T_Roof_init': data["opti"]["initials"]["T_Roof"],
                    'T_ExtWall_init': data["opti"]["initials"]["T_ExtWall"],
                    'T_Floor_init': data["opti"]["initials"]["T_Floor"],
                    'T_Win_init': data["opti"]["initials"]["T_Win"],
                    'T_return_init': data["opti"]["initials"]["T_return"],
                    'T_return_UFH_init': data["opti"]["initials"]["T_return_UFH"],
                    'T_supply_init': data["opti"]["initials"]["T_supply"],
                    'T_supply_HP_init': data["opti"]["initials"]["T_supply_HP"],
                    'T_supply_UFH_init': data["opti"]["initials"]["T_supply_UFH"],
                    'T_thermalCapacity_down_init': data["opti"]["initials"]["T_thermalCapacity_down"],
                    'T_thermalCapacity_top_init': data["opti"]["initials"]["T_thermalCapacity_top"]
                   })
df_sim = pd.DataFrame({
                   't_rad': data["sim_out"]["outs_all_states_sim"]["t_rad"],
                   't_TES': data["sim_out"]["outs_all_states_sim"]["t_TES"],
                   't_DHW': data["sim_out"]["outs_all_states_sim"]["t_DHW"],
                   'soc_BAT': data["sim_out"]["outs_all_states_sim"]["soc_BAT"],
                    'res_elec': data["sim_out"]["outs_all_states_sim"]["res_elec"],
                    'power_use_PV': data["sim_out"]["outs_all_states_sim"]["power_use_PV"],
                    'power_use_BAT': data["sim_out"]["outs_all_states_sim"]["power_use_BAT"],
                    'power_to_grid_PV': data["sim_out"]["outs_all_states_sim"]["power_to_grid_PV"],
                    'power_to_grid_BAT': data["sim_out"]["outs_all_states_sim"]["power_to_grid_BAT"],
                    'power_to_grid': data["sim_out"]["outs_all_states_sim"]["power_to_grid"],
                    'power_to_BAT_from_grid': data["sim_out"]["outs_all_states_sim"]["power_to_BAT_from_grid"],
                    'power_to_BAT_PV': data["sim_out"]["outs_all_states_sim"]["power_to_BAT_PV"],
                    'power_rod': data["sim_out"]["outs_all_states_sim"]["power_rod"],
                    'power_from_grid': data["sim_out"]["outs_all_states_sim"]["power_from_grid"],
                    'power_PV': data["sim_out"]["outs_all_states_sim"]["power_PV"],
                    'power_HP': data["sim_out"]["outs_all_states_sim"]["power_HP"],
                    'heat_rod': data["sim_out"]["outs_all_states_sim"]["heat_rod"],
                    'heat_HP': data["sim_out"]["outs_all_states_sim"]["heat_HP"],
                    'dT_vio': data["sim_out"]["outs_all_states_sim"]["dT_vio"],
                    'dch_BAT': data["sim_out"]["outs_all_states_sim"]["dch_BAT"],
                    'dch_DHW': data["sim_out"]["outs_all_states_sim"]["dch_DHW"],
                    'dch_TES': data["sim_out"]["outs_all_states_sim"]["dch_TES"],
                    'T_panel_heating1': data["sim_out"]["outs_all_states_sim"]["T_panel_heating1"],
                    'ch_BAT': data["sim_out"]["outs_all_states_sim"]["ch_BAT"],
                    'ch_DHW': data["sim_out"]["outs_all_states_sim"]["ch_DHW"],
                    'ch_TES': data["sim_out"]["outs_all_states_sim"]["ch_TES"]
                    })

#Save data to csv
#f = csv.writer(open(r"D:\01_Modellierung\master-thesis\AMPC_Training_Data\test.csv", "wb+"))
df_opti.to_csv(r'D:\01_Modellierung\master-thesis\AMPC_Training_Data\mpc_results_opti_week2.csv',index=False)
df_sim.to_csv(r'D:\01_Modellierung\master-thesis\AMPC_Training_Data\mpc_results_sim_week2.csv',index=False)