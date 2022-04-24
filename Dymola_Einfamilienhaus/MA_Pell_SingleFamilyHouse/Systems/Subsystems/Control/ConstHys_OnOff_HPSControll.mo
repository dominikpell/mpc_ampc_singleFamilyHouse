within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control;
model ConstHys_OnOff_HPSControll
  "Constant Hysteresis for an on/off HP"
  extends BaseClasses.PartialTwoPoint_HPS_Controller(
    redeclare
      Components.Control.HeatPumpNSetController.OnOffHeatPumpController
      HP_nSet_Controller(n_opt=systemParameters.nOptHP),
    redeclare
      Components.Control.OnOffController.ConstantHysteresis
      BufferOnOffController(Hysteresis=systemParameters.dT_hys, dt_hr=
          systemParameters.dt_hr),
    redeclare
      Components.Control.OnOffController.ConstantHysteresis
      DHWOnOffContoller(Hysteresis=systemParameters.dT_hys, dt_hr=
          systemParameters.dt_hr));

equation

  connect(sigBusGen.hp_bus.TConInMea, HP_nSet_Controller.T_Meas) annotation (
      Line(
      points={{-112,-103},{-114,-103},{-114,0},{97,0},{97,61.2}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
end ConstHys_OnOff_HPSControll;
