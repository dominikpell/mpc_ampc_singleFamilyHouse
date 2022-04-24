within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control.BaseClasses;
partial model PartialTwoPoint_HPS_Controller_Laura
  "Partial model with replaceable blocks for rule based control of HPS using on off heating rods"
extends
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control.BaseClasses.PartialControl;

replaceable
  Components.Control.OnOffController.BaseClasses.PartialOnOffController
  DHWOnOffController annotation (choicesAllMatching=true, Placement(
      transformation(extent={{-128,78},{-112,94}})));
replaceable
  Components.Control.OnOffController.BaseClasses.PartialOnOffController
  BufferOnOffController annotation (choicesAllMatching=true, Placement(
      transformation(extent={{-128,34},{-112,48}})));

Components.Control.HeatingCurve heatingCurve(
  TRoomSet=systemParameters.TSetRoomConst,
  GraHeaCurve=systemParameters.GradientHeatCurve,
  THeaThres=systemParameters.THeaTrehs,
  dTOffSet_HC=systemParameters.dTOffSetHeatCurve)
  annotation (Placement(transformation(extent={{-212,18},{-190,40}})));
Modelica.Blocks.MathBoolean.Or
                           HRactive(nu=3)
                                    annotation (Placement(transformation(
      extent={{-5,-5},{5,5}},
      rotation=0,
      origin={15,25})));
Modelica.Blocks.Logical.Or HP_active
                                    annotation (Placement(transformation(
      extent={{-5,-5},{5,5}},
      rotation=0,
      origin={27,91})));
replaceable
  Components.Control.HeatPumpNSetController.BaseClasses.PartialHPNSetController
  HP_nSet_Controller annotation (choicesAllMatching=true, Placement(
      transformation(extent={{82,64},{112,92}})));
Modelica.Blocks.Math.Add add_dT_Loading
  annotation (Placement(transformation(extent={{40,68},{50,78}})));
Modelica.Blocks.Logical.Switch switch1
  annotation (Placement(transformation(extent={{-5,-5},{5,5}},
      rotation=0,
      origin={15,77})));
Modelica.Blocks.Sources.Constant const_dT_loading(k=systemParameters.dT_loading
       + systemParameters.dT_hys/2) annotation (Placement(transformation(
      extent={{2,-2},{-2,2}},
      rotation=180,
      origin={28,70})));

Modelica.Blocks.MathBoolean.Or
                           DHWHysOrLegionella(nu=4)
  "Use the HR if the HP reached its limit" annotation (Placement(
      transformation(
      extent={{-5,-5},{5,5}},
      rotation=0,
      origin={-77,69})));
AixLib.Controls.HeatPump.SafetyControls.SafetyControl securityControl(
  final minRunTime=systemParameters.minRunTime,
  final minLocTime=systemParameters.minLocTime,
  final maxRunPerHou=systemParameters.maxRunPerHou,
  final use_opeEnv=true,
  final use_opeEnvFroRec=true,
  final dataTable=AixLib.DataBase.HeatPump.EN14511.Vitocal200AWO201(
      tableUppBou=[-20,50; -10,60; 30,60; 35,55]),
  final tableUpp=[-40,70; 40,70],
  final use_minRunTime=systemParameters.use_minRunTime,
  final use_minLocTime=systemParameters.use_minLocTime,
  final use_runPerHou=systemParameters.use_runPerHou,
  final use_deFro=false,
  final minIceFac=0,
  final use_chiller=false,
  final calcPel_deFro=0,
  final pre_n_start=systemParameters.pre_n_start,
  use_antFre=false) annotation (Placement(transformation(
      extent={{-16,-17},{16,17}},
      rotation=0,
      origin={210,81})));
Modelica.Blocks.Sources.BooleanConstant hp_mode(final k=true) annotation (
    Placement(transformation(
      extent={{-7,-7},{7,7}},
      rotation=0,
      origin={155,69})));
Modelica.Blocks.Sources.Constant hp_iceFac(final k=1) annotation (Placement(
      transformation(
      extent={{-7,-7},{7,7}},
      rotation=0,
      origin={-181,-85})));

replaceable
  Components.Control.SecurityControls.BaseClasses.PartialTSet_DHW_Control
  TSet_DHW annotation (choicesAllMatching=true, Placement(transformation(
        extent={{-216,66},{-192,90}})));
Modelica.Blocks.Routing.RealPassThrough realPassThrough_T_Amb1
  "Only used to make warning disappear, has no effect on model veloccity"
  annotation (Placement(transformation(extent={{-242,-102},{-220,-80}})));
Modelica.Blocks.Logical.Or BufOn annotation (Placement(transformation(
      extent={{-5,-5},{5,5}},
      rotation=0,
      origin={-67,41})));
Modelica.Blocks.Routing.RealPassThrough realPassThrough_T_Amb2
  "Only used to make warning disappear, has no effect on model veloccity"
  annotation (Placement(transformation(extent={{-242,-132},{-220,-110}})));
Modelica.Blocks.Math.BooleanToReal
                           or3(final realTrue=1, final realFalse=0)
                               annotation (Placement(transformation(
      extent={{-6,-6},{6,6}},
      rotation=0,
      origin={36,26})));
Modelica.Blocks.Logical.And AmbCoolEnough
  annotation (Placement(transformation(extent={{-60,-2},{-50,8}})));
Modelica.Blocks.Logical.LessThreshold lessThreshold(threshold=
      systemParameters.T_threshold_heat)
  annotation (Placement(transformation(extent={{-106,-6},{-94,6}})));
Modelica.Blocks.Math.RectifiedMean rectifiedMean(f=f) "Like moving average"
  annotation (Placement(transformation(extent={{-190,-14},{-170,6}})));
parameter Modelica.SIunits.Frequency f=1/10800 "Base frequency";
ControlHPCoolBuffer controlHPCoolBuffer(
  uLowHyst=systemParameters.TSup_nominal_Cooling - 2.5,
  uHighHyst=systemParameters.TSup_nominal_Cooling + 2.5,
  final thresholdCooling=systemParameters.T_threshold_cool,
  final TSetCool=systemParameters.TSup_nominal_Cooling,
  final minModRange=systemParameters.ratioQHPMin,
  final use_minRunTime=systemParameters.use_minRunTime,
  final minRunTime=systemParameters.minRunTime,
  final use_minLocTime=systemParameters.use_minLocTime,
  minLocTime=systemParameters.minLocTime,
  final use_runPerHou=systemParameters.use_runPerHou,
  final maxRunPerHou=systemParameters.maxRunPerHou,
  final pre_n_start=systemParameters.pre_n_start)
  annotation (Placement(transformation(extent={{-178,-62},{-118,-22}})));
Modelica.Blocks.Logical.Switch switchHeatingCooling annotation (Placement(
      transformation(
      extent={{-8,-8},{8,8}},
      rotation=0,
      origin={-40,-44})));
Modelica.Blocks.Logical.LogicalSwitch HPMode
  "Heating = true; Cooling = false"
  annotation (Placement(transformation(extent={{10,-92},{30,-72}})));
Modelica.Blocks.Sources.BooleanExpression HPInCoolingMode
  annotation (Placement(transformation(extent={{-24,-82},{-4,-62}})));
Modelica.Blocks.Logical.And noDHWAndCooling "DHW has priority over cooling"
  annotation (Placement(transformation(extent={{-80,-30},{-60,-10}})));
Modelica.Blocks.Logical.Not notDHW
  annotation (Placement(transformation(extent={{-122,-18},{-110,-6}})));
Modelica.Blocks.Interfaces.RealInput TRoom[systemParameters.nZones]
  annotation (Placement(transformation(
      extent={{-20,-20},{20,20}},
      rotation=-90,
      origin={-34,102})));
Components.Control.TransferSystem.TransferOnOff transferOnOff
  annotation (Placement(transformation(extent={{42,-38},{96,-12}})));
equation
connect(BufferOnOffController.T_Top, sigBusDistr.T_StoBuf_top) annotation (
    Line(points={{-128.8,45.9},{-316,45.9},{-316,-166},{4,-166},{4,-100.785},{1.145,
          -100.785}},
      color={0,0,127}), Text(
    string="%second",
    index=1,
    extent={{-6,3},{-6,3}},
    horizontalAlignment=TextAlignment.Right));
connect(DHWOnOffController.T_Top, sigBusDistr.T_StoDHW_top) annotation (Line(
      points={{-128.8,91.6},{-316,91.6},{-316,-166},{1.145,-166},{1.145,-100.785}},
      color={0,0,127}), Text(
    string="%second",
    index=1,
    extent={{-6,3},{-6,3}},
    horizontalAlignment=TextAlignment.Right));
connect(heatingCurve.TSet, BufferOnOffController.T_Set) annotation (Line(
      points={{-188.9,29},{-120,29},{-120,33.3}}, color={0,0,127}));

connect(BufferOnOffController.T_bot, sigBusDistr.T_StoBuf_bot) annotation (
    Line(points={{-128.8,37.5},{-318,37.5},{-318,-166},{2,-166},{2,-100.785},{1.145,
          -100.785}},
      color={0,0,127}), Text(
    string="%second",
    index=1,
    extent={{-6,3},{-6,3}},
    horizontalAlignment=TextAlignment.Right));
connect(HP_active.y, HP_nSet_Controller.HP_On) annotation (Line(points={{32.5,
        91},{70,91},{70,78},{79,78}}, color={255,0,255}));
connect(heatingCurve.TSet, switch1.u3) annotation (Line(points={{-188.9,29},{
        -48,29},{-48,73},{9,73}},     color={0,0,127}));
connect(add_dT_Loading.y, HP_nSet_Controller.T_Set) annotation (Line(points={
        {50.5,73},{72,73},{72,86.4},{79,86.4}}, color={0,0,127}));
connect(const_dT_loading.y, add_dT_Loading.u2)
  annotation (Line(points={{30.2,70},{39,70}},   color={0,0,127}));
connect(switch1.y, add_dT_Loading.u1) annotation (Line(points={{20.5,77},{38,
        77},{38,76},{39,76}},   color={0,0,127}));
connect(TSet_DHW.TSet_DHW, DHWOnOffController.T_Set) annotation (Line(points={{-190.8,
        78},{-120,78},{-120,77.2}},         color={0,0,127}));
connect(TSet_DHW.TSet_DHW, switch1.u1) annotation (Line(points={{-190.8,78},{
        -48,78},{-48,81},{9,81}},     color={0,0,127}));
connect(sigBusDistr, TSet_DHW.sigBusDistr) annotation (Line(
    points={{1,-101},{-2,-101},{-2,-152},{-292,-152},{-292,77.88},{-216,77.88}},
    color={255,204,51},
    thickness=0.5), Text(
    string="%first",
    index=-1,
    extent={{-6,3},{-6,3}},
    horizontalAlignment=TextAlignment.Right));

connect(DHWOnOffController.Auxilliar_Heater_On, HRactive.u[1]) annotation (
    Line(points={{-110.88,82},{-22,82},{-22,27.3333},{10,27.3333}}, color={
        255,0,255}));
connect(BufferOnOffController.Auxilliar_Heater_On, HRactive.u[2]) annotation (
   Line(points={{-110.88,37.5},{-94,37.5},{-94,25},{10,25}},           color=
        {255,0,255}));
connect(TSet_DHW.y, HRactive.u[3]) annotation (Line(points={{-190.8,71.04},{-96,
          71.04},{-96,22.6667},{10,22.6667}},                           color=
       {255,0,255}));
connect(securityControl.sigBusHP, sigBusGen.hp_bus) annotation (Line(
    points={{192,69.27},{178,69.27},{178,70},{174,70},{174,-136},{-111.87,-136},
        {-111.87,-102.765}},
    color={255,204,51},
    thickness=0.5), Text(
    string="%second",
    index=1,
    extent={{-6,3},{-6,3}},
    horizontalAlignment=TextAlignment.Right));
connect(securityControl.modeSet, hp_mode.y) annotation (Line(points={{191.867,
          77.6},{168,77.6},{168,69},{162.7,69}},
                                               color={255,0,255}));
connect(hp_iceFac.y, sigBusGen.hp_bus.iceFacMea) annotation (Line(
      points={{-173.3,-85},{-156.65,-85},{-156.65,-102.765},{-111.87,-102.765}},
                    color={0,0,127}), Text(
    string="%second",
    index=1,
    extent={{6,3},{6,3}},
    horizontalAlignment=TextAlignment.Left));
connect(HP_nSet_Controller.n_Set, securityControl.nSet) annotation (Line(
      points={{113.5,78},{144,78},{144,84.4},{191.867,84.4}}, color={0,0,127}));
connect(DHWOnOffController.HP_On, HP_active.u1) annotation (Line(points={{-110.88,
        91.6},{-32,91.6},{-32,91},{21,91}},    color={255,0,255}));
connect(DHWHysOrLegionella.y, sigBusDistr.dhw_on) annotation (Line(
      points={{-71.25,69},{-26,69},{-26,-100.785},{1.145,-100.785}},
      color={255,0,255}), Text(
    string="%second",
    index=1,
    extent={{6,3},{6,3}},
    horizontalAlignment=TextAlignment.Left));
connect(DHWHysOrLegionella.y, switch1.u2) annotation (Line(points={{-71.25,69},
        {-20,69},{-20,77},{9,77}},              color={255,0,255}));
  connect(heatingCurve.TOda, inputScenBus.weaBus.TDryBul) annotation (Line(
        points={{-214.2,29},{-235.89,29},{-235.89,-0.885}}, color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));

connect(realPassThrough_T_Amb1.y, sigBusGen.hp_bus.TOdaMea) annotation (Line(
      points={{-218.9,-91},{-200,-91},{-200,-102.765},{-111.87,-102.765}},
      color={0,0,127}), Text(
    string="%second",
    index=1,
    extent={{6,3},{6,3}},
    horizontalAlignment=TextAlignment.Left));
  connect(realPassThrough_T_Amb1.u, inputScenBus.weaBus.TDryBul) annotation (
      Line(points={{-244.2,-91},{-256,-91},{-256,-0.885},{-235.89,-0.885}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
connect(TSet_DHW.y, DHWHysOrLegionella.u[1]) annotation (Line(points={{-190.8,
        71.04},{-96,71.04},{-96,71.625},{-82,71.625}},      color={255,0,255}));
connect(DHWOnOffController.Auxilliar_Heater_On, DHWHysOrLegionella.u[2])
  annotation (Line(points={{-110.88,82},{-92,82},{-92,69.875},{-82,69.875}},
                                                                      color={
        255,0,255}));
connect(DHWOnOffController.HP_On, DHWHysOrLegionella.u[3]) annotation (Line(
      points={{-110.88,91.6},{-90,91.6},{-90,68.125},{-82,68.125}},
      color={255,0,255}));
connect(BufferOnOffController.Auxilliar_Heater_On, BufOn.u2) annotation (Line(
      points={{-110.88,37.5},{-78,37.5},{-78,37},{-73,37}},    color={255,0,
        255}));
connect(BufferOnOffController.HP_On, BufOn.u1) annotation (Line(points={{-110.88,
        45.9},{-106,45.9},{-106,41},{-73,41}},          color={255,0,255}));
connect(BufOn.y, sigBusDistr.buffer_on) annotation (Line(points={{-61.5,41},{-30,
          41},{-30,-100.785},{1.145,-100.785}},      color={255,0,255}), Text(
    string="%second",
    index=1,
    extent={{6,3},{6,3}},
    horizontalAlignment=TextAlignment.Left));
  connect(realPassThrough_T_Amb2.u, inputScenBus.TSoil) annotation (Line(points=
         {{-244.2,-121},{-262,-121},{-262,-0.885},{-235.89,-0.885}}, color={0,0,
          127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
connect(realPassThrough_T_Amb2.y, sigBusGen.TSoil) annotation (Line(points={{-218.9,
        -121},{-128,-121},{-128,-102.765},{-111.87,-102.765}},
                                                           color={0,0,127}),
    Text(
    string="%second",
    index=1,
    extent={{6,3},{6,3}},
    horizontalAlignment=TextAlignment.Left));
connect(or3.y, sigBusGen.hr_on) annotation (Line(points={{42.6,26},{48,26},{48,
        -62},{-111.87,-62},{-111.87,-102.765}},
                                            color={0,0,127}), Text(
    string="%second",
    index=1,
    extent={{-6,3},{-6,3}},
    horizontalAlignment=TextAlignment.Right));
connect(or3.u, HRactive.y) annotation (Line(points={{28.8,26},{20.75,26},{
        20.75,25}},              color={255,0,255}));
connect(TSet_DHW.y, DHWHysOrLegionella.u[4]) annotation (Line(points={{-190.8,
        71.04},{-136.4,71.04},{-136.4,66.375},{-82,66.375}}, color={255,0,255}));
connect(realPassThrough_T_Amb1.y, DHWOnOffController.T_oda) annotation (Line(
      points={{-218.9,-91},{-218.9,-62},{-250,-62},{-250,92},{-120,92},{-120,
        94.96}}, color={0,0,127}));
connect(realPassThrough_T_Amb1.y, BufferOnOffController.T_oda) annotation (
    Line(points={{-218.9,-91},{-218.9,-64},{-252,-64},{-252,48.84},{-120,
        48.84}}, color={0,0,127}));
connect(BufferOnOffController.HP_On, AmbCoolEnough.u1) annotation (Line(
      points={{-110.88,45.9},{-86.44,45.9},{-86.44,3},{-61,3}}, color={255,0,255}));
connect(AmbCoolEnough.y, HP_active.u2) annotation (Line(points={{-49.5,3},{-49.5,
        44.5},{21,44.5},{21,87}}, color={255,0,255}));
connect(lessThreshold.y, AmbCoolEnough.u2) annotation (Line(points={{-93.4,0},
        {-78,0},{-78,-1},{-61,-1}}, color={255,0,255}));
connect(rectifiedMean.y, lessThreshold.u) annotation (Line(points={{-169,-4},{
        -120,-4},{-120,0},{-107.2,0}}, color={0,0,127}));
  connect(inputScenBus.weaBus.TDryBul, rectifiedMean.u) annotation (Line(
      points={{-235.89,-0.885},{-196,-0.885},{-196,-4},{-192,-4}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
connect(controlHPCoolBuffer.HPn_Set, switchHeatingCooling.u1) annotation (
    Line(points={{-117.4,-51.2},{-86.7,-51.2},{-86.7,-37.6},{-49.6,-37.6}},
      color={0,0,127}));
connect(securityControl.nOut, switchHeatingCooling.u3) annotation (Line(
      points={{227.333,84.4},{224,84.4},{224,-56},{-72,-56},{-72,-50.4},{-49.6,
          -50.4}},
                 color={0,0,127}));
connect(switchHeatingCooling.y, sigBusGen.hp_bus.nSet) annotation (Line(
      points={{-31.2,-44},{-16,-44},{-16,-102},{-72,-102},{-72,-102.765},{-111.87,
        -102.765}}, color={0,0,127}), Text(
    string="%second",
    index=1,
    extent={{-6,3},{-6,3}},
    horizontalAlignment=TextAlignment.Right));
connect(controlHPCoolBuffer.HPOn_Cooling, HPMode.u2) annotation (Line(points={
        {-116.8,-26.8},{-88,-26.8},{-88,-82},{8,-82}}, color={255,0,255}));
connect(HPMode.u1, HPInCoolingMode.y) annotation (Line(points={{8,-74},{2,-74},
        {2,-72},{-3,-72}}, color={255,0,255}));
connect(securityControl.modeOut, HPMode.u3) annotation (Line(points={{227.333,
          77.6},{227.333,-12},{228,-12},{228,-100},{4,-100},{4,-90},{8,-90}},
      color={255,0,255}));
connect(HPMode.y, sigBusGen.hp_bus.modeSet) annotation (Line(points={{31,-82},
        {38,-82},{38,-102.765},{-111.87,-102.765}}, color={255,0,255}), Text(
    string="%second",
    index=1,
    extent={{6,3},{6,3}},
    horizontalAlignment=TextAlignment.Left));
connect(sigBusDistr, controlHPCoolBuffer.sigBusDistr) annotation (Line(
    points={{1,-101},{-130,-101},{-130,-62.2},{-130.9,-62.2}},
    color={255,204,51},
    thickness=0.5), Text(
    string="%first",
    index=-1,
    extent={{6,3},{6,3}},
    horizontalAlignment=TextAlignment.Left));
connect(controlHPCoolBuffer.HPOn_Cooling, noDHWAndCooling.u2) annotation (
    Line(points={{-116.8,-26.8},{-100.4,-26.8},{-100.4,-28},{-82,-28}}, color=
       {255,0,255}));
connect(notDHW.y, noDHWAndCooling.u1) annotation (Line(points={{-109.4,-12},{-103.7,
        -12},{-103.7,-20},{-82,-20}}, color={255,0,255}));
connect(DHWOnOffController.HP_On, notDHW.u) annotation (Line(points={{-110.88,91.6},
        {-110.88,38.8},{-123.2,38.8},{-123.2,-12}}, color={255,0,255}));
connect(noDHWAndCooling.y, switchHeatingCooling.u2) annotation (Line(points={{
        -59,-20},{-54,-20},{-54,-44},{-49.6,-44}}, color={255,0,255}));
connect(sigBusGen, controlHPCoolBuffer.sigBusGen) annotation (Line(
    points={{-112,-103},{-138,-103},{-138,-62.4},{-165.4,-62.4}},
    color={255,204,51},
    thickness=0.5), Text(
    string="%first",
    index=-1,
    extent={{6,3},{6,3}},
    horizontalAlignment=TextAlignment.Left));
connect(sigBusGen.weaBus.TDryBul, controlHPCoolBuffer.TDryBul) annotation (
    Line(
    points={{-111.87,-102.765},{-214,-102.765},{-214,-41.6},{-179.8,-41.6}},
    color={255,204,51},
    thickness=0.5), Text(
    string="%first",
    index=-1,
    extent={{-6,3},{-6,3}},
    horizontalAlignment=TextAlignment.Right));
connect(sigBusDistr.T_StoDHW_bot, DHWOnOffController.T_bot) annotation (Line(
    points={{1.145,-100.785},{-7.5,-100.785},{-7.5,82},{-128.8,82}},
    color={255,204,51},
    thickness=0.5));
  connect(inputScenBus.weaBus.TDryBul, transferOnOff.TAmb) annotation (Line(
      points={{-235.89,-0.885},{-238,-0.885},{-238,-102},{-8,-102},{-8,-25},{
          40.38,-25}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
connect(TRoom, transferOnOff.TRoom) annotation (Line(points={{-34,102},{2,102},
        {2,-17.46},{40.38,-17.46}}, color={0,0,127}));

  connect(transferOnOff.ActiveTransfer, traControlBus.transfer_active)
    annotation (Line(points={{97.08,-23.44},{109.135,-23.44},{109.135,-100.785}},
        color={255,0,255}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(inputScenBus.ts_T_inside_max, transferOnOff.TSet_max) annotation (
      Line(
      points={{-235.89,-0.885},{-224,-0.885},{-224,0},{-208,0},{-208,-110},{-20,
          -110},{-20,-13.3},{40.38,-13.3}},
      color={255,204,51},
      thickness=0.5));
  connect(inputScenBus.ts_T_inside_min, transferOnOff.TSet_min) annotation (
      Line(
      points={{-235.89,-0.885},{-228,-0.885},{-228,-2},{-206,-2},{-206,-112},{
          -22,-112},{-22,-36.44},{42,-36.44}},
      color={255,204,51},
      thickness=0.5));
annotation (Diagram(graphics={
      Rectangle(
        extent={{-240,100},{-50,60}},
        lineColor={238,46,47},
        lineThickness=1),
      Text(
        extent={{-238,96},{-170,120}},
        lineColor={238,46,47},
        lineThickness=1,
        textString="DHW Control"),
      Rectangle(
        extent={{-240,58},{-50,14}},
        lineColor={0,140,72},
        lineThickness=1),
      Text(
        extent={{-176,14},{-126,30}},
        lineColor={0,140,72},
        lineThickness=1,
        textString="Buffer Control"),
      Rectangle(
        extent={{0,100},{132,52}},
        lineColor={28,108,200},
        lineThickness=1),
      Text(
        extent={{4,122},{108,102}},
        lineColor={28,108,200},
        lineThickness=1,
        textString="Heat Pump Control"),
      Rectangle(
        extent={{0,46},{132,4}},
        lineColor={162,29,33},
        lineThickness=1),
      Text(
        extent={{60,16},{126,2}},
        lineColor={162,29,33},
        lineThickness=1,
        textString="Heating Rod Control"),
      Rectangle(
        extent={{138,100},{240,52}},
        lineColor={28,108,200},
        lineThickness=1),
      Text(
        extent={{138,122},{242,102}},
        lineColor={28,108,200},
        lineThickness=1,
        textString="Heat Pump Safety"),
      Rectangle(
        extent={{0,-4},{132,-46}},
        lineColor={244,125,35},
        lineThickness=1),
      Text(
        extent={{70,-36},{130,-44}},
        lineColor={244,125,35},
        lineThickness=1,
        textString="Artificial Pump")}));
end PartialTwoPoint_HPS_Controller_Laura;
