within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control;
model Biv_PI_ConFlow_HPSController_Laura
  "Using alt_bivalent + PI Inverter + Return Temperature as controller"
  extends BaseClasses.PartialTwoPoint_HPS_Controller_Laura(
    redeclare
      Components.Control.SecurityControls.ConstTSet_DHW TSet_DHW(T_DHW=
          systemParameters.TSetDHW),
    redeclare
      Components.Control.HeatPumpNSetController.PI_InverterHeatPumpController
      HP_nSet_Controller(
      P=systemParameters.P_hp,
      nMin=systemParameters.ratioQHPMin,
      T_I=systemParameters.T_I),
    redeclare
      Components.Control.OnOffController.BivalentParallelOnOffController
      BufferOnOffController(final T_biv=systemParameters.T_bivNom, hysteresis=
          systemParameters.dT_hys),
    redeclare
      Components.Control.OnOffController.BivalentParallelOnOffController
      DHWOnOffController(final T_biv=systemParameters.T_bivNom, hysteresis=
          systemParameters.dT_hys),
    const_dT_loading(k=systemParameters.dT_loading));

    Components.Control.HeatPumpNSetController.PI_InverterHeatPumpController ValveTESController(
    P=1,
    nMin=0.1,
    T_I=100,
    Ni=0.2)                   annotation (choicesAllMatching=true, Placement(
        transformation(extent={{66,-110},{48,-90}})));
equation
  connect(sigBusGen.hp_bus.TConOutMea, HP_nSet_Controller.T_Meas) annotation (
      Line(
      points={{-111.87,-102.765},{-111.87,-54},{97,-54},{97,61.2}},
      color={255,204,51},
      thickness=0.5));
  connect(ValveTESController.n_Set, sigBusDistr.y_TES_Valve) annotation (Line(
        points={{47.1,-100},{24,-100},{24,-100.785},{1.145,-100.785}}, color={0,
          0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(ValveTESController.HP_On, transferOnOff.ActiveTransfer[1])
    annotation (Line(points={{67.8,-100},{97.08,-100},{97.08,-23.44}}, color={
          255,0,255}));
  connect(TRoom[1], ValveTESController.T_Meas) annotation (Line(points={{-34,
          102},{-34,-120},{57,-120},{57,-112}}, color={0,0,127}));
  connect(ValveTESController.T_Set, inputScenBus.ts_T_inside_max) annotation (
      Line(points={{67.8,-94},{80,-94},{80,-124},{-212,-124},{-212,-0.885},{
          -235.89,-0.885}}, color={0,0,127}));
  connect(controlHPCoolBuffer.HPOn_Cooling, sigBusDistr.TES_cooled) annotation (
     Line(points={{-116.8,-26.8},{-116.8,-38},{-90,-38},{-90,-100.785},{1.145,
          -100.785}}, color={255,0,255}));
  connect(traControlBus.SupplyGreaterReturn, sigBusDistr.SupplyGreaterReturn)
    annotation (Line(
      points={{109.135,-100.785},{90,-100.785},{90,-116},{18,-116},{18,-100.785},
          {1.145,-100.785}},
      color={255,204,51},
      thickness=0.5));
  connect(inputScenBus.ts_T_inside_max, heatingCurve.T_Room_Set) annotation (
      Line(
      points={{-235.89,-0.885},{-235.89,36.7},{-214.2,36.7}},
      color={255,204,51},
      thickness=0.5));
end Biv_PI_ConFlow_HPSController_Laura;
