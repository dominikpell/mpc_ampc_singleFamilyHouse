within MA_Pell_SingleFamilyHouse.Systems.Examples;
model Example_SFH_FMU_UFH_noTES "Example model to simulate SFH with UFH"
FMUs.SFH_FMU_UFH_noTES
                 sFH_FMU_UFH_noTES(
  T_supply_Init=303.15,
  T_supply_HP_Init=303.15,
  T_return_Init=303.15,
  T_supply_UFH_Init=303.15,
  T_return_UFH_Init=303.15,
  T_thermalCapacity_down_Init=291.15,
  t_DHW_Init=323.15,
  n_mod=63,
  TSetDHW=333.15,
  tariff=1,
  Q_HP_max=7000)
  annotation (Placement(transformation(extent={{-36,-100},{166,66}})));

AixLib.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
      Modelica.Utilities.Files.loadResource(
      "modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Somm_City_Berlin.mos"))
  "Weather data reader"
  annotation (Placement(transformation(extent={{-194,20},{-180,36}})));
AixLib.BoundaryConditions.WeatherData.Bus
    weaBus "Weather data bus" annotation (Placement(transformation(extent={{-162,18},
          {-142,38}}),         iconTransformation(extent={{190,-10},{210,10}})));
Modelica.Blocks.Sources.CombiTimeTable tableEV(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="dem_e_mob",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/dem_e_mob.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-187,-15})));

Modelica.Blocks.Sources.CombiTimeTable tableElec(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="dem_elec",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/dem_elec.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-187,5})));

Modelica.Blocks.Sources.CombiTimeTable table_PV_Distr_Use(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="PV_Distr_Use",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/PV_Distr_Use.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-189,89})));

Modelica.Blocks.Sources.CombiTimeTable table_PV_Distr_FeedIn(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="PV_Distr_FeedIn",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/PV_Distr_FeedIn.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-189,69})));

Modelica.Blocks.Sources.CombiTimeTable table_PV_Distr_ChBat(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="PV_Distr_ChBat",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/PV_Distr_ChBat.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-189,51})));

Modelica.Blocks.Sources.CombiTimeTable table_pow_use_BAT(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="power_use_BAT",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/power_use_BAT.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-133,79})));

Modelica.Blocks.Sources.CombiTimeTable table_pow_feedIn_BAT(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="power_to_grid_BAT",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/power_to_grid_BAT.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-113,89})));

Modelica.Blocks.Sources.CombiTimeTable table_pow_ch_BAT(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="ch_BAT",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/ch_BAT.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-93,95})));

Modelica.Blocks.Sources.CombiTimeTable table_T_supply_HP_heat(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="T_supply_HP_heat",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/T_supply_HP_heat.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-95,-95})));

Modelica.Blocks.Sources.CombiTimeTable table_T_supply_cool(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="T_supply_cool",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/T_supply_cool.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-133,-119})));

Modelica.Blocks.Sources.CombiTimeTable table_heat_rod(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="heat_rod",
  final fileName=Modelica.Utilities.Files.loadResource(
      "modelica://MA_Pell_SingleFamilyHouse/Data/heat_rod.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-93,-115})));

Modelica.Blocks.Sources.CombiTimeTable table_ch_DHW(
  final tableOnFile=true,
  smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="ch_DHW",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/ch_DHW.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-91,-155})));

Modelica.Blocks.Sources.CombiTimeTable table_ch_TES(
  final tableOnFile=true,
  smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="ch_TES",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/ch_TES.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-95,-135})));

Modelica.Blocks.Sources.CombiTimeTable table_x_HP_on(
  final tableOnFile=true,
  smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="x_HP_on",
  final fileName=Modelica.Utilities.Files.loadResource(
      "modelica://MA_Pell_SingleFamilyHouse/Data/x_HP_on.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-91,-177})));

Modelica.Blocks.Sources.CombiTimeTable table_x_HP_heat(
  final tableOnFile=true,
  smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="x_HP_heat",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/x_HP_heat.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-131,-143})));

Modelica.Blocks.Sources.CombiTimeTable table_x_HP_cool(
  final tableOnFile=true,
  smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="x_HP_cool",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/x_HP_cool.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-129,-167})));

Modelica.Blocks.Sources.CombiTimeTable table_T_supply_UFH(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="T_supply_UFH",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/T_supply_UFH.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-129,-189})));

Modelica.Blocks.Sources.CombiTimeTable table_T_return_heat(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="T_return_heat",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/T_return_heat.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-135,-93})));

Modelica.Blocks.Sources.CombiTimeTable table_T_return_UFH(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="T_return_UFH",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/T_return_UFH.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-187,-97})));

Modelica.Blocks.Sources.CombiTimeTable table_dch_TES(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="dch_TES",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/dch_TES.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-185,-125})));

Modelica.Blocks.Sources.CombiTimeTable table_t_TES(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="t_TES",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/t_TES.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-187,-145})));

Modelica.Blocks.Sources.CombiTimeTable table_t_DHW(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="t_DHW",
  final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/t_DHW.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-187,-167})));

Modelica.Blocks.Sources.CombiTimeTable table_ts_T_inside_max(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="ts_T_inside_max",
  final fileName=Modelica.Utilities.Files.loadResource(
      "modelica://MA_Pell_SingleFamilyHouse/Data/ts_T_inside_max.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-93,-199})));

Modelica.Blocks.Sources.CombiTimeTable table_ts_T_inside_min(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="ts_T_inside_min",
  final fileName=Modelica.Utilities.Files.loadResource(
      "modelica://MA_Pell_SingleFamilyHouse/Data/ts_T_inside_min.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-93,-219})));
Modelica.Blocks.Sources.CombiTimeTable table_T_supply_heat(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="T_supply_heat",
  final fileName=Modelica.Utilities.Files.loadResource(
      "modelica://MA_Pell_SingleFamilyHouse/Data/T_supply_heat.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-93,-239})));
Modelica.Blocks.Sources.CombiTimeTable table_dem_dhw_T(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="dem_dhw_T",
  final fileName=Modelica.Utilities.Files.loadResource(
      "modelica://MA_Pell_SingleFamilyHouse/Data/dem_dhw_T.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-187,-77})));
Modelica.Blocks.Sources.CombiTimeTable table_dem_dhw_m_flow(
  final tableOnFile=true,
  final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
  final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
  final tableName="dem_dhw_m_flow",
  final fileName=Modelica.Utilities.Files.loadResource(
      "modelica://MA_Pell_SingleFamilyHouse/Data/dem_dhw_m_flow.txt"),
  columns=2:2) "Profiles for internal gains" annotation (Placement(
      transformation(
      extent={{7,7},{-7,-7}},
      rotation=180,
      origin={-187,-57})));
  Modelica.Blocks.Sources.CombiTimeTable table_ts_gains_human(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="ts_gains_human",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/ts_gains_human.txt"),
    columns=2:4) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-221,-29})));
  Modelica.Blocks.Sources.CombiTimeTable table_ts_gains_dev(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="ts_gains_dev",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/ts_gains_dev.txt"),
    columns=2:4) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-189,-33})));
  Modelica.Blocks.Sources.CombiTimeTable table_ts_gains_light(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName=ts_gains_light,
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/ts_gains_light.txt"),
    columns=2:4) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-161,-39})));
equation
connect(weaDat.weaBus, weaBus) annotation (Line(
    points={{-180,28},{-152,28}},
    color={255,204,51},
    thickness=0.5));
  connect(weaBus.TDryBul, sFH_FMU_UFH_noTES.ts_T_air) annotation (Line(
      points={{-152,28},{-110,28},{-110,37.3793},{-36,37.3793}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus.HGloHor, sFH_FMU_UFH_noTES.ts_sol_rad) annotation (Line(
      points={{-152,28},{-110,28},{-110,28.2207},{-36,28.2207}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus.winSpe, sFH_FMU_UFH_noTES.ts_win_spe) annotation (Line(
      points={{-152,28},{-110,28},{-110,32.8},{-36,32.8}},
      color={255,204,51},
      thickness=0.5));
  connect(sFH_FMU_UFH_noTES.PV_Distr_Use, table_PV_Distr_Use.y[1]) annotation (
      Line(points={{-36,64.8552},{-172,64.8552},{-172,89},{-181.3,89}}, color={
          0,0,127}));
  connect(table_PV_Distr_FeedIn.y[1], sFH_FMU_UFH_noTES.PV_Distr_FeedIn)
    annotation (Line(points={{-181.3,69},{-176,69},{-176,60.8483},{-36,60.8483}},
        color={0,0,127}));
  connect(table_PV_Distr_ChBat.y[1], sFH_FMU_UFH_noTES.PV_Distr_ChBat)
    annotation (Line(points={{-181.3,51},{-116,51},{-116,56.269},{-36,56.269}},
        color={0,0,127}));
  connect(table_pow_use_BAT.y[1], sFH_FMU_UFH_noTES.power_use_BAT) annotation (
      Line(points={{-125.3,79},{-88,79},{-88,51.1172},{-36,51.1172}}, color={0,
          0,127}));
  connect(table_pow_feedIn_BAT.y[1], sFH_FMU_UFH_noTES.power_to_grid_BAT)
    annotation (Line(points={{-105.3,89},{-80,89},{-80,45.9655},{-36,45.9655}},
        color={0,0,127}));
  connect(table_pow_ch_BAT.y[1], sFH_FMU_UFH_noTES.ch_BAT) annotation (Line(
        points={{-85.3,95},{-74,95},{-74,41.3862},{-36,41.3862}}, color={0,0,
          127}));
  connect(table_T_supply_HP_heat.y[1], sFH_FMU_UFH_noTES.T_supply_HP_heat)
    annotation (Line(points={{-87.3,-95},{-68,-95},{-68,-56},{-60,-56},{-60,
          -49.6276},{-36,-49.6276}}, color={0,0,127}));
  connect(table_T_supply_cool.y[1], sFH_FMU_UFH_noTES.T_supply_cool)
    annotation (Line(points={{-125.3,-119},{-120,-119},{-120,-62},{-86,-62},{
          -86,-34},{-66,-34},{-66,-22.1517},{-36,-22.1517}}, color={0,0,127}));
  connect(table_heat_rod.y[1], sFH_FMU_UFH_noTES.heat_rod) annotation (Line(
        points={{-85.3,-115},{-66,-115},{-66,-64},{-58,-64},{-58,-55.3517},{-36,
          -55.3517}}, color={0,0,127}));
  connect(table_ch_DHW.y[1], sFH_FMU_UFH_noTES.ch_DHW) annotation (Line(points={{-83.3,
          -155},{-58,-155},{-58,-70},{-36,-70},{-36,-70.2345}},         color={
          0,0,127}));
  connect(table_ch_TES.y[1], sFH_FMU_UFH_noTES.ch_TES) annotation (Line(points=
          {{-87.3,-135},{-78,-135},{-78,-134},{-62,-134},{-62,-66.8},{-36,-66.8}},
        color={0,0,127}));
  connect(table_x_HP_on.y[1], sFH_FMU_UFH_noTES.x_HP_on) annotation (Line(
        points={{-83.3,-177},{-72,-177},{-72,-176},{-60,-176},{-60,-74},{-36,
          -74},{-36,-73.0966}}, color={0,0,127}));
  connect(table_x_HP_heat.y[1], sFH_FMU_UFH_noTES.x_HP_heat) annotation (Line(
        points={{-123.3,-143},{-120,-143},{-120,-144},{-116,-144},{-116,-68},{-76,
          -68},{-76,-29.5931},{-36,-29.5931}}, color={0,0,127}));
  connect(table_x_HP_cool.y[1], sFH_FMU_UFH_noTES.x_HP_cool) annotation (Line(
        points={{-121.3,-167},{-118,-167},{-118,-168},{-112,-168},{-112,-72},{
          -70,-72},{-70,-50},{-60,-50},{-60,-37.0345},{-36,-37.0345}}, color={0,
          0,127}));
  connect(table_T_supply_UFH.y[1], sFH_FMU_UFH_noTES.T_supply_UFH) annotation (
      Line(points={{-121.3,-189},{-110,-189},{-110,-78},{-68,-78},{-68,-43.9034},
          {-36,-43.9034}}, color={0,0,127}));
  connect(tableElec.y[1], sFH_FMU_UFH_noTES.dem_elec) annotation (Line(points={{-179.3,
          5},{-130,5},{-130,21.3517},{-36,21.3517}},         color={0,0,127}));
  connect(tableEV.y[1], sFH_FMU_UFH_noTES.dem_e_mob) annotation (Line(points={{-179.3,
          -15},{-120,-15},{-120,17.3448},{-36,17.3448}},        color={0,0,127}));
  connect(table_dch_TES.y[1], sFH_FMU_UFH_noTES.dch_TES) annotation (Line(
        points={{-177.3,-125},{-168,-125},{-168,-102},{-162,-102},{-162,-80},{-36,
          -80},{-36,-79.3931}}, color={0,0,127}));
  connect(table_t_TES.y[1], sFH_FMU_UFH_noTES.t_TES) annotation (Line(points={{-179.3,
          -145},{-168,-145},{-168,-146},{-158,-146},{-158,-88.5517},{-36,
          -88.5517}}, color={0,0,127}));
  connect(table_t_DHW.y[1], sFH_FMU_UFH_noTES.t_DHW) annotation (Line(points={{
          -179.3,-167},{-166,-167},{-166,-168},{-154,-168},{-154,-83.4},{-36,-83.4}},
        color={0,0,127}));
  connect(table_ts_T_inside_max.y[1], sFH_FMU_UFH_noTES.ts_T_inside_max)
    annotation (Line(points={{-85.3,-199},{-50,-199},{-50,-95.9931},{-35.5792,
          -95.9931}}, color={0,0,127}));
  connect(table_ts_T_inside_min.y[1], sFH_FMU_UFH_noTES.ts_T_inside_min)
    annotation (Line(points={{-85.3,-219},{-48,-219},{-48,-107.441},{-35.5792,
          -107.441}}, color={0,0,127}));
  connect(table_dem_dhw_T.y[1], sFH_FMU_UFH_noTES.dem_dhw_T) annotation (Line(
        points={{-179.3,-77},{-112,-77},{-112,7.61379},{-36,7.61379}}, color={0,
          0,127}));
  connect(table_dem_dhw_m_flow.y[1], sFH_FMU_UFH_noTES.dem_dhw_m_flow)
    annotation (Line(points={{-179.3,-57},{-98,-57},{-98,12.7655},{-36,12.7655}},
        color={0,0,127}));
  connect(table_ts_gains_light.y[1], sFH_FMU_UFH_noTES.ts_gains_light)
    annotation (Line(points={{-153.3,-39},{-153.3,-10},{-38,-10}}, color={0,0,
          127}));
  connect(table_ts_gains_dev.y[1], sFH_FMU_UFH_noTES.ts_gains_dev) annotation (
      Line(points={{-181.3,-33},{-36,-33},{-36,0}}, color={0,0,127}));
  connect(table_ts_gains_human.y[1], sFH_FMU_UFH_noTES.ts_gains_human)
    annotation (Line(points={{-213.3,-29},{-116,-29},{-116,2},{-38,2}}, color={
          0,0,127}));
annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,
          -100},{200,100}})),                                  Diagram(
      coordinateSystem(preserveAspectRatio=false, extent={{-200,-100},{200,
          100}})),
  experiment(
      StopTime=86400,
      Interval=900.00288,
      Tolerance=1e-05,
      __Dymola_Algorithm="Cvode"));
end Example_SFH_FMU_UFH_noTES;
