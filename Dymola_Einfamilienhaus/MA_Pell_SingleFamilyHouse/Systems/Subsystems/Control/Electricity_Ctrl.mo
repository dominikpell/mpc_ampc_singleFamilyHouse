within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control;
model Electricity_Ctrl
    parameter Modelica.SIunits.Time timZon(displayUnit="h")=timZon
        "Time zone. Should be equal with timZon in ReaderTMY3, if PVSystem and ReaderTMY3 are used together.";
    parameter Real SOC_Bat_Init;
      parameter Integer n_mod=3 "Number of connected PV modules";
    parameter AixLib.DataBase.SolarElectric.PVBaseDataDefinition data = AixLib.DataBase.SolarElectric.ShellSP70()
      "PV Panel data definition";
    parameter ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral
      batteryData=ElectricalStorages.Data.LithiumIon.LithiumIonViessmann()
      "Characteristic data of the battery";
    parameter Integer nBat=3 "Number of batteries";
    parameter Real til = 15*2*3.14/360 annotation(Evaluate=false);
    parameter Real azi1 = 90*(2*3.14)/(360) annotation(Evaluate=false);
    parameter Real azi2 = -90*(2*3.14)/(360) annotation(Evaluate=false);
    parameter Real lat = 52.519*2*3.14/360 annotation(Evaluate=false);
    parameter Real lon = 13.408*2*3.14/360 annotation(Evaluate=false);
    Electrical.PVSystem.PVSystem_ref pVSystemEast(
      data=data,
      redeclare model IVCharacteristics =
          Electrical.PVSystem.BaseClasses.IVCharacteristics5pAnalytical,
      redeclare model CellTemperature =
        Electrical.PVSystem.BaseClasses.CellTemperatureMountingCloseToGround,
      n_mod=n_mod,
      til(displayUnit="deg") = til,
      azi=azi2,
      lat=lat,
      lon=lon,
      alt=15,
      timZon=timZon)
      annotation (Placement(transformation(extent={{-64,64},{-32,96}})));

    Electrical.PVSystem.PVSystem_ref
                                 pVSystemWest(
      data=data,
      redeclare model IVCharacteristics =
          Electrical.PVSystem.BaseClasses.IVCharacteristics5pAnalytical,
      redeclare model CellTemperature =
        Electrical.PVSystem.BaseClasses.CellTemperatureMountingCloseToGround,
      n_mod=n_mod,
      til=til,
      azi=azi1,
      lat=lat,
      lon=lon,
      alt=15,
      timZon=timZon)
      annotation (Placement(transformation(extent={{-64,100},{-32,132}})));

    Modelica.Blocks.Math.Add tot_powerPV
      annotation (Placement(transformation(extent={{-10,112},{10,132}})));
    Modelica.Blocks.Interfaces.RealInput PV_Distr_Use annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,158}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-1})));
    Modelica.Blocks.Interfaces.RealInput PV_Distr_ChBat annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,126}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-29})));
    Modelica.Blocks.Interfaces.RealInput PV_Distr_FeedIn annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,142}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-15})));
    Modelica.Blocks.Interfaces.RealInput Pow_BAT_Use annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,-44}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-59})));
    Modelica.Blocks.Interfaces.RealInput Pow_BAT_ChBat annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,-78}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-87})));
    Modelica.Blocks.Interfaces.RealInput Pow_BAT_FeedIn annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,-62}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-73})));
    Modelica.Blocks.Math.Product PV_ch_BAT
      annotation (Placement(transformation(extent={{36,116},{46,126}})));
    Modelica.Blocks.Math.Product PV_use
    annotation (Placement(transformation(extent={{36,144},{46,154}})));
    Modelica.Blocks.Math.Product PV_FeedIn
    annotation (Placement(transformation(extent={{36,130},{46,140}})));
    AixLib.BoundaryConditions.WeatherData.Bus
        weaBus "Weather data bus" annotation (Placement(transformation(extent={{-110,88},
            {-90,108}}),           iconTransformation(extent={{-110,88},{-90,
            108}})));
    Modelica.Blocks.Interfaces.RealInput P_el_Gen annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,6}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=90,
          origin={1,-93})));
    Modelica.Blocks.Interfaces.RealInput P_el_dom annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,-8}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=90,
          origin={23,-93})));
  Modelica.Blocks.Math.Add domDem
    annotation (Placement(transformation(extent={{-72,-12},{-52,8}})));
  Modelica.Blocks.Math.Division division
    annotation (Placement(transformation(extent={{-34,20},{-14,40}})));
  Modelica.Blocks.Nonlinear.Limiter limiter(uMax=1, uMin=0)
    annotation (Placement(transformation(extent={{-6,24},{8,38}})));
  Modelica.Blocks.Math.Add add(k1=-1)
    annotation (Placement(transformation(extent={{22,6},{42,26}})));
  Modelica.Blocks.Math.Division division1
    annotation (Placement(transformation(extent={{-58,-54},{-38,-34}})));
  Modelica.Blocks.Nonlinear.Limiter limiter1(uMax=1, uMin=0)
    annotation (Placement(transformation(extent={{-30,-50},{-16,-36}})));
equation

    connect(pVSystemWest.DCOutputPower, tot_powerPV.u1) annotation (Line(points={{-30.4,
          116},{-22,116},{-22,128},{-12,128}},     color={0,0,127}));
    connect(pVSystemEast.DCOutputPower, tot_powerPV.u2) annotation (Line(points={{-30.4,
          80},{-18,80},{-18,116},{-12,116}},       color={0,0,127}));
    connect(weaBus, pVSystemWest.waeBus) annotation (Line(
        points={{-100,98},{-88,98},{-88,116},{-64,116}},
        color={255,204,51},
        thickness=0.5));
    connect(weaBus, pVSystemEast.waeBus) annotation (Line(
        points={{-100,98},{-88,98},{-88,80},{-64,80}},
        color={255,204,51},
        thickness=0.5));
  connect(PV_Distr_Use, PV_use.u1) annotation (Line(points={{-100,158},{-80,158},
          {-80,152},{35,152}}, color={0,0,127}));
  connect(PV_Distr_FeedIn, PV_FeedIn.u1) annotation (Line(points={{-100,142},{
          28,142},{28,138},{35,138}}, color={0,0,127}));
  connect(PV_Distr_ChBat, PV_ch_BAT.u1) annotation (Line(points={{-100,126},{
          -80,126},{-80,140},{22,140},{22,122},{28,122},{28,124},{35,124}},
        color={0,0,127}));
  connect(tot_powerPV.y, PV_use.u2) annotation (Line(points={{11,122},{16,122},
          {16,146},{35,146}}, color={0,0,127}));
  connect(tot_powerPV.y, PV_FeedIn.u2) annotation (Line(points={{11,122},{16,
          122},{16,132},{35,132}}, color={0,0,127}));
  connect(tot_powerPV.y, PV_ch_BAT.u2) annotation (Line(points={{11,122},{16,
          122},{16,118},{35,118}}, color={0,0,127}));
  connect(P_el_Gen, domDem.u1) annotation (Line(points={{-100,6},{-86,6},{-86,4},
          {-74,4}}, color={0,0,127}));
  connect(P_el_dom, domDem.u2)
    annotation (Line(points={{-100,-8},{-74,-8}}, color={0,0,127}));
  connect(division.y, limiter.u) annotation (Line(points={{-13,30},{-8,30},{-8,
          31},{-7.4,31}}, color={0,0,127}));
  connect(domDem.y, add.u2) annotation (Line(points={{-51,-2},{-46,-2},{-46,10},
          {20,10}}, color={0,0,127}));
  connect(limiter.y, add.u1) annotation (Line(points={{8.7,31},{14,31},{14,22},
          {20,22}}, color={0,0,127}));
  connect(division1.y, limiter1.u) annotation (Line(points={{-37,-44},{-32,-44},
          {-32,-43},{-31.4,-43}}, color={0,0,127}));
  connect(add.y, division1.u1) annotation (Line(points={{43,16},{50,16},{50,-24},
          {-78,-24},{-78,-38},{-60,-38}}, color={0,0,127}));
  connect(domDem.y, division.u1) annotation (Line(points={{-51,-2},{-46,-2},{
          -46,36},{-36,36}}, color={0,0,127}));
  connect(PV_use.y, division.u2) annotation (Line(points={{46.5,149},{58,149},{
          58,56},{-42,56},{-42,24},{-36,24}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(extent={{-100,-160},{100,160}})), Icon(
        coordinateSystem(extent={{-100,-160},{100,160}})));
end Electricity_Ctrl;
