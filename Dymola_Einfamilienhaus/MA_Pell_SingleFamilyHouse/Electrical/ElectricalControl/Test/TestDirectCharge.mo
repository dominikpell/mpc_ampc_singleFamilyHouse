within MA_Pell_SingleFamilyHouse.Electrical.ElectricalControl.Test;
model TestDirectCharge
  extends Modelica.Icons.Example;
  PVBatteryControl.DirectCharge directCharge(threshold=electricity_PVandBAT.batteryData.SOC_min)
    annotation (Placement(transformation(extent={{-44,30},{30,54}})));
  Systems.Subsystems.Electricity.Electricity_PVandBAT_MPC electricity_PVandBAT(
    timZon=3600,
    SOC_Bat_Init=0.8,
    data=AixLib.DataBase.SolarElectric.ShellSP70())
    annotation (Placement(transformation(extent={{-2,-54},{48,-4}})));
  Modelica.Blocks.Sources.Trapezoid BuiLoad(
    amplitude=2000,
    rising=4*3600,
    width=2*3600,
    falling=4*3600,
    period=86400,
    startTime=5*3600) "Electrical building load"
    annotation (Placement(transformation(extent={{-96,74},{-76,94}})));
  Modelica.Blocks.Math.Add3 sumOfPV
    annotation (Placement(transformation(extent={{74,10},{94,30}})));
  Interfaces.InputScenarioBus inputScenBus1
    annotation (Placement(transformation(extent={{-46,-28},{-26,-8}})));
  Modelica.Blocks.Sources.Trapezoid GenLoad(
    amplitude=5000,
    rising=4*3600,
    width=2*3600,
    falling=4*3600,
    period=86400,
    startTime=3*3600) "Electrical building load"
    annotation (Placement(transformation(extent={{-40,-90},{-20,-70}})));
  AixLib.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(filNam=
        ModelicaServices.ExternalReferences.loadResource(
        "modelica://MA_Pell_SingleFamilyHouse/Resources/Library/FMU/PV_FMU/resources/TRY2015_524528132978_Wint_City_Berlin.mos"),
      computeWetBulbTemperature=false)
    annotation (Placement(transformation(extent={{-94,-14},{-62,16}})));
equation
  connect(BuiLoad.y, directCharge.BuiEleLoadAC) annotation (Line(points={{-75,
          84},{-8,84},{-8,68},{-7,68},{-7,54.48}}, color={0,0,127}));
  connect(electricity_PVandBAT.SOC_Bat, directCharge.SOCBat) annotation (Line(
        points={{50.5,-50},{68,-50},{68,68},{-26.425,68},{-26.425,54.48}},
        color={0,0,127}));
  connect(directCharge.PV_Distr_Use, electricity_PVandBAT.PV_Distr_Use)
    annotation (Line(points={{13.0417,29.76},{13.0417,6},{-14,6},{-14,-29.25},{
          -0.25,-29.25}}, color={0,0,127}));
  connect(directCharge.PV_Distr_FeedIn, electricity_PVandBAT.PV_Distr_FeedIn)
    annotation (Line(points={{18.5917,29.76},{18.5917,6},{-14,6},{-14,-32.75},{
          -0.25,-32.75}}, color={0,0,127}));
  connect(directCharge.PV_Distr_ChBat, electricity_PVandBAT.PV_Distr_ChBat)
    annotation (Line(points={{23.8333,29.76},{23.8333,6},{-14,6},{-14,-36.25},{
          -0.25,-36.25}}, color={0,0,127}));
  connect(directCharge.Pow_BAT_Use, electricity_PVandBAT.Pow_BAT_Use)
    annotation (Line(points={{-15.6333,29.28},{-15.6333,-43.75},{-0.25,-43.75}},
        color={0,0,127}));
  connect(directCharge.Pow_BAT_FeedIn, electricity_PVandBAT.Pow_BAT_FeedIn)
    annotation (Line(points={{-11.3167,29.28},{-11.3167,-10},{-12,-10},{-12,-48},
          {-6,-48},{-6,-47.25},{-0.25,-47.25}}, color={0,0,127}));
  connect(directCharge.Pow_BAT_ChBat, electricity_PVandBAT.Pow_BAT_ChBat)
    annotation (Line(points={{-6.075,29.28},{-6.075,-12},{-6,-12},{-6,-52},{
          -0.25,-52},{-0.25,-50.75}}, color={0,0,127}));
  connect(electricity_PVandBAT.PV_Pow_Use, sumOfPV.u1) annotation (Line(points=
          {{50.5,-9},{50.5,10},{50,10},{50,28},{72,28}}, color={0,0,127}));
  connect(electricity_PVandBAT.PV_Pow_FeedIn, sumOfPV.u2)
    annotation (Line(points={{50.5,-15},{50.5,20},{72,20}}, color={0,0,127}));
  connect(electricity_PVandBAT.PV_Pow_Ch, sumOfPV.u3) annotation (Line(points={
          {50.5,-22},{58,-22},{58,12},{72,12}}, color={0,0,127}));
  connect(sumOfPV.y, directCharge.PVPowerDC) annotation (Line(points={{95,20},{
          100,20},{100,62},{3.48333,62},{3.48333,54.24}}, color={0,0,127}));
  connect(electricity_PVandBAT.inputScenBus, inputScenBus1) annotation (Line(
      points={{-1.75,-21.75},{-18.875,-21.75},{-18.875,-18},{-36,-18}},
      color={255,204,51},
      thickness=0.5));
  connect(GenLoad.y, electricity_PVandBAT.P_el_Gen) annotation (Line(points={{
          -19,-80},{24,-80},{24,-68},{23,-68},{23,-56}}, color={0,0,127}));
  connect(weaDat.weaBus, inputScenBus1.weaBus) annotation (Line(
      points={{-62,1},{-36,1},{-36,-6},{-35.95,-6},{-35.95,-17.95}},
      color={255,204,51},
      thickness=0.5));
  connect(GenLoad.y, directCharge.GenEleLoadAC) annotation (Line(points={{-19,
          -80},{100,-80},{100,76},{-15.325,76},{-15.325,54.48}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StartTime=21600000,
      StopTime=21686400,
      Interval=900,
      Tolerance=1e-05,
      __Dymola_Algorithm="Dassl"),
    __Dymola_experimentSetupOutput,
    __Dymola_experimentFlags(
      Advanced(GenerateVariableDependencies=false, OutputModelicaCode=false),
      Evaluate=false,
      OutputCPUtime=false,
      OutputFlatModelica=false));
end TestDirectCharge;
