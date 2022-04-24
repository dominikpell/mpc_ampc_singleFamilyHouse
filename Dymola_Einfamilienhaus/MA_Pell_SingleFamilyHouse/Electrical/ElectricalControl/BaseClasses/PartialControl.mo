within MA_Pell_SingleFamilyHouse.Electrical.ElectricalControl.BaseClasses;
partial model PartialControl "Partial electrical control model"
  Modelica.Blocks.Interfaces.RealInput SOCBat "SOC of battery" annotation (
      Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={-126,104})));
  Modelica.Blocks.Interfaces.RealInput BuiEleLoadAC
    "Electricity (AC) demand of building" annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={0,104})));
  Modelica.Blocks.Interfaces.RealInput PVPowerDC
    "Power output (DC) of PV plant" annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={68,102})));
  Modelica.Blocks.Interfaces.RealInput GenEleLoadAC
    "Electricity (AC) demand of HVAC system" annotation (Placement(
        transformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={-54,104})));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-240,
            -100},{240,100}}), graphics={
        Rectangle(
          extent={{-240,100},{240,-100}},
          lineColor={0,0,0},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid,
          lineThickness=0.5), Text(
          extent={{-92,58},{112,-38}},
          lineColor={0,0,0},
          textString="%name%")}),                                Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-240,-100},{240,
            100}})));
end PartialControl;
