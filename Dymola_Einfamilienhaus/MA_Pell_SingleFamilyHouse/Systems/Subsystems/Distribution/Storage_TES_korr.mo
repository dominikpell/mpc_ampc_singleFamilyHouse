within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution;
model Storage_TES_korr

  replaceable package Medium =
             Modelica.Media.Water.ConstantPropertyLiquidWater
             constrainedby Modelica.Media.Interfaces.PartialMedium;

  parameter Integer n(min=3) "number of layers";
  parameter Modelica.SIunits.Length d "storage diameter";
  parameter Modelica.SIunits.Length h "storage height";
  parameter Modelica.SIunits.ThermalConductivity lambda_ins
"thermal conductivity of insulation"
annotation (Dialog(group="Heat losses"));
  parameter Modelica.SIunits.Length s_ins "thickness of insulation"
annotation (Dialog(group="Heat losses"));
  parameter Modelica.SIunits.CoefficientOfHeatTransfer hConIn
"Iinternal heat transfer coefficient"
annotation (Dialog(group="Heat losses"));
  parameter Modelica.SIunits.CoefficientOfHeatTransfer hConOut
"External heat transfer coefficient"
annotation (Dialog(group="Heat losses"));
  parameter Modelica.SIunits.Volume V_HE "heat exchanger volume"
annotation (Dialog(group="Heat exchanger"));
  parameter Modelica.SIunits.CoefficientOfHeatTransfer k_HE
"heat exchanger heat transfer coefficient"
annotation (Dialog(group="Heat exchanger"));
  parameter Modelica.SIunits.Area A_HE "heat exchanger area"
annotation (Dialog(group="Heat exchanger"));
  parameter Modelica.SIunits.RelativePressureCoefficient beta=350e-6
annotation (Dialog(group="Bouyancy"));
  parameter Real kappa=0.4 annotation (Dialog(group="Bouyancy"));
  parameter Real T_start_layers[n]=fill(T_start, n)
annotation (Dialog(tab="Initialization"));
  parameter Real T_start_layers_HE[n]=fill(T_start, n)
annotation (Dialog(tab="Initialization"));
  Modelica.Fluid.Interfaces.FluidPort_a port_a_consumer_heating(redeclare
      final package
                Medium = Medium) annotation (Placement(transformation(
      extent={{-36,-108},{-16,-88}}), iconTransformation(extent={{-10,-110},
        {10,-90}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b_consumer_top(redeclare final
      package
          Medium = Medium) annotation (Placement(transformation(extent={{-10,
        82},{10,102}}), iconTransformation(extent={{-48,90},{-28,110}})));
  AixLib.Fluid.MixingVolumes.MixingVolume layer[n](
each final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
each final p_start=p_start,
final T_start=T_start_layers,
each final m_flow_small=m_flow_small_layer,
each final V=V/n,
redeclare final package Medium = Medium,
each final nPorts=2,
each final m_flow_nominal=m_flow_nominal_layer) annotation (Placement(
    transformation(
    extent={{-10,-10},{10,10}},
    rotation=90,
    origin={0,0})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort
"connect to ambient temperature around the storage" annotation (Placement(
    transformation(extent={{-116,-10},{-96,10}}), iconTransformation(extent=
       {{-90,-10},{-70,10}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b_heatGenerator_heating(redeclare
      final package
                Medium = Medium) annotation (Placement(transformation(
      extent={{60,-108},{80,-88}}), iconTransformation(extent={{74,-90},{94,
        -70}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a_heatGenerator_heating(redeclare
      final package
                Medium = Medium) annotation (Placement(transformation(
      extent={{72,78},{92,98}}),  iconTransformation(extent={{72,78},{92,98}})));
  AixLib.Fluid.MixingVolumes.MixingVolume layer_HE[n](
each final energyDynamics=energyDynamics,
each final p_start=p_start,
final T_start=T_start_layers_HE,
each final m_flow_small=m_flow_small_layer_HE,
each final V=V_HE/n,
redeclare final package Medium = Medium,
each final nPorts=2,
each final m_flow_nominal=m_flow_nominal_HE) annotation (Placement(
    transformation(
    extent={{-10,-10},{10,10}},
    rotation=90,
    origin={84,0})));

  Modelica.SIunits.Temperature T_mean;

  Modelica.Thermal.HeatTransfer.Components.ThermalConductor heatTransfer[n](
  final G=if n == 1 then (array(G_middle + 2*lambda_ins/s_ins*A for k in 1:
    n)) else cat(1,{G_top_bottom},array(G_middle for k in 2:n - 1),{
        G_top_bottom}))
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  AixLib.Fluid.Storage.BaseClasses.Bouyancy bouyancy[n - 1](
each final rho=Medium.density(Medium.setState_phX(
    port_a_consumer_heating.p,
    inStream(port_a_consumer_heating.h_outflow),
    inStream(port_a_consumer_heating.Xi_outflow))),
each final lambda=Medium.thermalConductivity(Medium.setState_phX(
    port_a_consumer_heating.p,
    inStream(port_a_consumer_heating.h_outflow),
    inStream(port_a_consumer_heating.Xi_outflow))),
each final g=Modelica.Constants.g_n,
each final cp=Medium.specificHeatCapacityCp(Medium.setState_phX(
    port_a_consumer_heating.p,
    inStream(port_a_consumer_heating.h_outflow),
    inStream(port_a_consumer_heating.Xi_outflow))),
each final A=A,
each final beta=beta,
each final dx=dx,
each final kappa=kappa) annotation (Placement(transformation(extent={{-10,-10},
        {10,10}}, origin={-28,0})));
  parameter Modelica.SIunits.MassFlowRate m_flow_nominal_layer
"Nominal mass flow rate in layers";
  parameter Modelica.SIunits.MassFlowRate m_flow_nominal_HE
"Nominal mass flow rate of heat exchanger layers";

  parameter Modelica.Fluid.Types.Dynamics energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial
"Type of energy balance: dynamic (3 initialization options) or steady state in layers and layers_HE";

  //Initialization parameters
  parameter Modelica.Media.Interfaces.Types.Temperature T_start=Medium.T_default
"Start value of temperature" annotation (Dialog(tab="Initialization"));
  parameter Modelica.Media.Interfaces.Types.AbsolutePressure p_start=Medium.p_default
"Start value of pressure" annotation (Dialog(tab="Initialization"));

  //Mass flow rates to regulate zero flow
  parameter Modelica.SIunits.MassFlowRate m_flow_small_layer=1E-4*abs(
  m_flow_nominal_layer)
"Small mass flow rate for regularization of zero flow"
annotation (Dialog(tab="Advanced"));
  parameter Modelica.SIunits.MassFlowRate m_flow_small_layer_HE=1E-4*abs(
  m_flow_nominal_HE) "Small mass flow rate for regularization of zero flow"
annotation (Dialog(tab="Advanced"));

  Modelica.Blocks.Math.Sum sum1(nin=n)
annotation (Placement(transformation(extent={{-50,-80},{-40,-70}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b_consumer_bot(redeclare final
      package
          Medium = Medium) annotation (Placement(transformation(extent={{-50,
        82},{-30,102}}), iconTransformation(extent={{-46,-110},{-26,-90}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a_consumer_cooling(redeclare
      final package
                Medium = Medium) annotation (Placement(transformation(
      extent={{0,-108},{20,-88}}), iconTransformation(extent={{-14,90},{6,110}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a_heatGenerator_cooling(redeclare
      final package
                Medium = Medium) annotation (Placement(transformation(
      extent={{84,82},{104,102}}), iconTransformation(extent={{74,-68},{94,-48}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b_heatGenerator_cooling(redeclare
      final package
                Medium = Medium) annotation (Placement(transformation(
      extent={{84,-108},{104,-88}}), iconTransformation(extent={{72,56},{92,
        76}})));
protected
  parameter Modelica.SIunits.Volume V=A*h;
  parameter Modelica.SIunits.Area A=Modelica.Constants.pi*d^2/4;
  parameter Modelica.SIunits.Length dx=V/A/n;
  parameter Modelica.SIunits.ThermalConductance G_middle=2*Modelica.Constants.pi
  *h/n/                                                                (1/(hConIn*
  d/2) + 1/lambda_ins*log((d/2 + s_ins)/(d/2)) + 1/(hConOut*(d/2 + s_ins)));
  parameter Modelica.SIunits.ThermalConductance G_top_bottom=G_middle +
  lambda_ins/s_ins*A;

equation
  //Calculate mean temperature and SOC
  for
  k in 1:n loop
sum1.u[k] = layer[k].T;
  end for;
  T_mean = sum1.y/n;


  //Connect layers to the upper and lower ports
  connect(
      port_a_consumer_heating, layer[1].ports[1]) annotation (Line(points={{-26,
          -98},
      {-26,-34},{20,-34},{20,-2},{10,-2}},                      color={0,127,
      255}));
  connect(
      layer[n].ports[2], port_b_consumer_top) annotation (Line(points={{10,2},{
      16,2},{20,2},{20,40},{0,40},{0,92}},  color={0,127,255}));

  //Connect layers
  for
  k in 1:n - 1 loop
connect(layer[k].ports[2],layer[k + 1].ports[1]);
  end for;
  //Connect Heat Transfer to the Outside
  for
  k in 1:n loop
connect(heatTransfer[k].port_a,layer[k].heatPort);
connect(heatTransfer[k].port_b,heatPort);
  end for;
  //Connect layers of Heat Exchanger
  connect(
      port_a_heatGenerator_heating, layer_HE[n].ports[2]) annotation (Line(
    points={{82,88},{82,36},{98,36},{98,2},{94,2},{94,2}},            color=
     {0,127,255}));
  connect(
      port_b_heatGenerator_heating, layer_HE[1].ports[1]) annotation (Line(
    points={{70,-98},{70,-26},{94,-26},{94,-2}},       color={0,127,255}));
  for
  k in 1:n - 1 loop
connect(layer_HE[k].ports[2],layer_HE[k + 1].ports[1]);
  end for;
  //Connect volume layers
  for
  k in 1:n loop
connect(layer_HE[k].heatPort,layer[k].heatPort);

  end for;
  //Connect bouyancy element
  for
  k in 1:n - 1 loop
connect(bouyancy[k].port_a,layer[k + 1].heatPort);
connect(bouyancy[k].port_b,layer[k].heatPort);
  end for;
  connect(heatPort, heatPort)
annotation (Line(points={{-106,0},{-106,0}}, color={191,0,0}));

  connect(
      port_b_consumer_bot, layer[1].ports[2]) annotation (Line(points={{-40,92},
      {-40,24},{16,24},{16,2},{10,2}},             color={0,127,255}));
  connect(
      port_a_consumer_cooling, layer[n].ports[1])
annotation (Line(points={{10,-98},{10,-2}},      color={0,127,255}));
  connect(
      port_a_heatGenerator_cooling, layer_HE[1].ports[2])
annotation (Line(points={{94,92},{94,2}},            color={0,127,255}));
  connect(
      port_b_heatGenerator_cooling, layer_HE[n].ports[1]) annotation (Line(
    points={{94,-98},{94,-2},{94,-2}},           color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
        {100,100}}), graphics={
    Polygon(
      points={{-154,3},{-136,-7},{-110,-3},{-84,-7},{-48,-5},{-18,-9},{6,-3},
          {6,-41},{-154,-41},{-154,3}},
      lineColor={0,0,255},
      pattern=LinePattern.None,
      fillColor={0,0,255},
          fillPattern=FillPattern.Solid,
          origin={78,-59},
          rotation=360),
        Polygon(
          points={{-154,3},{-134,-3},{-110,1},{-84,-1},{-56,-5},{-30,-11},{6,-3},
              {6,-41},{-154,-41},{-154,3}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={14,110,255},
          fillPattern=FillPattern.Solid,
          origin={78,-27},
          rotation=360),
        Rectangle(
          extent={{-80,-71},{80,71}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={85,170,255},
          fillPattern=FillPattern.Solid,
          origin={4,1},
          rotation=360),
        Polygon(
          points={{-24,-67},{-16,-67},{-8,-67},{4,-67},{12,-67},{36,-67},{76,-67},
              {110,-67},{136,-67},{136,39},{-24,35},{-24,-67}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid,
          origin={-52,33},
          rotation=360),
        Polygon(
          points={{-39,-30},{-31,-30},{-11,-30},{23,-30},{67,-30},{93,-30},{121,
              -30},{121,24},{-39,26},{-39,-30}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,170,170},
          fillPattern=FillPattern.Solid,
          origin={-37,38},
          rotation=360),
        Polygon(
          points={{-80,100},{-80,54},{-62,54},{-30,54},{32,54},{80,54},{80,82},
              {80,100},{-80,100}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,62,62},
          fillPattern=FillPattern.Solid,
          origin={4,0},
          rotation=360),
        Rectangle(
          extent={{-76,100},{84,-100}},
          lineColor={0,0,0},
          lineThickness=1),
        Line(
          points={{-21,94},{-21,132}},
          color={0,0,0},
          smooth=Smooth.Bezier,
          thickness=1,
          arrow={Arrow.Filled,Arrow.None},
          origin={-56,67},
          rotation=270,
          visible=use_heatingCoil1),
        Line(
          points={{-54,88},{68,56}},
          color={0,0,0},
          thickness=1,
          smooth=Smooth.Bezier,
          visible=use_heatingCoil1),
        Line(
          points={{68,56},{-48,44}},
          color={0,0,0},
          thickness=1,
          smooth=Smooth.Bezier,
          visible=use_heatingCoil1),
        Line(
          points={{-48,44},{62,6}},
          color={0,0,0},
          thickness=1,
          smooth=Smooth.Bezier,
          visible=use_heatingCoil1),
        Line(
          points={{62,6},{-44,-16}},
          color={0,0,0},
          thickness=1,
          smooth=Smooth.Bezier,
          visible=use_heatingCoil1),
        Line(
          points={{76,-81},{-26,-81}},
          color={0,0,0},
          thickness=1,
          smooth=Smooth.Bezier,
          visible=use_heatingCoil1),
        Line(
          points={{0,-9},{0,9}},
          color={0,0,0},
          smooth=Smooth.Bezier,
          thickness=1,
          arrow={Arrow.Filled,Arrow.None},
          origin={-34,-81},
          rotation=90,
          visible=use_heatingCoil1),
        Line(
          points={{62,-42},{-44,-16}},
          color={0,0,0},
          thickness=1,
          smooth=Smooth.Bezier,
          visible=use_heatingCoil1),
        Line(
          points={{62,-42},{-42,-80}},
          color={0,0,0},
          thickness=1,
          smooth=Smooth.Bezier,
          visible=use_heatingCoil1),
        Line(
          points={{48,88},{-54,88}},
          color={0,0,0},
          thickness=1,
          smooth=Smooth.Bezier,
          visible=use_heatingCoil1)}), Documentation(info =                                                                                                                                                                                                        "<html><h4>
  <span style=\"color:#008000\">Overview</span>
</h4>
<p>
  Simple model for a buffer storage.
</p>
<h4>
  <span style=\"color:#008000\">Concept</span>
</h4>
<p>
  The water volume can be discretised in several layers.
</p>
<p>
  The following physical processes are modelled
</p>
<ul>
  <li>heat exchange with the environment
  </li>
  <li>heat exchange over the heat exchanger
  </li>
  <li>a bouyancy model for the heat transfer between the layers
  </li>
</ul>
<p>
  <br/>
  <b><span style=\"color: #008000\">Example Results</span></b>
</p>
<p>
  <a href=
  \"AixLib.HVAC.Storage.Examples.StorageBoiler\">AixLib.HVAC.Storage.Examples.StorageBoiler</a>
</p>
<p>
  <a href=
  \"AixLib.HVAC.Storage.Examples.StorageSolarCollector\">AixLib.HVAC.Storage.Examples.StorageSolarCollector</a>
</p>
<ul>
  <li>
    <i>November 2014&#160;</i> by Marcus Fuchs:<br/>
    Changed model to use Annex 60 base class
  </li>
  <li>
    <i>13.12.2013</i> by Sebastian Stinner:<br/>
    implemented
  </li>
</ul>
</html>"));
end Storage_TES_korr;
