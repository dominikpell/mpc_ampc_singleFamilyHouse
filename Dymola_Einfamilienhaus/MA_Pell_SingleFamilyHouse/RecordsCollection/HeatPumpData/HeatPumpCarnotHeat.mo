within MA_Pell_SingleFamilyHouse.RecordsCollection.HeatPumpData;
record HeatPumpCarnotHeat
  "Reversible heat pump in heating mode using carnot efficiency and quality grade"
  //parameter Modelica.SIunits.Power dotQ_hp_max_heat = 7000 "Maximum heat capacity of hp in heating mode";
  //parameter Modelica.SIunits.TemperatureDifference dT_con = 8 "Temperature difference over condenser";
  //parameter Modelica.SIunits.TemperatureDifference dT_eva = 3 "Temperature difference over evaporator";
  //parameter Real quality_grade = 0.3 "Efficiency loss of heat pump compared to Carnot efficiency";
  //parameter Real COP_nominal = quality_grade * 4.89 "Nominal COP to calculate mass flow in evaporator";
  //parameter Real tableCOPCarnot[:,:]= [0,-20,-4,12;
    //            25,6.63,10.28,22.93;
      //          35,5.6,7.9,13.4;
        //        45,4.89,6.49,9.64];
  extends AixLib.DataBase.HeatPump.HeatPumpBaseDataDefinition(
    tableP_ele=[0,-20,-4,12,26,38;
                25,3522,2270,1017,-78,-1017;
                35,4165,2953,1742,681,-227;
                45,4767,3594,2420,1393,513;
                55,5333,4195,3058, 2062,1209],
    tableQdot_con=[0,-20,-4,12,26,38;
                25,7000,7000,7000,7000,7000;
                35,7000,7000,7000,7000,7000;
                45,7000,7000,7000,7000,7000;
                55,7000,7000,7000,7000,7000],
    mFlow_conNom=7000/4180/8,
    mFlow_evaNom=7000*(1-(1/1.467))/4180/3,
    tableUppBou=[-25, 45; 25, 55]);

  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end HeatPumpCarnotHeat;
