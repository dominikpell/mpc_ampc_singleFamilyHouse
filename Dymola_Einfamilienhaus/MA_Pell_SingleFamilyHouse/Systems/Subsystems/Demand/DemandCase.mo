within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Demand;
model DemandCase "Case without ventilation"
  extends BaseClasses.PartialDemandWithDHW(final use_vent=false);
  parameter Real T_Roof=T_Roof annotation(Dialog(tab="Initialize"));
  parameter Real T_Air=T_Air  annotation(Dialog(tab="Initialize"));
  parameter Real T_IntWall=T_IntWall
                                  annotation(Dialog(tab="Initialize"));
  parameter Real T_ExtWall=T_ExtWall
                                  annotation(Dialog(tab="Initialize"));
  parameter Real T_Floor=T_Floor
                                annotation(Dialog(tab="Initialize"));
  parameter Real T_Win=T_Win  annotation(Dialog(tab="Initialize"));
  MA_Pell_SingleFamilyHouse.Systems.Subsystems.Demand.BaseClasses.ThermalZone thermalZone[
    systemParameters.nZones](
    redeclare each final package Medium = MediumZone,
    T_start=systemParameters.TAir_start,
    final zoneParam=systemParameters.zoneParam,
    T_Roof=T_Roof,
    T_Air=T_Air,
    T_IntWall=T_IntWall,
    T_ExtWall=T_ExtWall,
    T_Floor=T_Floor,
    T_Win=T_Win,
    each final use_AirExchange=true)
    annotation (Placement(transformation(extent={{37,12},{-37,84}},rotation=0)));

  Modelica.Blocks.Sources.Constant constVentRate[systemParameters.nZones](each final k=
        systemParameters.ventRate) "Transform Volume l to massflowrate"
                                         annotation (Placement(transformation(
          extent={{-6,-6},{6,6}},     rotation=180,
        origin={76,32})));

  Modelica.Blocks.Sources.RealExpression QIntGains[systemParameters.nZones](y=
        thermalZone.lights.convHeat.Q_flow + thermalZone.lights.radHeat.Q_flow +
        thermalZone.machinesSenHea.radHeat.Q_flow + thermalZone.machinesSenHea.convHeat.Q_flow
         + thermalZone.humanSenHeaDependent.radHeat.Q_flow + thermalZone.humanSenHeaDependent.convHeat.Q_flow)
    "Internal gains" annotation (Placement(transformation(
        extent={{-7,-4},{7,4}},
        rotation=0,
        origin={65,4})));



  Modelica.Blocks.Sources.RealExpression feedback_T_Win(y=thermalZone[1].ROM.convWin.solid.T)
    "Internal gains" annotation (Placement(transformation(
        extent={{-6,-3},{6,3}},
        rotation=0,
        origin={30,-13})));
  Modelica.Blocks.Sources.RealExpression feedback_T_Roof(y=thermalZone[1].ROM.convRoof.solid.T)
    "Internal gains" annotation (Placement(transformation(
        extent={{-6,-3},{6,3}},
        rotation=0,
        origin={30,-21})));
  Modelica.Blocks.Sources.RealExpression feedback_T_IntWall(y=thermalZone[1].ROM.convIntWall.solid.T)
    "Internal gains" annotation (Placement(transformation(
        extent={{-6,-3},{6,3}},
        rotation=0,
        origin={30,-29})));
  Modelica.Blocks.Sources.RealExpression feedback_T_ExtWall(y=thermalZone[1].ROM.convExtWall.solid.T)
    "Internal gains" annotation (Placement(transformation(
        extent={{-6,-3},{6,3}},
        rotation=0,
        origin={30,-17})));
  Modelica.Blocks.Sources.RealExpression feedback_T_Floor(y=thermalZone[1].ROM.convFloor.solid.T)
    "Internal gains" annotation (Placement(transformation(
        extent={{-6,-3},{6,3}},
        rotation=0,
        origin={30,-25})));
  Modelica.Blocks.Sources.RealExpression dT_max(y=if (TZone[1] - sigBusDem.ts_T_inside_max
         > 0) then (TZone[1] - sigBusDem.ts_T_inside_max) else 0)
    "Internal gains" annotation (Placement(transformation(
        extent={{-6,-5},{6,5}},
        rotation=0,
        origin={28,13})));
  Modelica.Blocks.Sources.RealExpression dT_min(y=if (sigBusDem.ts_T_inside_min
         - TZone[1] > 0) then (sigBusDem.ts_T_inside_min - TZone[1]) else 0)
    "Internal gains" annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={28,8})));
  Modelica.Blocks.Math.Add dT_tot
    annotation (Placement(transformation(extent={{48,6},{56,14}})));
  Modelica.Blocks.Sources.RealExpression feedback_T_Air(y=TZone[1])
    "Internal gains" annotation (Placement(transformation(
        extent={{-6,-3},{6,3}},
        rotation=0,
        origin={30,-9})));
  Modelica.Blocks.Sources.RealExpression t_rad(y=heatPortRad[1].T)
    "Radiation Temperature" annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=0,
        origin={54,24})));
equation

  connect(thermalZone.intGainsRad, heatPortRad) annotation (Line(points={{-37.74,
          60.24},{-76,60.24},{-76,30},{-100,30}}, color={191,0,0}));
  connect(thermalZone.intGainsConv, heatPortCon) annotation (Line(points={{-37.74,
          49.44},{-64,49.44},{-64,68},{-100,68}}, color={191,0,0}));
  for i in 1:systemParameters.nZones loop

  end for;


  connect(thermalZone.TAir, TZone) annotation (Line(points={{-40.7,76.8},{-74,76.8},
          {-74,92},{-110,92}}, color={0,0,127}));

  connect(constVentRate.y, thermalZone.ventRate) annotation (Line(points={{69.4,32},
          {48,32},{48,32.88},{35.52,32.88}},color={0,0,127}));

  connect(QIntGains.y, outBusDem.QIntGains_flow) annotation (Line(points={{72.7,4},
          {86,4},{86,-2},{98,-2}},
                    color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));

  connect(sigBusDem.inputScenario.intGains, thermalZone[1].intGains)
    annotation (Line(
      points={{3.135,99.095},{-54,99.095},{-54,14},{-30,14},{-30,17.76},{-29.6,
          17.76}},
      color={255,204,51},
      thickness=0.5));
  connect(sigBusDem.inputScenario.weaBus, thermalZone[1].weaBus) annotation (
      Line(
      points={{3.135,99.095},{37,99.095},{37,69.6}},
      color={255,204,51},
      thickness=0.5));
  connect(sigBusDem.inputScenario.weaBus.TDryBul, thermalZone[1].ventTemp)
    annotation (Line(
      points={{3.135,99.095},{128,99.095},{128,42},{82,42},{82,42.24},{35.52,
          42.24}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(thermalZone[1].TSetCool, sigBusDem.ts_T_inside_max) annotation (Line(
        points={{35.52,62.4},{148,62.4},{148,99.095},{3.135,99.095}}, color={0,
          0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(thermalZone[1].TSetHeat, sigBusDem.ts_T_inside_min) annotation (Line(
        points={{35.52,52.32},{160,52.32},{160,99.095},{3.135,99.095}}, color={
          0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(dT_max.y, dT_tot.u1) annotation (Line(points={{34.6,13},{46,13},{46,
          12.4},{47.2,12.4}}, color={0,0,127}));
  connect(dT_min.y, dT_tot.u2) annotation (Line(points={{34.6,8},{46,8},{46,7.6},
          {47.2,7.6}}, color={0,0,127}));
  connect(feedback_T_Win.y, outBusDem.T_Win) annotation (Line(points={{36.6,-13},
          {98.05,-13},{98.05,-1.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(feedback_T_ExtWall.y, outBusDem.T_ExtWall) annotation (Line(points={{
          36.6,-17},{98.05,-17},{98.05,-1.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(feedback_T_Roof.y, outBusDem.T_Roof) annotation (Line(points={{36.6,
          -21},{98,-21},{98,-1.95},{98.05,-1.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(feedback_T_Floor.y, outBusDem.T_Floor) annotation (Line(points={{36.6,
          -25},{98.05,-25},{98.05,-1.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(feedback_T_IntWall.y, outBusDem.T_IntWall) annotation (Line(points={{
          36.6,-29},{98.05,-29},{98.05,-1.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(feedback_T_Air.y, outBusDem.T_Air) annotation (Line(points={{36.6,-9},
          {98,-9},{98,-1.95},{98.05,-1.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(t_rad.y, outBusDem.t_rad) annotation (Line(points={{60.6,24},{98,24},
          {98,-2},{98.05,-2},{98.05,-1.95}}, color={0,0,127}));
  connect(dT_tot.y, outBusDem.dT_vio) annotation (Line(points={{56.4,10},{98.05,
          10},{98.05,-1.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
end DemandCase;
