within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Control;
model Biv_PI_ConFlow_HPSController
  "Using alt_bivalent + PI Inverter + Return Temperature as controller"
  extends BaseClasses.PartialTwoPoint_HPS_Controller(
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
      Components.Control.OnOffController.AlternativeBivalentOnOffController
      BufferOnOffController(final T_biv=systemParameters.T_bivNom, hysteresis=
          systemParameters.dT_hys),
    redeclare
      Components.Control.OnOffController.AlternativeBivalentOnOffController
      DHWOnOffContoller(final T_biv=systemParameters.T_bivNom, hysteresis=
          systemParameters.dT_hys),
    const_dT_loading(k=systemParameters.dT_loading));

equation
  connect(sigBusGen.hp_bus.TConOutMea, HP_nSet_Controller.T_Meas) annotation (
      Line(
      points={{-111.87,-102.765},{-111.87,-54},{97,-54},{97,61.2}},
      color={255,204,51},
      thickness=0.5));
end Biv_PI_ConFlow_HPSController;
