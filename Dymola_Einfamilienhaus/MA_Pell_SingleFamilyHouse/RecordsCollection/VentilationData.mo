within MA_Pell_SingleFamilyHouse.RecordsCollection;
package VentilationData
extends Modelica.Icons.RecordsPackage;
  partial record PartialVentilationBaseDataDefinition
    extends Modelica.Icons.Record;

    parameter Modelica.SIunits.Efficiency epsHex "Heat exchanger effectiveness";
    parameter Modelica.SIunits.TemperatureDifference dTSup_nominal "Nominal temperature difference between supply and room temperature";
    parameter Modelica.SIunits.PressureDifference dpHex_nominal "Nominal pressure drop on one HEX pipe";
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end PartialVentilationBaseDataDefinition;

  record DummyVentilation "DummyVentilation"
    extends PartialVentilationBaseDataDefinition(
      dTSup_nominal=10,                          dpHex_nominal=0, epsHex=0.8);
  end DummyVentilation;
end VentilationData;
