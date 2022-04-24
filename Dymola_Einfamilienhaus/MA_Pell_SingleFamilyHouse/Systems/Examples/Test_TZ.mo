within MA_Pell_SingleFamilyHouse.Systems.Examples;
model Test_TZ
  replaceable package MediumZone = AixLib.Media.Air constrainedby
    Modelica.Media.Interfaces.PartialMedium annotation (__Dymola_choicesAllMatching=true);
  AixLib.ThermalZones.ReducedOrder.ThermalZone.ThermalZone thermalZone(
    zoneParam=
        Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase.ResidentialBuildingWFloor_SingleDwellingWithFloor(
        HeaterOn=false),
            redeclare final package Medium = MediumZone,
    use_AirExchange=true)
    annotation (Placement(transformation(extent={{-40,-34},{54,56}})));
  Modelica.Blocks.Sources.Constant constTSetRoom(each final k=systemParameters.TSetRoomConst)
    "Transform Volume l to massflowrate" annotation (Placement(transformation(
        extent={{6,6},{-6,-6}},
        rotation=180,
        origin={-82,24})));
  Modelica.Blocks.Sources.Constant vent(each final k=systemParameters.ventRate)
    "Transform Volume l to massflowrate" annotation (Placement(transformation(
        extent={{9,9},{-9,-9}},
        rotation=180,
        origin={-81,-7})));

  Modelica.Blocks.Math.Gain gainIntGains[3](each k=1)
    "Profiles for internal gains" annotation (Placement(transformation(
        extent={{6,6},{-6,-6}},
        rotation=180,
        origin={-136,56})));
  Modelica.Blocks.Sources.CombiTimeTable tableInternalGains(
    final tableOnFile=true,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="Internals",
    final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/InternalGains_ResidentialBuildingTabulaMulti.txt"),
    columns=2:4) "Profiles for internal gains"
    annotation (Placement(transformation(extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-171,55})));

  AixLib.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Somm_City_Berlin.mos"))
    "Weather data reader"
    annotation (Placement(transformation(extent={{-204,18},{-190,34}})));
  AixLib.BoundaryConditions.WeatherData.Bus
      weaBus "Weather data bus" annotation (Placement(transformation(extent={{-172,16},
            {-152,36}}),         iconTransformation(extent={{190,-10},{210,10}})));
  parameter RecordsCollection.ExampleSystemParameters systemParameters(
    TSup_nominal=308.15,
    TSetRoomConst=294.15,
    TOffNight=3,
    nZones=1,
    oneZoneParam=
        MA_Pell_SingleFamilyHouse.Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase.ResidentialBuilding_SingleDwellingNoFloor(
        HeaterOn=false),
    zoneParam=fill(systemParameters.oneZoneParam, systemParameters.nZones),
    filNamIntGains=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/InternalGains_ResidentialBuildingTabulaMulti.txt"),
    DHWtapping=MA_Pell_SingleFamilyHouse.Components.DHW.DHWProfile.M,
    oneZoneParamUFH=
        MA_Pell_SingleFamilyHouse.Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase.ResidentialBuildingWFloor_SingleDwellingWithFloor(),
    DHWProfile=MA_Pell_SingleFamilyHouse.RecordsCollection.DHW.ProfileM())
    "Parameters relevant for the whole energy system" annotation (
      choicesAllMatching=true, Placement(transformation(extent={{-46,-96},{6,-36}})));

equation
  connect(vent.y, thermalZone.ventRate) annotation (Line(points={{-71.1,-7},{-60,
          -7},{-60,-7.9},{-38.12,-7.9}}, color={0,0,127}));
  connect(constTSetRoom.y, thermalZone.TSetCool) annotation (Line(points={{-75.4,
          24},{-56,24},{-56,29},{-38.12,29}}, color={0,0,127}));
  connect(constTSetRoom.y, thermalZone.TSetHeat) annotation (Line(points={{-75.4,
          24},{-66,24},{-66,22},{-58,22},{-58,16.4},{-38.12,16.4}}, color={0,0,127}));
  connect(tableInternalGains.y,gainIntGains. u) annotation (Line(points={{-163.3,
          55},{-163.3,56},{-143.2,56}},       color={0,0,127}));
  connect(gainIntGains.y, thermalZone.intGains) annotation (Line(points={{-129.4,
          56},{-76,56},{-76,64},{78,64},{78,-42},{44.6,-42},{44.6,-26.8}},
        color={0,0,127}));
  connect(weaDat.weaBus,weaBus)  annotation (Line(
      points={{-190,26},{-162,26}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus.TDryBul, thermalZone.ventTemp) annotation (Line(
      points={{-162,26},{-146,26},{-146,24},{-104,24},{-104,3.8},{-38.12,3.8}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));

  connect(weaBus, thermalZone.weaBus) annotation (Line(
      points={{-162,26},{-162,38},{-40,38}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=31536000,
      Interval=900.00288,
      __Dymola_Algorithm="Dassl"));
end Test_TZ;
