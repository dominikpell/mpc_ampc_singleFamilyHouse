within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Transfer;
package Tests
  extends Modelica.Icons.ExamplesPackage;
  model TestPressureBasedSystem
    extends Modelica.Icons.Example;
    radPressureBased radiatorTransferSystemPressureBased(redeclare package
        Medium =
          AixLib.Media.Water, redeclare
        RecordsCollection.TransferData.RadiatorTransferData parameters)
      annotation (Placement(transformation(extent={{-32,-26},{36,44}})));
    Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature
                                                           prescribedTemperature(T(
          displayUnit="K"))
                 annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=180,
          origin={58,0})));

    Modelica.Blocks.Sources.Sine     m_flow1(
      amplitude=1,
      freqHz=1/3600,
      offset=293.15 - 1)                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={86,32})));
    AixLib.Fluid.MixingVolumes.MixingVolume
                                     vol1(
      redeclare package Medium = AixLib.Media.Water,
      m_flow_nominal=sum(radiatorTransferSystemPressureBased.rad.m_flow_nominal),
      V=1,
      nPorts=2)                                    annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={-82,-16})));

    AixLib.Fluid.Sources.Boundary_pT bou1(
      redeclare package Medium = AixLib.Media.Water,
      p=200000,
      nPorts=1)                                    annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-88,20})));
  equation
    connect(prescribedTemperature.port, radiatorTransferSystemPressureBased.heatPortCon[
      1]) annotation (Line(points={{48,1.33227e-15},{50,1.33227e-15},{50,23},{
            36,23}}, color={191,0,0}));
    connect(prescribedTemperature.port, radiatorTransferSystemPressureBased.heatPortRad[
      1]) annotation (Line(points={{48,0},{50,0},{50,-5},{36,-5}}, color={191,0,
            0}));
    connect(radiatorTransferSystemPressureBased.TZone[1], m_flow1.y) annotation (
        Line(points={{39.4,38.4},{56,38.4},{56,32},{75,32}}, color={0,0,127}));
    connect(radiatorTransferSystemPressureBased.portTra_out, vol1.ports[1])
      annotation (Line(points={{-32,-5.7},{-58,-5.7},{-58,-6},{-80,-6}},   color={
            0,127,255}));
    connect(radiatorTransferSystemPressureBased.portTra_in, vol1.ports[2])
      annotation (Line(points={{-32,23},{-60,23},{-60,-6},{-84,-6}}, color={0,127,
            255}));
    connect(radiatorTransferSystemPressureBased.portTra_in, bou1.ports[1])
      annotation (Line(points={{-32,23},{-62,23},{-62,30},{-88,30}}, color={0,
            127,255}));
    connect(m_flow1.y, prescribedTemperature.T)
      annotation (Line(points={{75,32},{70,32},{70,0}}, color={0,0,127}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)),
      experiment(StopTime=3600, __Dymola_Algorithm="Dassl"));
  end TestPressureBasedSystem;
end Tests;
