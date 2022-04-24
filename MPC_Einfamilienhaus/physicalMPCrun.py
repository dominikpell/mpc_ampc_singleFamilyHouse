import json
import utilities.fmu_handler as fmu_handler
from utilities.pickle_handler import *
from physical_mpc_controller import *
from rule_based_control.subsystem_controller_tz import *
import time


class SimulateConsumerOptimization:
    """
    Simulates FMU and optimizes Thermal Zone
    """
    def __init__(self,path_simulation_setup):
        """
        Initializes Subcomponents
        load simulation options as json
        """

        """ FMU Settings and Initialization """
        with open(path_simulation_setup, 'r') as f:
            self.setup = json.load(f)
        print('Initialize FMU')
        self.start_time = self.setup['start_time']
        self.stop_time = self.setup['stop_time']
        self.fmu_step_size = self.setup['fmu_step_size']
        self.fmu_tolerance = self.setup['fmu_tolerance']
        self.print_interval = self.setup['print_interval']
        self.path_to_fmu = self.setup['path_to_fmu']
        self.instance_name = self.setup['instance_name']
        self.fmu_bus = self.setup['fmu_bus']
        self.save = self.setup['save']
        self.savename = self.setup['savename']
        self.__initialize_fmu()

        """ MPC & RB Controller Settings and Initialization """
        print('Initialize Controller')
        self.mpc_step_size = self.setup['mpc_step_size']
        self.mpc_horizon = self.setup['mpc_horizon']
        self.path_to_mos = self.setup['path_to_mos']
        self.path_to_sol_opts =  self.setup['path_to_sol_opts']
        self.path_to_mapping = self.setup['path_to_mapping']
        self.__initialize_tz_controller()

        """ Initialize Disturbances """
        print('Initialize Disturbances')
        self.path_disturbances = self.setup['path_to_disturbances']
        self.__initialize_disturbances()

        """ Initialize Dataframe for Simulation"""
        self.__initialize_sim_data()

        """ Initialize Dict to Store Optimization Results """
        self.mpc_results = {}
        self.mpc_stats = {}
        self.mapped_controls = {}



    def __initialize_tz_controller(self):
        """
        Initialize mpc and Subsystem Controller for the first tz
        load mapping as json
        :return:
        """
        # MPC
        self.mpc = ThermalZone(path_to_mos = self.path_to_mos, path_sol_opts = self.path_to_sol_opts, N = self.mpc_horizon, dt = self.mpc_step_size)
        self.mpc.create_controller()
        self.current_MPC_step = 0

        # Mapping
        with open(self.path_to_mapping,'r') as f:
            self.mapping_tz = json.load(f)
        self.mapping_states = self.mapping_tz['states']
        self.mapping_disturbances = self.mapping_tz['disturbances']
        self.mapping_outputs = self.mapping_tz['outputs']
        self.mapping_measurements = self.mapping_tz['measurements']

    def __initialize_disturbances(self):
        """
        Initialize the disturbance dataframe which is used for forcasting and resample it for usage in MPC
        :return:
        """
        self.disturbances = read_pickle(self.path_disturbances)
        self.disturbances.index = self.disturbances['SimTime']

    def __initialize_fmu(self):
        """
        Initialize fmu to be simulated
        :return:
        """

        self.fmu = fmu_handler.fmu_handler(start_time=self.start_time,
                                      stop_time=self.stop_time,
                                      step_size=self.fmu_step_size,
                                      sim_tolerance=self.fmu_tolerance,
                                      fmu_file=self.path_to_fmu,
                                      instanceName=self.instance_name)

    def __initialize_sim_data(self):
        """
        Initializes Data Frame with relevant datapoints
        :return:
        """
        self.fmu_vars =[]# self.fmu.find_vars('thermalZone1.weaBus')# self.fmu.find_vars(self.fmu_bus)
        for key in self.mapping_states.keys():
            self.fmu_vars.append(self.mapping_states[key])
        for key in self.mapping_measurements.keys():
            self.fmu_vars.append(self.mapping_measurements[key])
        for key in self.mapping_outputs.keys():
            self.fmu_vars.append(self.mapping_outputs[key])

        # remove duplicates
        self.fmu_vars = list(set(self.fmu_vars))
        self.simulation_data = pd.DataFrame(columns = self.fmu_vars+['SimTime'])


    def set_mpc_inputs(self):
        """
        prepare disturbance dict for mpc
        :return:
        """
        x0 = {}
        dist = {}
        u0 = {'T_Ahu': min(273.15+25,max(273.15+18,self.simulation_data[self.mapping_measurements['T_ahu_act']].iloc[-1])),'Q_TabsSet':min(5,max(-5,self.simulation_data[self.mapping_measurements["Q_fl_tabs_act"]].iloc[-1]))}
        for key in self.mapping_states.keys():
            x0.update({key:self.simulation_data[self.mapping_states[key]].iloc[-1]})

        J = self.disturbances.index.get_loc(self.simulation_data['SimTime'].iloc[-1], method='nearest')
        N = self.disturbances.index.get_loc(self.simulation_data['SimTime'].iloc[-1]+self.mpc_horizon*self.mpc_step_size, method='nearest')
        for key in self.mapping_disturbances.keys():
            single_dist = self.disturbances[self.mapping_disturbances[key]][J:N]
            single_dist.index = single_dist.index - single_dist.index[0]
            dist.update({key: pd.Series(single_dist)})
        return x0, u0, dist

    def get_mpc_control(self):
        """
        Perform MPC step
        1. Check current time step
        2. get states
        3. get forecasts
        4. perform MPC step
        :return:
        """
        perform_mpc_step = False
        if self.current_MPC_step == 0:
            perform_mpc_step = True
        else:
            if self.fmu.current_time % self.mpc_step_size == 0:
                perform_mpc_step = True
            else:
                perform_mpc_step = False
        if perform_mpc_step:
            x0, u0, dist = self.set_mpc_inputs()
            results, instance, sol = self.mpc.get_control(x0 = x0, u0 = u0, disturbances = dist)
            for input in self.mpc.inputs:
                self.mapped_controls.update({self.mapping_outputs[input]:results[input].iloc[1]})
            self.mpc_results.update({self.current_MPC_step:results})
            self.mpc_stats.update({self.current_MPC_step:sol})
            self.current_MPC_step +=1

    def update_measurements(self):
        """
        load new simulation data from fmu
        :return:
        """
        res = self.fmu.read_variables(self.fmu_vars)
        self.simulation_data = self.simulation_data.append(pd.DataFrame(res, index=[res['SimTime']]))

    def write_inputs(self):
        """
        Write inputs to fmu
        :return:
        """
        self.fmu.set_variables(self.mapped_controls)

    def simulation_step(self):
        """
        Perform one simulation step with actual
        :return:
        """
        finished = self.fmu.do_step()
        return finished

    def close_simulation(self):
        """
        Close FMU and save Results
        :return:
        """
        self.fmu.close()
        if self.save:
            write_pickle(self.savename, {'Simulation_res': self.simulation_data, 'setup': self.setup,'Disturbances': self.disturbances})

    def run(self):
        """
        Perform Simulation, Optimization and rule based control
        :return:
        """
        self.fmu.setup()
        self.fmu.initialize()

        finished = False
        start_time = time.time()
        print('Start Simulation')
        while not finished:
            self.update_measurements()  # get Values from fmu
            self.get_mpc_control()
            self.write_inputs()
            finished = self.simulation_step()

            if self.fmu.current_time % self.print_interval== 0:
                print("-------------------------------------------------------------------------------------")
                print(f'Simulated {(self.fmu.current_time-self.start_time)/(self.stop_time-self.start_time)*100} % | Current Time: {self.fmu.current_time/3600} hours')
                print(f'Elapsed Time {(time.time() -start_time)/60} min')
        print(f"finished simulation in {(time.time() -start_time)/60} min")
        self.close_simulation()



if __name__ == '__main__':
    import matplotlib.pyplot as plt
    Sim = SimulateConsumerOptimization(r"C:\Users\pst\Data\Repos\MPC_dev\evaluation-of-ai-based-control-applications\physical_mpc\setup\setup_simulation_vm.json")
    Sim.run()

    bounds = Sim.disturbances
    bounds.index = bounds['SimTime']
    start = 60*60*24*0
    end = 60*60*24*7
    L = Sim.simulation_data.index.get_loc(start,'nearest')
    M = Sim.simulation_data.index.get_loc(end, 'nearest')
    J = bounds.index.get_loc(start,'nearest')
    K = bounds.index.get_loc(end, 'nearest')
    plt.plot(Sim.simulation_data['thermalZone1.TAir'].iloc[L:M])
    plt.plot(bounds['T_Air_LB'].iloc[J:K])
    plt.plot(bounds['T_Air_UB'].iloc[J:K])
    plt.show()

    plt.plot(Sim.simulation_data['TAhuSet'].iloc[L:M])
    plt.ylim([285,300])
    plt.show()

    plt.plot(Sim.simulation_data['QFlowTabsSet'].iloc[L:M])
    plt.show()

    plt.plot(bounds['Q_RadSol'].iloc[J:K])
    plt.show()
