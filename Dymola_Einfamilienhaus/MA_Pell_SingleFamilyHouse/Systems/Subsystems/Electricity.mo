within MA_Pell_SingleFamilyHouse.Systems.Subsystems;
package Electricity "Subsystem for electricity supply"
  package BaseClasses
    partial model PartialElectricity

      AixLib.BoundaryConditions.WeatherData.Bus waeBus annotation (
          Placement(transformation(extent={{-120,60},{-80,100}}),
            iconTransformation(extent={{-120,60},{-80,100}})));
      Interfaces.Outputs.ElectricityOutputs outBusElec annotation (Placement(
            transformation(extent={{80,-20},{120,20}}), iconTransformation(
              extent={{80,-20},{120,20}})));
      parameter RecordsCollection.SystemParametersBaseDataDefinition systemParameters
        "Parameters relevant for the whole energy system"
        annotation (Placement(transformation(extent={{80,-100},{100,-80}})));
    end PartialElectricity;
  end BaseClasses;

  model Electricity_PVandBAT_MPC
    parameter Modelica.SIunits.Time timZon(displayUnit="h")=timZon
        "Time zone. Should be equal with timZon in ReaderTMY3, if PVSystem and ReaderTMY3 are used together.";
    parameter Real SOC_Bat_Init;
      parameter Integer n_mod=3 "Number of connected PV modules";
    parameter AixLib.DataBase.SolarElectric.PVBaseDataDefinition data = AixLib.DataBase.SolarElectric.ShellSP70()
      "PV Panel data definition";
    parameter ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral
      batteryData=ElectricalStorages.Data.LithiumIon.LithiumIonViessmann()
      "Characteristic data of the battery";
    parameter Integer nBat=3 "Number of batteries";
    parameter Real til = 15*2*3.14/360 annotation(Evaluate=false);
    parameter Real azi1 = 90*(2*3.14)/(360) annotation(Evaluate=false);
    parameter Real azi2 = -90*(2*3.14)/(360) annotation(Evaluate=false);
    parameter Real lat = 52.519*2*3.14/360 annotation(Evaluate=false);
    parameter Real lon = 13.408*2*3.14/360 annotation(Evaluate=false);

    Electrical.PVSystem.PVSystem_ref pVSystemEast(
      data=data,
      redeclare model IVCharacteristics =
          Electrical.PVSystem.BaseClasses.IVCharacteristics5pAnalytical,
      redeclare model CellTemperature =
          Electrical.PVSystem.BaseClasses.CellTemperatureMountingCloseToGround,
      n_mod=n_mod,
      til(displayUnit="deg") = til,
      azi=azi2,
      lat=lat,
      lon=lon,
      alt=15,
      timZon=timZon)
      annotation (Placement(transformation(extent={{-80,64},{-64,80}})));

    ElectricalStorages.BatterySimple Battery(
      batteryData=batteryData,
      nBat=nBat,
      SOC_start=SOC_Bat_Init)
      annotation (Placement(transformation(extent={{-28.5,29.5},{28.5,-29.5}},
          rotation=90,
          origin={259.5,-127.5})));
    Electrical.PVSystem.PVSystem_ref
                                 pVSystemWest(
      data=data,
      redeclare model IVCharacteristics =
          Electrical.PVSystem.BaseClasses.IVCharacteristics5pAnalytical,
      redeclare model CellTemperature =
          Electrical.PVSystem.BaseClasses.CellTemperatureMountingCloseToGround,
      n_mod=n_mod,
      til=til,
      azi=azi1,
      lat=lat,
      lon=lon,
      alt=15,
      timZon=timZon)
      annotation (Placement(transformation(extent={{-80,84},{-64,100}})));

    Modelica.Blocks.Math.Add tot_powerPV
      annotation (Placement(transformation(extent={{-56,76},{-44,88}})));
    Modelica.Blocks.Math.Product PV_ch_BAT
      annotation (Placement(transformation(extent={{-38,24},{-26,36}})));
    Modelica.Blocks.Math.Product use
      annotation (Placement(transformation(extent={{-38,56},{-26,68}})));
    Modelica.Blocks.Math.Product FeedIn
      annotation (Placement(transformation(extent={{-38,40},{-26,52}})));
    Modelica.Blocks.Math.Add calcLoad
      annotation (Placement(transformation(extent={{150,-44},{162,-32}})));
    Modelica.Blocks.Math.Add chBATfromGrid(k1=-1)
      annotation (Placement(transformation(extent={{290,-8},{304,6}})));
    Modelica.Blocks.Math.Add totFeedIn
      annotation (Placement(transformation(extent={{284,32},{298,46}})));
    Modelica.Blocks.Math.Add totSelfUse
      annotation (Placement(transformation(extent={{292,-106},{306,-92}})));
    Modelica.Blocks.Math.Add res_elec annotation (Placement(transformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={301,-171})));
    Modelica.Blocks.Math.Add remain_dem(k1=-1)
      annotation (Placement(transformation(extent={{318,-112},{334,-96}})));
    Modelica.Blocks.Math.Add chBATfromGrid2(k2=-1)
      annotation (Placement(transformation(extent={{316,-16},{326,-6}})));
    Modelica.Blocks.Interfaces.RealInput PV_Distr_Use annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,58}),  iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-1})));
    Modelica.Blocks.Interfaces.RealInput PV_Distr_ChBat annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,26}),  iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-29})));
    Modelica.Blocks.Interfaces.RealInput PV_Distr_FeedIn annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,42}),  iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-15})));
    Modelica.Blocks.Interfaces.RealInput Pow_BAT_Use annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,-34}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-59})));
    Modelica.Blocks.Interfaces.RealInput Pow_BAT_ChBat annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-98,-86}),  iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-95,-83})));
    Modelica.Blocks.Interfaces.RealInput Pow_BAT_FeedIn annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-98,-70}),  iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-95,-67})));
    AixLib.BoundaryConditions.WeatherData.Bus
        weaBus "Weather data bus" annotation (Placement(transformation(extent={{-110,74},
              {-90,94}}),          iconTransformation(extent={{-110,74},{-90,94}})));
    Interfaces.Outputs.ElectricityOutputs outBusElec
      annotation (Placement(transformation(extent={{330,-86},{350,-66}})));
    Modelica.Blocks.Interfaces.RealInput P_el_Gen annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={286,-254}),
                            iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=90,
          origin={1,-93})));
    Modelica.Blocks.Interfaces.RealInput P_el_dom annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={304,-254}),iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=90,
          origin={23,-93})));
    Modelica.Blocks.Math.Division division
      annotation (Placement(transformation(extent={{-4,78},{6,68}})));
    Modelica.Blocks.Nonlinear.Limiter limiter(uMax=1, uMin=0)
      annotation (Placement(transformation(extent={{16,68},{26,78}})));
    Modelica.Blocks.Math.Feedback feedback
      annotation (Placement(transformation(extent={{66,52},{86,72}})));
    Modelica.Blocks.Math.Product product1
      annotation (Placement(transformation(extent={{46,66},{58,78}})));
    Modelica.Blocks.Math.Add add
      annotation (Placement(transformation(extent={{98,42},{106,50}})));
    Modelica.Blocks.Math.Division division1
      annotation (Placement(transformation(extent={{-60,-32},{-50,-42}})));
    Modelica.Blocks.Nonlinear.Limiter limiter1(uMax=1, uMin=0)
      annotation (Placement(transformation(extent={{-34,-42},{-24,-32}})));
    Modelica.Blocks.Math.Feedback feedback1
      annotation (Placement(transformation(extent={{-10,-64},{-2,-56}})));
    Modelica.Blocks.Math.Product product2
      annotation (Placement(transformation(extent={{30,-50},{42,-38}})));
    Modelica.Blocks.Math.Feedback feedback2
      annotation (Placement(transformation(extent={{-22,-80},{-14,-72}})));
    Modelica.Blocks.Math.Add add1
      annotation (Placement(transformation(extent={{94,-54},{102,-46}})));
    Modelica.Blocks.Math.Division division2
      annotation (Placement(transformation(extent={{154,24},{164,14}})));
    Modelica.Blocks.Nonlinear.Limiter limiter2(uMax=1, uMin=0)
      annotation (Placement(transformation(extent={{176,16},{186,26}})));
    Modelica.Blocks.Math.Product product3
      annotation (Placement(transformation(extent={{200,12},{212,24}})));
    Modelica.Blocks.Math.Feedback feedback3
      annotation (Placement(transformation(extent={{228,-2},{248,18}})));
    Modelica.Blocks.Math.Add add2
      annotation (Placement(transformation(extent={{224,34},{232,42}})));
    Modelica.Blocks.Logical.LessThreshold isZero(threshold=Modelica.Constants.eps)
      annotation (Placement(transformation(extent={{-66,114},{-56,124}})));
    Modelica.Blocks.Logical.Switch noPVdummy "Switch for PV covers building load"
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-34,120})));
    Modelica.Blocks.Sources.RealExpression AlmostZeroFlow(y=Modelica.Constants.eps)
      annotation (Placement(transformation(extent={{-88,118},{-68,138}})));
    Modelica.Blocks.Logical.LessThreshold isZero1(threshold=Modelica.Constants.eps)
      annotation (Placement(transformation(extent={{174,-18},{178,-14}})));
    Modelica.Blocks.Logical.Switch noPVdummy1
                                             "Switch for PV covers building load"
      annotation (Placement(transformation(
          extent={{-5,-5},{5,5}},
          rotation=0,
          origin={191,-17})));
    Modelica.Blocks.Sources.RealExpression AlmostZeroFlow1(y=Modelica.Constants.eps)
      annotation (Placement(transformation(extent={{156,-16},{166,-10}})));
    Modelica.Blocks.Logical.LessThreshold isZero2(threshold=Modelica.Constants.eps)
      annotation (Placement(transformation(extent={{-78,-20},{-74,-16}})));
    Modelica.Blocks.Logical.Switch noPVdummy2
                                             "Switch for PV covers building load"
      annotation (Placement(transformation(
          extent={{-5,-5},{5,5}},
          rotation=0,
          origin={-61,-19})));
    Modelica.Blocks.Sources.RealExpression AlmostZeroFlow2(y=Modelica.Constants.eps)
      annotation (Placement(transformation(extent={{-96,-18},{-86,-12}})));
    Modelica.Blocks.Logical.LessThreshold isZero3(threshold=Modelica.Constants.eps)
      annotation (Placement(transformation(extent={{400,-12},{404,-8}})));
    Modelica.Blocks.Logical.Switch noPVdummy3
                                             "Switch for PV covers building load"
      annotation (Placement(transformation(
          extent={{-5,-5},{5,5}},
          rotation=0,
          origin={417,-11})));
    Modelica.Blocks.Sources.RealExpression AlmostZeroFlow3(y=0)
      annotation (Placement(transformation(extent={{382,-10},{392,-4}})));
    Modelica.Blocks.Logical.LessThreshold isZero5(threshold=Modelica.Constants.eps)
      annotation (Placement(transformation(extent={{400,-28},{404,-24}})));
    Modelica.Blocks.Logical.Switch noPVdummy4
                                             "Switch for PV covers building load"
      annotation (Placement(transformation(
          extent={{-5,-5},{5,5}},
          rotation=0,
          origin={417,-27})));
    Modelica.Blocks.Sources.RealExpression AlmostZeroFlow4(y=0)
      annotation (Placement(transformation(extent={{382,-34},{392,-28}})));
    Modelica.Blocks.Math.Add totFeedIn1(k2=-1)
      annotation (Placement(transformation(extent={{352,22},{366,36}})));
    Modelica.Blocks.Logical.GreaterThreshold
                                          isZero4(threshold=Modelica.Constants.eps)
      annotation (Placement(transformation(extent={{310,-58},{314,-54}})));
    Modelica.Blocks.Logical.Switch noPVdummy5
                                             "Switch for PV covers building load"
      annotation (Placement(transformation(
          extent={{-5,-5},{5,5}},
          rotation=0,
          origin={327,-57})));
    Modelica.Blocks.Sources.RealExpression AlmostZeroFlow5(y=0)
      annotation (Placement(transformation(extent={{292,-64},{302,-58}})));
    Modelica.Blocks.Math.Add totBatFeedIn2
      annotation (Placement(transformation(extent={{224,-66},{238,-52}})));
    Modelica.Blocks.Math.Add totFeedIn2(k2=-1)
      annotation (Placement(transformation(extent={{304,-42},{318,-28}})));
  equation

    connect(pVSystemWest.DCOutputPower,tot_powerPV. u1) annotation (Line(points={{-63.2,
            92},{-60,92},{-60,86},{-56,86},{-56,85.6},{-57.2,85.6}},
                                                   color={0,0,127}));
    connect(pVSystemEast.DCOutputPower,tot_powerPV. u2) annotation (Line(points={{-63.2,
            72},{-60,72},{-60,78},{-58,78},{-58,78.4},{-57.2,78.4}},
                                                   color={0,0,127}));
    connect(weaBus,pVSystemWest. waeBus) annotation (Line(
        points={{-100,84},{-88,84},{-88,92},{-80,92}},
        color={255,204,51},
        thickness=0.5));
    connect(weaBus,pVSystemEast. waeBus) annotation (Line(
        points={{-100,84},{-88,84},{-88,72},{-80,72}},
        color={255,204,51},
        thickness=0.5));
    connect(Pow_BAT_Use,calcLoad. u1) annotation (Line(points={{-100,-34},{88,-34},
            {88,-34.4},{148.8,-34.4}},       color={0,0,127}));
    connect(Pow_BAT_FeedIn,calcLoad. u2) annotation (Line(points={{-98,-70},{144,-70},
            {144,-41.6},{148.8,-41.6}},          color={0,0,127}));
    connect(tot_powerPV.y,outBusElec. power_PV) annotation (Line(points={{-43.4,
            82},{340,82},{340,-76}},                    color={0,0,127}));
    connect(Battery.SOC,outBusElec. soc_BAT) annotation (Line(points={{275.43,
            -127.5},{322,-127.5},{322,-128},{340.05,-128},{340.05,-75.95}},
                                                 color={0,0,127}));
    connect(PV_Distr_Use, use.u2) annotation (Line(points={{-100,58},{-76,58},{
            -76,58.4},{-39.2,58.4}}, color={0,0,127}));
    connect(PV_Distr_FeedIn, FeedIn.u2) annotation (Line(points={{-100,42},{-70,
            42},{-70,42.4},{-39.2,42.4}}, color={0,0,127}));
    connect(PV_Distr_ChBat, PV_ch_BAT.u2) annotation (Line(points={{-100,26},{
            -70,26},{-70,26.4},{-39.2,26.4}}, color={0,0,127}));
    connect(tot_powerPV.y, use.u1) annotation (Line(points={{-43.4,82},{-42,82},
            {-42,65.6},{-39.2,65.6}}, color={0,0,127}));
    connect(FeedIn.u1, use.u1) annotation (Line(points={{-39.2,49.6},{-42,49.6},
            {-42,65.6},{-39.2,65.6}}, color={0,0,127}));
    connect(PV_ch_BAT.u1, use.u1) annotation (Line(points={{-39.2,33.6},{-42,
            33.6},{-42,65.6},{-39.2,65.6}}, color={0,0,127}));
    connect(calcLoad.y, Battery.PLoad) annotation (Line(points={{162.6,-38},{259.5,
            -38},{259.5,-113.25}},                              color={0,0,127}));
    connect(PV_ch_BAT.y, chBATfromGrid.u1) annotation (Line(points={{-25.4,30},{-14,
            30},{-14,4},{110,4},{110,3.2},{288.6,3.2}},      color={0,0,127}));
    connect(Pow_BAT_ChBat, chBATfromGrid.u2) annotation (Line(points={{-98,-86},{-76,
            -86},{-76,-5.2},{288.6,-5.2}},               color={0,0,127}));
    connect(P_el_dom, res_elec.u2) annotation (Line(points={{304,-254},{304,-242},
            {292.6,-242},{292.6,-175.2}},
                                        color={0,0,127}));
    connect(P_el_Gen, res_elec.u1) annotation (Line(points={{286,-254},{286,-166.8},
            {292.6,-166.8}},        color={0,0,127}));
    connect(res_elec.y, outBusElec.res_elec) annotation (Line(points={{308.7,-171},
            {340.05,-171},{340.05,-75.95}},       color={0,0,127}));
    connect(totSelfUse.y, remain_dem.u1) annotation (Line(points={{306.7,-99},{
            306,-99},{306,-100},{314,-100},{314,-99.2},{316.4,-99.2}},
                                                       color={0,0,127}));
    connect(res_elec.y, remain_dem.u2) annotation (Line(points={{308.7,-171},{
            312,-171},{312,-108.8},{316.4,-108.8}},
                                              color={0,0,127}));
    connect(remain_dem.y, outBusElec.power_from_grid) annotation (Line(points={{334.8,
            -104},{340.05,-104},{340.05,-75.95}},       color={0,0,127}));
    connect(chBATfromGrid.y, chBATfromGrid2.u1) annotation (Line(points={{304.7,-1},
            {312,-1},{312,0},{310,0},{310,-8},{315,-8}},
                                           color={0,0,127}));
    connect(Battery.PGrid, chBATfromGrid2.u2) annotation (Line(points={{271.3,-112.11},
            {272,-112.11},{272,-14},{315,-14}},
          color={0,0,127}));
    connect(Pow_BAT_Use, outBusElec.power_use_BAT) annotation (Line(points={{-100,
            -34},{-154,-34},{-154,-202},{340.05,-202},{340.05,-75.95}},
          color={0,0,127}));
    connect(res_elec.y, division.u1) annotation (Line(points={{308.7,-171},{308.7,
            -170},{374,-170},{374,130},{-10,130},{-10,70},{-5,70}}, color={0,0,
            127}));
    connect(division.y, limiter.u)
      annotation (Line(points={{6.5,73},{15,73}}, color={0,0,127}));
    connect(use.y, feedback.u1)
      annotation (Line(points={{-25.4,62},{68,62}}, color={0,0,127}));
    connect(use.y, product1.u2) annotation (Line(points={{-25.4,62},{34,62},{34,
            68},{40,68},{40,68.4},{44.8,68.4}}, color={0,0,127}));
    connect(limiter.y, product1.u1) annotation (Line(points={{26.5,73},{36,73},
            {36,76},{40,76},{40,75.6},{44.8,75.6}}, color={0,0,127}));
    connect(product1.y, feedback.u2) annotation (Line(points={{58.6,72},{62,72},
            {62,52},{76,52},{76,54}}, color={0,0,127}));
    connect(feedback.y, add.u1) annotation (Line(points={{85,62},{94,62},{94,48},
            {96,48},{96,48.4},{97.2,48.4}}, color={0,0,127}));
    connect(FeedIn.y, add.u2) annotation (Line(points={{-25.4,46},{-22,46},{-22,
            44},{-16,44},{-16,43.6},{97.2,43.6}}, color={0,0,127}));
    connect(add.y, totFeedIn.u1) annotation (Line(points={{106.4,46},{242,46},{242,
            43.2},{282.6,43.2}},   color={0,0,127}));
    connect(division1.y, limiter1.u) annotation (Line(points={{-49.5,-37},{-49.5,-36},
            {-35,-36},{-35,-37}},                  color={0,0,127}));
    connect(limiter1.y, product2.u1) annotation (Line(points={{-23.5,-37},{2,-37},
            {2,-40},{16,-40},{16,-40.4},{28.8,-40.4}}, color={0,0,127}));
    connect(product2.y, feedback1.u2) annotation (Line(points={{42.6,-44},{48,
            -44},{48,-64},{-6,-64},{-6,-63.2}},              color={0,0,127}));
    connect(add.y, outBusElec.power_to_grid_PV) annotation (Line(points={{106.4,
            46},{340.05,46},{340.05,-75.95}}, color={0,0,127}));
    connect(product1.y, feedback2.u2) annotation (Line(points={{58.6,72},{258,
            72},{258,-79.2},{-18,-79.2}},                 color={0,0,127}));
    connect(res_elec.y, feedback2.u1) annotation (Line(points={{308.7,-171},{
            374,-171},{374,-292},{-36,-292},{-36,-76},{-21.2,-76}},
                                                                  color={0,0,
            127}));
    connect(feedback2.y, division1.u1) annotation (Line(points={{-14.4,-76},{6,
            -76},{6,-54},{-70,-54},{-70,-40},{-61,-40}},                 color=
            {0,0,127}));
    connect(product2.u2, division1.u2) annotation (Line(points={{28.8,-47.6},{
            -74,-47.6},{-74,-34},{-61,-34}},
                                color={0,0,127}));
    connect(feedback1.u1, division1.u2) annotation (Line(points={{-9.2,-60},{
            -74,-60},{-74,-34},{-61,-34}},              color={0,0,127}));
    connect(feedback1.y, add1.u1) annotation (Line(points={{-2.4,-60},{88,-60},
            {88,-47.6},{93.2,-47.6}},                                  color={0,
            0,127}));
    connect(Pow_BAT_FeedIn, add1.u2) annotation (Line(points={{-98,-70},{58,-70},
            {58,-52.4},{93.2,-52.4}},           color={0,0,127}));
    connect(division2.y, limiter2.u) annotation (Line(points={{164.5,19},{
            169.25,19},{169.25,21},{175,21}}, color={0,0,127}));
    connect(limiter2.y, product3.u1) annotation (Line(points={{186.5,21},{
            192.25,21},{192.25,21.6},{198.8,21.6}}, color={0,0,127}));
    connect(product3.u2, division2.u1) annotation (Line(points={{198.8,14.4},{
            198,14.4},{198,8},{134,8},{134,16},{153,16}},   color={0,0,127}));
    connect(product3.y, feedback3.u2) annotation (Line(points={{212.6,18},{218,18},
            {218,0},{238,0}},           color={0,0,127}));
    connect(feedback3.y, add2.u2) annotation (Line(points={{247,8},{250,8},{250,
            32},{212,32},{212,36},{218,36},{218,35.6},{223.2,35.6}},
                                                                color={0,0,127}));
    connect(add2.y, totFeedIn.u2) annotation (Line(points={{232.4,38},{264,38},
            {264,36},{274,36},{274,34.8},{282.6,34.8}},
                                              color={0,0,127}));
    connect(AlmostZeroFlow.y,noPVdummy. u1)
      annotation (Line(points={{-67,128},{-46,128}},
                                                   color={0,0,127}));
    connect(isZero.y,noPVdummy. u2) annotation (Line(points={{-55.5,119},{-50,
            119},{-50,120},{-46,120}},
                                color={255,0,255}));
    connect(noPVdummy.y, division.u2) annotation (Line(points={{-23,120},{-20,
            120},{-20,76},{-5,76}}, color={0,0,127}));
    connect(isZero.u, use.y) annotation (Line(points={{-67,119},{-82,119},{-82,
            106},{-25.4,106},{-25.4,62}}, color={0,0,127}));
    connect(noPVdummy.u3, use.y) annotation (Line(points={{-46,112},{-46,106},{
            -25.4,106},{-25.4,62}}, color={0,0,127}));
    connect(PV_ch_BAT.y, division2.u1) annotation (Line(points={{-25.4,30},{134,
            30},{134,16},{153,16}}, color={0,0,127}));
    connect(PV_ch_BAT.y, feedback3.u1) annotation (Line(points={{-25.4,30},{134,
            30},{134,8},{230,8}}, color={0,0,127}));
    connect(AlmostZeroFlow1.y, noPVdummy1.u1)
      annotation (Line(points={{166.5,-13},{185,-13}}, color={0,0,127}));
    connect(isZero1.y, noPVdummy1.u2) annotation (Line(points={{178.2,-16},{180,
            -16},{180,-17},{185,-17}}, color={255,0,255}));
    connect(Pow_BAT_ChBat, noPVdummy1.u3) annotation (Line(points={{-98,-86},{
            -16,-86},{-16,-84},{138,-84},{138,-21},{185,-21}}, color={0,0,127}));
    connect(isZero1.u, noPVdummy1.u3) annotation (Line(points={{173.6,-16},{166,
            -16},{166,-21},{185,-21}}, color={0,0,127}));
    connect(noPVdummy1.y, division2.u2) annotation (Line(points={{196.5,-17},{
            204,-17},{204,-8},{142,-8},{142,22},{153,22}}, color={0,0,127}));
    connect(AlmostZeroFlow2.y, noPVdummy2.u1)
      annotation (Line(points={{-85.5,-15},{-67,-15}}, color={0,0,127}));
    connect(isZero2.y, noPVdummy2.u2) annotation (Line(points={{-73.8,-18},{-72,
            -18},{-72,-19},{-67,-19}}, color={255,0,255}));
    connect(isZero2.u, noPVdummy2.u3) annotation (Line(points={{-78.4,-18},{-86,
            -18},{-86,-23},{-67,-23}}, color={0,0,127}));
    connect(Pow_BAT_Use, noPVdummy2.u3) annotation (Line(points={{-100,-34},{
            -94,-34},{-94,-30},{-86,-30},{-86,-23},{-67,-23}}, color={0,0,127}));
    connect(noPVdummy2.y, division1.u2) annotation (Line(points={{-55.5,-19},{
            -48,-19},{-48,-30},{-61,-30},{-61,-34}}, color={0,0,127}));
    connect(add1.y, add2.u1) annotation (Line(points={{102.4,-50},{110,-50},{
            110,-46},{122,-46},{122,40.4},{223.2,40.4}}, color={0,0,127}));
    connect(product1.y, totSelfUse.u1) annotation (Line(points={{58.6,72},{62,
            72},{62,-94.8},{290.6,-94.8}}, color={0,0,127}));
    connect(product2.y, totSelfUse.u2) annotation (Line(points={{42.6,-44},{48,
            -44},{48,-64},{126,-64},{126,-103.2},{290.6,-103.2}}, color={0,0,
            127}));
    connect(AlmostZeroFlow3.y,noPVdummy3. u1)
      annotation (Line(points={{392.5,-7},{411,-7}},   color={0,0,127}));
    connect(isZero3.y,noPVdummy3. u2) annotation (Line(points={{404.2,-10},{406,-10},
            {406,-11},{411,-11}},      color={255,0,255}));
    connect(chBATfromGrid2.y, isZero3.u) annotation (Line(points={{326.5,-11},{363.25,
            -11},{363.25,-10},{399.6,-10}}, color={0,0,127}));
    connect(chBATfromGrid2.y, noPVdummy3.u3) annotation (Line(points={{326.5,-11},
            {350,-11},{350,-15},{411,-15}}, color={0,0,127}));
    connect(noPVdummy3.y, outBusElec.power_to_BAT_from_grid) annotation (Line(
          points={{422.5,-11},{430,-11},{430,-75.95},{340.05,-75.95}}, color={0,0,
            127}), Text(
        string="%second",
        index=1,
        extent={{6,3},{6,3}},
        horizontalAlignment=TextAlignment.Left));
    connect(Pow_BAT_ChBat, Battery.PCharge) annotation (Line(points={{-98,-86},
            {186,-86},{186,-158},{259.5,-158},{259.5,-141.75}}, color={0,0,127}));
    connect(Pow_BAT_ChBat, outBusElec.ch_BAT) annotation (Line(points={{-98,-86},
            {340.05,-86},{340.05,-75.95}}, color={0,0,127}));
    connect(product1.y, outBusElec.power_use_PV) annotation (Line(points={{58.6,
            72},{340.05,72},{340.05,-75.95}}, color={0,0,127}));
    connect(product3.y, outBusElec.power_to_BAT_PV) annotation (Line(points={{
            212.6,18},{340.05,18},{340.05,-75.95}}, color={0,0,127}));
    connect(noPVdummy4.u2, isZero5.y) annotation (Line(points={{411,-27},{404.2,
            -27},{404.2,-26}}, color={255,0,255}));
    connect(totFeedIn.y, totFeedIn1.u1) annotation (Line(points={{298.7,39},{
            350.6,39},{350.6,33.2}}, color={0,0,127}));
    connect(totFeedIn1.y, outBusElec.power_to_grid) annotation (Line(points={{
            366.7,29},{366.7,-20},{340.05,-20},{340.05,-75.95}}, color={0,0,127}));
    connect(chBATfromGrid2.y, isZero5.u) annotation (Line(points={{326.5,-11},{
            360,-11},{360,-26},{399.6,-26}}, color={0,0,127}));
    connect(AlmostZeroFlow4.y, noPVdummy4.u3) annotation (Line(points={{392.5,
            -31},{401.25,-31},{401.25,-31},{411,-31}}, color={0,0,127}));
    connect(noPVdummy4.u1, isZero5.u) annotation (Line(points={{411,-23},{368,
            -23},{368,-26},{399.6,-26}}, color={0,0,127}));
    connect(noPVdummy4.y, totFeedIn1.u2) annotation (Line(points={{422.5,-27},{
            486,-27},{486,14},{346,14},{346,24.8},{350.6,24.8}}, color={0,0,127}));
    connect(noPVdummy5.u2, isZero4.y) annotation (Line(points={{321,-57},{314.2,
            -57},{314.2,-56}}, color={255,0,255}));
    connect(AlmostZeroFlow5.y, noPVdummy5.u3)
      annotation (Line(points={{302.5,-61},{321,-61}}, color={0,0,127}));
    connect(noPVdummy5.u1, isZero4.u) annotation (Line(points={{321,-53},{278,
            -53},{278,-56},{309.6,-56}}, color={0,0,127}));
    connect(Battery.PGrid, isZero4.u) annotation (Line(points={{271.3,-112.11},
            {271.3,-56},{309.6,-56}}, color={0,0,127}));
    connect(Pow_BAT_FeedIn, totBatFeedIn2.u1) annotation (Line(points={{-98,-70},
            {176,-70},{176,-54.8},{222.6,-54.8}}, color={0,0,127}));
    connect(noPVdummy5.y, totBatFeedIn2.u2) annotation (Line(points={{332.5,-57},
            {336,-57},{336,-48},{244,-48},{244,-66},{218,-66},{218,-63.2},{
            222.6,-63.2}}, color={0,0,127}));
    connect(totBatFeedIn2.y, outBusElec.power_to_grid_BAT) annotation (Line(
          points={{238.7,-59},{246,-59},{246,-75.95},{340.05,-75.95}}, color={0,
            0,127}));
    connect(totFeedIn2.u1, calcLoad.y) annotation (Line(points={{302.6,-30.8},{
            162.6,-30.8},{162.6,-38}}, color={0,0,127}));
    connect(noPVdummy4.y, totFeedIn2.u2) annotation (Line(points={{422.5,-27},{
            422.5,-44},{290,-44},{290,-39.2},{302.6,-39.2}}, color={0,0,127}));
    connect(totFeedIn2.y, outBusElec.dch_BAT) annotation (Line(points={{318.7,
            -35},{340.05,-35},{340.05,-75.95}}, color={0,0,127}));
    annotation (Diagram(coordinateSystem(extent={{-100,-100},{340,100}})), Icon(
          coordinateSystem(extent={{-100,-100},{340,100}})));
  end Electricity_PVandBAT_MPC;

  model Electricity_PVandBAT_ref
    parameter Modelica.SIunits.Time timZon(displayUnit="h")=timZon
        "Time zone. Should be equal with timZon in ReaderTMY3, if PVSystem and ReaderTMY3 are used together.";
    parameter Real SOC_Bat_Init;
      parameter Integer n_mod=3 "Number of connected PV modules";
    parameter AixLib.DataBase.SolarElectric.PVBaseDataDefinition data = AixLib.DataBase.SolarElectric.ShellSP70()
      "PV Panel data definition";
    parameter ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral
      batteryData=ElectricalStorages.Data.LithiumIon.LithiumIonViessmann()
      "Characteristic data of the battery";
    parameter Integer nBat=3 "Number of batteries";
    parameter Real til = 15*2*3.14/360 annotation(Evaluate=false);
    parameter Real azi1 = 90*(2*3.14)/(360) annotation(Evaluate=false);
    parameter Real azi2 = -90*(2*3.14)/(360) annotation(Evaluate=false);
    parameter Real lat = 52.519*2*3.14/360 annotation(Evaluate=false);
    parameter Real lon = 13.408*2*3.14/360 annotation(Evaluate=false);
    Electrical.PVSystem.PVSystem_ref pVSystemEast(
      data=data,
      redeclare model IVCharacteristics =
          Electrical.PVSystem.BaseClasses.IVCharacteristics5pAnalytical,
      redeclare model CellTemperature =
          Electrical.PVSystem.BaseClasses.CellTemperatureMountingCloseToGround,
      n_mod=n_mod,
      til(displayUnit="deg") = til,
      azi=azi2,
      lat=lat,
      lon=lon,
      alt=15,
      timZon=timZon)
      annotation (Placement(transformation(extent={{-80,64},{-64,80}})));

    ElectricalStorages.BatterySimple Battery(
      batteryData=batteryData,
      nBat=nBat,
      SOC_start=SOC_Bat_Init)
      annotation (Placement(transformation(extent={{-28.5,29.5},{28.5,-29.5}},
          rotation=90,
          origin={-16.5,-69.5})));



    Electrical.PVSystem.PVSystem_ref
                                 pVSystemWest(
      data=data,
      redeclare model IVCharacteristics =
          Electrical.PVSystem.BaseClasses.IVCharacteristics5pAnalytical,
      redeclare model CellTemperature =
          Electrical.PVSystem.BaseClasses.CellTemperatureMountingCloseToGround,
      n_mod=n_mod,
      til=til,
      azi=azi1,
      lat=lat,
      lon=lon,
      alt=15,
      timZon=timZon)
      annotation (Placement(transformation(extent={{-80,84},{-64,100}})));

    Modelica.Blocks.Math.Add tot_powerPV
      annotation (Placement(transformation(extent={{-56,76},{-44,88}})));
    Modelica.Blocks.Interfaces.RealInput PV_Distr_Use annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,58}),  iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-1})));
    Modelica.Blocks.Interfaces.RealInput PV_Distr_ChBat annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,26}),  iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-29})));
    Modelica.Blocks.Interfaces.RealInput PV_Distr_FeedIn annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,42}),  iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-15})));
    Modelica.Blocks.Interfaces.RealInput Pow_BAT_Use annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,-56}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-59})));
    Modelica.Blocks.Interfaces.RealInput Pow_BAT_ChBat annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,-88}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-87})));
    Modelica.Blocks.Interfaces.RealInput Pow_BAT_FeedIn annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,-72}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-73})));
    Modelica.Blocks.Math.Product PV_ch_BAT
      annotation (Placement(transformation(extent={{-38,24},{-26,36}})));
    Modelica.Blocks.Math.Product use
      annotation (Placement(transformation(extent={{-38,56},{-26,68}})));
    Modelica.Blocks.Math.Product FeedIn
      annotation (Placement(transformation(extent={{-38,40},{-26,52}})));
    AixLib.BoundaryConditions.WeatherData.Bus
        weaBus "Weather data bus" annotation (Placement(transformation(extent={{-110,74},
              {-90,94}}),          iconTransformation(extent={{-110,74},{-90,94}})));
    Modelica.Blocks.Math.Add calcLoad
      annotation (Placement(transformation(extent={{-74,-70},{-62,-58}})));
    Interfaces.Outputs.ElectricityOutputs outBusElec
      annotation (Placement(transformation(extent={{90,-10},{110,10}})));
    Modelica.Blocks.Interfaces.RealInput P_el_Gen annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={18,-100}),iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=90,
          origin={1,-93})));
    Modelica.Blocks.Interfaces.RealInput P_el_dom annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={36,-100}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=90,
          origin={23,-93})));
    Modelica.Blocks.Math.Add chBATfromGrid(k1=-1)
      annotation (Placement(transformation(extent={{4,10},{18,24}})));
    Modelica.Blocks.Math.Add totFeedIn
      annotation (Placement(transformation(extent={{4,-10},{18,4}})));
    Modelica.Blocks.Math.Add totSelfUse
      annotation (Placement(transformation(extent={{4,-30},{18,-16}})));
    Modelica.Blocks.Math.Add res_elec annotation (Placement(transformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={55,-85})));
    Modelica.Blocks.Math.Add remain_dem(k1=-1)
      annotation (Placement(transformation(extent={{76,-34},{92,-18}})));
    Modelica.Blocks.Math.Add chBATfromGrid2(k2=-1)
      annotation (Placement(transformation(extent={{40,10},{50,20}})));
  equation



    connect(pVSystemWest.DCOutputPower, tot_powerPV.u1) annotation (Line(points={{-63.2,
            92},{-60,92},{-60,86},{-56,86},{-56,85.6},{-57.2,85.6}},
                                                   color={0,0,127}));
    connect(pVSystemEast.DCOutputPower, tot_powerPV.u2) annotation (Line(points={{-63.2,
            72},{-60,72},{-60,78},{-58,78},{-58,78.4},{-57.2,78.4}},
                                                   color={0,0,127}));
    connect(weaBus, pVSystemWest.waeBus) annotation (Line(
        points={{-100,84},{-88,84},{-88,92},{-80,92}},
        color={255,204,51},
        thickness=0.5));
    connect(weaBus, pVSystemEast.waeBus) annotation (Line(
        points={{-100,84},{-88,84},{-88,72},{-80,72}},
        color={255,204,51},
        thickness=0.5));
    connect(Pow_BAT_Use, calcLoad.u1) annotation (Line(points={{-100,-56},{-82,
            -56},{-82,-60},{-78,-60},{-78,-60.4},{-75.2,-60.4}},
                                             color={0,0,127}));
    connect(Pow_BAT_FeedIn, calcLoad.u2) annotation (Line(points={{-100,-72},{
            -82,-72},{-82,-67.6},{-75.2,-67.6}}, color={0,0,127}));
    connect(tot_powerPV.y, outBusElec.power_PV) annotation (Line(points={{-43.4,
            82},{100,82},{100,0}},                      color={0,0,127}));
    connect(Pow_BAT_ChBat, Battery.PCharge) annotation (Line(points={{-100,-88},
            {-80,-88},{-80,-94},{-16,-94},{-16,-83.75},{-16.5,-83.75}},
                                           color={0,0,127}));
    connect(use.y, outBusElec.power_use_PV) annotation (Line(points={{-25.4,62},
            {100.05,62},{100.05,0.05}}, color={0,0,127}));
    connect(FeedIn.y, outBusElec.power_to_grid_PV) annotation (Line(points={{-25.4,
            46},{100.05,46},{100.05,0.05}},      color={0,0,127}));
    connect(PV_ch_BAT.y, outBusElec.power_to_BAT_PV) annotation (Line(points={{-25.4,
            30},{100.05,30},{100.05,0.05}},      color={0,0,127}));
    connect(Battery.SOC, outBusElec.soc_BAT) annotation (Line(points={{-0.57,
            -69.5},{-4,-69.5},{-4,-70},{100.05,-70},{100.05,0.05}},
                                                 color={0,0,127}));
    connect(PV_Distr_Use, use.u2) annotation (Line(points={{-100,58},{-76,58},{
            -76,58.4},{-39.2,58.4}}, color={0,0,127}));
    connect(PV_Distr_FeedIn, FeedIn.u2) annotation (Line(points={{-100,42},{-70,
            42},{-70,42.4},{-39.2,42.4}}, color={0,0,127}));
    connect(PV_Distr_ChBat, PV_ch_BAT.u2) annotation (Line(points={{-100,26},{
            -70,26},{-70,26.4},{-39.2,26.4}}, color={0,0,127}));
    connect(tot_powerPV.y, use.u1) annotation (Line(points={{-43.4,82},{-42,82},
            {-42,65.6},{-39.2,65.6}}, color={0,0,127}));
    connect(FeedIn.u1, use.u1) annotation (Line(points={{-39.2,49.6},{-42,49.6},
            {-42,65.6},{-39.2,65.6}}, color={0,0,127}));
    connect(PV_ch_BAT.u1, use.u1) annotation (Line(points={{-39.2,33.6},{-42,
            33.6},{-42,65.6},{-39.2,65.6}}, color={0,0,127}));
    connect(calcLoad.y, Battery.PLoad) annotation (Line(points={{-61.4,-64},{
            -52,-64},{-52,-46},{-16.5,-46},{-16.5,-55.25}}, color={0,0,127}));
    connect(PV_ch_BAT.y, chBATfromGrid.u1) annotation (Line(points={{-25.4,30},
            {-22,30},{-22,18},{-2,18},{-2,21.2},{2.6,21.2}}, color={0,0,127}));
    connect(Pow_BAT_ChBat, chBATfromGrid.u2) annotation (Line(points={{-100,-88},
            {-124,-88},{-124,12.8},{2.6,12.8}}, color={0,0,127}));
    connect(FeedIn.y, totFeedIn.u1) annotation (Line(points={{-25.4,46},{-14,46},
            {-14,1.2},{2.6,1.2}}, color={0,0,127}));
    connect(Pow_BAT_FeedIn, totFeedIn.u2) annotation (Line(points={{-100,-72},{
            -120,-72},{-120,-7.2},{2.6,-7.2}}, color={0,0,127}));
    connect(totFeedIn.y, outBusElec.power_to_grid) annotation (Line(points={{
            18.7,-3},{84,-3},{84,0.05},{100.05,0.05}}, color={0,0,127}));
    connect(use.y, totSelfUse.u1) annotation (Line(points={{-25.4,62},{-8,62},{
            -8,-18.8},{2.6,-18.8}}, color={0,0,127}));
    connect(Pow_BAT_Use, totSelfUse.u2) annotation (Line(points={{-100,-56},{
            -100,-27.2},{2.6,-27.2}}, color={0,0,127}));
    connect(P_el_dom, res_elec.u2) annotation (Line(points={{36,-100},{36,-88},
            {46.6,-88},{46.6,-89.2}}, color={0,0,127}));
    connect(P_el_Gen, res_elec.u1) annotation (Line(points={{18,-100},{18,-80.8},
            {46.6,-80.8}}, color={0,0,127}));
    connect(res_elec.y, outBusElec.res_elec) annotation (Line(points={{62.7,-85},
            {100.05,-85},{100.05,0.05}}, color={0,0,127}));
    connect(totSelfUse.y, remain_dem.u1) annotation (Line(points={{18.7,-23},{
            24.35,-23},{24.35,-21.2},{74.4,-21.2}}, color={0,0,127}));
    connect(res_elec.y, remain_dem.u2) annotation (Line(points={{62.7,-85},{68,
            -85},{68,-30.8},{74.4,-30.8}}, color={0,0,127}));
    connect(remain_dem.y, outBusElec.power_from_grid) annotation (Line(points={
            {92.8,-26},{100.05,-26},{100.05,0.05}}, color={0,0,127}));
    connect(chBATfromGrid.y, chBATfromGrid2.u1) annotation (Line(points={{18.7,
            17},{28,17},{28,18},{39,18}}, color={0,0,127}));
    connect(Battery.PGrid, chBATfromGrid2.u2) annotation (Line(points={{-4.7,
            -54.11},{-4,-54.11},{-4,-40},{28,-40},{28,12},{39,12}}, color={0,0,
            127}));
    connect(chBATfromGrid2.y, outBusElec.power_to_BAT_from_grid) annotation (
        Line(points={{50.5,15},{100.05,15},{100.05,0.05}}, color={0,0,127}));
    connect(Pow_BAT_ChBat, outBusElec.ch_BAT) annotation (Line(points={{-100,
            -88},{-100,-120},{100.05,-120},{100.05,0.05}}, color={0,0,127}));
    connect(calcLoad.y, outBusElec.dch_BAT) annotation (Line(points={{-61.4,-64},
            {-52,-64},{-52,-46},{100.05,-46},{100.05,0.05}}, color={0,0,127}));
    connect(Pow_BAT_Use, outBusElec.power_use_BAT) annotation (Line(points={{
            -100,-56},{-150,-56},{-150,-132},{100.05,-132},{100.05,0.05}},
          color={0,0,127}));
    connect(Pow_BAT_FeedIn, outBusElec.power_to_grid_BAT) annotation (Line(
          points={{-100,-72},{-130,-72},{-130,-126},{100.05,-126},{100.05,0.05}},
          color={0,0,127}));
    connect(tot_powerPV.y, outBusElec.ts_power_PV) annotation (Line(points={{
            -43.4,82},{100.05,82},{100.05,0.05}}, color={0,0,127}));
  end Electricity_PVandBAT_ref;

model Electricity_PVandBAT_ref2
    parameter Modelica.SIunits.Time timZon(displayUnit="h")=timZon
        "Time zone. Should be equal with timZon in ReaderTMY3, if PVSystem and ReaderTMY3 are used together.";
    parameter Real SOC_Bat_Init;
      parameter Integer n_mod=3 "Number of connected PV modules";
    parameter AixLib.DataBase.SolarElectric.PVBaseDataDefinition data = AixLib.DataBase.SolarElectric.ShellSP70()
      "PV Panel data definition";
    parameter ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral
      batteryData=ElectricalStorages.Data.LithiumIon.LithiumIonViessmann()
      "Characteristic data of the battery";
    parameter Integer nBat=3 "Number of batteries";
    parameter Real til = 15*2*3.14/360 annotation(Evaluate=false);
    parameter Real azi1 = 90*(2*3.14)/(360) annotation(Evaluate=false);
    parameter Real azi2 = -90*(2*3.14)/(360) annotation(Evaluate=false);
    parameter Real lat = 52.519*2*3.14/360 annotation(Evaluate=false);
    parameter Real lon = 13.408*2*3.14/360 annotation(Evaluate=false);
    Electrical.PVSystem.PVSystem_ref pVSystemEast(
      data=data,
      redeclare model IVCharacteristics =
          Electrical.PVSystem.BaseClasses.IVCharacteristics5pAnalytical,
      redeclare model CellTemperature =
          Electrical.PVSystem.BaseClasses.CellTemperatureMountingCloseToGround,
      n_mod=n_mod,
      til(displayUnit="deg") = til,
      azi=azi2,
      lat=lat,
      lon=lon,
      alt=15,
      timZon=timZon)
      annotation (Placement(transformation(extent={{-80,64},{-64,80}})));

    ElectricalStorages.BatterySimple Battery(
      batteryData=batteryData,
      nBat=nBat,
      SOC_start=SOC_Bat_Init)
      annotation (Placement(transformation(extent={{-28.5,29.5},{28.5,-29.5}},
          rotation=90,
          origin={-16.5,-69.5})));



    Electrical.PVSystem.PVSystem_ref
                                 pVSystemWest(
      data=data,
      redeclare model IVCharacteristics =
          Electrical.PVSystem.BaseClasses.IVCharacteristics5pAnalytical,
      redeclare model CellTemperature =
          Electrical.PVSystem.BaseClasses.CellTemperatureMountingCloseToGround,
      n_mod=n_mod,
      til=til,
      azi=azi1,
      lat=lat,
      lon=lon,
      alt=15,
      timZon=timZon)
      annotation (Placement(transformation(extent={{-80,84},{-64,100}})));

    Modelica.Blocks.Math.Add tot_powerPV
      annotation (Placement(transformation(extent={{-56,76},{-44,88}})));
    Modelica.Blocks.Interfaces.RealInput PV_Distr_Use annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,58}),  iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-1})));
    Modelica.Blocks.Interfaces.RealInput PV_Distr_ChBat annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,26}),  iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-29})));
    Modelica.Blocks.Interfaces.RealInput PV_Distr_FeedIn annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,42}),  iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-15})));
    Modelica.Blocks.Interfaces.RealInput Pow_BAT_Use annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,-56}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-59})));
    Modelica.Blocks.Interfaces.RealInput Pow_BAT_ChBat annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,-88}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-87})));
    Modelica.Blocks.Interfaces.RealInput Pow_BAT_FeedIn annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-100,-72}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={-93,-73})));
    Modelica.Blocks.Math.Product PV_ch_BAT
      annotation (Placement(transformation(extent={{-38,24},{-26,36}})));
    Modelica.Blocks.Math.Product use
      annotation (Placement(transformation(extent={{-38,56},{-26,68}})));
    Modelica.Blocks.Math.Product FeedIn
      annotation (Placement(transformation(extent={{-38,40},{-26,52}})));
    AixLib.BoundaryConditions.WeatherData.Bus
        weaBus "Weather data bus" annotation (Placement(transformation(extent={{-110,74},
              {-90,94}}),          iconTransformation(extent={{-110,74},{-90,94}})));
    Modelica.Blocks.Math.Add calcLoad
      annotation (Placement(transformation(extent={{-74,-70},{-62,-58}})));
    Interfaces.Outputs.ElectricityOutputs outBusElec
      annotation (Placement(transformation(extent={{90,-10},{110,10}})));
    Modelica.Blocks.Interfaces.RealInput P_el_Gen annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={18,-100}),iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=90,
          origin={1,-93})));
    Modelica.Blocks.Interfaces.RealInput P_el_dom annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={36,-100}), iconTransformation(
          extent={{-7,-7},{7,7}},
          rotation=90,
          origin={23,-93})));
    Modelica.Blocks.Math.Add chBATfromGrid(k1=-1)
      annotation (Placement(transformation(extent={{4,10},{18,24}})));
    Modelica.Blocks.Math.Add totFeedIn
      annotation (Placement(transformation(extent={{4,-10},{18,4}})));
    Modelica.Blocks.Math.Add totSelfUse
      annotation (Placement(transformation(extent={{4,-30},{18,-16}})));
    Modelica.Blocks.Math.Add res_elec annotation (Placement(transformation(
          extent={{-7,-7},{7,7}},
          rotation=0,
          origin={55,-85})));
    Modelica.Blocks.Math.Add remain_dem(k1=-1)
      annotation (Placement(transformation(extent={{76,-34},{92,-18}})));
    Modelica.Blocks.Math.Add chBATfromGrid2(k2=-1)
      annotation (Placement(transformation(extent={{40,10},{50,20}})));
equation



    connect(pVSystemWest.DCOutputPower, tot_powerPV.u1) annotation (Line(points={{-63.2,
            92},{-60,92},{-60,86},{-56,86},{-56,85.6},{-57.2,85.6}},
                                                   color={0,0,127}));
    connect(pVSystemEast.DCOutputPower, tot_powerPV.u2) annotation (Line(points={{-63.2,
            72},{-60,72},{-60,78},{-58,78},{-58,78.4},{-57.2,78.4}},
                                                   color={0,0,127}));
    connect(weaBus, pVSystemWest.waeBus) annotation (Line(
        points={{-100,84},{-88,84},{-88,92},{-80,92}},
        color={255,204,51},
        thickness=0.5));
    connect(weaBus, pVSystemEast.waeBus) annotation (Line(
        points={{-100,84},{-88,84},{-88,72},{-80,72}},
        color={255,204,51},
        thickness=0.5));
    connect(Pow_BAT_Use, calcLoad.u1) annotation (Line(points={{-100,-56},{-82,
            -56},{-82,-60},{-78,-60},{-78,-60.4},{-75.2,-60.4}},
                                             color={0,0,127}));
    connect(Pow_BAT_FeedIn, calcLoad.u2) annotation (Line(points={{-100,-72},{
            -82,-72},{-82,-67.6},{-75.2,-67.6}}, color={0,0,127}));
    connect(tot_powerPV.y, outBusElec.power_PV) annotation (Line(points={{-43.4,
            82},{100,82},{100,0}},                      color={0,0,127}));
    connect(Pow_BAT_ChBat, Battery.PCharge) annotation (Line(points={{-100,-88},
            {-80,-88},{-80,-94},{-16,-94},{-16,-83.75},{-16.5,-83.75}},
                                           color={0,0,127}));
    connect(use.y, outBusElec.power_use_PV) annotation (Line(points={{-25.4,62},
            {100.05,62},{100.05,0.05}}, color={0,0,127}));
    connect(FeedIn.y, outBusElec.power_to_grid_PV) annotation (Line(points={{-25.4,
            46},{100.05,46},{100.05,0.05}},      color={0,0,127}));
    connect(PV_ch_BAT.y, outBusElec.power_to_BAT_PV) annotation (Line(points={{-25.4,
            30},{100.05,30},{100.05,0.05}},      color={0,0,127}));
    connect(Battery.SOC, outBusElec.soc_BAT) annotation (Line(points={{-0.57,
            -69.5},{-4,-69.5},{-4,-70},{100.05,-70},{100.05,0.05}},
                                                 color={0,0,127}));
    connect(PV_Distr_Use, use.u2) annotation (Line(points={{-100,58},{-76,58},{
            -76,58.4},{-39.2,58.4}}, color={0,0,127}));
    connect(PV_Distr_FeedIn, FeedIn.u2) annotation (Line(points={{-100,42},{-70,
            42},{-70,42.4},{-39.2,42.4}}, color={0,0,127}));
    connect(PV_Distr_ChBat, PV_ch_BAT.u2) annotation (Line(points={{-100,26},{
            -70,26},{-70,26.4},{-39.2,26.4}}, color={0,0,127}));
    connect(tot_powerPV.y, use.u1) annotation (Line(points={{-43.4,82},{-42,82},
            {-42,65.6},{-39.2,65.6}}, color={0,0,127}));
    connect(FeedIn.u1, use.u1) annotation (Line(points={{-39.2,49.6},{-42,49.6},
            {-42,65.6},{-39.2,65.6}}, color={0,0,127}));
    connect(PV_ch_BAT.u1, use.u1) annotation (Line(points={{-39.2,33.6},{-42,
            33.6},{-42,65.6},{-39.2,65.6}}, color={0,0,127}));
    connect(calcLoad.y, Battery.PLoad) annotation (Line(points={{-61.4,-64},{
            -52,-64},{-52,-46},{-16.5,-46},{-16.5,-55.25}}, color={0,0,127}));
    connect(PV_ch_BAT.y, chBATfromGrid.u1) annotation (Line(points={{-25.4,30},
            {-22,30},{-22,18},{-2,18},{-2,21.2},{2.6,21.2}}, color={0,0,127}));
    connect(Pow_BAT_ChBat, chBATfromGrid.u2) annotation (Line(points={{-100,-88},
            {-124,-88},{-124,12.8},{2.6,12.8}}, color={0,0,127}));
    connect(FeedIn.y, totFeedIn.u1) annotation (Line(points={{-25.4,46},{-14,46},
            {-14,1.2},{2.6,1.2}}, color={0,0,127}));
    connect(Pow_BAT_FeedIn, totFeedIn.u2) annotation (Line(points={{-100,-72},{
            -120,-72},{-120,-7.2},{2.6,-7.2}}, color={0,0,127}));
    connect(totFeedIn.y, outBusElec.power_to_grid) annotation (Line(points={{
            18.7,-3},{84,-3},{84,0.05},{100.05,0.05}}, color={0,0,127}));
    connect(use.y, totSelfUse.u1) annotation (Line(points={{-25.4,62},{-8,62},{
            -8,-18.8},{2.6,-18.8}}, color={0,0,127}));
    connect(Pow_BAT_Use, totSelfUse.u2) annotation (Line(points={{-100,-56},{
            -100,-27.2},{2.6,-27.2}}, color={0,0,127}));
    connect(P_el_dom, res_elec.u2) annotation (Line(points={{36,-100},{36,-88},
            {46.6,-88},{46.6,-89.2}}, color={0,0,127}));
    connect(P_el_Gen, res_elec.u1) annotation (Line(points={{18,-100},{18,-80.8},
            {46.6,-80.8}}, color={0,0,127}));
    connect(res_elec.y, outBusElec.res_elec) annotation (Line(points={{62.7,-85},
            {100.05,-85},{100.05,0.05}}, color={0,0,127}));
    connect(totSelfUse.y, remain_dem.u1) annotation (Line(points={{18.7,-23},{
            24.35,-23},{24.35,-21.2},{74.4,-21.2}}, color={0,0,127}));
    connect(res_elec.y, remain_dem.u2) annotation (Line(points={{62.7,-85},{68,
            -85},{68,-30.8},{74.4,-30.8}}, color={0,0,127}));
    connect(remain_dem.y, outBusElec.power_from_grid) annotation (Line(points={
            {92.8,-26},{100.05,-26},{100.05,0.05}}, color={0,0,127}));
    connect(chBATfromGrid.y, chBATfromGrid2.u1) annotation (Line(points={{18.7,
            17},{28,17},{28,18},{39,18}}, color={0,0,127}));
    connect(Battery.PGrid, chBATfromGrid2.u2) annotation (Line(points={{-4.7,
            -54.11},{-4,-54.11},{-4,-40},{28,-40},{28,12},{39,12}}, color={0,0,
            127}));
    connect(chBATfromGrid2.y, outBusElec.power_to_BAT_from_grid) annotation (
        Line(points={{50.5,15},{100.05,15},{100.05,0.05}}, color={0,0,127}));
    connect(Pow_BAT_ChBat, outBusElec.ch_BAT) annotation (Line(points={{-100,
            -88},{-100,-120},{100.05,-120},{100.05,0.05}}, color={0,0,127}));
    connect(calcLoad.y, outBusElec.dch_BAT) annotation (Line(points={{-61.4,-64},
            {-52,-64},{-52,-46},{100.05,-46},{100.05,0.05}}, color={0,0,127}));
    connect(Pow_BAT_Use, outBusElec.power_use_BAT) annotation (Line(points={{
            -100,-56},{-150,-56},{-150,-132},{100.05,-132},{100.05,0.05}},
          color={0,0,127}));
    connect(Pow_BAT_FeedIn, outBusElec.power_to_grid_BAT) annotation (Line(
          points={{-100,-72},{-130,-72},{-130,-126},{100.05,-126},{100.05,0.05}},
          color={0,0,127}));
    connect(tot_powerPV.y, outBusElec.ts_power_PV) annotation (Line(points={{
            -43.4,82},{100.05,82},{100.05,0.05}}, color={0,0,127}));
end Electricity_PVandBAT_ref2;


annotation (Icon(graphics={
       Rectangle(
         lineColor={200,200,200},
         fillColor={248,248,248},
         fillPattern=FillPattern.HorizontalCylinder,
         extent={{-100.0,-100.0},{100.0,100.0}},
         radius=25.0),
       Rectangle(
         lineColor={128,128,128},
         extent={{-100.0,-100.0},{100.0,100.0}},
         radius=25.0),
       Rectangle(
         lineColor={128,128,128},
         extent={{-100.0,-100.0},{100.0,100.0}},
         radius=25.0),
     Rectangle(extent={{-80,66},{-18,-42}}, lineColor={0,0,0}),
     Rectangle(extent={{24,66},{88,8}}, lineColor={0,0,0}),
     Rectangle(extent={{24,-24},{88,-82}}, lineColor={0,0,0}),
     Line(points={{-20,50},{24,50}}, color={0,0,0}),
     Line(points={{-20,24},{24,24}}, color={0,0,0}),
     Line(points={{74,-24},{74,8}}, color={0,0,0}),
     Line(points={{38,-24},{38,8}}, color={0,0,0})}));
end Electricity;
