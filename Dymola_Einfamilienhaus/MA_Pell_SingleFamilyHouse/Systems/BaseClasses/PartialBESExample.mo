within MA_Pell_SingleFamilyHouse.Systems.BaseClasses;
partial model PartialBESExample "Partial example model"
  extends Modelica.Icons.Example;

    replaceable parameter
    RecordsCollection.ExampleSystemParameters systemParameters
    "Parameters relevant for the whole energy system" annotation (
      choicesAllMatching=true, Placement(transformation(extent={{76,-96},{96,-76}})));
end PartialBESExample;
