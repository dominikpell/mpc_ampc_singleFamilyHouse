within MA_Pell_SingleFamilyHouse.Interfaces;
expandable connector InputScenarioBus
  "data bus with control signals for generation model"
  extends Modelica.Icons.SignalBus;

  Modelica.SIunits.MassFlowRate m_flowDHW
    "Volume flow rate demand of dhw based on input scenario [litre/hour]";
  Modelica.SIunits.Temperature TDemandDHW "Demand temperature of DHW tap";
  Real intGains[3];
  Real TSoil "Soil temperature";
  Real ElectricityDemand;
  Real EVDemand;
  AixLib.BoundaryConditions.WeatherData.Bus weaBus;
annotation (
  defaultComponentName = "inputScenBus",
  Icon(coordinateSystem(preserveAspectRatio=false)),
  Diagram(coordinateSystem(preserveAspectRatio=false)));

end InputScenarioBus;
