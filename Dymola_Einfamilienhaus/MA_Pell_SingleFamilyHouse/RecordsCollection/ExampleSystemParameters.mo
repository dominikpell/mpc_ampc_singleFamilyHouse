within MA_Pell_SingleFamilyHouse.RecordsCollection;
record ExampleSystemParameters
  extends SystemParametersBaseDataDefinition(
    mGen_flow_nominal=0.21,
    mVent_flow_nominal=1,
    dpVent_nominal=1000,
    TOda_nominal=285.15,
    oneZoneParam=AixLib.DataBase.ThermalZones.OfficePassiveHouse.OPH_1_Office());
end ExampleSystemParameters;
