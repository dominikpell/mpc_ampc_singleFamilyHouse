within MA_Pell_SingleFamilyHouse.Systems.Examples;
record SimpleStudyOfHeatingRodEfficiency
  extends
    RecordsCollection.ParameterAssumptionsBaseDefinition;

  parameter Real efficiceny_heating_rod = 1;
  parameter Real hr_nominal_power = 10000;

end SimpleStudyOfHeatingRodEfficiency;
