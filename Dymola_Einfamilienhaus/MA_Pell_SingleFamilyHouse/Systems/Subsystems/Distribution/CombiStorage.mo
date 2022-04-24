within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution;
model CombiStorage
  "Combi Storage for heating, dhw and solar assitance"
  extends BaseClasses.PartialDistribution(final nParallelGen=2);

  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperatureBuf(
      final T=systemParameters.TAmbInternal) annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=0,
        origin={-62,-70})));

  replaceable
    RecordsCollection.StorageData.BufferStorage.BufferStorageBaseDataDefinition
    parameters constrainedby
    RecordsCollection.StorageData.BufferStorage.BufferStorageBaseDataDefinition(
      final Q_flow_nominal=systemParameters.QDem_flow*systemParameters.fDesDis*
        systemParameters.fDesTra) annotation (choicesAllMatching=true,
      Placement(transformation(extent={{82,56},{96,70}})));

  AixLib.Fluid.Storage.BufferStorage bufferStorage(
    redeclare final package Medium = MediumBui,
    final energyDynamics=systemParameters.energyDynamics,
    final massDynamics=systemParameters.massDynamics,
    final p_start=systemParameters.pHyd,
    final mSenFac=1,
    redeclare final package MediumHC1 = MediumGen,
    redeclare final package MediumHC2 = MediumDHW,
    final m1_flow_nominal=systemParameters.mGen_flow_nominal,
    final m2_flow_nominal=systemParameters.mTra_flow_nominal,
    final mHC1_flow_nominal=parameters.mHC1_flow_nominal,
    final mHC2_flow_nominal=parameters.mHC2_flow_nominal,
    final useHeatingCoil1=true,
    final useHeatingCoil2=true,
    final useHeatingRod=parameters.use_hr,
    final TStart=systemParameters.TWater_start,
    redeclare RecordsCollection.StorageData.BufferStorage.bufferData data(
      final hTank=parameters.h,
      final dTank=parameters.d,
      final sWall=parameters.s_ins/2,
      final sIns=parameters.s_ins/2,
      final lambdaWall=parameters.lambda_ins,
      final lambdaIns=parameters.lambda_ins,
      final rhoIns=373000,
      final cIns=1000),
    final n=parameters.nLayer,
    final hConIn=parameters.hConIn,
    final hConOut=parameters.hConOut,
    final hConHC1=parameters.hConHC1,
    final hConHC2=parameters.hConHC2,
    final upToDownHC1=true,
    final upToDownHC2=true,
    final TStartWall=systemParameters.TWater_start,
    final TStartIns=systemParameters.TWater_start,
    redeclare model HeatTransfer =
        AixLib.Fluid.Storage.BaseClasses.HeatTransferBuoyancyWetter,
    final allowFlowReversal_layers=systemParameters.allowFlowReversal,
    final allowFlowReversal_HC1=systemParameters.allowFlowReversal,
    final allowFlowReversal_HC2=systemParameters.allowFlowReversal)
    annotation (Placement(transformation(extent={{24,-36},{-36,40}})));
  Modelica.Blocks.Sources.Constant const_dhwHROn(k=parameters.QHR_flow_nominal)
    annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=180,
        origin={192,18})));
  Modelica.Blocks.Sources.Constant const_dhwHROff(final k=0) annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=180,
        origin={192,-10})));
  Modelica.Blocks.Logical.Switch switch2 if parameters.use_hr
                                         annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=180,
        origin={160,4})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow
                                                         prescribedHeatFlow if
    parameters.use_hr              annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=180,
        origin={110,2})));

equation
  connect(fixedTemperatureBuf.port, bufferStorage.heatportOutside) annotation (
      Line(points={{-50,-70},{-42,-70},{-42,4.28},{-35.25,4.28}},
        color={191,0,0}));
  connect(bufferStorage.TTop, sigBusDistr.T_StoBuf_top) annotation (Line(points={{24,
          35.44},{30,35.44},{30,70},{0.12,70},{0.12,101.105}},     color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(bufferStorage.TBottom, sigBusDistr.T_StoBuf_bot) annotation (Line(
        points={{24,-28.4},{40,-28.4},{40,70},{0.12,70},{0.12,101.105}},
                                                                       color={0,
          0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(portGen_in[2], bufferStorage.portHC2In) annotation (Line(
      points={{-100,85},{-56,85},{-56,-60},{46,-60},{46,-7.5},{24.375,-7.5}},
      color={225,225,0},
      thickness=0.5));
  connect(portGen_out[2], bufferStorage.portHC2Out) annotation (Line(
      points={{-100,45},{-62,45},{-62,-66},{50,-66},{50,-19.66},{24.375,-19.66}},
      color={225,225,0},
      thickness=0.5));

  connect(prescribedHeatFlow.port, bufferStorage.heatingRod)
    annotation (Line(points={{98,2},{62,2},{62,2},{24,2}}, color={191,0,0}));
  connect(switch2.y, prescribedHeatFlow.Q_flow) annotation (Line(points={{149,4},
          {134,4},{134,2},{122,2}}, color={0,0,127}));
  connect(const_dhwHROn.y, switch2.u1) annotation (Line(points={{185.4,18},{182,
          18},{182,12},{172,12}}, color={0,0,127}));
  connect(switch2.u3, const_dhwHROff.y) annotation (Line(points={{172,-4},{178,-4},
          {178,-10},{185.4,-10}}, color={0,0,127}));
  connect(sigBusDistr.dhwHR_on, switch2.u2) annotation (Line(
      points={{0.12,101.105},{180,101.105},{180,4},{172,4}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(portDHW_out, bufferStorage.portHC1Out) annotation (Line(points={{100,
          -22},{63,-22},{63,11.88},{24.375,11.88}}, color={0,127,255}));
  connect(bufferStorage.fluidportTop1, portBui_in) annotation (Line(points={{
          4.5,40.38},{52.25,40.38},{52.25,40},{100,40}}, color={0,127,255}));
  connect(bufferStorage.fluidportBottom1, portBui_out) annotation (Line(points=
          {{4.125,-36.76},{4.125,-46},{56,-46},{56,80},{100,80}}, color={0,127,
          255}));
  connect(portGen_out[1], bufferStorage.fluidportTop2) annotation (Line(points=
          {{-100,35},{-60,35},{-60,52},{-15.375,52},{-15.375,40.38}}, color={0,
          127,255}));
  connect(bufferStorage.fluidportBottom2, portGen_in[1]) annotation (Line(
        points={{-14.625,-36.38},{-14.625,-48},{-82,-48},{-82,75},{-100,75}},
        color={0,127,255}));
  connect(bufferStorage.portHC1In, portDHW_in) annotation (Line(points={{24.75,
          23.66},{54,23.66},{54,-82},{100,-82}}, color={0,127,255}));
  connect(bufferStorage.TTop, sigBusDistr.T_StoDHW_top) annotation (Line(points=
         {{24,35.44},{28,35.44},{28,86},{0.12,86},{0.12,101.105}}, color={0,0,
          127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(bufferStorage.TBottom, sigBusDistr.T_StoDHW_bot) annotation (Line(
        points={{24,-28.4},{36,-28.4},{36,72},{0.12,72},{0.12,101.105}}, color=
          {0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
end CombiStorage;
