within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution;
model DistributionTwoStorageParallel
  "Model for the distribution of heat using two storages, one as buffer storage for buildings and the other for DHW demand. The devices are hydraulically modelled as in parallel"
  extends BaseClasses.PartialDistribution;
  parameter Real t_TES=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  parameter Real t_DHW=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
  MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution.Storage storage_DHW(
    redeclare final package Medium = MediumDHW,
    final n=dhwParameters.nLayer,
    final d=dhwParameters.d,
    final h=dhwParameters.h,
    final lambda_ins=dhwParameters.lambda_ins,
    final s_ins=dhwParameters.s_ins,
    final hConIn=dhwParameters.hConIn,
    final hConOut=dhwParameters.hConOut,
    final k_HE=dhwParameters.k_HE,
    final A_HE=dhwParameters.A_HE,
    final V_HE=dhwParameters.V_HE,
    final beta=dhwParameters.beta,
    final kappa=dhwParameters.kappa,
    T_start_layers=systemParameters.T_start_layersDHW,
    T_start_layers_HE=systemParameters.T_start_layers_HE_DHW,
    final m_flow_nominal_layer=systemParameters.mGen_flow_nominal,
    final m_flow_nominal_HE=systemParameters.mGen_flow_nominal,
    final T_start=t_DHW) "The DHW storage (TWWS) for domestic hot water demand"
    annotation (Placement(transformation(extent={{66,-70},{32,-32}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperatureBuf(final T=
        systemParameters.TAmbInternal)           annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={84,8})));
  Storage_TES_korr                                                  storage_TES_korr(
    redeclare package Medium = MediumBui,
    final n=bufParameters.nLayer,
    d=bufParameters.d,
    h=bufParameters.h,
    final lambda_ins=bufParameters.lambda_ins,
    final s_ins=bufParameters.s_ins,
    final hConIn=bufParameters.hConIn,
    final hConOut=bufParameters.hConOut,
    final k_HE=bufParameters.k_HE,
    final A_HE=bufParameters.A_HE,
    final V_HE=bufParameters.V_HE,
    final beta=bufParameters.beta,
    final kappa=bufParameters.kappa,
    T_start_layers=systemParameters.T_start_layersBuf,
    T_start_layers_HE=systemParameters.T_start_layers_HE_Buf,
    final m_flow_nominal_layer=systemParameters.mGen_flow_nominal,
    final m_flow_nominal_HE=systemParameters.mGen_flow_nominal,
    final T_start=t_TES)  "The buffer storage (PS) for the building"
    annotation (Placement(transformation(extent={{42,44},{18,74}})));
  Components.Valves.ArtificialThreeWayValve artificialThreeWayValve(
      redeclare final package Medium = MediumGen, p_hydr=systemParameters.pHyd)
    annotation (Placement(transformation(extent={{-76,42},{-60,76}})));
  Modelica.Blocks.Sources.RealExpression T_mean_DHW(y=storage_DHW.T_mean)
    annotation (Placement(transformation(
        extent={{18,-9},{-18,9}},
        rotation=180,
        origin={-82,-71})));
  Modelica.Blocks.Sources.RealExpression T_mean_TES(y=storage_TES_korr.T_mean)
    annotation (Placement(transformation(
        extent={{18,-9},{-18,9}},
        rotation=180,
        origin={-82,-87})));

  Real SOC_buf;
  Real SOC_DHW;

  replaceable
    RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition
    bufParameters(eps=0.99, V=0.3)
                  constrainedby
    RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition(
      final Q_flow_nominal=systemParameters.QDemBuiSum_flow*systemParameters.fDesTra
        *systemParameters.fDesDis) annotation (choicesAllMatching=true,
      Placement(transformation(extent={{84,54},{98,68}})));
  replaceable
    RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition
    dhwParameters(eps=0.99, V=0.3)
                  constrainedby
    RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition(
      final Q_flow_nominal=systemParameters.QDemDHW_flow, final V_dhw_day=
        systemParameters.V_dhw_day) annotation (choicesAllMatching=true,
      Placement(transformation(extent={{82,-58},{98,-42}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperatureDHW(final T=
        systemParameters.TAmbInternal)           annotation (Placement(transformation(
        extent={{-4,-4},{4,4}},
        rotation=0,
        origin={30,-94})));

  Modelica.Blocks.Sources.RealExpression T_Buf_1(y=storage_TES_korr.layer[1].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-18})));
  Modelica.Blocks.Sources.RealExpression T_Buf_4(y=storage_TES_korr.layer[
        bufParameters.nLayer].T) annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-36})));
  Modelica.Blocks.Sources.RealExpression T_DHW_1(y=storage_DHW.layer[1].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-42})));
  Modelica.Blocks.Sources.RealExpression T_DHW_4(y=storage_DHW.layer[
        dhwParameters.nLayer].T) annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-60})));
  AixLib.Fluid.Actuators.Valves.ThreeWayLinear val(redeclare package Medium =
        MediumDHW,
    T_start=t_TES,
    m_flow_nominal=systemParameters.mGen_flow_nominal,
    dpValve_nominal=systemParameters.dpVent_nominal)
    annotation (Placement(transformation(extent={{66,74},{78,86}})));
  AixLib.Fluid.Actuators.Valves.ThreeWayLinear val1(redeclare package Medium =
        MediumDHW,
    T_start=t_TES,
    m_flow_nominal=systemParameters.mGen_flow_nominal,
    dpValve_nominal=systemParameters.dpVent_nominal,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving)
    annotation (Placement(transformation(
        extent={{-6,6},{6,-6}},
        rotation=180,
        origin={72,40})));
  Modelica.Blocks.Math.BooleanToReal booleanToReal
    annotation (Placement(transformation(extent={{20,82},{28,90}})));
  AixLib.Fluid.Actuators.Valves.ThreeWayLinear val2(
    redeclare package Medium = MediumDHW,
    T_start=t_TES,
    m_flow_nominal=systemParameters.mGen_flow_nominal,
    dpValve_nominal=systemParameters.dpVent_nominal,
    portFlowDirection_1=Modelica.Fluid.Types.PortFlowDirection.Entering,
    portFlowDirection_2=Modelica.Fluid.Types.PortFlowDirection.Leaving,
    portFlowDirection_3=Modelica.Fluid.Types.PortFlowDirection.Leaving)
    annotation (Placement(transformation(
        extent={{4,4},{-4,-4}},
        rotation=180,
        origin={-24,72})));
  Modelica.Blocks.Math.BooleanToReal TES_isCooled
    annotation (Placement(transformation(extent={{-48,84},{-40,92}})));
  AixLib.Fluid.Actuators.Valves.ThreeWayLinear val4(
    redeclare package Medium = MediumDHW,
    T_start=t_TES,
    m_flow_nominal=systemParameters.mGen_flow_nominal,
    dpValve_nominal=systemParameters.dpVent_nominal)
    annotation (Placement(transformation(extent={{-20,54},{-28,62}})));
  Modelica.Blocks.Sources.RealExpression T_Buf_2(y=storage_TES_korr.layer[2].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-24})));
  Modelica.Blocks.Sources.RealExpression T_Buf_3(y=storage_TES_korr.layer[3].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-30})));
  Modelica.Blocks.Sources.RealExpression T_DHW_2(y=storage_DHW.layer[2].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-48})));
  Modelica.Blocks.Sources.RealExpression T_DHW_3(y=storage_DHW.layer[3].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-54})));
  Modelica.Blocks.Sources.RealExpression T_Buf_HE2(y=storage_TES_korr.layer_HE[
        2].T) annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,0})));
  Modelica.Blocks.Sources.RealExpression T_Buf_HE3(y=storage_TES_korr.layer_HE[
        3].T) annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-6})));
  Modelica.Blocks.Sources.RealExpression T_Buf_HE1(y=storage_TES_korr.layer_HE[
        1].T) annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,6})));
  Modelica.Blocks.Sources.RealExpression T_Buf_HE4(y=storage_TES_korr.layer_HE[
        4].T) annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-12})));
  Modelica.Blocks.Sources.RealExpression T_DHW_HE2(y=storage_DHW.layer_HE[2].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,24})));
  Modelica.Blocks.Sources.RealExpression T_DHW_HE3(y=storage_DHW.layer_HE[3].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,18})));
  Modelica.Blocks.Sources.RealExpression T_DHW_HE1(y=storage_DHW.layer_HE[1].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,30})));
  Modelica.Blocks.Sources.RealExpression T_DHW_HE4(y=storage_DHW.layer_HE[4].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,12})));
equation
  SOC_DHW =(storage_DHW.T_mean - systemParameters.TAmbInternal)/(
    systemParameters.TSetDHW - systemParameters.TAmbInternal);
  SOC_buf =storage_DHW.T_mean/1;
  connect(fixedTemperatureBuf.port, storage_TES_korr.heatPort) annotation (Line(
        points={{90,8},{94,8},{94,18},{42,18},{42,59},{39.6,59}}, color={191,0,
          0}));
  connect(storage_DHW.port_b_consumer, portDHW_out) annotation (Line(points={{49,
          -32},{48,-32},{48,-22},{100,-22}}, color={0,127,255}));
  connect(portDHW_in, storage_DHW.port_a_consumer) annotation (Line(points={{100,
          -82},{48,-82},{48,-70},{49,-70}}, color={0,127,255}));
  connect(artificialThreeWayValve.port_dhw_b, storage_DHW.port_a_heatGenerator)
    annotation (Line(points={{-60,52.2},{-10,52.2},{-10,46},{8,46},{8,-34.28},{34.72,
          -34.28}}, color={0,127,255}));
  connect(artificialThreeWayValve.port_dhw_a, storage_DHW.port_b_heatGenerator)
    annotation (Line(points={{-60,45.4},{-16,45.4},{-16,36},{8,36},{8,-66.2},{34.72,
          -66.2}}, color={0,127,255}));
  connect(fixedTemperatureDHW.port, storage_DHW.heatPort) annotation (Line(
        points={{34,-94},{70,-94},{70,-51},{62.6,-51}}, color={191,0,0}));
  connect(sigBusDistr.dhw_on, artificialThreeWayValve.dhw_on) annotation (Line(
      points={{0.12,101.105},{-68,101.105},{-68,79.4}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(portGen_in[1], artificialThreeWayValve.port_a) annotation (Line(
        points={{-100,80},{-83,80},{-83,65.8},{-76,65.8}}, color={0,127,255}));
  connect(portGen_out[1], artificialThreeWayValve.port_b) annotation (Line(
        points={{-100,40},{-78,40},{-78,52.2},{-76,52.2}}, color={0,127,255}));
  connect(T_mean_DHW.y, sigBusDistr.T_mean_DHW) annotation (Line(points={{-62.2,
          -71},{0.12,-71},{0.12,101.105}}, color={0,0,127}));
  connect(T_mean_TES.y, sigBusDistr.T_mean_Buf) annotation (Line(points={{-62.2,
          -87},{0.12,-87},{0.12,101.105}}, color={0,0,127}));
  connect(T_Buf_1.y, sigBusDistr.T_StoBuf_bot) annotation (Line(points={{-87.4,-18},
          {0.12,-18},{0.12,101.105}}, color={0,0,127}));
  connect(T_Buf_4.y, sigBusDistr.T_StoBuf_top) annotation (Line(points={{-87.4,-36},
          {0.12,-36},{0.12,101.105}}, color={0,0,127}));
  connect(T_DHW_1.y, sigBusDistr.T_StoDHW_bot) annotation (Line(points={{-87.4,-42},
          {0.12,-42},{0.12,101.105}}, color={0,0,127}));
  connect(T_DHW_4.y, sigBusDistr.T_StoDHW_top) annotation (Line(points={{-87.4,-60},
          {0.12,-60},{0.12,101.105}}, color={0,0,127}));
  connect(portBui_out, val.port_2) annotation (Line(points={{100,80},{78,80}},
                        color={0,127,255}));
  connect(val.port_1, storage_TES_korr.port_b_consumer_top) annotation (Line(
        points={{66,80},{50,80},{50,74},{34.56,74}}, color={0,127,255}));
  connect(storage_TES_korr.port_b_consumer_bot, val.port_3) annotation (Line(
        points={{34.32,44},{34.32,52},{52,52},{52,74},{72,74}}, color={0,127,
          255}));
  connect(portBui_out, portBui_out) annotation (Line(points={{100,80},{107,80},{
          107,80},{100,80}}, color={0,127,255}));
  connect(val.y, sigBusDistr.y_TES_Valve) annotation (Line(points={{72,87.2},{72,
          101.105},{0.12,101.105}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(val1.port_1, portBui_in)
    annotation (Line(points={{78,40},{100,40}}, color={0,127,255}));
  connect(val1.port_2, storage_TES_korr.port_a_consumer_heating)
    annotation (Line(points={{66,40},{30,40},{30,44}}, color={0,127,255}));
  connect(val1.port_3, storage_TES_korr.port_a_consumer_cooling) annotation (
      Line(points={{72,34},{72,30},{46,30},{46,80},{34,80},{34,74},{30.48,74}},
        color={0,127,255}));
  connect(booleanToReal.y, val1.y) annotation (Line(points={{28.4,86},{58,86},{58,
          48},{66,48},{66,47.2},{72,47.2}}, color={0,0,127}));
  connect(booleanToReal.u, sigBusDistr.SupplyGreaterReturn) annotation (Line(
        points={{19.2,86},{2,86},{2,98},{0.12,98},{0.12,101.105}}, color={255,0,
          255}));
  connect(TES_isCooled.u, sigBusDistr.TES_cooled) annotation (Line(points={{-48.8,
          88},{-50,88},{-50,101.105},{0.12,101.105}}, color={255,0,255}));
  connect(TES_isCooled.y, val2.y) annotation (Line(points={{-39.6,88},{-22,88},{
          -22,76.8},{-24,76.8}}, color={0,0,127}));
  connect(TES_isCooled.y, val4.y) annotation (Line(points={{-39.6,88},{-18,88},{
          -18,64},{-24,64},{-24,62.8}}, color={0,0,127}));
  connect(artificialThreeWayValve.port_buf_b, val2.port_1) annotation (Line(
        points={{-60,71.92},{-32,71.92},{-32,72},{-28,72}}, color={0,127,255}));
  connect(artificialThreeWayValve.port_buf_a, val4.port_2) annotation (Line(
        points={{-60,65.12},{-50,65.12},{-50,66},{-30,66},{-30,58},{-28,58}},
        color={0,127,255}));
  connect(val4.port_1, storage_TES_korr.port_b_heatGenerator_cooling)
    annotation (Line(points={{-20,58},{14,58},{14,68.9},{20.16,68.9}}, color={0,
          127,255}));
  connect(val4.port_3, storage_TES_korr.port_b_heatGenerator_heating)
    annotation (Line(points={{-24,54},{-4,54},{-4,47},{19.92,47}}, color={0,127,
          255}));
  connect(val2.port_2, storage_TES_korr.port_a_heatGenerator_heating)
    annotation (Line(points={{-20,72},{12,72},{12,72.2},{20.16,72.2}}, color={0,
          127,255}));
  connect(val2.port_3, storage_TES_korr.port_a_heatGenerator_cooling)
    annotation (Line(points={{-24,68},{-24,66},{12,66},{12,50.3},{19.92,50.3}},
        color={0,127,255}));
  connect(T_DHW_4.y, outBusDist.T_DHW_4) annotation (Line(points={{-87.4,-60},{0.05,
          -60},{0.05,-99.95}}, color={0,0,127}));
  connect(T_DHW_3.y, outBusDist.T_DHW_3) annotation (Line(points={{-87.4,-54},{0.05,
          -54},{0.05,-99.95}}, color={0,0,127}));
  connect(T_DHW_2.y, outBusDist.T_DHW_2) annotation (Line(points={{-87.4,-48},{0.05,
          -48},{0.05,-99.95}}, color={0,0,127}));
  connect(T_DHW_1.y, outBusDist.T_DHW_1) annotation (Line(points={{-87.4,-42},{0.05,
          -42},{0.05,-99.95}}, color={0,0,127}));
  connect(T_Buf_3.y, outBusDist.T_TES_3) annotation (Line(points={{-87.4,-30},{0.05,
          -30},{0.05,-99.95}}, color={0,0,127}));
  connect(T_Buf_4.y, outBusDist.T_TES_4) annotation (Line(points={{-87.4,-36},{0.05,
          -36},{0.05,-99.95}}, color={0,0,127}));
  connect(T_Buf_2.y, outBusDist.T_TES_2) annotation (Line(points={{-87.4,-24},{0.05,
          -24},{0.05,-99.95}}, color={0,0,127}));
  connect(T_Buf_1.y, outBusDist.T_TES_1) annotation (Line(points={{-87.4,-18},{0.05,
          -18},{0.05,-99.95}}, color={0,0,127}));
  connect(T_Buf_HE4.y, outBusDist.T_HE_TES_4) annotation (Line(points={{-87.4,-12},
          {0,-12},{0,-99.95},{0.05,-99.95}}, color={0,0,127}));
  connect(T_Buf_HE3.y, outBusDist.T_HE_TES_3) annotation (Line(points={{-87.4,-6},
          {0,-6},{0,-99.95},{0.05,-99.95}}, color={0,0,127}));
  connect(T_Buf_HE2.y, outBusDist.T_HE_TES_2) annotation (Line(points={{-87.4,0},
          {0,0},{0,-99.95},{0.05,-99.95}}, color={0,0,127}));
  connect(T_Buf_HE1.y, outBusDist.T_HE_TES_1) annotation (Line(points={{-87.4,6},
          {0,6},{0,-99.95},{0.05,-99.95}}, color={0,0,127}));
  connect(T_DHW_HE4.y, outBusDist.T_HE_DHW_4) annotation (Line(points={{-87.4,12},
          {0,12},{0,-99.95},{0.05,-99.95}}, color={0,0,127}));
  connect(T_DHW_HE3.y, outBusDist.T_HE_DHW_3) annotation (Line(points={{-87.4,18},
          {0,18},{0,-99.95},{0.05,-99.95}}, color={0,0,127}));
  connect(T_DHW_HE2.y, outBusDist.T_HE_DHW_2) annotation (Line(points={{-87.4,24},
          {0,24},{0,-99.95},{0.05,-99.95}}, color={0,0,127}));
  connect(T_DHW_HE1.y, outBusDist.T_HE_DHW_1) annotation (Line(points={{-87.4,30},
          {0,30},{0,-99.95},{0.05,-99.95}}, color={0,0,127}));
  connect(T_mean_TES.y, outBusDist.t_TES) annotation (Line(points={{-62.2,-87},
          {0.05,-87},{0.05,-99.95}}, color={0,0,127}));
  connect(T_mean_DHW.y, outBusDist.t_DHW) annotation (Line(points={{-62.2,-71},
          {0.05,-71},{0.05,-99.95}}, color={0,0,127}));
end DistributionTwoStorageParallel;
