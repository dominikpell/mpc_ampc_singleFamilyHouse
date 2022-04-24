within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control;
model Controller_MPC_noTES
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
  Modelica.Blocks.Logical.GreaterThreshold isChargedDHW(threshold=1)
    annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=270,
        origin={26,-58})));
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
  Modelica.Blocks.Logical.Not not1
    annotation (Placement(transformation(extent={{48,-74},{60,-62}})));
  Modelica.Blocks.Logical.And and1
    annotation (Placement(transformation(extent={{80,-46},{100,-26}})));
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
  connect(switchStorageSignal.y, HP_nSet_Controller.T_Set) annotation (Line(
        points={{-79,-54},{-94,-54},{-94,-22},{-161,-22},{-161,-35.6}}, color={
          0,0,127}));
  connect(switchStorageFeedback.y, HP_nSet_Controller.T_Meas) annotation (Line(
        points={{-79,-82},{-144,-82},{-144,-60.8},{-143,-60.8}}, color={0,0,127}));
  connect(switchStorageSignal.u1, inputScenBus.t_DHW) annotation (Line(points={{
          -56,-46},{-22,-46},{-22,-1},{-236,-1}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(isChargedDHW.y, switchStorageSignal.u2) annotation (Line(points={{26,-64.6},
          {26,-68},{-10,-68},{-10,-54},{-56,-54}}, color={255,0,255}));
  connect(isChargedDHW.y, not1.u) annotation (Line(points={{26,-64.6},{26,-68},{
          46.8,-68}}, color={255,0,255}));
  connect(not1.y, and1.u2) annotation (Line(points={{60.6,-68},{72,-68},{72,-44},
          {78,-44}}, color={255,0,255}));
  connect(isOn.y, and1.u1) annotation (Line(points={{-195.4,-48},{-172,-48},{-172,
          -10},{64,-10},{64,-36},{78,-36}}, color={255,0,255}));
  connect(and1.y, traControlBus.transfer_active[1]) annotation (Line(points={{101,
          -36},{104,-36},{104,-100.785},{109.135,-100.785}}, color={255,0,255}),
      Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(switchStorageFeedback.u1, sigBusDistr.T_mean_DHW) annotation (Line(
        points={{-56,-74},{-28,-74},{-28,-100.785},{1.145,-100.785}}, color={0,0,
          127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(switchStorageFeedback.u2, switchStorageSignal.u2) annotation (Line(
        points={{-56,-82},{-10,-82},{-10,-54},{-56,-54}}, color={255,0,255}));
  connect(switchStorageFeedback.u3, traControlBus.T_supply_UFH_Mea) annotation (
     Line(points={{-56,-90},{20,-90},{20,-88},{109.135,-88},{109.135,-100.785}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(switchStorageSignal.u3, inputScenBus.T_supply_UFH) annotation (Line(
        points={{-56,-62},{-30,-62},{-30,-0.885},{-235.89,-0.885}}, color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  annotation (Diagram(coordinateSystem(extent={{-240,-100},{240,100}})),
                                            Icon(coordinateSystem(extent={{-240,
            -100},{240,100}})));
end Controller_MPC_noTES;
