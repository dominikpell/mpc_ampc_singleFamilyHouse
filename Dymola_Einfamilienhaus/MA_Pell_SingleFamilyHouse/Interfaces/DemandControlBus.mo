within MA_Pell_SingleFamilyHouse.Interfaces;
expandable connector DemandControlBus
   "data bus with control signals for demand model"
   extends Modelica.Icons.SignalBus;

   Real ts_T_inside_max;
   Real ts_T_inside_min;
   InputScenarioBus inputScenario;

   annotation (
   defaultComponentName = "sigBusDem",
   Icon(coordinateSystem(preserveAspectRatio=false)),
   Diagram(coordinateSystem(preserveAspectRatio=false)));

end DemandControlBus;
