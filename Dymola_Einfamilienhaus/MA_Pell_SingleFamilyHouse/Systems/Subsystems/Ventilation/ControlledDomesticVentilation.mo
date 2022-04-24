within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Ventilation;
model ControlledDomesticVentilation "Controlled domestic ventilation model"
  extends BaseClasses.PartialVentilationSystem(final use_vent=true);
  AixLib.Fluid.HeatExchangers.ConstantEffectiveness hex(
    redeclare package Medium1 = MediumZone,
    redeclare package Medium2 = MediumZone,
    final allowFlowReversal1=systemParameters.allowFlowReversal,
    final allowFlowReversal2=systemParameters.allowFlowReversal,
    final m1_flow_nominal=systemParameters.mVent_flow_nominal,
    final m2_flow_nominal=systemParameters.mVent_flow_nominal,
    final dp1_nominal=parameters.dpHex_nominal,
    final dp2_nominal=parameters.dpHex_nominal,
    final eps=parameters.epsHex)
             annotation (Placement(transformation(extent={{30,-24},{-14,26}})));
  AixLib.Fluid.Sources.Boundary_pT bouSup(
    redeclare package Medium = MediumZone,
    final use_p_in=true,
    final use_T_in=true,
    final nPorts=1) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={76,16})));
  AixLib.Fluid.Movers.SpeedControlled_y fanFlow(
    redeclare final package Medium = MediumZone,
    final energyDynamics=systemParameters.energyDynamics,
    final massDynamics=systemParameters.massDynamics,
    final p_start=systemParameters.pAtm,
    final T_start=systemParameters.TAir_start,
    final allowFlowReversal=systemParameters.allowFlowReversal,
    final show_T=systemParameters.show_T,
    redeclare
      RecordsCollection.Movers.AutomaticConfigurationData
      per(
      m_flow_nominal=systemParameters.mVent_flow_nominal,
      dp_nominal=systemParameters.dpVent_nominal,
      rho(displayUnit="kg/m3") = systemParameters.rhoAir),
    final inputType=AixLib.Fluid.Types.InputType.Continuous,
    final addPowerToMedium=false,
    final tau=1,
    final use_inputFilter=false)  annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={-72,42})));
  Modelica.Blocks.Sources.Constant yFan(k=1)
    "Transform Volume l to massflowrate" annotation (Placement(transformation(
        extent={{-8,-8},{8,8}},
        rotation=180,
        origin={-54,68})));
  AixLib.Fluid.Sensors.TemperatureTwoPort
                             TExhOut(
    final initType=systemParameters.initTypeTempSensors,
    redeclare final package Medium = MediumZone,
    final allowFlowReversal=systemParameters.allowFlowReversal,
    final m_flow_small=1E-4*systemParameters.mVent_flow_nominal,
    final T_start=systemParameters.TAir_start,
    final tau=systemParameters.tauTempSensors,
    final m_flow_nominal=systemParameters.mVent_flow_nominal,
    final transferHeat=systemParameters.transferHeatTempSensors,
    TAmb=systemParameters.TAmbInternal,
    tauHeaTra=systemParameters.tauHeaTraTempSensors)
    "Temperature at exhaust outlet"                           annotation (
      Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=0,
        origin={46,-14})));
  AixLib.Fluid.Sensors.TemperatureTwoPort TExhIn(
    final initType=systemParameters.initTypeTempSensors,
    redeclare final package Medium = MediumZone,
    final allowFlowReversal=systemParameters.allowFlowReversal,
    final m_flow_small=1E-4*systemParameters.mVent_flow_nominal,
    final T_start=systemParameters.TAir_start,
    final tau=systemParameters.tauTempSensors,
    final m_flow_nominal=systemParameters.mVent_flow_nominal,
    final transferHeat=systemParameters.transferHeatTempSensors,
    TAmb=systemParameters.TAmbInternal,
    tauHeaTra=systemParameters.tauHeaTraTempSensors)
    "Temperature at exhaust inlet" annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=0,
        origin={-64,-40})));
  AixLib.Fluid.Sensors.TemperatureTwoPort
                             TSupOut(
    final initType=systemParameters.initTypeTempSensors,
    redeclare final package Medium = MediumZone,
    final allowFlowReversal=systemParameters.allowFlowReversal,
    final m_flow_small=1E-4*systemParameters.mVent_flow_nominal,
    final T_start=systemParameters.TAir_start,
    final tau=systemParameters.tauTempSensors,
    final m_flow_nominal=systemParameters.mVent_flow_nominal,
    final transferHeat=systemParameters.transferHeatTempSensors,
    final TAmb=systemParameters.TAmbInternal,
    final tauHeaTra=systemParameters.tauHeaTraTempSensors)
    "Temperature at supply outlet"                            annotation (
      Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={-36,42})));
  AixLib.Fluid.Sensors.TemperatureTwoPort TSupIn(
    final initType=systemParameters.initTypeTempSensors,
    redeclare final package Medium = MediumZone,
    final allowFlowReversal=systemParameters.allowFlowReversal,
    final m_flow_small=1E-4*systemParameters.mVent_flow_nominal,
    final T_start=systemParameters.TAir_start,
    final tau=systemParameters.tauTempSensors,
    final m_flow_nominal=systemParameters.mVent_flow_nominal,
    final transferHeat=systemParameters.transferHeatTempSensors,
    TAmb=systemParameters.TAmbInternal,
    tauHeaTra=systemParameters.tauHeaTraTempSensors)
    "Temperature at supply inlet" annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={46,16})));
  AixLib.Fluid.Sources.Boundary_pT bouExh(redeclare package Medium = MediumZone,
      nPorts=1) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={76,-14})));
equation
  connect(bouSup.p_in, inputScenBus.weaBus.pAtm) annotation (Line(points={{88,8},
          {112,8},{112,92},{1.075,92},{1.075,99.065}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(bouSup.T_in, inputScenBus.weaBus.TDryBul) annotation (Line(points={{88,
          12},{112,12},{112,92},{1.075,92},{1.075,99.065}}, color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(fanFlow.port_b, portVent_in) annotation (Line(points={{-82,42},{-100,
          42}},                color={0,127,255}));
  connect(yFan.y, fanFlow.y)
    annotation (Line(points={{-62.8,68},{-72,68},{-72,54}}, color={0,0,127}));
  connect(fanFlow.port_a, TSupOut.port_b)
    annotation (Line(points={{-62,42},{-46,42}}, color={0,127,255}));
  connect(hex.port_b1, TSupOut.port_a) annotation (Line(points={{-14,16},{-20,16},
          {-20,42},{-26,42}}, color={0,127,255}));
  connect(portVent_out, TExhIn.port_a)
    annotation (Line(points={{-100,-40},{-74,-40}}, color={0,127,255}));
  connect(hex.port_b2, TExhOut.port_a)
    annotation (Line(points={{30,-14},{36,-14}}, color={0,127,255}));
  connect(hex.port_a1, TSupIn.port_b)
    annotation (Line(points={{30,16},{36,16}}, color={0,127,255}));
  connect(TExhIn.port_b, hex.port_a2) annotation (Line(points={{-54,-40},{-26,-40},
          {-26,-14},{-14,-14}}, color={0,127,255}));
  connect(TSupOut.T, outBusVen.TSupOut) annotation (Line(points={{-36,53},{-36,62},
          {96,62},{96,-1},{102,-1}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(TSupIn.T, outBusVen.TSupIn) annotation (Line(points={{46,27},{46,36},{
          102,36},{102,-1}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(TExhOut.T, outBusVen.TExhOut) annotation (Line(points={{46,-25},{46,-56},
          {102,-56},{102,-1}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(TExhIn.T, outBusVen.TExhIn) annotation (Line(points={{-64,-51},{-64,-56},
          {102,-56},{102,-1}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(fanFlow.P, outBusVen.PVentSup) annotation (Line(points={{-83,51},{-83,
          84},{102,84},{102,-1}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(TSupIn.port_a, bouSup.ports[1])
    annotation (Line(points={{56,16},{62,16},{62,16},{66,16}},
                                               color={0,127,255}));
  connect(TExhOut.port_b, bouExh.ports[1])
    annotation (Line(points={{56,-14},{66,-14}}, color={0,127,255}));
end ControlledDomesticVentilation;
