within MA_Pell_SingleFamilyHouse.Interfaces;
expandable connector BatControlBus
  "data bus with control signals for BAT model"
  extends Modelica.Icons.SignalBus;
  Real InputsBattery[3] "Power Array in Battery for: 1. Self Use, 2. Total Charging Power, 3. FeedIn";
annotation (
  defaultComponentName = "BatControlBus",
  Icon(coordinateSystem(preserveAspectRatio=false)),
  Diagram(coordinateSystem(preserveAspectRatio=false)));

end BatControlBus;
