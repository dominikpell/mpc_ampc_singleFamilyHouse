import pandas as pd
from utilities.pickle_handler import *

def load_weather(path):
    """Load weather path"""
    skiprows = 40
    startrows = 10

    ex_df = pd.read_csv(
        filepath_or_buffer=path, engine="python", skiprows=skiprows, sep="\t", header=None
    )
    # get file Names
    with open(path) as f:
        contents = f.readlines()
    contents = [x.strip() for x in contents]

    res_dict = {}
    for i,content in enumerate(contents[startrows:skiprows]):
        res_dict.update({content.split(' ', 1)[1]:ex_df[i]})


    weather = pd.DataFrame(
        res_dict
    )

    return weather

if __name__ == '__main__':
    # load Weather_data
    weather= load_weather("D:/Git_Repos/AixLib/AixLib/Resources/weatherdata/USA_CA_San.Francisco.Intl.AP.724940_TMY3.mos")
    write_pickle("D:/Git_Repos/MPC_Geothermie/controller_testing/termalzone_tabs/termalzone_tabs_data/weather_data_san_fran",weather)