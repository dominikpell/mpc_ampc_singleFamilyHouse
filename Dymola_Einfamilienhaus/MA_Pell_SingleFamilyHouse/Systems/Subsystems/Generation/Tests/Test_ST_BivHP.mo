within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Generation.Tests;
model Test_ST_BivHP
  extends MA_Pell_SingleFamilyHouse.Systems.BaseClasses.PartialBESExample;

  Interfaces.GenerationControlBus genControlBus
    annotation (Placement(transformation(extent={{-10,54},{30,94}})));
  ST_BivHP                        sT_BivHP(
    systemParameters=systemParameters,        redeclare package Medium_eva =
        AixLib.Media.Air,
    redeclare RecordsCollection.GenerationData.DummyHP heatPumpParameters,
    redeclare RecordsCollection.GenerationData.DummyHR heatingRodParameters,
    redeclare RecordsCollection.GenerationData.DummySolarThermal
      solarThermalParas)
    annotation (Placement(transformation(extent={{-50,-44},{24,28}})));
  Modelica.Blocks.Sources.Constant     const1(k=0)
    annotation (Placement(transformation(extent={{-98,46},{-78,66}})));
  Modelica.Blocks.Sources.Pulse        pulse(period=1800)
    annotation (Placement(transformation(extent={{-62,112},{-42,132}})));
  Modelica.Blocks.Sources.Ramp         ramp(
    height=20,
    duration=3600,
    offset=273.15)
    annotation (Placement(transformation(extent={{-54,42},{-34,62}})));
  Modelica.Blocks.Sources.BooleanConstant
                                       booleanConstant(k=true)
    annotation (Placement(transformation(extent={{-100,78},{-80,98}})));
  Modelica.Blocks.Sources.Constant     const(k=1)
    annotation (Placement(transformation(extent={{-108,116},{-88,136}})));
  AixLib.Fluid.MixingVolumes.MixingVolume
                                   vol(
    redeclare package Medium = AixLib.Media.Water,
    m_flow_nominal=sT_BivHP.solarThermalParas.m_flow_nominal,
    V=1,                               nPorts=2) annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={64,-32})));
  Modelica.Blocks.Sources.Constant     const2(k=278.15)
    annotation (Placement(transformation(extent={{-144,64},{-124,84}})));
  Modelica.Blocks.Sources.Constant     const3(k=500)
    annotation (Placement(transformation(extent={{-144,36},{-124,56}})));
  AixLib.Fluid.MixingVolumes.MixingVolume
                                   vol1(
    redeclare package Medium = AixLib.Media.Water,
    m_flow_nominal=sT_BivHP.solarThermalParas.m_flow_nominal,
    V=1,
    nPorts=2)                                    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={62,6})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T(
        displayUnit="K") = 303.15)
               annotation (Placement(transformation(extent={{98,-8},{118,12}})));
equation
  connect(sT_BivHP.sigBusGen, genControlBus) annotation (Line(
      points={{-12.26,27.28},{-12.26,49.64},{10,49.64},{10,74}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(const1.y, genControlBus.hr_on) annotation (Line(points={{-77,56},{-68,
          56},{-68,76},{10,76},{10,74}}, color={255,0,255}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(pulse.y, genControlBus.hp_bus.nSet) annotation (Line(points={{-41,122},
          {10,122},{10,74}},                 color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(ramp.y, genControlBus.hp_bus.TOdaMea) annotation (Line(points={{-33,52},
          {-26,52},{-26,64},{10,64},{10,74}},                color={0,0,
          127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(booleanConstant.y, genControlBus.hp_bus.modeSet) annotation (
      Line(points={{-79,88},{10,88},{10,74}},       color={255,0,255}),
      Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(genControlBus.hp_bus.iceFacMea, const.y) annotation (Line(
      points={{10,74},{-38,74},{-38,126},{-87,126}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(vol.ports[1], sT_BivHP.portGen_out[2]) annotation (Line(points={{66,-22},
          {38,-22},{38,20.8},{24,20.8}}, color={0,127,255}));
  connect(vol.ports[2], sT_BivHP.portGen_in[2]) annotation (Line(points={{62,-22},
          {46,-22},{46,-36},{34,-36},{34,6.4},{24,6.4}},      color={0,127,255}));
  connect(const2.y, genControlBus.weaBus.TDryBul) annotation (Line(points={{
          -123,74},{-54,74},{-54,74},{10,74}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(const3.y, genControlBus.weaBus.HGloHor) annotation (Line(points={{
          -123,46},{-54,46},{-54,74},{10,74}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(sT_BivHP.portGen_out[1], vol1.ports[1]) annotation (Line(points={{24,20.8},
          {43,20.8},{43,16},{64,16}}, color={0,127,255}));
  connect(sT_BivHP.portGen_in[1], vol1.ports[2]) annotation (Line(points={{24,6.4},
          {44,6.4},{44,16},{60,16}}, color={0,127,255}));
  connect(vol1.heatPort, fixedTemperature.port)
    annotation (Line(points={{72,6},{96,6},{96,2},{118,2}}, color={191,0,0}));
  annotation (experiment(
      StopTime=864000,
      Interval=600,
      __Dymola_Algorithm="Dassl"));
end Test_ST_BivHP;
