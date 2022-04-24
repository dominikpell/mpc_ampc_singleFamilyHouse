within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Ventilation.BaseClasses;
partial model PartialVentilationSystem
  "Base model for all ventilation systems"
  parameter
    RecordsCollection.SystemParametersBaseDataDefinition systemParameters
    "Parameters relevant for the whole energy system"
    annotation (Placement(transformation(extent={{78,-98},{98,-78}})));
  replaceable package MediumZone = Modelica.Media.Air.SimpleAir constrainedby
    Modelica.Media.Interfaces.PartialMedium annotation (
      __Dymola_choicesAllMatching=true);

  replaceable
    RecordsCollection.VentilationData.PartialVentilationBaseDataDefinition
    parameters annotation (choicesAllMatching=true, Placement(transformation(
          extent={{40,-98},{60,-78}})));

  Interfaces.Outputs.VentilationOutputs outBusVen
    annotation (Placement(transformation(extent={{88,-16},{116,14}})));
  Interfaces.InputScenarioBus inputScenBus
    annotation (Placement(transformation(extent={{-14,86},{16,112}})));
  Modelica.Fluid.Interfaces.FluidPort_b portVent_out(redeclare final package
      Medium = MediumZone) if use_vent
                           "Outlet of the demand of Ventilation"
    annotation (Placement(transformation(extent={{-110,-50},{-90,-30}}),
        iconTransformation(extent={{-110,-50},{-90,-30}})));
  Modelica.Fluid.Interfaces.FluidPort_a portVent_in(redeclare final package
      Medium = MediumZone) if use_vent
                           "Inlet for the demand of ventilation"
    annotation (Placement(transformation(extent={{-110,32},{-90,52}}),
        iconTransformation(extent={{-110,32},{-90,52}})));

  Modelica.Blocks.Interfaces.RealInput  TZone[systemParameters.nZones](
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Indoor air temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-110,90}), iconTransformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-110,88})));
protected
      parameter Boolean use_vent
                             "=true to use the ventilation ports";

  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end PartialVentilationSystem;
