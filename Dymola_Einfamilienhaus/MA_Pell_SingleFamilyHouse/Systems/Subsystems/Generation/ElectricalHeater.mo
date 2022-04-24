within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Generation;
model ElectricalHeater "Only heat using a heating rod"
  extends BaseClasses.PartialGeneration(final nParallel=1);

  Modelica.Blocks.Logical.Switch switch1 annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={46,-16})));
  Modelica.Blocks.Sources.Constant       dummyMassFlow(final k=1)
    annotation (Placement(transformation(extent={{84,-6},{64,14}})));
  Modelica.Blocks.Sources.Constant       dummyZero(k=0)
                                                   annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={18,4})));

  AixLib.Fluid.HeatExchangers.HeatingRod hea(
    redeclare package Medium = MediumGen,
    final allowFlowReversal=systemParameters.allowFlowReversal,
    final m_flow_nominal=systemParameters.mGen_flow_nominal,
    final m_flow_small=1E-4*abs(systemParameters.mGen_flow_nominal),
    final show_T=systemParameters.show_T,
    final dp_nominal=heatingRodParameters.dp_nominal,
    final tau=30,
    final energyDynamics=systemParameters.energyDynamics,
    final massDynamics=systemParameters.massDynamics,
    final p_start=systemParameters.pHyd,
    final T_start=systemParameters.TWater_start,
    final Q_flow_nominal=heatingRodParameters.Q_HR_Nom,
    final V=heatingRodParameters.V_hr,
    final eta=heatingRodParameters.eta_hr)
    annotation (Placement(transformation(extent={{-16,-16},{16,16}},
        rotation=90,
        origin={-32,10})));
  replaceable
    RecordsCollection.GenerationData.HeatingRodBaseDataDefinition
    heatingRodParameters annotation (choicesAllMatching=true, Placement(
        transformation(extent={{-62,-42},{-50,-30}})));

  Modelica.Blocks.Logical.GreaterThreshold isOnHR(threshold=Modelica.Constants.eps)
    annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={46,14})));

  AixLib.Fluid.Movers.SpeedControlled_y pumpHP(
    redeclare final package Medium = MediumGen,
    final energyDynamics=systemParameters.energyDynamics,
    final massDynamics=systemParameters.massDynamics,
    final p_start=systemParameters.pHyd,
    final T_start=systemParameters.TWater_start,
    final allowFlowReversal=systemParameters.allowFlowReversal,
    redeclare RecordsCollection.Movers.AutomaticConfigurationData per(
      final m_flow_nominal=systemParameters.mGen_flow_nominal,
      final dp_nominal=hea.dp_nominal,
      final rho=systemParameters.rhoWater),
    final inputType=AixLib.Fluid.Types.InputType.Continuous,
    final addPowerToMedium=false,
    use_inputFilter=false,
    final init=Modelica.Blocks.Types.Init.InitialOutput,
    final y_start=1) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={48,-48})));
  AixLib.Fluid.Sources.Boundary_pT bou1(
    redeclare package Medium = MediumGen,
    p=systemParameters.pHyd,
    T=systemParameters.TWater_start,
    nPorts=1)                                    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={62,-74})));

equation
  connect(dummyZero.y,switch1. u3)
    annotation (Line(points={{29,4},{38,4},{38,-4}},    color={0,0,127}));
  connect(dummyMassFlow.y,switch1. u1)
    annotation (Line(points={{63,4},{54,4},{54,-4}}, color={0,0,127}));

  connect(hea.u, sigBusGen.hr_on) annotation (Line(points={{-41.6,-9.2},{-62,-9.2},
          {-62,98},{2,98}},      color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(sigBusGen.hr_on, isOnHR.u) annotation (Line(
      points={{2,98},{2,60},{46,60},{46,21.2}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(hea.port_b, portGen_out[1]) annotation (Line(points={{-32,26},{-32,80},
          {100,80}},        color={0,127,255}));
  connect(hea.Pel, outBusGen.PelHR) annotation (Line(points={{-41.6,27.6},{-41.6,
          49.6},{-72,49.6},{-72,-100},{0,-100}},
                                       color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(portGen_in[1], pumpHP.port_a) annotation (Line(points={{100,-2},{80,-2},
          {80,-48},{58,-48}}, color={0,127,255}));
  connect(pumpHP.port_a, bou1.ports[1]) annotation (Line(points={{58,-48},{62,-48},
          {62,-64}},          color={0,127,255}));
  connect(switch1.y, pumpHP.y) annotation (Line(points={{46,-27},{46,-31.5},{48,
          -31.5},{48,-36}}, color={0,0,127}));
  connect(isOnHR.y, switch1.u2)
    annotation (Line(points={{46,7.4},{46,-4}}, color={255,0,255}));
  connect(hea.port_a, pumpHP.port_b) annotation (Line(points={{-32,-6},{-34,-6},
          {-34,-48},{38,-48}}, color={0,127,255}));
end ElectricalHeater;
