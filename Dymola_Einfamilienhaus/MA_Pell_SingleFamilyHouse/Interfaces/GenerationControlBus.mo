within MA_Pell_SingleFamilyHouse.Interfaces;
expandable connector GenerationControlBus
  "data bus with control signals for generation model"
  extends Modelica.Icons.SignalBus;

  Modelica.SIunits.Temperature T_StoDHW_top "Temperature of uppest layer of DHW storage";
  Modelica.SIunits.Temperature T_StoBuf_top "Temperature of uppest layer of buffer storage";
  Modelica.SIunits.Temperature T_StoDHW_bot "Temperature of lowest layer of DHW storage";
  Modelica.SIunits.Temperature T_StoBuf_bot "Temperature of lowest layer of buffer storage";


  AixLib.Controls.Interfaces.VapourCompressionMachineControlBus hp_bus;
  Real hr_on "Relative input signal for the heating rod (min=0, max=1)";
  Real TSoil "Soil temperature";
  AixLib.BoundaryConditions.WeatherData.Bus weaBus "Weather Bus";
  //Modelica.SIunits.MassFlowRate mFlow[nZones] "mass flow to thermal zones";

  annotation (
  defaultComponentName = "sigBusGen",
  Icon(coordinateSystem(preserveAspectRatio=false)),
  Diagram(coordinateSystem(preserveAspectRatio=false)));

end GenerationControlBus;
