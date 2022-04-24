within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control;
model ConstHys_PI_ConFlow_HPSController
  "Using const. hys + PI Inverter + Return Temperature as controller"
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
    const_dT_loading(k=systemParameters.dT_loading));

equation
  connect(HP_nSet_Controller.T_Meas, sigBusGen.hp_bus.TConInMea)
    annotation (Line(points={{97,61.2},{8,61.2},{8,-56},{-112,-56},{-112,-103}},
                              color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
end ConstHys_PI_ConFlow_HPSController;
