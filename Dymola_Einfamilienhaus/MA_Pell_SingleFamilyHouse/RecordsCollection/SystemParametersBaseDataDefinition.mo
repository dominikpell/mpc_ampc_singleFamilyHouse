within MA_Pell_SingleFamilyHouse.RecordsCollection;
record SystemParametersBaseDataDefinition
  "Parameters globally used on all systems"
  extends Modelica.Icons.Record;

  // Heat demand levels
  parameter Modelica.SIunits.HeatFlowRate QBui_flow_nominal[nZones]=fill(9710.1, nZones)
    "Nominal heating load at outdoor air temperature of each zone" annotation(Dialog(group="Heat demand"));

  parameter Modelica.SIunits.HeatFlowRate QDemBuiSum_flow=sum(QBui_flow_nominal) "Sum of building heat demand" annotation(Dialog(group="Heat demand"));
  parameter Modelica.SIunits.HeatFlowRate QDemDHW_flow=DHWProfile.QDHW_flow_nominal "DHW heat demand" annotation(Dialog(group="Heat demand"));
  parameter Modelica.SIunits.HeatFlowRate QDem_flow=QDemBuiSum_flow + QDemDHW_flow "Total heat demand" annotation(Dialog(group="Heat demand"));

  // Temperature Levels
  parameter Modelica.SIunits.Temperature TSup_nominal
    "Water supply temperature at nominal condition for heating mode"
    annotation (Dialog(group="Temperature demand"));
  parameter Modelica.SIunits.Temperature TRet_nominal=TSup_nominal - 10
    "Water outlet temperature at nominal condition for heating mode"
    annotation (Dialog(group="Temperature demand"));
  parameter Modelica.SIunits.Temperature TSup_nominal_Cooling = 291.5
    "Nominal supply temperature for cooling mode"
    annotation (Dialog(group="Temperature demand"));
  parameter Modelica.SIunits.Temperature TRet_nominal_Cooling = TSup_nominal_Cooling + 7
    "Nominal return temperature for cooling mode"
    annotation (Dialog(group="Temperature demand"));

  parameter Modelica.SIunits.Temperature TOda_nominal "Nominal outdoor air temperature" annotation(Dialog(group="Temperature demand"));
  parameter Modelica.SIunits.Temperature T_bivNom(min=TOda_nominal)=
    TOda_nominal
    "Nominal bivalence temperature (assumption: -2°C). = TOda_nominal for monovalent systems."
    annotation (Dialog(group="Temperature demand"));
  parameter Modelica.SIunits.Temperature T_a_nominal=328.15
    "Water inlet temperature at nominal condition"
    annotation (Dialog(group="Temperature demand"));
  parameter Modelica.SIunits.Temperature T_b_nominal=T_a_nominal-10
    "Water outlet temperature at nominal condition"
    annotation (Dialog(group="Temperature demand"));
  parameter Modelica.SIunits.Temperature T_threshold_heat = 288.15 "Threshold temperature above which no heating occurs" annotation (Dialog(group="Temperature demand"));
  parameter Modelica.SIunits.Temperature T_threshold_cool = 296.15 "Threshold temperature below which no cooling occurs" annotation (Dialog(group="Temperature demand"));

  parameter Modelica.SIunits.Temperature TSetDHW=323.15   "Set temperature for dhw storage" annotation(Dialog(group="Temperature demand"));
  parameter Modelica.SIunits.Temperature TSetRoomConst=293.15
    "Room set temerature"                                                                   annotation(Dialog(group=
          "Temperature demand"));
  parameter Real TSetRoomSchedule[:,2]=[0.0,TSetRoomConst - TOffNight; 28800,
      TSetRoomConst; 79200,TSetRoomConst - TOffNight; 86400,TSetRoomConst -
      TOffNight]
    "Table matrix (time = first column; e.g., table=[0, 0; 1, 1; 2, 4])"
    annotation (Dialog(group="Temperature demand"));
  parameter Modelica.SIunits.TemperatureDifference TOffNight=5 "Night setback" annotation(Dialog(group="Temperature demand"));
  parameter Modelica.SIunits.Temperature THeaTrehs=TSetRoomConst "Heating treshhold" annotation(Dialog(group="Temperature demand"));

  // Demand System
  parameter Integer nZones=1 "Number of zones to transfer heat to"  annotation(Dialog(tab="Demand"));
  parameter AixLib.DataBase.ThermalZones.ZoneBaseRecord oneZoneParam=
      AixLib.DataBase.ThermalZones.ZoneRecordDummy()
    "Default zone if only one is chosen" annotation(choicesAllMatching=true, Dialog(tab="Demand"));
  parameter AixLib.DataBase.ThermalZones.ZoneBaseRecord zoneParam[nZones]=fill(oneZoneParam, nZones)
    "Choose an array of multiple zones" annotation(choicesAllMatching=true, Dialog(tab="Demand"));
  parameter Modelica.SIunits.Area area[nZones]= {zoneParam[i].AFloor for i in 1:nZones}
    "Room area" annotation(Dialog(tab="Demand"));
  parameter Boolean is_groundFloor[nZones] = fill(true, nZones) "Indicate if the florr is connected to soil or other rooms" annotation(Dialog(tab="Demand"));

  // Boundary conditions
  parameter String filNamWea=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Jahr_City_Berlin.mos")
    "Name of weather data file"
    annotation (Dialog(tab="Inputs", group="Weather"));
  //TRY2015_524528132978_Somm_City_Berlin.mos
  //TRY2015_524528132978_Wint_City_Berlin.mos
  parameter String filNamEV=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/ev_dem_quarterly.txt")
    "Name of Electric Vehicle file"
    annotation (Dialog(tab="Inputs", group="Electricity"));
  parameter String filNamElecDom=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/elec_dom_quarterly.txt")
    "Name of Domestic Electricity Demand file"
    annotation (Dialog(tab="Inputs", group="Electricity"));
  parameter String filNamIntGains=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/InternalGains_ResidentialBuildingTabulaMulti.txt")
    "File where matrix is stored"
    annotation (Dialog(tab="Inputs", group="Internal Gains"));
  parameter Real intGains_gain=1 "Gain value multiplied with input signal" annotation (Dialog(group="Internal Gains", tab="Inputs"));
  parameter Components.DHW.DHWProfile DHWtapping=
      Components.DHW.DHWProfile.M
    annotation (Dialog(group="DHW", tab="Inputs"));
  parameter String tableName="DHWCalc" "Table name on file for DHWCalc" annotation (Dialog(group="DHW", tab="Inputs", enable=use_file));
  parameter String fileName=Modelica.Utilities.Files.loadResource(
      "modelica://BuildingEnergySystems/Resources/DHWCalc.txt")
    "File where matrix is stored for DHWCalc"
    annotation (Dialog(group="DHW", tab="Inputs", enable=DHWtapping == BuildingEnergySystems.Components.DHW.DHWProfile.DHWCalc));

  // HVAC-Subsystems
  parameter Boolean use_generation=true "=false to disable generation subsystem" annotation(Dialog(group="System layout"));
  parameter Boolean use_distribution=true "=false to disable distribution subsystem" annotation(Dialog(group="System layout"));
  parameter Boolean use_control=true "=false to disable control subsystem" annotation(Dialog(group="System layout"));
  parameter Boolean use_transfer=true "=false to disable transfer subsystem" annotation(Dialog(group="System layout"));
  parameter Boolean use_demand=true "=false to disable demand subsystem" annotation(Dialog(group="System layout"));
  parameter Boolean use_ventilation=true "=false to disable ventilation subsystem" annotation(Dialog(group="System layout"));

  parameter Modelica.SIunits.Power Q_HP_max=5000 "Maximum/Nominal HP Power" annotation(Dialog(tab="Generation", group= "Design"));
  parameter Real fDesGen=1.2 "Factor to account for overdesign of generation system" annotation(Dialog(tab="Generation", group= "Design"));
  parameter Real fDesDis=1.2 "Factor to account for overdesign of distribution system" annotation(Dialog(tab="Distribution", group= "Design"));
  parameter Integer nLayers=4 "Factor to account for overdesign of distribution system" annotation(Dialog(tab="Distribution"));
  parameter Real fDesTra=1.2 "Factor to account for overdesign of transfer system" annotation(Dialog(tab="Transfer", group= "Design"));
  parameter Real fDesVen=1.2 "Factor to account for overdesign of ventilation system" annotation(Dialog(tab="Ventilation", group= "Design"));

  // Transfer System: UFH

  parameter Boolean use_ufh = true "Use under floor heating = true, else radiator system is assumed" annotation(Dialog(tab="Transfer", group= "Design"));
  parameter AixLib.DataBase.ThermalZones.ZoneBaseRecord oneZoneParamUFH=
      AixLib.DataBase.ThermalZones.ZoneRecordDummy()
    "Default zone if only one is chosen, used for UFH parameterization" annotation(choicesAllMatching=true, Dialog(enable=use_ufh, tab="Transfer", group="Design"));
  parameter AixLib.DataBase.ThermalZones.ZoneBaseRecord zoneParamUFH[nZones]=fill(oneZoneParamUFH, nZones)
    "Choose an array of multiple zones, used for UFH parameterization" annotation(choicesAllMatching=true, Dialog(enable=use_ufh, tab="Transfer", group= "Design"));
  parameter AixLib.Fluid.HeatExchangers.ActiveWalls.BaseClasses.HeatCapacityPerArea C_ActivatedElement[nZones]=
    {zoneParamUFH[i].CFloor[1] for i in 1:nZones} "Thermal capacity of UFH system" annotation(Dialog(enable=use_ufh, tab="Transfer", group= "Design"));
  parameter Modelica.SIunits.Area AFloor_UFH[nZones] = {zoneParamUFH[i].AFloor for i in 1:nZones} "Floor area of UFH system" annotation(Dialog(enable=use_ufh, tab="Transfer", group= "Design"));


  parameter Modelica.SIunits.MassFlowRate mGen_flow_nominal
    "Nominal mass flow rate for generation" annotation(Dialog(tab="Generation", group="Design"));

  parameter Modelica.SIunits.MassFlowRate mTra_flow_nominal=mGen_flow_nominal
    "Nominal mass flow rate for transfer" annotation(Dialog(tab="Generation", group="Design"));

  parameter Real ventRate=0 "Extra ventilation rate in thermal zone model"
    annotation (Dialog(tab="Demand", group="Building"));
  parameter Modelica.SIunits.PressureDifference dpVent_nominal
    "Pressure drop at nominal mass flow rate for ventilation" annotation(Dialog(tab="Ventilation", group= "Design"));
  parameter Modelica.SIunits.MassFlowRate mVent_flow_nominal
    "Nominal mass flow rate for ventilation" annotation(Dialog(tab="Ventilation", group="Design"));

  //Control
  parameter Modelica.SIunits.Time T_I=1200 "Time constant of Integrator block"
                                                                              annotation(Dialog(tab = "Control"));
  parameter Real P_hp=0.3 "Proportional gain of PID HP controller"
                                                                  annotation(Dialog(tab = "Control"));
  parameter Modelica.SIunits.TemperatureDifference dT_heater = 5 annotation(Dialog(tab="Control"));
  parameter Modelica.SIunits.TemperatureDifference dTOffSetHeatCurve=2
    "Additional Offset of heating curve"                                                                  annotation(Evaluate=true, Dialog(group=
          "Heating Curve", tab="Control"));

  parameter Modelica.SIunits.TemperatureDifference dT_hys = 10 "Heat pump hysteresis for buffer storage" annotation(Dialog(tab="Control"));
  parameter Modelica.SIunits.TemperatureDifference dT_loading=0  "Temperature difference in storage hx between loading fluid and storage fluid" annotation(Dialog(tab="Control"));
  parameter Real GradientHeatCurve=1.2 "Heat curve gradient"    annotation(Evaluate=true, Dialog(group=
          "Heating Curve", tab="Control"));
  parameter Modelica.SIunits.Time dt_hr = 30 * 60 "Seconds for regulation when hr should be activated: If lower set temperature is hurt for more than this time period" annotation(Dialog(tab="Control"));

  parameter Boolean use_minRunTime=true
    "False if minimal runtime of HP is not considered"
  annotation (Dialog(tab="Control", group="HP-Security: OnOffControl"), choices(checkBox=true));
  parameter Modelica.SIunits.Time minRunTime=600
                                               "Mimimum runtime of heat pump"
    annotation (Dialog(tab="Control", group="HP-Security: OnOffControl",enable=use_minRunTime));
  parameter Boolean use_minLocTime=true
    "False if minimal locktime of HP is not considered"
    annotation (Dialog(tab="Control", group="HP-Security: OnOffControl"), choices(checkBox=true));
  parameter Modelica.SIunits.Time minLocTime=1200
                                               "Minimum lock time of heat pump"
    annotation (Dialog(tab="Control", group="HP-Security: OnOffControl", enable=use_minLocTime));
  parameter Boolean use_runPerHou=true
    "False if maximal runs per hour HP are not considered"
    annotation (Dialog(tab="Control", group="HP-Security: OnOffControl"), choices(checkBox=true));
  parameter Integer maxRunPerHou=3 "Maximal number of on/off cycles in one hour. Source: German law"
    annotation (Dialog(tab="Control", group="HP-Security: OnOffControl", enable=use_runPerHou));
  parameter Boolean pre_n_start=true "Start value of pre(n) at initial time"
    annotation (Dialog(tab="Control", group="HP-Security: OnOffControl", descriptionLabel=true),choices(checkBox=true));
  parameter Real dT_opeEnv=5
    "Delta value for operational envelope used for upper hysteresis. Used to avoid state-events and to model the real world high pressure pressostat." annotation (Dialog(tab="Control", group="HP-Security: Operational Envelope"));

  parameter Boolean aux_for_desinfection=true
    "If false, heating rod is not automatically used for thermal desinfection" annotation(Dialog(tab="Control", group="HP-Security: Legionella"));
  parameter Real ratioQHPMin=0.3
    "Ratio of minimum partial load heating power to nominal heating power of heat pump"
    annotation (Dialog(tab="Control", group="Heat Pumps"));
  parameter Real nOptHP=0.7
    "Frequency of the heat pump map with an optimal isentropic efficiency. Necessary, as on-off HP will be optimized for this frequency and only used there."
    annotation (Dialog(tab="Control", group="Heat Pumps"));
  // Components
  parameter Real V_flowCurve[:] = {0, 1, 1.1, 1.15} "Relative V_flow curve to be used" annotation(Dialog(tab="Components", group="Movers"));
  parameter Real dpCurve[:] = {1.25, 1, 0.75, 0} "Relative dp curve to be used" annotation(Dialog(tab="Components", group="Movers"));
  parameter Modelica.SIunits.Conversions.NonSIunits.AngularVelocity_rpm speed_rpm_nominal=1500
    "Nominal rotational speed for flow characteristic" annotation(Dialog(tab="Components", group="Movers"));
   parameter Boolean addPowerToMedium=false
    "Set to false to avoid any power (=heat and flow work) being added to medium (may give simpler equations)"
    annotation (Dialog(tab="Components", group="Movers"));
  parameter Boolean use_inputFilterMovers=false
    "= true, if speed is filtered with a 2nd order CriticalDamping filter"
                                                                          annotation (Dialog(tab="Components", group="Movers"));
  parameter Modelica.SIunits.Time riseTimeMoverInpFilter=30
    "Rise time of the filter (time to reach 99.6 % of the speed)"
                                                                 annotation (Dialog(tab="Components", group="Movers"));
  parameter Modelica.SIunits.Time tauMover=1
    "Time constant of fluid volume for nominal flow, used if energy or mass balance is dynamic"
                                                                                               annotation (Dialog(tab="Components", group="Movers"));

  // Initialization
  parameter Real T_start_layersDHW[nLayers] = fill(TWater_start, nLayers) "Start temperatures of the DHW layers" annotation(Dialog(group="Storage", tab="Initialization"));
  parameter Real T_start_layers_HE_DHW[nLayers] = fill(TWater_start, nLayers) "Start temperatures of the DHW layers" annotation(Dialog(group="Storage", tab="Initialization"));
  parameter Real T_start_layersBuf[nLayers] = fill(TWater_start, nLayers) "Start temperatures of the Buffer storage layers" annotation(Dialog(group="Storage", tab="Initialization"));
  parameter Real T_start_layers_HE_Buf[nLayers] = fill(TWater_start, nLayers) "Start temperatures of the Buffer storage layers" annotation(Dialog(group="Storage", tab="Initialization"));
  parameter Modelica.SIunits.Temperature TWater_start=303.15 "Start temperature of all water models" annotation(Dialog(tab="Initialization"));
  parameter Modelica.SIunits.Temperature TAir_start=303.15 "Start temperature of all air models"  annotation(Dialog(tab="Initialization"));
  // Assumptions
  parameter Modelica.SIunits.Temperature TAmbInternal=291.15
    "Internal ambient temperature for heating system. Usually basement, therefore 18 degC assumend"                                                   annotation(Dialog(tab=
          "Assumptions",                                                                                                                                                                   group="Ambient"));
  parameter Real TSoilConst=281.15 "Constant output value" annotation (Dialog(group="Assumptions", tab="Ambient"));

  parameter Modelica.SIunits.Pressure pHyd=200000
                                               "Pressure of hydraulic systems"  annotation(Dialog(tab="Assumptions", group="Constants"));
  parameter Modelica.SIunits.Pressure pAtm=101325 "Pressure of atmosphere" annotation(Dialog(tab="Assumptions", group="Constants"));
  parameter Modelica.SIunits.Density rhoWater(displayUnit="kg/m3")=1000
                                                    "Density of liquid water" annotation(Dialog(tab="Assumptions", group = "Constants"));
  parameter Modelica.SIunits.Density rhoAir(displayUnit="kg/m3")=1.29
                                                    "TODO: Check value. Density of liquid water" annotation(Dialog(tab="Assumptions", group = "Constants"));

  parameter Modelica.SIunits.SpecificHeatCapacityAtConstantPressure c_pWater=4184
    "Heat capacity of water"
                            annotation(Dialog(tab="Assumptions", group="Constants"));
    parameter Modelica.SIunits.SpecificHeatCapacityAtConstantPressure c_pAir=1004
    "Heat capacity of air"
                          annotation(Dialog(tab="Assumptions", group="Constants"));
  parameter Modelica.SIunits.Temperature TWaterCold=283.15
    "Cold water temperature (new water)"                                                           annotation(Dialog(tab=
          "Assumptions",                                                                                                                  group=
          "Constants"));

  parameter Modelica.SIunits.Time tauTempSensors=1
    "Time constant at nominal flow rate (use tau=0 for steady-state sensor, but see user guide for potential problems)"
    annotation (Dialog(tab="Assumptions", group="Temperature Sensors"));
  parameter Modelica.Blocks.Types.Init initTypeTempSensors=Modelica.Blocks.Types.Init.InitialState
    "Type of initialization (InitialState and InitialOutput are identical)"
    annotation (Dialog(tab="Assumptions", group="Temperature Sensors"));
  parameter Boolean transferHeatTempSensors=false
    "if true, temperature T converges towards TAmb when no flow"
    annotation (Dialog(tab="Assumptions", group="Temperature Sensors"));
  parameter Boolean allowFlowReversal=true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal"
    annotation (Dialog(tab="Assumptions"));
  parameter Modelica.SIunits.Time tauHeaTraTempSensors=1200
    "Time constant for heat transfer, default 20 minutes"
    annotation (Dialog(tab="Assumptions", group="Temperature Sensors"));
  parameter Modelica.SIunits.Temperature TAmbTempSensors=TAmbInternal
    "Fixed ambient temperature for heat transfer"
    annotation (Dialog(tab="Assumptions", group="Temperature Sensors"));
  parameter Modelica.Fluid.Types.Dynamics energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation (Dialog(tab="Advanced", group="Dynamics"));
  parameter Modelica.Fluid.Types.Dynamics massDynamics=energyDynamics
    "Type of mass balance: dynamic (3 initialization options) or steady state"
    annotation (Dialog(tab="Advanced", group="Dynamics"));
  parameter Boolean show_T=false
    "= true, if actual temperature at port is computed"
    annotation (Dialog(tab="Advanced", group="Diagnostics"));

 // Helper parameters
 parameter Boolean use_fileDHW = if DHWtapping == MA_Pell_SingleFamilyHouse.Components.DHW.DHWProfile.DHWCalc then true else false annotation(Dialog(tab="Helper"));
 parameter RecordsCollection.DHW.PartialDHWTap DHWProfile=if DHWtapping ==
      Components.DHW.DHWProfile.S then
      RecordsCollection.DHW.ProfileS() elseif DHWtapping ==
      Components.DHW.DHWProfile.M then
      RecordsCollection.DHW.ProfileM() elseif DHWtapping ==
      Components.DHW.DHWProfile.L then
      RecordsCollection.DHW.ProfileL() else RecordsCollection.DHW.NoDHW()
    annotation (Dialog(tab="Helper"));

  parameter Modelica.SIunits.Volume V_dhw_day=if DHWtapping == Components.DHW.DHWProfile.L
         then 248.517e-3 elseif DHWtapping == Components.DHW.DHWProfile.M
         then 123.417e-3 elseif DHWtapping == Components.DHW.DHWProfile.S then 43.5e-3 else 0;
  annotation (defaultComponentName = "baseParameterAssumptions", Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end SystemParametersBaseDataDefinition;
