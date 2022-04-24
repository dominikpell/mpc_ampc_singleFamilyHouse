within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Generation.BaseClasses;
partial model PartialGeneration "Partial generation model for HPS"
  replaceable package MediumGen =
      Modelica.Media.Interfaces.PartialMedium
    annotation (choicesAllMatching=true);
  Interfaces.GenerationControlBus sigBusGen
    annotation (Placement(transformation(extent={{-18,78},{22,118}})));
  Modelica.Fluid.Interfaces.FluidPort_b portGen_out[nParallel](redeclare final
      package Medium = MediumGen) "Outlet of the generation" annotation (
      Placement(transformation(extent={{90,70},{110,90}}), iconTransformation(
          extent={{90,70},{110,90}})));
  Modelica.Fluid.Interfaces.FluidPort_a portGen_in[nParallel](redeclare final
      package Medium = MediumGen) "Inlet to the generation" annotation (
      Placement(transformation(extent={{90,-12},{110,8}}), iconTransformation(
          extent={{90,30},{110,50}})));
  Interfaces.Outputs.GenerationOutputs outBusGen
    annotation (Placement(transformation(extent={{-10,-110},{10,-90}})));
  parameter
    RecordsCollection.SystemParametersBaseDataDefinition systemParameters
    "Parameters relevant for the whole energy system"
    annotation (Placement(transformation(extent={{78,-98},{98,-78}})));

  parameter Integer nParallel = 1 "Number of parallel loops which generate heat";

  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end PartialGeneration;
