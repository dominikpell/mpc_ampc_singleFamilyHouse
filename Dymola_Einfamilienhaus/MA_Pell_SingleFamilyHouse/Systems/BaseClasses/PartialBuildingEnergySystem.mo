within MA_Pell_SingleFamilyHouse.Systems.BaseClasses;
partial model PartialBuildingEnergySystem "Partial BES"
  extends Modelica.Icons.Example;

  // Replaceable packages
  replaceable package MediumHyd = AixLib.Media.Water constrainedby
    Modelica.Media.Interfaces.PartialMedium annotation (
      __Dymola_choicesAllMatching=true);
  replaceable package MediumZone = AixLib.Media.Air constrainedby
    Modelica.Media.Interfaces.PartialMedium annotation (__Dymola_choicesAllMatching=true);
  replaceable
    RecordsCollection.ParameterAssumptionsBaseDefinition parameterStudy
    "Parameters changed in the study / analysis" annotation (choicesAllMatching=
       true, Placement(transformation(extent={{422,-256},{474,-196}})));
  replaceable package MediumDHW = AixLib.Media.Water constrainedby
    Modelica.Media.Interfaces.PartialMedium
    annotation (__Dymola_choicesAllMatching=true);
  // Parameters
  replaceable parameter
    RecordsCollection.SystemParametersBaseDataDefinition systemParameters
    "Parameters relevant for the whole energy system" annotation (
      choicesAllMatching=true, Placement(transformation(extent={{338,-256},{390,
            -196}})));

  // Subsystems
  replaceable
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution.BaseClasses.PartialDistribution
    Distribution if systemParameters.use_distribution constrainedby
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution.BaseClasses.PartialDistribution(
    redeclare final package MediumDHW = MediumDHW,
    redeclare final package MediumBui = MediumHyd,
    redeclare final package MediumGen = MediumHyd,
    final systemParameters=systemParameters) annotation (choicesAllMatching=
        true, Placement(transformation(extent={{-100,-146},{-2,10}})));
  replaceable
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control.BaseClasses.PartialControl
    Control if systemParameters.use_control constrainedby
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control.BaseClasses.PartialControl(
      final systemParameters=systemParameters) annotation (choicesAllMatching=
        true, Placement(transformation(extent={{-162,54},{138,92}})));
  replaceable
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Generation.BaseClasses.PartialGeneration
    Generation if systemParameters.use_generation constrainedby
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Generation.BaseClasses.PartialGeneration(
      redeclare final package MediumGen = MediumHyd, final systemParameters=
        systemParameters) annotation (choicesAllMatching=true, Placement(
        transformation(extent={{-236,-144},{-122,10}})));
  replaceable
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Demand.BaseClasses.PartialDemand
    Demand if systemParameters.use_demand constrainedby
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Demand.BaseClasses.PartialDemand(
    redeclare final package MediumDHW = MediumDHW,
    redeclare final package MediumZone = MediumZone,
    final systemParameters=systemParameters) annotation (choicesAllMatching=
        true, Placement(transformation(extent={{104,-144},{192,10}})));
                                                                         replaceable
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Transfer.BaseClasses.PartialTransfer
    Transfer if systemParameters.use_transfer constrainedby
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Transfer.BaseClasses.PartialTransfer(
      redeclare final package Medium = MediumHyd, final systemParameters=
        systemParameters) annotation (choicesAllMatching=true, Placement(
        transformation(extent={{22,-46},{78,10}})));
  replaceable Subsystems.Ventilation.BaseClasses.PartialVentilationSystem
    Ventilation(redeclare package MediumZone = MediumZone,
      final systemParameters=systemParameters) if systemParameters.use_ventilation
    annotation (choicesAllMatching=true, Placement(transformation(extent={{220,-58},
            {290,8}})));
  // Outputs
  Interfaces.Outputs.SystemOutputs outputs(nZones=systemParameters.nZones)
    annotation (Placement(transformation(extent={{446,-30},{512,30}}),
        iconTransformation(extent={{446,-30},{512,30}})));
  AixLib.Fluid.Interfaces.PassThroughMedium passThroughMedium(redeclare final
      package Medium = MediumDHW) if not systemParameters.use_transfer
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={68,-100})));


equation
  connect(Control.sigBusGen, Generation.sigBusGen) annotation (
      Line(
      points={{-82,53.43},{-82,27.6},{-177.86,27.6},{-177.86,8.46}},
      color={255,204,51},
      thickness=0.5));
  connect(Control.sigBusDistr, Distribution.sigBusDistr)
    annotation (Line(
      points={{-11.375,53.81},{-10,53.81},{-10,30},{-51,30},{-51,10.78}},
      color={255,204,51},
      thickness=0.5));
  connect(Generation.portGen_out, Distribution.portGen_in) annotation (Line(
        points={{-122,-5.4},{-114,-5.4},{-114,-4},{-108,-4},{-108,-5.6},{-100,-5.6}},
                                                              color={0,127,255}));
  connect(Generation.portGen_in, Distribution.portGen_out) annotation (Line(
        points={{-122,-36.2},{-100,-36.2},{-100,-36.8}},            color={0,127,
          255}));
  connect(Distribution.portDHW_out, Demand.portDHW_in)
    annotation (Line(points={{-2,-83.6},{86,-83.6},{86,-82.4},{104,-82.4}},
                                                       color={0,127,255}));
  connect(Distribution.portDHW_in, Demand.portDHW_out)
    annotation (Line(points={{-2,-114.8},{104,-114.8},{104,-113.2}},
                                                       color={0,127,255}));

  connect(Transfer.heatPortCon, Demand.heatPortCon) annotation (Line(points={{78,-6.8},
          {96,-6.8},{96,-14.64},{104,-14.64}},            color={191,0,0}));
  connect(Transfer.heatPortRad, Demand.heatPortRad) annotation (Line(points={{78,
          -29.2},{98,-29.2},{98,-43.9},{104,-43.9}},  color={191,0,0}));
  connect(Distribution.portBui_out, Transfer.portTra_in) annotation (Line(
        points={{-2,-5.6},{22,-5.6},{22,-6.8}}, color={0,127,255}));
  connect(Transfer.portTra_out, Distribution.portBui_in) annotation (Line(
        points={{22,-29.76},{22,-36.8},{-2,-36.8}},
                                                 color={0,127,255}));

  connect(Demand.TZone, Transfer.TZone) annotation (Line(points={{99.6,6.92},{95.8,
          6.92},{95.8,5.52},{80.8,5.52}},             color={0,0,127}));
  connect(Generation.outBusGen, outputs.outputsGen) annotation (Line(
      points={{-179,-144},{-179,-176},{408,-176},{408,0},{444,0},{444,0.15},{
          479.165,0.15}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));

  connect(Distribution.outBusDist, outputs.outputsDist) annotation (Line(
      points={{-51,-146},{-51,-170},{398,-170},{398,0},{438,0},{438,0.15},{
          479.165,0.15}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(Transfer.outBusTra, outputs.outputsTra) annotation (Line(
      points={{50,-47.12},{50,-164},{388,-164},{388,0.15},{479.165,0.15}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(Demand.outBusDem, outputs.outputsDem) annotation (Line(
      points={{191.12,-68.54},{200,-68.54},{200,-68},{208,-68},{208,-158},{376,
          -158},{376,0},{428,0},{428,0.15},{479.165,0.15}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(Control.outBusCtrl, outputs.outputsCtrl) annotation (Line(
      points={{138,73},{436,73},{436,0.15},{479.165,0.15}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(Ventilation.outBusVen, outputs.outputsVen) annotation (Line(
      points={{290.7,-25.33},{290.7,-26},{364,-26},{364,0},{400,0},{400,0.15},{
          479.165,0.15}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));

  connect(Demand.portVent_in, Ventilation.portVent_in) annotation (Line(points={{192,
          -5.4},{206,-5.4},{206,-11.14},{220,-11.14}},     color={0,127,255}));
  connect(Ventilation.portVent_out, Demand.portVent_out) annotation (Line(
        points={{220,-38.2},{206,-38.2},{206,-50.06},{192,-50.06}},
                                                                color={0,127,
          255}));

  connect(Demand.TZone, Ventilation.TZone) annotation (Line(points={{99.6,6.92},
          {92,6.92},{92,18},{210,18},{210,4.04},{216.5,4.04}},    color={0,0,
          127}));
  connect(passThroughMedium.port_a, Demand.portDHW_out) annotation (Line(points={{68,-110},
          {66,-110},{66,-113.2},{104,-113.2}},       color={0,127,255}));
  connect(passThroughMedium.port_b, Demand.portDHW_in) annotation (Line(points={{68,-90},
          {68,-82},{104,-82},{104,-82.4}},           color={0,127,255}));
  connect(Control.sigBusDem, Demand.sigBusDem) annotation (Line(
      points={{102.375,53.81},{102.375,44},{149.32,44},{149.32,9.23}},
      color={255,204,51},
      thickness=0.5));
  connect(Control.traControlBus, Transfer.traControlBus) annotation (Line(
      points={{53.625,53.81},{53.625,24},{8,24},{8,4.12},{21.72,4.12}},
      color={255,204,51},
      thickness=0.5));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-480,-260},
            {480,180}})), Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-480,-260},{480,180}})));
end PartialBuildingEnergySystem;
