within MA_Pell_SingleFamilyHouse.Systems.Examples;
model TEST_SFH_FMU_UFH "Example model to simulate SFH with UFH"
  MA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box
                   mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box(
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
    price_el=0.346/1000,
    Q_HP_max=7000,
    fmi_InputTime=false,
    fmi_UsePreOnInputSignals=true,
    fmi_StartTime=0,
    fmi_CommunicationStepSize=900)
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

  Modelica.Blocks.Sources.CombiTimeTable table_ts_gains_human(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="ts_gains_human",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/ts_gains_human.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-233,-31})));

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
  Modelica.Blocks.Sources.CombiTimeTable table_ts_gains_dev(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="ts_gains_dev",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/ts_gains_dev.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-201,-35})));
  Modelica.Blocks.Sources.CombiTimeTable table_ts_gains_light(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="ts_gains_light",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/ts_gains_light.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-173,-41})));
equation
  connect(weaDat.weaBus, weaBus) annotation (Line(
      points={{-180,28},{-152,28}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus.TDryBul,
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.ts_T_air)
    annotation (Line(
      points={{-152,28},{-110,28},{-110,-17},{-36,-17}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus.HGloHor,
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.ts_sol_rad)
    annotation (Line(
      points={{-152,28},{-110,28},{-110,-17},{-36,-17}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus.winSpe,
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.ts_win_spe)
    annotation (Line(
      points={{-152,28},{-110,28},{-110,-17},{-36,-17}},
      color={255,204,51},
      thickness=0.5));
  connect(mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.PV_Distr_Use,
    table_PV_Distr_Use.y[1]) annotation (Line(points={{-36,-17},{-172,-17},{
          -172,89},{-181.3,89}}, color={0,0,127}));
  connect(table_PV_Distr_FeedIn.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.PV_Distr_FeedIn)
    annotation (Line(points={{-181.3,69},{-176,69},{-176,-17},{-36,-17}}, color=
         {0,0,127}));
  connect(table_PV_Distr_ChBat.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.PV_Distr_ChBat)
    annotation (Line(points={{-181.3,51},{-116,51},{-116,-17},{-36,-17}}, color=
         {0,0,127}));
  connect(table_pow_use_BAT.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.power_use_BAT)
    annotation (Line(points={{-125.3,79},{-88,79},{-88,-17},{-36,-17}}, color={
          0,0,127}));
  connect(table_pow_feedIn_BAT.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.power_to_grid_BAT)
    annotation (Line(points={{-105.3,89},{-80,89},{-80,-17},{-36,-17}}, color={
          0,0,127}));
  connect(table_pow_ch_BAT.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.ch_BAT)
    annotation (Line(points={{-85.3,95},{-74,95},{-74,-17},{-36,-17}}, color={0,
          0,127}));
  connect(table_T_supply_HP_heat.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.T_supply_HP_heat)
    annotation (Line(points={{-87.3,-95},{-68,-95},{-68,-56},{-60,-56},{-60,-17},
          {-36,-17}}, color={0,0,127}));
  connect(table_T_supply_cool.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.T_supply_cool)
    annotation (Line(points={{-125.3,-119},{-120,-119},{-120,-62},{-86,-62},{
          -86,-34},{-66,-34},{-66,-17},{-36,-17}}, color={0,0,127}));
  connect(table_heat_rod.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.heat_rod)
    annotation (Line(points={{-85.3,-115},{-66,-115},{-66,-64},{-58,-64},{-58,
          -17},{-36,-17}}, color={0,0,127}));
  connect(table_ch_DHW.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.ch_DHW)
    annotation (Line(points={{-83.3,-155},{-58,-155},{-58,-70},{-36,-70},{-36,
          -17}}, color={0,0,127}));
  connect(table_ch_TES.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.ch_TES)
    annotation (Line(points={{-87.3,-135},{-78,-135},{-78,-134},{-62,-134},{-62,
          -17},{-36,-17}}, color={0,0,127}));
  connect(table_x_HP_on.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.x_HP_on)
    annotation (Line(points={{-83.3,-177},{-72,-177},{-72,-176},{-60,-176},{-60,
          -74},{-36,-74},{-36,-17}}, color={0,0,127}));
  connect(table_x_HP_heat.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.x_HP_heat)
    annotation (Line(points={{-123.3,-143},{-120,-143},{-120,-144},{-116,-144},
          {-116,-68},{-76,-68},{-76,-17},{-36,-17}}, color={0,0,127}));
  connect(table_x_HP_cool.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.x_HP_cool)
    annotation (Line(points={{-121.3,-167},{-118,-167},{-118,-168},{-112,-168},
          {-112,-72},{-70,-72},{-70,-50},{-60,-50},{-60,-17},{-36,-17}}, color=
          {0,0,127}));
  connect(table_T_supply_UFH.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.T_supply_UFH)
    annotation (Line(points={{-121.3,-189},{-110,-189},{-110,-78},{-68,-78},{
          -68,-17},{-36,-17}}, color={0,0,127}));
  connect(tableElec.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.dem_elec)
    annotation (Line(points={{-179.3,5},{-130,5},{-130,-17},{-36,-17}}, color={
          0,0,127}));
  connect(tableEV.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.dem_e_mob)
    annotation (Line(points={{-179.3,-15},{-120,-15},{-120,-17},{-36,-17}},
        color={0,0,127}));
  connect(table_dch_TES.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.dch_TES)
    annotation (Line(points={{-177.3,-125},{-168,-125},{-168,-102},{-162,-102},
          {-162,-80},{-36,-80},{-36,-17}}, color={0,0,127}));
  connect(table_t_TES.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.t_TES)
    annotation (Line(points={{-179.3,-145},{-168,-145},{-168,-146},{-158,-146},
          {-158,-17},{-36,-17}}, color={0,0,127}));
  connect(table_t_DHW.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.t_DHW)
    annotation (Line(points={{-179.3,-167},{-166,-167},{-166,-168},{-154,-168},
          {-154,-17},{-36,-17}}, color={0,0,127}));
  connect(table_ts_T_inside_max.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.ts_T_inside_max)
    annotation (Line(points={{-85.3,-199},{-50,-199},{-50,-17},{-36,-17}},
        color={0,0,127}));
  connect(table_ts_T_inside_min.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.ts_T_inside_min)
    annotation (Line(points={{-85.3,-219},{-48,-219},{-48,-17},{-36,-17}},
        color={0,0,127}));
  connect(table_dem_dhw_T.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.dem_dhw_T)
    annotation (Line(points={{-179.3,-77},{-112,-77},{-112,-17},{-36,-17}},
        color={0,0,127}));
  connect(table_dem_dhw_m_flow.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.dem_dhw_m_flow)
    annotation (Line(points={{-179.3,-57},{-98,-57},{-98,-17},{-36,-17}}, color=
         {0,0,127}));
  connect(table_ts_gains_human.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.ts_gains_human)
    annotation (Line(points={{-225.3,-31},{-92,-31},{-92,-17},{-36,-17}}, color
        ={0,0,127}));
  connect(table_ts_gains_dev.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.ts_gains_dev)
    annotation (Line(points={{-193.3,-35},{-138,-35},{-138,-17},{-36,-17}},
        color={0,0,127}));
  connect(table_ts_gains_light.y[1],
    mA_0Pell_0SingleFamilyHouse_FMUs_SFH_0FMU_0UFH_fmu_black_box.ts_gains_light)
    annotation (Line(points={{-165.3,-41},{-136,-41},{-136,-17},{-36,-17}},
        color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,
            -100},{200,100}})),                                  Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-200,-100},{200,
            100}})),
    experiment(
      StopTime=604800,
      Interval=900.00288,
      Tolerance=1e-05,
      __Dymola_Algorithm="Cvode"));
end TEST_SFH_FMU_UFH;
