within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Demand.Tests;
model Test_DemandCaseOFH
  extends MA_Pell_SingleFamilyHouse.Systems.BaseClasses.PartialBESExample;
// DHW
  parameter String filename_DHW = Modelica.Utilities.Files.loadResource("modelica://HeatPumpSystemScenarioStudies/Resources/Data/TRY/00-Aachen_Normal/DHW_buffer.mat") "Path to mat file with DHW data" annotation(Dialog(group = "DHW"));

  AixLib.Fluid.MixingVolumes.MixingVolume storage_bui1(
    nPorts=2,
    redeclare package Medium = AixLib.Media.Water,
    m_flow_nominal=0.2,
    V=0.003)                 annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-66,-28})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature(T=333.15)
    annotation (Placement(transformation(extent={{-106,-64},{-86,-44}})));

  DemandCase demandCaseOFH_ThermalZoneROM(redeclare package MediumDHW =
        AixLib.Media.Water,
    systemParameters=systemParameters,
    redeclare Components.DHW.calcmFlowEquStatic calcmFlow)
    annotation (Placement(transformation(extent={{8,-48},{50,16}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature1[
    demandCaseOFH_ThermalZoneROM.systemParameters.nZones](T=298.15)
    annotation (Placement(transformation(extent={{-84,-10},{-64,10}})));
  InputScenario.Scenario scenario(systemParameters=systemParameters)
    annotation (Placement(transformation(extent={{-98,20},{-58,72}})));
equation
  connect(fixedTemperature.port, storage_bui1.heatPort) annotation (Line(points={{-86,-54},
          {-80,-54},{-80,-38},{-66,-38}},           color={191,0,0}));
  connect(demandCaseOFH_ThermalZoneROM.portDHW_in, storage_bui1.ports[1])
    annotation (Line(points={{8,-22.4},{-23,-22.4},{-23,-30},{-56,-30}}, color=
          {0,127,255}));
  connect(storage_bui1.ports[2], demandCaseOFH_ThermalZoneROM.portDHW_out)
    annotation (Line(points={{-56,-26},{-26,-26},{-26,-35.2},{8,-35.2}}, color=
          {0,127,255}));
  connect(scenario.inputScenBus, demandCaseOFH_ThermalZoneROM.sigBusDem)
    annotation (Line(
      points={{-57.7,45.9},{-52,45.9},{-52,36},{29.63,36},{29.63,15.68}},
      color={255,204,51},
      thickness=0.5));
  connect(fixedTemperature1.port, demandCaseOFH_ThermalZoneROM.heatPortCon)
    annotation (Line(points={{-64,0},{-30,0},{-30,5.76},{8,5.76}}, color={191,0,
          0}));
  connect(fixedTemperature1.port, demandCaseOFH_ThermalZoneROM.heatPortRad)
    annotation (Line(points={{-64,0},{-30,0},{-30,-6.4},{8,-6.4}}, color={191,0,
          0}));
                                                                                                                                                                   annotation(Dialog(group=
          "Building"),
              experiment(StopTime=31536000, Interval=3600));
end Test_DemandCaseOFH;
