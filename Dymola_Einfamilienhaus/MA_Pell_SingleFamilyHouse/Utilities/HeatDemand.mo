within MA_Pell_SingleFamilyHouse.Utilities;
package HeatDemand "Models for validation during thesis"
  extends Modelica.Icons.ExamplesPackage;

  model CalcHeatingDemand
    "Model to calculate the heating demand for a given building record"
    extends Modelica.Icons.Example;

      replaceable parameter
      BuildingEnergySystems.RecordsCollection.ExampleSystemParameters systemParameters
      constrainedby
      BuildingEnergySystems.RecordsCollection.SystemParametersBaseDataDefinition(
        final ventRate=0.3) "Parameters relevant for the whole energy system"
      annotation (choicesAllMatching=true, Placement(transformation(extent={{
              76,-96},{96,-76}})));
    BuildingEnergySystems.Systems.Subsystems.InputScenario.HeatDemandScenario
      heatDemandScenario(final systemParameters=systemParameters, final
        T_const=systemParameters.TOda_nominal)
      annotation (Placement(transformation(extent={{-100,18},{-50,80}})));
    BuildingEnergySystems.Systems.Subsystems.Demand.DemandCase building(
      redeclare package MediumDHW = AixLib.Media.Water,
      redeclare package MediumZone = AixLib.Media.Air,
      final systemParameters=systemParameters,
      redeclare BuildingEnergySystems.Components.DHW.calcmFlowEquStatic
        calcmFlow)
      annotation (Placement(transformation(extent={{24,-34},{72,24}})));
    Modelica.Blocks.Interfaces.RealOutput QDemBuiSum_flow(final unit="W")
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={110,0}), iconTransformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={110,-80})));
    Modelica.Blocks.Sources.RealExpression
                                     realExpression(y=sum(building.thermalZone.PHeater))
      annotation (Placement(transformation(extent={{10,52},{32,74}})));
    AixLib.Fluid.Interfaces.PassThroughMedium passThroughMedium(redeclare
        final package Medium = AixLib.Media.Water)
      annotation (Placement(transformation(
          extent={{-6,-6},{6,6}},
          rotation=90,
          origin={-10,-18})));
    Modelica.Blocks.Sources.RealExpression realExpression1[systemParameters.nZones](
       y=building.thermalZone.PHeater)
      annotation (Placement(transformation(extent={{10,70},{32,92}})));
    Modelica.Blocks.Interfaces.RealOutput QBui_flow_nominal[systemParameters.nZones](
       each final unit="W") "Indoor air temperature" annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={110,40}), iconTransformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={110,-80})));
  equation
    connect(heatDemandScenario.inputScenBus, building.inputScenBus) annotation (
        Line(
        points={{-49.625,48.8808},{50,48.8808},{50,28},{48.72,28},{48.72,23.71}},
        color={255,204,51},
        thickness=0.5));
    connect(QDemBuiSum_flow, realExpression.y) annotation (Line(points={{110,0},
            {80,0},{80,63},{33.1,63}}, color={0,0,127}));
    connect(building.portDHW_in, passThroughMedium.port_b) annotation (Line(
          points={{24,-10.8},{6,-10.8},{6,-12},{-10,-12}}, color={0,127,255}));
    connect(building.portDHW_out, passThroughMedium.port_a) annotation (Line(
          points={{24,-22.4},{6,-22.4},{6,-24},{-10,-24}}, color={0,127,255}));
    connect(realExpression1.y, QBui_flow_nominal) annotation (Line(points={{
            33.1,81},{92,81},{92,40},{110,40}}, color={0,0,127}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false), graphics={Text(
            extent={{-130,-24},{56,-118}},
            lineColor={28,108,200},
            textString="Right click -> Parameters -> 
Select your system parameters -> 
Simulate and extract QDemand and 
array based demand for your systemParameters")}),        experiment(StopTime=31536000, Interval=3600));
  end CalcHeatingDemand;

end HeatDemand;
