within MA_Pell_SingleFamilyHouse.Systems.Examples;
model TestElectricity
Subsystems.Electricity.Electricity_PVandBAT_ref     Electricity(
    timZon=weaDat.timZon,
    SOC_Bat_Init=0.3,
    n_mod=63,
    data=AixLib.DataBase.SolarElectric.ShellSP70(),
    batteryData=ElectricalStorages.Data.LithiumIon.LithiumIonViessmann(),
    nBat=3)
  annotation (Placement(transformation(extent={{64,-90},{144,-10}})));
  Electrical.ElectricalControl.PVBatteryControl.DirectCharge
    directChargeControl(threshold=0.2)                 annotation (Placement(
        transformation(
        extent={{84,-40},{-84,40}},
        rotation=0,
        origin={-44,36})));
  Modelica.Blocks.Math.Add totElecDm
    annotation (Placement(transformation(extent={{-184,80},{-164,100}})));
  AixLib.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/TRY2015_524528132978_Somm_City_Berlin.mos"))
    "Weather data reader"
    annotation (Placement(transformation(extent={{-112,-106},{-98,-90}})));
  Modelica.Blocks.Sources.CombiTimeTable tableEV1(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="dem_e_mob",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/dem_e_mob.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-311,69})));
  Modelica.Blocks.Sources.CombiTimeTable tableElec1(
    final tableOnFile=true,
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
    final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    final tableName="dem_elec",
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Data/dem_elec.txt"),
    columns=2:2) "Profiles for internal gains" annotation (Placement(
        transformation(
        extent={{7,7},{-7,-7}},
        rotation=180,
        origin={-311,89})));
  Modelica.Blocks.Sources.Constant const(k=100)
    annotation (Placement(transformation(extent={{-150,126},{-130,146}})));
  Interfaces.Outputs.ElectricityOutputs outBusElec
    annotation (Placement(transformation(extent={{152,-60},{172,-40}})));
equation
  connect(directChargeControl.PV_Distr_Use,Electricity. PV_Distr_Use)
    annotation (Line(points={{-89.5,-4.8},{-89.5,-50.4},{66.8,-50.4}},
        color={0,0,127}));
  connect(directChargeControl.PV_Distr_FeedIn,Electricity. PV_Distr_FeedIn)
    annotation (Line(points={{-102.1,-4.8},{-102.1,-56},{66.8,-56}},   color={0,
          0,127}));
  connect(directChargeControl.PV_Distr_ChBat,Electricity. PV_Distr_ChBat)
    annotation (Line(points={{-114,-4.8},{-114,-61.6},{66.8,-61.6}},   color={0,
          0,127}));
  connect(directChargeControl.Pow_BAT_ChBat,Electricity. Pow_BAT_ChBat)
    annotation (Line(points={{-46.1,-6.4},{-46.1,-84.8},{66.8,-84.8}},
        color={0,0,127}));
  connect(directChargeControl.Pow_BAT_FeedIn,Electricity. Pow_BAT_FeedIn)
    annotation (Line(points={{-34.2,-6.4},{-34.2,-79.2},{66.8,-79.2}},
        color={0,0,127}));
  connect(directChargeControl.Pow_BAT_Use,Electricity. Pow_BAT_Use) annotation (
     Line(points={{-24.4,-6.4},{-24.4,-73.6},{66.8,-73.6}},     color={0,0,127}));
  connect(directChargeControl.BuiEleLoadAC,totElecDm. y) annotation (Line(
        points={{-44,77.6},{-44,90},{-163,90}},      color={0,0,127}));
  connect(tableElec1.y[1], totElecDm.u1) annotation (Line(points={{-303.3,89},{
          -245.65,89},{-245.65,96},{-186,96}}, color={0,0,127}));
  connect(tableEV1.y[1], totElecDm.u2) annotation (Line(points={{-303.3,69},{
          -244.65,69},{-244.65,84},{-186,84}}, color={0,0,127}));
  connect(const.y, directChargeControl.GenEleLoadAC) annotation (Line(points={{
          -129,136},{-25.1,136},{-25.1,77.6}}, color={0,0,127}));
  connect(weaDat.weaBus, Electricity.weaBus) annotation (Line(
      points={{-98,-98},{42,-98},{42,-23.6},{64,-23.6}},
      color={255,204,51},
      thickness=0.5));
  connect(totElecDm.y, Electricity.P_el_dom) annotation (Line(points={{-163,90},
          {-162,90},{-162,-130},{113.2,-130},{113.2,-87.2}}, color={0,0,127}));
  connect(const.y, Electricity.P_el_Gen) annotation (Line(points={{-129,136},{
          80,136},{80,104},{208,104},{208,-114},{104.4,-114},{104.4,-87.2}},
        color={0,0,127}));
  connect(Electricity.outBusElec, outBusElec) annotation (Line(
      points={{144,-50},{162,-50}},
      color={255,204,51},
      thickness=0.5));
  connect(directChargeControl.SOCBat, outBusElec.SOC_Bat) annotation (Line(
        points={{0.1,77.6},{0.1,86},{162.05,86},{162.05,-49.95}}, color={0,0,
          127}));
  connect(directChargeControl.PVPowerDC, outBusElec.power_PV) annotation (Line(
        points={{-67.8,76.8},{-67.8,108},{226,108},{226,-52},{162.05,-52},{
          162.05,-49.95}}, color={0,0,127}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=86400, __Dymola_Algorithm="Dassl"));
end TestElectricity;
