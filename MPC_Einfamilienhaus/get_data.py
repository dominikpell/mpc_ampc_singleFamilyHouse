# -*- coding: utf-8 -*-
"""

ECTOCONTROL

Developed by:  E.ON Energy Research Center, 
               Institute for Energy Efficient Buildings and Indoor Climate, 
               RWTH Aachen University, 
               Germany

Developed in:  2021

"""


# Initial values at begin of first mpc loop (1st Janaury, 0:00)
def get_soc_data(run, results_dict):
    input_data = {}
    for storage_type in ["TES", "DHW", "BAT"]:
        if run == 0:
            input_data[storage_type] = 0  # SOC of storage is zero
        else:
            input_data[storage_type] = results_dict["SOC_" + storage_type][-1]
    return input_data
    
