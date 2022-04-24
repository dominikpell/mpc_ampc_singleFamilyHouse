within MA_Pell_SingleFamilyHouse.Electrical;
package PVSystem
  extends Modelica.Icons.Package;

  model PVSystem
    "Model that determines the DC performance of a Silicium-based PV array"

   replaceable parameter AixLib.DataBase.SolarElectric.PVBaseDataDefinition data
   constrainedby AixLib.DataBase.SolarElectric.PVBaseDataDefinition
   "PV Panel data definition"
                             annotation (choicesAllMatching);

   replaceable model IVCharacteristics =
      MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.PartialIVCharacteristics
      "Model for determining the I-V characteristics of a PV array" annotation (choicesAllMatching=
      true);

   replaceable model CellTemperature =
      MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.PartialCellTemperature
      "Model for determining the cell temperature of a PV array" annotation (choicesAllMatching=
      true, Dialog(tab="Mounting"));

   parameter Integer n_mod
      "Number of connected PV modules";
   parameter Modelica.SIunits.Angle til
   "Surface's tilt angle (0:flat)"
    annotation (Dialog(tab="Mounting"));
   parameter Modelica.SIunits.Angle azi
     "Surface's azimut angle (0:South)"
     annotation (Dialog(tab="Mounting"));
   parameter Modelica.SIunits.Angle lat
   "Location's Latitude"
     annotation (Dialog(tab="Location"));
   parameter Modelica.SIunits.Angle lon
   "Location's Longitude"
     annotation (Dialog(tab="Location"));
   parameter Real alt(final quantity="Length", final unit="m")
     "Site altitude in Meters, default= 1"
     annotation (Dialog(tab="Location"));
   parameter Modelica.SIunits.Time timZon(displayUnit="h")=timZon
      "Time zone. Should be equal with timZon in ReaderTMY3, if PVSystem and ReaderTMY3 are used together." annotation (Dialog(tab="Location"));
   parameter Real groRef(final unit="1") = 0.2
    "Ground reflectance (default=0.2)
  Urban environment: 0.14 - 0.22
  Grass: 0.15 - 0.25
  Fresh grass: 0.26
  Fresh snow: 0.82
  Wet snow: 0.55-0.75
  Dry asphalt: 0.09-0.15
  Wet Asphalt: 0.18
  Concrete: 0.25-0.35
  Red tiles: 0.33
  Aluminum: 0.85
  Copper: 0.74
  New galvanized steel: 0.35
  Very dirty galvanized steel: 0.08"
    annotation (Dialog(tab="Location"));

    parameter Boolean use_ParametersGlaz=false
      "= false if standard values for glazing can be used" annotation(choices(checkBox=true),Dialog(tab="Glazing"));

    parameter Real glaExtCoe(final unit="1/m") = 4
    "Glazing extinction coefficient (for glass = 4)" annotation(Dialog(enable=
            use_ParametersGlaz, tab="Glazing"));

    parameter Real glaThi(final unit="m") = 0.002
    "Glazing thickness (for most cells = 0.002 m)" annotation(Dialog(enable=
            use_ParametersGlaz, tab="Glazing"));

    parameter Real refInd(final unit="1", min=0) = 1.526
    "Effective index of refraction of the cell cover (glass = 1.526)" annotation(Dialog(enable=
            use_ParametersGlaz, tab="Glazing"));

    IVCharacteristics iVCharacteristics(final n_mod=n_mod,
    final data=data)
      "Model for determining the I-V characteristics of a PV array" annotation (
        Placement(transformation(extent={{26,12},{46,32}},   rotation=0)));

    CellTemperature cellTemperature(final data=data)
      "Model for determining the cell temperature of a PV array" annotation (
        Placement(transformation(extent={{4,68},{24,88}},    rotation=0)));

    BaseClasses.PVRadiationHorizontal    pVRadiationHorizontalTRY(
     final lat = lat,
     final lon = lon,
     final alt = alt,
     final til = til,
     final azi = azi,
     final groRef = groRef,
     final timZon = timZon,
     final glaExtCoe=glaExtCoe,
     final glaThi=glaThi,
     final refInd=refInd)
     "Radiation and absorptance model for PV simulations"
      annotation (Placement(transformation(extent={{-62,34},{-42,54}})));

    AixLib.BoundaryConditions.WeatherData.Bus waeBus
      annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
    Modelica.Blocks.Math.Product product1
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-50,-70})));
    Modelica.Blocks.Math.Product product2
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={0,-70})));
    Modelica.Blocks.Math.Product product3
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={50,-70})));
    Modelica.Blocks.Interfaces.RealOutput DCOutputPowerChargeBat(final
        quantity="Power", final unit="W") "DC output power of the PV array"
      annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
    Modelica.Blocks.Interfaces.RealOutput DCOutputPowerFeedIn(final quantity=
          "Power", final unit="W") "DC output power of the PV array"
      annotation (Placement(transformation(extent={{100,-10},{120,10}})));
    Modelica.Blocks.Interfaces.RealOutput DCOutputPowerUse(final quantity=
          "Power", final unit="W") "DC output power of the PV array"
      annotation (Placement(transformation(extent={{100,50},{120,70}})));
    Modelica.Blocks.Interfaces.RealInput Percentage_Use annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-60,-110}), iconTransformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-60,-110})));
    Modelica.Blocks.Interfaces.RealInput Percentage_ChBat annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={60,-110}), iconTransformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={60,-110})));
    Modelica.Blocks.Interfaces.RealInput Percentage_FeedIn annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={0,-110}), iconTransformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={0,-110})));
  equation

    connect(pVRadiationHorizontalTRY.radTil, iVCharacteristics.radTil)
      annotation (Line(points={{-41,38},{-28,38},{-28,-40},{-6,-40},{-6,14},{24,14}},
                                                                   color={0,0,127}));
    connect(pVRadiationHorizontalTRY.absRadRat, iVCharacteristics.absRadRat)
      annotation (Line(points={{-41,50},{-22,50},{-22,18},{24,18}},  color={0,0,127}));
    connect(pVRadiationHorizontalTRY.radTil, cellTemperature.radTil)
      annotation (Line(points={{-41,38},{-12,38},{-12,69.8},{2,69.8}}, color={0,0,127}));
    connect(iVCharacteristics.eta, cellTemperature.eta)
      annotation (Line(points={{47,16},{60,16},{60,54},{-4,54},{-4,74},{2,74},{2,73.8}},    color={0,0,127}));
    connect(waeBus.TDryBul, cellTemperature.T_a) annotation (
        Line(
        points={{-100,0},{-86,0},{-86,0},{-72,0},{-72,87.4},{2,87.4}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{-6,3},{-6,3}},
        horizontalAlignment=TextAlignment.Right));

    connect(waeBus.winSpe, cellTemperature.winVel) annotation (
        Line(
        points={{-100,0},{-70,0},{-70,83.9},{2,83.9}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{-6,3},{-6,3}},
        horizontalAlignment=TextAlignment.Right));
    connect(waeBus.HGloHor, pVRadiationHorizontalTRY.radHor)
      annotation (Line(
        points={{-100,0},{-96,0},{-96,-12},{-64,-12},{-64,50}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{-3,6},{-3,6}},
        horizontalAlignment=TextAlignment.Right));
    connect(cellTemperature.T_c, iVCharacteristics.T_c) annotation (Line(points={{
            26,78},{38,78},{38,46},{4,46},{4,26},{24,26}}, color={0,0,127}));
    connect(iVCharacteristics.DCOutputPower, product1.u2) annotation (Line(points=
           {{47,28},{64,28},{64,-52},{-34,-52},{-34,-90},{-44,-90},{-44,-82}},
          color={0,0,127}));
    connect(product3.u2, iVCharacteristics.DCOutputPower) annotation (Line(points={{56,-82},
            {56,-88},{64,-88},{64,28},{47,28}},          color={0,0,127}));
    connect(product2.u2, iVCharacteristics.DCOutputPower) annotation (Line(points={{6,-82},
            {6,-88},{24,-88},{24,-52},{64,-52},{64,28},{47,28}},         color={0,
            0,127}));
    connect(product1.y, DCOutputPowerUse) annotation (Line(points={{-50,-59},{-50,
            -44},{80,-44},{80,60},{110,60}}, color={0,0,127}));
    connect(product2.y, DCOutputPowerFeedIn) annotation (Line(points={{8.88178e-16,
            -59},{8.88178e-16,-46},{84,-46},{84,0},{110,0}}, color={0,0,127}));
    connect(product3.y, DCOutputPowerChargeBat) annotation (Line(points={{50,-59},
            {72,-59},{72,-60},{110,-60}}, color={0,0,127}));
    connect(product3.u1, Percentage_ChBat) annotation (Line(points={{44,-82},{44,-96},
            {60,-96},{60,-110}}, color={0,0,127}));
    connect(Percentage_Use, product1.u1) annotation (Line(points={{-60,-110},{-60,
            -92},{-56,-92},{-56,-82}}, color={0,0,127}));
    connect(Percentage_FeedIn, product2.u1) annotation (Line(points={{0,-110},{0,-88},
            {-6,-88},{-6,-82}}, color={0,0,127}));
    annotation (Icon(graphics={
          Rectangle(
            lineColor={200,200,200},
            fillColor={248,248,248},
            fillPattern=FillPattern.HorizontalCylinder,
            extent={{-100.0,-100.0},{100.0,100.0}},
            radius=25.0),
          Rectangle(
            lineColor={128,128,128},
            extent={{-100.0,-100.0},{100.0,100.0}},
            radius=25.0),      Polygon(points={{-80,-80},{-40,80},{80,80},{40,-80},
                {-80,-80}}, lineColor={0,0,0}),
          Line(points={{-60,-76},{-20,76}}, color={0,0,0}),
          Line(points={{-34,-76},{6,76}}, color={0,0,0}),
          Line(points={{-8,-76},{32,76}}, color={0,0,0}),
          Line(points={{16,-76},{56,76}}, color={0,0,0}),
          Line(points={{-38,60},{68,60}}, color={0,0,0}),
          Line(points={{-44,40},{62,40}}, color={0,0,0}),
          Line(points={{-48,20},{58,20}}, color={0,0,0}),
          Line(points={{-54,0},{52,0}}, color={0,0,0}),
          Line(points={{-60,-20},{46,-20}}, color={0,0,0}),
          Line(points={{-64,-40},{42,-40}}, color={0,0,0}),
          Line(points={{-70,-60},{36,-60}}, color={0,0,0})}),
                                 Documentation(info="<html><h4>
  <span style=\"color: #008000\">Overview</span>
</h4>
<p>
  Model that determines the DC performance of a PV array.
</p>
<h4>
  Concept
</h4>
<p>
  Model consists of a model determining the IV Characteristic, a model
  to calculate the cell temperature and a model to calculate the
  irradiance and absorption ratio for the PV module.
</p>
<h4>
  1. IV Characteristic:
</h4>
<p>
  Model for determining the I-V characteristics of a PV array based on
  Batzelis et al., De Soto et al. and Boyd.
</p>
<h4>
  2. Cell Temperature calculation:
</h4>
<p>
  Two cell temperature models are implemented and should be chosen
  depending on the module's topology:
</p>
<p>
  CellTemperatureOpenRack:
</p>
<p>
  Module is installed on open rack based on Duffie et al.. Here, the
  resulting cell temperature is usually lower compared to the cell
  temperature model <i>CellTemperatureMountingCloseToGround</i>
  resulting in higher efficiencies.
</p>
<p>
  CellTemperatureMountingCloseToGround:
</p>
<p>
  Module is installed close to ground (e.g. on roof) based on King et
  al.
</p>
<p>
  CellTemperatureMountingContactToGround:
</p>
<p>
  Module is installed in contact to ground (e.g. integrated in roof)
  based on King et al.
</p>
<p>
  If line losses are not known, the model
  CellTemperatureMountingCloseToGround can be used for a more
  conservative estimation of PV DC power output. This is due to the
  fact that line losses are not included in the calculation process.
</p>
<h4>
  Known limitations
</h4>
<ul>
  <li>Model does not include line losses and decreasing panel
  efficiency due to shading! This leads to the fact that model usually
  overestimates real DC power.
  </li>
  <li>Some parameter combinations result in high peaks for variables
  such as V_mp, I_mp and T_c. The output power is therefore limited to
  the reasonable values 0 and P_mp0*1.05, with 5 &amp;percnt; being a
  common tolerance for power at MPP.
  </li>
</ul>
<h4>
  References
</h4>
<p>
  A Method for the analytical extraction of the Single-Diode PV model
  parameters. by Batzelis, Efstratios I. ; Papathanassiou, Stavros A.
</p>
<p>
  Improvement and validation of a model for photovoltaic array
  performance. by De Soto, W. ; Klein, S. A. ; Beckman, W. A.
</p>
<p>
  Performance Data from the NIST Photovoltaic Arrays and Weather
  Station. by Boyd, M.
</p>
<p>
  SANDIA REPORT SAND 2004-3535 Unlimited Release Printed December 2004
  Photovoltaic Array Performance Model. (2005). by King, D. L. et al.
</p>
<p>
  Solar engineering of thermal processes. by Duffie, John A. ; Beckman,
  W. A.
</p>
</html>",
  revisions="<html><ul>
  <li>
    <i>May 6, 2021&#160;</i> by Laura Maier:<br/>
    Finalization of the model
  </li>
  <li>
    <i>April, 2020&#160;</i> by Arnold Fütterer:<br/>
    General changes to align the model with AixLib standards (see
    <a href=\"https://github.com/RWTH-EBC/AixLib/issues/767\">issue
    767</a>).
  </li>
  <li>
    <i>August, 2019&#160;</i> by Michael Kratz:<br/>
    First implementation (see <a href=
    \"https://github.com/RWTH-EBC/AixLib/issues/767\">issue 767</a>).
  </li>
</ul>
</html>"));
  end PVSystem;

  model PVSystem_ref
    "Model that determines the DC performance of a Silicium-based PV array"

   replaceable parameter AixLib.DataBase.SolarElectric.PVBaseDataDefinition data
   constrainedby AixLib.DataBase.SolarElectric.PVBaseDataDefinition
   "PV Panel data definition"
                             annotation (choicesAllMatching);

   replaceable model IVCharacteristics =
      MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.PartialIVCharacteristics
      "Model for determining the I-V characteristics of a PV array" annotation (choicesAllMatching=
      true);

   replaceable model CellTemperature =
      MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.PartialCellTemperature
      "Model for determining the cell temperature of a PV array" annotation (choicesAllMatching=
      true, Dialog(tab="Mounting"));

   parameter Integer n_mod
      "Number of connected PV modules";
   parameter Modelica.SIunits.Angle til
   "Surface's tilt angle (0:flat)"
    annotation (Dialog(tab="Mounting"));
   parameter Modelica.SIunits.Angle azi
     "Surface's azimut angle (0:South)"
     annotation (Dialog(tab="Mounting"));
   parameter Modelica.SIunits.Angle lat
   "Location's Latitude"
     annotation (Dialog(tab="Location"));
   parameter Modelica.SIunits.Angle lon
   "Location's Longitude"
     annotation (Dialog(tab="Location"));
   parameter Real alt(final quantity="Length", final unit="m")
     "Site altitude in Meters, default= 1"
     annotation (Dialog(tab="Location"));
   parameter Modelica.SIunits.Time timZon(displayUnit="h")=timZon
      "Time zone. Should be equal with timZon in ReaderTMY3, if PVSystem and ReaderTMY3 are used together." annotation (Dialog(tab="Location"));
   parameter Real groRef(final unit="1") = 0.2
    "Ground reflectance (default=0.2)
  Urban environment: 0.14 - 0.22
  Grass: 0.15 - 0.25
  Fresh grass: 0.26
  Fresh snow: 0.82
  Wet snow: 0.55-0.75
  Dry asphalt: 0.09-0.15
  Wet Asphalt: 0.18
  Concrete: 0.25-0.35
  Red tiles: 0.33
  Aluminum: 0.85
  Copper: 0.74
  New galvanized steel: 0.35
  Very dirty galvanized steel: 0.08"
    annotation (Dialog(tab="Location"));

    parameter Boolean use_ParametersGlaz=false
      "= false if standard values for glazing can be used" annotation(choices(checkBox=true),Dialog(tab="Glazing"));

    parameter Real glaExtCoe(final unit="1/m") = 4
    "Glazing extinction coefficient (for glass = 4)" annotation(Dialog(enable=
            use_ParametersGlaz, tab="Glazing"));

    parameter Real glaThi(final unit="m") = 0.002
    "Glazing thickness (for most cells = 0.002 m)" annotation(Dialog(enable=
            use_ParametersGlaz, tab="Glazing"));

    parameter Real refInd(final unit="1", min=0) = 1.526
    "Effective index of refraction of the cell cover (glass = 1.526)" annotation(Dialog(enable=
            use_ParametersGlaz, tab="Glazing"));

    IVCharacteristics iVCharacteristics(final n_mod=n_mod,
    final data=data)
      "Model for determining the I-V characteristics of a PV array" annotation (
        Placement(transformation(extent={{26,12},{46,32}},   rotation=0)));

    CellTemperature cellTemperature(final data=data)
      "Model for determining the cell temperature of a PV array" annotation (
        Placement(transformation(extent={{4,68},{24,88}},    rotation=0)));

    BaseClasses.PVRadiationHorizontal    pVRadiationHorizontalTRY(
     final lat = lat,
     final lon = lon,
     final alt = alt,
     final til = til,
     final azi = azi,
     final groRef = groRef,
     final timZon = timZon,
     final glaExtCoe=glaExtCoe,
     final glaThi=glaThi,
     final refInd=refInd)
     "Radiation and absorptance model for PV simulations"
      annotation (Placement(transformation(extent={{-62,34},{-42,54}})));

    AixLib.BoundaryConditions.WeatherData.Bus waeBus
      annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
    Modelica.Blocks.Interfaces.RealOutput DCOutputPower(final quantity="Power",
        final unit="W") "DC output power of the PV array"
      annotation (Placement(transformation(extent={{100,-10},{120,10}})));
  equation

    connect(pVRadiationHorizontalTRY.radTil, iVCharacteristics.radTil)
      annotation (Line(points={{-41,38},{-28,38},{-28,-40},{-6,-40},{-6,14},{24,14}},
                                                                   color={0,0,127}));
    connect(pVRadiationHorizontalTRY.absRadRat, iVCharacteristics.absRadRat)
      annotation (Line(points={{-41,50},{-22,50},{-22,18},{24,18}},  color={0,0,127}));
    connect(pVRadiationHorizontalTRY.radTil, cellTemperature.radTil)
      annotation (Line(points={{-41,38},{-12,38},{-12,69.8},{2,69.8}}, color={0,0,127}));
    connect(iVCharacteristics.eta, cellTemperature.eta)
      annotation (Line(points={{47,16},{60,16},{60,54},{-4,54},{-4,74},{2,74},{2,73.8}},    color={0,0,127}));
    connect(waeBus.TDryBul, cellTemperature.T_a) annotation (
        Line(
        points={{-100,0},{-86,0},{-86,0},{-72,0},{-72,87.4},{2,87.4}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{-6,3},{-6,3}},
        horizontalAlignment=TextAlignment.Right));

    connect(waeBus.winSpe, cellTemperature.winVel) annotation (
        Line(
        points={{-100,0},{-70,0},{-70,83.9},{2,83.9}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{-6,3},{-6,3}},
        horizontalAlignment=TextAlignment.Right));
    connect(waeBus.HGloHor, pVRadiationHorizontalTRY.radHor)
      annotation (Line(
        points={{-100,0},{-96,0},{-96,-12},{-64,-12},{-64,50}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{-3,6},{-3,6}},
        horizontalAlignment=TextAlignment.Right));
    connect(cellTemperature.T_c, iVCharacteristics.T_c) annotation (Line(points={{
            26,78},{38,78},{38,46},{4,46},{4,26},{24,26}}, color={0,0,127}));
    connect(iVCharacteristics.DCOutputPower, DCOutputPower) annotation (Line(
          points={{47,28},{76,28},{76,0},{110,0}}, color={0,0,127}));
    annotation (Icon(graphics={
          Rectangle(
            lineColor={200,200,200},
            fillColor={248,248,248},
            fillPattern=FillPattern.HorizontalCylinder,
            extent={{-100.0,-100.0},{100.0,100.0}},
            radius=25.0),
          Rectangle(
            lineColor={128,128,128},
            extent={{-100.0,-100.0},{100.0,100.0}},
            radius=25.0),      Polygon(points={{-80,-80},{-40,80},{80,80},{40,-80},
                {-80,-80}}, lineColor={0,0,0}),
          Line(points={{-60,-76},{-20,76}}, color={0,0,0}),
          Line(points={{-34,-76},{6,76}}, color={0,0,0}),
          Line(points={{-8,-76},{32,76}}, color={0,0,0}),
          Line(points={{16,-76},{56,76}}, color={0,0,0}),
          Line(points={{-38,60},{68,60}}, color={0,0,0}),
          Line(points={{-44,40},{62,40}}, color={0,0,0}),
          Line(points={{-48,20},{58,20}}, color={0,0,0}),
          Line(points={{-54,0},{52,0}}, color={0,0,0}),
          Line(points={{-60,-20},{46,-20}}, color={0,0,0}),
          Line(points={{-64,-40},{42,-40}}, color={0,0,0}),
          Line(points={{-70,-60},{36,-60}}, color={0,0,0})}),
                                 Documentation(info="<html><h4>
  <span style=\"color: #008000\">Overview</span>
</h4>
<p>
  Model that determines the DC performance of a PV array.
</p>
<h4>
  Concept
</h4>
<p>
  Model consists of a model determining the IV Characteristic, a model
  to calculate the cell temperature and a model to calculate the
  irradiance and absorption ratio for the PV module.
</p>
<h4>
  1. IV Characteristic:
</h4>
<p>
  Model for determining the I-V characteristics of a PV array based on
  Batzelis et al., De Soto et al. and Boyd.
</p>
<h4>
  2. Cell Temperature calculation:
</h4>
<p>
  Two cell temperature models are implemented and should be chosen
  depending on the module's topology:
</p>
<p>
  CellTemperatureOpenRack:
</p>
<p>
  Module is installed on open rack based on Duffie et al.. Here, the
  resulting cell temperature is usually lower compared to the cell
  temperature model <i>CellTemperatureMountingCloseToGround</i>
  resulting in higher efficiencies.
</p>
<p>
  CellTemperatureMountingCloseToGround:
</p>
<p>
  Module is installed close to ground (e.g. on roof) based on King et
  al.
</p>
<p>
  CellTemperatureMountingContactToGround:
</p>
<p>
  Module is installed in contact to ground (e.g. integrated in roof)
  based on King et al.
</p>
<p>
  If line losses are not known, the model
  CellTemperatureMountingCloseToGround can be used for a more
  conservative estimation of PV DC power output. This is due to the
  fact that line losses are not included in the calculation process.
</p>
<h4>
  Known limitations
</h4>
<ul>
  <li>Model does not include line losses and decreasing panel
  efficiency due to shading! This leads to the fact that model usually
  overestimates real DC power.
  </li>
  <li>Some parameter combinations result in high peaks for variables
  such as V_mp, I_mp and T_c. The output power is therefore limited to
  the reasonable values 0 and P_mp0*1.05, with 5 &amp;percnt; being a
  common tolerance for power at MPP.
  </li>
</ul>
<h4>
  References
</h4>
<p>
  A Method for the analytical extraction of the Single-Diode PV model
  parameters. by Batzelis, Efstratios I. ; Papathanassiou, Stavros A.
</p>
<p>
  Improvement and validation of a model for photovoltaic array
  performance. by De Soto, W. ; Klein, S. A. ; Beckman, W. A.
</p>
<p>
  Performance Data from the NIST Photovoltaic Arrays and Weather
  Station. by Boyd, M.
</p>
<p>
  SANDIA REPORT SAND 2004-3535 Unlimited Release Printed December 2004
  Photovoltaic Array Performance Model. (2005). by King, D. L. et al.
</p>
<p>
  Solar engineering of thermal processes. by Duffie, John A. ; Beckman,
  W. A.
</p>
</html>",
  revisions="<html><ul>
  <li>
    <i>May 6, 2021&#160;</i> by Laura Maier:<br/>
    Finalization of the model
  </li>
  <li>
    <i>April, 2020&#160;</i> by Arnold Fütterer:<br/>
    General changes to align the model with AixLib standards (see
    <a href=\"https://github.com/RWTH-EBC/AixLib/issues/767\">issue
    767</a>).
  </li>
  <li>
    <i>August, 2019&#160;</i> by Michael Kratz:<br/>
    First implementation (see <a href=
    \"https://github.com/RWTH-EBC/AixLib/issues/767\">issue 767</a>).
  </li>
</ul>
</html>"));
  end PVSystem_ref;


  package Examples
    extends Modelica.Icons.ExamplesPackage;

    model ExamplePVSystem
      "Example of a model for determining the DC output Power of a PV array; 
  Modules mounted close to the ground"
      import ModelicaServices;

     extends Modelica.Icons.Example;

      PVSystem pVSystem(
        redeclare AixLib.DataBase.SolarElectric.QPlusBFRG41285
                                                        data,
        n_mod=20,
        lat(displayUnit="deg") = 0.91664692314742,
        lon(displayUnit="deg") = 0.23387411976724,
        alt=10,
        til(displayUnit="deg") = 0.26179938779915,
        azi(displayUnit="deg") = 0,
        redeclare model CellTemperature =
            BaseClasses.CellTemperatureMountingCloseToGround,
        redeclare model IVCharacteristics =
            BaseClasses.IVCharacteristics5pAnalytical,
        timZon(displayUnit="s") = weaDat.timZon)
        "Model for determining the DC output Power of a PV array; Modules mounted close to the ground (adjust to different mounting via cellTemp)"
        annotation (Placement(transformation(extent={{-8,-12},{16,12}})));

      AixLib.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
            ModelicaServices.ExternalReferences.loadResource(
            "modelica://AixLib/Resources/weatherdata/Weather_TRY_Berlin_winter.mos"),
          calTSky=AixLib.BoundaryConditions.Types.
          SkyTemperatureCalculation.HorizontalRadiation)
        annotation (Placement(transformation(extent={{-100,-10},{-80,10}})));

      Modelica.Blocks.Interfaces.RealOutput DCOutputPower(
      final quantity="Power",
      final unit="W")
      "DC output power of the PV array"
      annotation (Placement(transformation(extent={{100,-10},{120,10}})));

    equation

      connect(pVSystem.DCOutputPowerChargeBat, DCOutputPower)
        annotation (Line(points={{17.2,0},{110,0}}, color={0,0,127}));

      connect(weaDat.weaBus, pVSystem.weaBus) annotation (Line(
          points={{-80,0},{-34,0},{-34,0.72},{-10.16,0.72}},
          color={255,204,51},
          thickness=0.5));
      annotation (experiment(StopTime=31536000, Interval=900), Documentation(info="<html><p>
  Simulation to test the <a href=
  \"AixLib.Electrical.PVSystem.PVSystem\">PVSystem</a> model.
</p>
<p>
  A cold TRY in Berlin is used as an example for the weather data.
</p>
</html>"));
    end ExamplePVSystem;
  end Examples;

  package Validation "Collection of validation models"
    extends Modelica.Icons.ExamplesPackage;

    model ValidationPVSystem
      "Validation with empirical data from NIST for the date of 14.06.2016"
      extends Modelica.Icons.Example;

      PVSystem pVSystem(
        redeclare AixLib.DataBase.SolarElectric.SharpNUU235F2
                                                       data,
        redeclare model IVCharacteristics =
            BaseClasses.IVCharacteristics5pAnalytical,
        redeclare model CellTemperature =
            BaseClasses.CellTemperatureMountingCloseToGround,
        n_mod=312,
        til=0.17453292519943,
        azi=0,
        lat=0.68304158408499,
        lon=-1.3476664539029,
        alt=0.08,
        timZon=-18000)
        "PV System according to measurements taken from https://pvdata.nist.gov/  "
        annotation (Placement(transformation(extent={{40,-10},{60,10}})));
      Modelica.Blocks.Interfaces.RealOutput DCOutputPower(
      final quantity="Power",
      final unit="W")
        "DC output power of the PV array"
        annotation (Placement(transformation(extent={{96,-10},{116,10}})));
      AixLib.BoundaryConditions.WeatherData.Bus weaBus
        annotation (Placement(transformation(extent={{4,-10},{24,10}})));
      Modelica.Blocks.Sources.CombiTimeTable NISTdata(
        tableOnFile=true,
        tableName="Roof2016",
        fileName=ModelicaServices.ExternalReferences.loadResource(
            "modelica://AixLib/Resources/weatherdata/NIST_onemin_Roof_2016.txt"),
        columns={3,5,2,4},
        smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative)
        "The PVSystem model is validaded with measurement data from: https://pvdata.nist.gov/ "
        annotation (Placement(transformation(extent={{-100,-10},{-80,10}})));

      Modelica.Blocks.Math.UnitConversions.From_degC from_degC
        annotation (Placement(transformation(extent={{-22,-4},{-14,4}})));

      Modelica.Blocks.Interfaces.RealOutput DCOutputPower_Measured(
      final quantity="Power",
      final unit="W")
        "Measured DC output power of the PV array"
        annotation (Placement(transformation(extent={{96,-50},{116,-30}})));
      Modelica.Blocks.Math.Gain kiloWattToWatt(k=1000)
        annotation (Placement(transformation(extent={{40,-50},{60,-30}})));
    equation
      connect(pVSystem.DCOutputPowerChargeBat, DCOutputPower)
        annotation (Line(points={{61,0},{106,0}}, color={0,0,127}));
      connect(pVSystem.weaBus, weaBus) annotation (Line(
          points={{38.2,0.6},{14.1,0.6},{14.1,0},{14,0}},
          color={255,204,51},
          thickness=0.5));
      connect(NISTdata.y[2], weaBus.winSpe) annotation (Line(points={{-79,0},{-36,0},
              {-36,-20},{14,-20},{14,0}}, color={0,0,127}));
      connect(NISTdata.y[3], weaBus.HGloHor) annotation (Line(points={{-79,0},{-36,
              0},{-36,18},{14,18},{14,0}}, color={0,0,127}));
      connect(NISTdata.y[1], from_degC.u)
        annotation (Line(points={{-79,0},{-22.8,0}}, color={0,0,127}));
      connect(from_degC.y, weaBus.TDryBul) annotation (Line(points={{-13.6,0},{14,0}},
                                         color={0,0,127}), Text(
          string="%second",
          index=1,
          extent={{6,3},{6,3}},
          horizontalAlignment=TextAlignment.Left));
      connect(NISTdata.y[4], kiloWattToWatt.u) annotation (Line(points={{-79,0},{-36,
              0},{-36,-40},{38,-40}}, color={0,0,127}));
      connect(kiloWattToWatt.y, DCOutputPower_Measured)
        annotation (Line(points={{61,-40},{106,-40}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false), graphics={Text(
              extent={{-98,46},{-40,12}},
              lineColor={28,108,200},
              horizontalAlignment=TextAlignment.Left,
              textString="1 - Air temperature in °C
2 - Wind speed in m/s
3 - Global horizontal irradiance in W/m2
4 - Ouput power in kW")}),
        experiment(
          StartTime=28684800,
          StopTime=28771200,
          Interval=60,
          __Dymola_Algorithm="Dassl"),
        Documentation(info="<html><p>
  The PVSystem model is validaded with empirical data from: <a href=
  \"https://pvdata.nist.gov/\">https://pvdata.nist.gov/</a>
</p>
<p>
  The date 14.06.2016 was chosen as an example for the PVSystem model.
</p>
<p>
  The PV mounting is an open rack system based on the ground.
</p>
</html>"));
    end ValidationPVSystem;
  annotation (preferredView="info", Documentation(info="<html><p>
  This package contains validation models for the classes in <a href=
  \"modelica://AixLib.Electrical.PVSystem\">AixLib.Electrical.PVSystem</a>
  .
</p>
</html>"));
  end Validation;

  package BaseClasses
          extends Modelica.Icons.BasesPackage;

    partial model PartialIVCharacteristics
      "Partial model for IV Characteristic of a PV module"

    replaceable parameter AixLib.DataBase.SolarElectric.PVBaseDataDefinition data
     constrainedby AixLib.DataBase.SolarElectric.PVBaseDataDefinition
     "PV Panel data definition"
                               annotation (choicesAllMatching);

    // Adjustable input parameters

     parameter Real n_mod(final quantity=
        "NumberOfModules", final unit="1") "Number of connected PV modules"
        annotation ();

    // Parameters from module data sheet

     final parameter Modelica.SIunits.Efficiency eta_0=data.eta_0
        "Efficiency under standard conditions";

     final parameter Real n_ser=data.n_ser
        "Number of cells connected in series on the PV panel";

     final parameter Modelica.SIunits.Area A_pan = data.A_pan
        "Area of one Panel, must not be confused with area of the whole module";

     final parameter Modelica.SIunits.Area A_mod = data.A_mod
        "Area of one module (housing)";

     final parameter Modelica.SIunits.Voltage V_oc0=data.V_oc0
        "Open circuit voltage under standard conditions";

     final parameter Modelica.SIunits.ElectricCurrent I_sc0=data.I_sc0
        "Short circuit current under standard conditions";

     final parameter Modelica.SIunits.Voltage V_mp0=data.V_mp0
        "MPP voltage under standard conditions";

     final parameter Modelica.SIunits.ElectricCurrent I_mp0=data.I_mp0
        "MPP current under standard conditions";

     final parameter Modelica.SIunits.Power P_Max = data.P_mp0*1.05
        "Maximal power of one PV module under standard conditions. P_MPP with 5 % tolerance. This is used to limit DCOutputPower.";

     final parameter Real TCoeff_Isc(unit = "A/K")=data.TCoeff_Isc
        "Temperature coefficient for short circuit current, >0";

     final parameter Real TCoeff_Voc(unit = "V/K")=data.TCoeff_Voc
        "Temperature coefficient for open circuit voltage, <0";

     final parameter Modelica.SIunits.LinearTemperatureCoefficient alpha_Isc= data.alpha_Isc
        "Normalized temperature coefficient for short circuit current, >0";

     final parameter Modelica.SIunits.LinearTemperatureCoefficient beta_Voc = data.beta_Voc
        "Normalized temperature coefficient for open circuit voltage, <0";

     final parameter Modelica.SIunits.LinearTemperatureCoefficient gamma_Pmp=data.gamma_Pmp
        "Normalized temperature coefficient for power at MPP";

     final parameter Modelica.SIunits.Temp_K T_c0=25+273.15
        "Thermodynamic cell temperature under standard conditions";

     Modelica.Blocks.Interfaces.RealOutput DCOutputPower(
      final quantity="Power",
      final unit="W")
      "DC output power of the PV array"
      annotation(Placement(
      transformation(extent={{100,50},{120,70}}),
      iconTransformation(extent={{100,50},{120,70}})));

     Modelica.Blocks.Interfaces.RealOutput eta(
      final quantity="Efficiency",
      final unit="1",
      min=0)
      "Efficiency of the PV module under operating conditions"
      annotation(Placement(
      transformation(extent={{100,-70},{120,-50}}),
      iconTransformation(extent={{100,-70},{120,-50}})));

      Modelica.Blocks.Interfaces.RealInput T_c(final quantity=
        "ThermodynamicTemperature", final unit="K")
        "Cell temperature"
        annotation (Placement(transformation(extent={{-140,20},{-100,60}}), iconTransformation(extent={{-140,20},{-100,60}})));

     Modelica.Blocks.Interfaces.RealInput absRadRat(final unit= "1")
        "Ratio of absorbed radiation under operating conditions to standard conditions"
        annotation (Placement(transformation(extent={{-140,-60},{-100,-20}}), iconTransformation(extent={{-140,-60},{-100,-20}})));

     Modelica.Blocks.Interfaces.RealInput radTil(final unit="W/m2")
        "Total solar irradiance on the tilted surface"
        annotation (Placement(transformation(extent={{-140,-100},{-100,-60}}), iconTransformation(extent={{-140,-100},{-100,
                -60}})));

      annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
         Rectangle(
          lineColor={0,0,0},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          extent={{-100,100},{100,-100}}),
            Line(
              points={{-66,-64},{-66,88}},
              color={0,0,0},
              arrow={Arrow.None,Arrow.Filled},
              thickness=0.5),
            Line(
              points={{-66,-64},{64,-64}},
              color={0,0,0},
              arrow={Arrow.None,Arrow.Filled},
              thickness=0.5),
            Text(
              extent={{-72,80},{-102,68}},
              lineColor={0,0,0},
              lineThickness=0.5,
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid,
              textString="I"),
            Text(
              extent={{80,-80},{50,-92}},
              lineColor={0,0,0},
              lineThickness=0.5,
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid,
              textString="U"),
            Line(
              points={{-66,54},{-66,54},{-6,54},{12,50},{22,42},{32,28},{38,8},{42,-14},
                  {44,-44},{44,-64}},
              color={0,0,0},
              thickness=0.5,
              smooth=Smooth.Bezier)}),
                                   Diagram(coordinateSystem(preserveAspectRatio=false)));
    end PartialIVCharacteristics;

    model IVCharacteristics5pAnalytical "Analytical 5-p model for PV I-V 
  characteristics (Batzelis et al.,2016) with temp. dependency of the 
  5 parameters based on (DeSoto et al.,2006)"

    extends PartialIVCharacteristics;

    // Main parameters under standard conditions

     Modelica.SIunits.ElectricCurrent I_ph0
        "Photo current under standard conditions";
     Modelica.SIunits.ElectricCurrent I_s0
        "Saturation current under standard conditions";
     Modelica.SIunits.Resistance R_s0
        "Series resistance under standard conditions";
     Modelica.SIunits.Resistance R_sh0
        "Shunt resistance under standard conditions";
     Real a_0(unit = "V")
        "Modified diode ideality factor under standard conditions";
     Real w_0(final unit = "1")
        "MPP auxiliary correlation coefficient under standard conditions";

    // Additional parameters and constants

     constant Real e=Modelica.Math.exp(1.0)
       "Euler's constant";
     constant Real pi=Modelica.Constants.pi
       "Pi";
     constant Real k(final unit="J/K") = 1.3806503e-23
       "Boltzmann's constant";
     constant Real q( unit = "A.s")= 1.602176620924561e-19
       "Electron charge";
     parameter Modelica.SIunits.Energy E_g0=1.79604e-19
        "Band gap energy under standard conditions for Si";
     parameter Real C=0.0002677
        "Band gap temperature coefficient for Si";

     Modelica.SIunits.ElectricCurrent I_mp( start = 0.5*I_mp0)
        "MPP current";

     Modelica.SIunits.Voltage V_mp
        "MPP voltage";

     Modelica.SIunits.Energy E_g
        "Band gap energy";

     Modelica.SIunits.ElectricCurrent I_s
        "Saturation current";

     Modelica.SIunits.ElectricCurrent I_ph
        "Photo current";

     Modelica.SIunits.Resistance R_s
        "Series resistance";

     Modelica.SIunits.Resistance R_sh
        "Shunt resistance";

     Real a(final unit = "V", start = 1.3)
        "Modified diode ideality factor";

     Modelica.SIunits.Power P_mod
        "Output power of one PV module";

     Real w(final unit = "1", start = 0)
       "MPP auxiliary correlation coefficient";

     Modelica.SIunits.Voltage V_oc
        "Open circuit voltage under operating conditions";

    equation

    // Analytical parameter extraction equations under standard conditions (Batzelis et al., 2016)

     a_0 = V_oc0*(1-T_c0*beta_Voc)/(50.1-T_c0*alpha_Isc);

      w_0 = MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.Wsimple(
        exp(1/(a_0/V_oc0) + 1));

     R_s0 = (a_0*(w_0-1)-V_mp0)/I_mp0;

     R_sh0 = a_0*(w_0-1)/(I_sc0*(1-1/w_0)-I_mp0);

     I_ph0 = (1+R_s0/R_sh0)*I_sc0;

     I_s0 = I_ph0*exp(-1/(a_0/V_oc0));

    // Parameter extrapolation equations to operating conditions (DeSoto et al.,2006)

     a/a_0 = T_c/T_c0;

     I_s/I_s0 = (T_c/T_c0)^3*exp(1/k*(E_g0/T_c0-E_g/T_c));

     E_g/E_g0 = 1-C*(T_c-T_c0);

     R_s = R_s0;

     I_ph = if absRadRat > 0 then absRadRat*(I_ph0+TCoeff_Isc*(T_c-T_c0))
     else
      0;

     R_sh/R_sh0 = if noEvent(absRadRat > 0.001) then 1/absRadRat
     else
      0;

    //Simplified Power correlations at MPP using lambert W function (Batzelis et al., 2016)

     I_mp = if noEvent(absRadRat <= 0.0011 or w<=0.001) then 0
     else
     I_ph*(1-1/w)-a*(w-1)/R_sh;

     V_mp = if absRadRat <= 0 then 0
     else
     a*(w-1)-R_s*I_mp;

     V_oc = if I_ph >= 0.01  then
     a*log(abs((I_ph/I_s+1)))
     else
     0;

      w = if noEvent(V_oc >= 0.001) then
        MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.Wsimple(exp(
        1/(a/V_oc) + 1)) else 0;

    //I-V curve equation - use if P at a given V is needed (e.g. battery loading scenarios without MPP tracker)
    //I = I_ph - I_s*(exp((V+I*R_s)/(a))-1) - (V + I*R_s)/(R_sh);

    // Efficiency and Performance

     eta= if noEvent(radTil <= 0.01) then 0
     else
     P_mod/(radTil*A_pan);

     P_mod = V_mp*I_mp;

     DCOutputPower=max(0, min(P_Max*n_mod, P_mod*n_mod));

       annotation (
       Icon(
        coordinateSystem(extent={{-100,-100},{100,100}})),
         Documentation(info="<html><h4>
  <span style=\"color: #008000\">Overview</span>
</h4>
<p>
  <br/>
  Analytical 5-p model for determining the I-V characteristics of a PV
  array (Batzelis et al.,2016) with temp. dependency of the 5
  parameters after (DeSoto et al.,2006). The final output of this model
  is the DC performance of the PV array.
</p>
<p>
  <br/>
  Validated with experimental data from NIST (Boyd, 2017).
</p>
<p>
  Module calibration is based on manufactory data.
</p>
<p>
  <br/>
</p>
<h4>
  <span style=\"color: #008000\">References</span>
</h4>
<p>
  A Method for the analytical extraction of the Single-Diode PV model
  parameters. by Batzelis, Efstratios I. ; Papathanassiou, Stavros A.
</p>
<p>
  Improvement and validation of a model for photovoltaic array
  performance. by De Soto, W. ; Klein, S. A. ; Beckman, W. A.
</p>
<p>
  Performance Data from the NIST Photovoltaic Arrays and Weather
  Station. by Boyd, M.:
</p>
</html>"));
    end IVCharacteristics5pAnalytical;

    partial model PartialCellTemperature
      "Partial model for determining the cell temperature of a PV moduleConnector 
  for PV record data"

    // Parameters from module data sheet
     replaceable parameter AixLib.DataBase.SolarElectric.PVBaseDataDefinition data
     constrainedby AixLib.DataBase.SolarElectric.PVBaseDataDefinition
     "PV Panel data definition"
                               annotation (choicesAllMatching);

     final parameter Modelica.SIunits.Efficiency eta_0=data.eta_0
        "Efficiency under standard conditions";

     final parameter Modelica.SIunits.Temp_K T_NOCT=data.T_NOCT
        "Cell temperature under NOCT conditions";

     final parameter Real radNOCT(final quantity="Irradiance",
        final unit="W/m2")= 800
        "Irradiance under NOCT conditions";
     Modelica.Blocks.Interfaces.RealInput T_a(final quantity=
        "Temp_C", final unit="K")
        "Ambient temperature"
        annotation (Placement(transformation(extent={{-140,64},{-100,114}}),iconTransformation(extent={{-140,74},{-100,114}})));

     Modelica.Blocks.Interfaces.RealInput winVel(final quantity= "Velocity",
        final unit= "m/s")
        "Wind velocity"
        annotation (Placement(transformation(extent={{-140,24},{-100,74}}), iconTransformation(extent={{-140,44},{-100,74}})));

     Modelica.Blocks.Interfaces.RealInput eta(final quantity="Efficiency",
          final unit="1",
          min=0)
        "Efficiency of the PV module under operating conditions"
        annotation (Placement(transformation(extent={{-140,-72},{-100,-22}}),
                                                                            iconTransformation(extent={{-140,-62},{-100,-22}})));

     Modelica.Blocks.Interfaces.RealInput radTil(final quantity="Irradiance",
        final unit="W/m2")
        "Total solar irradiance on the tilted surface"
        annotation (Placement(transformation(extent={{-140,-102},{-100,-62}}), iconTransformation(extent={{-140,-102},{-100,
                -62}})));

     Modelica.Blocks.Interfaces.RealOutput T_c(final quantity=
        "ThermodynamicTemperature", final unit="K")
        "Cell temperature"
        annotation (Placement(transformation(extent={{100,-20},{140,20}}),  iconTransformation(extent={{100,-20},{140,20}})));

      annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Rectangle(
              lineColor={200,200,200},
              fillColor={248,248,248},
              fillPattern=FillPattern.HorizontalCylinder,
              extent={{-100.0,-100.0},{100.0,100.0}},
              radius=25.0),
            Rectangle(
              lineColor={128,128,128},
              extent={{-100.0,-100.0},{100.0,100.0}},
              radius=25.0),      Polygon(points={{-80,-80},{-40,80},{80,80},{40,-80},
                  {-80,-80}}, lineColor={0,0,0}),
            Line(points={{-60,-76},{-20,76}}, color={0,0,0}),
            Line(points={{-34,-76},{6,76}}, color={0,0,0}),
            Line(points={{-8,-76},{32,76}}, color={0,0,0}),
            Line(points={{16,-76},{56,76}}, color={0,0,0}),
            Line(points={{-38,60},{68,60}}, color={0,0,0}),
            Line(points={{-44,40},{62,40}}, color={0,0,0}),
            Line(points={{-48,20},{58,20}}, color={0,0,0}),
            Line(points={{-54,0},{52,0}}, color={0,0,0}),
            Line(points={{-60,-20},{46,-20}}, color={0,0,0}),
            Line(points={{-64,-40},{42,-40}}, color={0,0,0}),
            Line(points={{-70,-60},{36,-60}}, color={0,0,0}),
            Ellipse(
              extent={{-20,-88},{20,-50}},
              lineColor={0,0,0},
              lineThickness=0.5,
              fillColor={191,0,0},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-12,50},{12,-58}},
              lineColor={191,0,0},
              fillColor={191,0,0},
              fillPattern=FillPattern.Solid),
            Polygon(
              points={{-12,50},{-12,90},{-10,96},{-6,98},{0,100},{6,98},{10,96},{12,
                  90},{12,50},{-12,50}},
              lineColor={0,0,0},
              lineThickness=0.5,
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid),
            Line(
              points={{-12,50},{-12,-54}},
              thickness=0.5),
            Line(
              points={{12,50},{12,-54}},
              thickness=0.5),
            Text(
              extent={{126,-30},{6,-60}},
              lineColor={0,0,0},
              textString="T"),
            Line(points={{12,0},{60,0}}, color={0,0,127})}),
         Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end PartialCellTemperature;

    model CellTemperatureOpenRack
       "Empirical model for determining the cell temperature of a PV module mounted on an 
   open rack"

     extends
        MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.PartialCellTemperature;

     final parameter Modelica.SIunits.Temperature T_a_0 = 293.15
     "Reference ambient temperature";
     final parameter Real coeff_trans_abs = 0.9
     "Module specific coefficient as a product of transmission and absorption.
 It is usually unknown and set to 0.9 in literature";

    equation

     T_c = if noEvent(radTil >= Modelica.Constants.eps) then
     (T_a)+(T_NOCT-T_a_0)*radTil/radNOCT*9.5/(5.7+3.8*winVel)*(1-eta/coeff_trans_abs)
     else
     (T_a);

     annotation (
      Documentation(info="<html><h4>
  <span style=\"color: #008000\">Overview</span>
</h4>
<p>
  Model for determining the cell temperature of a PV module mounted on
  an open rack under operating conditions and under consideration of
  the wind velocity.
</p>
<p>
  <br/>
</p>
<h4>
  <span style=\"color: #008000\">References</span>
</h4>
<p>
  <q>Solar engineering of thermal processes.</q> by Duffie, John A. ;
  Beckman, W. A.
</p>
</html>
"));
    end CellTemperatureOpenRack;

    model CellTemperatureMountingCloseToGround
      "Empirical model for determining the cell temperature of a PV module mounted with the 
  module backsite close to the ground"

     extends
        MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.PartialCellTemperature;

    equation

     T_c = if noEvent(radTil >= Modelica.Constants.eps) then
     radTil*(exp(-2.98-0.0471*winVel))+(T_a)+radTil/1000*1
     else
     (T_a);

     annotation (
      Documentation(info="<html><h4>
  <span style=\"color: #008000\">Overview</span>
</h4>
<p>
  Model for determining the cell temperature of a PV module mounted
  with the module backsite close to the ground, under operating
  conditions and under consideration of the wind velocity.
</p>
<p>
  <br/>
</p>
<h4>
  <span style=\"color: #008000\">References</span>
</h4>
<p>
  <q>SANDIA REPORT SAND 2004-3535 Unlimited Release Printed December
  2004 Photovoltaic Array Performance Model. (2005).</q> by King, D. L.
  et al.
</p>
</html>
"));
    end CellTemperatureMountingCloseToGround;

    model CellTemperatureMountingContactToGround
      "Empirical model for determining the cell temperature of a PV module mounted with the 
  module backsite in contact with the ground"

    extends
        MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.PartialCellTemperature;

    equation

     T_c = if noEvent(radTil >= Modelica.Constants.eps) then
         radTil*(exp(-2.81-0.0455*winVel))+(T_a)
     else
     (T_a);

      annotation (Documentation(info="<html><h4>
  Overview
</h4>
<p>
  Model for determining the cell temperature of a PV module mounted
  with the module backside in contact with the ground, under operating
  conditions and under consideration of the wind velocity. E.g. roof
  integrated PV modules.
</p>
<p>
  <br/>
  <b>References</b>
</p>
<p>
  SANDIA REPORT SAND 2004-3535 Unlimited Release Printed December 2004
  Photovoltaic Array Performance Model. (2005). by King, D. L. et al.
</p>
</html>"));
    end CellTemperatureMountingContactToGround;

    function Wsimple
      "Simple approximation for Lambert W function for x >= 2,
  should only be used for large input values as error decreases for increasing 
  input values (Batzelis, 2016)"

       input Real x(min=2);
       output Real W;
    algorithm

      W:= log(x)*(1-log(log(x))/(log(x)+1));
    end Wsimple;

    model PVRadiationHorizontal "PV radiation and absorptance model - input: total irradiance on horizontal plane"

     parameter Real lat(final quantity = "Angle",
       final unit = "rad",
       displayUnit = "deg") "Latitude"
       annotation ();

     parameter Real lon(final quantity = "Angle",
       final unit = "rad",
       displayUnit = "deg") "Longitude"
       annotation ();

     parameter Real  alt(final quantity="Length", final unit="m")
       "Site altitude in Meters, default= 1"
       annotation ();

     parameter Real til(final quantity = "Angle",
       final unit = "rad",
       displayUnit = "deg")
       "Surface tilt. til=90 degree for walls; til=0 for ceilings; til=180 for roof"
       annotation ();

     parameter Real  azi(final quantity = "Angle",
       final unit = "rad",
       displayUnit = "deg")
       "Module surface azimuth. azi=-90 degree if normal of surface outward unit points towards east; azi=0 if it points towards south"
       annotation ();

     parameter Real timZon(final quantity="Time",
       final unit="s", displayUnit="h")
       "Time zone in seconds relative to GMT"
       annotation ();

     parameter Real groRef(final unit="1") "Ground refelctance"
       annotation ();

     // Air mass parameters for mono-SI
      parameter Real b_0=0.935823;
      parameter Real b_1=0.054289;
      parameter Real b_2=-0.008677;
      parameter Real b_3=0.000527;
      parameter Real b_4=-0.000011;

      parameter Real radTil0(final quantity="Irradiance",
      final unit= "W/m2") = 1000 "total solar radiation on the horizontal surface 
  under standard conditions";

      parameter Real G_sc(final quantity="Irradiance",
      final unit = "W/m2") = 1376 "Solar constant";

      parameter Real glaExtCoe(final unit="1/m") = 4
      "Glazing extinction coefficient for glass";

      parameter Real glaThi(final unit="m") = 0.002
      "Glazing thickness for most PV cell panels";

      parameter Real refInd(final unit="1", min=0) = 1.526
      "Effective index of refraction of the cell cover (glass)";

      parameter Real tau_0(final unit="1", min=0)=
       exp(-(glaExtCoe*glaThi))*(1 - ((refInd - 1)/(refInd + 1))
      ^2) "Transmittance at standard conditions (incAng=refAng=0)";

      Real cloTim(final quantity="Time",
       final unit="s", displayUnit="h")
       "Local clock time";

      Real nDay(final quantity="Time",final unit="s")
        "Day number with units of seconds";

      Real radHorBea(final quantity="Irradiance",
       final unit= "W/m2")
       "Beam solar radiation on the horizontal surface";

      Real radHorDif(final quantity="Irradiance",
       final unit= "W/m2")
       "Diffuse solar radiation on the horizontal surface";

      Real k_t(final unit="1", start=0.5) "Clearness index";

      Real airMas(final unit="1", min=0) "Air mass";

      Real airMasMod(final unit="1", min=0) "Air mass modifier";

      Modelica.SIunits.Angle incAngGro "Incidence angle for ground reflection";

      Modelica.SIunits.Angle incAngDif "Incidence angle for diffuse radiation";

      Real incAngMod(final unit="1", min=0) "Incidence angle modifier";

      Real incAngModGro(final unit="1", min=0) "Incidence angle modifier for ground refelction";

      Real incAngModDif(final unit="1", min=0)
      "Incidence angle modifier for diffuse radiation";

      Modelica.SIunits.Angle refAng "Angle of refraction";

      Modelica.SIunits.Angle refAngGro "Angle of refraction for ground reflection";

      Modelica.SIunits.Angle refAngDif "Angle of refraction for diffuse irradiation";

      Real tau(final unit="1", min=0)
      "Transmittance of the cover system";

      Real tau_ground(final unit="1", min=0)
      "Transmittance of the cover system for ground reflection";

      Real tau_diff(final unit="1", min=0)
      "Transmittance of the cover system for diffuse radiation";

      Real R_b(final unit="1", min=0)
       "Ratio of irradiance on tilted surface to horizontal surface";

      Modelica.SIunits.Angle zen
      "Zenith angle";

      AixLib.BoundaryConditions.SolarGeometry.BaseClasses.SolarHourAngle
        solHouAng
        "Solar hour angle";

      AixLib.BoundaryConditions.WeatherData.BaseClasses.LocalCivilTime locTim(
        timZon=timZon,
        lon=lon)
        "Block that computes the local civil time";

      AixLib.BoundaryConditions.WeatherData.BaseClasses.SolarTime solTim
        "Block that computes the solar time";

      AixLib.BoundaryConditions.WeatherData.BaseClasses.EquationOfTime eqnTim
        "Block that computes the equation of time";

      AixLib.BoundaryConditions.SolarGeometry.BaseClasses.Declination decAng
        "Declination angle";

      AixLib.BoundaryConditions.SolarGeometry.BaseClasses.IncidenceAngle incAng(
       azi=azi,
       til=til,
       lat=lat) "Incidence angle";

      AixLib.BoundaryConditions.SolarGeometry.BaseClasses.ZenithAngle zenAng(
       lat=lat) "Zenith angle";

      AixLib.Utilities.Time.ModelTime modTim
        "Block that outputs simulation time";

      Modelica.Blocks.Interfaces.RealOutput radTil(final quantity="Irradiance",
       final unit= "W/m2")
       "Total solar radiation on the tilted surface"
       annotation (Placement(transformation(extent={{100,-70},{120,-50}})));

      Modelica.Blocks.Interfaces.RealOutput absRadRat(final unit= "1", min=0)
       "Ratio of absorbed radiation under operating conditions to standard conditions"
       annotation (Placement(transformation(extent={{100,50},{120,70}})));

      Modelica.Blocks.Interfaces.RealInput radHor(final quantity="Irradiance",
       final unit= "W/m2")
       "Total solar irradiance on the horizontal surface"
       annotation (Placement(transformation(extent={{-140,40},{-100,80}})));

    equation

     connect(solTim.solTim, solHouAng.solTim);

     connect(locTim.locTim, solTim.locTim);

     connect(eqnTim.eqnTim, solTim.equTim);

     connect(decAng.decAng, incAng.decAng);

     connect(solHouAng.solHouAng, incAng.solHouAng);

     connect(decAng.decAng, zenAng.decAng);

     connect(solHouAng.solHouAng, zenAng.solHouAng);

     nDay = floor(modTim.y/86400)*86400
      "Zero-based day number in seconds (January 1=0, January 2=86400)";

     cloTim= modTim.y-nDay;

     eqnTim.nDay= nDay;

     locTim.cloTim=cloTim;

     decAng.nDay= nDay;

     zen = if zenAng.zen <= Modelica.Constants.pi/2 then
     zenAng.zen
     else
     Modelica.Constants.pi/2
     "Restriction for zenith angle";

      refAng = if noEvent(incAng.incAng >= 0.0001 and incAng.incAng <= Modelica.Constants.pi
      /2*0.999) then asin(sin(incAng.incAng)/refInd) else
      0;

      refAngGro = if noEvent(incAngGro >= 0.0001 and incAngGro <= Modelica.Constants.pi/2*
      0.999) then asin(sin(incAngGro)/refInd) else
      0;

      refAngDif = if noEvent(incAngDif >= 0.0001 and incAngDif <= Modelica.Constants.pi/2*
      0.999) then asin(sin(incAngDif)/refInd) else
      0;

      tau = if noEvent(incAng.incAng >= 0.0001 and incAng.incAng <= Modelica.Constants.pi/
      2*0.999 and refAng >= 0.0001) then exp(-(glaExtCoe*glaThi/cos(refAng)))*(1
      - 0.5*((sin(refAng - incAng.incAng)^2)/(sin(refAng + incAng.incAng)^2) + (
      tan(refAng - incAng.incAng)^2)/(tan(refAng + incAng.incAng)^2))) else
      0;

      tau_ground = if noEvent(incAngGro >= 0.0001 and refAngGro >= 0.0001) then exp(-(
      glaExtCoe*glaThi/cos(refAngGro)))*(1 - 0.5*((sin(refAngGro - incAngGro)^2)/
      (sin(refAngGro + incAngGro)^2) + (tan(refAngGro - incAngGro)^2)/(tan(
      refAngGro + incAngGro)^2))) else
      0;

      tau_diff = if noEvent(incAngDif >= 0.0001 and refAngDif >= 0.0001) then exp(-(
      glaExtCoe*glaThi/cos(refAngDif)))*(1 - 0.5*((sin(refAngDif - incAngDif)^2)/
      (sin(refAngDif + incAngDif)^2) + (tan(refAngDif - incAngDif)^2)/(tan(
      refAngDif + incAngDif)^2))) else
      0;

      incAngMod = tau/tau_0;

      incAngModGro = tau_ground/tau_0;

      incAngModDif = tau_diff/tau_0;

      airMasMod = if (b_0 + b_1*(airMas^1) + b_2*(airMas^2) + b_3*(
      airMas^3) + b_4*(airMas^4)) <= 0 then
      0 else
      b_0 + b_1*(airMas^1) + b_2*(airMas^2) + b_3*(airMas^3) + b_4*(airMas^4);

      airMas = exp(-0.0001184*alt)/(cos(zen) + 0.5057*(96.080 - zen*
      180/Modelica.Constants.pi)^(-1.634));

      incAngGro = (90 - 0.5788*til*180/Modelica.Constants.pi + 0.002693*(til*180/
      Modelica.Constants.pi)^2)*Modelica.Constants.pi/180;

      incAngDif = (59.7 - 0.1388*til*180/Modelica.Constants.pi + 0.001497*(til*180/
      Modelica.Constants.pi)^2)*Modelica.Constants.pi/180;

      R_b = if noEvent((zen >= Modelica.Constants.pi/2*0.999) or (cos(incAng.incAng)
      > cos(zen)*4)) then 4 else (cos(incAng.incAng)/cos(zen));

      radHor = radHorBea + radHorDif;

      radTil = if noEvent(radHor <= 0.1) then 0 else radHorBea*R_b + radHorDif*(0.5*(1 + cos(
      til)*(1 + (1 - (radHorDif/radHor)^2)*sin(til/2)^3)*(1 + (1 - (radHorDif/
      radHor)^2)*(cos(incAng.incAng)^2)*(cos(til)^3)))) + radHor*groRef*(1 - cos(
      til))/2;

      k_t = if noEvent(radHor <=0.001) then 0
      else
      min(1,max(0,(radHor)/(G_sc*(1.00011+0.034221*cos(2*Modelica.Constants.pi*nDay/24/60/60/365)+0.00128*sin(2*Modelica.Constants.pi*nDay/24/60/60/365)
      +0.000719*cos(2*2*Modelica.Constants.pi*nDay/24/60/60/365)+0.000077*sin(2*2*Modelica.Constants.pi*nDay/24/60/60/365))*cos(zenAng.zen)))) "after (Iqbal,1983)";

    // Erb´s diffuse fraction relation
      radHorDif = if radHor <=0.001 then 0
      elseif
           k_t <= 0.22 then
      (radHor)*(1.0-0.09*k_t)
       elseif
           k_t > 0.8 then
      (radHor)*0.165
       else
      (radHor)*(0.9511-0.1604*k_t+4.388*k_t^2-16.638*k_t^3+12.336*k_t^4);

      absRadRat = if noEvent(radHor <=0.1) then 0
      else
      airMasMod*(radHorBea/radTil0*R_b*incAngMod
      +radHorDif/radTil0*incAngModDif*(0.5*(1+cos(til)*(1+(1-(radHorDif/radHor)^2)*sin(til/2)^3)*(1+(1-(radHorDif/radHor)^2)*(cos(incAng.incAng)^2)*(cos(til)^3))))
      +radHor/radTil0*groRef*incAngModGro*(1-cos(til))/2);

      annotation (Icon(graphics={   Bitmap(extent={{-90,-90},{90,90}}, fileName=
                  "modelica://AixLib/Resources/Images/BoundaryConditions/SolarGeometry/BaseClasses/IncidenceAngle.png")}),
                  Documentation(info="<html><h4>
  <span style=\"color: #008000\">Overview</span>
</h4>
<p>
  Model for determining Irradiance and absorptance ratio for PV modules
  - input: total irradiance on horizontal plane.
</p>
<p>
  <br/>
</p>
<h4>
  <span style=\"color: #008000\">References</span>
</h4>
<p>
  <q>Solar engineering of thermal processes.</q> by Duffie, John A. ;
  Beckman, W. A.
</p>
<p>
  <q>Regenerative Energiesysteme: Technologie ; Berechnung ;
  Simulation</q> by Quaschning, Volker:
</p>
</html>
"));
    end PVRadiationHorizontal;
  end BaseClasses;
  annotation (Icon(graphics={Polygon(points={{-80,-80},{-40,80},{80,80},{40,-80},
              {-80,-80}}, lineColor={0,0,0}),
        Line(points={{-60,-76},{-20,76}}, color={0,0,0}),
        Line(points={{-34,-76},{6,76}}, color={0,0,0}),
        Line(points={{-8,-76},{32,76}}, color={0,0,0}),
        Line(points={{16,-76},{56,76}}, color={0,0,0}),
        Line(points={{-38,60},{68,60}}, color={0,0,0}),
        Line(points={{-44,40},{62,40}}, color={0,0,0}),
        Line(points={{-48,20},{58,20}}, color={0,0,0}),
        Line(points={{-54,0},{52,0}}, color={0,0,0}),
        Line(points={{-60,-20},{46,-20}}, color={0,0,0}),
        Line(points={{-64,-40},{42,-40}}, color={0,0,0}),
        Line(points={{-70,-60},{36,-60}}, color={0,0,0})}));
end PVSystem;
