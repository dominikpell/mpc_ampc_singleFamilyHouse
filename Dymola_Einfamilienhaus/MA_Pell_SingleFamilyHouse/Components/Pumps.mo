within MA_Pell_SingleFamilyHouse.Components;
package Pumps "Package for pumps"
  model ArtificalPumpIsotermhal
    "Pump without temperature losses"
  extends BaseClasses.PartialArtificalPumpT(bou_source(use_T_in=true), final
      bou_sink(final nPorts=1));
    AixLib.Fluid.Sensors.TemperatureTwoPort senTem(
      redeclare final package Medium = Medium,
      allowFlowReversal=false,                     m_flow_nominal=m_flow_nominal)
      annotation (Placement(transformation(extent={{-90,-10},{-70,10}})));
    parameter Modelica.SIunits.MassFlowRate m_flow_nominal
      "Nominal mass flow rate, used for regularization near zero flow";
  equation
    connect(port_a, senTem.port_a)
      annotation (Line(points={{-100,0},{-90,0}}, color={0,127,255}));
    connect(bou_sink.ports[1], senTem.port_b)
      annotation (Line(points={{-62,0},{-70,0}}, color={0,127,255}));
  connect(senTem.T, bou_source.T_in) annotation (Line(points={{-80,11},{-78,11},
          {-78,26},{-40,26},{-40,24},{-16,24},{-16,4},{58,4}}, color={0,0,127}));
  end ArtificalPumpIsotermhal;

    model ArtificalPumpTprescribed
    "Pump without temperature losses"
    extends BaseClasses.PartialArtificalPumpT(
                                            bou_source(use_T_in=true), final
      bou_sink(final nPorts=1));
    AixLib.Fluid.Sensors.TemperatureTwoPort senTem(
      redeclare final package Medium = Medium,
      allowFlowReversal=false,                     m_flow_nominal=m_flow_nominal)
      annotation (Placement(transformation(extent={{-90,-10},{-70,10}})));
    parameter Modelica.SIunits.MassFlowRate m_flow_nominal
      "Nominal mass flow rate, used for regularization near zero flow";
      Modelica.Blocks.Interfaces.RealInput T_supply(final unit="K")
      "Prescribed mass flow rate" annotation (Placement(transformation(
          extent={{-20,-20},{20,20}},
          rotation=270,
          origin={-50,120}), iconTransformation(
          extent={{-20,-20},{20,20}},
          rotation=270,
          origin={-48,114})));
    equation
    connect(port_a, senTem.port_a)
      annotation (Line(points={{-100,0},{-90,0}}, color={0,127,255}));
    connect(bou_sink.ports[1], senTem.port_b)
      annotation (Line(points={{-62,0},{-70,0}}, color={0,127,255}));
    connect(senTem.T, bou_source.T_in) annotation (Line(points={{-80,11},{-80,
            22},{-18,22},{-18,4},{58,4}}, color={0,0,127}));
    end ArtificalPumpTprescribed;

  model ArtificalPump_h_in "Artifical pump with enthalpy as input"
    extends BaseClasses.PartialArtificalPump_h(bou_sink(nPorts=1), bou_source(
          use_h_in=true));
    Modelica.Blocks.Interfaces.RealInput h_flow_in(final unit="J/(kg)")
      "Prescribed enthaply flow rate" annotation (Placement(transformation(
          extent={{-20,-20},{20,20}},
          rotation=270,
          origin={-60,120}), iconTransformation(
          extent={{-20,-20},{20,20}},
          rotation=270,
          origin={-84,114})));
  equation
    connect(port_a, bou_sink.ports[1])
      annotation (Line(points={{-100,0},{-62,0}}, color={0,127,255}));
    connect(h_flow_in, bou_source.h_in) annotation (Line(points={{-60,120},{-60,
            42},{-28,42},{-28,4},{50,4}},
                                      color={0,0,127}));
  end ArtificalPump_h_in;

  model ArtificalPumpFixedT
    "Temperature of source is a given fixed value"
    extends BaseClasses.PartialArtificalPumpT(final bou_sink(nPorts=1),
        bou_source(final T=T_fixed));
    parameter Modelica.Media.Interfaces.Types.Temperature T_fixed=Medium.T_default
      "Fixed value of temperature for outlet of pump";
  equation
    connect(bou_sink.ports[1], port_a)
      annotation (Line(points={{-62,0},{-100,0}}, color={0,127,255}));
  end ArtificalPumpFixedT;

  package BaseClasses "Base Classes for pumps"
    partial model PartialArtificalPump
      "Partial model a sink combined with a source to avoid calculation of pump characteristics (time-consuming)"
      extends AixLib.Fluid.Interfaces.PartialTwoPort;

      parameter Modelica.Media.Interfaces.Types.AbsolutePressure p=Medium.p_default
      "Fixed value of pressure";

      AixLib.Fluid.Sources.Boundary_ph bou_sink(redeclare package Medium = Medium,
          p=p)
        annotation (Placement(transformation(extent={{-42,-10},{-62,10}})));
      Modelica.Blocks.Interfaces.RealInput m_flow_in(final unit="kg/s")
        "Prescribed mass flow rate"
        annotation (Placement(transformation(extent={{-20,-20},{20,20}},
            rotation=270,
            origin={0,120}),                                                iconTransformation(extent={{-20,-20},
                {20,20}},
            rotation=270,
            origin={0,116})));

      annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
                  Ellipse(extent = {{-100, 96}, {100, -104}},
      lineColor = {0, 0, 0}, fillColor = {0, 127, 0},
                fillPattern=FillPattern.Solid),
                Polygon(points = {{-42, 70}, {78, -4}, {-42, -78}, {-42, 70}},
                lineColor = {0, 0, 0}, fillColor = {175, 175, 175},
                fillPattern=FillPattern.Solid)}),                    Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end PartialArtificalPump;

    partial model PartialArtificalPump_h
      extends PartialArtificalPump;
      AixLib.Fluid.Sources.MassFlowSource_h bou_source(
        redeclare package Medium = Medium,             use_m_flow_in=true, nPorts=1)
        annotation (Placement(transformation(extent={{52,-10},{72,10}})));
    equation
      connect(bou_source.ports[1], port_b)
        annotation (Line(points={{72,0},{100,0}}, color={0,127,255}));
      connect(m_flow_in, bou_source.m_flow_in)
        annotation (Line(points={{0,120},{0,10},{50,10},{50,8}}, color={0,0,127}));
    end PartialArtificalPump_h;

    partial model PartialArtificalPumpT "Setting m_flow and temperature possible"
      extends PartialArtificalPump;
      AixLib.Fluid.Sources.MassFlowSource_T bou_source(
        redeclare package Medium = Medium,             final use_m_flow_in=true,
          nPorts=1)
        annotation (Placement(transformation(extent={{60,-10},{80,10}})));
    equation
      connect(bou_source.ports[1], port_b)
        annotation (Line(points={{80,0},{100,0}}, color={0,127,255}));
      connect(m_flow_in, bou_source.m_flow_in)
        annotation (Line(points={{0,120},{0,8},{58,8}}, color={0,0,127}));
    end PartialArtificalPumpT;
  end BaseClasses;
end Pumps;
