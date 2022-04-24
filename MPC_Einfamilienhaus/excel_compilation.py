# -*- coding: utf-8 -*-

"""

ECTOPLANNER SOFTWARE

Developed by:  E.ON Energy Research Center, 
               Institute for Energy Efficient Buildings and Indoor Climate, 
               RWTH Aachen University, 
               Germany

Development period: 2018/2019

"""

import xlsxwriter

def create_excel_file(last_results, title, scenario):


    print("Compile Excel file...")
        
    # file_path = os.path.join("Users\dodoa\Documents\Studium\Hiwi\EON\design_optim_develop", "Excel_Test.xlsx")    
    # workbook = xlsxwriter.Workbook(file_path)
    
    workbook = xlsxwriter.Workbook(title)

    ###FORMATS###
    formats = {} 
    formats["right"] = workbook.add_format({'align': 'right'})
    formats["left"] = workbook.add_format({'align': 'left'})
    formats["bold"] = workbook.add_format({'bold': True})
    formats["bold_underl"] = workbook.add_format({'bold': True, 'underline': True})
    
    formats["big_bold"] = workbook.add_format({'bold': True, 'font_size': 12})
    formats["center_bold"] = workbook.add_format({'bold': True, 'align': 'center',})
    formats["right_bold"] = workbook.add_format({'bold': True, 'align': 'right',})
    
    formats["italic"] = workbook.add_format({'italic': True})
    formats["big_italic"] = workbook.add_format({'italic': True, 'font_size': 12})
    formats["right_italic"] = workbook.add_format({'italic': True, 'align': 'right',})
    formats["left_italic"] = workbook.add_format({'italic': True, 'align': 'left',})
    
    formats["format_params"] = workbook.add_format({
        'bold': 1,
        'align': 'right',
        'valign': 'vcenter',})
    formats["format_results_acc"] = workbook.add_format({
        'align': 'right',
        'valign': 'vcenter',
        'num_format': '0.00'})
    formats["format_results"] = workbook.add_format({
        'align': 'right',
        'valign': 'vcenter',
        'num_format': '0'})
    
        
    ########### MAIN RESULTS ###########
    worksheets = {}
    worksheets["worksheet_ref"] = workbook.add_worksheet("Reference Scenario")
    # worksheets["worksheet_ren1"] = workbook.add_worksheet("Renewable1 Scenario")
    # worksheets["worksheet_ren2"] = workbook.add_worksheet("Renewable2 Scenario")
    # worksheets["worksheet_ren3"] = workbook.add_worksheet("Renewable3 Scenario")
    
    row = 0
    col = 0
        
    for worksheet in worksheets:
        
        worksheets[worksheet].set_column(0, 0, 40)  # set width first column
        worksheets[worksheet].set_column(1, 50, 15)  # set width next columns
        
        worksheets[worksheet].write(row  ,col, "domestic_BAT", formats["big_bold" ]) ## B4
        worksheets[worksheet].write(row+1,col, "enable_exchange", formats["big_bold" ]) ## B4
        worksheets[worksheet].write(row+3,col, "Date", formats["big_bold" ]) ## B4
        worksheets[worksheet].write(row+4,col, "Optimization_horizon", formats["big_bold" ]) ## B4
        worksheets[worksheet].write(row+5,col, "Electricty Costs", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+6,col, "Total Electricity Exchanged", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+7,col, "Total Electricity To Grid", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+8,col, "Total Electricity From Grid", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+9,col, "Total Electricity PV generated", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+10,col, "Total Load Battery", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+11,col, "Total Load TES DHW", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+12,col, "Total Load TES Heat", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+13,col, "Demand Electricity and E-mobility", formats["left_italic" ])
        worksheets[worksheet].write(row+14,col, "Demand Heating and DHW", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+15,col, "Demand Cooling", formats["left_italic" ]) ## B4
        
        worksheets[worksheet].write(row+16,col, "el_dem_1", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+17,col, "el_dem_2", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+18,col, "e_dem_1", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+19,col, "e_dem_2", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+20,col, "em_dem_1", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+21,col, "em_dem_2", formats["left_italic" ]) ## B4
        
        worksheets[worksheet].write(row+22,col, "heat_dem_1", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+23,col, "heat_dem_2", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+24,col, "dhw_dem_1", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+25,col, "dhw_dem_1", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+26,col, "h_dem_1", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+27,col, "h_dem_2", formats["left_italic" ]) ## B4
        
        worksheets[worksheet].write(row+28,col, "cool_dem_1", formats["left_italic" ]) ## B4
        worksheets[worksheet].write(row+29,col, "cool_dem_2", formats["left_italic" ]) ## B4
        
        col =1
        worksheets[worksheet].write(row, col, scenario["domestic_BAT"], formats["format_params"]) ## B4
        worksheets[worksheet].write(row+1, col, scenario["enable_exchange"], formats["format_params"]) ## B4
        worksheets[worksheet].write(row+3, col, scenario["date"], formats["format_params"]) ## B4
        worksheets[worksheet].write(row+4, col, scenario["num_optim_iterations"], formats["format_params"]) ## B4
        worksheets[worksheet].write(row+5, col, sum(last_results["el_costs"][t] for t in range(scenario["num_optim_iterations"])), formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+6, col, last_results["total_exch"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+7, col, last_results["to_grid"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+8, col, last_results["from_grid"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+9, col, last_results["total_PV"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+10, col, last_results["total_BAT_load"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+11, col, last_results["total_TES_dhw_load"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+12, col, last_results["total_TES_heat_load"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+13, col, last_results["el_dem"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+14, col, last_results["heat_dem"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+15, col, last_results["cool_dem"], formats["format_results_acc"]) ## B4
        
        worksheets[worksheet].write(row+16, col, last_results["el_dem_1"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+17, col, last_results["el_dem_2"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+18, col, last_results["e_dem_1"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+19, col, last_results["e_dem_2"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+20, col, last_results["em_dem_1"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+21, col, last_results["em_dem_2"], formats["format_results_acc"]) ## B4
        
        worksheets[worksheet].write(row+22, col, last_results["heat_dem_1"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+23, col, last_results["heat_dem_2"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+24, col, last_results["dhw_dem_1"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+25, col, last_results["dhw_dem_2"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+26, col, last_results["h_dem_1"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+27, col, last_results["h_dem_2"], formats["format_results_acc"]) ## B4
        
        worksheets[worksheet].write(row+28, col, last_results["cool_dem_1"], formats["format_results_acc"]) ## B4
        worksheets[worksheet].write(row+29, col, last_results["cool_dem_2"], formats["format_results_acc"]) ## B4
        
    workbook.close()
    return
             
#     ### End Energy Demand ### 
#     worksheet.write(row+1,col_1, "Energy Demand", big_bold) ## B4
#     worksheet.write_row(row+1, col_1+1, ("Annual energy (MWh/a)", "Peak power (kW)"), bold)
#     worksheet.write_row(row+2, col_1, ("Natural gas", result_dict["total_gas"], result_dict["peak_gas"]))
#     worksheet.write_row(row+3, col_1, ("Electricity from grid", result_dict["total_el_from_grid"], result_dict["peak_power_from_grid"]))
#     worksheet.write_row(row+4, col_1, ("Electricity feed-in",   result_dict["total_el_to_grid"], result_dict["peak_power_to_grid"]))
#     worksheet.write_row(row+5, col_1, ("PV generation",         result_dict["total_PV_power"], result_dict["peak_PV"]))
#     worksheet.write_row(row+6, col_1, ("District heating",      result_dict["total_from_DH"], result_dict["peak_from_DH"]))
#     worksheet.write_row(row+7, col_1, ("District cooling",      result_dict["total_from_DC"], result_dict["peak_from_DC"]))
#     worksheet.write_row(row+8, col_1, ("Waste heat",            result_dict["total_from_waste_heat"], result_dict["peak_from_WASTE"]))
#     worksheet.write_row(row+9, col_1, ("Waste cold",            result_dict["total_from_waste_cold"], result_dict["peak_from_WASTE_cold"]))
#     row += 9+2
    
#     ### Demand Balancing ###
#     worksheet.write(row+1, col_1, "Demand Balancing", big_bold) ## B15
#     worksheet.write_row(row+1, col_1+1, ("Heat demand (MWh/a)", "Cold demand (MWh/a)", "Balanced demands (MWh/a)", "Balanced demands"), bold)
#     worksheet.write_row(row+2, col_1, ("Buildings (input data)", result_dict["all_bldgs"]["total_sh_tap_dem"], result_dict["all_bldgs"]["total_cool_dem"], "---", "---", "①"))
#     worksheet.write_row(row+3, col_1, ("Building energy systems", result_dict["BES_heat_dem_total"], result_dict["BES_cool_dem_total"], "---", "---", "②"))
#     worksheet.write_row(row+4, col_1, ("Net building demands", result_dict["Net_BES_heat_dem_total"], result_dict["Net_BES_cool_dem_total"], result_dict["BES_dem_balanced"], str(result_dict["DOC_BES"])+" %", "③"))
#     worksheet.write_row(row+5, col_1, ("Balancing unit load", result_dict["BU_load_total"]["heat"], result_dict["BU_load_total"]["cool"], result_dict["netw_dem_balanced"], str(result_dict["DOC_netw"])+" %", "④"))
#     row += 5+2
    
#     worksheet.insert_image("G15", "ectoplanner/static/icons/Explanation_Balancing.png", {'x_scale': 0.06, 'y_scale': 0.06})
#     # path on E.ON server: "/code/ectogrid/ectoplanner/static/icons/Explanation_Balancing.png"
    
    
#     ### Balancing unit ###
#     worksheet.write(row+1, col_1, "Balancing unit", big_bold) ## B22
#     worksheet.write_row(row+1, col_1+1, ("Capacity (kW)", "Generation (MWh/a)", "Full load hours (h/a)"), bold)
#     worksheet.write_row(row+2, col_1, ("Reversible heat pump", result_dict["RevHP"]["cap"], result_dict["RevHP"]["gen_heat"]+result_dict["RevHP"]["gen_cold"], result_dict["RevHP"]["hrs"]))
#     worksheet.write_row(row+3, col_1, ("Heat pump (heating only)", result_dict["SimpHP"]["cap"], result_dict["SimpHP"]["gen"], result_dict["SimpHP"]["hrs"]))
#     worksheet.write_row(row+4, col_1, ("Electric boiler", result_dict["EH"]["cap"], result_dict["EH"]["gen"], result_dict["EH"]["hrs"]))
#     worksheet.write_row(row+5, col_1, ("Compression chiller", result_dict["CC"]["cap"], result_dict["CC"]["gen"], result_dict["CC"]["hrs"]))
#     worksheet.write_row(row+6, col_1, ("Absorption chiller", result_dict["AC"]["cap"], result_dict["AC"]["gen"], result_dict["AC"]["hrs"]))
#     worksheet.write_row(row+7, col_1, ("CHP unit", result_dict["CHP"]["cap"], result_dict["CHP"]["gen"], result_dict["CHP"]["hrs"]))
#     worksheet.write_row(row+8, col_1, ("Gas boiler", result_dict["BOI"]["cap"], result_dict["BOI"]["gen"], result_dict["BOI"]["hrs"]))
#     worksheet.write_row(row+9, col_1, ("", "Capacity (kWp)", "Area (m2)", "Full load hours (h/a)"), bold)
#     worksheet.write_row(row+10, col_1, ("Photovoltaics", result_dict["PV"]["cap"], result_dict["total_PV_area"], result_dict["PV"]["hrs"]))
#     worksheet.write_row(row+11, col_1, ("", "Capacity (kWh)", "Volume (m3)", "Charging cycles"), bold)
#     worksheet.write_row(row+12, col_1, ("Accumulator tank", result_dict["ACC"]["cap"], result_dict["ACC"]["vol"], result_dict["ACC"]["chc"]))
#     worksheet.write_row(row+13, col_1, ("Battery", result_dict["BAT"]["cap"], "---", result_dict["BAT"]["chc"]))
#     worksheet.write_row(row+14, col_1, ("Heat storage", result_dict["TES"]["cap"], result_dict["TES"]["vol"], result_dict["TES"]["chc"]))
#     worksheet.write_row(row+15, col_1, ("Cold storage", result_dict["CTES"]["cap"], result_dict["CTES"]["vol"], result_dict["CTES"]["chc"]))
#     row += 15+2
    
#     ### Balancing unit ###
#     worksheet.write(row+1, col_1, "Costs (CAPEX and OPEX)", big_bold) ## B39
#     worksheet.write_row(row+1, col_1+1, ("Annual costs (EUR/a)", "Investments (EUR)"), bold)
#     worksheet.write_row(row+2, col_1, ("Natural gas", result_dict["total_gas_costs"], ""))  
#     worksheet.write_row(row+3, col_1, ("Electricity", result_dict["total_el_from_grid_costs"]))
#     worksheet.write_row(row+4, col_1, ("Feed-in", result_dict["total_el_to_grid_revenue"]))
#     worksheet.write_row(row+5, col_1, ("District heating", result_dict["total_from_DH_costs"]))
#     worksheet.write_row(row+6, col_1, ("District cooling", result_dict["total_from_DC_costs"]))
#     worksheet.write_row(row+7, col_1, ("Waste heat", result_dict["total_waste_heat_costs"]))
#     worksheet.write_row(row+8, col_1, ("Waste cold", result_dict["total_waste_cold_costs"]))    
#     worksheet.write_row(row+9, col_1, ("Investment buildings", result_dict["all_bldgs"]["ann_total_bldg_equip_cost"], result_dict["all_bldgs"]["total_bldg_equip_cost"]))
#     worksheet.write_row(row+10, col_1, ("Investment balancing unit", result_dict["ann_total_bu_equip_cost"], result_dict["total_bu_equip_cost"]))
#     worksheet.write_row(row+11, col_1, ("Operation & maintenance costs", result_dict["total_bu_om_cost"]))
#     worksheet.write_row(row+12, col_1, ("Pipe installation", result_dict["ann_piping_cost"], result_dict["piping_cost"]))    
#     row += 12+2
    
    
#     ### CO2 emissions ###
#     worksheet.write(row+1, col_1, "CO2 emissions", big_bold) ## B53
#     worksheet.write_row(row+1, col_1+1, ("CO2 emissions (t/a)", ), bold)
#     worksheet.write_row(row+2, col_1, ("Total emissions", result_dict["CO2"]))
#     worksheet.write_row(row+3, col_1, ("Electricity import", result_dict["el_CO2"]))
#     worksheet.write_row(row+4, col_1, ("Burning natural gas", result_dict["gas_CO2"]))
#     row += 4+2
    
#     ### Pipe installation ###
#     worksheet.write(row+1, col_1, "Pipe connection at BU", big_bold) ## B59
#     worksheet.write_row(row+2, col_1, ("Maximum heating power of BU", result_dict["BU_load_peak"]["heat"], "kW"))
#     worksheet.write_row(row+3, col_1, ("Maximum cooling power of BU", result_dict["BU_load_peak"]["cool"], "kW"))
#     worksheet.write_row(row+4, col_1, ("Pipe diameter at BU", ("DN"+str(result_dict["BU_pipe_diam"])), ("(resulting flow velocity: " + str(result_dict["BU_pipe_v"]) + " m/s)")))
#     row += 4+2    
    
#     ## Calculation functions for Allocation Methods: 
#     def anuityfactor():
#         interest_rate   = param["interest_rate"]
#         lifetime        = param["observation_time"]
#         global anuity
#         anuity = (((( 1 + interest_rate )**lifetime ) * ( interest_rate ) / ((( 1 + interest_rate )**lifetime ) - 1 )))

#     def elprice_5gdhc():
    
#         Amount_El_CHP       =   result_dict["CHP"]["gen"]
#         Amount_El_PV        =   result_dict["total_PV_power"]
#         Amount_El_grid      =   result_dict["total_el_from_grid"] 
#         Amount_El_feedin    =   result_dict["total_el_to_grid"] 
#         # sum of total el generated and used, minus electricity that was fed into the grid#
#         sum_el              =   Amount_El_CHP + Amount_El_PV + Amount_El_grid - Amount_El_feedin

#         ##### Inputparamter #####

#         teta_el             =   devs["CHP"]["eta_el"] 
#         teta_th             =   devs["CHP"]["eta_th"]        
#         gas_costs           =   (result_dict["CHP"]["gen"]     /   devs["CHP"]["eta_el"] ) * param["price_gas"] * 1000 
               
#         Price_Factor        =   teta_el     /   (teta_el + teta_th)           

#         #### CHP and PV OM & Annualized costs:
        
#         om_costs_CHP                =   result_dict["CHP"]["cap"]   *   devs["CHP"]["inv_var"]  *   devs["CHP"]["cost_om"] 
#         annualized_inv_costs_CHP    =   result_dict["CHP"]["cap"]   *   anuity                  *   devs["CHP"]["inv_var"]
#         om_costs_PV                 =   result_dict["PV"]["cap"]    *   devs["PV"]["inv_var"]   *   devs["PV"]["cost_om"] 
#         annualized_inv_costs_PV     =   result_dict["PV"]["cap"]    *   anuity                  *   devs["PV"]["inv_var"] 

#         ## PV and CHP Power Production Price:
#         ppp_CHP     = (    gas_costs   +   om_costs_CHP    +   annualized_inv_costs_CHP) * Price_Factor 
#         ppp_PV      = (    om_costs_PV +   annualized_inv_costs_PV)                                   
#         ppp_grid    =       param["price_el"]           * 1000 
#         ppp_feedin  =       param["revenue_feed_in"]   * 1000
    
#         ## Total Electricity Price 5GDHC
#         global elprodprice5GDHC
#         elprodprice5GDHC = ((   ppp_CHP +   ppp_PV  +   (   ppp_grid    * Amount_El_grid    )    - (ppp_feedin   *   Amount_El_feedin    )   )   /   sum_el  )

#     def allocation_method_calculation(allomethod):
#         ## Calculation of shares (building and BU) ##
#         total_heatingandcooling_demand      =   result_dict["all_bldgs"]["total_sh_tap_dem"]    + result_dict["all_bldgs"]["total_cool_dem"]  
#         total_share_heating_5GDHC           =   result_dict["all_bldgs"]["total_sh_tap_dem"]    / total_heatingandcooling_demand   
#         total_share_cooling_5GDHC           =   result_dict["all_bldgs"]["total_cool_dem"]      / total_heatingandcooling_demand

#         # Process inputs
#         print('5 power_for_cooling', result_dict['system_efficiency'].power_for_cooling.sum())
#         print('5 heat_for_cooling', result_dict['system_efficiency'].heat_for_cooling.sum())
#         process_input_heating = (result_dict['system_efficiency'].power_for_heating.sum() + result_dict['system_efficiency'].gas_for_heating.sum())
#         process_input_cooling = (result_dict['system_efficiency'].power_for_cooling.sum() + result_dict['system_efficiency'].heat_for_cooling.sum())

#         # Process efficiencies
#         efficiency_heating = (result_dict['system_efficiency'].output_heat.sum() + result_dict['system_efficiency'].chp_output_power.sum()) / \
#                           (result_dict['system_efficiency'].power_for_heating.sum() + \
#                             result_dict['system_efficiency'].gas_for_heating.sum() + \
#                             result_dict['system_efficiency'].power_for_cooling.sum() + \
#                             result_dict['system_efficiency'].heat_for_cooling.sum())
#         efficiency_cooling = (result_dict['system_efficiency'].output_cool.sum()) / \
#                           (result_dict['system_efficiency'].power_for_heating.sum() + \
#                             result_dict['system_efficiency'].gas_for_heating.sum() + \
#                             result_dict['system_efficiency'].power_for_cooling.sum() + \
#                             result_dict['system_efficiency'].heat_for_cooling.sum())

#         ## Cost Factor Calculation depending on allocation method##
#         global costfactor_heating
#         global costfactor_cooling
        
#         if allomethod == "Demand share":
#             costfactor_heating     = total_share_heating_5GDHC 
#             costfactor_cooling     = total_share_cooling_5GDHC

#         if allomethod == "Process input":
#             costfactor_heating     = process_input_heating / (process_input_heating + process_input_cooling) 
#             costfactor_cooling     = process_input_cooling / (process_input_heating + process_input_cooling) 

#         if allomethod == "IEA":
#             costfactor_heating     = efficiency_heating / (efficiency_heating + efficiency_cooling) 
#             costfactor_cooling     = efficiency_cooling / (efficiency_heating + efficiency_cooling) 

#         if allomethod == "Cooling Credit Method": 
#             costfactor_cooling     = (c_gbc_total * result_dict["all_bldgs"]["total_cool_dem"] )/ ta_5GDHC
#             costfactor_heating     = 1.0 - costfactor_cooling

#         if allomethod == "Heating Credit Method": 
#             costfactor_heating     = (h_gbc_total * result_dict["all_bldgs"]["total_sh_tap_dem"] )/ ta_5GDHC
#             costfactor_cooling     = 1.0 - costfactor_heating
        
#         print(costfactor_heating, costfactor_cooling)
#         return costfactor_heating, costfactor_cooling
    
#     def prices_5gdhc():
               
#         ## Total annualized Heating and Cooling costs (CAPEX&OPEX) ##
#         global ta_5GDHC
#         ta_5GDHC = (    result_dict["total_gas_costs"]
#                     +   result_dict["total_el_from_grid_costs"]
#                     -   result_dict["total_el_to_grid_revenue"]
#                     +   result_dict["total_from_DH_costs"]
#                     +   result_dict["total_from_DC_costs"]
#                     +   result_dict["total_waste_heat_costs"]
#                     +   result_dict["total_waste_cold_costs"]
#                     +   result_dict["all_bldgs"]["ann_total_bldg_equip_cost"]
#                     +   result_dict["ann_total_bu_equip_cost"]
#                     +   result_dict["total_bu_om_cost"]
#                     +   result_dict["ann_piping_cost"])                          # OK


#         # Create set for devices
#         all_devs_BU = ["RevHP", "SimpHP", "EH", "CC", "AC", "CHP", "BOI"]       
#         all_devs_building = ["SimpHP", "EH", "CC", "BOI"]       

#         # Create cost variables
#         global total_heating_costs_5G
#         global total_cooling_costs_5G
#         total_heating_costs_5G = 0.0
#         total_cooling_costs_5G = 0.0

#         # Handle assignable cost terms
#         tc_district_heating     = result_dict["total_from_DH_costs"] 
#         tc_district_cooling     = result_dict["total_from_DC_costs"] 
#         tc_waste_heat           = result_dict["total_waste_heat_costs"] 
#         tc_waste_cold           = result_dict["total_waste_cold_costs"] 

#         total_heating_costs_5G += tc_district_heating
#         total_heating_costs_5G += tc_waste_heat
#         total_cooling_costs_5G += tc_district_cooling
#         total_cooling_costs_5G += tc_waste_cold

#         # Handle pipe cost terms
#         pipe_installation_heat  = result_dict["ann_piping_cost"] * costfactor_heating
#         pipe_installation_cool  = result_dict["ann_piping_cost"] * costfactor_cooling
#         total_cooling_costs_5G += tc_waste_heat
#         total_cooling_costs_5G += tc_waste_cold

#         # Handle building cost terms
#         hp_inv_bldg             = 0.00
#         for bldg in result_dict["bldgs"].keys():
#             hp_inv_bldg         += ( result_dict["bldgs"][bldg]["hp_costs"] * anuity ) 

#         cc_inv_bldg             = 0.00
#         for bldg in result_dict["bldgs"].keys():
#             cc_inv_bldg         += ( result_dict["bldgs"][bldg]["cc_costs"] * anuity ) 

#         boi_inv_bldg            = 0.00
#         for bldg in result_dict["bldgs"].keys():
#             boi_inv_bldg        += ( result_dict["bldgs"][bldg]["boi_costs"] * anuity ) 

#         hp_el_bldg              = result_dict["all_bldgs"]["total_power_dem_HP"]   * elprodprice5GDHC
#         cc_el_bldg              = result_dict["all_bldgs"]["total_power_dem_CC"]   * elprodprice5GDHC
#         boi_gas_bldg            = result_dict["all_bldgs"]["total_gas_dem_bldgs"]  * param["price_gas"] * 1000 

#         total_heating_costs_5G += hp_inv_bldg + boi_inv_bldg + hp_el_bldg + boi_gas_bldg
#         total_cooling_costs_5G += cc_inv_bldg + cc_el_bldg

#         # Handle BU cost terms
#         BU_cost_not_assignable  = (result_dict["total_gas_costs"]
#                                 + result_dict["total_el_from_grid_costs"]
#                                 - result_dict["total_el_to_grid_revenue"]   
#                                 + result_dict["ann_total_bu_equip_cost_not_assignable"]
#                                 + result_dict["total_bu_om_cost_not_assignable"]
#                                 - hp_el_bldg 
#                                 - cc_el_bldg 
#                                 - boi_gas_bldg)
#         BU_cost_heating = result_dict["ann_total_bu_equip_cost_heating"] + result_dict["total_bu_om_cost_heating"]
#         BU_cost_cooling = result_dict["ann_total_bu_equip_cost_cooling"] + result_dict["total_bu_om_cost_cooling"]

#         total_heating_costs_5G  += BU_cost_not_assignable * costfactor_heating + BU_cost_heating
#         total_cooling_costs_5G  += BU_cost_not_assignable * costfactor_cooling + BU_cost_cooling
       
#         global lcoe_heating_5G
#         global lcoe_cooling_5G
#         lcoe_heating_5G      = total_heating_costs_5G    / result_dict["all_bldgs"]["total_sh_tap_dem"]
#         lcoe_cooling_5G      = total_cooling_costs_5G    / result_dict["all_bldgs"]["total_cool_dem"] 


#     def gasboilers_chillers(): ## hc= heating and cooling; gbc= gas boilers and chillers ##
      
#         ## Demand is given in model:
#         Heating_Demand      = result_dict["all_bldgs"]["total_sh_tap_dem"]
#         Cooling_Demand      = result_dict["all_bldgs"]["total_cool_dem"]
#         Gas_Demand          = Heating_Demand / devs["BOI"]["eta_th"]
#         ElCooling_Demand    = Cooling_Demand / devs["CC"]["cop_const"]

#         ## Anualized Investment Costs ##        
#         max_heating_demand = 0.00 
#         max_cooling_demand = 0.00

#         for n in nodes.keys():      
        
#             # Space heating demand:
#             heat_sh_b = round(np.max(nodes[n]["heat_sh"]),2)
#             # Tap water demand:        
#             heat_tap_b = round(np.max(nodes[n]["heat_tap"]),2)
#             #heating sum:
#             max_heating_demand = max_heating_demand + heat_sh_b + heat_tap_b

#             #Cooling Demand building:
#             max_cooling_demand = max_cooling_demand + round(np.max(nodes[n]["cool"]),2)
            
#         total_anualized_heating_inv_cost = max_heating_demand * devs["BOI"]["inv_var"]  * anuity               
#         total_anualized_cooling_inv_cost = max_cooling_demand * devs["CC"]["inv_var"]   * anuity            

#         ## Annual Costs ## 
#         annual_gas_cost     = Gas_Demand            * param["price_gas"] * 1000                                      
#         annual_el_cost      = ElCooling_Demand      * param["price_el"] * 1000                                        
#         annual_OM_gb_costs  = max_heating_demand    * devs["BOI"]["inv_var"]    * devs["BOI"]["cost_om"]             
#         annual_OM_c_costs   = max_cooling_demand    * devs["CC"]["inv_var"]     * devs["CC"]["cost_om"]           

#         ## Total Anualized Costs for Heating and Cooling ##
#         ta_hc = total_anualized_heating_inv_cost +  annual_gas_cost  +   annual_OM_gb_costs
#         ta_cc = total_anualized_cooling_inv_cost +  annual_el_cost   +   annual_OM_c_costs          

#         ## Total Heating and Cooling Production Costs ##
#         global h_gbc_total
#         global c_gbc_total
       
#         h_gbc_total = (ta_hc / Heating_Demand) 
#         c_gbc_total = (ta_cc / Cooling_Demand) 

#         ## CO2 Emissions: ##
#         global total_co2_gbch
#         global total_co2_gb
#         global total_co2_ch
#         total_co2_gb    = Gas_Demand        *   param["gas_CO2_emission"]                                        
#         total_co2_ch    = ElCooling_Demand  *   param["grid_CO2_emission"]                           
#         total_co2_gbch  = total_co2_gb      +   total_co2_ch

#     def heatpump_chiller():              
        
#         ## Demand is given in model:
#         Heating_Demand      = result_dict["all_bldgs"]["total_sh_tap_dem"]
#         Cooling_Demand      = result_dict["all_bldgs"]["total_cool_dem"] 
#         ElHeating_Demand    = Heating_Demand / devs["RevHP"]["cop_const_heat"]
#         ElCooling_Demand    = Cooling_Demand / devs["CC"]["cop_const"]

#         ## Anualized Investment Costs ##
        
#         max_heating_demand = 0.0 
#         max_cooling_demand = 0.0 

#         for n in nodes.keys():        
        
#             # Space heating demand:
#             heat_sh_b = round(np.max(nodes[n]["heat_sh"]),2)
#             # Tap water demand:        
#             heat_tap_b = round(np.max(nodes[n]["heat_tap"]),2)
#             #heating sum:
#             max_heating_demand = max_heating_demand + heat_sh_b + heat_tap_b

#             #Cooling Demand building:
#             max_cooling_demand = max_cooling_demand + round(np.max(nodes[n]["cool"]),2)
        
#         total_anualized_heating_inv_cost = max_heating_demand * devs["RevHP"]["inv_var"]  * anuity               
#         total_anualized_cooling_inv_cost = max_cooling_demand * devs["CC"]["inv_var"]   * anuity            


#         ## Annual Costs ##
#         annual_el_cost_hp   = ElHeating_Demand      * param["price_el"] * 1000                                               
#         annual_el_cost_ch   = ElCooling_Demand      * param["price_el"] * 1000                                             
#         annual_OM_hp_costs  = max_heating_demand    * devs["RevHP"]["inv_var"]  * devs["RevHP"]["cost_om"]           
#         annual_OM_c_costs   = max_cooling_demand    * devs["CC"]["inv_var"]     * devs["CC"]["cost_om"]              

#         ## Total Anualized Costs for Heating and Cooling ##
#         ta_hc = total_anualized_heating_inv_cost + annual_el_cost_hp + annual_OM_hp_costs
#         ta_cc = total_anualized_cooling_inv_cost + annual_el_cost_ch + annual_OM_c_costs

#         ## Total Heating and Cooling Production Costs ##
#         global h_hpc_total
#         global c_hpc_total
#         h_hpc_total = (ta_hc / Heating_Demand) 
#         c_hpc_total = (ta_cc / Cooling_Demand) 

#         ## CO2 Emissions: ##
#         global total_co2_hpch
#         global total_co2_hp
#         global total_co2_ch
#         total_co2_hp    = ElHeating_Demand * param["grid_CO2_emission"] 
#         total_co2_ch    = ElCooling_Demand * param["grid_CO2_emission"] 
#         total_co2_hpch  = total_co2_hp + total_co2_ch

#     def prices_3gdhc():
#         global heating_3gdhc 
#         heating_3gdhc = devs["from_DH"]["price_DH"] * 1000
#         global cooling_3gdhc 
#         cooling_3gdhc = devs["from_DC"]["price_DC"] * 1000
        
#     ### Cost for Heating and Cooling ###
#     worksheet.merge_range('C64:F64', 'Allocation Method', bold)
#     worksheet.write(        'A65', "5GDHC Costs", big_bold) 
#     worksheet.write_row(    'B65', ("", "IEA Method", "Energy Input Share Method", "Energy Demand Share Method", "Cooling Credit Method", "Heating Credit Method"), bold)
#     worksheet.write_column( 'B66', ("Levelized Cost of Heating [€/MWh]","Levelized Cost of Cooling [€/MWh]","Average system-internal electricity price [€/MWh]","Heating CO2 Emissions [t/a]", "Cooling CO2 Emissions [t/a]",
#                                     "","",
#                                     "Levelized Cost of Heating [€/MWh]","Levelized Cost of Cooling [€/MWh]","Average system-internal electricity price [€/MWh]","Heating CO2 Emissions [t/a]", "Cooling CO2 Emissions [t/a]"))
#     ## general functions ##
#     anuityfactor()
#     elprice_5gdhc()
#     gasboilers_chillers()
#     heatpump_chiller()
#     prices_3gdhc()

#  	## Call functions for IEA ##
#     allocation_method_calculation("IEA")
#     prices_5gdhc()
#     worksheet.write_column( 'C66',(round(lcoe_heating_5G,2), round(lcoe_cooling_5G,2), round(elprodprice5GDHC,2), round(result_dict["CO2"] * costfactor_heating,2)  , round(result_dict["CO2"]* costfactor_cooling,2),
#                                     ))

#     ## Call functions for Process Input Method ##
#     allocation_method_calculation("Process input")
#     prices_5gdhc()
#     worksheet.write_column( 'D66',(round(lcoe_heating_5G,2), round(lcoe_cooling_5G,2), round(elprodprice5GDHC,2), round(result_dict["CO2"] * costfactor_heating,2)  , round(result_dict["CO2"]* costfactor_cooling,2),
#                                     ))

#     ## Call functions for Demand Share Method ##
#     allocation_method_calculation("Demand share")
#     prices_5gdhc()
#     worksheet.write_column( 'E66',(round(lcoe_heating_5G,2), round(lcoe_cooling_5G,2), round(elprodprice5GDHC,2), round(result_dict["CO2"] * costfactor_heating,2)  , round(result_dict["CO2"]* costfactor_cooling,2),
#                                     ))

#     ## Call functions for Cooling Credit Method ##                               
#     allocation_method_calculation("Cooling Credit Method")
#     prices_5gdhc()
#     worksheet.write_column( 'F66',(round(lcoe_heating_5G,2), round(lcoe_cooling_5G,2), round(elprodprice5GDHC,2), round(result_dict["CO2"] * costfactor_heating,2)  , round(result_dict["CO2"]* costfactor_cooling,2),
#                                     ))

#     ## Call functions for Heating Credit Method ##
#     allocation_method_calculation("Heating Credit Method")
#     prices_5gdhc()
#     worksheet.write_column( 'G66',(round(lcoe_heating_5G,2), round(lcoe_cooling_5G,2), round(elprodprice5GDHC,2), round(result_dict["CO2"] * costfactor_heating,2)  , round(result_dict["CO2"]* costfactor_cooling,2),
#                                     ))

#     ## Comparison Technologies ##
#     worksheet.write(        'A72', "Comparison Technologies", big_bold)
#     worksheet.write_row(    'C72',("Decentralized Gas boiler + Compression Chiller", "Decentralized Heat Pump + Compression Chiller", "3GDHC")) 
#     worksheet.write_column( 'C73',(round(h_gbc_total,2), round(c_gbc_total,2), round(param["price_el"]*1000,2), round(total_co2_gb,2), round(total_co2_ch,2))) 
#     worksheet.write_column( 'D73',(round(h_hpc_total,2), round(c_hpc_total,2), round(param["price_el"]*1000,2), round(total_co2_hp,2), round(total_co2_ch,2)))
     
#     ########### BUILDING RESULTS ###########
#     worksheet = workbook.add_worksheet("Building results")
#     worksheet.set_column(0, 0, 20)
#     worksheet.set_column(1, 2, 30)
#     worksheet.set_column(3, 5, 24)
#     worksheet.set_column(6, 6, 30)
#     worksheet.set_column(7, 7, 20)
#     row = 0
    
#     ### Buildings ###
#     worksheet.write(row+0, col_1, "Cumulated installations in buildings", big_bold)
#     worksheet.write_row(row+1, col_1, ("Technology", "Capacity (kW)", "Power / Gas demand (MWh/a)", "Mean COP"), bold)
#     worksheet.write_row(row+2, col_1, ("Heat pump", result_dict["all_bldgs"]["hp_cap"], result_dict["all_bldgs"]["total_power_dem_HP"], result_dict["all_bldgs"]["mean_COP_HP"]))
#     worksheet.write_row(row+3, col_1, ("Chiller", 
#                                         result_dict["all_bldgs"]["cc_cap"], 
#                                         result_dict["all_bldgs"]["total_power_dem_CC"], 
#                                         result_dict["all_bldgs"]["mean_COP_CC"]))
#     worksheet.write_row(row+4, col_1, ("Direct cooling", 
#                                         result_dict["all_bldgs"]["drc_cap"], 
#                                         0))
#     worksheet.write_row(row+5, col_1, ("Electric heating rod", 
#                                         result_dict["all_bldgs"]["eh_cap"], 
#                                         result_dict["all_bldgs"]["total_power_dem_EH"]))
#     worksheet.write_row(row+6, col_1, ("Gas boiler", 
#                                         result_dict["all_bldgs"]["boi_cap"], 
#                                         result_dict["all_bldgs"]["total_gas_dem_bldgs"]))
#     row += 6+2
    
#     worksheet.write(row+0, col_1, "Building equipment", big_bold)
#     worksheet.write_row(row+1, col_1, ("Building", 
#                                         "Heat pump (kW_th)", 
#                                         "Electric heating rod (kW_th)", 
#                                         "Gas boiler (kW_th)", 
#                                         "Chiller (kW_th)", 
#                                         "Direct cooling (kW_th)"), bold)
    
#     curr = 0
#     for bldg in result_dict["bldgs"].keys():
#         worksheet.write_row(row+2+curr, col_1, (result_dict["bldgs"][bldg]["name"],
#                                                 result_dict["bldgs"][bldg]["hp_capacity"],
#                                                 result_dict["bldgs"][bldg]["eh_capacity"], 
#                                                 result_dict["bldgs"][bldg]["boi_capacity"],
#                                                 result_dict["bldgs"][bldg]["cc_capacity"], 
#                                                 result_dict["bldgs"][bldg]["drc_capacity"]))
#         curr += 1
#     row += curr + 3
    
#     worksheet.write(row+0, col_1, "CAPEX buildings", big_bold)
#     worksheet.write_row(row+1, col_1, ("Building", 
#                                         "Heat pump (EUR)", 
#                                         "Electric heating rod (EUR)", 
#                                         "Gas boiler (EUR)", 
#                                         "Chiller (EUR)", 
#                                         "Direct cooling (EUR)"), bold)
#     curr = 0
#     for bldg in result_dict["bldgs"].keys():
#         worksheet.write_row(row+2+curr, col_1, (result_dict["bldgs"][bldg]["name"],
#                                                 result_dict["bldgs"][bldg]["hp_costs"], 
#                                                 result_dict["bldgs"][bldg]["eh_costs"], 
#                                                 result_dict["bldgs"][bldg]["boi_costs"], 
#                                                 result_dict["bldgs"][bldg]["cc_costs"], 
#                                                 result_dict["bldgs"][bldg]["drc_costs"]))
#         curr += 1
       
#     row += curr + 3
        
#     worksheet.write(row+0, col_1, "Energy demands", big_bold)
#     worksheet.write_row(row+1, col_1, ("Building", 
#                                         "Space heating demand (MWh/a)", 
#                                         "Tap water demand (MWh/a)", 
#                                         "Cooling demand (MWh/a)", 
#                                         "Electricity demand (MWh/a)", 
#                                         "Gas demand (MWh/a)", 
#                                         "Balanced demands in building (%)", 
#                                         "Mean heat pump COP"), bold)
#     curr = 0
#     for bldg in result_dict["bldgs"].keys():
#         worksheet.write_row(row+2+curr, col_1, (
#         result_dict["bldgs"][bldg]["name"], 
#         result_dict["bldgs"][bldg]["total_heat_sh_dem"], 
#         result_dict["bldgs"][bldg]["total_heat_tap_dem"], 
#         result_dict["bldgs"][bldg]["total_cool_dem"], 
#         result_dict["bldgs"][bldg]["total_power_dem"], 
#         result_dict["bldgs"][bldg]["total_gas_dem"], 
#         result_dict["bldgs"][bldg]["DOC_BES"], 
#         result_dict["bldgs"][bldg]["HP_COP"]))
#         curr += 1
        
#     print("Line 232. (%f seconds.)" %(time.time() - start_time))
    
#     ########### TIME SERIES (BU) ###########
#     worksheet = workbook.add_worksheet("Energy demand")
#     worksheet.set_column(0, 20, 18)
#     row = 14
    
#     worksheet.write(row-1, col_1, "Balance:", right_bold)
#     worksheet.write_row(row-1, col_1+1, ("④", "④", "①", "③", "②", "①", "③", "②", ), center_bold)
#     worksheet.write_row(row+0, col_1+1, (
#     "Heat generation in BU (kW_th)", 
#     "Cold generation in BU (kW_th)", 
#     "Power demand total (kW_el) - electric power from the power grid (negative values indicate electricity feed-in to power grid", 
#     "Power demand buildings (kW_el) - electric power demand of heat pumps, chillers and electric heating rod in buildings", 
#     "Power demand BU (kW_el) - net electric power demand of BU (negative values indicate power generation in BU)", 
#     "Gas demand total (kW) - gas flow from the gas grid", 
#     "Gas demand buildings (kW) - gas flow to gas boilers in buildings", 
#     "Gas demand BU (kW) - gas flow to CHP unit and gas boiler in BU", ), bold)
    
#     worksheet.insert_image("D2", "ectoplanner/static/icons/Demand_flows_explanation.png", {'x_scale': 0.09, 'y_scale': 0.09})
#     # path on E.ON server: "/code/ectogrid/ectoplanner/static/icons/Demand_flows_explanation.png"

    
#     # add time step: DD.MM. weitere Spalte HH:00
#     time_steps = range(8760)
#     worksheet.write(row+1, col_1, "Sum (MWh/a)", right_bold)
#     worksheet.write_row(row+1, col_1+1, (
#     round(result_dict["BU_load_total"]["heat"]), 
#     round(result_dict["BU_load_total"]["cool"]), 
#     round(result_dict["total_el_from_grid"]-result_dict["total_el_to_grid"]),
#     round(result_dict["all_bldgs"]["total_power_dem_bldgs"]),
#     result_dict["total_el_to_BU"],
#     result_dict["total_gas"],
#     round(result_dict["all_bldgs"]["total_gas_dem_bldgs"]),
#     result_dict["total_gas_to_BU"],
#     ))
#     #worksheet.write_row(row+3, col_1, ("Day", "Month", "Hour"))
#     worksheet.write(row+3,col_1,"MM-DD HH:MM", bold)
    
#     #worksheet.write(0,col,"MM-DD HH:MM", bold)
#     time_stamps = pd.date_range('2019-01-01', periods=8760, freq='H').to_series()
#     #for t in t_8760:
#     #    worksheet.write(row+4+curr,col, str(time_stamps[t].strftime('%m-%d %H:%M')), bold)
    
#     # Write lines
#     curr = 0
#     for t in time_steps:
#         hour, day, month = get_hour_day_month(t)
#         worksheet.write_row(row+4+curr, col_1, (str(time_stamps[t].strftime('%m-%d %H:%M')), 
#         round(result_dict["BU_load"]["heat"][t]), 
#         round(result_dict["BU_load"]["cool"][t]), 
#         round(result_dict["power_from_grid"][t]-result_dict["power_to_grid"][t]), 
#         round(result_dict["BU_load"]["power"][t]), 
#         round(result_dict["power_from_grid"][t]-result_dict["power_to_grid"][t]-result_dict["BU_load"]["power"][t]), 
#         round(result_dict["gas"][t]), 
#         round(result_dict["BU_load"]["gas"][t]), 
#         round(result_dict["gas"][t]-result_dict["BU_load"]["gas"][t])))
#         curr += 1
        
        
#     ########### OPERATION BU ###########
#     worksheet = workbook.add_worksheet("Operation BU")
#     worksheet.set_column(0, 100, 18)
#     row = 0
#     worksheet.write_row(row+0, col_1, ("", 
#         "Reversible heat pump - heat generation (kW_th)", 
#         "Reversible heat pump - cold generation (kW_th)", 
#         "Reversible heat pump - power demand (kW_el)", 
#         "Heat pump - heat generation (kW_th)", 
#         "Heat pump - power demand (kW_el)", 
#         "Electric boiler - heat generation (kW_th)", 
#         "Electric boiler - power demand (kW_el)", 
#         "Compression chiller - cold generation (kW_th)", 
#         "Compression chiller - power demand (kW_el)", 
#         "Absorption chiller - cold generation (kW_th)", 
#         "Absorption chiller - thermal driving power (kW_th)",
#         "CHP unit - power generation (kW_el)", 
#         "CHP unit - heat generation (kW_th)",
#         "CHP unit - gas demand (kW)",
#         "Gas boiler - heat generation (kW_th)", 
#         "Gas boiler - gas demand (kW)",
#         "PV - power generation (kW_el)", 
#         "District heating - heat flow to BU (kW_th)", 
#         "District cooling - cold flow to BU (kW_th)", 
#         "Waste heat - heat flow to BU (kW_th)", 
#         "Waste heat - power demand of booster heat pump (kW_el)", 
#         "Waste cold - cold flow to BU (kW_th)", 
#         "Waste cold - power demand of additional chiller (kW_el)", 
#         "Accumulator - charging (>0), discharging (<0) (kW_th)",
#         "Accumulator - state of charge (kWh_th)",
#         "Battery - charging (>0), discharging (<0) (kW_el)",
#         "Battery - state of charge (kWh_el)",
#         "Heat storage - charging (>0), discharging (<0) (kW_th)",
#         "Heat storage - state of charge (kWh_th)",
#         "Cold storage - charging (>0), discharging (<0) (kW_th)",
#         "Cold storage - state of charge (kWh_th)",        
#         ), bold)

#     # add time step: DD.MM. weitere Spalte HH:00
#     time_steps = range(8760)
#     worksheet.write_row(row+1, col_1, ("Sum (MWh/a)",), right_bold)
#     worksheet.write_row(row+1, col_1+1, (
#     round(result_dict["flows"]["heat"]["RevHP"]["sum"]/1000), 
#     round(result_dict["flows"]["cool"]["RevHP"]["sum"]/1000), 
#     round(result_dict["flows"]["power"]["RevHP"]["sum"]/1000), 
#     round(result_dict["flows"]["heat"]["SimpHP"]["sum"]/1000), 
#     round(result_dict["flows"]["power"]["SimpHP"]["sum"]/1000), 
#     round(result_dict["flows"]["heat"]["EH"]["sum"]/1000), 
#     round(result_dict["flows"]["power"]["EH"]["sum"]/1000), 
#     round(result_dict["flows"]["cool"]["CC"]["sum"]/1000), 
#     round(result_dict["flows"]["power"]["CC"]["sum"]/1000), 
#     round(result_dict["flows"]["cool"]["AC"]["sum"]/1000), 
#     round(result_dict["flows"]["heat"]["AC"]["sum"]/1000), 
#     round(result_dict["flows"]["power"]["CHP"]["sum"]/1000), 
#     round(result_dict["flows"]["heat"]["CHP"]["sum"]/1000), 
#     round(result_dict["flows"]["gas"]["CHP"]["sum"]/1000), 
#     round(result_dict["flows"]["heat"]["BOI"]["sum"]/1000), 
#     round(result_dict["flows"]["gas"]["BOI"]["sum"]/1000), 
#     round(result_dict["flows"]["power"]["PV"]["sum"]/1000), 
#     round(result_dict["flows"]["heat"]["from_DH"]["sum"]/1000),
#     round(result_dict["flows"]["cool"]["from_DC"]["sum"]/1000),
#     round(result_dict["flows"]["heat"]["from_WASTE"]["sum"]/1000),
#     round(result_dict["flows"]["power"]["waste_heat_hp"]["sum"]/1000),
#     round(result_dict["flows"]["cool"]["from_WASTE_cold"]["sum"]/1000),
#     round(result_dict["flows"]["power"]["waste_cool_ch"]["sum"]/1000),
#     ))
    
    
#     worksheet.write_row(row+2, col_1, ("Max (kW)",), right_bold)
#     worksheet.write_row(row+2, col_1+1, (
#     round(result_dict["flows"]["heat"]["RevHP"]["max"]), 
#     round(result_dict["flows"]["cool"]["RevHP"]["max"]), 
#     round(result_dict["flows"]["power"]["RevHP"]["max"]), 
#     round(result_dict["flows"]["heat"]["SimpHP"]["max"]), 
#     round(result_dict["flows"]["power"]["SimpHP"]["max"]), 
#     round(result_dict["flows"]["heat"]["EH"]["max"]), 
#     round(result_dict["flows"]["power"]["EH"]["max"]), 
#     round(result_dict["flows"]["cool"]["CC"]["max"]), 
#     round(result_dict["flows"]["power"]["CC"]["max"]), 
#     round(result_dict["flows"]["cool"]["AC"]["max"]), 
#     round(result_dict["flows"]["heat"]["AC"]["max"]), 
#     round(result_dict["flows"]["power"]["CHP"]["max"]), 
#     round(result_dict["flows"]["heat"]["CHP"]["max"]), 
#     round(result_dict["flows"]["gas"]["CHP"]["max"]), 
#     round(result_dict["flows"]["heat"]["BOI"]["max"]), 
#     round(result_dict["flows"]["gas"]["BOI"]["max"]), 
#     round(result_dict["flows"]["power"]["PV"]["max"]), 
#     round(result_dict["flows"]["heat"]["from_DH"]["max"]),
#     round(result_dict["flows"]["cool"]["from_DC"]["max"]),
#     round(result_dict["flows"]["heat"]["from_WASTE"]["max"]),
#     round(result_dict["flows"]["power"]["waste_heat_hp"]["max"]),
#     round(result_dict["flows"]["cool"]["from_WASTE_cold"]["max"]),
#     round(result_dict["flows"]["power"]["waste_cool_ch"]["max"]),
#     ))
#     worksheet.write(row+3, col_1, ("MM-DD HH:MM"), right_bold)
    
#     # Write lines
#     curr = 0
#     for t in time_steps:
#         worksheet.write_row(row+4+curr, col_1, 
#         (str(time_stamps[t].strftime('%m-%d %H:%M')), 
#         round(result_dict["flows"]["heat"]["RevHP"][t]), 
#         round(result_dict["flows"]["cool"]["RevHP"][t]), 
#         round(result_dict["flows"]["power"]["RevHP"][t]), 
#         round(result_dict["flows"]["heat"]["SimpHP"][t]), 
#         round(result_dict["flows"]["power"]["SimpHP"][t]), 
#         round(result_dict["flows"]["heat"]["EH"][t]), 
#         round(result_dict["flows"]["power"]["EH"][t]), 
#         round(result_dict["flows"]["cool"]["CC"][t]), 
#         round(result_dict["flows"]["power"]["CC"][t]), 
#         round(result_dict["flows"]["cool"]["AC"][t]), 
#         round(result_dict["flows"]["heat"]["AC"][t]), 
#         round(result_dict["flows"]["power"]["CHP"][t]), 
#         round(result_dict["flows"]["heat"]["CHP"][t]), 
#         round(result_dict["flows"]["gas"]["CHP"][t]), 
#         round(result_dict["flows"]["heat"]["BOI"][t]), 
#         round(result_dict["flows"]["gas"]["BOI"][t]), 
#         round(result_dict["flows"]["power"]["PV"][t]), 
#         round(result_dict["flows"]["heat"]["from_DH"][t]),
#         round(result_dict["flows"]["cool"]["from_DC"][t]),
#         round(result_dict["flows"]["heat"]["from_WASTE"][t]),
#         round(result_dict["flows"]["power"]["waste_heat_hp"][t]),
#         round(result_dict["flows"]["cool"]["from_WASTE_cold"][t]),
#         round(result_dict["flows"]["power"]["waste_cool_ch"][t]),
#         round(result_dict["flows"]["ch_dch"]["ACC"][t]),
#         round(result_dict["flows"]["soc"]["ACC"][t]),
#         round(result_dict["flows"]["ch_dch"]["BAT"][t]),
#         round(result_dict["flows"]["soc"]["BAT"][t]),
#         round(result_dict["flows"]["ch_dch"]["TES"][t]),
#         round(result_dict["flows"]["soc"]["TES"][t]),
#         round(result_dict["flows"]["ch_dch"]["CTES"][t]),
#         round(result_dict["flows"]["soc"]["CTES"][t]),
#         ))
#         curr += 1
    
#     print("Line 444. (%f seconds.)" %(time.time() - start_time))
    
#     ########### INPUT PARAMETERS ###########
#     worksheet = workbook.add_worksheet("Input parameters")
#     worksheet.set_column(0, 0, 35)
#     worksheet.set_column(1, 1, 10)
#     row = 0
    
#     ### Heating system in buildings ###
#     worksheet.write_row(row+1, col_1, ("Building energy system", ), big_bold)
#     worksheet.write_row(row+3, col_1, ("Heat pumps in buildings", ""), bold_underl)
#     worksheet.write_row(row+4, col_1, ("Investment", devs_bldg["HP"]["inv_var"], "EUR/kW"), bold)
#     worksheet.write_row(row+5, col_1, ("Use constant COP", devs_bldg["HP"]["cop_is_const"], ""))
#     if devs_bldg["HP"]["cop_is_const"]:
#         worksheet.write_row(row+6, col_1, ("COP space heating", devs_bldg["HP"]["cop_const_space_heating"], ""), bold)
#         worksheet.write_row(row+7, col_1, ("COP tap water", devs_bldg["HP"]["cop_const_tap_water"], ""), bold)
#         row += 2
#     worksheet.write_row(row+6, col_1, ("Use carnot efficiency", devs_bldg["HP"]["cop_with_carnot"], ""))
#     if devs_bldg["HP"]["cop_with_carnot"]:
#         worksheet.write_row(row+7, col_1, ("Carnot efficiency", devs_bldg["HP"]["cop_carnot_eff"]*100, "%"), bold)
#         worksheet.write_row(row+8, col_1, ("Supply temperature space heating", devs_bldg["HP"]["temp_space_heating"], "°C"), bold)
#         worksheet.write_row(row+9, col_1, ("Supply temperature tap water", devs_bldg["HP"]["temp_tap_water"], "°C"), bold)
#         row += 3
    
#     worksheet.write_row(row+8, col_1, ("Auxiliary boilers in buildings", ), bold_underl)
#     worksheet.write_row(row+9, col_1, ("Install heating rod", devs_bldg["EH"]["enabled"], ""))
#     if devs_bldg["EH"]["enabled"]:
#         worksheet.write_row(row+10, col_1, ("Thermal efficiency", float(devs_bldg["EH"]["eta_th"]*100), "%"), bold)
#         worksheet.write_row(row+11, col_1, ("Investment", devs_bldg["EH"]["inv_var"], "EUR/kW_th"), bold)
#         worksheet.write_row(row+12, col_1, ("Cover of peak demand", float(devs_bldg["EH"]["peak_cover"]*100), "%"), bold)
#         row += 3
#     worksheet.write_row(row+10, col_1, ("Install gas boiler", devs_bldg["BOI"]["enabled"], ""))    
#     if devs_bldg["BOI"]["enabled"]:
#         worksheet.write_row(row+11, col_1, ("Thermal efficiency", float(devs_bldg["BOI"]["eta_th"]*100), "%"), bold)
#         worksheet.write_row(row+12, col_1, ("Investment", devs_bldg["BOI"]["inv_var"], "EUR/kW_th"), bold)
#         worksheet.write_row(row+13, col_1, ("Cover of peak demand", float(devs_bldg["BOI"]["peak_cover"]*100), "%"), bold)
#         row += 3
        
#     ### Cooling system in buildings ###
#     worksheet.write_row(row+12, col_1, ("Cooling system in buildings", ), bold_underl)
#     worksheet.write_row(row+13, col_1, ("Install chillers", devs_bldg["CC"]["enabled"], "")) 
#     if devs_bldg["CC"]["enabled"]:
#         worksheet.write_row(row+14, col_1, ("Investment", devs_bldg["CC"]["inv_var"], "EUR/kW_th"), bold)
#         worksheet.write_row(row+15, col_1, ("Use constant COP", devs_bldg["CC"]["cop_is_const"], ""))        
#         if devs_bldg["CC"]["cop_is_const"]: 
#             worksheet.write_row(row+16, col_1, ("Constant COP", devs_bldg["CC"]["cop_const"], ""), bold)
#             row += 1            
#         worksheet.write_row(row+16, col_1, ("Use carnot efficiency", devs_bldg["CC"]["cop_with_carnot"], ""))
#         if devs_bldg["CC"]["cop_with_carnot"]:
#             worksheet.write_row(row+17, col_1, ("Carnot efficiency", float(devs_bldg["CC"]["cop_carnot_eff"]*100), "%"), bold)
#             worksheet.write_row(row+18, col_1, ("Supply temperature space cooling", devs_bldg["CC"]["temp_cooling"], "°C"), bold)
#             row += 2
#         row += 3
#     worksheet.write_row(row+14, col_1, ("Install direct cooling", devs_bldg["DRC"]["enabled"], "")) 
#     if devs_bldg["DRC"]["enabled"]:
#         worksheet.write_row(row+15, col_1, ("Investment", devs_bldg["DRC"]["inv_var"], "EUR/kW_th"), bold)
#         row += 1
        
#     ### Location ###
#     worksheet.write_row(row+18, col_1, ("Location", ), big_bold)    
#     worksheet.write_row(row+20, col_1, ("Country", param["country"], ), bold)
#     worksheet.write_row(row+21, col_1, ("City", param["city"], ), bold)      
        
        
        
#     row = 0 
#     col_1 = 4
#     worksheet.set_column(col_1, col_1, 35)
#     worksheet.set_column(col_1+1, col_1+1, 10)
#     ### BU - Heating technologies ###
#     worksheet.write_row(row+1, col_1, ("Balancing unit", ), big_bold)
    
#     # REVERSIBLE HEAT PUMP
#     worksheet.write_row(row+3, col_1, ("Reversible heat pump", ), bold_underl)
#     if devs["RevHP"]["feasible"]:
#         worksheet.write_row(row+3, col_1+1, ("ENABLED", ), bold) 
#     else:
#         worksheet.write_row(row+3, col_1+1, ("DISABLED", ), bold)
    
#     if devs["RevHP"]["feasible"]:
#         worksheet.write_row(row+4, col_1, ("Minimum capacity", devs["RevHP"]["min_cap"], "kW_th"), bold)
#         worksheet.write_row(row+5, col_1, ("Maximum capacity", devs["RevHP"]["max_cap"], "kW_th"), bold)
#         worksheet.write_row(row+6, col_1, ("Ground source heat pump", devs["RevHP"]["cop_is_const"], ""))
#         if devs["RevHP"]["cop_is_const"]:
#             worksheet.write_row(row+7, col_1, ("Heating COP (constant)", devs["RevHP"]["cop_const_heat"], ""), bold)
#             worksheet.write_row(row+8, col_1, ("Cooling COP (constant)", devs["RevHP"]["cop_const_cool"], ""), bold)
#             row += 2
#         worksheet.write_row(row+7, col_1, ("Air source heat pump", devs["RevHP"]["is_ASHP"], ""))
#         if devs["RevHP"]["is_ASHP"]:
#             worksheet.write_row(row+8, col_1, ("Carnot efficiency", devs["RevHP"]["ASHP_carnot_eff"]*100, "%"), bold)
#             worksheet.write_row(row+9, col_1, ("Maximum COP (heating)", devs["RevHP"]["max_COP_heat"], ""), bold)
#             worksheet.write_row(row+10, col_1, ("Maximum COP (cooling)", devs["RevHP"]["max_COP_cool"], ""), bold)
#             row += 3
#         worksheet.write_row(row+8, col_1, ("Investment", devs["RevHP"]["inv_var"], "EUR/kW_th"), bold)
#         worksheet.write_row(row+9, col_1, ("Lifetime", devs["RevHP"]["life_time"], "years"), bold)
#         worksheet.write_row(row+10, col_1, ("Cost O&M", devs["RevHP"]["cost_om"]*100, "% of invest"), bold)
#         row += 7
    
#     # SIMPLE HEAT PUMP
#     worksheet.write_row(row+5, col_1, ("Heat pump (heating only)", ), bold_underl)
#     if devs["SimpHP"]["feasible"]:
#         worksheet.write_row(row+5, col_1+1, ("ENABLED", ), bold)
#     else:
#         worksheet.write_row(row+5, col_1+1, ("DISABLED", ), bold)        
#     if devs["SimpHP"]["feasible"]:
#         worksheet.write_row(row+6, col_1, ("Minimum capacity", devs["SimpHP"]["min_cap"], "kW_th"), bold)
#         worksheet.write_row(row+7, col_1, ("Maximum capacity", devs["SimpHP"]["max_cap"], "kW_th"), bold)
#         worksheet.write_row(row+8, col_1, ("Ground source heat pump", devs["SimpHP"]["cop_is_const"], ""))
#         if devs["SimpHP"]["cop_is_const"]:
#             worksheet.write_row(row+9, col_1, ("Heating COP (constant)", devs["SimpHP"]["cop_const"], ""), bold)
#             row += 1
#         worksheet.write_row(row+9, col_1, ("Air source heat pump", devs["SimpHP"]["is_ASHP"], ""))
#         if devs["SimpHP"]["is_ASHP"]:
#             worksheet.write_row(row+10, col_1, ("Carnot efficiency", devs["SimpHP"]["ASHP_carnot_eff"]*100, "%"), bold)
#             worksheet.write_row(row+11, col_1, ("Maximum COP", devs["SimpHP"]["max_COP"], ""), bold)
#             row += 2
#         worksheet.write_row(row+10, col_1, ("Investment", devs["SimpHP"]["inv_var"], "EUR/kW_th"), bold)
#         worksheet.write_row(row+11, col_1, ("Lifetime", devs["SimpHP"]["life_time"], "years"), bold)
#         worksheet.write_row(row+12, col_1, ("Cost O&M", devs["SimpHP"]["cost_om"]*100, "% of invest"), bold)
#         row += 7
    
#     # ELECTRIC BOILER
#     worksheet.write_row(row+7, col_1, ("Electric boiler", ), bold_underl)
#     if devs["EH"]["feasible"]:
#         worksheet.write_row(row+7, col_1+1, ("ENABLED", ), bold)
#     else:
#         worksheet.write_row(row+7, col_1+1, ("DISABLED", ), bold)
#     if devs["EH"]["feasible"]:    
#         worksheet.write_row(row+8, col_1, ("Minimum capacity", devs["EH"]["min_cap"], "kW_th"), bold)
#         worksheet.write_row(row+9, col_1, ("Maximum capacity", devs["EH"]["max_cap"], "kW_th"), bold)
#         worksheet.write_row(row+10, col_1, ("Thermal efficiency", devs["EH"]["eta_th"]*100, "%"), bold)
#         worksheet.write_row(row+11, col_1, ("Investment", devs["EH"]["inv_var"], "EUR/kW_th"), bold)
#         worksheet.write_row(row+12, col_1, ("Lifetime", devs["EH"]["life_time"], "years"), bold)
#         worksheet.write_row(row+13, col_1, ("Cost O&M", devs["EH"]["cost_om"]*100, "% of invest"), bold)
#         row += 6
        
#     ### BU - Chiller technologies ###
#     # COMPRESSION CHILLER
#     worksheet.write_row(row+9, col_1, ("Compression chiller", ), bold_underl)
#     if devs["CC"]["feasible"]:
#         worksheet.write_row(row+9, col_1+1, ("ENABLED", ), bold)
#     else:
#         worksheet.write_row(row+9, col_1+1, ("DISABLED", ), bold)
#     if devs["CC"]["feasible"]:    
#         worksheet.write_row(row+10, col_1, ("Minimum capacity", devs["CC"]["min_cap"], "kW_th"), bold)
#         worksheet.write_row(row+11, col_1, ("Maximum capacity", devs["CC"]["max_cap"], "kW_th"), bold)
#         worksheet.write_row(row+12, col_1, ("Use constant COP ", devs["CC"]["cop_is_const"], ""))
#         if devs["CC"]["cop_is_const"]:
#             worksheet.write_row(row+13, col_1, ("COP (constant)", devs["CC"]["cop_const"], ""), bold)
#             row += 1
#         worksheet.write_row(row+13, col_1, ("Use carnot efficiency", devs["CC"]["cop_with_carnot"], ""))
#         if devs["CC"]["cop_with_carnot"]:
#             worksheet.write_row(row+14, col_1, ("Carnot efficiency", devs["CC"]["cop_carnot_eff"]*100, "%"), bold)
#             worksheet.write_row(row+15, col_1, ("Maximum COP", devs["CC"]["max_COP"], ""), bold)
#             row += 2
#         worksheet.write_row(row+14, col_1, ("Investment", devs["CC"]["inv_var"], "EUR/kW_th"), bold)
#         worksheet.write_row(row+15, col_1, ("Lifetime", devs["CC"]["life_time"], "years"), bold)
#         worksheet.write_row(row+16, col_1, ("Cost O&M", devs["CC"]["cost_om"]*100, "% of invest"), bold)
#         row += 7
        
#     # ABSORPTION CHILLER
#     worksheet.write_row(row+11, col_1, ("Absorption chiller", ), bold_underl)
#     if devs["AC"]["feasible"]:
#         worksheet.write_row(row+11, col_1+1, ("ENABLED", ), bold)
#     else:
#         worksheet.write_row(row+11, col_1+1, ("DISABLED", ), bold)
#     if devs["AC"]["feasible"]:    
#         worksheet.write_row(row+12, col_1, ("Minimum capacity", devs["AC"]["min_cap"], "kW_th"), bold)
#         worksheet.write_row(row+13, col_1, ("Maximum capacity", devs["AC"]["max_cap"], "kW_th"), bold)
#         worksheet.write_row(row+14, col_1, ("Thermal efficiency", devs["AC"]["eta_th"]*100, "%"), bold)
#         worksheet.write_row(row+15, col_1, ("Investment", devs["AC"]["inv_var"], "EUR/kW"), bold)
#         worksheet.write_row(row+16, col_1, ("Lifetime", devs["AC"]["life_time"], "years"), bold)
#         worksheet.write_row(row+17, col_1, ("Cost O&M", devs["AC"]["cost_om"]*100, "% of invest"), bold)
#         row += 6
        
#     # CHP
#     worksheet.write_row(row+13, col_1, ("CHP unit", ), bold_underl)
#     if devs["CHP"]["feasible"]:
#         worksheet.write_row(row+13, col_1+1, ("ENABLED", ), bold)
#     else:
#         worksheet.write_row(row+13, col_1+1, ("DISABLED", ), bold)
#     if devs["CHP"]["feasible"]:    
#         worksheet.write_row(row+14, col_1, ("Minimum capacity", devs["CHP"]["min_cap"], "kW_el"), bold)
#         worksheet.write_row(row+15, col_1, ("Maximum capacity", devs["CHP"]["max_cap"], "kW_el"), bold)
#         worksheet.write_row(row+16, col_1, ("Electric efficiency", devs["CHP"]["eta_el"]*100, "%"), bold)
#         worksheet.write_row(row+17, col_1, ("Thermal efficiency", devs["CHP"]["eta_th"]*100, "%"), bold)
#         worksheet.write_row(row+18, col_1, ("Investment", devs["CHP"]["inv_var"], "EUR/kW_el"), bold)
#         worksheet.write_row(row+19, col_1, ("Lifetime", devs["CHP"]["life_time"], "years"), bold)
#         worksheet.write_row(row+20, col_1, ("Cost O&M", devs["CHP"]["cost_om"]*100, "% of invest"), bold)
#         row += 7
        
#     # GAS BOILER
#     worksheet.write_row(row+15, col_1, ("Gas boiler", ), bold_underl)
#     if devs["BOI"]["feasible"]:
#         worksheet.write_row(row+15, col_1+1, ("ENABLED", ), bold)
#     else:
#         worksheet.write_row(row+15, col_1+1, ("DISABLED", ), bold)
#     if devs["BOI"]["feasible"]:    
#         worksheet.write_row(row+16, col_1, ("Minimum capacity", devs["BOI"]["min_cap"], "kW_th"), bold)
#         worksheet.write_row(row+17, col_1, ("Maximum capacity", devs["BOI"]["max_cap"], "kW_th"), bold)
#         worksheet.write_row(row+18, col_1, ("Thermal efficiency", devs["BOI"]["eta_th"]*100, "%"), bold)
#         worksheet.write_row(row+19, col_1, ("Investment", devs["BOI"]["inv_var"], "EUR/kW"), bold)
#         worksheet.write_row(row+20, col_1, ("Lifetime", devs["BOI"]["life_time"], "years"), bold)
#         worksheet.write_row(row+21, col_1, ("Cost O&M", devs["BOI"]["cost_om"]*100, "% of invest"), bold)
#         row += 6
        
#     # PHOTOVOLTAICS
#     worksheet.write_row(row+17, col_1, ("Photovoltaics", ), bold_underl)
#     if devs["PV"]["feasible"]:
#         worksheet.write_row(row+17, col_1+1, ("ENABLED", ), bold)
#     else:
#         worksheet.write_row(row+17, col_1+1, ("DISABLED", ), bold)
#     if devs["PV"]["feasible"]:    
#         worksheet.write_row(row+18, col_1, ("Minimum PV area", devs["PV"]["min_area"], "m2"), bold)
#         worksheet.write_row(row+19, col_1, ("Maximum PV area", devs["PV"]["max_area"], "m2"), bold)
#         worksheet.write_row(row+20, col_1, ("Module efficiency", devs["PV"]["eta"]*100, "%"), bold)
#         worksheet.write_row(row+21, col_1, ("Investment", devs["PV"]["inv_var"], "EUR/kW"), bold)
#         worksheet.write_row(row+22, col_1, ("Lifetime", devs["PV"]["life_time"], "years"), bold)
#         worksheet.write_row(row+23, col_1, ("Cost O&M", devs["PV"]["cost_om"]*100, "% of invest"), bold)
#         row += 6
    
    
    
#     row = 0 
#     col_1 = 8
#     worksheet.set_column(col_1, col_1, 35)
#     worksheet.set_column(col_1+1, col_1+1, 10)
#     ### BU - Heating technologies ###
#     worksheet.write_row(row+1, col_1, ("Balancing unit", ), big_bold)
    
#     # ACCUMULATOR TANK
#     worksheet.write_row(row+3, col_1, ("Accumulator tank", ), bold_underl)
#     if devs["ACC"]["feasible"]:
#         worksheet.write_row(row+3, col_1+1, ("ENABLED", ), bold) 
#     else:
#         worksheet.write_row(row+3, col_1+1, ("DISABLED", ), bold)
    
#     if devs["ACC"]["feasible"]:
#         worksheet.write_row(row+4, col_1, ("Minimum volume", devs["ACC"]["min_vol"], "m3"), bold)
#         worksheet.write_row(row+5, col_1, ("Maximum volume", devs["ACC"]["max_vol"], "m3"), bold)
#         worksheet.write_row(row+6, col_1, ("Investment", devs["ACC"]["inv_var_per_m3"], "EUR/m3"), bold)
#         worksheet.write_row(row+7, col_1, ("Lifetime", devs["ACC"]["life_time"], "years"), bold)
#         worksheet.write_row(row+8, col_1, ("Cost O&M", devs["ACC"]["cost_om"]*100, "% of invest"), bold)
#         row += 5
        
#     # BATTERY
#     worksheet.write_row(row+5, col_1, ("Battery", ), bold_underl)
#     if devs["BAT"]["feasible"]:
#         worksheet.write_row(row+5, col_1+1, ("ENABLED", ), bold) 
#     else:
#         worksheet.write_row(row+5, col_1+1, ("DISABLED", ), bold)
    
#     if devs["BAT"]["feasible"]:
#         worksheet.write_row(row+6, col_1, ("Minimum capacity", devs["BAT"]["min_cap"], "kWh"), bold)
#         worksheet.write_row(row+7, col_1, ("Maximum capacity", devs["BAT"]["max_cap"], "kWh"), bold)
#         worksheet.write_row(row+8, col_1, ("Investment", devs["BAT"]["inv_var"], "EUR/kWh"), bold)
#         worksheet.write_row(row+9, col_1, ("Lifetime", devs["BAT"]["life_time"], "years"), bold)
#         worksheet.write_row(row+10, col_1, ("Cost O&M", devs["BAT"]["cost_om"]*100, "% of invest"), bold)
#         row += 5
        
#     # HEAT STORAGE
#     worksheet.write_row(row+7, col_1, ("Heat storage", ), bold_underl)
#     if devs["TES"]["feasible"]:
#         worksheet.write_row(row+7, col_1+1, ("ENABLED", ), bold) 
#     else:
#         worksheet.write_row(row+7, col_1+1, ("DISABLED", ), bold)
    
#     if devs["TES"]["feasible"]:
#         worksheet.write_row(row+8, col_1, ("Minimum capacity", devs["TES"]["min_cap"], "kWh"), bold)
#         worksheet.write_row(row+9, col_1, ("Maximum capacity", devs["TES"]["max_cap"], "kWh"), bold)
#         worksheet.write_row(row+10, col_1, ("Investment", devs["TES"]["inv_var"], "EUR/kWh"), bold)
#         worksheet.write_row(row+11, col_1, ("Lifetime", devs["TES"]["life_time"], "years"), bold)
#         worksheet.write_row(row+12, col_1, ("Cost O&M", devs["TES"]["cost_om"]*100, "% of invest"), bold)
#         worksheet.write_row(row+13, col_1, ("Storage loss", devs["TES"]["sto_loss"]*100, "% per hour"), bold)
#         row += 6
        
#     # COLD STORAGE
#     worksheet.write_row(row+9, col_1, ("Cold storage", ), bold_underl)
#     if devs["CTES"]["feasible"]:
#         worksheet.write_row(row+9, col_1+1, ("ENABLED", ), bold) 
#     else:
#         worksheet.write_row(row+9, col_1+1, ("DISABLED", ), bold)
    
#     if devs["CTES"]["feasible"]:
#         worksheet.write_row(row+10, col_1, ("Minimum capacity", devs["CTES"]["min_cap"], "kWh"), bold)
#         worksheet.write_row(row+11, col_1, ("Maximum capacity", devs["CTES"]["max_cap"], "kWh"), bold)
#         worksheet.write_row(row+12, col_1, ("Investment", devs["CTES"]["inv_var"], "EUR/kWh"), bold)
#         worksheet.write_row(row+13, col_1, ("Lifetime", devs["CTES"]["life_time"], "years"), bold)
#         worksheet.write_row(row+14, col_1, ("Cost O&M", devs["CTES"]["cost_om"]*100, "% of invest"), bold)
#         worksheet.write_row(row+15, col_1, ("Storage loss", devs["CTES"]["sto_loss"]*100, "% per hour"), bold)
#         row += 6
        
        
#     row = 0 
#     col_1 = 12
#     worksheet.set_column(col_1, col_1, 35)
#     worksheet.set_column(col_1+1, col_1+1, 10)
#     ### BU - Other sources ###
#     worksheet.write_row(row+1, col_1, ("Other sources", ), big_bold)    
        
#     # DISTRICT HEATING
#     worksheet.write_row(row+3, col_1, ("District heating", ), bold_underl)
#     if devs["from_DH"]["feasible"]:
#         worksheet.write_row(row+3, col_1+1, ("ENABLED", ), bold) 
#     else:
#         worksheet.write_row(row+3, col_1+1, ("DISABLED", ), bold)
    
#     if devs["from_DH"]["feasible"]:
#         worksheet.write_row(row+4, col_1, ("Capacity of district heating connection", devs["from_DH"]["max_cap"], "kW"), bold)
#         worksheet.write_row(row+5, col_1, ("Price", devs["from_DH"]["price_DH"], "EUR/kWh"), bold)
#         worksheet.write_row(row+6, col_1, ("Consider annual supply limit", devs["from_DH"]["enable_supply_limit"], ""))
#         if devs["from_DH"]["enable_supply_limit"]:
#             worksheet.write_row(row+7, col_1, ("Annual supply limit", devs["from_DH"]["supply_limit"]/1000, "MWh/a"), bold)
#             row += 1
#         row += 3
        
#     # DISTRICT COOLING
#     worksheet.write_row(row+5, col_1, ("District cooling", ), bold_underl)
#     if devs["from_DC"]["feasible"]:
#         worksheet.write_row(row+5, col_1+1, ("ENABLED", ), bold) 
#     else:
#         worksheet.write_row(row+5, col_1+1, ("DISABLED", ), bold)
    
#     if devs["from_DC"]["feasible"]:
#         worksheet.write_row(row+6, col_1, ("Capacity of district cooling connection", devs["from_DC"]["max_cap"], "kW"), bold)
#         worksheet.write_row(row+7, col_1, ("Price", devs["from_DC"]["price_DC"], "EUR/kWh"), bold)
#         worksheet.write_row(row+8, col_1, ("Consider annual supply limit", devs["from_DC"]["enable_supply_limit"], ""))
#         if devs["from_DC"]["enable_supply_limit"]:
#             worksheet.write_row(row+9, col_1, ("Annual supply limit", devs["from_DC"]["supply_limit"]/1000, "MWh/a"), bold)
#             row += 1
#         row += 3    
        
#     # WASTE HEAT
#     worksheet.write_row(row+7, col_1, ("Waste heat", ), bold_underl)
#     if devs["from_WASTE"]["feasible"]:
#         worksheet.write_row(row+7, col_1+1, ("ENABLED", ), bold) 
#     else:
#         worksheet.write_row(row+7, col_1+1, ("DISABLED", ), bold)
    
#     if devs["from_WASTE"]["feasible"]:
#         worksheet.write_row(row+8, col_1, ("Available heating power", devs["from_WASTE"]["available_power"], "kW"), bold)
#         worksheet.write_row(row+9, col_1, ("Price", devs["from_WASTE"]["price"], "EUR/kWh"), bold)
#         worksheet.write_row(row+10, col_1, ("Install booster heat pump", devs["from_WASTE"]["enable_hp"], ""))
#         if devs["from_WASTE"]["enable_hp"]:
#             worksheet.write_row(row+11, col_1, ("COP heat pump", devs["from_WASTE"]["cop_hp"], ""), bold)
#             row += 1
#         row += 3    
        
#     # WASTE COLD
#     worksheet.write_row(row+9, col_1, ("Waste cold", ), bold_underl)
#     if devs["from_WASTE_cold"]["feasible"]:
#         worksheet.write_row(row+9, col_1+1, ("ENABLED", ), bold) 
#     else:
#         worksheet.write_row(row+9, col_1+1, ("DISABLED", ), bold)
    
#     if devs["from_WASTE_cold"]["feasible"]:
#         worksheet.write_row(row+10, col_1, ("Available cooling power", devs["from_WASTE_cold"]["available_power"], "kW"), bold)
#         worksheet.write_row(row+10, col_1, ("Price", devs["from_WASTE_cold"]["price"], "EUR/kWh"), bold)
#         worksheet.write_row(row+11, col_1, ("Install additional chiller", devs["from_WASTE_cold"]["enable_chiller"], ""))
#         if devs["from_WASTE_cold"]["enable_chiller"]:
#             worksheet.write_row(row+12, col_1, ("COP chiller", devs["from_WASTE_cold"]["cop_chiller"], ""), bold)
#             row += 1
#         row += 3    
    
    
#     row = 0 
#     col_1 = 16
#     worksheet.set_column(col_1, col_1, 35)
#     worksheet.set_column(col_1+1, col_1+1, 10)
    
#     ### MODEL PARAMETERS ###
#     worksheet.write_row(row+1, col_1, ("Model parameters", ), big_bold)    
        
#     worksheet.write_row(row+3, col_1, ("Temperature of warm pipe", param["netw_temp_warm_pipe"], "°C"), bold)
#     worksheet.write_row(row+4, col_1, ("Temperature of cold pipe", param["netw_temp_cold_pipe"], "°C"), bold)
#     worksheet.write_row(row+5, col_1, ("Consider network costs", param["enable_netw_costs"], ""))
#     if param["enable_netw_costs"]:
#         worksheet.write_row(row+6, col_1, ("Network length", param["network_length"], "km"), bold)
#         worksheet.write_row(row+7, col_1, ("Costs earthworks and installation", param["costs_earth_work"], "EUR/m"), bold)
#         worksheet.write_row(row+8, col_1, ("Costs pipe material", param["costs_pipe"], "EUR/m"), bold)
#         row += 3
#     worksheet.write_row(row+6, col_1, ("Natural gas price", param["price_gas"], "EUR/kWh"), bold) 
#     worksheet.write_row(row+7, col_1, ("Electricity price", param["price_el"], "EUR/kWh"), bold) 
#     worksheet.write_row(row+8, col_1, ("Enable feed-in", param["feasible_feed_in"], ""))     
#     if param["enable_netw_costs"]:
#         worksheet.write_row(row+9, col_1, ("Feed-in tariff", param["revenue_feed_in"], "EUR/kWh"), bold) 
#         row += 1
#     worksheet.write_row(row+9, col_1, ("Interest rate", param["interest_rate"]*100, "%"), bold)
#     worksheet.write_row(row+10, col_1, ("Project lifetime", param["observation_time"], "years"), bold)
#     worksheet.write_row(row+11, col_1, ("CO₂ emissions natural gas", param["gas_CO2_emission"], "kg/kWh"), bold)
#     worksheet.write_row(row+12, col_1, ("CO₂ emissions power grid", param["grid_CO2_emission"], "kg/kWh"), bold)
    
#     worksheet.write_row(row+14, col_1, ("Fix parameters", ), big_bold)
#     worksheet.write_row(row+15, col_1, ("Heat capacity (water)", param["c_w"], "kJ/(kg K)"), bold)
#     worksheet.write_row(row+16, col_1, ("Density (water)", param["rho_w"], "kg/m3"), bold)


#     ### Economic Parameters ###
#     if param["enable_scenario"] == True:
#         worksheet.write_row(row+18, col_1, ("Economic Parameters",), big_bold)
#         worksheet.write_row(row+19, col_1, ("Interest rate", param["interest_rate"]*100,"%/a"), bold)
#         worksheet.write_row(row+20, col_1, ("Project lifetime", param["observation_time"],"years"), bold)
#         worksheet.write_row(row+21, col_1, ("Tax rate", param["tax_rate"], "%"), bold)
#         worksheet.write_row(row+22, col_1, ("Scenario chosen",param["scenario"]),bold)

#         worksheet.write_row(row+24, col_1, ("Electricity price",), bold) 
#         worksheet.write_row(row+25, col_1, ("Initial wholesale market price", param["price_ex_el"],"EUR/kWh"), bold) 
#         worksheet.write_row(row+26, col_1, ("Yearly wholesale price change rate", param["price_growth_el"],"%/a"), bold)
#         worksheet.write_row(row+27, col_1, ("Initial grid surcharge", param["price_grid_el"], "EUR/kWh"), bold)
#         worksheet.write_row(row+28, col_1, ("Yearly grid surcharge growth rate", param["grid_growth_el"]*100,"%/a"), bold)
#         worksheet.write_row(row+29, col_1, ("Environmental surcharge", param["env_surcharge"], "EUR/kWh"), bold) 
#         worksheet.write_row(row+30, col_1, ("Other surcharge", param["oth_surcharge"], "EUR/kWh"), bold) 

#         worksheet.write_row(row+32, col_1, ("Gas price",), bold) 
#         worksheet.write_row(row+33, col_1, ("Initial wholesale market price", param["price_ex_gas"], "EUR/kWh"), bold)
#         worksheet.write_row(row+34, col_1, ("Yearly wholesale price change rate", param["price_growth_gas"]*100,"%/a"), bold)
#         worksheet.write_row(row+35, col_1, ("Initial grid surcharge", param["price_grid_gas"], "EUR/kWh"), bold)
#         worksheet.write_row(row+36, col_1, ("Yearly grid surcharge growth rate", param["grid_growth_gas"]*100,"%/a"), bold)


#     print("Line 841. (%f seconds.)" %(time.time() - start_time))
#     row = 0 
#     col_1 = 20
#     worksheet.set_column(col_1, 100, 10)
#     ### WEATHER DATA ###
#     worksheet.write_row(row+1, col_1, ("Weather data and COPs", ), big_bold)
#     worksheet.write_row(row+3, col_1, 
#     ("MM-DD HH:MM", 
#     "Ambient air temperature (°C)", 
#     "Solar irradiance (W/m2)", 
#     "COP HP bldgs (space heating)", 
#     "COP HP bldgs (tap water)",), bold)
#     for t in time_steps:
#         worksheet.write_row(row+4, col_1, (
#         str(time_stamps[t].strftime('%m-%d %H:%M')), 
#         param["air_temp"][t], 
#         param["GHI"][t],
#         round(devs_bldg["HP"]["COP_space_heating"][t],2),
#         round(devs_bldg["HP"]["COP_tap_water"][t],2),
#         ))
#         row += 1
    
#     row = 0 
#     if devs_bldg["CC"]["enabled"]:
#         worksheet.write_row(row+3, col_1+5, ("COP chiller bldgs (cooling)", ), bold)
#         for t in time_steps:
#             worksheet.write_row(row+4, col_1+5, (round(devs_bldg["CC"]["COP"][t],2), ))
#             row += 1
#         col_1 += 1
            
#     row = 0 
#     if devs["RevHP"]["feasible"]:
#         worksheet.write_row(row+3, col_1+5, ("COP (heating) Rev HP (BU)", "COP (cooling) Rev HP (BU)"), bold)
#         for t in time_steps:
#             worksheet.write_row(row+4, col_1+5, (round(devs["RevHP"]["COP_heat"][t],2), round(devs["RevHP"]["COP_cool"][t],2)))
#             row += 1
#         col_1 += 2
    
#     row = 0 
#     if devs["SimpHP"]["feasible"]:
#         worksheet.write_row(row+3, col_1+5, ("COP HP (heating only) (BU)", ), bold)
#         for t in time_steps:
#             worksheet.write_row(row+4, col_1+5, (round(devs["SimpHP"]["COP_heat"][t],2), ))
#             row += 1
#         col_1 += 1
            
#     row = 0 
#     if devs["CC"]["feasible"]:
#         worksheet.write_row(row+3, col_1+5, ("COP Compression chiller (BU)", ), bold)
#         for t in time_steps:
#             worksheet.write_row(row+4, col_1+5, (round(devs["CC"]["COP"][t],2), ))
#             row += 1
#         col_1 += 1
    
#     ########### INPUT DEMAND DATA ###########    
#     worksheet = workbook.add_worksheet("Detailed building data")
#     worksheet.set_column(0, 100, 12)
#     row = 0

#     f_sh = workbook.add_format({"fg_color": "ffc5b8"})
#     f_tap = workbook.add_format({"fg_color": "eb8c81"})
#     f_cool = workbook.add_format({"fg_color": "c2d1ed"})
#     f_power = workbook.add_format({"fg_color": "bfe3be"})
#     f_gas = workbook.add_format({"fg_color": "f5e5b2"})
    
#     worksheet.write(2, 0, "Sum (MWh/a)", right_bold)
#     worksheet.write(3, 0, "Max (kW)", right_bold)
#     worksheet.write(4, 0, "MM-DD HH:MM", right_bold)
#     for t in time_steps:
#         worksheet.write(t+5, 0, str(time_stamps[t].strftime('%m-%d %H:%M')))
        
#     col = 1
#     for n in nodes.keys():
#         # Building name
#         worksheet.write(0, col, nodes[n]["name"], bold)
        
#         # Space heating demand
#         worksheet.write(1, col, "Space heating demand - input data (kW_th)", f_sh)
#         worksheet.write(2, col, round(np.sum(nodes[n]["heat_sh"])/1000,2), f_sh)
#         worksheet.write(3, col, round(np.max(nodes[n]["heat_sh"]),2), f_sh)
#         for t in time_steps:
#             worksheet.write(t+5, col, round(nodes[n]["heat_sh"][t],2), f_sh)

#         # Tap water demand
#         worksheet.write(1, col+1, "Tap water demand - input data(kW_th)", f_tap)
#         worksheet.write(2, col+1, round(np.sum(nodes[n]["heat_tap"])/1000,2), f_tap)
#         worksheet.write(3, col+1, round(np.max(nodes[n]["heat_tap"]),2), f_tap)
#         for t in time_steps:
#             worksheet.write(t+5, col+1, round(nodes[n]["heat_tap"][t],2), f_tap)

#         # Heat pump
#         worksheet.write(1, col+2, "Heat pump - heat generation (including tap water) (kW_th)")
#         worksheet.write(2, col+2, round(np.sum(nodes[n]["heat_HP"])/1000,2))
#         worksheet.write(3, col+2, round(np.max(nodes[n]["heat_HP"]),2))
#         for t in time_steps:
#             worksheet.write(t+5, col+2, round(nodes[n]["heat_HP"][t],2))
        
#         # Electric heating rod (space heating)
#         if devs_bldg["EH"]["enabled"]:
#             worksheet.write(1, col+3, "Electric heating rod - heat generation space heating (kW_th)")
#             worksheet.write(2, col+3, round(np.sum(nodes[n]["heat_EH"])/1000,2))
#             worksheet.write(3, col+3, round(np.max(nodes[n]["heat_EH"]),2))
#             for t in time_steps:
#                 worksheet.write(t+5, col+3, round(nodes[n]["heat_EH"][t],2))
#             col += 1
        
#         # Gas boiler (space heating)        
#         if devs_bldg["BOI"]["enabled"]:
#             worksheet.write(1, col+3, "Gas boiler - heat generation space heating (kW_th)")
#             worksheet.write(2, col+3, round(np.sum(nodes[n]["heat_BOI"])/1000,2))
#             worksheet.write(3, col+3, round(np.max(nodes[n]["heat_BOI"]),2))
#             for t in time_steps:
#                 worksheet.write(t+5, col+3, round(nodes[n]["heat_BOI"][t],2))
#             col += 1
        
#         # Cooling demand
#         worksheet.write(1, col+3, "Cooling demand - input data(kW)", f_cool)
#         worksheet.write(2, col+3, round(np.sum(nodes[n]["cool"])/1000,2), f_cool)
#         worksheet.write(3, col+3, round(np.max(nodes[n]["cool"]),2), f_cool)
#         for t in time_steps:
#             worksheet.write(t+5, col+3, round(nodes[n]["cool"][t],2), f_cool)
        
#         # Chiller
#         if devs_bldg["CC"]["enabled"]:
#             worksheet.write(1, col+4, "Chiller - Cold generation (kW_th)")
#             worksheet.write(2, col+4, round(np.sum(nodes[n]["cool_CC"])/1000,2))
#             worksheet.write(3, col+4, round(np.max(nodes[n]["cool_CC"]),2))
#             for t in time_steps:
#                 worksheet.write(t+5, col+4, round(nodes[n]["cool_CC"][t],2))
            
#         # Direct cooling
#         if devs_bldg["DRC"]["enabled"]:
#             worksheet.write(1, col+4, "Direct cooling (kW_th)")
#             worksheet.write(2, col+4, round(np.sum(nodes[n]["cool_DRC"])/1000,2))
#             worksheet.write(3, col+4, round(np.max(nodes[n]["cool_DRC"]),2))
#             for t in time_steps:
#                 worksheet.write(t+5, col+4, round(nodes[n]["cool_DRC"][t],2))
        
#         # Power demand
#         worksheet.write(1, col+5, "Power demand - Heat pump, chiller and electric heating rod (kW_el)", f_power)
#         worksheet.write(2, col+5, round(np.sum(nodes[n]["power_HP"] + nodes[n]["power_EH"] + nodes[n]["power_CC"])/1000,2), f_power)
#         worksheet.write(3, col+5, round(np.max(nodes[n]["power_HP"] + nodes[n]["power_EH"] + nodes[n]["power_CC"]),2), f_power)
#         for t in time_steps:
#             worksheet.write(t+5, col+5, round(nodes[n]["power_HP"][t] + nodes[n]["power_EH"][t] + nodes[n]["power_CC"][t],2), f_power)
        
#         # Gas demand
#         if devs_bldg["BOI"]["enabled"]:
#             worksheet.write(1, col+6, "Gas demand - gas boiler (kW)", f_gas)
#             worksheet.write(2, col+6, round(np.sum(nodes[n]["gas_BOI"])/1000,2), f_gas)
#             worksheet.write(3, col+6, round(np.max(nodes[n]["gas_BOI"]),2), f_gas)
#             for t in time_steps:
#                 worksheet.write(t+5, col+6, round(nodes[n]["gas_BOI"][t],2),f_gas)
#             col += 1
            
#         col += 8
    
#     workbook.close()
    
#     print("Excel file created. (%f seconds.)" %(time.time() - start_time))
    
#     return flags

    
# def get_hour_day_month(t):
    
#     start_day = np.array([0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334])
#     end_day = np.array([31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365])
    
#     t_int = int(t/24)+1
    
#     for m in range(len(start_day)):
#         if t_int >= start_day[m] and t_int <= end_day[m]:
#             return (t-int(t/24)*24)+1, (t_int-start_day[m]), m+1   # hour, day, month
    