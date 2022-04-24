within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution.Tests;
model Test_DistributionTwoStorageParallel
  extends Modelica.Icons.Example;
  replaceable package Medium = AixLib.Media.Water;

  Interfaces.DistributionControlBus distControlBus
    annotation (Placement(transformation(extent={{-20,58},{20,98}})));
  DistributionTwoStorageParallel distributionTwoStorageParallel(
    redeclare package MediumDHW = Medium,
    redeclare package MediumBui = Medium,
    redeclare package MediumGen = Medium,
    redeclare RecordsCollection.StorageData.SimpleStorage.DirectLoadingStorage
      bufParameters,
    redeclare RecordsCollection.StorageData.SimpleStorage.DummySimpleStorage
      dhwParameters)
    annotation (Placement(transformation(extent={{-24,-62},{56,36}})));

  Modelica.Blocks.Sources.BooleanConstant
                                       booleanConstant
    annotation (Placement(transformation(extent={{-108,80},{-88,100}})));
  Modelica.Blocks.Sources.BooleanPulse booleanPulse1(width=70, period=3600)
    annotation (Placement(transformation(extent={{-110,44},{-90,64}})));
  Modelica.Blocks.Sources.Sine m_flow(
    amplitude=0.1,
    freqHz=1/1800,
    offset=0.2)
              annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={166,-4})));
  Components.Pumps.ArtificalPumpFixedT artificalPumpFixedT(
    redeclare package Medium = Medium,
    p=200000,
    T_fixed=313.15) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={96,14})));
  Components.Pumps.ArtificalPumpFixedT artificalPumpFixedT1(
    redeclare package Medium = Medium,
    p=200000,
    T_fixed=303.15) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={92,-32})));
  Components.Pumps.ArtificalPumpFixedT artificalPumpFixedT2(
    redeclare package Medium = Medium,
    p=200000,
    T_fixed=333.15) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-70,18})));
  Modelica.Blocks.Sources.Constant m_flow1(k=0.2) annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-114,12})));
  inner Studies.CO2MitigationStudies.Data.CO2MitigationStudiesData
    parameterAssumptions
    annotation (Placement(transformation(extent={{-120,-42},{-100,-22}})));
equation
  connect(distControlBus, distributionTwoStorageParallel.sigBusDistr)
    annotation (Line(
      points={{0,78},{16,78},{16,36.49}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(booleanConstant.y, distControlBus.buffer_on) annotation (Line(points={
          {-87,90},{-52,90},{-52,78.1},{0.1,78.1}}, color={255,0,255}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(booleanPulse1.y, distControlBus.dhw_on) annotation (Line(points={{-89,54},
          {-89,60},{0.1,60},{0.1,78.1}},     color={255,0,255}), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(artificalPumpFixedT.port_a, distributionTwoStorageParallel.portBui_out)
    annotation (Line(points={{96,24},{76,24},{76,26.2},{56,26.2}}, color={0,127,
          255}));
  connect(artificalPumpFixedT.port_b, distributionTwoStorageParallel.portBui_in)
    annotation (Line(points={{96,4},{86,4},{86,6.6},{56,6.6}}, color={0,127,255}));
  connect(distributionTwoStorageParallel.portDHW_out, artificalPumpFixedT1.port_a)
    annotation (Line(points={{56,-22.8},{73,-22.8},{73,-22},{92,-22}}, color={0,
          127,255}));
  connect(distributionTwoStorageParallel.portDHW_in, artificalPumpFixedT1.port_b)
    annotation (Line(points={{56,-42.4},{74,-42.4},{74,-42},{92,-42}}, color={0,
          127,255}));
  connect(m_flow.y, artificalPumpFixedT.m_flow_in) annotation (Line(points={{155,-4},
          {140,-4},{140,14},{107.6,14}},     color={0,0,127}));
  connect(m_flow.y, artificalPumpFixedT1.m_flow_in) annotation (Line(points={{155,-4},
          {138,-4},{138,-32},{103.6,-32}},     color={0,0,127}));
  connect(artificalPumpFixedT2.port_b, distributionTwoStorageParallel.portGen_in)
    annotation (Line(points={{-70,28},{-74,28},{-74,34},{-24,34},{-24,26.2}},
        color={0,127,255}));
  connect(distributionTwoStorageParallel.portGen_out, artificalPumpFixedT2.port_a)
    annotation (Line(points={{-24,6.6},{-50,6.6},{-50,8},{-70,8}}, color={0,127,
          255}));
  connect(m_flow1.y, artificalPumpFixedT2.m_flow_in)
    annotation (Line(points={{-103,12},{-94,12},{-94,18},{-81.6,18}},
                                                    color={0,0,127}));
  annotation (experiment(StopTime=31536000, Interval=3600));
end Test_DistributionTwoStorageParallel;
