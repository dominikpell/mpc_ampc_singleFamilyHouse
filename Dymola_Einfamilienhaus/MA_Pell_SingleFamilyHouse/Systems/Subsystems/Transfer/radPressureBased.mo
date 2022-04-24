within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Transfer;
model radPressureBased "Pressure Based transfer system"
  extends BaseClasses.PartialTransfer;

  AixLib.Fluid.HeatExchangers.Radiators.RadiatorEN442_2 rad[systemParameters.nZones](
    allowFlowReversal=systemParameters.allowFlowReversal,
    show_T=systemParameters.show_T,
    each final energyDynamics=systemParameters.energyDynamics,
    massDynamics=systemParameters.massDynamics,
    each final p_start=systemParameters.pHyd,
    each final nEle=radParameters.nEle,
    each final fraRad=radParameters.fraRad,
    final Q_flow_nominal=systemParameters.QBui_flow_nominal*systemParameters.fDesTra,
    each final T_a_nominal(displayUnit="degC") = systemParameters.T_a_nominal,
    final TAir_nominal=systemParameters.TSetRoomConst,
    final TRad_nominal=systemParameters.TSetRoomConst,
    each final n=radParameters.n,
    each final deltaM=0.3,
    each final dp_nominal=0,
    redeclare package Medium = Medium,
    each final T_start=systemParameters.TWater_start,
    each final T_b_nominal=systemParameters.T_b_nominal)
                                                  "Radiator" annotation (Placement(
        transformation(
        extent={{11,11},{-11,-11}},
        rotation=90,
        origin={-13,-29})));
  AixLib.Fluid.FixedResistances.PressureDrop res1[systemParameters.nZones](
    redeclare package Medium = Medium,
    each final dp_nominal=thermostaticValveParameters.dpFixed_nominal,
    final m_flow_nominal=rad.m_flow_nominal) "Hydraulic resistance of supply"
    annotation (Placement(transformation(
        extent={{-12.5,-13.5},{12.5,13.5}},
        rotation=0,
        origin={-34.5,37.5})));
  Components.Control.ThermostaticValvePIControlled thermostaticValvePIControlled[
    systemParameters.nZones](
    each final TRoomSet=systemParameters.TSetRoomSchedule,
    each final leakageOpening=thermostaticValveParameters.leakageOpening,
    each final k=thermostaticValveParameters.k,
    each final Ti=thermostaticValveParameters.Ti) annotation (Placement(
        transformation(
        extent={{-19,-17},{19,17}},
        rotation=180,
        origin={39,67})));
  AixLib.Fluid.Actuators.Valves.TwoWayLinear val[systemParameters.nZones](
    redeclare package Medium = Medium,
    each final allowFlowReversal=systemParameters.allowFlowReversal,
    final m_flow_nominal=rad.m_flow_nominal,
    each final show_T=systemParameters.show_T,
    each final CvData=AixLib.Fluid.Types.CvTypes.OpPoint,
    each final dpValve_nominal=thermostaticValveParameters.dpValve_nominal,
    each final use_inputFilter=false,
    each final dpFixed_nominal=thermostaticValveParameters.dpFixed_nominal,
    each final l=thermostaticValveParameters.leakageOpening)
                                            annotation (Placement(transformation(
        extent={{-10,-11},{10,11}},
        rotation=270,
        origin={-14,3})));

  AixLib.Fluid.MixingVolumes.MixingVolume
                                   vol1(
    redeclare package Medium = Medium,
    m_flow_nominal=sum(rad.m_flow_nominal),
    V(displayUnit="l") = 0.005,
    nPorts=1+systemParameters.nZones)                                    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-58,18})));
  AixLib.Fluid.Movers.SpeedControlled_y     pump(
    redeclare final package Medium = Medium,
    final energyDynamics=systemParameters.energyDynamics,
    final massDynamics=systemParameters.massDynamics,
    final p_start=systemParameters.pHyd,
    final T_start=systemParameters.TWater_start,
    final allowFlowReversal=systemParameters.allowFlowReversal,
    final show_T=systemParameters.show_T,
    redeclare RecordsCollection.Movers.AutomaticConfigurationData per(
      final speed_rpm_nominal=systemParameters.speed_rpm_nominal,
      final m_flow_nominal=systemParameters.mTra_flow_nominal,
      dp_nominal=sum(rad.dp_nominal) + sum(val.dpValve_nominal),
      final rho=systemParameters.rhoWater,
      final V_flowCurve=systemParameters.V_flowCurve,
      final dpCurve=systemParameters.dpCurve),
    final inputType=AixLib.Fluid.Types.InputType.Continuous,
    final addPowerToMedium=systemParameters.addPowerToMedium,
    final tau=systemParameters.tauMover,
    final use_inputFilter=systemParameters.use_inputFilterMovers,
    final riseTime=systemParameters.riseTimeMoverInpFilter,
    final init=Modelica.Blocks.Types.Init.InitialOutput,
    final y_start=1)                                    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-74,38})));

  Modelica.Blocks.Sources.Constant m_flow1(k=1)   annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-48,68})));
  RecordsCollection.TransferData.ThermostaticValveDataDefinition
    thermostaticValveParameters
    annotation (Placement(transformation(extent={{22,82},{42,102}})));
  RecordsCollection.TransferData.RadiatorTransferData radParameters
    annotation (Placement(transformation(extent={{-244,-278},{-224,-258}})));
  RecordsCollection.TransferData.RadiatorTransferData radParameters1
    annotation (Placement(transformation(extent={{-100,-98},{-80,-78}})));
equation
  connect(rad.heatPortRad, heatPortRad) annotation (Line(points={{-5.08,-31.2},
          {40,-31.2},{40,-40},{100,-40}}, color={191,0,0}));
  connect(rad.heatPortCon, heatPortCon) annotation (Line(points={{-5.08,-26.8},
          {-5.08,-26},{40,-26},{40,40},{100,40}},  color={191,0,0}));

  for i in 1:systemParameters.nZones loop
    connect(rad[i].port_b, portTra_out) annotation (Line(points={{-13,-40},{-13,-42},
          {-100,-42}}, color={0,127,255}));
  end for;
  connect(thermostaticValvePIControlled.TRoom, TZone) annotation (Line(points={{61.8,67},
          {94,67},{94,84},{110,84}},        color={0,0,127}));

  connect(thermostaticValvePIControlled.opening, val.y) annotation (Line(points={{16.2,67},
          {8,67},{8,3},{-0.8,3}},           color={0,0,127}));
  connect(val.port_b, rad.port_a) annotation (Line(points={{-14,-7},{-14,-13.5},
          {-13,-13.5},{-13,-18}}, color={0,127,255}));
  connect(res1.port_b, val.port_a) annotation (Line(points={{-22,37.5},{-14,37.5},
          {-14,13}}, color={0,127,255}));
  connect(portTra_in,pump. port_a)
    annotation (Line(points={{-100,38},{-84,38}}, color={0,127,255}));
  connect(pump.port_b, vol1.ports[1]) annotation (Line(points={{-64,38},{-62,38},
          {-62,28},{-58,28}}, color={0,127,255}));
  for i in 1:systemParameters.nZones loop
   connect(res1[i].port_a, vol1.ports[i+1]) annotation (Line(points={{-47,
          37.5},{-56,37.5},{-56,28},{-58,28}},
                              color={0,127,255}));
  end for;
  connect(m_flow1.y,pump. y)
    annotation (Line(points={{-59,68},{-74,68},{-74,50}}, color={0,0,127}));
end radPressureBased;
