within MA_Pell_SingleFamilyHouse.FMUs;
model SFH_FMU_radiator
  extends Systems.BaseClasses.PartialBuildingEnergySystem(
    redeclare Systems.Subsystems.Ventilation.NoVentilation Ventilation,
    redeclare Systems.Examples.SimpleStudyOfHeatingRodEfficiency parameterStudy,
    redeclare RecordsCollection.ExampleSystemParameters systemParameters(
      TSetRoomConst=294.15,
      TOffNight=3,
      nZones=1,
      oneZoneParam=
          MA_Pell_SingleFamilyHouse.Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase.ResidentialBuildingWFloor_SingleDwellingWithFloor(),
      zoneParam=fill(systemParameters.oneZoneParam, systemParameters.nZones),
      filNamIntGains=Modelica.Utilities.Files.loadResource(
          "modelica://MA_Pell_SingleFamilyHouse/Data/InternalGains_ResidentialBuildingTabulaMulti.txt"),
      DHWtapping=DHWtapping,
      use_ufh=false,
      DHWProfile=DHWProfile),
    redeclare Systems.Subsystems.Transfer.RadiatorTransferSystem Transfer,
    redeclare Systems.Subsystems.Demand.DemandCase Demand(redeclare
        Components.DHW.calcmFlowEquStatic calcmFlow),
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
    timZon=inputScenario.weaDat.timZon,
    SOC_Bat_Init=SOC_Bat_Init/100,
    n_mod=n_mod,
    data=data,
    batteryData=batteryData,
    nBat=nBat)
    annotation (Placement(transformation(extent={{-200,100},{-120,180}})));

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
  Modelica.Blocks.Interfaces.RealInput T_air annotation (Placement(
        transformation(extent={{-490,70},{-470,90}}), iconTransformation(extent={{-490,70},
            {-470,90}})));
  Modelica.Blocks.Interfaces.RealInput ElecDemand annotation (Placement(
        transformation(extent={{-490,22},{-470,42}}), iconTransformation(extent={{-490,22},
            {-470,42}})));
  Modelica.Blocks.Interfaces.RealInput EVDemand annotation (Placement(
        transformation(extent={{-490,4},{-470,24}}),  iconTransformation(extent={{-490,4},
            {-470,24}})));
  Modelica.Blocks.Interfaces.RealInput H_GloHor annotation (Placement(
        transformation(extent={{-490,38},{-470,58}}), iconTransformation(extent={{-490,38},
            {-470,58}})));

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
  Modelica.Blocks.Interfaces.RealInput IntGains[3] annotation (Placement(
        transformation(extent={{-490,-14},{-470,6}}), iconTransformation(extent={{-490,
            -14},{-470,6}})));
  Modelica.Blocks.Interfaces.RealInput mFlow_DHW annotation (Placement(
        transformation(extent={{-490,-34},{-470,-14}}),iconTransformation(
          extent={{-490,-34},{-470,-14}})));
  Modelica.Blocks.Interfaces.RealInput TDem_DHW annotation (Placement(
        transformation(extent={{-490,-56},{-470,-36}}), iconTransformation(
          extent={{-490,-56},{-470,-36}})));
  Modelica.Blocks.Interfaces.RealInput winSpe
                                             annotation (Placement(
        transformation(extent={{-490,54},{-470,74}}), iconTransformation(extent={{-490,54},
            {-470,74}})));
equation
  connect(Electricity.SOC_Bat,SOC_BAT)  annotation (Line(points={{-116,106.4},{
          188,106.4},{188,100},{490,100}},
                                     color={0,0,127}));
  connect(BAT_Pow_FeedIn, Electricity.Pow_BAT_FeedIn) annotation (Line(points={{-480,
          110},{-372,110},{-372,110.8},{-197.2,110.8}}, color={0,0,127}));
  connect(BAT_Pow_Ch, Electricity.Pow_BAT_ChBat) annotation (Line(points={{-480,94},
          {-358,94},{-358,105.2},{-197.2,105.2}},       color={0,0,127}));
  connect(BAT_Pow_Use, Electricity.Pow_BAT_Use) annotation (Line(points={{-480,128},
          {-380,128},{-380,116.4},{-197.2,116.4}},color={0,0,127}));
  connect(Electricity.ElectricityFeedIn, FeedIn)
    annotation (Line(points={{-116,116},{490,116}}, color={0,0,127}));
  connect(Electricity.ElectricityFromGrid, ElecFromGrid) annotation (Line(
        points={{-116,125.6},{150,125.6},{150,126},{416,126},{416,136},{490,136}},
        color={0,0,127}));
  connect(inputScenario.inputScenBus, Electricity.inputScenBus) annotation (
      Line(
      points={{-263.7,55.9},{-248,55.9},{-248,151.6},{-199.6,151.6}},
      color={255,204,51},
      thickness=0.5));
  connect(PV_Distr_Use, Electricity.PV_Distr_Use) annotation (Line(points={{-480,
          176},{-230,176},{-230,139.6},{-197.2,139.6}}, color={0,0,127}));
  connect(PV_Distr_FeedIn, Electricity.PV_Distr_FeedIn) annotation (Line(points=
         {{-480,162},{-236,162},{-236,134},{-197.2,134}}, color={0,0,127}));
  connect(PV_Distr_ChBat, Electricity.PV_Distr_ChBat) annotation (Line(points={{
          -480,146},{-242,146},{-242,128.4},{-197.2,128.4}}, color={0,0,127}));
  connect(T_air, inputScenario.TDryBulb)
    annotation (Line(points={{-480,80},{-392,80},{-392,80.4},{-304,80.4}},
                                                   color={0,0,127}));
  connect(ElecDemand, inputScenario.ElecDemand) annotation (Line(points={{-480,32},
          {-382,32},{-382,58},{-344,58},{-344,70.2},{-304,70.2}},
                                          color={0,0,127}));
  connect(EVDemand, inputScenario.EVDemand) annotation (Line(points={{-480,14},
          {-370,14},{-370,54},{-304,54},{-304,66.2}},color={0,0,127}));
  connect(inputScenario.H_GloHor, H_GloHor) annotation (Line(points={{-304,73.8},
          {-334,73.8},{-334,70},{-406,70},{-406,48},{-480,48}}, color={0,0,127}));
  connect(Electricity.PV_Pow_Use, PV_Pow_Use) annotation (Line(points={{-116,
          172},{-70,172},{-70,186},{490,186}},  color={0,0,127}));
  connect(Electricity.PV_Pow_FeedIn, PV_Pow_FeedIn) annotation (Line(points={{-116,
          162.4},{-70,162.4},{-70,168},{490,168}},           color={0,0,127}));
  connect(Electricity.PV_Pow_Ch, PV_Pow_Ch) annotation (Line(points={{-116,
          151.2},{184,151.2},{184,152},{490,152}},
                                            color={0,0,127}));
  connect(Generation.P_el_HP_HR, Electricity.P_el_Gen) annotation (Line(points=
          {{-236,-144},{-236,-172},{-334,-172},{-334,86},{-160,86},{-160,96.8}},
        color={0,0,127}));
  connect(IntGains, inputScenario.IntGains) annotation (Line(points={{-480,-4},
          {-366,-4},{-366,62.6},{-304,62.6}},
                                            color={0,0,127}));
  connect(mFlow_DHW, inputScenario.mFlow_DHW) annotation (Line(points={{-480,
          -24},{-362,-24},{-362,58.8},{-304,58.8}}, color={0,0,127}));
  connect(TDem_DHW, inputScenario.TDem_DHW) annotation (Line(points={{-480,-46},
          {-358,-46},{-358,54.4},{-304,54.4}}, color={0,0,127}));
  connect(winSpe, inputScenario.winSpe) annotation (Line(points={{-480,64},{
          -418,64},{-418,77},{-304,77}}, color={0,0,127}));
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
end SFH_FMU_radiator;
