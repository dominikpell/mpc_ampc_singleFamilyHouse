within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Generation.Tests;
model Test_GenerationHeatPumpAndHeatingRod
  extends MA_Pell_SingleFamilyHouse.Systems.BaseClasses.PartialBESExample;

  Interfaces.GenerationControlBus genControlBus
    annotation (Placement(transformation(extent={{-10,54},{30,94}})));
  GenerationHeatPumpAndHeatingRod generationHeatPumpAndHeatingRod(redeclare
      package MediumGen = AixLib.Media.Water,
    systemParameters=systemParameters,        redeclare package Medium_eva =
        AixLib.Media.Air,
    redeclare RecordsCollection.GenerationData.DummyHP heatPumpParameters,
    redeclare RecordsCollection.GenerationData.DummyHR heatingRodParameters)
    annotation (Placement(transformation(extent={{-50,-44},{24,28}})));
  Modelica.Blocks.Sources.Pulse        pulse(period=1800)
    annotation (Placement(transformation(extent={{-62,112},{-42,132}})));
  Components.Pumps.ArtificalPumpFixedT artificalPumpFixedT1(
    redeclare package Medium = AixLib.Media.Water,
    p=200000,
    T_fixed=303.15) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={66,14})));
  Modelica.Blocks.Sources.Constant m_flow(k=systemParameters.mGen_flow_nominal)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={110,14})));
  Modelica.Blocks.Sources.Ramp         ramp(
    height=20,
    duration=3600,
    offset=273.15)
    annotation (Placement(transformation(extent={{-54,42},{-34,62}})));
  Modelica.Blocks.Sources.BooleanConstant
                                       booleanConstant(k=true)
    annotation (Placement(transformation(extent={{-52,78},{-32,98}})));
  Modelica.Blocks.Sources.Constant     const(k=1)
    annotation (Placement(transformation(extent={{-108,116},{-88,136}})));
equation
  connect(generationHeatPumpAndHeatingRod.sigBusGen, genControlBus) annotation (
     Line(
      points={{-12.26,27.28},{-12.26,49.64},{10,49.64},{10,74}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(artificalPumpFixedT1.port_a, generationHeatPumpAndHeatingRod.portGen_out[1])
    annotation (Line(points={{66,24},{54,24},{54,20.8},{24,20.8}}, color={0,127,
          255}));
  connect(artificalPumpFixedT1.port_b, generationHeatPumpAndHeatingRod.portGen_in[1])
    annotation (Line(points={{66,4},{54,4},{54,6.4},{24,6.4}}, color={0,127,255}));
  connect(m_flow.y, artificalPumpFixedT1.m_flow_in) annotation (Line(points={{
          99,14},{87.5,14},{87.5,14},{77.6,14}}, color={0,0,127}));
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
      Line(points={{-31,88},{10,88},{10,74}},       color={255,0,255}),
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
  connect(const.y, genControlBus.hr_on) annotation (Line(points={{-87,126},{-88,
          126},{-88,74},{10,74}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  annotation (experiment(StopTime=31536000, Interval=3600));
end Test_GenerationHeatPumpAndHeatingRod;
