within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Transfer;
model UFHTransferSystem_Laura
      extends BaseClasses.PartialTransfer(outBusTra(nZones=systemParameters.nZones));

  Components.Control.ThermostaticValvePControlled thermostaticValvePControlled[
    systemParameters.nZones](
    each final T_RoomSet=systemParameters.TSetRoomConst,
    each final Kvs=thermostaticValveParas.Kvs,
    each final Kv_setT=thermostaticValveParas.Kv_setT,
    each final P=thermostaticValveParas.P,
    each final leakageOpening=thermostaticValveParas.leakageOpening)
    annotation (Placement(transformation(
        extent={{-12,-14},{12,14}},
        rotation=180,
        origin={48,88})));

  AixLib.Fluid.FixedResistances.PressureDrop res1[systemParameters.nZones](
    redeclare package Medium = Medium,
    each final dp_nominal=1,
    final m_flow_nominal=m_flow_nominal)     "Hydraulic resistance of supply"
    annotation (Placement(transformation(
        extent={{-10.5,-12},{10.5,12}},
        rotation=0,
        origin={-64.5,38})));

  Modelica.Blocks.Math.Gain gain[systemParameters.nZones](k=m_flow_nominal)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-28,72})));
  Components.Pumps.ArtificalPumpIsotermhal artificalPumpIsotermhal1[
    systemParameters.nZones](
    redeclare package Medium = Medium,
    each final p=systemParameters.pHyd,
    final m_flow_nominal=m_flow_nominal) annotation (Placement(transformation(
        extent={{-11,-11},{11,11}},
        rotation=0,
        origin={-27,39})));
  Components.UFH.PanelHeating                          panelHeating[systemParameters.nZones](
    redeclare package Medium = Medium,
    floorHeatingType=floorHeatingType,
    Spacing=0.2,
    each dis=1,
    A={systemParameters.AFloor_UFH[i] for i in 1:systemParameters.nZones},
    each T0=systemParameters.TAir_start,
    calcMethod=1)   annotation (Placement(transformation(
        extent={{-23,-10},{23,10}},
        rotation=270,
        origin={5,-2})));

  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature
                                                      fixedTemperature
                                                                   [systemParameters.nZones](final T=
        UFHParameters.T_floor)
               annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-90,10})));
  Modelica.Thermal.HeatTransfer.Sensors.HeatFlowSensor heatFlowSensor
                                                                   [systemParameters.nZones]
               annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-46,-6})));
  Modelica.Blocks.Continuous.Integrator sum2[systemParameters.nZones] annotation (
      Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={22,-48})));
  Modelica.Blocks.Interfaces.RealOutput QUFH_Loss[systemParameters.nZones]
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={112,-82})));
  Modelica.Thermal.HeatTransfer.Sources.FixedHeatFlow fixedHeatFlow[systemParameters.nZones](final
      Q_flow=0)
               annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-92,-20})));
  Modelica.Thermal.HeatTransfer.Components.HeatCapacitor
                                                      heatCapacitor[systemParameters.nZones](C=
        systemParameters.C_ActivatedElement)
               annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-114,2})));

  RecordsCollection.TransferData.ThermostaticValveDataDefinition
    thermostaticValveParas
    annotation (Placement(transformation(extent={{46,46},{66,66}})));
  RecordsCollection.TransferData.UFHData UFHParameters(nZones=systemParameters.nZones,
    k_top=fill(100, systemParameters.nZones),
      C_ActivatedElement=systemParameters.C_ActivatedElement/systemParameters.AFloor_UFH[
        1])
    annotation (Placement(transformation(extent={{22,12},{42,32}})));
  Modelica.Blocks.Sources.RealExpression feedback_TZone(y=TZone[1])
    annotation (Placement(transformation(extent={{-100,-96},{-78,-86}})));
  Modelica.Blocks.Sources.RealExpression feedback_m_flow_UFH(y=
        artificalPumpIsotermhal1[1].m_flow_in)
    annotation (Placement(transformation(extent={{-100,-104},{-78,-92}})));
  Modelica.Blocks.Sources.RealExpression feedbac_T_supply_UFH(y=panelHeating[1].TFlow.T)
    annotation (Placement(transformation(extent={{-100,-88},{-78,-78}})));
  Modelica.Blocks.Sources.RealExpression feedback_T_return_UFH(y=panelHeating[1].TReturn.T)
    annotation (Placement(transformation(extent={{-100,-80},{-78,-68}})));
  Modelica.Blocks.Sources.RealExpression feedback_T_thermalCapDown(y=
        panelHeating[1].panelHeatingSegment[1].panel_Segment2.heatCapacitor.T)
    annotation (Placement(transformation(extent={{-100,-72},{-78,-60}})));
  Modelica.Blocks.Sources.RealExpression Q_rad_UFH(y=-heatPortRad[1].Q_flow)
    annotation (Placement(transformation(extent={{40,-80},{26,-66}})));
  Modelica.Blocks.Sources.RealExpression Q_conv_UFH(y=-heatPortCon[1].Q_flow)
    annotation (Placement(transformation(extent={{40,-90},{26,-76}})));
  Modelica.Blocks.Sources.RealExpression T_panelHeating(y=panelHeating[1].panelHeatingSegment[
        1].panel_Segment1.thermalConductor2.port_b.T)
    annotation (Placement(transformation(extent={{42,-96},{24,-86}})));
  Modelica.Blocks.Sources.RealExpression feedback_T_thermalCapTop(y=
        panelHeating[1].panelHeatingSegment[1].panel_Segment1.heatCapacitor.T)
    annotation (Placement(transformation(extent={{-100,-62},{-78,-50}})));
  Modelica.Blocks.Logical.Switch switchTransfer[systemParameters.nZones]
    annotation (Placement(transformation(extent={{-62,84},{-50,96}})));
  Modelica.Blocks.Sources.Constant TransferOn[systemParameters.nZones](k=1)
    annotation (Placement(transformation(extent={{-78,98},{-70,106}})));
  Modelica.Blocks.Sources.Constant TransferOff[systemParameters.nZones](k=0)
    annotation (Placement(transformation(extent={{-76,74},{-68,82}})));
  Modelica.Blocks.Sources.RealExpression ch_Buf(y=panelHeating[1].TFlow.T)
    annotation (Placement(transformation(
        extent={{3,-7},{-3,7}},
        rotation=180,
        origin={-97,69})));
  Modelica.Blocks.Sources.BooleanExpression booleanHeatORCool(y=panelHeating[1].TFlow.T
         > panelHeating[1].TReturn.T)
    annotation (Placement(transformation(extent={{-100,50},{-92,58}})));
  Modelica.Blocks.Sources.RealExpression T_panelHeating1(y=
        artificalPumpIsotermhal1[1].m_flow_in*systemParameters.c_pWater*(
        outBusTra.T_supply_UFH - outBusTra.T_return_UFH))
    annotation (Placement(transformation(extent={{50,-108},{32,-98}})));
protected
    parameter Modelica.SIunits.MassFlowRate m_flow_nominal[systemParameters.nZones]=
      systemParameters.QBui_flow_nominal/(systemParameters.c_pWater*(systemParameters.TSup_nominal - systemParameters.TRet_nominal))
    "Nominal mass flow rate, used for regularization near zero flow";

protected
  parameter MA_Pell_SingleFamilyHouse.Components.UFH.ActiveWallBaseDataDefinition floorHeatingType[systemParameters.nZones]={MA_Pell_SingleFamilyHouse.Components.UFH.ActiveWallBaseDataDefinition(
        Temp_nom=Modelica.SIunits.Conversions.from_degC({systemParameters.TSup_nominal,
          systemParameters.TRet_nominal,systemParameters.TSetRoomConst}),
        q_dot_nom=systemParameters.QBui_flow_nominal[i] / systemParameters.area[i],
        k_isolation=UFHParameters.k_top[i] + UFHParameters.k_down[i],
        k_top=UFHParameters.k_top[i],
        k_down=UFHParameters.k_down[i],
        VolumeWaterPerMeter=0.01,
        eps=0.9,
        C_ActivatedElement=UFHParameters.C_ActivatedElement[i],
        c_top_ratio=UFHParameters.c_top_ratio[i],
        PressureDropExponent=0,
        PressureDropCoefficient=0,
        diameter=UFHParameters.diameter) for i in 1:systemParameters.nZones};

equation
  connect(TZone,thermostaticValvePControlled. TRoom)
    annotation (Line(points={{110,84},{86,84},{86,88},{62.4,88}},
                                                        color={0,0,127}));

  for i in 1:systemParameters.nZones loop
    connect(res1[i].port_a, portTra_in)
    annotation (Line(points={{-75,38},{-100,38}}, color={0,127,255}));
    connect(panelHeating[i].port_b, portTra_out) annotation (Line(points={{3.33333,
            -25},{3.33333,-42},{-100,-42}},
                                          color={0,127,255}));
  if systemParameters.is_groundFloor[i] then
   connect(fixedHeatFlow[i].port, heatCapacitor[i].port) annotation (Line(points=
         {{-82,-20},{-76,-20},{-76,-8},{-114,-8}}, color={191,0,0}));
   connect(fixedTemperature[i].port, heatFlowSensor[i].port_a) annotation (Line(
      points={{-80,10},{-64,10},{-64,-6},{-56,-6}},
      color={191,0,0},
      pattern=LinePattern.Dash));
  else
   connect(fixedHeatFlow[i].port, heatFlowSensor[i].port_a) annotation (Line(
      points={{-82,-20},{-66,-20},{-66,-6},{-56,-6}},
      color={191,0,0},
      pattern=LinePattern.Dash));
   connect(fixedTemperature[i].port, heatCapacitor[i].port) annotation (Line(
      points={{-80,10},{-80,-8},{-114,-8}},
      color={191,0,0},
      pattern=LinePattern.Dash));
  end if;
  end for;

  connect(res1.port_b, artificalPumpIsotermhal1.port_a) annotation (Line(points=
         {{-54,38},{-48,38},{-48,37},{-38,37},{-38,39}}, color={0,127,255}));
  connect(gain.y, artificalPumpIsotermhal1.m_flow_in) annotation (Line(points={{
          -28,61},{-28,55.5},{-27,55.5},{-27,51.76}}, color={0,0,127}));
  connect(artificalPumpIsotermhal1.port_b, panelHeating.port_a) annotation (
      Line(points={{-16,39},{-8,39},{-8,38},{3.33333,38},{3.33333,21}}, color={0,
          127,255}));

  connect(panelHeating.thermConv, heatPortCon) annotation (Line(points={{16.6667,
          -5.22},{52,-5.22},{52,42},{100,42},{100,40}}, color={191,0,0}));
  connect(panelHeating.starRad, heatPortRad) annotation (Line(points={{16,0.76},
          {40,0.76},{40,-40},{100,-40}},  color={0,0,0}));

  connect(heatFlowSensor.port_b, panelHeating.ThermDown) annotation (Line(
        points={{-36,-6},{-22,-6},{-22,-3.84},{-6,-3.84}}, color={191,0,0}));
  connect(sum2.y, QUFH_Loss) annotation (Line(points={{33,-48},{28,-48},{28,-60},
          {88,-60},{88,-82},{112,-82}}, color={0,0,127}));
  connect(heatFlowSensor.Q_flow, sum2.u) annotation (Line(points={{-46,-16},{-46,
          -54},{10,-54},{10,-48}},   color={0,0,127}));

  connect(feedback_TZone.y, outBusTra.TZone[1]) annotation (Line(points={{-76.9,
          -91},{11,-91},{11,-95.6}}, color={0,0,127}));
  connect(feedback_T_thermalCapTop.y, outBusTra.T_thermalCapacity_top)
    annotation (Line(points={{-76.9,-56},{-70,-56},{-70,-60},{0.05,-60},{0.05,-103.95}},
                     color={0,0,127}));
  connect(feedback_T_thermalCapDown.y, outBusTra.T_thermalCapacity_down)
    annotation (Line(points={{-76.9,-66},{-46,-66},{-46,-68},{0.05,-68},{0.05,-103.95}},
                     color={0,0,127}));
  connect(feedback_T_return_UFH.y, outBusTra.T_return_UFH) annotation (Line(
        points={{-76.9,-74},{0.05,-74},{0.05,-103.95}}, color={0,0,127}));
  connect(feedbac_T_supply_UFH.y, outBusTra.T_supply_UFH) annotation (Line(
        points={{-76.9,-83},{0.05,-83},{0.05,-103.95}}, color={0,0,127}));
  connect(Q_rad_UFH.y, outBusTra.Q_rad_UFH) annotation (Line(points={{25.3,-73},
          {0.05,-73},{0.05,-103.95}}, color={0,0,127}));
  connect(Q_conv_UFH.y, outBusTra.Q_conv_UFH) annotation (Line(points={{25.3,-83},
          {0.05,-83},{0.05,-103.95}},      color={0,0,127}));
  connect(T_panelHeating.y, outBusTra.T_panel_heating1) annotation (Line(points={{23.1,
          -91},{0.05,-91},{0.05,-103.95}},       color={0,0,127}));
  connect(TransferOn.y,switchTransfer. u1) annotation (Line(points={{-69.6,102},
          {-66,102},{-66,94.8},{-63.2,94.8}},color={0,0,127}));
  connect(TransferOff.y,switchTransfer. u3) annotation (Line(points={{-67.6,78},
          {-66,78},{-66,85.2},{-63.2,85.2}}, color={0,0,127}));
  connect(switchTransfer.y, gain.u) annotation (Line(points={{-49.4,90},{-28,90},
          {-28,84}},                   color={0,0,127}));
  connect(traControlBus.transfer_active,switchTransfer. u2) annotation (Line(
      points={{-100.935,83.085},{-90,83.085},{-90,90},{-63.2,90}},
      color={255,204,51},
      thickness=0.5));
  connect(ch_Buf.y, traControlBus.T_supply_UFH_Mea) annotation (Line(points={{-93.7,
          69},{-86,69},{-86,83.085},{-100.935,83.085}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(booleanHeatORCool.y, traControlBus.SupplyGreaterReturn) annotation (
      Line(points={{-91.6,54},{-84,54},{-84,83.085},{-100.935,83.085}}, color={255,
          0,255}));
  connect(T_panelHeating1.y, outBusTra.dch_TES) annotation (Line(points={{31.1,
          -103},{11.55,-103},{11.55,-103.95},{0.05,-103.95}}, color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
end UFHTransferSystem_Laura;
