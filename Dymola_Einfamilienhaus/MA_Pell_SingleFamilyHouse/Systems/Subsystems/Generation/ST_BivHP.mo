within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Generation;
model ST_BivHP
  "Solar thermal assistet monoenergetic heat pump with heating rod"
  extends BaseClasses.PartialGeneration(final nParallel=2);
  replaceable package Medium_eva = AixLib.Media.Air                        constrainedby
    Modelica.Media.Interfaces.PartialMedium annotation (
      __Dymola_choicesAllMatching=true);
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
  Modelica.Blocks.Logical.Or or1 annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={46,14})));

  AixLib.Fluid.HeatPumps.HeatPump heatPump(
    redeclare package Medium_con = MediumGen,
    redeclare package Medium_eva = Medium_eva,
    final use_rev=false,
    final use_autoCalc=false,
    final Q_useNominal=0,
    final scalingFactor=heatPumpParameters.Q_HP_Nom/heatPump.innerCycle.PerformanceDataHPHeating.Q_flowTableNom,
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
    final transferHeat=true,
    final allowFlowReversalEva=systemParameters.allowFlowReversal,
    final allowFlowReversalCon=systemParameters.allowFlowReversal,
    final tauHeaTraEva=systemParameters.tauHeaTraTempSensors,
    final TAmbEva_nominal=systemParameters.TAmbInternal,
    final tauHeaTraCon=systemParameters.tauHeaTraTempSensors,
    final TAmbCon_nominal=systemParameters.TOda_nominal,
    final pCon_start=systemParameters.pHyd,
    final TCon_start=systemParameters.TWater_start,
    final pEva_start=systemParameters.pAtm,
    final TEva_start=systemParameters.TAir_start,
    final massDynamics=systemParameters.massDynamics,
    final energyDynamics=systemParameters.energyDynamics,
    final show_TPort=systemParameters.show_T,
    redeclare model PerDataMainHP =
        AixLib.DataBase.HeatPump.PerformanceData.VCLibMap (
        QCon_flow_nominal=heatPumpParameters.Q_HP_Nom,
        refrigerant=heatPumpParameters.refrigerant,
        flowsheet=heatPumpParameters.flowsheet),
    redeclare model PerDataRevHP =
        AixLib.DataBase.Chiller.PerformanceData.LookUpTable2D (dataTable=
            AixLib.DataBase.Chiller.EN14511.Vitocal200AWO201()))
                                                 annotation (Placement(
        transformation(
        extent={{22,-27},{-22,27}},
        rotation=270,
        origin={-44,15})));

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
    final T_start=systemParameters.TWater_start,
    final Q_flow_nominal=heatingRodParameters.Q_HR_Nom,
    final V=heatingRodParameters.V_hr,
    final eta=heatingRodParameters.eta_hr)
    annotation (Placement(transformation(extent={{48,64},{80,96}})));
  replaceable
    RecordsCollection.GenerationData.HeatPumpBaseDataDefinition
    heatPumpParameters annotation (choicesAllMatching=true, Placement(
        transformation(extent={{-90,4},{-72,22}})));
  replaceable
    RecordsCollection.GenerationData.HeatingRodBaseDataDefinition
    heatingRodParameters annotation (choicesAllMatching=true, Placement(
        transformation(extent={{58,42},{70,54}})));

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
  AixLib.Fluid.Solar.Thermal.SolarThermal solarThermal(
    redeclare final package Medium = MediumGen,
    final allowFlowReversal=true,
    final m_flow_nominal=solarThermalParas.m_flow_nominal,
    final m_flow_small=1E-4*abs(solarThermalParas.m_flow_nominal),
    final show_T=false,
    final tau=1,
    final initType=Modelica.Blocks.Types.Init.InitialState,
    final T_start=systemParameters.TWater_start,
    final transferHeat=false,
    final TAmb=MediumGen.T_default,
    final tauHeaTra=1200,
    final p_start=systemParameters.pHyd,
    final dp_nominal=dpST_nominal,
    final rho_default=systemParameters.rhoWater,
    final a=solarThermal.pressureDropCoeff,
    final A=solarThermalParas.A,
    final volPip=solarThermalParas.volPip,
    final pressureDropCoeff=solarThermalParas.pressureDropCoeff,
    final Collector=solarThermalParas.Collector)             annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-32,-86})));
  replaceable
    RecordsCollection.GenerationData.SolarThermalBaseDataDefinition
    solarThermalParas annotation (choicesAllMatching=true, Placement(
        transformation(extent={{-68,-98},{-48,-78}})));
  AixLib.Fluid.Movers.SpeedControlled_y pumpST(
    redeclare final package Medium = MediumGen,
    final energyDynamics=systemParameters.energyDynamics,
    final massDynamics=systemParameters.massDynamics,
    final p_start=systemParameters.pHyd,
    final T_start=systemParameters.TWater_start,
    final allowFlowReversal=systemParameters.allowFlowReversal,
    final show_T=systemParameters.show_T,
    redeclare RecordsCollection.Movers.AutomaticConfigurationData per(
      final speed_rpm_nominal=systemParameters.speed_rpm_nominal,
      final m_flow_nominal=solarThermalParas.m_flow_nominal,
      final dp_nominal=dpST_nominal,
      final rho=systemParameters.rhoWater,
      final V_flowCurve=systemParameters.V_flowCurve,
      final dpCurve=systemParameters.dpCurve),
    final inputType=AixLib.Fluid.Types.InputType.Continuous,
    final addPowerToMedium=systemParameters.addPowerToMedium,
    final tau=systemParameters.tauMover,
    final use_inputFilter=systemParameters.use_inputFilterMovers,
    final riseTime=systemParameters.riseTimeMoverInpFilter,
    final init=Modelica.Blocks.Types.Init.InitialOutput,
    final y_start=1) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={28,-104})));

  AixLib.Fluid.Sources.Boundary_pT bou(
    redeclare package Medium = MediumGen,
    final p=systemParameters.pHyd,
    final T=systemParameters.TWater_start,              nPorts=1) annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={54,-128})));
  Modelica.Blocks.Sources.Constant AirOrSoil1(k=1)
    annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={-2,-132})));
  AixLib.Fluid.Movers.SpeedControlled_y pumpHP(
    redeclare final package Medium = MediumGen,
    final energyDynamics=systemParameters.energyDynamics,
    final massDynamics=systemParameters.massDynamics,
    final p_start=systemParameters.pHyd,
    final T_start=systemParameters.TWater_start,
    final allowFlowReversal=systemParameters.allowFlowReversal,
    final show_T=systemParameters.show_T,
    redeclare RecordsCollection.Movers.AutomaticConfigurationData per(
      final speed_rpm_nominal=systemParameters.speed_rpm_nominal,
      final m_flow_nominal=systemParameters.mGen_flow_nominal,
      final dp_nominal=heatPump.dpCon_nominal + hea.dp_nominal,
      final rho=systemParameters.rhoWater,
      final V_flowCurve=systemParameters.V_flowCurve,
      final dpCurve=systemParameters.dpCurve),
    final inputType=AixLib.Fluid.Types.InputType.Continuous,
    final addPowerToMedium=systemParameters.addPowerToMedium,
    final tau=systemParameters.tauMover,
    final use_inputFilter=systemParameters.use_inputFilterMovers,
    final riseTime=systemParameters.riseTimeMoverInpFilter,
    final init=Modelica.Blocks.Types.Init.InitialOutput,
    final y_start=1) annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={48,-50})));
  AixLib.Fluid.Sources.Boundary_pT bou1(
    redeclare package Medium = MediumGen,
    final p=systemParameters.pHyd,
    final T=systemParameters.TWater_start,
    final nPorts=1)                                    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={66,-74})));

protected
  parameter Modelica.SIunits.PressureDifference dpST_nominal=solarThermalParas.m_flow_nominal
      ^2*solarThermalParas.pressureDropCoeff/(systemParameters.rhoWater^2)
    "Pressure drop at nominal mass flow rate";
equation
  connect(dummyZero.y,switch1. u3)
    annotation (Line(points={{29,4},{38,4},{38,-4}},    color={0,0,127}));
  connect(dummyMassFlow.y,switch1. u1)
    annotation (Line(points={{63,4},{54,4},{54,-4}}, color={0,0,127}));
  connect(or1.y,switch1. u2)
    annotation (Line(points={{46,7.4},{46,-4}},
                                             color={255,0,255}));

  connect(bou_air.ports[1], heatPump.port_a2) annotation (Line(
      points={{-80,52},{-57.5,52},{-57.5,37}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(heatPump.port_b2, bou_sinkAir.ports[1]) annotation (Line(
      points={{-57.5,-7},{-58,-7},{-58,-22},{-80,-22}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(sigBusGen.hp_bus, heatPump.sigBus) annotation (Line(
      points={{2,98},{-132,98},{-132,-62},{-52.775,-62},{-52.775,-6.78}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));

  connect(sigBusGen.hp_bus.nSet, isOnHP.u) annotation (Line(
      points={{2,98},{2,58},{16,58},{16,45.2}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(isOnHP.y, or1.u2) annotation (Line(points={{16,31.4},{16,28},{41.2,28},
          {41.2,21.2}}, color={255,0,255}));
  connect(heatPump.port_b1, hea.port_a) annotation (Line(points={{-30.5,37},{-30.5,
          80},{48,80}},       color={0,127,255}));
  connect(bou_air.T_in, switch2.y)
    annotation (Line(points={{-102,56},{-113,56}}, color={0,0,127}));
  connect(sigBusGen.hp_bus.TOdaMea, switch2.u1) annotation (Line(
      points={{2,98},{-150,98},{-150,64},{-136,64}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(sigBusGen.TSoil, switch2.u3) annotation (Line(
      points={{2,98},{-76,98},{-76,100},{-152,100},{-152,48},{-136,48}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(switch2.u2, AirOrSoil.y)
    annotation (Line(points={{-136,56},{-157.4,56}}, color={255,0,255}));
  connect(hea.u, sigBusGen.hr_on) annotation (Line(points={{44.8,89.6},{22,89.6},
          {22,98},{2,98}},       color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(sigBusGen.hr_on, isOnHR.u) annotation (Line(
      points={{2,98},{2,60},{46,60},{46,43.2},{40,43.2}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(isOnHR.y, or1.u1) annotation (Line(points={{40,29.4},{46,29.4},{46,
          21.2}}, color={255,0,255}));
  connect(sigBusGen.weaBus.TDryBul, solarThermal.T_air) annotation (Line(
      points={{2,98},{-158,98},{-158,-92},{-42,-92}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(sigBusGen.weaBus.HGloHor, solarThermal.Irradiation) annotation (Line(
      points={{2,98},{-170,98},{-170,-86},{-42,-86}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(hea.port_b, portGen_out[1]) annotation (Line(points={{80,80},{90,80},{
          90,75},{100,75}}, color={0,127,255}));
  connect(pumpST.port_a, bou.ports[1]) annotation (Line(points={{38,-104},{54,-104},
          {54,-118}}, color={0,127,255}));
  connect(pumpST.port_b, solarThermal.port_a) annotation (Line(points={{18,-104},
          {-32,-104},{-32,-96}}, color={0,127,255}));
  connect(solarThermal.port_b, portGen_out[2]) annotation (Line(points={{-32,-76},
          {-32,-62},{132,-62},{132,85},{100,85}}, color={0,127,255}));
  connect(portGen_in[2], pumpST.port_a) annotation (Line(points={{100,3},{102,3},
          {102,-104},{38,-104}}, color={0,127,255}));
  connect(hea.Pel, outBusGen.PelHR) annotation (Line(points={{81.6,89.6},{140,89.6},
          {140,-86},{0,-86},{0,-100}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(pumpST.P, outBusGen.PelPumpST) annotation (Line(points={{17,-113},{0,
          -113},{0,-100}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(portGen_in[1], pumpHP.port_a) annotation (Line(points={{100,-7},{80,-7},
          {80,-50},{58,-50}}, color={0,127,255}));
  connect(pumpHP.port_b, heatPump.port_a1) annotation (Line(points={{38,-50},{
          10,-50},{10,-48},{-30.5,-48},{-30.5,-7}}, color={0,127,255}));
  connect(pumpHP.port_a, bou1.ports[1]) annotation (Line(points={{58,-50},{62,-50},
          {62,-64},{66,-64}}, color={0,127,255}));
  connect(switch1.y, pumpHP.y) annotation (Line(points={{46,-27},{46,-31.5},{48,
          -31.5},{48,-38}}, color={0,0,127}));
  connect(AirOrSoil1.y, pumpST.y) annotation (Line(points={{4.6,-132},{28,-132},
          {28,-116}}, color={0,0,127}));
  connect(pumpHP.P, outBusGen.PelPumpGen) annotation (Line(points={{37,-41},{26,
          -41},{26,-40},{0,-40},{0,-100}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
end ST_BivHP;
