within MA_Pell_SingleFamilyHouse.Interfaces;
expandable connector PVControlBus
  "data bus with control signals for PV model"
  extends Modelica.Icons.SignalBus;

  AixLib.BoundaryConditions.WeatherData.Bus waeBus;
  Real DistributionPV[3] "Shares of self used, Battery Charge and FeedIn Power";

annotation (
  defaultComponentName = "PVControlBus",
  Icon(coordinateSystem(preserveAspectRatio=false)),
  Diagram(coordinateSystem(preserveAspectRatio=false)));

end PVControlBus;
