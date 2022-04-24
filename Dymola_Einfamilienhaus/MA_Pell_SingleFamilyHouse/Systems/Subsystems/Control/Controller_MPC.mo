within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control;
model Controller_MPC
  "Using alt_bivalent + PI Inverter + Return Temperature as controller"
  extends
    MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control.BaseClasses.PartialControl;

  parameter Real hr_nom_power;
  Modelica.Blocks.Sources.Constant hp_iceFac(final k=1) annotation (Placement(
        transformation(
        extent={{-7,-7},{7,7}},
        rotation=0,
        origin={-205,-83})));
  Modelica.Blocks.Routing.RealPassThrough realPassThrough_T_Amb1
    "Only used to make warning disappear, has no effect on model veloccity"
    annotation (Placement(transformation(extent={{-266,-100},{-244,-78}})));
  Modelica.Blocks.Routing.RealPassThrough realPassThrough_T_Amb2
    "Only used to make warning disappear, has no effect on model veloccity"
    annotation (Placement(transformation(extent={{-266,-130},{-244,-108}})));
  Modelica.Blocks.Logical.GreaterThreshold isHeatLoad(threshold=1) annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={-12,-22})));
  Modelica.Blocks.Logical.GreaterThreshold isChargedDHW(threshold=1)
    annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={26,-58})));
  Modelica.Blocks.Logical.Or isChargedBuf annotation (Placement(transformation(
        extent={{-5,-5},{5,5}},
        rotation=270,
        origin={1,-45})));
  Modelica.Blocks.Logical.LessThreshold isCoolLoaf(threshold=-1) annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={12,-22})));
    Components.Control.HeatPumpNSetController.PI_InverterHeatPumpController
    HP_nSet_Controller(
    P=systemParameters.P_hp,
    nMin=systemParameters.ratioQHPMin,
    T_I=systemParameters.T_I)
                       annotation (choicesAllMatching=true, Placement(
        transformation(extent={{-158,-58},{-128,-30}})));
  Modelica.Blocks.Logical.GreaterThreshold isOn(threshold=0.01)  annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={-202,-48})));
  Modelica.Blocks.Logical.GreaterThreshold is_dch_TES(threshold=1) annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={132,-18})));
  Modelica.Blocks.Logical.Or is_dch_Buf annotation (Placement(transformation(
        extent={{-5,-5},{5,5}},
        rotation=270,
        origin={145,-45})));
  Modelica.Blocks.Logical.LessThreshold is_dch_TES2(threshold=-1)
                                                                 annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={156,-18})));
Modelica.Blocks.Logical.Switch switchStorageSignal annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-68,-54})));
Modelica.Blocks.Logical.Switch switchStorageFeedback annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-68,-82})));
    Components.Control.HeatPumpNSetController.PI_InverterHeatPumpController ValveTESController(
    P=systemParameters.P_hp,
    nMin=0.01,
    T_I=systemParameters.T_I) annotation (choicesAllMatching=true, Placement(
        transformation(extent={{66,-44},{48,-24}})));
equation

  connect(inputScenBus.weaBus, sigBusGen.weaBus) annotation (
    Line(
      points={{-235.89,-0.885},{-262,-0.885},{-262,-102.765},{-111.87,-102.765}},
      color={255,204,51},
      thickness=0.5),
    Text(
      string="%first",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right),
    Text(
      string="%second",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));

  connect(hp_iceFac.y, sigBusGen.hp_bus.iceFacMea) annotation (Line(
        points={{-197.3,-83},{-180.65,-83},{-180.65,-102.765},{-111.87,-102.765}},
                      color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(realPassThrough_T_Amb1.y, sigBusGen.hp_bus.TOdaMea) annotation (Line(
        points={{-242.9,-89},{-224,-89},{-224,-102.765},{-111.87,-102.765}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(realPassThrough_T_Amb1.u, inputScenBus.weaBus.TDryBul) annotation (
      Line(points={{-268.2,-89},{-280,-89},{-280,-0.885},{-235.89,-0.885}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(realPassThrough_T_Amb2.u, inputScenBus.TSoil) annotation (Line(points=
         {{-268.2,-119},{-286,-119},{-286,-0.885},{-235.89,-0.885}}, color={0,0,
          127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(realPassThrough_T_Amb2.y, sigBusGen.TSoil) annotation (Line(points={{-242.9,
          -119},{-152,-119},{-152,-102.765},{-111.87,-102.765}},
                                                             color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(inputScenBus.mode_HP, sigBusGen.hp_bus.modeSet) annotation (Line(
      points={{-235.89,-0.885},{-180,-0.885},{-180,-14},{-112,-14},{-112,-66},{
          -111.87,-66},{-111.87,-102.765}},
      color={255,204,51},
      thickness=0.5));
  connect(inputScenBus.hr_rel, sigBusGen.hr_on) annotation (
    Line(
      points={{-235.89,-0.885},{-196,-0.885},{-196,0},{-112,0},{-112,-102.765},
          {-111.87,-102.765}},
      color={255,204,51},
      thickness=0.5),
    Text(
      string="%first",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left),
    Text(
      string="%second",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(isHeatLoad.y, isChargedBuf.u2) annotation (Line(points={{-12,-28.6},{
          -12,-38},{-3,-38},{-3,-39}},color={255,0,255}));
  connect(isCoolLoaf.y, isChargedBuf.u1) annotation (Line(points={{12,-28.6},{
          12,-36},{1,-36},{1,-39}},   color={255,0,255}));
  connect(isChargedBuf.y, sigBusDistr.buffer_on) annotation (Line(points={{1,-50.5},
          {1,-70.25},{1.145,-70.25},{1.145,-100.785}},             color={255,0,
          255}), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(inputScenBus.ch_TES, isHeatLoad.u) annotation (Line(
      points={{-235.89,-0.885},{-12,-0.885},{-12,-14.8}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(inputScenBus.ch_TES, isCoolLoaf.u) annotation (Line(
      points={{-235.89,-0.885},{12,-0.885},{12,-14.8}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(inputScenBus.ch_DHW, isChargedDHW.u) annotation (Line(
      points={{-235.89,-0.885},{26,-0.885},{26,-50.8}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(isChargedDHW.y, sigBusDistr.dhw_on) annotation (Line(points={{26,
          -64.6},{26,-100.785},{1.145,-100.785}},    color={255,0,255}), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));

  connect(isOn.y, HP_nSet_Controller.HP_On) annotation (Line(points={{-195.4,
          -48},{-172,-48},{-172,-44},{-161,-44}},
                                             color={255,0,255}));
  connect(is_dch_TES.y, is_dch_Buf.u2) annotation (Line(points={{132,-24.6},{
          132,-34},{141,-34},{141,-39}}, color={255,0,255}));
  connect(is_dch_TES2.y, is_dch_Buf.u1) annotation (Line(points={{156,-24.6},{
          156,-32},{145,-32},{145,-39}}, color={255,0,255}));
  connect(inputScenBus.dch_TES, is_dch_TES.u) annotation (Line(
      points={{-236,-1},{132,-1},{132,-10.8}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(inputScenBus.dch_TES, is_dch_TES2.u) annotation (Line(
      points={{-236,-1},{-236,0},{156,0},{156,-10.8}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(isChargedBuf.y, switchStorageSignal.u2) annotation (Line(points={{1,-50.5},
          {1,-54},{-56,-54}},         color={255,0,255}));
  connect(inputScenBus.t_TES, switchStorageSignal.u1) annotation (Line(
      points={{-236,-1},{-36,-1},{-36,-46},{-56,-46}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(inputScenBus.t_DHW, switchStorageSignal.u3) annotation (Line(
      points={{-236,-1},{-36,-1},{-36,-62},{-56,-62}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(switchStorageFeedback.u2, isChargedBuf.y) annotation (Line(points={{-56,-82},
          {1,-82},{1,-50.5}},            color={255,0,255}));
  connect(is_dch_Buf.y, traControlBus.transfer_active[1]) annotation (Line(
        points={{145,-50.5},{145,-75.25},{109.135,-75.25},{109.135,-100.785}},
        color={255,0,255}), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(switchStorageFeedback.u3, sigBusDistr.T_mean_DHW) annotation (Line(
        points={{-56,-90},{-28,-90},{-28,-100.785},{1.145,-100.785}}, color={0,
          0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(switchStorageFeedback.u1, sigBusDistr.T_mean_Buf) annotation (Line(
        points={{-56,-74},{-28,-74},{-28,-100.785},{1.145,-100.785}}, color={0,
          0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));

  connect(HP_nSet_Controller.n_Set, sigBusGen.hp_bus.nSet) annotation (Line(
        points={{-126.5,-44},{-111.87,-44},{-111.87,-102.765}}, color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(inputScenBus.HP_on, isOn.u) annotation (Line(
      points={{-235.89,-0.885},{-232,-0.885},{-232,-48},{-209.2,-48}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(ValveTESController.T_Set, inputScenBus.T_supply_UFH) annotation (Line(
        points={{67.8,-28},{72,-28},{72,-30},{76,-30},{76,-0.885},{-235.89,-0.885}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(ValveTESController.T_Meas, traControlBus.T_supply_UFH_Mea)
    annotation (Line(points={{57,-46},{57,-100.785},{109.135,-100.785}}, color=
          {0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(is_dch_Buf.y, ValveTESController.HP_On) annotation (Line(points={{145,
          -50.5},{145,-62},{104,-62},{104,-34},{67.8,-34}}, color={255,0,255}));
  connect(ValveTESController.n_Set, sigBusDistr.y_TES_Valve) annotation (Line(
        points={{47.1,-34},{38,-34},{38,-100.785},{1.145,-100.785}}, color={0,0,
          127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(sigBusDistr.SupplyGreaterReturn, traControlBus.SupplyGreaterReturn)
    annotation (
    Line(
      points={{1.145,-100.785},{55.5,-100.785},{55.5,-100.785},{109.135,
          -100.785}},
      color={255,204,51},
      thickness=0.5),
    Text(
      string="%first",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left),
    Text(
      string="%second",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(isCoolLoaf.y, sigBusDistr.TES_cooled) annotation (Line(points={{12,
          -28.6},{12,-100.785},{1.145,-100.785}}, color={255,0,255}));
  connect(switchStorageSignal.y, HP_nSet_Controller.T_Set) annotation (Line(
        points={{-79,-54},{-94,-54},{-94,-22},{-161,-22},{-161,-35.6}}, color={
          0,0,127}));
  connect(switchStorageFeedback.y, HP_nSet_Controller.T_Meas) annotation (Line(
        points={{-79,-82},{-144,-82},{-144,-60.8},{-143,-60.8}}, color={0,0,127}));
  annotation (Diagram(coordinateSystem(extent={{-240,-100},{240,100}})),
                                            Icon(coordinateSystem(extent={{-240,
            -100},{240,100}})));
end Controller_MPC;
