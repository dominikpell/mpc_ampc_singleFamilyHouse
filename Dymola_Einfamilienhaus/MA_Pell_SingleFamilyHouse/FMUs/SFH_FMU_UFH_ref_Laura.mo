within MA_Pell_SingleFamilyHouse.FMUs;
model SFH_FMU_UFH_ref_Laura
  extends Systems.BaseClasses.PartialBuildingEnergySystem(
    redeclare Systems.Subsystems.Ventilation.NoVentilation Ventilation,
    redeclare Systems.Examples.SimpleStudyOfHeatingRodEfficiency parameterStudy(
        efficiceny_heating_rod=0.97, hr_nominal_power=2000),
    redeclare RecordsCollection.ExampleSystemParameters systemParameters(
      TSup_nominal=313.15,
      TRet_nominal=306.15,
      TOda_nominal=261.15,
      T_bivNom=271.15,
      TSetDHW=328.15,
      TSetRoomConst=294.15,
      TOffNight=3,
      nZones=1,
      oneZoneParam=
          MA_Pell_SingleFamilyHouse.Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase.ResidentialBuildingWFloor_SingleDwellingWithFloor(
           useConstantACHrate=true, HeaterOn=false),
      zoneParam=fill(systemParameters.oneZoneParam, systemParameters.nZones),
      filNamWea=if year == 1 then Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Somm_City_Berlin.mos")
           elseif year == 2 then Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Wint_City_Berlin.mos")
           else Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Jahr_City_Berlin.mos"),
      filNamIntGains=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/InternalGains_ResidentialBuildingTabulaMulti.txt"),
      DHWtapping=DHWtapping,
      Q_HP_max=7000,
      oneZoneParamUFH=
          Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase.ResidentialBuildingWFloor_SingleDwellingWithFloor(),
      GradientHeatCurve=1.1,
      use_minLocTime=false,
      use_runPerHou=false,
      pre_n_start=true,
      tauTempSensors=0,
      aux_for_desinfection=false,
      DHWProfile=DHWProfile),
    redeclare Systems.Subsystems.Transfer.UFHTransferSystem_Laura Transfer,
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
      redeclare RecordsCollection.GenerationData.DummyHP heatPumpParameters,
      redeclare RecordsCollection.GenerationData.DummyHR heatingRodParameters(
          eta_hr=parameterStudy.efficiceny_heating_rod, Q_HR_Nom=2000),
      redeclare package Medium_eva = AixLib.Media.Air),
    redeclare Systems.Subsystems.Control.Biv_PI_ConFlow_HPSController_Laura
      Control,
    redeclare
      Systems.Subsystems.Distribution.DistributionTwoStorageParallel
      Distribution(redeclare
        RecordsCollection.StorageData.SimpleStorage.DummySimpleStorage
        bufParameters(nLayer = systemParameters.nLayers,  V=0.3), redeclare
        RecordsCollection.StorageData.SimpleStorage.DummySimpleStorage
        dhwParameters(nLayer = systemParameters.nLayers, V=0.3)));

  Systems.Subsystems.Electricity.Electricity_PVandBAT_ref
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
    annotation (Placement(transformation(extent={{-92,108},{-12,188}})));

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
  parameter AixLib.DataBase.SolarElectric.PVBaseDataDefinition data=
  if IdentifierPV == 1 then AixLib.DataBase.SolarElectric.ShellSP70()
  elseif IdentifierPV == 2 then AixLib.DataBase.SolarElectric.AleoS24185()
  elseif IdentifierPV == 3 then AixLib.DataBase.SolarElectric.CanadianSolarCS6P250P()
  elseif IdentifierPV == 4 then AixLib.DataBase.SolarElectric.QPlusBFRG41285()
  elseif IdentifierPV == 5 then AixLib.DataBase.SolarElectric.SchuecoSPV170SME1()
  else AixLib.DataBase.SolarElectric.SharpNUU235F2()
  "PV Panel data definition" annotation ();
  parameter ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral batteryData=
  if IdentifierBAT == 1 then MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LithiumIon.LithiumIonViessmann()
  elseif IdentifierBAT == 2 then MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LeadAcid.Chloride200Ah()
  elseif IdentifierBAT == 3 then MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LeadAcid.LeadAcidGeneric()
  elseif IdentifierBAT == 4 then MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LeadAcid.Long7Ah()
  elseif IdentifierBAT == 5 then MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LithiumIon.LithiumIonAquion()
  elseif IdentifierBAT == 6 then MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LithiumIon.LithiumIonTeslaPowerwall1()
  else MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.LithiumIon.LithiumIonTeslaPowerwall2()
  "Characteristic data of the battery" annotation ();
  parameter Integer nBat=3 "Number of batteries" annotation(Evaluate=false, Dialog(group="Battery"));
  parameter Integer n_mod=3 "Number of connected PV modules" annotation(Evaluate=false, Dialog(group="PV"));
  parameter Integer IdentifierPV=1 "defines data for PV module" annotation(Evaluate=false, Dialog(group="PV"));
  parameter Integer IdentifierBAT=1 "defines data for Battery" annotation(Evaluate=false, Dialog(group="Battery"));
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
  parameter Integer tariff=1 annotation(Evaluate=false, Dialog(tab="Economic"));
  parameter Real price_el=0.25/1000 "electricity costs in €/Wh" annotation(Evaluate=false, Dialog(tab="Economic"));
  parameter Real price_comfort_vio=1000 "sanctioned price for discomfort in €/K^2" annotation(Evaluate=false, Dialog(tab="Economic"));
  parameter Real feed_in_revenue_el=0.08/1000 "electricity feed in revenue in €/Wh" annotation(Evaluate=false, Dialog(tab="Economic"));

Modelica.Blocks.Interfaces.RealInput dem_elec annotation (Placement(
      transformation(extent={{-490,4},{-470,24}}),  iconTransformation(
        extent={{-490,14},{-470,34}})));
Modelica.Blocks.Interfaces.RealInput dem_e_mob annotation (Placement(
      transformation(extent={{-490,-10},{-470,10}}),
                                                   iconTransformation(
        extent={{-490,0},{-470,20}})));
Modelica.Blocks.Interfaces.RealInput mFlow_DHW annotation (Placement(
      transformation(extent={{-490,-26},{-470,-6}}), iconTransformation(
        extent={{-490,-16},{-470,4}})));
Modelica.Blocks.Interfaces.RealInput TDem_DHW annotation (Placement(
      transformation(extent={{-490,-48},{-470,-28}}), iconTransformation(
        extent={{-490,-36},{-470,-16}})));
Modelica.Blocks.Interfaces.RealInput ts_gains_human annotation (Placement(
      transformation(extent={{-490,-62},{-470,-42}}), iconTransformation(
        extent={{-490,-58},{-470,-38}})));
Modelica.Blocks.Interfaces.RealInput ts_gains_dev annotation (Placement(
      transformation(extent={{-490,-78},{-470,-58}}), iconTransformation(
        extent={{-490,-76},{-470,-56}})));
Modelica.Blocks.Interfaces.RealInput ts_gains_light annotation (Placement(
      transformation(extent={{-490,-104},{-470,-84}}),iconTransformation(
        extent={{-490,-104},{-470,-84}})));


  Modelica.Blocks.Interfaces.RealInput ts_T_inside_max annotation (Placement(
        transformation(extent={{-488,-118},{-468,-98}}),  iconTransformation(
          extent={{-492,-138},{-472,-118}})));
  Modelica.Blocks.Interfaces.RealInput ts_T_inside_min annotation (Placement(
        transformation(extent={{-488,-136},{-468,-116}}), iconTransformation(
          extent={{-492,-164},{-472,-144}})));
  Electrical.ElectricalControl.PVBatteryControl.DirectCharge
    directChargeControl(threshold=batteryData.SOC_min) annotation (Placement(
        transformation(
        extent={{84,-40},{-84,40}},
        rotation=0,
        origin={-156,232})));
  Modelica.Blocks.Math.Add totElecDm
    annotation (Placement(transformation(extent={{-296,276},{-276,296}})));
  replaceable Systems.Subsystems.InputScenario.ReaderTMY3
                                                  weaDat(
    filNam=systemParameters.filNamWea,
    TDryBulSou=AixLib.BoundaryConditions.Types.DataSource.Input,
    winSpeSou=AixLib.BoundaryConditions.Types.DataSource.Input,
    HSou=AixLib.BoundaryConditions.Types.RadiationDataSource.File)
    "Weather data reader"
    annotation (Placement(transformation(extent={{-438,62},{-398,88}})));
  Modelica.Blocks.Sources.Constant TSoil(k=systemParameters.TSoilConst)
    annotation (Placement(transformation(extent={{-386,54},{-374,66}})));
  Modelica.Blocks.Interfaces.RealInput ts_T_air(
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") annotation (Placement(transformation(extent={{-490,78},{
            -470,98}}),  iconTransformation(extent={{-490,78},{-470,98}})));
  Modelica.Blocks.Interfaces.RealInput ts_sol_rad annotation (Placement(
        transformation(extent={{-490,44},{-470,64}}), iconTransformation(
          extent={{-490,38},{-470,58}})));
  Modelica.Blocks.Interfaces.RealInput ts_win_spe annotation (Placement(
        transformation(extent={{-490,62},{-470,82}}), iconTransformation(
          extent={{-490,58},{-470,78}})));
  Interfaces.REFControlBus Control_Interface annotation (Placement(
        transformation(extent={{-334,50},{-296,96}}), iconTransformation(extent=
           {{-294,34},{-256,80}})));

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
  Real tot_vio_Kh;
  Real Q_del_DHW;
    Real Q_HP;
    Real W_HP;
  output Modelica.Blocks.Interfaces.RealOutput Q_err_DHW
    annotation (Placement(transformation(extent={{482,-156},{502,-136}})));
  output Modelica.Blocks.Interfaces.RealOutput Q_DHW
    annotation (Placement(transformation(extent={{482,-176},{502,-156}})));

  output Modelica.Blocks.Interfaces.RealOutput E_from_grid annotation (
      Placement(transformation(extent={{482,-194},{502,-174}}),
        iconTransformation(extent={{482,-198},{502,-178}})));
  output Modelica.Blocks.Interfaces.RealOutput E_to_grid annotation (Placement(
        transformation(extent={{484,-212},{504,-192}}), iconTransformation(
          extent={{482,-198},{502,-178}})));
  Modelica.Blocks.Sources.RealExpression ch_Buf(y=if Distribution.sigBusDistr.buffer_on
         then Generation.artificalPumpIsotermhal.m_flow_in*systemParameters.c_pWater
        *(Generation.senTemVL1.T - Generation.heatPump.sigBus.TConInMea) else 0)
    annotation (Placement(transformation(
        extent={{8,-6},{-8,6}},
        rotation=180,
        origin={324,50})));
  Modelica.Blocks.Sources.RealExpression ch_DHW1(y=if Distribution.sigBusDistr.buffer_on
         == false then Generation.artificalPumpIsotermhal.m_flow_in*
        systemParameters.c_pWater*(Generation.senTemVL1.T - Generation.heatPump.sigBus.TConInMea)
         else 0)
    annotation (Placement(transformation(
        extent={{8,-6},{-8,6}},
        rotation=180,
        origin={324,26})));
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
        origin={-269,-225})));

  Modelica.Blocks.Sources.CombiTimeTable table_HT_NT(
    final tableOnFile=false,
    table=[0,0.316; 21600,0.316; 21600,0.376; 79200,0.376; 79200,0.316; 86400,0.316],
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="HT_NT",
    final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/HT_NT.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{15,15},{-15,-15}},
        rotation=180,
        origin={-195,-239})));

equation
  der(E_from_grid) = (outputs.outputsElec.power_from_grid + outputs.outputsElec.power_to_BAT_from_grid)/3600;
  der(E_to_grid) = outputs.outputsElec.power_to_grid/3600;
    der(costs_elec) = if tariff == 3 then (outputs.outputsElec.power_from_grid + outputs.outputsElec.power_to_BAT_from_grid)/3600*table_ts_price_elec.y[1]/1000
                  elseif tariff == 2 then (outputs.outputsElec.power_from_grid + outputs.outputsElec.power_to_BAT_from_grid)/3600*table_HT_NT.y[1]/1000
                  else (outputs.outputsElec.power_from_grid + outputs.outputsElec.power_to_BAT_from_grid)/3600*price_el;der(rev_elec) = outputs.outputsElec.power_to_grid/3600*feed_in_revenue_el;
  der(costs_vio) = outputs.outputsDem.dT_vio*outputs.outputsDem.dT_vio*1000/3600;
  costs_DHW_err = 1000*Q_err_DHW;
  costs_tot = costs_elec - rev_elec + costs_vio;
  der(Q_err_DHW) = Demand.calcmFlow.Q_flowERROR/1000/3600;
  der(Q_del_DHW) = Demand.calcmFlow.Q_flowDELIVERED/1000/3600;
  Q_DHW = (Q_del_DHW + Q_err_DHW);
  der(tot_vio_Kh) = outputs.outputsDem.dT_vio/3600;
  der(Q_HP) = outputs.outputsGen.heat_HP;
  der(W_HP) = outputs.outputsGen.power_HP;

  connect(Generation.P_el_HP_HR, Electricity.P_el_Gen) annotation (Line(points={{-236,
          -144},{-236,-172},{-334,-172},{-334,102},{-51.6,102},{-51.6,110.8}},
        color={0,0,127}));
  connect(mFlow_DHW, Control_Interface.m_flowDHW) annotation (Line(points={{-480,
          -16},{-316,-16},{-316,8},{-314.905,8},{-314.905,73.115}}, color={0,0,127}));
  connect(TDem_DHW, Control_Interface.TDemandDHW) annotation (Line(points={{-480,
          -38},{-316,-38},{-316,6},{-314.905,6},{-314.905,73.115}}, color={0,0,127}));
  connect(ts_gains_human, Control_Interface.intGains[1]) annotation (Line(
        points={{-480,-52},{-316,-52},{-316,73.115},{-314.905,73.115}}, color={0,
          0,127}));
  connect(ts_gains_dev, Control_Interface.intGains[2]) annotation (Line(points={
          {-480,-68},{-316,-68},{-316,73.115},{-314.905,73.115}}, color={0,0,127}));
  connect(ts_gains_light, Control_Interface.intGains[3]) annotation (Line(
        points={{-480,-94},{-316,-94},{-316,73.115},{-314.905,73.115}}, color={0,
          0,127}));
connect(Demand.TZone, Control.TRoom) annotation (Line(points={{99.6,6.92},{
        31.8,6.92},{31.8,92.38},{-33.25,92.38}}, color={0,0,127}));

  connect(directChargeControl.PV_Distr_Use, Electricity.PV_Distr_Use)
    annotation (Line(points={{-201.5,191.2},{-201.5,147.6},{-89.2,147.6}},
        color={0,0,127}));
  connect(directChargeControl.PV_Distr_FeedIn, Electricity.PV_Distr_FeedIn)
    annotation (Line(points={{-214.1,191.2},{-214.1,142},{-89.2,142}}, color={0,
          0,127}));
  connect(directChargeControl.PV_Distr_ChBat, Electricity.PV_Distr_ChBat)
    annotation (Line(points={{-226,191.2},{-226,136.4},{-89.2,136.4}}, color={0,
          0,127}));
  connect(directChargeControl.Pow_BAT_ChBat, Electricity.Pow_BAT_ChBat)
    annotation (Line(points={{-158.1,189.6},{-158.1,113.2},{-89.2,113.2}},
        color={0,0,127}));
  connect(directChargeControl.Pow_BAT_FeedIn, Electricity.Pow_BAT_FeedIn)
    annotation (Line(points={{-146.2,189.6},{-146.2,118.8},{-89.2,118.8}},
        color={0,0,127}));
  connect(directChargeControl.Pow_BAT_Use, Electricity.Pow_BAT_Use) annotation (
     Line(points={{-136.4,189.6},{-136.4,124.4},{-89.2,124.4}}, color={0,0,127}));
  connect(directChargeControl.GenEleLoadAC, Generation.P_el_HP_HR) annotation (
      Line(points={{-137.1,273.6},{-137.1,296},{-258,296},{-258,-180},{-236,-180},
          {-236,-144}}, color={0,0,127}));
  connect(directChargeControl.BuiEleLoadAC, totElecDm.y) annotation (Line(
        points={{-156,273.6},{-156,286},{-275,286}}, color={0,0,127}));
  connect(ts_T_air,weaDat. TDryBul_in) annotation (Line(points={{-480,88},{-440,
          88},{-440,86.7}},             color={0,0,127}));
  connect(ts_win_spe,weaDat. winSpe_in) annotation (Line(points={{-480,72},{-440,
          72},{-440,69.93}}, color={0,0,127}));
  connect(ts_sol_rad,weaDat. HGloHor_only) annotation (Line(points={{-480,54},{-440,
          54},{-440,53.29}},              color={0,0,127}));
  connect(Control_Interface, Ventilation.inputScenBus) annotation (Line(
      points={{-315,73},{-242,73},{-242,36},{256,36},{256,22},{255.35,22},{
          255.35,7.67}},
      color={255,204,51},
      thickness=0.5));
  connect(weaDat.weaBus, Control_Interface.weaBus) annotation (Line(
      points={{-397.5,75.065},{-370,75.065},{-370,73.115},{-314.905,73.115}},
      color={255,204,51},
      thickness=0.5));
  connect(TSoil.y, Control_Interface.TSoil) annotation (Line(points={{-373.4,60},
          {-314.905,60},{-314.905,73.115}}, color={0,0,127}));
  connect(Control_Interface, Control.inputScenBus) annotation (Line(
      points={{-315,73},{-234.5,73},{-234.5,72.81},{-159.5,72.81}},
      color={255,204,51},
      thickness=0.5));
  connect(dem_elec, totElecDm.u1) annotation (Line(points={{-480,14},{-350,14},
          {-350,292},{-298,292}}, color={0,0,127}));
  connect(dem_e_mob, totElecDm.u2) annotation (Line(points={{-480,0},{-342,0},{
          -342,280},{-298,280}}, color={0,0,127}));
  connect(ts_T_inside_min, Control_Interface.ts_T_inside_min) annotation (Line(
        points={{-478,-126},{-388,-126},{-388,-128},{-314.905,-128},{-314.905,
          73.115}}, color={0,0,127}));
  connect(ts_T_inside_max, Control_Interface.ts_T_inside_max) annotation (Line(
        points={{-478,-108},{-314.905,-108},{-314.905,73.115}}, color={0,0,127}));
  connect(totElecDm.y, Electricity.P_el_dom) annotation (Line(points={{-275,286},
          {-270,286},{-270,104},{-44,104},{-44,110.8},{-42.8,110.8}},
                                                                color={0,0,127}));
  connect(Electricity.outBusElec, outputs.outputsElec) annotation (Line(
      points={{-12,148},{224,148},{224,140},{479.165,140},{479.165,0.15}},
      color={255,204,51},
      thickness=0.5));
  connect(directChargeControl.PVPowerDC, outputs.outputsElec.power_PV)
    annotation (Line(points={{-179.8,272.8},{-182,272.8},{-182,290},{479.165,
          290},{479.165,0.15}}, color={0,0,127}));
  connect(weaDat.weaBus, Electricity.weaBus) annotation (Line(
      points={{-397.5,75.065},{-364,75.065},{-364,181.6},{-92,181.6}},
      color={255,204,51},
      thickness=0.5));
  connect(directChargeControl.SOCBat, outputs.outputsElec.soc_BAT) annotation (
      Line(points={{-111.9,273.6},{-111.9,302},{479.165,302},{479.165,0.15}},
        color={0,0,127}));
  connect(ch_Buf.y, outputs.outputsDist.ch_TES) annotation (Line(points={{332.8,
          50},{418,50},{418,6},{420,6},{420,0.15},{479.165,0.15}},     color={0,
          0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(ch_DHW1.y, outputs.outputsDist.ch_DHW) annotation (Line(points={{332.8,
          26},{432,26},{432,0.15},{479.165,0.15}},     color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
annotation (experiment(
    StopTime=86400,
    Interval=900,
    Tolerance=1e-07,
    __Dymola_Algorithm="Dassl"),
           Icon(coordinateSystem(preserveAspectRatio=false), graphics={
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
      coordinateSystem(preserveAspectRatio=false)));
end SFH_FMU_UFH_ref_Laura;
