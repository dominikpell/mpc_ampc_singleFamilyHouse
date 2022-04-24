within MA_Pell_SingleFamilyHouse.Systems.Examples;
model Example_SFH_FMU_ref_Laura
  FMUs.SFH_FMU_UFH_ref_Laura sFH_FMU(n_mod=63,
    tariff=3,                                  price_el=0.346/1000)
    annotation (Placement(transformation(extent={{-58,-66},{116,60}})));

  AixLib.BoundaryConditions.WeatherData.ReaderTMY3 weaDat1(filNam=
        Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Somm_City_Berlin.mos"))
    "Weather data reader"
    annotation (Placement(transformation(extent={{-198,22},{-184,38}})));

  AixLib.BoundaryConditions.WeatherData.Bus
      weaBus1
             "Weather data bus" annotation (Placement(transformation(extent={{-166,20},
            {-146,40}}),         iconTransformation(extent={{190,-10},{210,10}})));
  Modelica.Blocks.Sources.CombiTimeTable table_ts_T_inside_max(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="ts_T_inside_max",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/ts_T_inside_max_long.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-191,-133})));

  Modelica.Blocks.Sources.CombiTimeTable table_ts_T_inside_min(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="ts_T_inside_min",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/ts_T_inside_min_long.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-191,-153})));

  Modelica.Blocks.Sources.CombiTimeTable tableEV(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="dem_e_mob",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/dem_e_mob_long.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-219,-21})));

  Modelica.Blocks.Sources.CombiTimeTable tableElec(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="dem_elec",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/dem_elec_long.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-219,-1})));

  Modelica.Blocks.Math.Gain gainIntGains[3](each k=1)
    "Profiles for internal gains" annotation (Placement(transformation(
        extent={{6,6},{-6,-6}},
        rotation=180,
        origin={-184,-44})));
  Modelica.Blocks.Sources.CombiTimeTable tableInternalGains(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="Internals",
    final fileName=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/InternalGains_ResidentialBuildingTabulaMulti.txt"),
    columns=2:4) "Profiles for internal gains"
    annotation (Placement(transformation(extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-219,-45})));

  Modelica.Blocks.Sources.CombiTimeTable table_dem_dhw_T(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="dem_dhw_T",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/dem_dhw_T_long.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-219,-83})));

  Modelica.Blocks.Sources.CombiTimeTable table_dem_dhw_m_flow(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="dem_dhw_m_flow",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/dem_dhw_m_flow_long.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-219,-63})));

equation
  connect(weaDat1.weaBus, weaBus1) annotation (Line(
      points={{-184,30},{-156,30}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus1.TDryBul, sFH_FMU.ts_T_air) annotation (Line(
      points={{-156,30},{-114,30},{-114,33.6545},{-58,33.6545}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus1.HGloHor, sFH_FMU.ts_sol_rad) annotation (Line(
      points={{-156,30},{-114,30},{-114,22.2},{-58,22.2}},
      color={255,204,51},
      thickness=0.5));
  connect(weaBus1.winSpe, sFH_FMU.ts_win_spe) annotation (Line(
      points={{-156,30},{-114,30},{-114,27.9273},{-58,27.9273}},
      color={255,204,51},
      thickness=0.5));
  connect(table_ts_T_inside_max.y[1], sFH_FMU.ts_T_inside_max) annotation (Line(
        points={{-183.3,-133},{-124,-133},{-124,-134},{-64,-134},{-64,-28},{
          -58.3625,-28},{-58.3625,-28.2}},                          color={0,0,127}));
  connect(table_ts_T_inside_min.y[1], sFH_FMU.ts_T_inside_min) annotation (Line(
        points={{-183.3,-153},{-58.3625,-153},{-58.3625,-35.6455}}, color={0,0,127}));
  connect(tableInternalGains.y,gainIntGains. u) annotation (Line(points={{-211.3,
          -45},{-211.3,-44},{-191.2,-44}},    color={0,0,127}));
  connect(gainIntGains[1].y, sFH_FMU.ts_gains_human) annotation (Line(
        points={{-177.4,-44},{-128,-44},{-128,-5.29091},{-58,-5.29091}},
                                                                   color={0,0,
          127}));
  connect(gainIntGains[2].y, sFH_FMU.ts_gains_dev) annotation (Line(
        points={{-177.4,-44},{-170,-44},{-170,-46},{-132,-46},{-132,-10.4455},{
          -58,-10.4455}},   color={0,0,127}));
  connect(gainIntGains[3].y, sFH_FMU.ts_gains_light) annotation (Line(
        points={{-177.4,-44},{-134,-44},{-134,-18.4636},{-58,-18.4636}},
        color={0,0,127}));
  connect(tableElec.y[1], sFH_FMU.dem_elec) annotation (Line(points={{-211.3,-1},
          {-162,-1},{-162,15.3273},{-58,15.3273}},   color={0,0,127}));
  connect(tableEV.y[1], sFH_FMU.dem_e_mob) annotation (Line(points={{-211.3,-21},
          {-152,-21},{-152,11.3182},{-58,11.3182}},      color={0,0,127}));
  connect(table_dem_dhw_m_flow.y[1], sFH_FMU.mFlow_DHW) annotation (Line(points=
         {{-211.3,-63},{-92,-63},{-92,6.73636},{-58,6.73636}}, color={0,0,127}));
  connect(table_dem_dhw_T.y[1], sFH_FMU.TDem_DHW) annotation (Line(points={{
          -211.3,-83},{-76,-83},{-76,0},{-58,0},{-58,1.00909}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,
            -100},{200,100}})),                                  Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-200,-100},{200,
            100}})),
    experiment(
      StopTime=604800,
      Interval=900,
      Tolerance=1e-05,
      __Dymola_Algorithm="Dassl"));
end Example_SFH_FMU_ref_Laura;
