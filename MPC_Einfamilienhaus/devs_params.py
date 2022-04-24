
def load_battery_params(battery_type, requested_capacity):
    if battery_type == "Li-Ion Viessmann/4.7kWh":
        data = {
        "Identifier": 1,
        "SOC_min": 0.2,             # -
        "eta_ch": 0.93,             # -,        charging efficiency
        "eta_dch": 0.93,            # -,        discharging efficiency
        "sto_loss": 0.1/24,         # 1/h,      standby losses per hour
        "P_ch_max": 2850,           # W,        maximum charging power
        "P_dch_max": 2850,          # W,        maximum discharching power
        "unit_cap": 4.7 * 1000,     # Wh        BAT storage capacity
    }
    elif battery_type == "Lead Acid CLH/2.4kWh":
        data = {
        "Identifier": 2,
        "SOC_min": 0.2,         # -
        "eta_ch": 0.92736,      # -,        charging efficiency
        "eta_dch": 0.92736,     # -,        discharging efficiency
        "sto_loss": 0.01/(7*24),# 1/h,      standby losses per hour
        "P_ch_max": 336,        # W,        maximum charging power
        "P_dch_max": 8400,      # W,        maximum discharching power
        "unit_cap": 2.4*1000,   # Wh        BAT storage capacity
    }
    elif battery_type == "Lead Acid Generic/2.88kWh":
        data = {
        "Identifier": 3,
        "SOC_min": 0.3,             # -
        "eta_ch": 0.92736,          # -,        charging efficiency
        "eta_dch": 0.92736,         # -,        discharging efficiency
        "sto_loss": 0.05/(30*24),   # 1/h,      standby losses per hour
        "P_ch_max": 864,            # W,        maximum charging power
        "P_dch_max": 23520,         # W,        maximum discharching power
        "unit_cap": 2.88*1000,      # Wh        BAT storage capacity
    }
    elif battery_type == "Lead Acid WP/86.4Wh":
        data = {
        "Identifier": 4,
        "SOC_min": 0.5,             # -
        "eta_ch": 0.92736,          # -,        charging efficiency
        "eta_dch": 0.92736,         # -,        discharging efficiency
        "sto_loss": 0.2/(182.5*24), # 1/h,      standby losses per hour
        "P_ch_max": 25.9,           # W,        maximum charging power
        "P_dch_max": 1296,          # W,        maximum discharching power
        "unit_cap": 86.4,           # Wh        BAT storage capacity
    }
    elif battery_type == "Li-Ion Aquion/25.9kWh":
        data = {
        "Identifier": 5,
        "SOC_min": 0.0,             # -
        "eta_ch": 0.93,             # -,        charging efficiency
        "eta_dch": 0.93,            # -,        discharging efficiency
        "sto_loss": 0.1/(30*24),    # 1/h,      standby losses per hour
        "P_ch_max": 11700,          # W,        maximum charging power
        "P_dch_max": 11700,         # W,        maximum discharching power
        "unit_cap": 25.9*1000,      # Wh        BAT storage capacity
    }
    elif battery_type == "Li-Ion Tesla1/6.4kWh":
        data = {
        "Identifier": 6,
        "SOC_min": 0.0,             # -
        "eta_ch": 0.92,             # -,        charging efficiency
        "eta_dch": 0.92,            # -,        discharging efficiency
        "sto_loss": 0.1/(30*24),    # 1/h,      standby losses per hour
        "P_ch_max": 3300,           # W,        maximum charging power
        "P_dch_max": 3300,          # W,        maximum discharching power
        "unit_cap": 6.4*1000,       # Wh        BAT storage capacity
    }
    elif battery_type == "Li-Ion Tesla2/13.5kWh":
        data = {
        "Identifier": 7,
        "SOC_min": 0.0,             # -
        "eta_ch": 0.92,             # -,        charging efficiency
        "eta_dch": 0.92,            # -,        discharging efficiency
        "sto_loss": 0.1/(30*24),    # 1/h,      standby losses per hour
        "P_ch_max": 4600,           # W,        maximum charging power
        "P_dch_max": 4600,          # W,        maximum discharching power
        "unit_cap": 13.5*1000,      # Wh        BAT storage capacity
    }

    return data
def load_PV_params(PV_type):
    if PV_type == "ShellSP70":
        data = {
        "Identifier": 1,
        "eta": 0.1247,                      # -
        "n_ser": 36,                        # -,        number of cells connected on the PV panel
        "n_par": 1,                         # -,        number of parallel circuits on the PV panel
        "A_cell": 0.125*0.125,              # m²,       area of a single cell
        "A_panel": 0.125*0.125 * 36 * 1,    # -,        area of one panel
        "A_module": 0.527 * 1.200,          # m²,       area of one module

    }
    elif PV_type == "AleoS24185":
        data = {
        "Identifier": 2,
        "eta": 0.139,                       # -
        "n_ser": 48,                        # -,        number of cells connected on the PV panel
        "n_par": 1,                         # -,        number of parallel circuits on the PV panel
        "A_cell": 0.156*0.156,              # m²,       area of a single cell
        "A_panel": 0.156*0.156 * 48 * 1,    # -,        area of one panel
        "A_module": 0.990 * 1.345,          # m²,       area of one module

    }
    elif PV_type == "CanadianSolarCS6P250P":
        data = {
        "Identifier": 3,
        "eta": 0.1247,                                      # -
        "n_ser": 60,                                        # -,        number of cells connected on the PV panel
        "n_par": 1,                                         # -,        number of parallel circuits on the PV panel
        "A_cell": ((30.1*8.30)/(1000*0.1247))/60,           # m²,       area of a single cell
        "A_panel": ((30.1*8.30)/(1000*0.1247))/60 * 60 * 1, # -,        area of one panel
        "A_module": 0.982 * 1.638,                          # m²,       area of one module

    }
    elif PV_type == "SharpNUU235F2":
        data = {
        "Identifier": 6,
        "eta": 0.144,                                       # -
        "n_ser": 60,                                        # -,        number of cells connected on the PV panel
        "n_par": 1,                                         # -,        number of parallel circuits on the PV panel
        "A_cell": ((30*7.84)/(1000*0.144))/60,              # m²,       area of a single cell
        "A_panel": ((30*7.84)/(1000*0.144))/60 * 60 * 1,    # -,        area of one panel
        "A_module": 0.994 * 1.640,                          # m²,       area of one module

    }
    elif PV_type == "QPLusBFRG41285":
        data = {
        "Identifier": 4,
        "eta": 0.171,                                           # -
        "n_ser": 60,                                            # -,        number of cells connected on the PV panel
        "n_par": 1,                                             # -,        number of parallel circuits on the PV panel
        "A_cell": ((31.99*8.91)/(1000*0.171))/60,               # m²,       area of a single cell
        "A_panel": ((31.99*8.91)/(1000*0.171))/60 * 60 * 1,     # -,        area of one panel
        "A_module": 1.000 * 1.670,                              # m²,       area of one module

    }
    elif PV_type == "SchuecoSPV170SME1":
        data = {
        "Identifier": 5,
        "eta": 0.133,                       # -
        "n_ser": 72,                        # -,        number of cells connected on the PV panel
        "n_par": 1,                         # -,        number of parallel circuits on the PV panel
        "A_cell": 0.125*0.125,              # m²,       area of a single cell
        "A_panel": 0.125*0.125 * 72 * 1,    # -,        area of one panel
        "A_module": 0.8084 * 1.5804,        # m²,       area of one module

    }
    return data