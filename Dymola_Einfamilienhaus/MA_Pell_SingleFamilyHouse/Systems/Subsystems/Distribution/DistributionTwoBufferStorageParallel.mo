within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution;
model DistributionTwoBufferStorageParallel
  "Model for the distribution of heat using two storages, one for heat demand and other for DHW. Uses the buffer storage model as a base."
  extends BaseClasses.PartialDistribution;
  parameter Real QHR_flow_nominal "Constant output value";

  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperatureBuf(final T=
        bufParameters.TAmb)           annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=0,
        origin={44,6})));
  Components.Valves.ArtificialThreeWayValve artificialThreeWayValve(
      redeclare final package Medium = MediumGen, p_hydr=p_hydr)
    annotation (Placement(transformation(extent={{-68,36},{-18,80}})));

  replaceable
    RecordsCollection.StorageData.BufferStorage.BufferStorageBaseDataDefinition
    bufParameters constrainedby
    RecordsCollection.StorageData.BufferStorage.BufferStorageBaseDataDefinition
    annotation (choicesAllMatching=true, Placement(transformation(extent={{84,
            56},{98,70}})));
  replaceable
    RecordsCollection.StorageData.BufferStorage.BufferStorageBaseDataDefinition
    dhwParameters constrainedby
    RecordsCollection.StorageData.BufferStorage.BufferStorageBaseDataDefinition
    annotation (choicesAllMatching=true, Placement(transformation(extent={{82,-58},
            {98,-42}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperatureDHW(final T=
        dhwParameters.TAmb)           annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={30,-90})));
  parameter Modelica.SIunits.Pressure p_hydr=200000
                                                 "Hydraulic pressure in pipes";
  AixLib.Fluid.Storage.BufferStorage dhwStorage(
    redeclare final package Medium = MediumDHW,
    redeclare package MediumHC1 = MediumGen,
    redeclare package MediumHC2 = MediumGen,
    m1_flow_nominal=0,
    m2_flow_nominal=dhwParameters.mDem_flow,
    mHC1_flow_nominal=dhwParameters.mGen_flow,
    mHC2_flow_nominal=0,
    useHeatingCoil1=true,
    useHeatingCoil2=false,
    final useHeatingRod=dhwParameters.use_hr,
    TStart=dhwParameters.TStart,
    redeclare RecordsCollection.StorageData.BufferStorage.bufferData data(
      hTank=dhwParameters.h,
      dTank=dhwParameters.d,
      sWall=dhwParameters.s_ins/2,
      sIns=dhwParameters.s_ins/2,
      lambdaWall=dhwParameters.lambda_ins,
      lambdaIns=dhwParameters.lambda_ins,
      rhoIns=373000,
      cIns=1000),
    final n=dhwParameters.nLayer,
    hConIn=dhwParameters.hConIn,
    hConOut=dhwParameters.hConOut,
    hConHC1=dhwParameters.hConHC,
    upToDownHC1=true,
    TStartWall=dhwParameters.TStart,
    TStartIns=dhwParameters.TStart,
    redeclare model HeatTransfer =
        AixLib.Fluid.Storage.BaseClasses.HeatTransferBuoyancyWetter)
    "The DHW storage (TWWS) for domestic hot water demand"
    annotation (Placement(transformation(extent={{34,-70},{64,-32}})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow
                                                         prescribedHeatFlow if
    dhwParameters.use_hr              annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=0,
        origin={-18,-58})));
  Modelica.Blocks.Logical.Switch switch2 if dhwParameters.use_hr
                                         annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-54,-58})));
  Modelica.Blocks.Sources.Constant const_dhwHROff(final k=0) annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={-92,-66})));
  Modelica.Blocks.Sources.Constant const_dhwHROn(k=QHR_flow_nominal)
    annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={-92,-46})));
  AixLib.Fluid.Storage.BufferStorage bufferStorage(
    redeclare final package Medium = MediumBui,
    redeclare package MediumHC1 = MediumGen,
    redeclare package MediumHC2 = MediumGen,
    m1_flow_nominal=bufParameters.mGen_flow,
    m2_flow_nominal=bufParameters.mDem_flow,
    final mHC1_flow_nominal=bufParameters.mGen_flow,
    mHC2_flow_nominal=0,
    final useHeatingCoil1=false,
    final useHeatingCoil2=false,
    final useHeatingRod=bufParameters.use_hr,
    TStart=bufParameters.TStart,
    redeclare RecordsCollection.StorageData.BufferStorage.bufferData data(
      hTank=bufParameters.h,
      dTank=bufParameters.d,
      sWall=bufParameters.s_ins/2,
      sIns=bufParameters.s_ins/2,
      lambdaWall=bufParameters.lambda_ins,
      lambdaIns=bufParameters.lambda_ins,
      rhoIns=373000,
      cIns=1000),
    final n=bufParameters.nLayer,
    hConIn=bufParameters.hConIn,
    hConOut=bufParameters.hConOut,
    final upToDownHC1=true,
    TStartWall=bufParameters.TStart,
    TStartIns=bufParameters.TStart,
    redeclare model HeatTransfer =
        AixLib.Fluid.Storage.BaseClasses.HeatTransferBuoyancyWetter)
    annotation (Placement(transformation(extent={{32,42},{58,74}})));
equation
  connect(sigBusDistr.dhw_on, artificialThreeWayValve.dhw_on) annotation (Line(
      points={{0.12,101.105},{-14,101.105},{-14,102},{-22,102},{-22,84.4},{-43,
          84.4}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(portDHW_in, dhwStorage.fluidportBottom2) annotation (Line(points={{100,-82},
          {53.3125,-82},{53.3125,-70.19}},      color={0,127,255}));
  connect(dhwStorage.fluidportTop2, portDHW_out) annotation (Line(points={{53.6875,
          -31.81},{53.6875,-22},{100,-22}}, color={0,127,255}));
  connect(fixedTemperatureDHW.port, dhwStorage.heatportOutside) annotation (
      Line(points={{40,-90},{72,-90},{72,-49.86},{63.625,-49.86}}, color={191,0,
          0}));
  connect(dhwStorage.portHC1In, artificialThreeWayValve.port_dhw_b) annotation (
     Line(points={{33.625,-40.17},{8,-40.17},{8,49.2},{-18,49.2}}, color={0,127,
          255}));
  connect(artificialThreeWayValve.port_dhw_a, dhwStorage.portHC1Out)
    annotation (Line(points={{-18,40.4},{-8,40.4},{-8,42},{2,42},{2,-46.06},{33.8125,
          -46.06}}, color={0,127,255}));
  connect(prescribedHeatFlow.port, dhwStorage.heatingRod) annotation (Line(
        points={{-6,-58},{22,-58},{22,-51},{34,-51}}, color={191,0,0}));
  connect(switch2.y, prescribedHeatFlow.Q_flow)
    annotation (Line(points={{-43,-58},{-30,-58}}, color={0,0,127}));
  connect(switch2.u3, const_dhwHROff.y)
    annotation (Line(points={{-66,-66},{-85.4,-66}}, color={0,0,127}));
  connect(const_dhwHROn.y, switch2.u1) annotation (Line(points={{-85.4,-46},{-74,
          -46},{-74,-50},{-66,-50}}, color={0,0,127}));
  connect(switch2.u2, sigBusDistr.dhwHR_on) annotation (Line(points={{-66,-58},{
          -100,-58},{-100,-56},{-118,-56},{-118,101.105},{0.12,101.105}}, color=
         {255,0,255}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(fixedTemperatureBuf.port, bufferStorage.heatportOutside) annotation (
      Line(points={{56,6},{62,6},{62,8},{70,8},{70,58.96},{57.675,58.96}},
        color={191,0,0}));
  connect(bufferStorage.fluidportBottom2, portBui_in) annotation (Line(points={{48.7375,
          41.84},{48.7375,40},{100,40}},         color={0,127,255}));
  connect(bufferStorage.fluidportTop2, portBui_out) annotation (Line(points={{49.0625,
          74.16},{49.0625,80},{100,80}}, color={0,127,255}));
  connect(bufferStorage.TTop, sigBusDistr.T_StoBuf_top) annotation (Line(points={{32,
          72.08},{30,72.08},{30,70},{0.12,70},{0.12,101.105}},     color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(bufferStorage.TBottom, sigBusDistr.T_StoBuf_bot) annotation (Line(
        points={{32,45.2},{28,45.2},{28,44},{0.12,44},{0.12,101.105}}, color={0,
          0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(dhwStorage.TTop, sigBusDistr.T_StoDHW_top) annotation (Line(points={{34,
          -34.28},{28,-34.28},{28,-22},{0.12,-22},{0.12,101.105}}, color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(dhwStorage.TBottom, sigBusDistr.T_StoDHW_bot) annotation (Line(points={{34,
          -66.2},{0.12,-66.2},{0.12,101.105}},     color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(artificialThreeWayValve.port_buf_b, bufferStorage.fluidportTop1)
    annotation (Line(points={{-18,74.72},{-18,84},{40.45,84},{40.45,74.16}},
        color={0,127,255}));
  connect(bufferStorage.fluidportBottom1, artificialThreeWayValve.port_buf_a)
    annotation (Line(points={{40.6125,41.68},{40.6125,34},{22,34},{22,65.92},{-18,
          65.92}}, color={0,127,255}));
  connect(portGen_out[1], artificialThreeWayValve.port_b) annotation (Line(
        points={{-100,40},{-84,40},{-84,49.2},{-68,49.2}}, color={0,127,255}));
  connect(portGen_in[1], artificialThreeWayValve.port_a) annotation (Line(
        points={{-100,80},{-84,80},{-84,66.8},{-68,66.8}}, color={0,127,255}));
end DistributionTwoBufferStorageParallel;
