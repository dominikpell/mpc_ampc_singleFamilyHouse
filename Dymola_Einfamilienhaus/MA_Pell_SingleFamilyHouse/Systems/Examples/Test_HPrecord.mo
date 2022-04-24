within MA_Pell_SingleFamilyHouse.Systems.Examples;
model Test_HPrecord

  AixLib.Fluid.HeatPumps.HeatPump heatPump(
    redeclare package Medium_con = AixLib.Media.Water,
    redeclare package Medium_eva = AixLib.Media.Air,
    final use_rev=true,
    final use_autoCalc=false,
    final Q_useNominal=0,
    final scalingFactor=1,
    final use_refIne=false,
    final useBusConnectorOnly=true,
    final mFlow_conNominal=systemParameters.mGen_flow_nominal,
    final VCon=heatPumpParameters.VCon,
    final dpCon_nominal=heatPumpParameters.dpCon_nominal,
    final use_conCap=false,
    final CCon=0,
    final GConOut=0,
    final GConIns=0,
    final mFlow_evaNominal=heatPumpParameters.mFlow_eva,
    final VEva=heatPumpParameters.VEva,
    final dpEva_nominal=heatPumpParameters.dpEva_nominal,
    final use_evaCap=false,
    final CEva=0,
    final GEvaOut=0,
    final GEvaIns=0,
    final tauSenT=systemParameters.tauTempSensors,
    final transferHeat=true,
    final allowFlowReversalEva=systemParameters.allowFlowReversal,
    final allowFlowReversalCon=systemParameters.allowFlowReversal,
    final tauHeaTraEva=systemParameters.tauHeaTraTempSensors,
    final TAmbEva_nominal=systemParameters.TAmbInternal,
    final tauHeaTraCon=systemParameters.tauHeaTraTempSensors,
    final TAmbCon_nominal=systemParameters.TOda_nominal,
    final pCon_start=systemParameters.pHyd,
    final TCon_start=systemParameters.TWater_start,
    final pEva_start=systemParameters.pAtm,
    final TEva_start=systemParameters.TAir_start,
    final massDynamics=systemParameters.massDynamics,
    final energyDynamics=systemParameters.energyDynamics,
    final show_TPort=systemParameters.show_T,
    redeclare model PerDataMainHP =
        AixLib.DataBase.HeatPump.PerformanceData.LookUpTable2D (dataTable=
            MA_Pell_SingleFamilyHouse.RecordsCollection.HeatPumpData.HeatPumpCarnotHeat()),
    redeclare model PerDataRevHP =
        AixLib.DataBase.Chiller.PerformanceData.LookUpTable2D (dataTable=
            MA_Pell_SingleFamilyHouse.RecordsCollection.HeatPumpData.HeatPumpCarnotCool()))
                                                 annotation (Placement(
        transformation(
        extent={{22,-27},{-22,27}},
        rotation=270,
        origin={-20,-1})));
  AixLib.Fluid.Sources.Boundary_ph bou_sinkAir(final nPorts=1, redeclare
      package Medium = AixLib.Media.Air)                 annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-64,-38})));
  AixLib.Fluid.Sources.MassFlowSource_T bou_air(
    final m_flow=1.2,
    final use_T_in=true,
    redeclare package Medium = AixLib.Media.Air,
    final use_m_flow_in=false,
    final nPorts=1)
    annotation (Placement(transformation(extent={{-74,26},{-54,46}})));
  MA_Pell_SingleFamilyHouse.RecordsCollection.GenerationData.DummyHP heatPumpParameters annotation (choicesAllMatching=true, Placement(
        transformation(extent={{-64,-12},{-46,6}})));
  Modelica.Blocks.Sources.Ramp ramp(
    height=45,
    duration=60,
    offset=263.15,
    startTime=5)
    annotation (Placement(transformation(extent={{-160,30},{-140,50}})));
  AixLib.Fluid.Sources.Boundary_pT bou(
    redeclare package Medium = AixLib.Media.Water,
    p=150000,
    nPorts=1) annotation (Placement(transformation(extent={{58,-52},{78,-32}})));
  AixLib.Fluid.Sources.Boundary_pT sin1(
    T=299.15,
    nPorts=1,
    redeclare package Medium = AixLib.Media.Water)
    annotation (Placement(transformation(extent={{10,-10},{-10,10}}, origin={28,42})));
  parameter
    MA_Pell_SingleFamilyHouse.RecordsCollection.ExampleSystemParameters
                                                         systemParameters(
    TSup_nominal=308.15,
    TSetRoomConst=294.15,
    TOffNight=3,
    nZones=1,
    oneZoneParam=
        MA_Pell_SingleFamilyHouse.Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase.ResidentialBuilding_SingleDwellingNoFloor(),
    zoneParam=fill(systemParameters.oneZoneParam, systemParameters.nZones),
    filNamIntGains=Modelica.Utilities.Files.loadResource("modelica://MA_Pell_SingleFamilyHouse/Data/InternalGains_ResidentialBuildingTabulaMulti.txt"),
    DHWtapping=MA_Pell_SingleFamilyHouse.Components.DHW.DHWProfile.M,
    oneZoneParamUFH=
        MA_Pell_SingleFamilyHouse.Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase.ResidentialBuildingWFloor_SingleDwellingWithFloor(),
    DHWProfile=MA_Pell_SingleFamilyHouse.RecordsCollection.DHW.ProfileM())
    "Parameters relevant for the whole energy system" annotation (
      choicesAllMatching=true, Placement(transformation(extent={{-198,-68},{
            -146,-8}})));

  Modelica.Blocks.Sources.BooleanExpression booleanExpression(y=true)
    annotation (Placement(transformation(extent={{-98,-78},{-78,-58}})));
  Modelica.Blocks.Sources.Constant const(k=1)
    annotation (Placement(transformation(extent={{-80,-104},{-60,-84}})));
  AixLib.Controls.Interfaces.VapourCompressionMachineControlBus sigBus
    annotation (Placement(transformation(extent={{-48,-76},{-8,-36}})));
equation
  connect(bou_air.ports[1],heatPump. port_a2) annotation (Line(
      points={{-54,36},{-33.5,36},{-33.5,21}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(heatPump.port_b2,bou_sinkAir. ports[1]) annotation (Line(
      points={{-33.5,-23},{-32,-23},{-32,-38},{-54,-38}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(ramp.y, bou_air.T_in)
    annotation (Line(points={{-139,40},{-76,40}}, color={0,0,127}));
  connect(heatPump.port_a1, bou.ports[1]) annotation (Line(points={{-6.5,-23},{78,
          -23},{78,-42}}, color={0,127,255}));
  connect(heatPump.port_b1, sin1.ports[1])
    annotation (Line(points={{-6.5,21},{-6.5,42},{18,42}}, color={0,127,255}));
  connect(heatPump.sigBus, sigBus) annotation (Line(
      points={{-28.775,-22.78},{-28.775,-32.39},{-28,-32.39},{-28,-56}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(const.y, sigBus.nSet) annotation (Line(points={{-59,-94},{-27.9,-94},
          {-27.9,-55.9}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(ramp.y, sigBus.TOdaMea) annotation (Line(points={{-139,40},{-126,40},
          {-126,-55.9},{-27.9,-55.9}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(booleanExpression.y, sigBus.modeSet) annotation (Line(points={{-77,
          -68},{-27.9,-68},{-27.9,-55.9}}, color={255,0,255}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  annotation (experiment(StopTime=200, __Dymola_Algorithm="Dassl"));
end Test_HPrecord;
