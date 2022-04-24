within MA_Pell_SingleFamilyHouse.Utilities;
package KPIs "Package with models for KPI calculation"
  model CountOnTime
    Modelica.Blocks.Sources.IntegerConstant integerConstant(final k=1)
      annotation (Placement(transformation(extent={{-48,26},{-32,42}})));
    Modelica.Blocks.MathInteger.TriggeredAdd triggeredAdd(final use_reset=false,
        final y_start=0)
      "To count on-off cycles"
      annotation (Placement(transformation(extent={{-16,24},{0,42}})));
    Modelica.Blocks.Interfaces.BooleanInput u
      annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
    Modelica.Blocks.Interfaces.IntegerOutput numSwi "Integer output signal"
      annotation (Placement(transformation(extent={{100,70},{120,90}})));
    Modelica.Blocks.Logical.Switch switch1
      annotation (Placement(transformation(extent={{40,-60},{60,-40}})));
    Modelica.Blocks.Sources.Constant const(k=1)
      annotation (Placement(transformation(extent={{6,-36},{26,-16}})));
    Modelica.Blocks.Sources.Constant const1(k=0)
      annotation (Placement(transformation(extent={{6,-78},{26,-58}})));
    Modelica.Blocks.Interfaces.RealOutput onTime
      "Connector of Real output signal"
      annotation (Placement(transformation(extent={{100,-60},{120,-40}})));
    Modelica.Blocks.Continuous.Integrator integrator3
      annotation (Placement(transformation(extent={{76,-56},{88,-44}})));
  equation
    connect(integerConstant.y, triggeredAdd.u) annotation (Line(points={{-31.2,34},
            {-23.6,34},{-23.6,33},{-19.2,33}}, color={255,127,0}));
    connect(triggeredAdd.trigger, u) annotation (Line(points={{-12.8,22.2},{-12.8,
            0},{-120,0}}, color={255,0,255}));
    connect(triggeredAdd.y, numSwi) annotation (Line(points={{1.6,33},{39.8,33},{39.8,
            80},{110,80}}, color={255,127,0}));
    connect(u, switch1.u2) annotation (Line(points={{-120,0},{-14,0},{-14,-50},{38,
            -50}}, color={255,0,255}));
    connect(switch1.u1, const.y) annotation (Line(points={{38,-42},{32,-42},{32,-26},
            {27,-26}}, color={0,0,127}));
    connect(const1.y, switch1.u3) annotation (Line(points={{27,-68},{34,-68},{34,-58},
            {38,-58}}, color={0,0,127}));
    connect(switch1.y, integrator3.u)
      annotation (Line(points={{61,-50},{74.8,-50}}, color={0,0,127}));
    connect(onTime, integrator3.y)
      annotation (Line(points={{110,-50},{88.6,-50}}, color={0,0,127}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Rectangle(
            extent={{-100,100},{100,-100}},
            lineColor={0,0,0},
            fillColor={215,215,215},
            fillPattern=FillPattern.Solid), Text(
            extent={{-62,52},{66,-68}},
            lineColor={0,0,0},
            fillColor={215,215,215},
            fillPattern=FillPattern.Solid,
            textString="%name")}), Diagram(coordinateSystem(preserveAspectRatio=false)));
  end CountOnTime;

  model CountTimeDiscomfort
    Modelica.Blocks.Logical.Switch switch1
      annotation (Placement(transformation(extent={{40,-10},{60,10}})));
    Modelica.Blocks.Sources.Constant const(k=1)
      annotation (Placement(transformation(extent={{6,14},{26,34}})));
    Modelica.Blocks.Sources.Constant const1(k=0)
      annotation (Placement(transformation(extent={{6,-28},{26,-8}})));
    Modelica.Blocks.Interfaces.RealOutput discomfortTime
      "Connector of Real output signal"
      annotation (Placement(transformation(extent={{100,-10},{120,10}})));
    Modelica.Blocks.Continuous.Integrator integrator3(use_reset=true)
      annotation (Placement(transformation(extent={{76,-6},{88,6}})));
    Modelica.Blocks.Interfaces.RealInput T "Connector of Real input signal"
      annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
    Modelica.Blocks.Logical.LessThreshold
                                   switch2(threshold=TRoomSet)
      annotation (Placement(transformation(extent={{-50,-10},{-30,10}})));
    parameter Modelica.Media.Interfaces.Types.Temperature TRoomSet=293.15
      "Room set temperature";
    Modelica.Blocks.Logical.Not not1
      annotation (Placement(transformation(extent={{8,-70},{28,-50}})));
  equation
    connect(switch1.u1, const.y) annotation (Line(points={{38,8},{32,8},{32,24},{
            27,24}},   color={0,0,127}));
    connect(const1.y, switch1.u3) annotation (Line(points={{27,-18},{34,-18},{34,
            -8},{38,-8}},
                       color={0,0,127}));
    connect(switch1.y, integrator3.u)
      annotation (Line(points={{61,0},{74.8,0}},     color={0,0,127}));
    connect(discomfortTime, integrator3.y)
      annotation (Line(points={{110,0},{88.6,0}}, color={0,0,127}));
    connect(T, switch2.u)
      annotation (Line(points={{-120,0},{-52,0}}, color={0,0,127}));
    connect(switch2.y, switch1.u2)
      annotation (Line(points={{-29,0},{38,0}}, color={255,0,255}));
    connect(not1.y, integrator3.reset) annotation (Line(points={{29,-60},{90,-60},
            {90,-7.2},{85.6,-7.2}}, color={255,0,255}));
    connect(switch2.y, not1.u) annotation (Line(points={{-29,0},{-22,0},{-22,-60},
            {6,-60}}, color={255,0,255}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
            Rectangle(
            extent={{-100,100},{100,-100}},
            lineColor={0,0,0},
            fillColor={215,215,215},
            fillPattern=FillPattern.Solid), Text(
            extent={{-62,52},{66,-68}},
            lineColor={0,0,0},
            fillColor={215,215,215},
            fillPattern=FillPattern.Solid,
            textString="%name")}), Diagram(coordinateSystem(preserveAspectRatio=false)));
  end CountTimeDiscomfort;

  package BaseClasses "For partial models"
    partial model PartialKPICalculator "Partial KPI Calculator"
        parameter Real thresholdOn=Modelica.Constants.eps
        "If u is greater than this treshhold the device is considered on.";
      parameter Boolean calc_singleOnTime=true
                                          "True to calc singleOnTime";
      parameter Boolean calc_integral=true
                                      "True to calc integral";
      parameter Boolean calc_totalOnTime=true
                                         "True to calc totalOnTime";
      parameter Boolean calc_numSwi=true
                                    "True to calc number of device on-switches";
      parameter Boolean calc_movAve=true
                                    "True to calc moving average";

      Modelica.Blocks.Logical.Switch switch1 if calc_singleOnTime
        annotation (Placement(transformation(extent={{40,-10},{60,10}})));
      Modelica.Blocks.Sources.Constant const(k=1) if calc_singleOnTime
        annotation (Placement(transformation(extent={{6,14},{26,34}})));
      Modelica.Blocks.Sources.Constant const1(k=0) if calc_singleOnTime
        annotation (Placement(transformation(extent={{6,-28},{26,-8}})));
      Modelica.Blocks.Continuous.Integrator integrator3(use_reset=true) if
        calc_singleOnTime
        annotation (Placement(transformation(extent={{76,-6},{88,6}})));
      Modelica.Blocks.Logical.LessThreshold
                                     switch2(threshold=thresholdOn)
        annotation (Placement(transformation(extent={{-50,-10},{-30,10}})));

      Modelica.Blocks.Logical.Not not1 if calc_singleOnTime
        annotation (Placement(transformation(extent={{8,-70},{28,-50}})));
      Modelica.Blocks.Sources.IntegerConstant integerConstant(final k=1) if
        calc_numSwi
        annotation (Placement(transformation(extent={{-48,136},{-32,152}})));
      Modelica.Blocks.MathInteger.TriggeredAdd triggeredAdd(final use_reset=false,
          final y_start=0) if calc_numSwi
        "To count on-off cycles"
        annotation (Placement(transformation(extent={{-16,134},{0,152}})));
      Modelica.Blocks.Logical.Switch switch3 if calc_totalOnTime
        annotation (Placement(transformation(extent={{40,78},{60,98}})));
      Modelica.Blocks.Sources.Constant const2(k=1) if calc_totalOnTime
        annotation (Placement(transformation(extent={{6,102},{26,122}})));
      Modelica.Blocks.Sources.Constant const3(k=0) if calc_totalOnTime
        annotation (Placement(transformation(extent={{6,60},{26,80}})));
      Modelica.Blocks.Continuous.Integrator integrator1 if calc_totalOnTime
        annotation (Placement(transformation(extent={{76,82},{88,94}})));

      Modelica.Blocks.Continuous.Integrator integrator2(use_reset=false) if
        calc_integral
        annotation (Placement(transformation(extent={{72,-90},{84,-78}})));
      BuildingEnergySystems.Interfaces.KPIBus KPIBus
        annotation (Placement(transformation(extent={{92,-10},{112,10}})));

      Modelica.Blocks.Routing.RealPassThrough internalU annotation (Placement(
            transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-78,0})));
      AixLib.Utilities.Math.MovingAverage movingAverage(aveTime=aveTime) if
        calc_movAve
        annotation (Placement(transformation(extent={{-34,-168},{-14,-148}})));
      parameter Modelica.SIunits.Time aveTime=24*3600
        "Time span for moving average" annotation (Dialog(enable=calc_movAve));
    equation
      connect(switch1.u1, const.y) annotation (Line(points={{38,8},{32,8},{32,24},{
              27,24}},   color={0,0,127}));
      connect(const1.y, switch1.u3) annotation (Line(points={{27,-18},{34,-18},{34,
              -8},{38,-8}},
                         color={0,0,127}));
      connect(switch1.y, integrator3.u)
        annotation (Line(points={{61,0},{74.8,0}},     color={0,0,127}));
      connect(switch2.y, switch1.u2)
        annotation (Line(points={{-29,0},{38,0}}, color={255,0,255}));
      connect(not1.y, integrator3.reset) annotation (Line(points={{29,-60},{86,-60},
              {86,-7.2},{85.6,-7.2}}, color={255,0,255}));
      connect(switch2.y, not1.u) annotation (Line(points={{-29,0},{-22,0},{-22,-60},
              {6,-60}}, color={255,0,255}));
      connect(integerConstant.y,triggeredAdd. u) annotation (Line(points={{-31.2,144},
              {-23.6,144},{-23.6,143},{-19.2,143}},
                                                 color={255,127,0}));
      connect(switch3.u1, const2.y) annotation (Line(points={{38,96},{32,96},{32,112},
              {27,112}}, color={0,0,127}));
      connect(const3.y,switch3. u3) annotation (Line(points={{27,70},{34,70},{34,80},
              {38,80}},  color={0,0,127}));
      connect(switch3.y,integrator1. u)
        annotation (Line(points={{61,88},{74.8,88}},   color={0,0,127}));
      connect(integrator2.y, KPIBus.integral) annotation (Line(points={{84.6,-84},{102,
              -84},{102,0}}, color={0,0,127}), Text(
          string="%second",
          index=1,
          extent={{6,3},{6,3}},
          horizontalAlignment=TextAlignment.Left));
      connect(triggeredAdd.y, KPIBus.numSwi) annotation (Line(points={{1.6,143},{102,
              143},{102,0}}, color={255,127,0}), Text(
          string="%second",
          index=1,
          extent={{6,3},{6,3}},
          horizontalAlignment=TextAlignment.Left));
      connect(switch2.y, switch3.u2) annotation (Line(points={{-29,0},{-18,0},{-18,88},
              {38,88}}, color={255,0,255}));
      connect(switch2.y, triggeredAdd.trigger) annotation (Line(points={{-29,0},{-12.8,
              0},{-12.8,132.2}}, color={255,0,255}));
      connect(integrator3.y, KPIBus.singleOnTime) annotation (Line(points={{88.6,0},
              {102,0}}, color={0,0,127}), Text(
          string="%second",
          index=1,
          extent={{6,3},{6,3}},
          horizontalAlignment=TextAlignment.Left));
      connect(integrator1.y, KPIBus.totalOnTime) annotation (Line(points={{88.6,88},
              {90,88},{90,0},{102,0}},             color={0,0,127}), Text(
          string="%second",
          index=1,
          extent={{6,3},{6,3}},
          horizontalAlignment=TextAlignment.Left));
      connect(switch2.u, internalU.y)
        annotation (Line(points={{-52,0},{-67,0}}, color={0,0,127}));
      connect(internalU.y, integrator2.u)
        annotation (Line(points={{-67,0},{-67,-84},{70.8,-84}}, color={0,0,127}));
      connect(internalU.y, KPIBus.value) annotation (Line(points={{-67,0},{-62,0},{-62,
              -132},{102,-132},{102,0}}, color={0,0,127}), Text(
          string="%second",
          index=1,
          extent={{-6,3},{-6,3}},
          horizontalAlignment=TextAlignment.Right));
      connect(internalU.y, movingAverage.u) annotation (Line(points={{-67,0},{-64,0},
              {-64,2},{-62,2},{-62,-158},{-36,-158}}, color={0,0,127}));
      connect(movingAverage.y, KPIBus.movAve) annotation (Line(points={{-13,-158},{102,
              -158},{102,0}}, color={0,0,127}), Text(
          string="%second",
          index=1,
          extent={{6,3},{6,3}},
          horizontalAlignment=TextAlignment.Left));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-180},
                {100,180}}),                                        graphics={
              Rectangle(
              extent={{-100,100},{100,-100}},
              lineColor={0,0,0},
              fillColor={215,215,215},
              fillPattern=FillPattern.Solid), Text(
              extent={{-62,52},{66,-68}},
              lineColor={0,0,0},
              fillColor={215,215,215},
              fillPattern=FillPattern.Solid,
              textString="%name")}), Diagram(coordinateSystem(preserveAspectRatio=false, extent={
                {-100,-180},{100,180}})));
    end PartialKPICalculator;
  end BaseClasses;

  model InternalKPICalculator
    "KPIs for internal variables. Add via Attributes -> y=someVar"
    extends BaseClasses.PartialKPICalculator(integrator2(y_start=Modelica.Constants.eps));

    Modelica.Blocks.Interfaces.RealInput y "Value of Real input";

    Modelica.Blocks.Sources.RealExpression internal_u(y=y) annotation (
        Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-112,0})));
  equation
    connect(internalU.u, internal_u.y)
      annotation (Line(points={{-90,0},{-101,0}}, color={0,0,127}));
  end InternalKPICalculator;

  model InputKPICalculator "Calculate for given input"
    extends BaseClasses.PartialKPICalculator;
    Modelica.Blocks.Interfaces.RealInput u "Connector of Real input signal"
      annotation (Placement(transformation(extent={{-142,-20},{-102,20}})));
  equation
    connect(internalU.u, u)
      annotation (Line(points={{-90,0},{-122,0}}, color={0,0,127}));
  end InputKPICalculator;
end KPIs;
