within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control;
model ConstHys_PI_StoTop_HPSController_Laura
  "Using const. hys + PI Inverter + top level storage as controller"
  extends BaseClasses.PartialTwoPoint_HPS_Controller(
    redeclare
      Components.Control.HeatPumpNSetController.PI_InverterHeatPumpController
      HP_nSet_Controller(
      P=systemParameters.P_hp,
      nMin=systemParameters.ratioQHPMin,
      T_I=systemParameters.T_I),
    redeclare
      Components.Control.OnOffController.ConstantHysteresis
      BufferOnOffController(Hysteresis=systemParameters.dT_hys, dt_hr=
          systemParameters.dt_hr),
    redeclare
      Components.Control.OnOffController.ConstantHysteresis
      DHWOnOffContoller(Hysteresis=systemParameters.dT_hys, dt_hr=
          systemParameters.dt_hr),
    const_dT_loading(k=systemParameters.dT_hys/2));

  Modelica.Blocks.Logical.Switch switch2 "on: DHW, off: Buffer"
    annotation (Placement(transformation(extent={{-5,-5},{5,5}},
        rotation=90,
        origin={5,17})));
equation
  connect(sigBusDistr.T_StoBuf_top, switchHeatingCooling.u3) annotation (Line(
      points={{115.145,-100.785},{-32,-100.785},{-32,6},{9,6},{9,11}},
      color={255,204,51},
      thickness=0.5));
  connect(sigBusDistr.T_StoDHW_top, switchHeatingCooling.u1) annotation (Line(
      points={{115.145,-100.785},{-30,-100.785},{-30,2},{1,2},{1,11}},
      color={255,204,51},
      thickness=0.5));
  connect(switchHeatingCooling.y, HP_nSet_Controller.T_Meas) annotation (Line(
        points={{5,22.5},{5,28},{97,28},{97,61.2}}, color={0,0,127}));
  connect(DHWHysOrLegionella.y, switchHeatingCooling.u2) annotation (Line(
        points={{-71.25,69},{-12,69},{-12,4},{4,4},{4,8},{5,8},{5,11}}, color={
          255,0,255}));
  annotation (experiment(StopTime=31536000, Interval=500));
end ConstHys_PI_StoTop_HPSController_Laura;
