within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control;
model ConstHys_P_ConRet_HPSController
  "Using const. hys + P Inverter + Flow Temperature as controller"
  extends BaseClasses.PartialTwoPoint_HPS_Controller(
    redeclare
      Components.Control.HeatPumpNSetController.P_InverterHeatPumpController
      HP_nSet_Controller(P=systemParameters.P_hp, nMin=systemParameters.ratioQHPMin),
    redeclare
      Components.Control.OnOffController.ConstantHysteresis
      BufferOnOffController,
    redeclare
      Components.Control.OnOffController.ConstantHysteresis
      DHWOnOffContoller(Hysteresis=systemParameters.dT_hys, dt_hr=
          systemParameters.dt_hr),
    const_dT_loading(k=systemParameters.dT_loading + 5));

equation
  connect(HP_nSet_Controller.T_Meas, sigBusGen.hp_bus.TConOutMea)
    annotation (Line(points={{97,61.2},{97,-103},{-112,-103}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
end ConstHys_P_ConRet_HPSController;
