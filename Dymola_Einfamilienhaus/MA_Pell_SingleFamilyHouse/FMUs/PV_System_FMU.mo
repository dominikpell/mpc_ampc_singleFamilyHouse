within MA_Pell_SingleFamilyHouse.FMUs;
model PV_System_FMU

  Electrical.PVSystem.PVSystem_ref
                               pVSystem_ref1(
    data=data,
    redeclare model IVCharacteristics =
        MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.IVCharacteristics5pAnalytical,
    redeclare model CellTemperature =
        MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.CellTemperatureMountingCloseToGround,
    n_mod=n_mod,
    til(displayUnit="deg") = til,
    azi=azi_2,
    lat=lat,
    lon=lon,
    alt=15,
    timZon=3600)
    annotation (Placement(transformation(extent={{2,-46},{34,-14}})));

  Electrical.PVSystem.PVSystem_ref
                               pVSystem_ref(
    data=data,
    redeclare model IVCharacteristics =
        MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.IVCharacteristics5pAnalytical,
    redeclare model CellTemperature =
        MA_Pell_SingleFamilyHouse.Electrical.PVSystem.BaseClasses.CellTemperatureMountingCloseToGround,
    n_mod=n_mod,
    til=til,
    azi=azi_1,
    lat=lat,
    lon=lon,
    alt=15,
    timZon=3600)
    annotation (Placement(transformation(extent={{2,10},{34,42}})));

  Modelica.Blocks.Interfaces.RealInput T_air(start=273.15) annotation (Placement(
        transformation(extent={{-110,10},{-90,30}}),  iconTransformation(extent=
           {{-490,68},{-470,88}})));
  Modelica.Blocks.Interfaces.RealInput H_GloHor(start=50) annotation (Placement(
        transformation(extent={{-110,-28},{-90,-8}}), iconTransformation(extent=
           {{-490,50},{-470,70}})));
  Modelica.Blocks.Interfaces.RealInput winSpe(start=1) annotation (Placement(
        transformation(extent={{-110,-10},{-90,10}}),  iconTransformation(
          extent={{-490,50},{-470,70}})));
  parameter Modelica.SIunits.Angle til=0.26179938779915
    "Surface's tilt angle (0:flat)";
  parameter Modelica.SIunits.Angle azi_1=1.5707963267949
    "Surface's azimut angle (0:South)";
  parameter Modelica.SIunits.Angle lat=0.92502450355699 "Location's Latitude";
  parameter Modelica.SIunits.Angle lon=0.22689280275926 "Location's Longitude";
  parameter Modelica.SIunits.Angle azi_2=-1.5707963267949
    "Surface's azimut angle (0:South)";
  parameter Integer n_mod=2 "Number of connected PV modules";
  parameter Integer IdentifierPV=1 "defines data for PV module" annotation(Evaluate=false, Dialog(group="PV"));
  parameter AixLib.DataBase.SolarElectric.PVBaseDataDefinition data=
    if IdentifierPV == 1 then AixLib.DataBase.SolarElectric.ShellSP70()
    elseif IdentifierPV == 2 then AixLib.DataBase.SolarElectric.AleoS24185()
    elseif IdentifierPV == 3 then AixLib.DataBase.SolarElectric.CanadianSolarCS6P250P()
    elseif IdentifierPV == 4 then AixLib.DataBase.SolarElectric.QPlusBFRG41285()
    elseif IdentifierPV == 5 then AixLib.DataBase.SolarElectric.SchuecoSPV170SME1()
    else AixLib.DataBase.SolarElectric.SharpNUU235F2()
    "PV Panel data definition" annotation ();

  Modelica.Blocks.Interfaces.RealOutput power_PV(final quantity="Power", final
      unit="W") "DC output power"
    annotation (Placement(transformation(extent={{90,-10},{110,10}})));
  Modelica.Blocks.Math.Add add
    annotation (Placement(transformation(extent={{58,-10},{78,10}})));

  AixLib.BoundaryConditions.WeatherData.Bus waeBus
    annotation (Placement(transformation(extent={{-52,-10},{-32,10}})));
equation
  connect(add.y, power_PV)
    annotation (Line(points={{79,0},{100,0}}, color={0,0,127}));
  connect(T_air, waeBus.TDryBul)
    annotation (Line(points={{-100,20},{-42,20},{-42,0}}, color={0,0,127}));
  connect(winSpe, waeBus.winSpe)
    annotation (Line(points={{-100,0},{-42,0}}, color={0,0,127}));
  connect(H_GloHor, waeBus.HGloHor)
    annotation (Line(points={{-100,-18},{-42,-18},{-42,0}}, color={0,0,127}));
  connect(waeBus,pVSystem_ref. waeBus) annotation (Line(
      points={{-42,0},{-22,0},{-22,26},{2,26}},
      color={255,204,51},
      thickness=0.5));
  connect(waeBus, pVSystem_ref1.waeBus) annotation (Line(
      points={{-42,0},{-22,0},{-22,-30},{2,-30}},
      color={255,204,51},
      thickness=0.5));
  connect(pVSystem_ref.DCOutputPower, add.u1) annotation (Line(points={{35.6,26},
          {45.8,26},{45.8,6},{56,6}}, color={0,0,127}));
  connect(pVSystem_ref1.DCOutputPower, add.u2) annotation (Line(points={{35.6,
          -30},{46,-30},{46,-6},{56,-6}}, color={0,0,127}));
  annotation (
      experiment(
      StopTime=86400,
      Interval=900,
      Tolerance=1e-05,
      __Dymola_Algorithm="Dassl"));
end PV_System_FMU;
