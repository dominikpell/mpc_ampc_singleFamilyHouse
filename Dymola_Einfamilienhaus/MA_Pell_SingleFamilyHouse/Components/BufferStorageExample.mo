within MA_Pell_SingleFamilyHouse.Components;
model BufferStorageExample

  extends Modelica.Icons.Example;
  import AixLib;
  replaceable package Medium =
     Modelica.Media.Water.ConstantPropertyLiquidWater
     constrainedby Modelica.Media.Interfaces.PartialMedium;
  AixLib.Fluid.Storage.BufferStorage bufferStorage(
    energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    massDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial,
    m1_flow_nominal=0.2,
    m2_flow_nominal=0.2,
    mHC1_flow_nominal=0.5,
    n=10,
    redeclare package Medium = Medium,
    data=AixLib.DataBase.Storage.Generic_New_2000l(),
    useHeatingCoil1=true,
    useHeatingCoil2=false,
    upToDownHC1=false,
    upToDownHC2=false,
    useHeatingRod=false,
    redeclare model HeatTransfer =
        AixLib.Fluid.Storage.BaseClasses.HeatTransferBuoyancyWetter,
    redeclare package MediumHC1 = Medium,
    redeclare package MediumHC2 = Medium,
    TStart=303.15) annotation (Placement(transformation(extent={{-4,2},{-24,26}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T=283.15)   annotation(Placement(transformation(extent={{-58,4},
            {-38,24}})));
  AixLib.Fluid.Movers.FlowControlled_m_flow fan(
    redeclare final package Medium = Medium,
    final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final massDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=1,
    redeclare final AixLib.Fluid.Movers.Data.Pumps.Wilo.Stratos32slash1to12 per,
    final inputType=AixLib.Fluid.Types.InputType.Continuous,
    final tau=1,
    final use_inputFilter=false,
    final init=Modelica.Blocks.Types.Init.InitialOutput,
    final y_start=1)                                     annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={-80,8})));

  Modelica.Blocks.Sources.Constant const1(k=0.2)
                                                annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-132,20})));
  AixLib.Fluid.Movers.FlowControlled_m_flow fan1(
    redeclare final package Medium = Medium,
    final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final massDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=1,
    redeclare final AixLib.Fluid.Movers.Data.Pumps.Wilo.Stratos32slash1to12 per,
    final inputType=AixLib.Fluid.Types.InputType.Continuous,
    final tau=1,
    final use_inputFilter=false,
    final init=Modelica.Blocks.Types.Init.InitialOutput,
    final y_start=1)                                     annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={58,4})));

  Modelica.Blocks.Sources.Constant const2(k=0.2)
                                                annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={100,2})));
  AixLib.Fluid.Sources.Boundary_pT
                      boundary_ph2(redeclare package Medium = Medium, nPorts=1)
                                                     annotation(Placement(transformation(extent={{5,-5},{-5,5}},          rotation=0,     origin={-73,53})));
  AixLib.Fluid.Movers.FlowControlled_m_flow fan2(
    redeclare final package Medium = Medium,
    final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final massDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=1,
    redeclare final AixLib.Fluid.Movers.Data.Pumps.Wilo.Stratos32slash1to12 per,
    final inputType=AixLib.Fluid.Types.InputType.Continuous,
    final tau=1,
    final use_inputFilter=false,
    final init=Modelica.Blocks.Types.Init.InitialOutput,
    final y_start=1)                                     annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=270,
        origin={20,10})));

  AixLib.Fluid.Sources.Boundary_pT
                      boundary_ph1(redeclare package Medium = Medium, nPorts=1)
                                                     annotation(Placement(transformation(extent={{5,-5},{-5,5}},          rotation=0,     origin={23,-19})));
equation
  connect(fixedTemperature.port, bufferStorage.heatportOutside) annotation (Line(points={{-38,14},
          {-30,14},{-30,14.72},{-23.75,14.72}},                                                                                         color={191,0,0}));
  connect(fan.port_b, bufferStorage.fluidportBottom2) annotation (Line(points={{-80,-2},
          {-80,-22},{-12,-22},{-12,1.88},{-16.875,1.88}},           color={0,127,
          255}));
  connect(fan.port_a, bufferStorage.fluidportTop2) annotation (Line(points={{-80,18},
          {-80,36},{-17.125,36},{-17.125,26.12}},     color={0,127,255}));
  connect(const1.y, fan.m_flow_in) annotation (Line(points={{-121,20},{-108,20},
          {-108,8},{-92,8}}, color={0,0,127}));
  connect(fan1.port_b, bufferStorage.fluidportTop1) annotation (Line(points={{58,14},
          {58,48},{-10.5,48},{-10.5,26.12}},   color={0,127,255}));
  connect(fan1.port_a, bufferStorage.fluidportBottom1) annotation (Line(points={{58,-6},
          {58,-20},{42,-20},{42,-16},{-4,-16},{-4,1.76},{-10.625,1.76}},
        color={0,127,255}));
  connect(fan1.m_flow_in, const2.y)
    annotation (Line(points={{70,4},{76,4},{76,2},{89,2}}, color={0,0,127}));
  connect(fan.port_a, boundary_ph2.ports[1])
    annotation (Line(points={{-80,18},{-80,53},{-78,53}}, color={0,127,255}));
  connect(fan2.port_b, bufferStorage.portHC1In) annotation (Line(points={{20,20},
          {10,20},{10,20.84},{-3.75,20.84}}, color={0,127,255}));
  connect(bufferStorage.portHC1Out, fan2.port_a) annotation (Line(points={{
          -3.875,17.12},{20,17.12},{20,1.77636e-15}}, color={0,127,255}));
  connect(const2.y, fan2.m_flow_in)
    annotation (Line(points={{89,2},{62,2},{62,10},{32,10}}, color={0,0,127}));
  connect(fan2.port_a, boundary_ph1.ports[1]) annotation (Line(points={{20,
          1.77636e-15},{20,-19},{18,-19}}, color={0,127,255}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    experiment(Tolerance=1e-6, StopTime=86400, Interval=60),
    __Dymola_Commands(file="modelica://AixLib/Resources/Scripts/Dymola/Fluid/Storage/Examples/BufferStorage.mos" "Simulate and plot"),
    Documentation(info="<html><p>
  <b><span style=\"color: #008000;\">Overview</span></b>
</p>
<p>
  This is a simple example of a buffer storage that is charged with a
  mass flow with a higher temperature than the initial temperature.
</p>
<ul>
  <li>November 27, 2019, by Philipp Mehrfeld:<br/>
    <a href=\"https://github.com/RWTH-EBC/AixLib/issues/793\">#793</a>:
    Add one heating coil to example.
  </li>
  <li>
    <i>October 11,2016</i> by Sebastian Stinner:<br/>
    implemented
  </li>
</ul>
</html>"));
end BufferStorageExample;
