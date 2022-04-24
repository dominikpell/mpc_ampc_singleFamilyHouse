within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Transfer;
model RadiatorTransferSystem
  "Subsystem using a radiator as a tranfer model"
  extends BaseClasses.PartialTransfer(outBusTra(nZones=systemParameters.nZones));

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
    TAir_nominal=systemParameters.TSetRoomConst,
    TRad_nominal=systemParameters.TSetRoomConst,
    each final n=radParameters.n,
    each final deltaM=0.3,
    each final dp_nominal=0,
    redeclare package Medium = Medium,
    each final T_start=systemParameters.TWater_start,
    each final T_b_nominal=systemParameters.T_b_nominal) "Radiator" annotation (
     Placement(transformation(
        extent={{11,11},{-11,-11}},
        rotation=90,
        origin={-13,-29})));

  AixLib.Fluid.FixedResistances.PressureDrop res1[systemParameters.nZones](
    redeclare package Medium = Medium,
    each final dp_nominal=1,
    final m_flow_nominal=rad.m_flow_nominal) "Hydraulic resistance of supply"
    annotation (Placement(transformation(
        extent={{-12.5,-13.5},{12.5,13.5}},
        rotation=0,
        origin={-38.5,39.5})));
  Components.Control.ThermostaticValvePIControlled thermostaticValvePIControlled[
    systemParameters.nZones](
    each TRoomSet=systemParameters.TSetRoomSchedule,
    leakageOpening=thermostaticValveParameters.leakageOpening,
    each final k=thermostaticValveParameters.k,
    each final Ti=thermostaticValveParameters.Ti) annotation (Placement(
        transformation(
        extent={{-26,-18},{26,18}},
        rotation=180,
        origin={46,66})));
  Components.Pumps.ArtificalPumpIsotermhal artificalPumpIsotermhal1[
    systemParameters.nZones](
    redeclare package Medium = Medium,
    allowFlowReversal=systemParameters.allowFlowReversal,
    each final p=systemParameters.pHyd,
    final m_flow_nominal=rad.m_flow_nominal) annotation (Placement(
        transformation(
        extent={{-11,-11},{11,11}},
        rotation=270,
        origin={-13,3})));
  Modelica.Blocks.Math.Gain gain[systemParameters.nZones](k=rad.m_flow_nominal)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={8,34})));

  RecordsCollection.TransferData.RadiatorTransferData radParameters
    annotation (Placement(transformation(extent={{-100,-98},{-80,-78}})));
  RecordsCollection.TransferData.ThermostaticValveDataDefinition
    thermostaticValveParameters
    annotation (Placement(transformation(extent={{44,88},{64,108}})));
equation
  connect(rad.heatPortRad, heatPortRad) annotation (Line(points={{-5.08,-31.2},
          {40,-31.2},{40,-40},{100,-40}}, color={191,0,0}));
  connect(rad.heatPortCon, heatPortCon) annotation (Line(points={{-5.08,-26.8},
          {-5.08,-26},{40,-26},{40,40},{100,40}},  color={191,0,0}));

  for i in 1:systemParameters.nZones loop
    connect(rad[i].port_b, portTra_out) annotation (Line(points={{-13,-40},{-13,-42},
          {-100,-42}}, color={0,127,255}));
   connect(portTra_in, res1[i].port_a) annotation (Line(points={{-100,38},{-76,38},
          {-76,39.5},{-51,39.5}}, color={0,127,255}));
  end for;
  connect(thermostaticValvePIControlled.TRoom, TZone) annotation (Line(points={{77.2,66},
          {94,66},{94,84},{110,84}},        color={0,0,127}));
  connect(res1.port_b, artificalPumpIsotermhal1.port_a) annotation (Line(points=
         {{-26,39.5},{-13,39.5},{-13,14}}, color={0,127,255}));
  connect(artificalPumpIsotermhal1.port_b, rad.port_a)
    annotation (Line(points={{-13,-8},{-13,-8},{-13,-18}}, color={0,127,255}));
  connect(gain.y, artificalPumpIsotermhal1.m_flow_in)
    annotation (Line(points={{8,23},{8,3},{-0.24,3}}, color={0,0,127}));
  connect(gain.u, thermostaticValvePIControlled.opening)
    annotation (Line(points={{8,46},{8,66},{14.8,66}},
                                                     color={0,0,127}));

  connect(TZone, outBusTra.TZone) annotation (Line(points={{110,84},{86,84},{86,
          -60},{22,-60},{22,-95.6},{11,-95.6}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
end RadiatorTransferSystem;
