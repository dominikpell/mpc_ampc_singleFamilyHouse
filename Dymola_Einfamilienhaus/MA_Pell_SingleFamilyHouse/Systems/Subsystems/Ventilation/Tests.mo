within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Ventilation;
package Tests
  extends Modelica.Icons.ExamplesPackage;
  model DemandVentilationTest
    extends MA_Pell_SingleFamilyHouse.Systems.BaseClasses.PartialBESExample;
    replaceable ControlledDomesticVentilation        VentilationSystem(
      systemParameters=systemParameters,                               redeclare
        package MediumZone = AixLib.Media.Air,
      redeclare RecordsCollection.VentilationData.DummyVentilation parameters)
      annotation (choicesAllMatching=true, Placement(transformation(extent={{18,-48},{86,20}})));
    Demand.VentilationDemandCase demandCase(
      systemParameters=systemParameters,
      redeclare package MediumDHW = AixLib.Media.Water,
      redeclare package MediumZone = AixLib.Media.Air,
      redeclare Components.DHW.PassThrough calcmFlow)
      annotation (Placement(transformation(extent={{-84,-48},{-26,16}})));
    Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T=333.15)
      annotation (Placement(transformation(extent={{-174,-62},{-154,-42}})));
    AixLib.Fluid.MixingVolumes.MixingVolume storage_bui1(
      nPorts=2,
      redeclare package Medium = AixLib.Media.Water,
      m_flow_nominal=0.2,
      V=0.003)                 annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-134,-26})));
    InputScenario.Scenario scenario(systemParameters=systemParameters)
      annotation (Placement(transformation(extent={{-166,22},{-126,74}})));
  equation
    connect(fixedTemperature.port,storage_bui1. heatPort) annotation (Line(points={{-154,
            -52},{-134,-52},{-134,-36}},              color={191,0,0}));
    connect(scenario.inputScenBus, demandCase.sigBusDem) annotation (Line(
        points={{-125.7,47.9},{-54.13,47.9},{-54.13,15.68}},
        color={255,204,51},
        thickness=0.5));
    connect(storage_bui1.ports[1], demandCase.portDHW_in) annotation (Line(points={{-124,
            -28},{-104,-28},{-104,-22.4},{-84,-22.4}},       color={0,127,255}));
    connect(storage_bui1.ports[2], demandCase.portDHW_out) annotation (Line(
          points={{-124,-24},{-105,-24},{-105,-35.2},{-84,-35.2}}, color={0,127,255}));
    connect(scenario.inputScenBus, VentilationSystem.inputScenBus) annotation (
        Line(
        points={{-125.7,47.9},{52.34,47.9},{52.34,19.66}},
        color={255,204,51},
        thickness=0.5));
    connect(VentilationSystem.portVent_in, demandCase.portVent_in) annotation (
        Line(points={{18,0.28},{-4,0.28},{-4,9.6},{-26,9.6}}, color={0,127,255}));
    connect(VentilationSystem.portVent_out, demandCase.portVent_out)
      annotation (Line(points={{18,-27.6},{-16,-27.6},{-16,-8.96},{-26,-8.96}},
          color={0,127,255}));
    connect(demandCase.TZone, VentilationSystem.TZone) annotation (Line(points=
            {{-86.9,14.72},{-86.9,36},{6,36},{6,15.92},{14.6,15.92}}, color={0,
            0,127}));
    annotation (experiment(StopTime=2592000, __Dymola_Algorithm="Dassl"));
  end DemandVentilationTest;

  model NoVentilationTest
    extends MA_Pell_SingleFamilyHouse.Systems.BaseClasses.PartialBESExample;
    replaceable NoVentilation                                                                             VentilationSystem(
        systemParameters=systemParameters)
      annotation (choicesAllMatching=true, Placement(transformation(extent={{18,-48},{86,20}})));
    Demand.DemandCase demandCase(
      systemParameters=systemParameters,
      redeclare package MediumDHW = AixLib.Media.Water,
      redeclare package MediumZone = AixLib.Media.Air,
      redeclare Components.DHW.PassThrough calcmFlow)
      annotation (Placement(transformation(extent={{-86,-44},{-28,20}})));
    Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T=333.15)
      annotation (Placement(transformation(extent={{-174,-62},{-154,-42}})));
    AixLib.Fluid.MixingVolumes.MixingVolume storage_bui1(
      nPorts=2,
      redeclare package Medium = AixLib.Media.Water,
      m_flow_nominal=0.2,
      V=0.003)                 annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-134,-26})));
    InputScenario.Scenario scenario(systemParameters=systemParameters)
      annotation (Placement(transformation(extent={{-166,22},{-126,74}})));
  equation
    connect(fixedTemperature.port,storage_bui1. heatPort) annotation (Line(points={{-154,
            -52},{-148,-52},{-148,-36},{-134,-36}},   color={191,0,0}));
    connect(scenario.inputScenBus, demandCase.sigBusDem) annotation (Line(
        points={{-125.7,47.9},{-56.13,47.9},{-56.13,19.68}},
        color={255,204,51},
        thickness=0.5));
    connect(storage_bui1.ports[1], demandCase.portDHW_in) annotation (Line(points=
           {{-124,-28},{-104,-28},{-104,-18.4},{-86,-18.4}}, color={0,127,255}));
    connect(storage_bui1.ports[2], demandCase.portDHW_out) annotation (Line(
          points={{-124,-24},{-105,-24},{-105,-31.2},{-86,-31.2}}, color={0,127,255}));
    connect(scenario.inputScenBus, VentilationSystem.inputScenBus) annotation (
        Line(
        points={{-125.7,47.9},{52.34,47.9},{52.34,19.66}},
        color={255,204,51},
        thickness=0.5));
    connect(VentilationSystem.portVent_in, demandCase.portVent_in) annotation (
        Line(points={{18,0.28},{-4,0.28},{-4,13.6},{-28,13.6}}, color={0,127,255}));
    connect(VentilationSystem.portVent_out, demandCase.portVent_out) annotation (
        Line(points={{18,-27.6},{4,-27.6},{4,-28},{-16,-28},{-16,-4.96},{-28,-4.96}},
          color={0,127,255}));
    connect(demandCase.TZone, VentilationSystem.TZone) annotation (Line(points={{-88.9,
            18.72},{-37.45,18.72},{-37.45,15.92},{14.6,15.92}}, color={0,0,127}));
    annotation (experiment(StopTime=2592000, __Dymola_Algorithm="Dassl"));
  end NoVentilationTest;
end Tests;
