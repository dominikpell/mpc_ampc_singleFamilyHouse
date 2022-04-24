within MA_Pell_SingleFamilyHouse.FMUs;
model SFH_FMU_UFH "Model with UFH transfer system"
  extends Systems.BaseClasses.PartialBuildingEnergySystem(
    redeclare Systems.Subsystems.Ventilation.NoVentilation Ventilation,
    redeclare Systems.Examples.SimpleStudyOfHeatingRodEfficiency parameterStudy(
        efficiceny_heating_rod=eta_HR, hr_nominal_power=P_HR_max),
    redeclare RecordsCollection.ExampleSystemParameters systemParameters(
      TSup_nominal=313.15,
      TRet_nominal=306.15,
      TOda_nominal=261.15,
      T_bivNom=271.15,
      TSetDHW=TSetDHW,
      TSetRoomConst=294.15,
      TOffNight=3,
      nZones=1,
      oneZoneParam=
          MA_Pell_SingleFamilyHouse.Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase.ResidentialBuilding_SingleDwellingNoFloor(
           useConstantACHrate=true, HeaterOn=false),
      zoneParam=fill(systemParameters.oneZoneParam, systemParameters.nZones),
      filNamWea=if year == 1 then Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Somm_City_Berlin.mos")
           elseif year == 2 then Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Wint_City_Berlin.mos")
           else Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Jahr_City_Berlin.mos"),
      filNamIntGains=Modelica.Utilities.Files.loadResource(
          "modelica://MA_Pell_SingleFamilyHouse/Data/InternalGains_ResidentialBuildingTabulaMulti.txt"),
      DHWtapping=DHWtapping,
      use_generation=true,
      Q_HP_max=Q_HP_max,
      nLayers=4,
      oneZoneParamUFH=
          MA_Pell_SingleFamilyHouse.Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase.ResidentialBuildingWFloor_SingleDwellingWithFloor(),
      T_I=900,
      P_hp=0.3,
      ratioQHPMin=0.05,
      T_start_layersDHW={T_DHW_1_Init,T_DHW_2_Init,T_DHW_3_Init,T_DHW_4_Init},
      T_start_layers_HE_DHW={T_HE_DHW_1_Init,T_HE_DHW_2_Init,T_HE_DHW_3_Init,
          T_HE_DHW_4_Init},
      T_start_layersBuf={T_TES_1_Init,T_TES_2_Init,T_TES_3_Init,T_TES_4_Init},
      T_start_layers_HE_Buf={T_HE_TES_1_Init,T_HE_TES_2_Init,T_HE_TES_3_Init,
          T_HE_TES_4_Init},
      TAir_start=T_Air_Init,
      tauTempSensors=0,
      DHWProfile=DHWProfile),
    redeclare Systems.Subsystems.Transfer.UFHTransferSystem Transfer(
        T_thermalCapacity_top=T_thermalCapacity_top_Init,
        T_thermalCapacity_down=T_thermalCapacity_down_Init,
      T_supply=T_supply_UFH_Init,
      T_return=T_return_UFH_Init),
    redeclare Systems.Subsystems.Demand.DemandCase Demand(
      senT(T_start = T_DHW_1_Init),
      redeclare Components.DHW.calcmFlowEquStatic calcmFlow,
      T_Roof=T_Roof_Init,
      T_Air=T_Air_Init,
      T_IntWall=T_IntWall_Init,
      T_ExtWall=T_ExtWall_Init,
      T_Floor=T_Floor_Init,
      T_Win=T_Win_Init),
    redeclare Systems.Subsystems.Generation.GenerationHeatPumpAndHeatingRod
      Generation(
      t_Con_start=T_supply_HP_Init,
      t_supply_start=T_supply_Init,
      t_supply_HP_start=T_supply_HP_Init,
      t_return_start=T_return_Init,
      redeclare RecordsCollection.GenerationData.DummyHP heatPumpParameters(VEva=0.03, VCon=0.03, Q_HP_Nom=systemParameters.Q_HP_max),
      redeclare RecordsCollection.GenerationData.DummyHR heatingRodParameters(
          eta_hr=parameterStudy.efficiceny_heating_rod, Q_HR_Nom=parameterStudy.hr_nominal_power),
      redeclare package Medium_eva = AixLib.Media.Air),
    redeclare Systems.Subsystems.Control.Controller_MPC Control(hr_nom_power=
          parameterStudy.hr_nominal_power),
    redeclare Systems.Subsystems.Distribution.DistributionTwoStorageParallel
      Distribution(
      t_TES=t_TES_Init,
      t_DHW=t_DHW_Init, redeclare
        RecordsCollection.StorageData.SimpleStorage.DummySimpleStorage
        bufParameters(nLayer= systemParameters.nLayers, V=0.3), redeclare
        RecordsCollection.StorageData.SimpleStorage.DummySimpleStorage
        dhwParameters(nLayer=systemParameters.nLayers, V=0.3)));

  Systems.Subsystems.Electricity.Electricity_PVandBAT_MPC
                                                      Electricity(
    timZon=weaDat.timZon,
    SOC_Bat_Init=soc_BAT_Init,
    n_mod=n_mod,
    data=data,
    batteryData=batteryData,
    nBat=nBat,
    til=til,
    azi1=azi1,
    azi2=azi2,
    lat=lat,
    lon=lon)
    annotation (Placement(transformation(extent={{-212,100},{-132,180}})));

  parameter Real til = 15*2*3.14/360 annotation(Evaluate=false);
  parameter Real azi1 = 90*(2*3.14)/(360) annotation(Evaluate=false);
  parameter Real azi2 = -90*(2*3.14)/(360) annotation(Evaluate=false);
  parameter Real lat = 52.519*2*3.14/360 annotation(Evaluate=false);
  parameter Real lon = 13.408*2*3.14/360 annotation(Evaluate=false);
  parameter Integer year=1 annotation(Evaluate=false);
  parameter MA_Pell_SingleFamilyHouse.Components.DHW.DHWProfile DHWtapping=
    MA_Pell_SingleFamilyHouse.Components.DHW.DHWProfile.M annotation(Evaluate=false);
  parameter MA_Pell_SingleFamilyHouse.RecordsCollection.DHW.PartialDHWTap DHWProfile=
    MA_Pell_SingleFamilyHouse.RecordsCollection.DHW.ProfileM() annotation(Evaluate=false);
  parameter Real soc_BAT_Init=0.30 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_Air_Init=291.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_supply_Init=298.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_supply_HP_Init=298.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_return_Init=298.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_supply_UFH_Init=298.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_return_UFH_Init=298.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_thermalCapacity_top_Init=298.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_thermalCapacity_down_Init=298.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_Roof_Init=291.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_IntWall_Init=291.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_ExtWall_Init=291.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_Floor_Init=291.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_Win_Init=291.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real t_TES_Init=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real t_DHW_Init=323.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_DHW_1_Init=323.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_DHW_2_Init=323.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_DHW_3_Init=323.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_DHW_4_Init=323.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_HE_DHW_1_Init=323.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_HE_DHW_2_Init=323.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_HE_DHW_3_Init=323.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_HE_DHW_4_Init=323.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_TES_1_Init=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_TES_2_Init=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_TES_3_Init=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_TES_4_Init=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_HE_TES_1_Init=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_HE_TES_2_Init=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_HE_TES_3_Init=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_HE_TES_4_Init=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));

  parameter AixLib.DataBase.SolarElectric.PVBaseDataDefinition data=
    if IdentifierPV == 1 then AixLib.DataBase.SolarElectric.ShellSP70()
    elseif IdentifierPV == 2 then AixLib.DataBase.SolarElectric.AleoS24185()
    elseif IdentifierPV == 3 then AixLib.DataBase.SolarElectric.CanadianSolarCS6P250P()
    elseif IdentifierPV == 4 then AixLib.DataBase.SolarElectric.QPlusBFRG41285()
    elseif IdentifierPV == 5 then AixLib.DataBase.SolarElectric.SchuecoSPV170SME1()
    else AixLib.DataBase.SolarElectric.SharpNUU235F2()
    "PV Panel data definition" annotation (Evaluate=false, Dialog(group="PV"));
  parameter ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral batteryData=
    if IdentifierBAT == 1 then MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LithiumIon.LithiumIonViessmann()
    elseif IdentifierBAT == 2 then MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LeadAcid.Chloride200Ah()
    elseif IdentifierBAT == 3 then MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LeadAcid.LeadAcidGeneric()
    elseif IdentifierBAT == 4 then MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LeadAcid.Long7Ah()
    elseif IdentifierBAT == 5 then MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LithiumIon.LithiumIonAquion()
    elseif IdentifierBAT == 6 then MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LithiumIon.LithiumIonTeslaPowerwall1()
    else MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LithiumIon.LithiumIonTeslaPowerwall2()
    "Characteristic data of the battery" annotation (Evaluate=false, Dialog(group="Battery"));
  parameter Integer nBat=3 "Number of batteries" annotation(Evaluate=false, Dialog(group="Battery"));
  parameter Integer n_mod=3 "Number of connected PV modules" annotation(Evaluate=false, Dialog(group="PV"));
  parameter Integer IdentifierPV=1 "defines data for PV module" annotation(Evaluate=false, Dialog(group="PV"));
  parameter Integer IdentifierBAT=1 "defines data for Battery" annotation(Evaluate=false, Dialog(group="Battery"));
  parameter Real TSetDHW=323.15 "Max temperature for DHW strorage" annotation(Evaluate=false, Dialog(group="Storage"));
  parameter Integer tariff=1 annotation(Evaluate=false, Dialog(tab="Economic"));
  parameter Real price_el=0.346/1000 "electricity costs in €/Wh" annotation(Evaluate=false, Dialog(tab="Economic"));
  parameter Real price_comfort_vio=1000 "sanctioned price for discomfort in €/K^2" annotation(Evaluate=false, Dialog(tab="Economic"));
  parameter Real feed_in_revenue_el=0.064/1000 "electricity feed in revenue in €/Wh" annotation(Evaluate=false, Dialog(tab="Economic"));
  parameter Real eta_COP=0.3 "Max temperature for DHW strorage" annotation(Evaluate=false, Dialog(group="HP"));
  parameter Real Q_HP_max=5000 "Maximum/Nominal HP power" annotation(Evaluate=false, Dialog(group="HP"));
  parameter Real P_HR_max=2000 "Maximum/Nominal HR power" annotation(Evaluate=false, Dialog(group="HR"));
  parameter Real eta_HR=0.97 "HR efficiency" annotation(Evaluate=false, Dialog(group="HR"));

  Modelica.Blocks.Interfaces.RealInput PV_Distr_FeedIn
    annotation (Evaluate=false, Placement(transformation(extent={{-490,152},{-470,172}})));
  Modelica.Blocks.Interfaces.RealInput PV_Distr_ChBat
    annotation (Evaluate=false, Placement(transformation(extent={{-490,136},{-470,156}})));
  Modelica.Blocks.Interfaces.RealInput PV_Distr_Use
    annotation (Evaluate=false, Placement(transformation(extent={{-490,166},{-470,186}})));
  Modelica.Blocks.Interfaces.RealInput power_use_BAT
    annotation (Evaluate=false, Placement(transformation(extent={{-490,118},{-470,138}})));
  Modelica.Blocks.Interfaces.RealInput power_to_grid_BAT
    annotation (Evaluate=false, Placement(transformation(extent={{-490,100},{-470,120}})));
  Modelica.Blocks.Interfaces.RealInput ch_BAT
    annotation (Evaluate=false, Placement(transformation(extent={{-490,84},{-470,104}})));
  Modelica.Blocks.Interfaces.RealInput dem_elec annotation (Evaluate=false, Placement(
        transformation(extent={{-490,14},{-470,34}}), iconTransformation(
          extent={{-490,14},{-470,34}})));
  Modelica.Blocks.Interfaces.RealInput dem_e_mob annotation (Evaluate=false, Placement(
        transformation(extent={{-490,0},{-470,20}}), iconTransformation(
          extent={{-490,0},{-470,20}})));


  Modelica.Blocks.Interfaces.RealInput dem_dhw_m_flow annotation (Evaluate=false, Placement(
        transformation(extent={{-490,-16},{-470,4}}), iconTransformation(extent=
           {{-490,-16},{-470,4}})));
  Modelica.Blocks.Interfaces.RealInput dem_dhw_T annotation (Evaluate=false, Placement(
        transformation(extent={{-490,-34},{-470,-14}}), iconTransformation(
          extent={{-490,-34},{-470,-14}})));
  Modelica.Blocks.Interfaces.RealInput x_HP_heat
                                                annotation (Evaluate=false, Placement(
        transformation(extent={{-492,-114},{-472,-94}}),iconTransformation(
          extent={{-490,-164},{-470,-144}})));
  Modelica.Blocks.Interfaces.RealInput x_HP_cool
                                                annotation (Evaluate=false, Placement(
        transformation(extent={{-492,-132},{-472,-112}}),
                                                        iconTransformation(
          extent={{-490,-190},{-470,-170}})));
  Modelica.Blocks.Interfaces.RealInput T_supply_UFH annotation (Evaluate=false, Placement(
        transformation(extent={{-492,-162},{-472,-142}}),iconTransformation(
          extent={{-490,-214},{-470,-194}})));
  Modelica.Blocks.Math.Add add(k2=-1)
    annotation (Placement(transformation(extent={{-462,-122},{-442,-102}})));
  Modelica.Blocks.Logical.GreaterThreshold HPMode(threshold=-0.5)
    annotation (Placement(transformation(extent={{-430,-124},{-410,-104}})));
  Modelica.Blocks.Interfaces.RealInput T_supply_HP_heat annotation (Evaluate=false, Placement(
        transformation(extent={{-492,-206},{-472,-186}}), iconTransformation(
          extent={{-490,-234},{-470,-214}})));
  Modelica.Blocks.Interfaces.RealInput T_supply_cool annotation (Evaluate=false, Placement(
        transformation(extent={{-492,-226},{-472,-206}}), iconTransformation(
          extent={{-490,-138},{-470,-118}})));
  Modelica.Blocks.Interfaces.RealInput heat_rod annotation (Evaluate=false, Placement(
        transformation(extent={{-492,-242},{-472,-222}}), iconTransformation(
          extent={{-490,-254},{-470,-234}})));
  Modelica.Blocks.Logical.Switch TsupplyHP
    annotation (Evaluate=false, Placement(transformation(extent={{-392,-214},{-372,-194}})));
  Modelica.Blocks.Interfaces.RealInput ts_gains_human annotation (Evaluate=false, Placement(
        transformation(extent={{-490,-52},{-470,-32}}), iconTransformation(
          extent={{-490,-52},{-470,-32}})));
  Modelica.Blocks.Interfaces.RealInput ts_gains_dev annotation (Evaluate=false, Placement(
        transformation(extent={{-490,-68},{-470,-48}}), iconTransformation(
          extent={{-490,-68},{-470,-48}})));
  Modelica.Blocks.Interfaces.RealInput ts_gains_light annotation (Evaluate=false, Placement(
        transformation(extent={{-490,-90},{-470,-70}}), iconTransformation(
          extent={{-490,-90},{-470,-70}})));

  Modelica.Blocks.Math.Gain hr_rel(k=1/parameterStudy.hr_nominal_power)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-438,-232})));
  Modelica.Blocks.Interfaces.RealInput ch_DHW annotation (Evaluate=false, Placement(
        transformation(extent={{-490,-270},{-470,-250}}), iconTransformation(
          extent={{-490,-306},{-470,-286}})));
  Modelica.Blocks.Interfaces.RealInput ch_TES annotation (Evaluate=false, Placement(
        transformation(extent={{-490,-294},{-470,-274}}), iconTransformation(
          extent={{-490,-294},{-470,-274}})));
  Modelica.Blocks.Interfaces.RealInput x_HP_on annotation (Evaluate=false, Placement(
        transformation(extent={{-490,-316},{-470,-296}}), iconTransformation(
          extent={{-490,-316},{-470,-296}})));

  Modelica.Blocks.Interfaces.RealInput dch_TES annotation (Evaluate=false, Placement(
        transformation(extent={{-490,-338},{-470,-318}}), iconTransformation(
          extent={{-490,-338},{-470,-318}})));
  Modelica.Blocks.Interfaces.RealInput t_TES annotation (Evaluate=false, Placement(
        transformation(extent={{-490,-388},{-470,-368}}), iconTransformation(
          extent={{-490,-370},{-470,-350}})));
  Modelica.Blocks.Interfaces.RealInput t_DHW annotation (Evaluate=false, Placement(
        transformation(extent={{-490,-352},{-470,-332}}), iconTransformation(
          extent={{-490,-352},{-470,-332}})));
  Modelica.Blocks.Interfaces.RealInput ts_T_inside_max annotation (Evaluate=false, Placement(
        transformation(extent={{-490,-410},{-470,-390}}), iconTransformation(
          extent={{-488,-396},{-468,-376}})));
  Modelica.Blocks.Interfaces.RealInput ts_T_inside_min annotation (Evaluate=false, Placement(
        transformation(extent={{-492,-434},{-472,-414}}), iconTransformation(
          extent={{-488,-436},{-468,-416}})));
  Systems.Subsystems.InputScenario.ReaderTMY3 weaDat(
    filNam=systemParameters.filNamWea,
    TDryBulSou=AixLib.BoundaryConditions.Types.DataSource.Input,
    winSpeSou=AixLib.BoundaryConditions.Types.DataSource.Input,
    HSou=AixLib.BoundaryConditions.Types.RadiationDataSource.File)
    "Weather data reader"
    annotation (Placement(transformation(extent={{-436,54},{-396,80}})));
  Modelica.Blocks.Sources.Constant TSoil(k=systemParameters.TSoilConst)
    annotation (Placement(transformation(extent={{-384,46},{-372,58}})));
  Modelica.Blocks.Interfaces.RealInput ts_T_air(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") annotation (Evaluate=false,Placement(transformation(extent={{-488,70},{
            -468,90}}),  iconTransformation(extent={{-490,70},{-470,90}})));
  Modelica.Blocks.Interfaces.RealInput ts_sol_rad annotation (Evaluate=false, Placement(
        transformation(extent={{-488,36},{-468,56}}), iconTransformation(
          extent={{-490,38},{-470,58}})));
  Modelica.Blocks.Interfaces.RealInput ts_win_spe annotation (Evaluate=false, Placement(
        transformation(extent={{-488,54},{-468,74}}), iconTransformation(
          extent={{-490,54},{-470,74}})));
  Interfaces.MPCControlBus MPC_Interface annotation (Evaluate=false, Placement(
        transformation(extent={{-332,42},{-294,88}}), iconTransformation(extent=
           {{-294,34},{-256,80}})));

  Real tot_vio_Kh;
  Real Q_del_DHW;

  Modelica.Blocks.Math.Add totElecDem
    annotation (Placement(transformation(extent={{-224,16},{-204,36}})));
  output Modelica.Blocks.Interfaces.RealOutput costs_tot
    annotation (Placement(transformation(extent={{480,-38},{500,-18}})));
  output Modelica.Blocks.Interfaces.RealOutput costs_vio
    annotation (Placement(transformation(extent={{480,-60},{500,-40}}),
        iconTransformation(extent={{480,-60},{500,-40}})));
  output Modelica.Blocks.Interfaces.RealOutput costs_elec
    annotation (Placement(transformation(extent={{480,-82},{500,-62}}),
        iconTransformation(extent={{480,-82},{500,-62}})));
  output Modelica.Blocks.Interfaces.RealOutput rev_elec
    annotation (Placement(transformation(extent={{480,-110},{500,-90}}),
        iconTransformation(extent={{480,-110},{500,-90}})));
  output Modelica.Blocks.Interfaces.RealOutput costs_DHW_err
    annotation (Placement(transformation(extent={{480,-136},{500,-116}}),
        iconTransformation(extent={{480,-136},{500,-116}})));
  output Modelica.Blocks.Interfaces.RealOutput Q_err_DHW
    annotation (Placement(transformation(extent={{482,-156},{502,-136}})));
  output Modelica.Blocks.Interfaces.RealOutput Q_DHW
    annotation (Placement(transformation(extent={{482,-176},{502,-156}})));
  Modelica.Blocks.Sources.CombiTimeTable table_ts_price_elec(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="variable_tariff",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/variable_tariff2.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{15,15},{-15,-15}},
        rotation=180,
        origin={-239,-363})));

  Modelica.Blocks.Sources.RealExpression ch_Buf(y=if Distribution.sigBusDistr.buffer_on
         then Generation.artificalPumpIsotermhal.m_flow_in*systemParameters.c_pWater
        *(Generation.senTemVL1.T - Generation.heatPump.sigBus.TConInMea) else 0)
    annotation (Placement(transformation(
        extent={{8,-6},{-8,6}},
        rotation=180,
        origin={350,-298})));
  Modelica.Blocks.Sources.RealExpression ch_DHW1(y=if Distribution.sigBusDistr.buffer_on
         == false then Generation.artificalPumpIsotermhal.m_flow_in*
        systemParameters.c_pWater*(Generation.senTemVL1.T - Generation.heatPump.sigBus.TConInMea)
         else 0)
    annotation (Placement(transformation(
        extent={{8,-6},{-8,6}},
        rotation=180,
        origin={350,-322})));
  output Modelica.Blocks.Interfaces.RealOutput E_from_grid annotation (
      Placement(transformation(extent={{482,-198},{502,-178}}),
        iconTransformation(extent={{482,-198},{502,-178}})));
  output Modelica.Blocks.Interfaces.RealOutput E_to_grid annotation (Placement(
        transformation(extent={{484,-216},{504,-196}}), iconTransformation(
          extent={{482,-198},{502,-178}})));
  Modelica.Blocks.Sources.CombiTimeTable table_HT_NT(
    final tableOnFile=false,
    table=[0,0.316; 21600,0.316; 21600,0.376; 79200,0.376; 79200,0.316; 86400,
        0.316],
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="HT_NT",
    final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/HT_NT.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{15,15},{-15,-15}},
        rotation=180,
        origin={-125,-375})));

equation

  der(E_from_grid) = (outputs.outputsElec.power_from_grid + outputs.outputsElec.power_to_BAT_from_grid)/3600;
  der(E_to_grid) = outputs.outputsElec.power_to_grid/3600;

  der(costs_elec) = if tariff == 3 then (outputs.outputsElec.power_from_grid + outputs.outputsElec.power_to_BAT_from_grid)/3600*table_ts_price_elec.y[1]/1000
                  elseif tariff == 2 then (outputs.outputsElec.power_from_grid + outputs.outputsElec.power_to_BAT_from_grid)/3600*table_HT_NT.y[1]/1000
                  else (outputs.outputsElec.power_from_grid + outputs.outputsElec.power_to_BAT_from_grid)/3600*price_el;
  der(rev_elec) = outputs.outputsElec.power_to_grid/3600*feed_in_revenue_el;
  der(costs_vio) = outputs.outputsDem.dT_vio*outputs.outputsDem.dT_vio*1000/3600;
  costs_DHW_err = 1000*Q_err_DHW;
  costs_tot = costs_elec - rev_elec + costs_vio;
  der(Q_err_DHW) = Demand.calcmFlow.Q_flowERROR/1000/3600;
  der(Q_del_DHW) = Demand.calcmFlow.Q_flowDELIVERED/1000/3600;
  Q_DHW = (Q_del_DHW + Q_err_DHW);
  der(tot_vio_Kh) = outputs.outputsDem.dT_vio/3600;
  connect(power_to_grid_BAT, Electricity.Pow_BAT_FeedIn) annotation (Line(
        points={{-480,110},{-372,110},{-372,113.2},{-211.091,113.2}},
                                                                    color={0,0,
          127}));
  connect(ch_BAT, Electricity.Pow_BAT_ChBat) annotation (Line(points={{-480,94},
          {-358,94},{-358,106.8},{-211.091,106.8}},
                                                  color={0,0,127}));
  connect(power_use_BAT, Electricity.Pow_BAT_Use) annotation (Line(points={{-480,
          128},{-380,128},{-380,116.4},{-210.727,116.4}},
                                                        color={0,0,127}));
  connect(PV_Distr_Use, Electricity.PV_Distr_Use) annotation (Line(points={{-480,
          176},{-230,176},{-230,139.6},{-210.727,139.6}},
                                                        color={0,0,127}));
  connect(PV_Distr_FeedIn, Electricity.PV_Distr_FeedIn) annotation (Line(points={{-480,
          162},{-236,162},{-236,134},{-210.727,134}},     color={0,0,127}));
  connect(PV_Distr_ChBat, Electricity.PV_Distr_ChBat) annotation (Line(points={{-480,
          146},{-242,146},{-242,128.4},{-210.727,128.4}},    color={0,0,127}));
  connect(Generation.P_el_HP_HR, Electricity.P_el_Gen) annotation (Line(points={{-236,
          -144},{-236,-156},{-252,-156},{-252,86},{-193.636,86},{-193.636,102.8}},
        color={0,0,127}));
  connect(x_HP_heat, add.u1) annotation (Line(points={{-482,-104},{-470,-104},{-470,
          -106},{-464,-106}},       color={0,0,127}));
  connect(x_HP_cool, add.u2) annotation (Line(points={{-482,-122},{-472,-122},{-472,
          -118},{-464,-118}},       color={0,0,127}));
  connect(add.y, HPMode.u)
    annotation (Line(points={{-441,-112},{-436,-112},{-436,-114},{-432,-114}},
                                                       color={0,0,127}));
  connect(HPMode.y, TsupplyHP.u2) annotation (Line(points={{-409,-114},{-404,-114},
          {-404,-204},{-394,-204}}, color={255,0,255}));
  connect(T_supply_HP_heat, TsupplyHP.u1)
    annotation (Line(points={{-482,-196},{-394,-196}}, color={0,0,127}));
  connect(T_supply_cool, TsupplyHP.u3) annotation (Line(points={{-482,-216},{-458,
          -216},{-458,-212},{-394,-212}}, color={0,0,127}));
  connect(dem_elec, MPC_Interface.ElectricityDemand) annotation (Line(points={{-480,24},
          {-314,24},{-314,40},{-312.905,40},{-312.905,65.115}},     color={0,0,127}));
  connect(dem_e_mob, MPC_Interface.EVDemand) annotation (Line(points={{-480,10},
          {-312.905,10},{-312.905,65.115}}, color={0,0,127}));
  connect(dem_dhw_m_flow, MPC_Interface.m_flowDHW) annotation (Line(points={{-480,-6},
          {-314,-6},{-314,18},{-312.905,18},{-312.905,65.115}},     color={0,0,127}));
  connect(dem_dhw_T, MPC_Interface.TDemandDHW) annotation (Line(points={{-480,-24},
          {-314,-24},{-314,16},{-312.905,16},{-312.905,65.115}}, color={0,0,127}));
  connect(ts_gains_human, MPC_Interface.intGains[1]) annotation (Line(points={{-480,
          -42},{-314,-42},{-314,65.115},{-312.905,65.115}}, color={0,0,127}));
  connect(ts_gains_dev, MPC_Interface.intGains[2]) annotation (Line(points={{-480,
          -58},{-314,-58},{-314,65.115},{-312.905,65.115}}, color={0,0,127}));
  connect(ts_gains_light, MPC_Interface.intGains[3]) annotation (Line(points={{-480,
          -80},{-314,-80},{-314,65.115},{-312.905,65.115}}, color={0,0,127}));

  connect(HPMode.y, MPC_Interface.mode_HP) annotation (Line(points={{-409,-114},
          {-310,-114},{-310,65.115},{-312.905,65.115}},
                                            color={255,0,255}));
  connect(heat_rod, hr_rel.u)
    annotation (Line(points={{-482,-232},{-450,-232}}, color={0,0,127}));
  connect(hr_rel.y, MPC_Interface.hr_rel) annotation (Line(points={{-427,-232},{
          -312.905,-232},{-312.905,65.115}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(ch_DHW, MPC_Interface.ch_DHW) annotation (Line(points={{-480,-260},{-312.905,
          -260},{-312.905,65.115}}, color={0,0,127}));
  connect(ch_TES, MPC_Interface.ch_TES) annotation (Line(points={{-480,-284},{-312.905,
          -284},{-312.905,65.115}}, color={0,0,127}));

  connect(dch_TES, MPC_Interface.dch_TES) annotation (Line(points={{-480,-328},{
          -313,-328},{-313,65}}, color={0,0,127}));
  connect(T_supply_UFH, MPC_Interface.T_supply_UFH) annotation (Line(points={{-482,
          -152},{-312.905,-152},{-312.905,65.115}},
                                        color={0,0,127}));
  connect(t_DHW, MPC_Interface.t_DHW) annotation (Line(points={{-480,-342},{-414,
          -342},{-414,-352},{-313,-352},{-313,65}},      color={0,0,127}));
  connect(t_TES, MPC_Interface.t_TES) annotation (Line(points={{-480,-378},{-412,
          -378},{-412,-380},{-313,-380},{-313,65}},      color={0,0,127}));
  connect(TsupplyHP.y, MPC_Interface.T_supply_HP) annotation (Line(points={{-371,
          -204},{-313,-204},{-313,65}},      color={0,0,127}));
  connect(x_HP_on, MPC_Interface.HP_on) annotation (Line(points={{-480,-306},{-312.905,
          -306},{-312.905,65.115}},          color={0,0,127}));
  connect(ts_T_inside_max, MPC_Interface.ts_T_inside_max) annotation (Line(
        points={{-480,-400},{-312.905,-400},{-312.905,65.115}}, color={0,0,127}));
  connect(ts_T_inside_min, MPC_Interface.ts_T_inside_min) annotation (Line(
        points={{-482,-424},{-312.905,-424},{-312.905,65.115}}, color={0,0,127}));
  connect(ts_T_air,weaDat. TDryBul_in) annotation (Line(points={{-478,80},{-438,
          80},{-438,78.7}},             color={0,0,127}));
  connect(ts_win_spe,weaDat. winSpe_in) annotation (Line(points={{-478,64},{-438,
          64},{-438,61.93}}, color={0,0,127}));
  connect(ts_sol_rad,weaDat. HGloHor_only) annotation (Line(points={{-478,46},{-438,
          46},{-438,45.29}},              color={0,0,127}));
  connect(MPC_Interface, Ventilation.inputScenBus) annotation (Line(
      points={{-313,65},{-240,65},{-240,46},{255.35,46},{255.35,7.67}},
      color={255,204,51},
      thickness=0.5));
  connect(MPC_Interface, Control.inputScenBus) annotation (Line(
      points={{-313,65},{-240,65},{-240,72.81},{-159.5,72.81}},
      color={255,204,51},
      thickness=0.5));
  connect(weaDat.weaBus,MPC_Interface. weaBus) annotation (Line(
      points={{-395.5,67.065},{-368,67.065},{-368,65.115},{-312.905,65.115}},
      color={255,204,51},
      thickness=0.5));
  connect(TSoil.y,MPC_Interface. TSoil) annotation (Line(points={{-371.4,52},{-312.905,
          52},{-312.905,65.115}}, color={0,0,127}));
  connect(MPC_Interface.weaBus, Electricity.weaBus) annotation (Line(
      points={{-312.905,65.115},{-312.905,173.6},{-212,173.6}},
      color={255,204,51},
      thickness=0.5));
  connect(Electricity.outBusElec, outputs.outputsElec) annotation (Line(
      points={{-132,109.6},{112,109.6},{112,138},{479.165,138},{479.165,0.15}},
      color={255,204,51},
      thickness=0.5));
  connect(dem_elec, totElecDem.u1) annotation (Line(points={{-480,24},{-246,24},
          {-246,32},{-226,32}}, color={0,0,127}));
  connect(dem_e_mob, totElecDem.u2) annotation (Line(points={{-480,10},{-244,10},
          {-244,20},{-226,20}}, color={0,0,127}));
  connect(totElecDem.y, Electricity.P_el_dom) annotation (Line(points={{-203,26},
          {-192,26},{-192,98},{-162,98},{-162,102.8},{-189.636,102.8}},
                                                                      color={0,0,
          127}));
  connect(ch_Buf.y, outputs.outputsDist.ch_TES) annotation (Line(points={{358.8,
          -298},{458,-298},{458,0},{448,0},{448,0.15},{479.165,0.15}}, color={0,
          0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(ch_DHW1.y, outputs.outputsDist.ch_DHW) annotation (Line(points={{358.8,
          -322},{458,-322},{458,0.15},{479.165,0.15}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  annotation (experiment(
      StopTime=86400,
      Interval=900,
      Tolerance=1e-07,
      __Dymola_Algorithm="Dassl"),
             Icon(coordinateSystem(preserveAspectRatio=false, extent={{-480,-400},
            {480,180}}),                                       graphics={
        Rectangle(
          extent={{-180,-180},{180,70}},
          lineColor={95,95,95},
          fillColor={230,51,35},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-220,70},{0,178},{220,70},{-220,70}},
          lineColor={95,95,95},
          fillColor={145,121,121},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-128,30},{-62,-16}},
          lineColor={95,95,95},
          fillColor={85,170,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{72,30},{110,-16}},
          lineColor={95,95,95},
          fillColor={85,170,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-24,-96},{24,-180}},
          lineColor={95,95,95},
          fillColor={88,59,57},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{74,-104},{112,-150}},
          lineColor={95,95,95},
          fillColor={85,170,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-126,-96},{-88,-142}},
          lineColor={95,95,95},
          fillColor={85,170,255},
          fillPattern=FillPattern.Solid)}),                     Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-480,-400},{480,180}})));
end SFH_FMU_UFH;
