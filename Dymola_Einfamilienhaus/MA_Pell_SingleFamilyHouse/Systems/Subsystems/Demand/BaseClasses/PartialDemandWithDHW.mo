within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Demand.BaseClasses;
partial model PartialDemandWithDHW
  extends PartialDemand;
  Components.Pumps.ArtificalPumpFixedT artificalPumpFixedT(
    redeclare package Medium = MediumDHW,
    p=systemParameters.pHyd,
    T_fixed=systemParameters.TWaterCold) annotation (Placement(transformation(
        extent={{-14,-14},{14,14}},
        rotation=270,
        origin={-70,-60})));
  Modelica.Blocks.Sources.RealExpression Q_dhw(y=artificalPumpFixedT.port_a.m_flow
        *(inStream(artificalPumpFixedT.port_a.h_outflow) - artificalPumpFixedT.port_b.h_outflow))
    annotation (Placement(transformation(extent={{64,-74},{84,-54}})));
  replaceable Components.DHW.BaseClasses.PartialDHW calcmFlow
    constrainedby Components.DHW.BaseClasses.PartialDHW(
    final TCold=systemParameters.TWaterCold,
    final dWater=systemParameters.rhoWater,
    final c_p_water=systemParameters.c_pWater,
    final TSetDHW=systemParameters.TSetDHW) annotation (choicesAllMatching=true,
      Placement(transformation(
        extent={{-18,-16},{18,16}},
        rotation=180,
        origin={-22,-60})));

  AixLib.Fluid.Sensors.TemperatureTwoPort senT(
    final transferHeat=false,
    redeclare final package Medium = MediumDHW,
    final m_flow_nominal=0.1) "Temperature of DHW" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={-70,-32})));
equation
  connect(artificalPumpFixedT.port_b, portDHW_out) annotation (Line(points={{-70,-74},
          {-70,-82},{-100,-82}},                color={0,127,255}));
  connect(artificalPumpFixedT.m_flow_in, calcmFlow.m_flow_out)
    annotation (Line(points={{-53.76,-60},{-41.8,-60}}, color={0,0,127}));
  connect(portDHW_in, senT.port_a) annotation (Line(points={{-100,-20},{-96,-20},
          {-96,-22},{-70,-22}}, color={0,127,255}));
  connect(senT.port_b, artificalPumpFixedT.port_a)
    annotation (Line(points={{-70,-42},{-70,-46}}, color={0,127,255}));
  connect(senT.T, calcmFlow.TIs) annotation (Line(points={{-59,-32},{18,-32},{18,
          -60},{-0.4,-60}}, color={0,0,127}));
  connect(calcmFlow.TSet, sigBusDem.inputScenario.TDemandDHW) annotation (Line(
        points={{-0.4,-50.4},{120,-50.4},{120,99.095},{3.135,99.095}}, color={0,
          0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(calcmFlow.m_flow_in, sigBusDem.inputScenario.m_flowDHW) annotation (
      Line(points={{-0.4,-69.6},{132,-69.6},{132,99.095},{3.135,99.095}}, color=
         {0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(Q_dhw.y, outBusDem.dch_DHW) annotation (Line(points={{85,-64},{98.05,
          -64},{98.05,-1.95}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
end PartialDemandWithDHW;
