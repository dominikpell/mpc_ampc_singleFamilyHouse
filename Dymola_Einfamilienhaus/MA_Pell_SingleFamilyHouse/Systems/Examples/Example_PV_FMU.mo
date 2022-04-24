within MA_Pell_SingleFamilyHouse.Systems.Examples;
model Example_PV_FMU

  FMUs.PV_FMU_fmu pV_FMU_fmu(
    n_mod=63,
    IdentifierPV=1,
    _T_air_start=0,
    _winSpe_start=0)
    annotation (Placement(transformation(extent={{64,-12},{84,8}})));
  //MA_Pell_SingleFamilyHouse.Systems.Examples.PV_System_FMU pV_FMU_fmu
  Modelica.Blocks.Sources.Constant const1(k=273.15)
    annotation (Placement(transformation(extent={{-42,26},{-22,46}})));
  AixLib.BoundaryConditions.WeatherData.ReaderTMY3 normal(filNam=
        Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Jahr_City_Berlin.mos"))
    "Weather data reader"
    annotation (Placement(transformation(extent={{-78,-46},{-64,-30}})));
  AixLib.BoundaryConditions.WeatherData.Bus
      weaBus "Weather data bus" annotation (Placement(transformation(extent={{-44,-50},
            {-24,-30}}),         iconTransformation(extent={{190,-10},{210,10}})));
  Modelica.Blocks.Sources.CombiTimeTable T_air(
    final tableOnFile=true,
    tableName="T_air",
    final extrapolation=Modelica.Blocks.Types.Extrapolation.LastTwoPoints,
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/T_air.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-55,55})));
  Modelica.Blocks.Sources.CombiTimeTable winSpe(
    final tableOnFile=true,
    tableName="winSpe",
    final extrapolation=Modelica.Blocks.Types.Extrapolation.LastTwoPoints,
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/winSpe.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-91,-7})));
  Modelica.Blocks.Sources.CombiTimeTable sol_rad(
    final tableOnFile=true,
    tableName="sol_rad",
    final extrapolation=Modelica.Blocks.Types.Extrapolation.LastTwoPoints,
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/sol_rad.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-77,21})));
  AixLib.BoundaryConditions.WeatherData.ReaderTMY3 warm(filNam=
        Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Somm_City_Berlin.mos"))
    "Weather data reader"
    annotation (Placement(transformation(extent={{-82,-68},{-68,-52}})));
  AixLib.BoundaryConditions.WeatherData.Bus
      weaBus1
             "Weather data bus" annotation (Placement(transformation(extent={{-46,-70},
            {-26,-50}}),         iconTransformation(extent={{190,-10},{210,10}})));
  AixLib.BoundaryConditions.WeatherData.ReaderTMY3 cold(filNam=
        Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Wint_City_Berlin.mos"))
    "Weather data reader"
    annotation (Placement(transformation(extent={{-78,-98},{-64,-82}})));
  AixLib.BoundaryConditions.WeatherData.Bus
      weaBus2
             "Weather data bus" annotation (Placement(transformation(extent={{-42,
            -100},{-22,-80}}),   iconTransformation(extent={{190,-10},{210,10}})));
  Modelica.Blocks.Math.Add add
    annotation (Placement(transformation(extent={{0,26},{20,46}})));
equation
  connect(normal.weaBus,weaBus)  annotation (Line(
      points={{-64,-38},{-44,-38},{-44,-40},{-34,-40}},
      color={255,204,51},
      thickness=0.5));
  connect(winSpe.y[1], pV_FMU_fmu.winSpe)
    annotation (Line(points={{-83.3,-7},{63.6,-7}}, color={0,0,127}));
  connect(sol_rad.y[1], pV_FMU_fmu.H_GloHor) annotation (Line(points={{-69.3,21},
          {-36,21},{-36,-2},{63.6,-2}}, color={0,0,127}));
  connect(warm.weaBus, weaBus1) annotation (Line(
      points={{-68,-60},{-36,-60}},
      color={255,204,51},
      thickness=0.5));
  connect(cold.weaBus, weaBus2) annotation (Line(
      points={{-64,-90},{-32,-90}},
      color={255,204,51},
      thickness=0.5));
  connect(T_air.y[1], add.u1) annotation (Line(points={{-47.3,55},{-12,55},{-12,
          42},{-2,42}}, color={0,0,127}));
  connect(const1.y, add.u2) annotation (Line(points={{-21,36},{-16,36},{-16,30},
          {-2,30}}, color={0,0,127}));
  connect(add.y, pV_FMU_fmu.T_air) annotation (Line(points={{21,36},{30,36},{30,
          6},{63.6,6},{63.6,3}}, color={0,0,127}));
  annotation (experiment(
      StopTime=86400,
      Interval=900,
      Tolerance=1e-05,
      __Dymola_Algorithm="Dassl"));
end Example_PV_FMU;
