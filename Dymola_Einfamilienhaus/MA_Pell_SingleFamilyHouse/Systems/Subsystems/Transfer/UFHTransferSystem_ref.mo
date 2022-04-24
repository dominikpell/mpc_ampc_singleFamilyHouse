within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Transfer;
model UFHTransferSystem_ref
  extends Transfer.BaseClasses.PartialTransfer(outBusTra(nZones=
          systemParameters.nZones));

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
        origin={48,80})));

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
        origin={-14,-58})));
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
    k_top=fill(15.47, systemParameters.nZones),
      C_ActivatedElement=systemParameters.C_ActivatedElement)
    annotation (Placement(transformation(extent={{22,12},{42,32}})));
protected
    parameter Modelica.SIunits.MassFlowRate m_flow_nominal[systemParameters.nZones]=
      systemParameters.QBui_flow_nominal/(systemParameters.c_pWater*(systemParameters.T_a_nominal- systemParameters.T_b_nominal))
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
        C_ActivatedElement=UFHParameters.C_ActivatedElement[i]/systemParameters.AFloor_UFH[1],
        c_top_ratio=UFHParameters.c_top_ratio[i],
        PressureDropExponent=0,
        PressureDropCoefficient=0,
        diameter=UFHParameters.diameter) for i in 1:systemParameters.nZones};

equation
  connect(TZone,thermostaticValvePControlled. TRoom)
    annotation (Line(points={{110,84},{82,84},{82,80},{62.4,80}},
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
  connect(sum2.y, QUFH_Loss) annotation (Line(points={{-3,-58},{28,-58},{28,-60},
          {88,-60},{88,-82},{112,-82}}, color={0,0,127}));
  connect(heatFlowSensor.Q_flow, sum2.u) annotation (Line(points={{-46,-16},{-46,
          -54},{-26,-54},{-26,-58}}, color={0,0,127}));

  connect(gain.u, thermostaticValvePControlled.opening) annotation (Line(points=
         {{-28,84},{-28,94},{4,94},{4,80},{33.6,80}}, color={0,0,127}));
end UFHTransferSystem_ref;
