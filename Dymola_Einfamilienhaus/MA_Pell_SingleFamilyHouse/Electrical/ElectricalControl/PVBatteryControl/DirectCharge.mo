within MA_Pell_SingleFamilyHouse.Electrical.ElectricalControl.PVBatteryControl;
model DirectCharge
  "Control logic mainly focusing on maximizing self consumption"
  extends
    MA_Pell_SingleFamilyHouse.Electrical.ElectricalControl.BaseClasses.PartialControl;
  Modelica.Blocks.Logical.LessThreshold BatteryNotFull(threshold=1)
    annotation (Placement(transformation(extent={{-144,34},{-124,54}})));
  Modelica.Blocks.Logical.Switch switchForPVExcessToBatRel
    "Switch for PV excess energy charging the Bat" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-52,-40})));
  Modelica.Blocks.Interfaces.RealOutput PV_Distr_Use
    "Connector of Real output signal" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={130,-102})));
  Modelica.Blocks.Interfaces.RealOutput PV_Distr_FeedIn
    "Excess power from PV to grid (DC)" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={166,-102})));
  Modelica.Blocks.Interfaces.RealOutput PV_Distr_ChBat
    "Actual battery DC power to grid" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={200,-102})));
  Modelica.Blocks.Math.Feedback feedback
    annotation (Placement(transformation(extent={{-6,16},{-26,36}})));
  Modelica.Blocks.Interfaces.RealOutput Pow_BAT_Use
    "Connector of Real output signal" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-56,-106})));
  Modelica.Blocks.Interfaces.RealOutput Pow_BAT_FeedIn
    "Excess power from PV to grid (DC)" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-28,-106})));
  Modelica.Blocks.Interfaces.RealOutput Pow_BAT_ChBat
    "Actual battery DC power to grid" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={6,-106})));
  Modelica.Blocks.Logical.LessThreshold PVBiggerLoad(threshold=Modelica.Constants.eps)
    annotation (Placement(transformation(extent={{-56,50},{-76,70}})));
  Modelica.Blocks.Logical.And BatNotFullAndExcessPV annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-84,22})));
  Modelica.Blocks.Math.Gain gain(k=-1) annotation (Placement(transformation(
        extent={{-8,-8},{8,8}},
        rotation=-90,
        origin={-52,10})));
  Modelica.Blocks.Math.Division division annotation (Placement(transformation(
        extent={{-7,7},{7,-7}},
        rotation=-90,
        origin={7,-15})));
  Modelica.Blocks.Logical.Switch switchForPVExcessToBatPow
    "Switch for PV excess energy charging the Bat" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-126,-40})));
  Modelica.Blocks.Logical.And BatFullAndExcessPV annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={226,22})));
  Modelica.Blocks.Logical.Not BatteryFull
    annotation (Placement(transformation(extent={{178,28},{198,48}})));
  Modelica.Blocks.Logical.Switch switchForPVExcessToGridRel
    "Switch for PV excess energy to grid" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={142,-34})));
  Modelica.Blocks.Sources.RealExpression ZeroFlow
    annotation (Placement(transformation(extent={{28,-18},{48,2}})));
  Modelica.Blocks.Logical.Switch switchForPVCovBuiLoad
    "Switch for PV covers building load" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={88,-36})));
  Modelica.Blocks.Math.Division division1 annotation (Placement(transformation(
        extent={{-7,7},{7,-7}},
        rotation=-90,
        origin={97,23})));
  Modelica.Blocks.Sources.RealExpression FullCoverPVBui(y=1.0)
    "Full PV power is used for building load covering"
    annotation (Placement(transformation(extent={{36,-58},{56,-38}})));
  Modelica.Blocks.Logical.GreaterThreshold BatNotEmpty(threshold=threshold)
    annotation (Placement(transformation(extent={{-222,6},{-202,26}})));
  Modelica.Blocks.Logical.Switch switchForPVExcessToBatPow1
    "Switch for PV excess energy charging the Bat" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-184,-50})));
  Modelica.Blocks.Logical.Not noExcess
    annotation (Placement(transformation(extent={{-138,4},{-158,24}})));
  Modelica.Blocks.Logical.And BatNotEmptyAndBuiLoad
    "Battery is used as soon as building load is positive and battery not empty"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-184,-14})));
  Modelica.Blocks.Sources.RealExpression ZeroFlow1
    annotation (Placement(transformation(extent={{-232,-28},{-212,-8}})));
  Modelica.Blocks.Math.Add sumEleLoadsAC annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={-24,72})));
  Modelica.Blocks.Nonlinear.Limiter limiter(uMax=1, uMin=0)
    annotation (Placement(transformation(extent={{100,-82},{114,-68}})));
  Modelica.Blocks.Nonlinear.Limiter limiter1(uMax=1, uMin=0)
    annotation (Placement(transformation(extent={{172,-64},{186,-50}})));
  Modelica.Blocks.Nonlinear.Limiter limiter2(uMax=1, uMin=0) annotation (
      Placement(transformation(
        extent={{-7,-7},{7,7}},
        rotation=-90,
        origin={145,-73})));
  parameter Real threshold=SOC_min "Battery SOC higher than minimum SOC";
  Modelica.Blocks.Logical.LessThreshold isZero(threshold=Modelica.Constants.eps)
    annotation (Placement(transformation(extent={{120,82},{130,92}})));
  Modelica.Blocks.Logical.Switch noPVdummy "Switch for PV covers building load"
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={152,88})));
  Modelica.Blocks.Sources.RealExpression AlmostZeroFlow(y=Modelica.Constants.eps)
    annotation (Placement(transformation(extent={{98,86},{118,106}})));
equation

  connect(SOCBat, BatteryNotFull.u) annotation (Line(points={{-126,104},{-126,
          88},{-164,88},{-164,44},{-146,44}},
                                          color={0,0,127}));
  connect(feedback.y, PVBiggerLoad.u) annotation (Line(points={{-25,26},{-28,26},
          {-28,60},{-54,60}}, color={0,0,127}));
  connect(BatteryNotFull.y, BatNotFullAndExcessPV.u2)
    annotation (Line(points={{-123,44},{-92,44},{-92,34}}, color={255,0,255}));
  connect(PVBiggerLoad.y, BatNotFullAndExcessPV.u1)
    annotation (Line(points={{-77,60},{-84,60},{-84,34}}, color={255,0,255}));
  connect(BatNotFullAndExcessPV.y, switchForPVExcessToBatRel.u2) annotation (
      Line(points={{-84,11},{-84,-28},{-52,-28}}, color={255,0,255}));
  connect(feedback.y, gain.u) annotation (Line(points={{-25,26},{-16,26},{-16,
          22},{-52,22},{-52,19.6}}, color={0,0,127}));
  connect(gain.y, division.u1) annotation (Line(points={{-52,1.2},{-52,-6.6},{
          2.8,-6.6}}, color={0,0,127}));
  connect(division.y, switchForPVExcessToBatRel.u1) annotation (Line(points={{7,
          -22.7},{-18,-22.7},{-18,-22},{-44,-22},{-44,-28}}, color={0,0,127}));
  connect(BatNotFullAndExcessPV.y, switchForPVExcessToBatPow.u2) annotation (
      Line(points={{-84,11},{-84,-6},{-126,-6},{-126,-28}}, color={255,0,255}));
  connect(gain.y, switchForPVExcessToBatPow.u1) annotation (Line(points={{-52,
          1.2},{-118,1.2},{-118,-28}}, color={0,0,127}));
  connect(switchForPVExcessToBatPow.y, Pow_BAT_ChBat) annotation (Line(points={
          {-126,-51},{-126,-72},{6,-72},{6,-106}}, color={0,0,127}));
  connect(BatteryNotFull.y, BatteryFull.u) annotation (Line(points={{-123,44},{
          18,44},{18,38},{176,38}},   color={255,0,255}));
  connect(BatteryFull.y, BatFullAndExcessPV.u2)
    annotation (Line(points={{199,38},{218,38},{218,34}}, color={255,0,255}));
  connect(PVBiggerLoad.y, BatFullAndExcessPV.u1)
    annotation (Line(points={{-77,60},{226,60},{226,34}}, color={255,0,255}));
  connect(BatFullAndExcessPV.y, switchForPVExcessToGridRel.u2) annotation (Line(
        points={{226,11},{226,-22},{142,-22}}, color={255,0,255}));
  connect(division.y, switchForPVExcessToGridRel.u1) annotation (Line(points={{
          7,-22.7},{7,-30},{62,-30},{62,-10},{150,-10},{150,-22}}, color={0,0,
          127}));
  connect(ZeroFlow.y, switchForPVExcessToGridRel.u3)
    annotation (Line(points={{49,-8},{134,-8},{134,-22}}, color={0,0,127}));
  connect(ZeroFlow.y, switchForPVExcessToBatRel.u3) annotation (Line(points={{
          49,-8},{68,-8},{68,-16},{-60,-16},{-60,-28}}, color={0,0,127}));
  connect(ZeroFlow.y, switchForPVExcessToBatPow.u3) annotation (Line(points={{
          49,-8},{68,-8},{68,-16},{-134,-16},{-134,-28}}, color={0,0,127}));
  connect(PVBiggerLoad.y, switchForPVCovBuiLoad.u2) annotation (Line(points={{
          -77,60},{10,60},{10,6},{88,6},{88,-24}}, color={255,0,255}));
  connect(division1.y, switchForPVCovBuiLoad.u1) annotation (Line(points={{97,15.3},
          {97,2},{96,2},{96,-24}},       color={0,0,127}));
  connect(FullCoverPVBui.y, switchForPVCovBuiLoad.u3) annotation (Line(points={
          {57,-48},{68,-48},{68,-16},{80,-16},{80,-24}}, color={0,0,127}));
  connect(ZeroFlow.y, Pow_BAT_FeedIn) annotation (Line(points={{49,-8},{52,-8},
          {52,-86},{-28,-86},{-28,-106}}, color={0,0,127}));
  connect(SOCBat, BatNotEmpty.u) annotation (Line(points={{-126,104},{-72,104},
          {-72,88},{-226,88},{-226,16},{-224,16}}, color={0,0,127}));
  connect(BatNotEmptyAndBuiLoad.y, switchForPVExcessToBatPow1.u2)
    annotation (Line(points={{-184,-25},{-184,-38}}, color={255,0,255}));
  connect(BatNotEmpty.y, BatNotEmptyAndBuiLoad.u2) annotation (Line(points={{
          -201,16},{-192,16},{-192,-2}}, color={255,0,255}));
  connect(noExcess.y, BatNotEmptyAndBuiLoad.u1) annotation (Line(points={{-159,
          14},{-184,14},{-184,-2}}, color={255,0,255}));
  connect(PVBiggerLoad.y, noExcess.u) annotation (Line(points={{-77,60},{-104,
          60},{-104,14},{-136,14}}, color={255,0,255}));
  connect(feedback.y, switchForPVExcessToBatPow1.u1) annotation (Line(points={{
          -25,26},{-164,26},{-164,-28},{-170,-28},{-170,-38},{-176,-38}}, color=
         {0,0,127}));
  connect(ZeroFlow1.y, switchForPVExcessToBatPow1.u3) annotation (Line(points={
          {-211,-18},{-200,-18},{-200,-38},{-192,-38}}, color={0,0,127}));
  connect(switchForPVExcessToBatPow1.y, Pow_BAT_Use) annotation (Line(points={{
          -184,-61},{-184,-82},{-56,-82},{-56,-106}}, color={0,0,127}));
  connect(BuiEleLoadAC, sumEleLoadsAC.u1) annotation (Line(points={{0,104},{0,
          94},{-18,94},{-18,84}}, color={0,0,127}));
  connect(GenEleLoadAC, sumEleLoadsAC.u2)
    annotation (Line(points={{-54,104},{-54,84},{-30,84}}, color={0,0,127}));
  connect(sumEleLoadsAC.y, feedback.u1) annotation (Line(points={{-24,61},{-16,
          61},{-16,44},{2,44},{2,26},{-8,26}}, color={0,0,127}));
  connect(switchForPVCovBuiLoad.y, limiter.u) annotation (Line(points={{88,-47},
          {90,-47},{90,-76},{98.6,-76},{98.6,-75}}, color={0,0,127}));
  connect(limiter.y, PV_Distr_Use) annotation (Line(points={{114.7,-75},{130,
          -75},{130,-102}}, color={0,0,127}));
  connect(switchForPVExcessToBatRel.y, limiter1.u) annotation (Line(points={{
          -52,-51},{-52,-56},{170.6,-56},{170.6,-57}}, color={0,0,127}));
  connect(limiter1.y, PV_Distr_ChBat) annotation (Line(points={{186.7,-57},{200,
          -57},{200,-102}}, color={0,0,127}));
  connect(switchForPVExcessToGridRel.y, limiter2.u) annotation (Line(points={{
          142,-45},{146,-45},{146,-64.6},{145,-64.6}}, color={0,0,127}));
  connect(limiter2.y, PV_Distr_FeedIn) annotation (Line(points={{145,-80.7},{
          145,-88.35},{166,-88.35},{166,-102}}, color={0,0,127}));
  connect(sumEleLoadsAC.y, division1.u1) annotation (Line(points={{-24,61},{-4,
          61},{-4,62},{92.8,62},{92.8,31.4}}, color={0,0,127}));
  connect(isZero.u, PVPowerDC)
    annotation (Line(points={{119,87},{68,87},{68,102}}, color={0,0,127}));
  connect(AlmostZeroFlow.y, noPVdummy.u1)
    annotation (Line(points={{119,96},{140,96}}, color={0,0,127}));
  connect(isZero.y, noPVdummy.u2) annotation (Line(points={{130.5,87},{136,87},
          {136,88},{140,88}}, color={255,0,255}));
  connect(noPVdummy.u3, PVPowerDC)
    annotation (Line(points={{140,80},{68,80},{68,102}}, color={0,0,127}));
  connect(noPVdummy.y, division1.u2) annotation (Line(points={{163,88},{172,88},
          {172,70},{101.2,70},{101.2,31.4}}, color={0,0,127}));
  connect(noPVdummy.y, feedback.u2) annotation (Line(points={{163,88},{172,88},
          {172,70},{30,70},{30,18},{-16,18}}, color={0,0,127}));
  connect(division.u2, feedback.u2) annotation (Line(points={{11.2,-6.6},{11.2,
          12},{30,12},{30,18},{-16,18}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end DirectCharge;
