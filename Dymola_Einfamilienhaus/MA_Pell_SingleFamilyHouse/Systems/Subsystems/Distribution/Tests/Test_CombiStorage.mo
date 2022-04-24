within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution.Tests;
model Test_CombiStorage
  extends MA_Pell_SingleFamilyHouse.Systems.BaseClasses.PartialBESExample;
  replaceable package Medium = AixLib.Media.Water;

  Interfaces.DistributionControlBus distControlBus
    annotation (Placement(transformation(extent={{-20,58},{20,98}})));
  CombiStorage combiStorage(
    systemParameters=systemParameters,
    redeclare package MediumDHW = Medium,
    redeclare package MediumBui = Medium,
    redeclare package MediumGen = Medium,
    redeclare
      RecordsCollection.StorageData.BufferStorage.BufferStorageBaseDataDefinition
      parameters(
      Q_flow_nominal=10000,
      use_hr=false,
      QHR_flow_nominal=0))
    annotation (Placement(transformation(extent={{-24,-62},{56,36}})));

  Modelica.Blocks.Sources.Sine m_flow(
    amplitude=0.1,
    freqHz=1/1800,
    offset=0.2)
              annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={156,-14})));
  Modelica.Blocks.Sources.Constant m_flow1(k=0.2) annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-114,12})));
  AixLib.Fluid.Movers.FlowControlled_m_flow fan(
    redeclare final package Medium = Medium,
    final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final massDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=1,
    redeclare final AixLib.Fluid.Movers.Data.Pumps.Wilo.Stratos32slash1to12 per,
    final inputType=AixLib.Fluid.Types.InputType.Continuous,
    final tau=1,
    final use_inputFilter=false,
    final init=Modelica.Blocks.Types.Init.InitialOutput,
    final y_start=1)                                     annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-58,-24})));

  AixLib.Fluid.Movers.FlowControlled_m_flow fan1(
    redeclare final package Medium = Medium,
    final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final massDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=1,
    redeclare final AixLib.Fluid.Movers.Data.Pumps.Wilo.Stratos32slash1to12 per,
    final inputType=AixLib.Fluid.Types.InputType.Continuous,
    final tau=1,
    final use_inputFilter=false,
    final init=Modelica.Blocks.Types.Init.InitialOutput,
    final y_start=1)                                     annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-72,14})));

  AixLib.Fluid.Sources.Boundary_pT bou(
    redeclare package Medium = AixLib.Media.Water,
    p=200000,
    nPorts=1)                                    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-122,-26})));
  AixLib.Fluid.Sources.Boundary_pT bou1(
    redeclare package Medium = AixLib.Media.Water,
    p=200000,
    nPorts=1)                                    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-88,-66})));
  AixLib.Fluid.Movers.FlowControlled_m_flow fan2(
    redeclare final package Medium = Medium,
    final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final massDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=1,
    redeclare final AixLib.Fluid.Movers.Data.Pumps.Wilo.Stratos32slash1to12 per,
    final inputType=AixLib.Fluid.Types.InputType.Continuous,
    final tau=1,
    final use_inputFilter=false,
    final init=Modelica.Blocks.Types.Init.InitialOutput,
    final y_start=1)                                     annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={112,24})));

  AixLib.Fluid.Movers.FlowControlled_m_flow fan3(
    redeclare final package Medium = Medium,
    final energyDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    final massDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    m_flow_nominal=1,
    redeclare final AixLib.Fluid.Movers.Data.Pumps.Wilo.Stratos32slash1to12 per,
    final inputType=AixLib.Fluid.Types.InputType.Continuous,
    final tau=1,
    final use_inputFilter=false,
    final init=Modelica.Blocks.Types.Init.InitialOutput,
    final y_start=1)                                     annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={94,-46})));

  AixLib.Fluid.Sources.Boundary_pT bou3(
    redeclare package Medium = AixLib.Media.Water,
    p=200000,
    nPorts=1)                                    annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={106,-18})));
equation
  connect(distControlBus, combiStorage.sigBusDistr) annotation (Line(
      points={{0,78},{16,78},{16,36.49}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(fan.port_a, combiStorage.portGen_out[1]) annotation (Line(points={{-58,-34},
          {-36,-34},{-36,6.6},{-24,6.6}},          color={0,127,255}));
  connect(fan.port_b, combiStorage.portGen_in[1]) annotation (Line(points={{-58,-14},
          {-46,-14},{-46,26.2},{-24,26.2}},      color={0,127,255}));
  connect(m_flow1.y, fan.m_flow_in) annotation (Line(points={{-103,12},{-103,-46},
          {-56,-46},{-56,-24},{-70,-24}},      color={0,0,127}));
  connect(fan1.port_a, combiStorage.portGen_out[2]) annotation (Line(points={{-72,
          4},{-48,4},{-48,6.6},{-24,6.6}}, color={0,127,255}));
  connect(fan1.port_b, combiStorage.portGen_in[2]) annotation (Line(points={{-72,
          24},{-48,24},{-48,26.2},{-24,26.2}}, color={0,127,255}));
  connect(m_flow1.y, fan1.m_flow_in) annotation (Line(points={{-103,12},{-92,12},
          {-92,14},{-84,14}}, color={0,0,127}));
  connect(fan1.port_a, bou.ports[1]) annotation (Line(points={{-72,4},{-98,4},{-98,
          -16},{-122,-16}}, color={0,127,255}));
  connect(fan.port_a, bou1.ports[1]) annotation (Line(points={{-58,-34},{-74,-34},
          {-74,-56},{-88,-56}}, color={0,127,255}));
  connect(bou3.ports[1], fan3.port_a) annotation (Line(points={{106,-28},{118,-28},
          {118,-36},{94,-36}}, color={0,127,255}));
  connect(fan3.m_flow_in, m_flow.y) annotation (Line(points={{106,-46},{136,-46},
          {136,-14},{145,-14}}, color={0,0,127}));
  connect(fan2.port_b, combiStorage.portBui_in) annotation (Line(points={{112,14},
          {84,14},{84,6.6},{56,6.6}}, color={0,127,255}));
  connect(combiStorage.portBui_out, fan2.port_a) annotation (Line(points={{56,26.2},
          {84,26.2},{84,34},{112,34}}, color={0,127,255}));
  connect(fan3.port_a, combiStorage.portDHW_out) annotation (Line(points={{94,-36},
          {70,-36},{70,-24},{56,-24},{56,-22.8}}, color={0,127,255}));
  connect(combiStorage.portDHW_in, fan3.port_b) annotation (Line(points={{56,-42.4},
          {74,-42.4},{74,-56},{94,-56}}, color={0,127,255}));
  connect(m_flow.y, fan2.m_flow_in) annotation (Line(points={{145,-14},{145,7},
          {124,7},{124,24}}, color={0,0,127}));
  annotation (experiment(StopTime=31536000, Interval=3600));
end Test_CombiStorage;
