within MA_Pell_SingleFamilyHouse.Interfaces;
expandable connector DistributionControlBus
  "data bus with control signals for generation model"
extends Modelica.Icons.SignalBus;
  Boolean SupplyGreaterReturn;
  Boolean buffer_on "If true, heat will be drawn from the buffer storage";
  Boolean dhw_on "If true, haet will be drawn from the dhw storage";
  Boolean TES_cooled "If true, HP will be connected to bottom layer of storage";
  Real y_TES_Valve "regulates massflow from top and bottom of storage for UFH supply temperature";
  Modelica.SIunits.Temperature T_StoDHW_top "Temperature of uppest layer of DHW storage";
  Modelica.SIunits.Temperature T_StoBuf_top "Temperature of uppest layer of buffer storage";
  Modelica.SIunits.Temperature T_StoDHW_bot "Temperature of lowest layer of DHW storage";
  Modelica.SIunits.Temperature T_StoBuf_bot "Temperature of lowest layer of buffer storage";
  Modelica.SIunits.Temperature T_mean_DHW "Mean Temperature of DHW storage";
  Modelica.SIunits.Temperature T_mean_Buf "Mean Temperature of buffer storage";
  Boolean dhwHR_on "If true, the heating rod of the dhw storage will be turned on";
annotation (
  defaultComponentName = "sigBusDistr",
  Icon(coordinateSystem(preserveAspectRatio=false)),
  Diagram(coordinateSystem(preserveAspectRatio=false)));

end DistributionControlBus;
