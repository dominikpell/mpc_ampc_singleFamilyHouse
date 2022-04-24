within MA_Pell_SingleFamilyHouse.Interfaces;
expandable connector TransferControlBus
  "data bus with control signals for generation model"
  extends Modelica.Icons.SignalBus;
  Boolean transfer_active [:];
  Boolean SupplyGreaterReturn;
  Real ts_T_inside;
  Real T_supply_UFH_Mea;
annotation (
  defaultComponentName = "traControlBus",
  Icon(coordinateSystem(preserveAspectRatio=false)),
  Diagram(coordinateSystem(preserveAspectRatio=false)));

end TransferControlBus;
