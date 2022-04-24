within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Ventilation;
model NoVentilation "Model without any ventilation"
  extends BaseClasses.PartialVentilationSystem(redeclare
      RecordsCollection.VentilationData.DummyVentilation parameters,
    final use_vent=false);
end NoVentilation;
