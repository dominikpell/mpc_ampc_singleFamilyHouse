within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Transfer.BaseClasses;
partial model PartialTransfer "Partial transfer model for BES"
    replaceable package Medium =
      Modelica.Media.Interfaces.PartialMedium
    annotation (choicesAllMatching=true);
  parameter
    RecordsCollection.SystemParametersBaseDataDefinition systemParameters
    "Parameters relevant for the whole energy system"
    annotation (Placement(transformation(extent={{78,-98},{98,-78}})));
  Modelica.Fluid.Interfaces.FluidPort_b portTra_out(redeclare final package
      Medium = Medium) "Outlet of the transfer system"
                                                     annotation (Placement(
        transformation(extent={{-110,-52},{-90,-32}}),
                                                   iconTransformation(extent={{-110,
            -52},{-90,-32}})));
  Modelica.Fluid.Interfaces.FluidPort_a portTra_in(redeclare final package
      Medium = Medium) "Inlet to the transfer system"
                                                    annotation (Placement(
        transformation(extent={{-110,28},{-90,48}}),
                                                   iconTransformation(extent={{-110,30},
            {-90,50}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPortRad[systemParameters.nZones]
    "Heat port for radiative heat transfer with room radiation temperature"
    annotation (Placement(transformation(extent={{90,-50},{110,-30}})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPortCon[systemParameters.nZones]
    "Heat port for convective heat transfer with room air temperature"
    annotation (Placement(transformation(extent={{90,30},{110,50}}),
        iconTransformation(extent={{90,30},{110,50}})));
  Modelica.Blocks.Interfaces.RealInput  TZone[systemParameters.nZones](
    final quantity="ThermodynamicTemperature",
    final unit="K",
    displayUnit="degC")
    "Indoor air temperature" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={110,84}),  iconTransformation(extent={{-10,-10},{10,10}},
        rotation=180,
        origin={110,84})));
  Interfaces.Outputs.TransferOutputs outBusTra
    annotation (Placement(transformation(extent={{-10,-114},{10,-94}})));
  Interfaces.TransferControlBus traControlBus annotation (Placement(
        transformation(extent={{-114,66},{-88,100}}), iconTransformation(extent=
           {{-114,62},{-88,96}})));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end PartialTransfer;
