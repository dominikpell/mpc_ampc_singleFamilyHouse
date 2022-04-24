within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Demand.BaseClasses;
partial model PartialDemand "Partial demand model for HPS"
  replaceable package MediumDHW =
      Modelica.Media.Interfaces.PartialMedium
    annotation (choicesAllMatching=true);
  replaceable package MediumZone = Modelica.Media.Air.SimpleAir constrainedby
    Modelica.Media.Interfaces.PartialMedium annotation (
      __Dymola_choicesAllMatching=true);
  replaceable parameter
    RecordsCollection.SystemParametersBaseDataDefinition systemParameters
    "Parameters relevant for the whole energy system" annotation (
      choicesAllMatching=true, Placement(transformation(extent={{76,-96},{96,-76}})));
  Interfaces.DemandControlBus sigBusDem
    annotation (Placement(transformation(extent={{-24,80},{30,118}})));

  Modelica.Fluid.Interfaces.FluidPort_a portDHW_in(redeclare final package
      Medium = MediumDHW) "Inlet for the demand of DHW"
    annotation (Placement(transformation(extent={{-110,-30},{-90,-10}}),
        iconTransformation(extent={{-110,-30},{-90,-10}})));
  Modelica.Fluid.Interfaces.FluidPort_b portDHW_out(redeclare final package
      Medium = MediumDHW) "Outlet of the demand of DHW"
    annotation (Placement(transformation(extent={{-110,-92},{-90,-72}}),
        iconTransformation(extent={{-110,-70},{-90,-50}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPortCon[systemParameters.nZones] if
    systemParameters.use_transfer
    "Heat port for convective heat transfer with room air temperature"
    annotation (Placement(transformation(extent={{-110,58},{-90,78}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPortRad[systemParameters.nZones] if
    systemParameters.use_transfer
    "Heat port for radiative heat transfer with room radiation temperature"
    annotation (Placement(transformation(extent={{-110,20},{-90,40}})));
  Modelica.Blocks.Interfaces.RealOutput TZone[systemParameters.nZones](
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC") "Indoor air temperature"
                             annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,92}), iconTransformation(extent={{-10,-10},{10,10}},
        rotation=180,
        origin={-110,96})));
  Interfaces.Outputs.DemandOutputs outBusDem
    annotation (Placement(transformation(extent={{88,-12},{108,8}})));
  Modelica.Fluid.Interfaces.FluidPort_a portVent_in(redeclare final package
      Medium = MediumZone) if use_vent
                           "Inlet for the demand of ventilation"
    annotation (Placement(transformation(extent={{88,74},{108,94}}),
        iconTransformation(extent={{90,70},{110,90}})));
  Modelica.Fluid.Interfaces.FluidPort_b portVent_out(redeclare final package
      Medium = MediumZone) if use_vent
                           "Outlet of the demand of Ventilation"
    annotation (Placement(transformation(extent={{90,12},{110,32}}),
        iconTransformation(extent={{90,12},{110,32}})));
protected
    parameter Boolean use_vent "=true to use the ventilation ports";

  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-100,-2},{98,-98}},
          lineColor={0,0,0},
          lineThickness=0.5,
          fillColor={244,125,35},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-100,98},{98,2}},
          lineColor={0,0,0},
          lineThickness=0.5,
          fillColor={175,175,175},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-78,100},{-40,84}},
          lineColor={0,0,0},
          lineThickness=0.5,
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          textString="Building"),
        Text(
          extent={{-82,-4},{-44,-16}},
          lineColor={0,0,0},
          lineThickness=0.5,
          fillColor={28,108,200},
          fillPattern=FillPattern.Solid,
          textString="DHW")}));
end PartialDemand;
