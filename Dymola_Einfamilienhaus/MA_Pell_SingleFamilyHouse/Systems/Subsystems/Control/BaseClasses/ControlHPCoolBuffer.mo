within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control.BaseClasses;
model ControlHPCoolBuffer
"Control logic for heat pump in cooling mode with buffer storage"
Modelica.Blocks.Logical.Hysteresis hysteresis(uLow=uLowHyst, uHigh=uHighHyst)
  annotation (Placement(transformation(extent={{8,64},{34,90}})));
Modelica.Blocks.Interfaces.BooleanOutput HPOn_Cooling
  annotation (Placement(transformation(extent={{94,66},{114,86}})));
parameter Real uLowHyst "if y=true and u<=uLow, switch to y=false";
parameter Real uHighHyst "if y=false and u>=uHigh, switch to y=true";
Modelica.Blocks.Logical.And and1
  annotation (Placement(transformation(extent={{62,48},{82,68}})));
Modelica.Blocks.Math.RectifiedMean rectifiedMean(f=frequ_TAmb)
  annotation (Placement(transformation(extent={{-16,-4},{4,16}})));
parameter Modelica.SIunits.Frequency frequ_TAmb=1/21600
  "Frequency for moving average of T ambient";
Modelica.Blocks.Logical.GreaterEqualThreshold greaterEqualThreshold(threshold=
     thresholdCooling)
  annotation (Placement(transformation(extent={{18,-4},{38,16}})));
parameter Real thresholdCooling=297.15 "Threshold temperature below which no cooling occurs";
Modelica.Blocks.Continuous.LimPID PIDCool(
  controllerType=Modelica.Blocks.Types.SimpleController.PI,
  k=k,
  Ti=Ti,
  yMax=-minModRange,
  yMin=-1) annotation (Placement(transformation(extent={{12,-52},{32,-32}})));
Modelica.Blocks.Sources.Constant SouTSetCool(k=TSetCool)
  annotation (Placement(transformation(extent={{-22,-36},{-2,-16}})));
parameter Real TSetCool=291.15 "Constant output value";
parameter Real k=1 "Gain of controller";
parameter Modelica.SIunits.Time Ti=0.5 "Time constant of Integrator block";
Modelica.Blocks.Interfaces.RealOutput HPn_Set
  "Relative compressor speed of heat pump [0,1]"
  annotation (Placement(transformation(extent={{92,-56},{112,-36}})));
Modelica.Blocks.Math.Gain antiproportional(k=-1)
  annotation (Placement(transformation(extent={{40,-52},{52,-40}})));
parameter Real minModRange=0.3 "Minimum modulation range of hp";
AixLib.Controls.HeatPump.SafetyControls.OnOffControl onOffControl(
  use_minRunTime=use_minRunTime,
  minRunTime=minRunTime,
  use_minLocTime=use_minLocTime,
  minLocTime=minLocTime,
  use_runPerHou=use_runPerHou,
  maxRunPerHou=maxRunPerHou,
  pre_n_start=pre_n_start)
  annotation (Placement(transformation(extent={{60,-58},{84,-36}})));
parameter Boolean use_minRunTime
  "False if minimal runtime of HP is not considered";
parameter Modelica.SIunits.Time minRunTime "Mimimum runtime of heat pump";
parameter Boolean use_minLocTime
  "False if minimal locktime of HP is not considered";
parameter Modelica.SIunits.Time minLocTime "Minimum lock time of heat pump";
parameter Boolean use_runPerHou
  "False if maximal runs per hour of HP are not considered";
parameter Integer maxRunPerHou "Maximal number of on/off cycles in one hour";
parameter Boolean pre_n_start=true "Start value of pre(n) at initial time";
Interfaces.DistributionControlBus sigBusDistr
  annotation (Placement(transformation(extent={{28,-144},{86,-58}})));
Interfaces.GenerationControlBus sigBusGen annotation (Placement(
      transformation(extent={{-86,-128},{-30,-76}}), iconTransformation(
        extent={{-86,-128},{-30,-76}})));
Modelica.Blocks.Interfaces.RealInput TDryBul
  annotation (Placement(transformation(extent={{-126,-18},{-86,22}})));
equation
connect(hysteresis.y, and1.u1) annotation (Line(points={{35.3,77},{45.65,77},
        {45.65,58},{60,58}},color={255,0,255}));
connect(and1.y, HPOn_Cooling) annotation (Line(points={{83,58},{88,58},{88,76},
        {104,76}}, color={255,0,255}));
connect(rectifiedMean.y, greaterEqualThreshold.u)
  annotation (Line(points={{5,6},{16,6}}, color={0,0,127}));
connect(greaterEqualThreshold.y, and1.u2) annotation (Line(points={{39,6},{46,
        6},{46,50},{60,50}}, color={255,0,255}));
connect(SouTSetCool.y, PIDCool.u_s) annotation (Line(points={{-1,-26},{4,-26},{
          4,-42},{10,-42}}, color={0,0,127}));
connect(PIDCool.y, antiproportional.u)
  annotation (Line(points={{33,-42},{34,-42},{34,-46},{38.8,-46}},
                                                 color={0,0,127}));
connect(antiproportional.y, onOffControl.nSet)
  annotation (Line(points={{52.6,-46},{58.4,-46}}, color={0,0,127}));
connect(onOffControl.nOut, HPn_Set)
  annotation (Line(points={{85,-46},{102,-46}}, color={0,0,127}));
connect(sigBusDistr.T_StoBuf_bot, PIDCool.u_m) annotation (Line(
    points={{57.145,-100.785},{57.145,-81.5},{22,-81.5},{22,-54}},
    color={255,204,51},
    thickness=0.5), Text(
    string="%first",
    index=-1,
    extent={{-3,-6},{-3,-6}},
    horizontalAlignment=TextAlignment.Right));
connect(sigBusDistr.T_StoBuf_bot, hysteresis.u) annotation (Line(
    points={{57.145,-100.785},{58,-100.785},{58,-100},{-100,-100},{-100,76},{
        5.4,76},{5.4,77}},
    color={255,204,51},
    thickness=0.5), Text(
    string="%first",
    index=-1,
    extent={{-3,-6},{-3,-6}},
    horizontalAlignment=TextAlignment.Right));
connect(sigBusGen.hp_bus, onOffControl.sigBusHP) annotation (Line(
    points={{-57.86,-101.87},{-57.86,-66},{54,-66},{54,-52.9},{58.5,-52.9}},
    color={255,204,51},
    thickness=0.5), Text(
    string="%first",
    index=-1,
    extent={{-6,3},{-6,3}},
    horizontalAlignment=TextAlignment.Right));
connect(TDryBul, rectifiedMean.u) annotation (Line(points={{-106,2},{-62,2},{
        -62,6},{-18,6}}, color={0,0,127}));
annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
      coordinateSystem(preserveAspectRatio=false)));
end ControlHPCoolBuffer;
