within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control.BaseClasses;
partial model PartialControl "Partial controller for HPS"
  replaceable parameter
    RecordsCollection.SystemParametersBaseDataDefinition systemParameters
    "Parameters relevant for the whole energy system" annotation (
      choicesAllMatching=true, Placement(transformation(extent={{218,-98},{238,
            -78}})));
  Interfaces.GenerationControlBus sigBusGen
    annotation (Placement(transformation(extent={{-138,-150},{-86,-56}})));
  Interfaces.DistributionControlBus sigBusDistr
    annotation (Placement(transformation(extent={{-28,-144},{30,-58}})));
  Interfaces.MPCControlBus inputScenBus
    annotation (Placement(transformation(extent={{-258,-24},{-214,22}})));
  Interfaces.Outputs.ControlOutputs outBusCtrl
    annotation (Placement(transformation(extent={{230,-10},{250,10}})));
  Interfaces.DemandControlBus sigBusDem annotation (Placement(transformation(
          extent={{156,-144},{210,-58}}), iconTransformation(extent={{156,-144},
            {210,-58}})));
  Interfaces.TransferControlBus traControlBus annotation (Placement(
        transformation(extent={{82,-144},{136,-58}}), iconTransformation(extent=
           {{78,-144},{132,-58}})));
equation
  connect(inputScenBus.weaBus, sigBusGen.weaBus) annotation (
    Line(
      points={{-235.89,-0.885},{-238,-0.885},{-238,-102.765},{-111.87,-102.765}},
      color={255,204,51},
      thickness=0.5),
    Text(
      string="%first",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right),
    Text(
      string="%second",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));

  connect(sigBusDem.inputScenario, inputScenBus) annotation (Line(
      points={{183.135,-100.785},{183.135,-128},{-236,-128},{-236,-1}},
      color={255,204,51},
      thickness=0.5));

  connect(inputScenBus.ts_T_inside_max, sigBusDem.ts_T_inside_max) annotation (
      Line(
      points={{-235.89,-0.885},{-235.89,-146},{183.135,-146},{183.135,-100.785}},
      color={255,204,51},
      thickness=0.5));

  connect(inputScenBus.ts_T_inside_min, sigBusDem.ts_T_inside_min) annotation (
      Line(
      points={{-235.89,-0.885},{-235.89,-162},{183.135,-162},{183.135,-100.785}},
      color={255,204,51},
      thickness=0.5));

  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-240,
            -100},{240,100}}), graphics={
        Rectangle(
          extent={{-240,100},{240,-100}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid,
          lineThickness=0.5), Text(
          extent={{-98,60},{106,-36}},
          lineColor={0,0,0},
          textString="%name%")}),                                Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-240,-100},{240,
            100}})));
end PartialControl;
