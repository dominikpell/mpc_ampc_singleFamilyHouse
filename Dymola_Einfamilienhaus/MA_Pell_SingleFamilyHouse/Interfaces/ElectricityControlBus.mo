within MA_Pell_SingleFamilyHouse.Interfaces;
expandable connector ElectricityControlBus
  "data bus with control signals for electricity system"
  extends Modelica.Icons.SignalBus;

  Real DomesticElectricityDemand "Domestic Electricity Demand";
  Real EVDemand "Demand of electric vehicle";

  PVControlBus PVBus;
  BatControlBus BatBus;

annotation (
  defaultComponentName = "ElectricityControlBus",
  Icon(coordinateSystem(preserveAspectRatio=false)),
  Diagram(coordinateSystem(preserveAspectRatio=false)));

end ElectricityControlBus;
