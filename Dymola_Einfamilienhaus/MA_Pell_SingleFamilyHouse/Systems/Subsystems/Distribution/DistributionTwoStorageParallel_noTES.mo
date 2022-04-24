within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution;
model DistributionTwoStorageParallel_noTES
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
 Components.Valves.ArtificialThreeWayValve artificialThreeWayValve(
     redeclare final package Medium = MediumGen, p_hydr=systemParameters.pHyd)
   annotation (Placement(transformation(extent={{-76,42},{-60,76}})));
 Modelica.Blocks.Sources.RealExpression T_mean_DHW(y=storage_DHW.T_mean)
   annotation (Placement(transformation(
       extent={{18,-9},{-18,9}},
       rotation=180,
       origin={-82,-71})));

 Real SOC_buf;
 Real SOC_DHW;

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
 Modelica.Blocks.Sources.RealExpression ch_DHW(y=storage_DHW.port_a_heatGenerator.m_flow
       *(storage_DHW.port_a_heatGenerator.h_outflow - storage_DHW.port_b_heatGenerator.h_outflow))
   annotation (Placement(transformation(
       extent={{8,-6},{-8,6}},
       rotation=180,
       origin={-92,-128})));
 Modelica.Blocks.Sources.RealExpression dch_DHW(y=-portDHW_out.m_flow*(
       portDHW_out.h_outflow - portDHW_in.h_outflow)) annotation (Placement(
       transformation(
       extent={{8,-7},{-8,7}},
       rotation=180,
       origin={-92,-137})));
equation
 SOC_DHW =(storage_DHW.T_mean - systemParameters.TAmbInternal)/(
   systemParameters.TSetDHW - systemParameters.TAmbInternal);
 SOC_buf =storage_DHW.T_mean/1;
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
 connect(T_DHW_1.y, sigBusDistr.T_StoDHW_bot) annotation (Line(points={{-87.4,-42},
         {0.12,-42},{0.12,101.105}}, color={0,0,127}));
 connect(T_DHW_4.y, sigBusDistr.T_StoDHW_top) annotation (Line(points={{-87.4,-60},
         {0.12,-60},{0.12,101.105}}, color={0,0,127}));
 connect(portBui_out, portBui_out) annotation (Line(points={{100,80},{107,80},{
         107,80},{100,80}}, color={0,127,255}));
 connect(T_DHW_4.y, outBusDist.T_DHW_4) annotation (Line(points={{-87.4,-60},{0.05,
         -60},{0.05,-99.95}}, color={0,0,127}));
 connect(T_DHW_3.y, outBusDist.T_DHW_3) annotation (Line(points={{-87.4,-54},{0.05,
         -54},{0.05,-99.95}}, color={0,0,127}));
 connect(T_DHW_2.y, outBusDist.T_DHW_2) annotation (Line(points={{-87.4,-48},{0.05,
         -48},{0.05,-99.95}}, color={0,0,127}));
 connect(T_DHW_1.y, outBusDist.T_DHW_1) annotation (Line(points={{-87.4,-42},{0.05,
         -42},{0.05,-99.95}}, color={0,0,127}));
 connect(T_DHW_HE4.y, outBusDist.T_HE_DHW_4) annotation (Line(points={{-87.4,12},
         {0,12},{0,-99.95},{0.05,-99.95}}, color={0,0,127}));
 connect(T_DHW_HE3.y, outBusDist.T_HE_DHW_3) annotation (Line(points={{-87.4,18},
         {0,18},{0,-99.95},{0.05,-99.95}}, color={0,0,127}));
 connect(T_DHW_HE2.y, outBusDist.T_HE_DHW_2) annotation (Line(points={{-87.4,24},
         {0,24},{0,-99.95},{0.05,-99.95}}, color={0,0,127}));
 connect(T_DHW_HE1.y, outBusDist.T_HE_DHW_1) annotation (Line(points={{-87.4,30},
         {0,30},{0,-99.95},{0.05,-99.95}}, color={0,0,127}));
 connect(ch_DHW.y, outBusDist.ch_DHW) annotation (Line(points={{-83.2,-128},{
         -54,-128},{-54,-130},{0.05,-130},{0.05,-99.95}}, color={0,0,127}));
 connect(dch_DHW.y, outBusDist.dch_DHW) annotation (Line(points={{-83.2,-137},
         {0.05,-137},{0.05,-99.95}}, color={0,0,127}));
 connect(T_mean_DHW.y, outBusDist.t_DHW) annotation (Line(points={{-62.2,-71},
         {0.05,-71},{0.05,-99.95}}, color={0,0,127}));
  connect(artificialThreeWayValve.port_buf_b, portBui_out) annotation (Line(
        points={{-60,71.92},{-22,71.92},{-22,70},{38,70},{38,80},{100,80}},
        color={0,127,255}));
  connect(artificialThreeWayValve.port_buf_a, portBui_in) annotation (Line(
        points={{-60,65.12},{-46,65.12},{-46,66},{54,66},{54,40},{100,40}},
        color={0,127,255}));
end DistributionTwoStorageParallel_noTES;
