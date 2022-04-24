within MA_Pell_SingleFamilyHouse.RecordsCollection.HeatPumpData;
record HeatPumpCarnotCool
  "Reversible heat pump in cooling mode using carnot efficiency and quality grade"
  //parameter Modelica.SIunits.Power dotQ_hp_max_cool = 7000 "Maximum heat capacity of hp in cooling mode (evaporator side)";
  //parameter Modelica.SIunits.TemperatureDifference dT_con = 3 "Temperature difference over condenser";
  //parameter Modelica.SIunits.TemperatureDifference dT_eva = 8 "Temperature difference over evaporator";
  //parameter Real quality_grade = 0.3 "Efficiency loss of heat pump compared to Carnot efficiency";
  //parameter Real COP_nominal = quality_grade * 4.89 "Nominal COP to calculate mass flow in evaporator";
  //parameter Real tableCOPCarnot[:,:]= [0,27,36,45;
    //            15,24.01,13.72,9.61;
      //          20,41.88,18.32,11.73;
        //        25,149.08,27.1,14.91];

  extends AixLib.DataBase.Chiller.ChillerBaseDataDefinition(
    tableP_ele=[0,27,36,45;
                15,972,1701,2429;
                20,557,1274,1990;
                25,157,861,1565],
    tableQdot_eva=[0,27,36,45;
                15,7000,7000,7000;
                20,7000,7000,7000;
                25,7000,7000,7000],
    mFlow_conNom=7000/(1-1/4.89)/4180/3,
    mFlow_evaNom=7000/4180/8,
    tableUppBou=[20, 35; 15, 30]);
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end HeatPumpCarnotCool;
