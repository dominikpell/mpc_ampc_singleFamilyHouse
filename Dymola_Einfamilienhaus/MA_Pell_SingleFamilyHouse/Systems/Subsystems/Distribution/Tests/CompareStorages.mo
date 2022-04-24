within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution.Tests;
model CompareStorages
  extends Modelica.Icons.Example;
  AixLib.Fluid.Storage.BufferStorage bufferStorage(
    redeclare final package Medium = Medium,
    redeclare package MediumHC1 = Medium,
    redeclare package MediumHC2 = Medium,
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
    annotation (Placement(transformation(extent={{-28,22},{8,68}})));
  replaceable
    Studies.BuiFlexHP.Data.BufStorage
    bufParameters constrainedby
    RecordsCollection.StorageData.BufferStorage.BufferStorageBaseDataDefinition
                                                                                annotation (
      choicesAllMatching=true, Placement(transformation(extent={{36,26},{50,40}})));
  AixLib.Fluid.Storage.Storage storageDHW(
    redeclare final package Medium = Medium,
    final n=bufParametersSimple.nLayer,
    final d=(bufParametersSimple.V*4/(bufParametersSimple.storage_H_dia_ratio*
        Modelica.Constants.pi))^(1/3),
    final h=bufParametersSimple.storage_H_dia_ratio*storageDHW.d,
    final lambda_ins=bufParametersSimple.lambda_ins,
    final s_ins=bufParametersSimple.s_ins,
    final hConIn=bufParametersSimple.hConIn,
    final hConOut=bufParametersSimple.hConOut,
    final k_HE=bufParametersSimple.k_HE,
    final A_HE=bufParametersSimple.A_HE,
    final V_HE=bufParametersSimple.V_HE,
    final beta=bufParametersSimple.beta,
    final kappa=bufParametersSimple.kappa,
    final m_flow_nominal_layer=bufParametersSimple.mDem_flow,
    final m_flow_nominal_HE=bufParametersSimple.mGen_flow,
    final T_start=bufParametersSimple.TStart)
    "The DHW storage (TWWS) for domestic hot water demand"
    annotation (Placement(transformation(extent={{6,-72},{-28,-34}})));
  replaceable
    RecordsCollection.StorageData.SimpleStorage.DirectLoadingStorage
    bufParametersSimple constrainedby
    RecordsCollection.StorageData.SimpleStorage.SimpleStorageBaseDataDefinition
    annotation (choicesAllMatching=true, Placement(transformation(extent={{14,-58},
            {30,-42}})));
  Components.Pumps.ArtificalPumpFixedT artificalPumpFixedT2(
    redeclare package Medium = Medium,
    p=200000,
    T_fixed=333.15) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-78,52})));
  Modelica.Blocks.Sources.Constant m_flow1(k=0.2) annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-122,46})));
  replaceable package Medium = AixLib.Media.Water constrainedby
    Modelica.Media.Interfaces.PartialMedium annotation (
      __Dymola_choicesAllMatching=true);
  Modelica.Blocks.Sources.Sine m_flow(
    amplitude=0.1,
    freqHz=1/1800,
    offset=0.2)
              annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={142,-8})));
  Components.Pumps.ArtificalPumpFixedT artificalPumpFixedT1(
    redeclare package Medium = Medium,
    p=200000,
    T_fixed=303.15) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={84,-38})));
  Components.Pumps.ArtificalPumpFixedT artificalPumpFixedT3(
    redeclare package Medium = Medium,
    p=200000,
    T_fixed=333.15) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-72,-46})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperatureBuf(final T=
        bufParameters.TAmb)           annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=0,
        origin={6,-14})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperatureBuf1(final T=
        bufParametersSimple.TAmb)     annotation (Placement(transformation(
        extent={{-12,-12},{12,12}},
        rotation=0,
        origin={-30,-116})));
equation
  connect(m_flow1.y,artificalPumpFixedT2. m_flow_in)
    annotation (Line(points={{-111,46},{-102,46},{-102,52},{-89.6,52}},
                                                    color={0,0,127}));
  connect(artificalPumpFixedT2.port_b, bufferStorage.fluidportTop1) annotation (
     Line(points={{-78,62},{-78,76},{-16.3,76},{-16.3,68.23}}, color={0,127,255}));
  connect(bufferStorage.fluidportBottom1, artificalPumpFixedT2.port_a)
    annotation (Line(points={{-16.075,21.54},{-16.075,4},{-78,4},{-78,42}},
        color={0,127,255}));
  connect(m_flow.y, artificalPumpFixedT1.m_flow_in) annotation (Line(points={{131,
          -8},{108,-8},{108,-38},{95.6,-38}}, color={0,0,127}));
  connect(artificalPumpFixedT1.port_b, storageDHW.port_a_consumer) annotation (
      Line(points={{84,-48},{84,-66},{76,-66},{76,-72},{-11,-72}}, color={0,127,
          255}));
  connect(artificalPumpFixedT1.port_a, storageDHW.port_b_consumer) annotation (
      Line(points={{84,-28},{62,-28},{62,-24},{-11,-24},{-11,-34}}, color={0,127,
          255}));
  connect(artificalPumpFixedT3.port_a, storageDHW.port_b_heatGenerator)
    annotation (Line(points={{-72,-56},{-68,-56},{-68,-48},{-38,-48},{-38,-68.2},
          {-25.28,-68.2}}, color={0,127,255}));
  connect(artificalPumpFixedT3.port_b, storageDHW.port_a_heatGenerator)
    annotation (Line(points={{-72,-36},{-72,10},{-25.28,10},{-25.28,-36.28}},
        color={0,127,255}));
  connect(m_flow1.y, artificalPumpFixedT3.m_flow_in) annotation (Line(points={{-111,
          46},{-102,46},{-102,-46},{-83.6,-46}}, color={0,0,127}));
  connect(fixedTemperatureBuf.port, bufferStorage.heatportOutside) annotation (
      Line(points={{18,-14},{18,46.38},{7.55,46.38}}, color={191,0,0}));
  connect(fixedTemperatureBuf1.port, storageDHW.heatPort) annotation (Line(
        points={{-18,-116},{-2,-116},{-2,-53},{2.6,-53}}, color={191,0,0}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end CompareStorages;
