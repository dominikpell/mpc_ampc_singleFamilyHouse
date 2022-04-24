within MA_Pell_SingleFamilyHouse;
model ExamplePVSystem "Example of a model for determining the DC output Power of a PV array; 
  Modules mounted close to the ground"
  import ModelicaServices;

 extends Modelica.Icons.Example;

  Electrical.PVSystem.PVSystem pVSystem(
    redeclare AixLib.DataBase.SolarElectric.ShellSP70 data,
    redeclare model IVCharacteristics =
        Electrical.PVSystem.BaseClasses.IVCharacteristics5pAnalytical,
    redeclare model CellTemperature =
        Electrical.PVSystem.BaseClasses.CellTemperatureMountingCloseToGround,
    n_mod=3,
    til=0.26179938779915,
    azi=0,
    lat=0.92502450355699,
    lon=0.22689280275926,
    alt=15,
    timZon=weaDat.timZon)
    annotation (Placement(transformation(extent={{-96,20},{-62,54}})));
  Modelica.Blocks.Math.MultiSum calcRealElecDemand(k={-1,1}, nu=2)
    annotation (Placement(transformation(extent={{34,78},{70,114}})));
  parameter
    RecordsCollection.ExampleSystemParameters            systemParameters(nZones=1)
    "Parameters relevant for the whole energy system" annotation (
      choicesAllMatching=true, Placement(transformation(extent={{-52,-186},{0,
            -126}})));
  Modelica.Blocks.Sources.RealExpression PV_PowDistribution[3](y={0.5,0.2,0.3})
    "Shares of Power: 1. Self Used, 2. FeedIn, 3. Battery Charging "
    annotation (Placement(transformation(extent={{-342,-22},{-220,32}})));
  Modelica.Blocks.Sources.RealExpression ElecDemand(y=2500)
    "TotalElectricityDemand"
    annotation (Placement(transformation(extent={{-344,-102},{-222,-48}})));
  AixLib.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        systemParameters.filNamWea)
    "Weather data reader"
    annotation (Placement(transformation(extent={{-346,56},{-258,162}})));
  Interfaces.PVControlBus PVControlBus
    annotation (Placement(transformation(extent={{-146,-6},{-126,14}})));
equation

  connect(pVSystem.DCOutputPowerUse,calcRealElecDemand. u[1]) annotation (Line(
        points={{-60.3,47.2},{-38,47.2},{-38,48},{-14,48},{-14,102.3},{34,102.3}},
                                                               color={0,0,127}));
  connect(pVSystem.PVControlBus, PVControlBus) annotation (Line(
      points={{-96,37},{-112,37},{-112,40},{-136,40},{-136,4}},
      color={255,204,51},
      thickness=0.5));
  connect(PV_PowDistribution.y, PVControlBus.DistributionPV) annotation (Line(
        points={{-213.9,5},{-135.95,5},{-135.95,4.05}}, color={0,0,127}));
  connect(ElecDemand.y, calcRealElecDemand.u[2]) annotation (Line(points={{
          -215.9,-75},{34,-75},{34,89.7}}, color={0,0,127}));
  connect(weaDat.weaBus, PVControlBus.waeBus) annotation (Line(
      points={{-258,109},{-204,109},{-204,100},{-135.95,100},{-135.95,4.05}},
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
