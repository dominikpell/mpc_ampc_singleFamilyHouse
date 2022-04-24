within MA_Pell_SingleFamilyHouse.RecordsCollection;
partial record ParameterAssumptionsBaseDefinition
  "Partial record for all parameters where you have to assume a certain value, hence all modelica parameters except the optimization variables"
  extends Modelica.Icons.Record;

  annotation (Evaluate=false, defaultComponentName = "baseParameterAssumptions", Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end ParameterAssumptionsBaseDefinition;
