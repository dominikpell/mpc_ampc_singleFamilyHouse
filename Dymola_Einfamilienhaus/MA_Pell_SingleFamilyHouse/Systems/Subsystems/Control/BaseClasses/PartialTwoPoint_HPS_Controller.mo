within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control.BaseClasses;
partial model PartialTwoPoint_HPS_Controller
  "Partial model with replaceable blocks for rule based control of HPS using on off heating rods"
  extends
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control.BaseClasses.PartialControl;

  replaceable
    Components.Control.OnOffController.BaseClasses.PartialOnOffController
    DHWOnOffContoller annotation (choicesAllMatching=true, Placement(
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
equation
  connect(BufferOnOffController.T_Top, sigBusDistr.T_StoBuf_top) annotation (
      Line(points={{-128.8,45.9},{-316,45.9},{-316,-166},{4,-166},{4,-100.785},
          {115.145,-100.785}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(DHWOnOffContoller.T_Top, sigBusDistr.T_StoDHW_top) annotation (Line(
        points={{-128.8,91.6},{-316,91.6},{-316,-166},{115.145,-166},{115.145,
          -100.785}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(heatingCurve.TSet, BufferOnOffController.T_Set) annotation (Line(
        points={{-188.9,29},{-120,29},{-120,33.3}}, color={0,0,127}));

  connect(BufferOnOffController.T_bot, sigBusDistr.T_StoBuf_bot) annotation (
      Line(points={{-128.8,37.5},{-318,37.5},{-318,-166},{2,-166},{2,-100.785},
          {115.145,-100.785}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(DHWOnOffContoller.T_bot, sigBusDistr.T_StoDHW_bot) annotation (Line(
        points={{-128.8,82},{-318,82},{-318,-166},{115.145,-166},{115.145,
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
  connect(TSet_DHW.TSet_DHW, DHWOnOffContoller.T_Set) annotation (Line(points={{-190.8,
          78},{-120,78},{-120,77.2}},         color={0,0,127}));
  connect(TSet_DHW.TSet_DHW, switch1.u1) annotation (Line(points={{-190.8,78},{
          -146,78},{-146,74},{-102,74},{-102,81},{9,81}},
                                        color={0,0,127}));
  connect(sigBusDistr, TSet_DHW.sigBusDistr) annotation (Line(
      points={{115,-101},{-2,-101},{-2,-152},{-292,-152},{-292,77.88},{-216,
          77.88}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));

  connect(DHWOnOffContoller.Auxilliar_Heater_On, HRactive.u[1]) annotation (
      Line(points={{-110.88,82},{-22,82},{-22,27.3333},{10,27.3333}}, color={
          255,0,255}));
  connect(BufferOnOffController.Auxilliar_Heater_On, HRactive.u[2]) annotation (
     Line(points={{-110.88,37.5},{-94,37.5},{-94,25},{10,25}},           color=
          {255,0,255}));
  connect(TSet_DHW.y, HRactive.u[3]) annotation (Line(points={{-190.8,71.04},{
          -96,71.04},{-96,22.6667},{10,22.6667}},                         color=
         {255,0,255}));
  connect(securityControl.sigBusHP, sigBusGen.hp_bus) annotation (Line(
      points={{192,69.27},{180,69.27},{180,70},{176,70},{176,-136},{-111.87,-136},
          {-111.87,-102.765}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(securityControl.modeOut, sigBusGen.hp_bus.modeSet)
    annotation (Line(points={{227.333,77.6},{268,77.6},{268,-136},{-111.87,-136},
          {-111.87,-102.765}},               color={255,0,255}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(securityControl.modeSet, hp_mode.y) annotation (Line(points={{191.867,
          77.6},{168,77.6},{168,69},{162.7,69}}, color={255,0,255}));
  connect(securityControl.nOut, sigBusGen.hp_bus.nSet) annotation (Line(
        points={{227.333,84.4},{264,84.4},{264,-132},{-42,-132},{-42,-102.765},
          {-111.87,-102.765}},           color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(hp_iceFac.y, sigBusGen.hp_bus.iceFacMea) annotation (Line(
        points={{-173.3,-85},{-156.65,-85},{-156.65,-102.765},{-111.87,-102.765}},
                      color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(HP_nSet_Controller.n_Set, securityControl.nSet) annotation (Line(
        points={{113.5,78},{144,78},{144,84.4},{191.867,84.4}}, color={0,0,127}));
  connect(BufferOnOffController.HP_On, HP_active.u2) annotation (Line(points={{-110.88,
          45.9},{-78,45.9},{-78,54},{-38,54},{-38,87},{21,87}},
                                                 color={255,0,255}));
  connect(DHWOnOffContoller.HP_On, HP_active.u1) annotation (Line(points={{-110.88,
          91.6},{-32,91.6},{-32,91},{21,91}},    color={255,0,255}));
  connect(DHWHysOrLegionella.y, sigBusDistr.dhw_on) annotation (Line(
        points={{-71.25,69},{-26,69},{-26,-100.785},{115.145,-100.785}},
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
  connect(DHWOnOffContoller.Auxilliar_Heater_On, DHWHysOrLegionella.u[2])
    annotation (Line(points={{-110.88,82},{-92,82},{-92,69.875},{-82,69.875}},
                                                                        color={
          255,0,255}));
  connect(DHWOnOffContoller.HP_On, DHWHysOrLegionella.u[3]) annotation (Line(
        points={{-110.88,91.6},{-90,91.6},{-90,68.125},{-82,68.125}},
        color={255,0,255}));
  connect(BufferOnOffController.Auxilliar_Heater_On, BufOn.u2) annotation (Line(
        points={{-110.88,37.5},{-78,37.5},{-78,37},{-73,37}},    color={255,0,
          255}));
  connect(BufferOnOffController.HP_On, BufOn.u1) annotation (Line(points={{-110.88,
          45.9},{-106,45.9},{-106,41},{-73,41}},          color={255,0,255}));
  connect(BufOn.y, sigBusDistr.buffer_on) annotation (Line(points={{-61.5,41},{
          -30,41},{-30,-100.785},{115.145,-100.785}},  color={255,0,255}), Text(
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
  connect(realPassThrough_T_Amb1.y, DHWOnOffContoller.T_oda) annotation (Line(
        points={{-218.9,-91},{-218.9,-62},{-250,-62},{-250,92},{-120,92},{-120,
          94.96}}, color={0,0,127}));
  connect(realPassThrough_T_Amb1.y, BufferOnOffController.T_oda) annotation (
      Line(points={{-218.9,-91},{-218.9,-64},{-252,-64},{-252,48.84},{-120,
          48.84}}, color={0,0,127}));
  annotation (Diagram(graphics={
        Rectangle(
          extent={{-240,100},{-50,60}},
          lineColor={238,46,47},
          lineThickness=1),
        Text(
          extent={{-234,94},{-140,128}},
          lineColor={238,46,47},
          lineThickness=1,
          textString="DHW Control"),
        Rectangle(
          extent={{-240,58},{-50,14}},
          lineColor={0,140,72},
          lineThickness=1),
        Text(
          extent={{-216,-16},{-122,18}},
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
          extent={{2,4},{106,-16}},
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
          textString="Heat Pump Safety")}));
end PartialTwoPoint_HPS_Controller;
