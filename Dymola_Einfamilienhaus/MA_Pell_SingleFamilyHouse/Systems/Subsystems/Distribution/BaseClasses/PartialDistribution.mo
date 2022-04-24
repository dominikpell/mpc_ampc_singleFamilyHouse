within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution.BaseClasses;
partial model PartialDistribution
  "Partial distribution model for HPS"
  parameter
    RecordsCollection.SystemParametersBaseDataDefinition systemParameters
    "Parameters relevant for the whole energy system"
    annotation (Placement(transformation(extent={{78,-98},{98,-78}})));
  replaceable package MediumDHW =
      Modelica.Media.Interfaces.PartialMedium
    annotation (choicesAllMatching=true);

  replaceable package MediumBui =
      Modelica.Media.Interfaces.PartialMedium
    annotation (choicesAllMatching=true);
  replaceable package MediumGen =
      Modelica.Media.Interfaces.PartialMedium
    annotation (choicesAllMatching=true);
  parameter Integer nParallelGen = 1 "Number of parallel loops from the generation side";
  Modelica.Fluid.Interfaces.FluidPort_a portGen_in[nParallelGen](redeclare
      final package Medium = MediumGen) "Inlet from the generation" annotation (
     Placement(transformation(extent={{-110,70},{-90,90}}), iconTransformation(
          extent={{-110,70},{-90,90}})));
  Modelica.Fluid.Interfaces.FluidPort_b portGen_out[nParallelGen](redeclare
      final package Medium = MediumGen) "Outlet to the generation" annotation (
      Placement(transformation(extent={{-110,30},{-90,50}}), iconTransformation(
          extent={{-110,30},{-90,50}})));
  Modelica.Fluid.Interfaces.FluidPort_b portBui_out(redeclare final package
      Medium = MediumBui) "Outlet for the distribution to the building"
    annotation (Placement(transformation(extent={{90,70},{110,90}}),
        iconTransformation(extent={{90,70},{110,90}})));
  Modelica.Fluid.Interfaces.FluidPort_a portBui_in(redeclare final package
      Medium = MediumBui) "Inlet for the distribution from the building"
    annotation (Placement(transformation(extent={{90,30},{110,50}}),
        iconTransformation(extent={{90,30},{110,50}})));

  Modelica.Fluid.Interfaces.FluidPort_b portDHW_out(redeclare final package
      Medium = MediumDHW) "Outlet for the distribution to the DHW" annotation (
      Placement(transformation(extent={{90,-32},{110,-12}}), iconTransformation(
          extent={{90,-30},{110,-10}})));
  Modelica.Fluid.Interfaces.FluidPort_a portDHW_in(redeclare final package
      Medium = MediumDHW) "Inet for the distribution from the DHW" annotation (
      Placement(transformation(extent={{90,-92},{110,-72}}), iconTransformation(
          extent={{90,-70},{110,-50}})));

  Interfaces.DistributionControlBus sigBusDistr
    annotation (Placement(transformation(extent={{-24,80},{24,122}})));
  Interfaces.Outputs.DistributionOutputs outBusDist
    annotation (Placement(transformation(extent={{-10,-110},{10,-90}})));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end PartialDistribution;
