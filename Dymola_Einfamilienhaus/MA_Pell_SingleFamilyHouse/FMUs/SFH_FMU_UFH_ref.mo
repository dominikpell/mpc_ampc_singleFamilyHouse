within MA_Pell_SingleFamilyHouse.FMUs;
model SFH_FMU_UFH_ref
  extends Systems.BaseClasses.PartialBuildingEnergySystem(
    redeclare Systems.Subsystems.Ventilation.NoVentilation Ventilation,
    redeclare Systems.Examples.SimpleStudyOfHeatingRodEfficiency parameterStudy(
        efficiceny_heating_rod=0.97, hr_nominal_power=2000),
    redeclare RecordsCollection.ExampleSystemParameters systemParameters(
      TSup_nominal=313.15,
      TRet_nominal=306.15,
      TOda_nominal=261.15,
      T_bivNom=271.15,
      TSetRoomConst=294.15,
      TOffNight=3,
      nZones=1,
      oneZoneParam=
          MA_Pell_SingleFamilyHouse.Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase.ResidentialBuildingWFloor_SingleDwellingWithFloor(
          useConstantACHrate=true, HeaterOn=true),
      zoneParam=fill(systemParameters.oneZoneParam, systemParameters.nZones),
      filNamWea=Modelica.Utilities.Files.loadResource(
          "modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Somm_City_Berlin.mos"),
      filNamIntGains=Modelica.Utilities.Files.loadResource(
          "modelica://MA_Pell_SingleFamilyHouse/Data/InternalGains_ResidentialBuildingTabulaMulti.txt"),
      DHWtapping=DHWtapping,
      oneZoneParamUFH=
          Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase.ResidentialBuildingWFloor_SingleDwellingWithFloor(),
      use_minRunTime=true,
      use_minLocTime=false,
      use_runPerHou=false,
      pre_n_start=true,
      aux_for_desinfection=false,
      TAir_start=291.15,
      DHWProfile=DHWProfile),
    redeclare Systems.Subsystems.Transfer.UFHTransferSystem_ref Transfer,
    redeclare Systems.Subsystems.Demand.DemandCase Demand(
      redeclare Components.DHW.calcmFlowEquStatic calcmFlow,
      T_Roof=T_Roof,
      T_Air=T_Air,
      T_IntWall=T_IntWall,
      T_ExtWall=T_ExtWall,
      T_Floor=T_Floor,
      T_Win=T_Win),
    redeclare Systems.Subsystems.Generation.GenerationHeatPumpAndHeatingRod
      Generation(
      redeclare RecordsCollection.GenerationData.DummyHP heatPumpParameters,
      redeclare RecordsCollection.GenerationData.DummyHR heatingRodParameters(
          eta_hr=parameterStudy.efficiceny_heating_rod, Q_HR_Nom=parameterStudy.hr_nominal_power),
      redeclare package Medium_eva = AixLib.Media.Air),
    redeclare Systems.Subsystems.Control.Biv_PI_ConFlow_HPSController Control,
    redeclare Systems.Subsystems.Distribution.DistributionTwoStorageParallel
      Distribution(redeclare
        RecordsCollection.StorageData.SimpleStorage.DummySimpleStorage
        bufParameters, redeclare
        RecordsCollection.StorageData.SimpleStorage.DummySimpleStorage
        dhwParameters(V=Distribution.dhwParameters.V_dhw_day)));

  Systems.Subsystems.Electricity.Electricity_PVandBAT_MPC Electricity(
    timZon=weaDat.timZon,
    SOC_Bat_Init=SOC_Bat_Init/100,
    n_mod=n_mod,
    data=data,
    batteryData=batteryData,
    nBat=nBat)
    annotation (Placement(transformation(extent={{-214,100},{-134,180}})));

  parameter MA_Pell_SingleFamilyHouse.Components.DHW.DHWProfile DHWtapping=
    MA_Pell_SingleFamilyHouse.Components.DHW.DHWProfile.M annotation(Evaluate=false);
  parameter MA_Pell_SingleFamilyHouse.RecordsCollection.DHW.PartialDHWTap DHWProfile=
    MA_Pell_SingleFamilyHouse.RecordsCollection.DHW.ProfileM() annotation(Evaluate=false);
  parameter Real SOC_Bat_Init=50 "State of Charge in %" annotation(Dialog(group="Battery"));
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
  parameter Real T_Air=291.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_thermalCapacity_top=298.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_thermalCapacity_down=298.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_Roof=291.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_IntWall=291.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_ExtWall=291.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_Floor=291.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real T_Win=291.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real t_TES=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real t_DHW=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));

  Modelica.Blocks.Interfaces.RealInput PV_Distr_FeedIn
    annotation (Placement(transformation(extent={{-490,152},{-470,172}})));
  Modelica.Blocks.Interfaces.RealInput PV_Distr_ChBat
    annotation (Placement(transformation(extent={{-490,136},{-470,156}})));
  Modelica.Blocks.Interfaces.RealInput PV_Distr_Use
    annotation (Placement(transformation(extent={{-490,166},{-470,186}})));
  Modelica.Blocks.Interfaces.RealInput BAT_Pow_Use
    annotation (Placement(transformation(extent={{-490,118},{-470,138}})));
  Modelica.Blocks.Interfaces.RealInput BAT_Pow_FeedIn
    annotation (Placement(transformation(extent={{-490,100},{-470,120}})));
  Modelica.Blocks.Interfaces.RealInput BAT_Pow_Ch
    annotation (Placement(transformation(extent={{-490,84},{-470,104}})));

  output Modelica.Blocks.Interfaces.RealOutput SOC_BAT
    annotation (Placement(transformation(extent={{480,90},{500,110}})));
  output Modelica.Blocks.Interfaces.RealOutput FeedIn
    annotation (Placement(transformation(extent={{480,106},{500,126}})));
  output Modelica.Blocks.Interfaces.RealOutput ElecFromGrid
    annotation (Placement(transformation(extent={{480,126},{500,146}})));

  output Modelica.Blocks.Interfaces.RealOutput PV_Pow_Use
    annotation (Placement(transformation(extent={{480,176},{500,196}})));
  output Modelica.Blocks.Interfaces.RealOutput PV_Pow_Ch
    annotation (Placement(transformation(extent={{480,142},{500,162}})));
  output Modelica.Blocks.Interfaces.RealOutput PV_Pow_FeedIn
    annotation (Placement(transformation(extent={{480,158},{500,178}})));
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
          extent={{-490,-38},{-470,-18}})));
  Modelica.Blocks.Interfaces.RealInput ts_gains_human annotation (Placement(
        transformation(extent={{-490,-62},{-470,-42}}), iconTransformation(
          extent={{-490,-52},{-470,-32}})));
  Modelica.Blocks.Interfaces.RealInput ts_gains_dev annotation (Placement(
        transformation(extent={{-490,-78},{-470,-58}}), iconTransformation(
          extent={{-490,-68},{-470,-48}})));
  Modelica.Blocks.Interfaces.RealInput ts_gains_light annotation (Placement(
        transformation(extent={{-490,-98},{-470,-78}}), iconTransformation(
          extent={{-488,-84},{-468,-64}})));
  Modelica.Blocks.Sources.CombiTimeTable tableTSet(
    tableOnFile=true,
    tableName="Tset",
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/TsetHeat_Residential_WithNightMode.txt"),
    columns=2:2)
    "Set points for heater"
    annotation (Placement(transformation(extent={{-474,-190},{-426,-142}})));

equation
  connect(Electricity.SOC_Bat,SOC_BAT)  annotation (Line(points={{-130,106.4},{
          188,106.4},{188,100},{490,100}},
                                     color={0,0,127}));
  connect(BAT_Pow_FeedIn, Electricity.Pow_BAT_FeedIn) annotation (Line(points={{-480,
          110},{-372,110},{-372,113.2},{-213.091,113.2}},
                                                        color={0,0,127}));
  connect(BAT_Pow_Ch, Electricity.Pow_BAT_ChBat) annotation (Line(points={{-480,94},
          {-358,94},{-358,106.8},{-213.091,106.8}},     color={0,0,127}));
  connect(BAT_Pow_Use, Electricity.Pow_BAT_Use) annotation (Line(points={{-480,
          128},{-380,128},{-380,116.4},{-212.727,116.4}},
                                                  color={0,0,127}));
  connect(Electricity.ElectricityFeedIn, FeedIn)
    annotation (Line(points={{-130,116},{490,116}}, color={0,0,127}));
  connect(Electricity.ElectricityFromGrid, ElecFromGrid) annotation (Line(
        points={{-130,128},{150,128},{150,126},{416,126},{416,136},{490,136}},
        color={0,0,127}));
  connect(PV_Distr_Use, Electricity.PV_Distr_Use) annotation (Line(points={{-480,
          176},{-230,176},{-230,139.6},{-212.727,139.6}},
                                                        color={0,0,127}));
  connect(PV_Distr_FeedIn, Electricity.PV_Distr_FeedIn) annotation (Line(points={{-480,
          162},{-236,162},{-236,134},{-212.727,134}},     color={0,0,127}));
  connect(PV_Distr_ChBat, Electricity.PV_Distr_ChBat) annotation (Line(points={{-480,
          146},{-242,146},{-242,128.4},{-212.727,128.4}},    color={0,0,127}));
  connect(Electricity.PV_Pow_Use, PV_Pow_Use) annotation (Line(points={{-130,
          172},{-70,172},{-70,186},{490,186}},  color={0,0,127}));
  connect(Electricity.PV_Pow_FeedIn, PV_Pow_FeedIn) annotation (Line(points={{-130,
          162.4},{-70,162.4},{-70,168},{490,168}},           color={0,0,127}));
  connect(Electricity.PV_Pow_Ch, PV_Pow_Ch) annotation (Line(points={{-130,
          151.2},{184,151.2},{184,152},{490,152}},
                                            color={0,0,127}));
  connect(Generation.P_el_HP_HR, Electricity.P_el_Gen) annotation (Line(points={{-236,
          -144},{-236,-172},{-334,-172},{-334,86},{-195.636,86},{-195.636,102.8}},
        color={0,0,127}));
  connect(MPC_Interface, Electricity.inputScenBus) annotation (Line(
      points={{-315,57},{-242,57},{-242,151.6},{-213.6,151.6}},
      color={255,204,51},
      thickness=0.5));
  connect(dem_elec, MPC_Interface.ElectricityDemand) annotation (Line(points={{-480,14},
          {-316,14},{-316,30},{-314.905,30},{-314.905,57.115}},     color={0,0,127}));
  connect(dem_e_mob, MPC_Interface.EVDemand) annotation (Line(points={{-480,0},
          {-314.905,0},{-314.905,57.115}},  color={0,0,127}));
  connect(mFlow_DHW, MPC_Interface.m_flowDHW) annotation (Line(points={{-480,
          -16},{-316,-16},{-316,8},{-314.905,8},{-314.905,57.115}}, color={0,0,
          127}));
  connect(TDem_DHW, MPC_Interface.TDemandDHW) annotation (Line(points={{-480,
          -38},{-316,-38},{-316,6},{-314.905,6},{-314.905,57.115}}, color={0,0,
          127}));
  connect(ts_gains_human, MPC_Interface.intGains[1]) annotation (Line(points={{-480,
          -52},{-316,-52},{-316,57.115},{-314.905,57.115}}, color={0,0,127}));
  connect(ts_gains_dev, MPC_Interface.intGains[2]) annotation (Line(points={{-480,
          -68},{-316,-68},{-316,57.115},{-314.905,57.115}}, color={0,0,127}));
  connect(ts_gains_light, MPC_Interface.intGains[3]) annotation (Line(points={{-480,
          -88},{-316,-88},{-316,57.115},{-314.905,57.115}}, color={0,0,127}));
  connect(tableTSet.y[1], MPC_Interface.ts_T_inside) annotation (Line(points={{
          -423.6,-166},{-384,-166},{-384,-162},{-314.905,-162},{-314.905,57.115}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  annotation (experiment(
      StopTime=31536000,
      Interval=900.00288,
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
end SFH_FMU_UFH_ref;
