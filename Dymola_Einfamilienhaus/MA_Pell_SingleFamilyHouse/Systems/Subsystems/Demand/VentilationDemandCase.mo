within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Demand;
model VentilationDemandCase "Case for ventilation"
  extends BaseClasses.PartialDemandWithDHW(final use_vent=true);

  AixLib.ThermalZones.ReducedOrder.ThermalZone.ThermalZone thermalZone[
    systemParameters.nZones](
    redeclare each final package Medium = MediumZone,
                                      zoneParam=systemParameters.zoneParam,
    each final nPorts=2,
    each final use_AirExchange=true)
    annotation (Placement(transformation(extent={{16,34},{-37,84}},rotation=0)));

  Modelica.Blocks.Sources.Constant constTSetRoom[systemParameters.nZones](each final
      k=systemParameters.TSetRoomConst) "Transform Volume l to massflowrate"
                                         annotation (Placement(transformation(
          extent={{-6,-6},{6,6}}, rotation=180)));

  Modelica.Blocks.Sources.Constant constVentRate[systemParameters.nZones](each final
            k=systemParameters.ventRate) "Transform Volume l to massflowrate"
                                         annotation (Placement(transformation(
          extent={{-5,-5},{5,5}}, rotation=180)));

  Modelica.Blocks.Sources.RealExpression QIntGains[systemParameters.nZones](y=
        thermalZone.lights.convHeat.Q_flow + thermalZone.lights.radHeat.Q_flow +
        thermalZone.machinesSenHea.radHeat.Q_flow + thermalZone.machinesSenHea.convHeat.Q_flow
         + thermalZone.humanSenHeaDependent.radHeat.Q_flow + thermalZone.humanSenHeaDependent.convHeat.Q_flow)
    "Internal gains" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={62,-2})));

  AixLib.Fluid.FixedResistances.PressureDrop resSup[systemParameters.nZones](
    redeclare package Medium = MediumZone,
    each final dp_nominal=systemParameters.dpVent_nominal*systemParameters.nZones/2,
    final m_flow_nominal=systemParameters.mVent_flow_nominal/systemParameters.nZones)
    "Hydraulic resistance of supply" annotation (Placement(transformation(
        extent={{-7.5,-10},{7.5,10}},
        rotation=180,
        origin={50.5,44})));
  AixLib.Fluid.FixedResistances.PressureDrop resExh[systemParameters.nZones](
    redeclare package Medium = MediumZone,
    each final dp_nominal=systemParameters.dpVent_nominal*systemParameters.nZones/2,
    final m_flow_nominal=systemParameters.mVent_flow_nominal/systemParameters.nZones)
    "Hydraulic resistance of exhaust" annotation (Placement(transformation(
        extent={{-7.5,-10},{7.5,10}},
        rotation=0,
        origin={50.5,30})));
equation

  connect(thermalZone.intGainsRad, heatPortRad) annotation (Line(points={{-37.53,
          67.5},{-76,67.5},{-76,30},{-100,30}},   color={191,0,0}));
  connect(thermalZone.intGainsConv, heatPortCon) annotation (Line(points={{-37.53,
          60},{-64,60},{-64,68},{-100,68}},       color={191,0,0}));
  for i in 1:systemParameters.nZones loop
    connect(sigBusDem.weaBus, thermalZone[i].weaBus) annotation (Line(
        points={{3.135,99.095},{3.135,100},{16,100},{16,74}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{-3,6},{-3,6}},
        horizontalAlignment=TextAlignment.Right));
    connect(sigBusDem.weaBus.TDryBul, thermalZone[i].ventTemp) annotation (Line(
        points={{3.135,99.095},{126,99.095},{126,55},{14.94,55}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{6,3},{6,3}},
        horizontalAlignment=TextAlignment.Left));
    connect(sigBusDem.intGains, thermalZone[i].intGains) annotation (Line(
        points={{3.135,99.095},{-62,99.095},{-62,8},{-31.7,8},{-31.7,38}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{-3,-6},{-3,-6}},
        horizontalAlignment=TextAlignment.Right));
    connect(resSup[i].port_a, portVent_in) annotation (Line(points={{58,44},{78,
            44},{78,84},{98,84}}, color={0,127,255}));
    connect(resExh[i].port_b, portVent_out) annotation (Line(points={{58,30},{74,
            30},{74,22},{100,22}}, color={0,127,255}));
    connect(resSup[i].port_b, thermalZone[i].ports[1]) annotation (Line(points={{43,44},
            {28,44},{28,30},{-10,30},{-10,41},{-4.2725,41}},       color={0,127,
            255}));
    connect(resExh[i].port_a, thermalZone[i].ports[2]) annotation (Line(points={{43,30},
            {-10,30},{-10,42},{-16.7275,42},{-16.7275,41}},   color={0,127,255}));
  end for;
  connect(thermalZone.TAir, TZone) annotation (Line(points={{-39.65,79},{-74,79},
          {-74,92},{-110,92}}, color={0,0,127}));
  connect(constTSetRoom.y, thermalZone.TSetCool) annotation (Line(points={{-6.6,
          0},{30,0},{30,69},{14.94,69}}, color={0,0,127}));
  connect(constTSetRoom.y, thermalZone.TSetHeat) annotation (Line(points={{-6.6,
          0},{30,0},{30,62},{14.94,62}}, color={0,0,127}));

  connect(constVentRate.y, thermalZone.ventRate) annotation (Line(points={{-5.5,
          0},{24,0},{24,48.5},{14.94,48.5}}, color={0,0,127}));

  connect(QIntGains.y, outBusDem.QIntGains_flow) annotation (Line(points={{73,-2},
          {98,-2}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));

end VentilationDemandCase;
