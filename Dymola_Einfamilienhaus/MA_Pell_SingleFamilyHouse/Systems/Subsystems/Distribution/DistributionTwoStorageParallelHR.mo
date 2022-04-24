within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution;
model DistributionTwoStorageParallelHR
  "Model for the distribution of heat using two storages, one as buffer storage for buildings and the other for DHW demand. The devices are hydraulically modelled as in parallel"
  extends BaseClasses.PartialDistribution;

  Components.StorageHeatingRad storageHeatingRad(
    redeclare final package Medium = MediumDHW,
    layerHR=integer(dhwParameters.nLayer/2),
    final n=dhwParameters.nLayer,
    final d=(dhwParameters.V*4/(dhwParameters.storage_H_dia_ratio*Modelica.Constants.pi))
        ^(1/3),
    final h=dhwParameters.storage_H_dia_ratio*storageHeatingRad.d,
    final lambda_ins=dhwParameters.lambda_ins,
    final s_ins=dhwParameters.s_ins,
    final hConIn=dhwParameters.hConIn,
    final hConOut=dhwParameters.hConOut,
    final k_HE=dhwParameters.k_HE,
    final A_HE=dhwParameters.A_HE,
    final V_HE=dhwParameters.V_HE,
    final beta=dhwParameters.beta,
    final kappa=dhwParameters.kappa,
    final m_flow_nominal_layer=systemParameters.mTra_flow_nominal,
    final m_flow_nominal_HE=systemParameters.mGen_flow_nominal,
    final T_start=systemParameters.TWater_start)
    "The DHW storage (TWWS) for domestic hot water demand"
    annotation (Placement(transformation(extent={{66,-70},{32,-32}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperatureBuf(final T=
        systemParameters.TAmbInternal)
                                      annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=0,
        origin={44,6})));
  AixLib.Fluid.Storage.Storage storageBuf(
    redeclare package Medium = MediumBui,
    final n=bufParameters.nLayer,
    final d=bufParameters.d,
    final h=bufParameters.h,
    final lambda_ins=bufParameters.lambda_ins,
    final s_ins=bufParameters.s_ins,
    final hConIn=bufParameters.hConIn,
    final hConOut=bufParameters.hConOut,
    final k_HE=bufParameters.k_HE,
    final A_HE=bufParameters.A_HE,
    final V_HE=bufParameters.V_HE,
    final beta=bufParameters.beta,
    final kappa=bufParameters.kappa,
    final m_flow_nominal_layer=systemParameters.mTra_flow_nominal,
    final m_flow_nominal_HE=systemParameters.mGen_flow_nominal,
    final T_start=systemParameters.TWater_start)
                      "The buffer storage (PS) for the building"
    annotation (Placement(transformation(extent={{66,40},{32,76}})));
  Components.Valves.ArtificialThreeWayValve artificialThreeWayValve(
      redeclare final package Medium = MediumGen, p_hydr=systemParameters.pHyd)
    annotation (Placement(transformation(extent={{-68,36},{-18,80}})));
  Modelica.Blocks.Sources.RealExpression T_stoDHWTop(y=storageHeatingRad.layer[
        dhwParameters.nLayer].T) annotation (Placement(transformation(
        extent={{-5,-3},{5,3}},
        rotation=180,
        origin={37,87})));
  Modelica.Blocks.Sources.RealExpression T_stoBufTop(y=storageBuf.layer[
        bufParameters.nLayer].T) annotation (Placement(transformation(
        extent={{-5,-2},{5,2}},
        rotation=180,
        origin={23,92})));
  Modelica.Blocks.Sources.RealExpression T_stoBufBot(y=storageBuf.layer[1].T)
    annotation (Placement(transformation(
        extent={{-5,-3},{5,3}},
        rotation=180,
        origin={23,87})));
  Modelica.Blocks.Sources.RealExpression T_stoDHWBot(y=storageHeatingRad.layer[1].T)
    annotation (Placement(transformation(
        extent={{-5,-3},{5,3}},
        rotation=180,
        origin={35,93})));

  replaceable
    RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition
    bufParameters constrainedby
    RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition(
      final Q_flow_nominal=systemParameters.QDemBuiSum_flow*systemParameters.fDesTra
        *systemParameters.fDesDis) annotation (choicesAllMatching=true,
      Placement(transformation(extent={{84,56},{98,70}})));
  replaceable
    RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition
    dhwParameters constrainedby
    RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition(
      final Q_flow_nominal=systemParameters.QDemDHW_flow) annotation (
      choicesAllMatching=true, Placement(transformation(extent={{82,-58},{98,-42}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperatureDHW(final T=
        systemParameters.TAmbInternal)
                                      annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={30,-90})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow
                                                         prescribedHeatFlow               annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=0,
        origin={-12,-56})));
  Modelica.Blocks.Logical.Switch switch2 annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-48,-56})));
  Modelica.Blocks.Sources.Constant const_dhwHROff(final k=0) annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={-86,-64})));
  Modelica.Blocks.Sources.Constant const_dhwHROn(k=QHR_flow_nominal)
    annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={-86,-42})));
  parameter Real QHR_flow_nominal "Constant output value";
equation
  connect(fixedTemperatureBuf.port, storageBuf.heatPort) annotation (Line(
        points={{56,6},{80,6},{80,58},{62.6,58}}, color={191,0,0}));
  connect(storageBuf.port_b_consumer, portBui_out) annotation (Line(points={{49,76},
          {50,76},{50,80},{100,80}},     color={0,127,255}));
  connect(storageBuf.port_a_consumer, portBui_in) annotation (Line(points={{49,40},
          {100,40}},                 color={0,127,255}));
  connect(storageHeatingRad.port_b_consumer, portDHW_out) annotation (Line(
        points={{49,-32},{48,-32},{48,-22},{100,-22}}, color={0,127,255}));
  connect(portDHW_in, storageHeatingRad.port_a_consumer) annotation (Line(
        points={{100,-82},{48,-82},{48,-70},{49,-70}}, color={0,127,255}));
  connect(artificialThreeWayValve.port_buf_b, storageBuf.port_a_heatGenerator)
    annotation (Line(points={{-18,74.72},{8,74.72},{8,73.84},{34.72,73.84}},
        color={0,127,255}));
  connect(artificialThreeWayValve.port_buf_a, storageBuf.port_b_heatGenerator)
    annotation (Line(points={{-18,65.92},{8,65.92},{8,43.6},{34.72,43.6}},
        color={0,127,255}));
  connect(artificialThreeWayValve.port_dhw_b, storageHeatingRad.port_a_heatGenerator)
    annotation (Line(points={{-18,49.2},{-10,49.2},{-10,46},{8,46},{8,-34.28},{34.72,
          -34.28}}, color={0,127,255}));
  connect(artificialThreeWayValve.port_dhw_a, storageHeatingRad.port_b_heatGenerator)
    annotation (Line(points={{-18,40.4},{-16,40.4},{-16,36},{8,36},{8,-66.2},{34.72,
          -66.2}}, color={0,127,255}));
  connect(sigBusDistr.dhw_on, artificialThreeWayValve.dhw_on) annotation (Line(
      points={{0.12,101.105},{-14,101.105},{-14,102},{-22,102},{-22,84.4},{-43,
          84.4}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(T_stoDHWBot.y, sigBusDistr.T_StoDHW_bot) annotation (Line(points={{29.5,93},
          {2.5,93},{2.5,101.105},{0.12,101.105}},       color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(T_stoDHWTop.y, sigBusDistr.T_StoDHW_top) annotation (Line(points={{31.5,87},
          {-2,87},{-2,101.105},{0.12,101.105}},       color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(T_stoBufBot.y, sigBusDistr.T_StoBuf_bot) annotation (Line(points={{17.5,87},
          {0.12,87},{0.12,101.105}},                color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(T_stoBufTop.y, sigBusDistr.T_StoBuf_top) annotation (Line(points={{17.5,92},
          {0,92},{0,101.105},{0.12,101.105}},                   color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(fixedTemperatureDHW.port, storageHeatingRad.heatPort) annotation (
      Line(points={{40,-90},{70,-90},{70,-51},{62.6,-51}}, color={191,0,0}));
  connect(switch2.u2, sigBusDistr.dhwHR_on) annotation (Line(points={{-60,-56},{
          -94,-56},{-94,-52},{-112,-52},{-112,101.105},{0.12,101.105}},   color=
         {255,0,255}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(switch2.y, prescribedHeatFlow.Q_flow) annotation (Line(points={{-37,-56},
          {-30,-56},{-30,-56},{-24,-56}}, color={0,0,127}));
  connect(prescribedHeatFlow.port, storageHeatingRad.heatPortHeatingRod)
    annotation (Line(points={{0,-56},{16,-56},{16,-51},{34.04,-51}}, color={191,
          0,0}));
  connect(const_dhwHROn.y, switch2.u1) annotation (Line(points={{-79.4,-42},{-72,
          -42},{-72,-48},{-60,-48}}, color={0,0,127}));
  connect(const_dhwHROff.y, switch2.u3) annotation (Line(points={{-79.4,-64},{-70,
          -64},{-70,-64},{-60,-64}}, color={0,0,127}));
  connect(portGen_in[1], artificialThreeWayValve.port_a) annotation (Line(
        points={{-100,80},{-86,80},{-86,66.8},{-68,66.8}}, color={0,127,255}));
  connect(portGen_out[1], artificialThreeWayValve.port_b) annotation (Line(
        points={{-100,40},{-84,40},{-84,49.2},{-68,49.2}}, color={0,127,255}));
end DistributionTwoStorageParallelHR;
