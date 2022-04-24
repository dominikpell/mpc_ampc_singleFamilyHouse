import numpy as np
import matplotlib.pyplot as plt
import numpy as np
import os
import plotly.express as px
import pandas as pd
import json
def make_txt(dir, time_series, title):

    rows = len(time_series)
    txt_data = np.zeros((2*rows, 2))

    counter = 0
    step = 900
    txt_data[0, 0] = step * counter
    txt_data[0, 1] = time_series[0]
    counter +=1
    for i in range(rows-1):
        txt_data[counter,0] = txt_data[counter-1,0] + step
        txt_data[counter,1] = time_series[i]
        txt_data[counter+1,0] = txt_data[counter-1,0] + step
        txt_data[counter+1,1] = time_series[i+1]
        counter += 2
    txt_data[counter, 0] = step * rows
    txt_data[counter, 1] = time_series[rows-1]


    save_under = os.path.join(dir, title + ".txt")  # , str(datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")))

    np.savetxt(fname=save_under, X=txt_data, header="#1\ndouble " + title + "(" + str(2*rows)+", 2)", delimiter="\t")


def load_json(target_path, file_name):
    with open(os.path.join(target_path, file_name)) as f:
        last_results = json.load(f)
    return last_results

def write_json(target_path, file_name, data):
    if not os.path.exists(target_path):
        os.makedirs(target_path)
    with open(os.path.join(target_path, file_name), "w") as f:
        json.dump(data, f, indent=4, separators=(", ", ": "), sort_keys=True)


T_inside_min = []
T_inside_max = []
21 + 273.15, 3, 0.5,
for t in range(168):
    if t%24 < 8 or t%24 >= 22:
        for k in range(int(1/0.25)):
            T_inside_min.append(21 + 273.15 - 3)
            T_inside_max.append(21 + 273.15 - 3 + 0.5)
    else:
        for k in range(int(1 / 0.25)):
            T_inside_max.append(21 + 273.15)
            T_inside_min.append(21 + 273.15 - 0.5)
write_json("D:/MA/master-thesis/MPC_Einfamilienhaus/Results", "T_inside_min.json", T_inside_min)
write_json("D:/MA/master-thesis/MPC_Einfamilienhaus/Results", "T_inside_max.json", T_inside_max)