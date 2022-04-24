import json
import utilities.fmu_handler as fmu_handler
from utilities.pickle_handler import *
import datetime
class DisturbanceGenerator:
    def __init__(self, setup):
        """
        Initialize FMU and load mapping
        """
        """ Load Simulation Setup """
        with open(setup,'r') as f:
            self.setup = json.load(f)
        self.days = self.setup['days']
        sim_tolerance = self.setup['sim_tolerance']           # tolerance
        start_time = self.setup['start_time']              # start time
        stop_time = 3600 * 24 * self.days       # stop time
        self.step_size = self.setup['step_size']          # step size in s
        self.save_name = self.setup['save_name']
        path_mapping = self.setup['path_mapping']
        path_fmu = self.setup['path_fmu']
        # fmu setup
        self.fmu = fmu_handler.fmu_handler(start_time=start_time,
                                      stop_time=stop_time,
                                      step_size=self.step_size,
                                      sim_tolerance=sim_tolerance,
                                      fmu_file=path_fmu,
                                      instanceName='fmu2')
        with open(path_mapping,'r') as f:
            mapping = json.load(f)
        self.vars = self.fmu.find_vars('thermalZone1.weaBus')
        self.vars_dict = {}
        for key in mapping.keys():
            for var in mapping[key].keys():
                self.vars.append(mapping[key][var])
                self.vars_dict.update({var:mapping[key][var]})
        self.inv_dict = {v: k for k, v in self.vars_dict.items()}
    def perform_initial_simulation(self):
        """
        Simulate Fmu and save relevant disturbances as pandas dataframe
        :return:
        """
        self.fmu.setup()
        self.fmu.initialize()
        finished = False
        init_df = False
        df_interval = 1 * self.fmu.step_size  # data storage interval
        while not finished:
            # read variables
            res = self.fmu.read_variables(self.vars)
            # store data in dataframe
            if not init_df:
                df = pd.DataFrame(res, index=[0])
                init_df = True
            else:
                if self.fmu.current_time % df_interval == 0:
                    df = df.append(pd.DataFrame(res, index=[0]), ignore_index=True)
            print(str(self.fmu.current_time / 3600) + ' hours')
            finished = self.fmu.do_step()
        # close fmu
        print('finished, closing fmu')
        self.fmu.close()
        self.disturbances = df
        self.disturbances = self.disturbances.rename(columns=self.inv_dict)
        self.disturbances["Q_RadSol"] = self.disturbances["Q_RadSol_or_1"] \
                                        + self.disturbances["Q_RadSol_or_2"] \
                                        + self.disturbances["Q_RadSol_or_3"] \
                                        + self.disturbances["Q_RadSol_or_4"]
        write_pickle(self.save_name, self.disturbances)
    def generate_boundaries(self, LB_emp = 290.15, LB_use = 293.15, UB_emp = 299.15, UB_use = 295.15, m_flow_ahu_emp = 12000*1/3600*1.224, m_flow_ahu_use = 12000*3/3600*1.224, opening = 7, closing = 17,appendix=''):
        """
        Generate Boundaries for Room temperature
        :return:
        """
        start = datetime.datetime(year=2018, month=1, day=1)
        time_list = [start]
        LB_list = [LB_emp]
        UB_list = [UB_emp]
        m_flow_ahu_list = [m_flow_ahu_emp]
        numSteps = len(self.disturbances)
        for i in range(1, numSteps):
            time_list.append(start + datetime.timedelta(seconds=i * self.step_size))
            if datetime.date.weekday(time_list[i]) < 5 and time_list[i].hour >= opening and time_list[i].hour < closing+1:
                LB_list.append(LB_use)
                UB_list.append(UB_use)
                m_flow_ahu_list.append(m_flow_ahu_use)
            else:
                LB_list.append(LB_emp)
                UB_list.append(UB_emp)
                m_flow_ahu_list.append(m_flow_ahu_emp)
        ComfortCon = pd.DataFrame({'UB': UB_list, 'LB': LB_list, 'm_flow_ahu':m_flow_ahu_list}, index=time_list)
        self.disturbances.index = ComfortCon.index
        self.disturbances['T_Air_UB'+appendix] = ComfortCon['UB']
        self.disturbances['T_Air_LB'+appendix] = ComfortCon['LB']
        self.disturbances['m_flow_ahu'+appendix] = ComfortCon['m_flow_ahu']
    def create_disturbances(self):
        """
        Try to load pickle file and simulate a new one otherwise
        :return:
        """
        try:
            self.disturbances = read_pickle(self.save_name)
        except:
            self.perform_initial_simulation()
        # Generate Boundaries for TZ_1
        self.generate_boundaries(LB_emp = self.setup["T_LB_emp"],
                                 LB_use = self.setup["T_LB_use"],
                                 UB_emp = self.setup["T_UB_emp"],
                                 UB_use = self.setup["T_UB_use"],
                                 m_flow_ahu_emp = self.setup["m_flow_ahu_emp"],
                                 m_flow_ahu_use = self.setup["m_flow_ahu_use"],
                                 opening = self.setup["opening"],
                                 closing = self.setup["closing"],
                                 appendix='')
        self.create_relaxed_bounds()
        # save disturbance file
        write_pickle(self.save_name, self.disturbances)
        self.disturbances.to_csv("Disturbances_ASHRAE_365_d")
    def create_relaxed_bounds(self, rel=6):
        """
        :param rel: relaxation in hours
        :return:
        """
        self.generate_boundaries(LB_emp=self.setup["T_LB_emp"],
                                 LB_use=self.setup["T_LB_use"],
                                 UB_emp=self.setup["T_UB_emp"],
                                 UB_use=self.setup["T_UB_use"],
                                 m_flow_ahu_emp=self.setup["m_flow_ahu_emp"],
                                 m_flow_ahu_use=self.setup["m_flow_ahu_use"],
                                 opening=self.setup["opening"] - rel / 2,
                                 closing=self.setup["closing"] + rel / 2,
                                 appendix='_rel')
        self.disturbances['T_Air_UB_rel'] = self.disturbances['T_Air_UB_rel'].rolling(
            window=int(rel * 60 / 5), center=True).mean()
        self.disturbances['T_Air_UB_rel'] = self.disturbances['T_Air_UB_rel'].fillna(method='bfill')
        self.disturbances['T_Air_UB_rel'] = self.disturbances['T_Air_UB_rel'].fillna(method='ffill')
        self.disturbances['T_Air_LB_rel'] = self.disturbances['T_Air_LB_rel'].rolling(
            window=int(rel * 60 / 5), center=True).mean()
        self.disturbances['T_Air_LB_rel'] = self.disturbances['T_Air_LB_rel'].fillna(method='bfill')
        self.disturbances['T_Air_LB_rel'] = self.disturbances['T_Air_LB_rel'].fillna(method='ffill')
if __name__ == '__main__':
    import matplotlib.pyplot as plt
    Dist = DisturbanceGenerator(setup = r"D:\Git_Repos\MPC_Geothermie\dissemination\evaluation-of-ai-based-control-applications\data\setup_disturbances.json")
    Dist.create_disturbances()
