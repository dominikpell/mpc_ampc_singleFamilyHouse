within MA_Pell_SingleFamilyHouse.Systems.Examples;
model Example_SFH_FMU_ref
  FMUs.SFH_FMU_UFH_ref sFH_FMU(SOC_Bat_Init=30, n_mod=63)
    annotation (Placement(transformation(extent={{-60,-40},{60,20}})));
  Modelica.Blocks.Sources.RealExpression realExpression[3](y={1.0,0.0,0.0})
    annotation (Placement(transformation(extent={{-194,60},{-174,80}})));
  Modelica.Blocks.Sources.RealExpression realExpression1[3](y={2400,0,0})
    annotation (Placement(transformation(extent={{-194,40},{-174,60}})));

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
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="EVDem",
    final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/ev_dem_quarterly.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-187,-15})));

  Modelica.Blocks.Sources.CombiTimeTable tableElec(
    final tableOnFile=true,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="DomElecDem",
    final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/elec_dom_quarterly.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-187,5})));

  Modelica.Blocks.Math.Gain gain(k=1000)
    annotation (Placement(transformation(extent={{-158,0},{-148,10}})));
  Modelica.Blocks.Math.Gain gain1(k=1000)
    annotation (Placement(transformation(extent={{-158,-20},{-148,-10}})));
  Modelica.Blocks.Math.Gain gainIntGains[3](each k=1)
    "Profiles for internal gains" annotation (Placement(transformation(
        extent={{6,6},{-6,-6}},
        rotation=180,
        origin={-152,-38})));
  Modelica.Blocks.Sources.CombiTimeTable tableDHW(
    final tableOnFile=false,
    final table=sFH_FMU.DHWProfile.table,
    final columns=2:5,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic)
    "Read the input data from the given file. " annotation (Placement(visible=
         true, transformation(
        extent={{-7,-7},{7,7}},
        rotation=0,
        origin={-187,-63})));
  Modelica.Blocks.Math.UnitConversions.From_degC
                                         tableInternalGains2
    "Profiles for internal gains"
    annotation (Placement(transformation(extent={{6,6},{-6,-6}},
        rotation=180,
        origin={-152,-62})));
  Modelica.Blocks.Sources.CombiTimeTable tableInternalGains(
    final tableOnFile=true,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="Internals",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/InternalGains_ResidentialBuildingTabulaMulti.txt"),
    columns=2:4) "Profiles for internal gains"
    annotation (Placement(transformation(extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-187,-39})));

equation
  connect(realExpression[1].y, sFH_FMU.PV_Distr_Use) annotation (Line(points={{-173,70},
          {-98,70},{-98,20},{-80,20},{-80,19.4545},{-60,19.4545}},     color={0,
          0,127}));
  connect(realExpression[3].y, sFH_FMU.PV_Distr_ChBat) annotation (Line(points={{-173,70},
          {-98,70},{-98,15.3636},{-60,15.3636}},              color={0,0,127}));
  connect(realExpression[2].y, sFH_FMU.PV_Distr_FeedIn) annotation (Line(points={{-173,70},
          {-98,70},{-98,16},{-60,16},{-60,17.5455}},color={0,0,127}));
  connect(realExpression1[1].y, sFH_FMU.BAT_Pow_Use) annotation (Line(points={{-173,50},
          {-106,50},{-106,12.9091},{-60,12.9091}},   color={0,0,127}));
  connect(realExpression1[2].y, sFH_FMU.BAT_Pow_FeedIn) annotation (Line(points={{-173,50},
          {-106,50},{-106,10},{-60,10},{-60,10.4545}},    color={0,0,127}));
  connect(realExpression1[3].y, sFH_FMU.BAT_Pow_Ch) annotation (Line(points={{-173,50},
          {-106,50},{-106,6},{-60,6},{-60,8.27273}},     color={0,0,127}));
  connect(weaDat.weaBus, weaBus) annotation (Line(
      points={{-180,28},{-152,28}},
      color={255,204,51},
      thickness=0.5));
  connect(tableElec.y[1], gain.u)
    annotation (Line(points={{-179.3,5},{-159,5}},     color={0,0,127}));
  connect(tableEV.y[1], gain1.u) annotation (Line(points={{-179.3,-15},{-159,
          -15}},      color={0,0,127}));
  connect(tableDHW.y[4],tableInternalGains2. u) annotation (Line(points={{-179.3,
          -63},{-172,-63},{-172,-62},{-159.2,-62}},      color={0,0,127}));
  connect(tableInternalGains.y,gainIntGains. u) annotation (Line(points={{-179.3,
          -39},{-179.3,-38},{-159.2,-38}},    color={0,0,127}));
  connect(weaBus.TDryBul, sFH_FMU.ts_T_air) annotation (Line(
      points={{-152,28},{-114,28},{-114,6.36364},{-60,6.36364}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus.HGloHor, sFH_FMU.ts_sol_rad) annotation (Line(
      points={{-152,28},{-144,28},{-144,22},{-114,22},{-114,2},{-60,2}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus.winSpe, sFH_FMU.ts_win_spe) annotation (Line(
      points={{-152,28},{-114,28},{-114,4.18182},{-60,4.18182}},
      color={255,204,51},
      thickness=0.5));
  connect(gain.y, sFH_FMU.dem_elec) annotation (Line(points={{-147.5,5},{-140,5},
          {-140,-1.27273},{-60,-1.27273}}, color={0,0,127}));
  connect(gain1.y, sFH_FMU.dem_e_mob) annotation (Line(points={{-147.5,-15},{
          -128,-15},{-128,-3.18182},{-60,-3.18182}}, color={0,0,127}));
  connect(gainIntGains[1].y, sFH_FMU.ts_gains_human) annotation (Line(points={{-145.4,
          -38},{-124,-38},{-124,-10.2727},{-60,-10.2727}},        color={0,0,
          127}));
  connect(gainIntGains[2].y, sFH_FMU.ts_gains_dev) annotation (Line(points={{-145.4,
          -38},{-122,-38},{-122,-12.4545},{-60,-12.4545}},        color={0,0,
          127}));
  connect(gainIntGains[3].y, sFH_FMU.ts_gains_light) annotation (Line(points={{-145.4,
          -38},{-120,-38},{-120,-14.6364},{-59.75,-14.6364}},        color={0,0,
          127}));
  connect(tableDHW.y[2], sFH_FMU.mFlow_DHW) annotation (Line(points={{-179.3,
          -63},{-168,-63},{-168,-48},{-118,-48},{-118,-5.36364},{-60,-5.36364}},
        color={0,0,127}));
  connect(tableInternalGains2.y, sFH_FMU.TDem_DHW) annotation (Line(points={{
          -145.4,-62},{-116,-62},{-116,-8.36364},{-60,-8.36364}}, color={0,0,
          127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,
            -100},{200,100}})),                                  Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-200,-100},{200,
            100}})),
    experiment(
      StopTime=31536000,
      Interval=900.00288,
      Tolerance=1e-05,
      __Dymola_Algorithm="Dassl"));
end Example_SFH_FMU_ref;
