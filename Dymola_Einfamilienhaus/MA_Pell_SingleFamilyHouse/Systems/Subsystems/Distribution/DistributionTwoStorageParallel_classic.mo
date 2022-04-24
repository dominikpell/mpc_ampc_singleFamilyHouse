within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution;
model DistributionTwoStorageParallel_classic
"Model for the distribution of heat using two storages, one as buffer storage for buildings and the other for DHW demand. The devices are hydraulically modelled as in parallel"
extends BaseClasses.PartialDistribution;
parameter Real t_TES=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
parameter Real t_DHW=303.15 annotation(Evaluate=false, Dialog(tab="Initialize"));
MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution.Storage storage_DHW(
    redeclare final package Medium = MediumDHW,
    final n=dhwParameters.nLayer,
    final d=0.6,
    final h=1.06,
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
    final m_flow_nominal_layer=systemParameters.mGen_flow_nominal,
    final m_flow_nominal_HE=systemParameters.mGen_flow_nominal,
    final T_start=t_DHW) "The DHW storage (TWWS) for domestic hot water demand"
    annotation (Placement(transformation(extent={{66,-70},{32,-32}})));
Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperatureBuf(final T=
      systemParameters.TAmbInternal)           annotation (Placement(transformation(
      extent={{-12,-12},{12,12}},
      rotation=0,
      origin={44,6})));
MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution.Storage storage_TES(
    redeclare package Medium = MediumBui,
    final n=bufParameters.nLayer,
    final d=0.6,
    final h=1.06,
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
    final m_flow_nominal_layer=systemParameters.mGen_flow_nominal,
    final m_flow_nominal_HE=systemParameters.mGen_flow_nominal,
    final T_start=t_TES) "The buffer storage (PS) for the building"
    annotation (Placement(transformation(extent={{66,40},{32,76}})));
Components.Valves.ArtificialThreeWayValve artificialThreeWayValve(
    redeclare final package Medium = MediumGen, p_hydr=systemParameters.pHyd)
  annotation (Placement(transformation(extent={{-66,54},{-44,80}})));

Real SOC_buf;
Real SOC_DHW;

replaceable
  RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition
  bufParameters(eps=0.99)
                constrainedby
    RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition(
    final Q_flow_nominal=systemParameters.QDemBuiSum_flow*systemParameters.fDesTra
      *systemParameters.fDesDis) annotation (choicesAllMatching=true,
    Placement(transformation(extent={{84,54},{98,68}})));
replaceable
  RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition
  dhwParameters(eps=0.99)
                constrainedby
    RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition(
    final Q_flow_nominal=systemParameters.QDemDHW_flow, final V_dhw_day=
      systemParameters.V_dhw_day) annotation (choicesAllMatching=true,
    Placement(transformation(extent={{82,-58},{98,-42}})));
Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperatureDHW(final T=
      systemParameters.TAmbInternal)           annotation (Placement(transformation(
      extent={{-10,-10},{10,10}},
      rotation=0,
      origin={30,-90})));

  Modelica.Blocks.Sources.RealExpression T_mean_DHW(y=storage_DHW.T_mean)
    annotation (Placement(transformation(
        extent={{18,-9},{-18,9}},
        rotation=180,
        origin={-82,-81})));
  Modelica.Blocks.Sources.RealExpression T_mean_TES(y=storage_TES.T_mean)
    annotation (Placement(transformation(
        extent={{18,-9},{-18,9}},
        rotation=180,
        origin={-82,-97})));
  Modelica.Blocks.Sources.RealExpression T_Buf_1(y=storage_TES.layer[1].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-28})));
  Modelica.Blocks.Sources.RealExpression T_Buf_4(y=storage_TES.layer[
        bufParameters.nLayer].T) annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-46})));
  Modelica.Blocks.Sources.RealExpression T_DHW_1(y=storage_DHW.layer[1].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-52})));
  Modelica.Blocks.Sources.RealExpression T_DHW_4(y=storage_DHW.layer[
        dhwParameters.nLayer].T) annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-70})));
  Modelica.Blocks.Sources.RealExpression T_Buf_2(y=storage_TES.layer[2].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-34})));
  Modelica.Blocks.Sources.RealExpression T_Buf_3(y=storage_TES.layer[3].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-40})));
  Modelica.Blocks.Sources.RealExpression T_DHW_2(y=storage_DHW.layer[2].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-58})));
  Modelica.Blocks.Sources.RealExpression T_DHW_3(y=storage_DHW.layer[3].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-64})));
  Modelica.Blocks.Sources.RealExpression T_Buf_HE2(y=storage_TES.layer_HE[2].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-10})));
  Modelica.Blocks.Sources.RealExpression T_Buf_HE3(y=storage_TES.layer_HE[3].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-16})));
  Modelica.Blocks.Sources.RealExpression T_Buf_HE1(y=storage_TES.layer_HE[1].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-4})));
  Modelica.Blocks.Sources.RealExpression T_Buf_HE4(y=storage_TES.layer_HE[4].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,-22})));
  Modelica.Blocks.Sources.RealExpression T_DHW_HE2(y=storage_DHW.layer_HE[2].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,14})));
  Modelica.Blocks.Sources.RealExpression T_DHW_HE3(y=storage_DHW.layer_HE[3].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,8})));
  Modelica.Blocks.Sources.RealExpression T_DHW_HE1(y=storage_DHW.layer_HE[1].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,20})));
  Modelica.Blocks.Sources.RealExpression T_DHW_HE4(y=storage_DHW.layer_HE[4].T)
    annotation (Placement(transformation(
        extent={{6,-4},{-6,4}},
        rotation=180,
        origin={-94,2})));
  Modelica.Blocks.Sources.RealExpression ch_Buf(y=storage_TES.port_a_heatGenerator.m_flow
        *(storage_TES.port_a_heatGenerator.h_outflow - storage_TES.port_b_heatGenerator.h_outflow))
    annotation (Placement(transformation(
        extent={{8,-6},{-8,6}},
        rotation=180,
        origin={-86,-134})));
  Modelica.Blocks.Sources.RealExpression dch_Buf(y=-portBui_out.m_flow*(
        portBui_out.h_outflow - portBui_in.h_outflow))
    annotation (Placement(transformation(
        extent={{8,-7},{-8,7}},
        rotation=180,
        origin={-86,-123})));
  Modelica.Blocks.Sources.RealExpression ch_DHW(y=storage_DHW.port_a_heatGenerator.m_flow
        *(storage_DHW.port_a_heatGenerator.h_outflow - storage_DHW.port_b_heatGenerator.h_outflow))
    annotation (Placement(transformation(
        extent={{8,-6},{-8,6}},
        rotation=180,
        origin={-86,-148})));
  Modelica.Blocks.Sources.RealExpression dch_DHW(y=-portDHW_out.m_flow*(
        portDHW_out.h_outflow - portDHW_in.h_outflow)) annotation (Placement(
        transformation(
        extent={{8,-7},{-8,7}},
        rotation=180,
        origin={-86,-157})));
equation
SOC_DHW =(storage_DHW.T_mean - systemParameters.TAmbInternal)/(systemParameters.TSetDHW
     - systemParameters.TAmbInternal);
SOC_buf =storage_DHW.T_mean/1;
  connect(fixedTemperatureBuf.port, storage_TES.heatPort) annotation (Line(
        points={{56,6},{80,6},{80,58},{62.6,58}}, color={191,0,0}));
  connect(storage_TES.port_b_consumer, portBui_out) annotation (Line(points={{
          49,76},{50,76},{50,80},{100,80}}, color={0,127,255}));
  connect(storage_TES.port_a_consumer, portBui_in)
    annotation (Line(points={{49,40},{100,40}}, color={0,127,255}));
  connect(storage_DHW.port_b_consumer, portDHW_out) annotation (Line(points={{
          49,-32},{48,-32},{48,-22},{100,-22}}, color={0,127,255}));
  connect(portDHW_in, storage_DHW.port_a_consumer) annotation (Line(points={{
          100,-82},{48,-82},{48,-70},{49,-70}}, color={0,127,255}));
  connect(artificialThreeWayValve.port_buf_b, storage_TES.port_a_heatGenerator)
    annotation (Line(points={{-44,76.88},{8,76.88},{8,73.84},{34.72,73.84}},
        color={0,127,255}));
  connect(artificialThreeWayValve.port_buf_a, storage_TES.port_b_heatGenerator)
    annotation (Line(points={{-44,71.68},{8,71.68},{8,43.6},{34.72,43.6}},
        color={0,127,255}));
  connect(artificialThreeWayValve.port_dhw_b, storage_DHW.port_a_heatGenerator)
    annotation (Line(points={{-44,61.8},{-10,61.8},{-10,46},{8,46},{8,-34.28},{
          34.72,-34.28}}, color={0,127,255}));
  connect(artificialThreeWayValve.port_dhw_a, storage_DHW.port_b_heatGenerator)
    annotation (Line(points={{-44,56.6},{-16,56.6},{-16,36},{8,36},{8,-66.2},{
          34.72,-66.2}}, color={0,127,255}));
  connect(fixedTemperatureDHW.port, storage_DHW.heatPort) annotation (Line(
        points={{40,-90},{70,-90},{70,-51},{62.6,-51}}, color={191,0,0}));
connect(sigBusDistr.dhw_on, artificialThreeWayValve.dhw_on) annotation (Line(
    points={{0.12,101.105},{-55,101.105},{-55,82.6}},
    color={255,204,51},
    thickness=0.5), Text(
    string="%first",
    index=-1,
    extent={{-3,6},{-3,6}},
    horizontalAlignment=TextAlignment.Right));
connect(portGen_in[1], artificialThreeWayValve.port_a) annotation (Line(
      points={{-100,80},{-83,80},{-83,72.2},{-66,72.2}}, color={0,127,255}));
connect(portGen_out[1], artificialThreeWayValve.port_b) annotation (Line(
      points={{-100,40},{-78,40},{-78,61.8},{-66,61.8}}, color={0,127,255}));
  connect(T_mean_DHW.y, sigBusDistr.T_mean_DHW) annotation (Line(points={{-62.2,
          -81},{0.12,-81},{0.12,101.105}}, color={0,0,127}));
  connect(T_mean_TES.y, sigBusDistr.T_mean_Buf) annotation (Line(points={{-62.2,
          -97},{0.12,-97},{0.12,101.105}}, color={0,0,127}));
  connect(T_Buf_1.y, sigBusDistr.T_StoBuf_bot) annotation (Line(points={{-87.4,
          -28},{0.12,-28},{0.12,101.105}},
                                      color={0,0,127}));
  connect(T_Buf_4.y, sigBusDistr.T_StoBuf_top) annotation (Line(points={{-87.4,
          -46},{0.12,-46},{0.12,101.105}},
                                      color={0,0,127}));
  connect(T_DHW_1.y, sigBusDistr.T_StoDHW_bot) annotation (Line(points={{-87.4,
          -52},{0.12,-52},{0.12,101.105}},
                                      color={0,0,127}));
  connect(T_DHW_4.y, sigBusDistr.T_StoDHW_top) annotation (Line(points={{-87.4,
          -70},{0.12,-70},{0.12,101.105}},
                                      color={0,0,127}));
  connect(T_DHW_4.y, outBusDist.T_DHW_4) annotation (Line(points={{-87.4,-70},{
          0.05,-70},{0.05,-99.95}},
                               color={0,0,127}));
  connect(T_DHW_3.y, outBusDist.T_DHW_3) annotation (Line(points={{-87.4,-64},{
          0.05,-64},{0.05,-99.95}},
                               color={0,0,127}));
  connect(T_DHW_2.y, outBusDist.T_DHW_2) annotation (Line(points={{-87.4,-58},{
          0.05,-58},{0.05,-99.95}},
                               color={0,0,127}));
  connect(T_DHW_1.y, outBusDist.T_DHW_1) annotation (Line(points={{-87.4,-52},{
          0.05,-52},{0.05,-99.95}},
                               color={0,0,127}));
  connect(T_Buf_3.y, outBusDist.T_TES_3) annotation (Line(points={{-87.4,-40},{
          0.05,-40},{0.05,-99.95}},
                               color={0,0,127}));
  connect(T_Buf_4.y, outBusDist.T_TES_4) annotation (Line(points={{-87.4,-46},{
          0.05,-46},{0.05,-99.95}},
                               color={0,0,127}));
  connect(T_Buf_2.y, outBusDist.T_TES_2) annotation (Line(points={{-87.4,-34},{
          0.05,-34},{0.05,-99.95}},
                               color={0,0,127}));
  connect(T_Buf_1.y, outBusDist.T_TES_1) annotation (Line(points={{-87.4,-28},{
          0.05,-28},{0.05,-99.95}},
                               color={0,0,127}));
  connect(T_Buf_HE4.y, outBusDist.T_HE_TES_4) annotation (Line(points={{-87.4,
          -22},{0,-22},{0,-99.95},{0.05,-99.95}},
                                             color={0,0,127}));
  connect(T_Buf_HE3.y, outBusDist.T_HE_TES_3) annotation (Line(points={{-87.4,
          -16},{0,-16},{0,-99.95},{0.05,-99.95}},
                                            color={0,0,127}));
  connect(T_Buf_HE2.y, outBusDist.T_HE_TES_2) annotation (Line(points={{-87.4,
          -10},{0,-10},{0,-99.95},{0.05,-99.95}},
                                           color={0,0,127}));
  connect(T_Buf_HE1.y, outBusDist.T_HE_TES_1) annotation (Line(points={{-87.4,
          -4},{0,-4},{0,-99.95},{0.05,-99.95}},
                                           color={0,0,127}));
  connect(T_DHW_HE4.y, outBusDist.T_HE_DHW_4) annotation (Line(points={{-87.4,2},
          {0,2},{0,-99.95},{0.05,-99.95}},  color={0,0,127}));
  connect(T_DHW_HE3.y, outBusDist.T_HE_DHW_3) annotation (Line(points={{-87.4,8},
          {0,8},{0,-99.95},{0.05,-99.95}},  color={0,0,127}));
  connect(T_DHW_HE2.y, outBusDist.T_HE_DHW_2) annotation (Line(points={{-87.4,
          14},{0,14},{0,-99.95},{0.05,-99.95}},
                                            color={0,0,127}));
  connect(T_DHW_HE1.y, outBusDist.T_HE_DHW_1) annotation (Line(points={{-87.4,
          20},{0,20},{0,-99.95},{0.05,-99.95}},
                                            color={0,0,127}));
  connect(T_mean_DHW.y, outBusDist.t_DHW) annotation (Line(points={{-62.2,-81},
          {0.05,-81},{0.05,-99.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(T_mean_TES.y, outBusDist.t_TES) annotation (Line(points={{-62.2,-97},
          {-16,-97},{-16,-96},{0,-96},{0,-99.95},{0.05,-99.95}}, color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(dch_Buf.y, outBusDist.dch_TES) annotation (Line(points={{-77.2,-123},
          {-26,-123},{-26,-99.95},{0.05,-99.95}}, color={0,0,127}));
  connect(ch_Buf.y, outBusDist.ch_TES) annotation (Line(points={{-77.2,-134},{
          0.05,-134},{0.05,-99.95}}, color={0,0,127}));
  connect(ch_DHW.y, outBusDist.ch_DHW) annotation (Line(points={{-77.2,-148},{
          -48,-148},{-48,-150},{0.05,-150},{0.05,-99.95}}, color={0,0,127}));
  connect(dch_DHW.y, outBusDist.dch_DHW) annotation (Line(points={{-77.2,-157},
          {0.05,-157},{0.05,-99.95}}, color={0,0,127}));
end DistributionTwoStorageParallel_classic;
