within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Generation;
model GenerationHeatPumpAndHeatingRod
  "Generation system for monoenergetic heat supply using a electrical heat pump and a heating rod"
  extends BaseClasses.PartialGeneration(final nParallel=1);
  parameter Real t_Con_start=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real t_supply_start=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real t_supply_HP_start=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real t_return_start=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));

  Components.Pumps.ArtificalPumpIsotermhal artificalPumpIsotermhal(
    senTem(
    T_start =        t_return_start),
    redeclare package Medium = MediumGen,
    final p=systemParameters.pHyd,
    final m_flow_nominal=systemParameters.mGen_flow_nominal) annotation (
      Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={46,-54})));
  Modelica.Blocks.Logical.Switch switch1 annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={46,-16})));
  Modelica.Blocks.Sources.RealExpression dummyMassFlow(final y=
        systemParameters.mGen_flow_nominal)
    annotation (Placement(transformation(extent={{84,-6},{64,14}})));
  Modelica.Blocks.Sources.RealExpression dummyZero annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={18,4})));
  Modelica.Blocks.Logical.Or or1 annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={46,14})));

  AixLib.Fluid.HeatPumps.HeatPump heatPump(
    redeclare package Medium_con = MediumGen,
    redeclare package Medium_eva = Medium_eva,
    final use_rev=true,
    final use_autoCalc=false,
    final Q_useNominal=0,
    scalingFactor=1,
    final use_refIne=false,
    final useBusConnectorOnly=true,
    final mFlow_conNominal=systemParameters.mGen_flow_nominal,
    final VCon=heatPumpParameters.VCon,
    final dpCon_nominal=heatPumpParameters.dpCon_nominal,
    final use_conCap=false,
    final CCon=0,
    final GConOut=0,
    final GConIns=0,
    final mFlow_evaNominal=heatPumpParameters.mFlow_eva,
    final VEva=heatPumpParameters.VEva,
    final dpEva_nominal=heatPumpParameters.dpEva_nominal,
    final use_evaCap=false,
    final CEva=0,
    final GEvaOut=0,
    final GEvaIns=0,
    final tauSenT=systemParameters.tauTempSensors,
    final transferHeat=false,
    final allowFlowReversalEva=systemParameters.allowFlowReversal,
    final allowFlowReversalCon=systemParameters.allowFlowReversal,
    final tauHeaTraEva=systemParameters.tauHeaTraTempSensors,
    final TAmbEva_nominal=systemParameters.TAmbInternal,
    final tauHeaTraCon=systemParameters.tauHeaTraTempSensors,
    final TAmbCon_nominal=systemParameters.TOda_nominal,
    final pCon_start=systemParameters.pHyd,
    TCon_start=t_Con_start,
    final pEva_start=systemParameters.pAtm,
    final TEva_start=systemParameters.TAir_start,
    final massDynamics=systemParameters.massDynamics,
    final energyDynamics=systemParameters.energyDynamics,
    final show_TPort=systemParameters.show_T,
    redeclare model PerDataMainHP =
        MA_Pell_SingleFamilyHouse.Systems.Subsystems.Generation.BaseClasses.LookUpTable2D_heat
        (                                                                                       dataTable=
            MA_Pell_SingleFamilyHouse.RecordsCollection.HeatPumpData.HeatPumpCarnotHeat(),
                extrapolation=false),
    redeclare model PerDataRevHP =
        MA_Pell_SingleFamilyHouse.Systems.Subsystems.Generation.BaseClasses.LookUpTable2D_cool
        (                                                                                       dataTable=
            MA_Pell_SingleFamilyHouse.RecordsCollection.HeatPumpData.HeatPumpCarnotCool(),
                extrapolation=false))            annotation (Placement(
        transformation(
        extent={{22,-27},{-22,27}},
        rotation=270,
        origin={-46,15})));

  AixLib.Fluid.Sources.Boundary_ph bou_sinkAir(final nPorts=1, redeclare
      package Medium = Medium_eva)                       annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-90,-22})));
  AixLib.Fluid.Sources.MassFlowSource_T bou_air(
    final m_flow=heatPumpParameters.mFlow_eva,
    final use_T_in=true,
    redeclare package Medium = Medium_eva,
    final use_m_flow_in=false,
    final nPorts=1)
    annotation (Placement(transformation(extent={{-100,42},{-80,62}})));

  Modelica.Blocks.Logical.GreaterThreshold isOnHP(threshold=Modelica.Constants.eps)
    annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={16,38})));
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
    T_start=t_supply_start,
    final Q_flow_nominal=heatingRodParameters.Q_HR_Nom,
    final V=heatingRodParameters.V_hr,
    final eta=heatingRodParameters.eta_hr)
    annotation (Placement(transformation(extent={{36,64},{68,96}})));
  replaceable
    RecordsCollection.GenerationData.HeatPumpBaseDataDefinition
    heatPumpParameters(
    VEva=0.03,
    VCon=0.03,         Q_HP_Nom=systemParameters.Q_HP_max)
                       annotation (choicesAllMatching=true, Placement(
        transformation(extent={{-90,4},{-72,22}})));
  replaceable
    RecordsCollection.GenerationData.HeatingRodBaseDataDefinition
    heatingRodParameters annotation (choicesAllMatching=true, Placement(
        transformation(extent={{58,42},{70,54}})));
  replaceable package Medium_eva =
      Modelica.Media.Interfaces.PartialMedium                              constrainedby
    Modelica.Media.Interfaces.PartialMedium annotation (
      __Dymola_choicesAllMatching=true);
  Modelica.Blocks.Logical.Switch switch2 annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-124,56})));
  Modelica.Blocks.Sources.BooleanConstant
                                   AirOrSoil(k=heatPumpParameters.useAirSource)
    annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={-164,56})));
  Modelica.Blocks.Logical.GreaterThreshold isOnHR(threshold=Modelica.Constants.eps)
    annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={40,36})));
  Modelica.Blocks.Interfaces.RealOutput P_el_HP_HR annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-100,-100})));
  Modelica.Blocks.Sources.RealExpression power_HP(y=heatPump.innerCycle.Pel)
    annotation (Placement(transformation(extent={{-64,-80},{-82,-62}})));
AixLib.Fluid.Sensors.TemperatureTwoPort senTemVL1(
    redeclare final package Medium = MediumGen,
    allowFlowReversal=false,
    m_flow_nominal=systemParameters.mGen_flow_nominal,
    T_start=t_supply_start)
    annotation (Placement(transformation(extent={{80,74},{90,86}})));
  Modelica.Blocks.Sources.RealExpression Treturn(y=heatPump.innerCycle.sigBus.TConInMea)
    annotation (Placement(transformation(extent={{-46,-86},{-30,-68}})));
  Modelica.Blocks.Sources.RealExpression TsupplyHP(y=heatPump.innerCycle.sigBus.TConOutMea)
    annotation (Placement(transformation(extent={{-46,-98},{-30,-80}})));
  Modelica.Blocks.Sources.RealExpression TsupplyHR(y=senTemVL1.T)
    annotation (Placement(transformation(extent={{-46,-110},{-30,-92}})));
  Modelica.Blocks.Sources.RealExpression power_rod(y=hea.Pel)
    annotation (Placement(transformation(extent={{-64,-92},{-82,-74}})));
  Modelica.Blocks.Math.Add add
    annotation (Placement(transformation(extent={{-90,-74},{-98,-82}})));
  Modelica.Blocks.Sources.RealExpression heat_rod(y=hea.vol.heatPort.Q_flow)
    annotation (Placement(transformation(extent={{-46,-116},{-30,-104}})));
  Modelica.Blocks.Sources.RealExpression heat_HP(y=heatPump.innerCycle.QCon)
    annotation (Placement(transformation(extent={{-46,-124},{-30,-112}})));
  Modelica.Blocks.Sources.BooleanExpression isHP_on(y=sigBusGen.hp_bus.onOffMea)
    annotation (Placement(transformation(extent={{58,-108},{40,-90}})));
  Modelica.Blocks.Math.BooleanToReal booleanToReal
    annotation (Placement(transformation(extent={{34,-94},{24,-104}})));
equation
  connect(dummyZero.y,switch1. u3)
    annotation (Line(points={{29,4},{38,4},{38,-4}},    color={0,0,127}));
  connect(dummyMassFlow.y,switch1. u1)
    annotation (Line(points={{63,4},{54,4},{54,-4}}, color={0,0,127}));
  connect(or1.y,switch1. u2)
    annotation (Line(points={{46,7.4},{46,-4}},
                                             color={255,0,255}));
  connect(switch1.y, artificalPumpIsotermhal.m_flow_in)
    annotation (Line(points={{46,-27},{46,-42.4}},     color={0,0,127}));

  connect(bou_air.ports[1], heatPump.port_a2) annotation (Line(
      points={{-80,52},{-59.5,52},{-59.5,37}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(heatPump.port_b2, bou_sinkAir.ports[1]) annotation (Line(
      points={{-59.5,-7},{-58,-7},{-58,-22},{-80,-22}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(sigBusGen.hp_bus, heatPump.sigBus) annotation (Line(
      points={{2.1,98.1},{-132,98.1},{-132,-62},{-54.775,-62},{-54.775,-6.78}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));

  connect(sigBusGen.hp_bus.nSet, isOnHP.u) annotation (Line(
      points={{2.1,98.1},{2.1,58},{16,58},{16,45.2}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(isOnHP.y, or1.u2) annotation (Line(points={{16,31.4},{16,28},{41.2,28},
          {41.2,21.2}}, color={255,0,255}));
  connect(bou_air.T_in, switch2.y)
    annotation (Line(points={{-102,56},{-113,56}}, color={0,0,127}));
  connect(sigBusGen.hp_bus.TOdaMea, switch2.u1) annotation (Line(
      points={{2.1,98.1},{-150,98.1},{-150,64},{-136,64}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(sigBusGen.TSoil, switch2.u3) annotation (Line(
      points={{2.1,98.1},{-76,98.1},{-76,100},{-152,100},{-152,48},{-136,48}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(switch2.u2, AirOrSoil.y)
    annotation (Line(points={{-136,56},{-157.4,56}}, color={255,0,255}));
  connect(hea.u, sigBusGen.hr_on) annotation (Line(points={{32.8,89.6},{22,89.6},
          {22,98.1},{2.1,98.1}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(sigBusGen.hr_on, isOnHR.u) annotation (Line(
      points={{2.1,98.1},{2.1,60},{46,60},{46,43.2},{40,43.2}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(isOnHR.y, or1.u1) annotation (Line(points={{40,29.4},{46,29.4},{46,
          21.2}}, color={255,0,255}));
  connect(portGen_in[1], artificalPumpIsotermhal.port_a) annotation (Line(
        points={{100,-2},{100,-54},{56,-54}},          color={0,127,255}));
  connect(hea.port_b, senTemVL1.port_a)
    annotation (Line(points={{68,80},{80,80}}, color={0,127,255}));
  connect(senTemVL1.port_b, portGen_out[1])
    annotation (Line(points={{90,80},{100,80}}, color={0,127,255}));
  connect(heatPump.port_a1, artificalPumpIsotermhal.port_b) annotation (Line(
        points={{-32.5,-7},{-32,-7},{-32,-54},{36,-54}}, color={0,127,255}));
  connect(heatPump.port_b1, hea.port_a) annotation (Line(points={{-32.5,37},{
          -32.5,80},{36,80}}, color={0,127,255}));
  connect(power_HP.y, add.u2) annotation (Line(points={{-82.9,-71},{-85.45,-71},
          {-85.45,-75.6},{-89.2,-75.6}}, color={0,0,127}));
  connect(power_rod.y, add.u1) annotation (Line(points={{-82.9,-83},{-86.45,-83},
          {-86.45,-80.4},{-89.2,-80.4}}, color={0,0,127}));
  connect(add.y, P_el_HP_HR) annotation (Line(points={{-98.4,-78},{-100,-78},{
          -100,-100},{-100,-100}}, color={0,0,127}));
  connect(heat_rod.y, outBusGen.heat_rod) annotation (Line(points={{-29.2,-110},
          {0.05,-110},{0.05,-99.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(heat_HP.y, outBusGen.heat_HP) annotation (Line(points={{-29.2,-118},{
          0,-118},{0,-100}},         color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(power_rod.y, outBusGen.power_rod) annotation (Line(points={{-82.9,-83},
          {-82.9,-124},{0.05,-124},{0.05,-99.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(power_HP.y, outBusGen.power_HP) annotation (Line(points={{-82.9,-71},
          {-84,-71},{-84,-128},{0.05,-128},{0.05,-99.95}}, color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(TsupplyHR.y, outBusGen.T_supply_heat) annotation (Line(points={{-29.2,
          -101},{-12,-101},{-12,-99.95},{0.05,-99.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(TsupplyHP.y, outBusGen.T_supply_HP_heat) annotation (Line(points={{
          -29.2,-89},{0.05,-89},{0.05,-99.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(Treturn.y, outBusGen.T_return_heat) annotation (Line(points={{-29.2,
          -77},{0.05,-77},{0.05,-99.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(TsupplyHP.y, outBusGen.T_supply_HP) annotation (Line(points={{-29.2,
          -89},{-0.6,-89},{-0.6,-99.95},{0.05,-99.95}}, color={0,0,127}));
  connect(Treturn.y, outBusGen.T_return) annotation (Line(points={{-29.2,-77},{
          0.05,-77},{0.05,-99.95}}, color={0,0,127}));
  connect(TsupplyHR.y, outBusGen.T_supply) annotation (Line(points={{-29.2,-101},
          {-14.6,-101},{-14.6,-99.95},{0.05,-99.95}}, color={0,0,127}));
  connect(isHP_on.y, booleanToReal.u) annotation (Line(points={{39.1,-99},{
          36.55,-99},{36.55,-99},{35,-99}}, color={255,0,255}));
  connect(booleanToReal.y, outBusGen.x_HP_on) annotation (Line(points={{23.5,
          -99},{11.75,-99},{11.75,-99.95},{0.05,-99.95}}, color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
end GenerationHeatPumpAndHeatingRod;
