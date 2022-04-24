within MA_Pell_SingleFamilyHouse.Components;
package DHW
  package BaseClasses
    partial model PartialDHW
      parameter Modelica.SIunits.Temperature TCold=283.15 "Cold water temperature";
      parameter Modelica.SIunits.Density dWater=1000 "Density of water";
      parameter Modelica.SIunits.SpecificHeatCapacityAtConstantPressure c_p_water=4184 "Heat capacity of water";
      parameter Real TSetDHW "Set temperature of DHW";

      Modelica.Blocks.Interfaces.RealInput m_flow_in
        annotation (Placement(transformation(extent={{-140,40},{-100,80}})));
      Modelica.Blocks.Interfaces.RealOutput m_flow_out
        annotation (Placement(transformation(extent={{100,-10},{120,10}})));
      Modelica.Blocks.Interfaces.RealInput TSet "Set temperature of DHW"
        annotation (Placement(transformation(extent={{-140,-80},{-100,-40}})));
      Modelica.Blocks.Interfaces.RealInput TIs "Actual DHW temperature"
        annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));

    equation
      assert(TSet>=TCold, "Set temperature has to be higher than cold water temperature", AssertionLevel.error);
      assert(TIs>TCold, "Actual temperature has to be higher than cold water temperature", AssertionLevel.error);

      annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end PartialDHW;

    partial model PartialcalcmFlowEqu
      "Calculate based on set temperature and actual temperature"
      extends BaseClasses.PartialDHW;
      Modelica.Blocks.Math.Division
                                division
        annotation (Placement(transformation(extent={{-8,-2},{12,-22}})));
      Modelica.Blocks.Math.Add dTSet(final k2=-1)
        annotation (Placement(transformation(extent={{-42,-80},{-22,-60}})));
      Modelica.Blocks.Sources.Constant constTCold(final k=TCold)
        annotation (Placement(transformation(extent={{-80,-100},{-60,-80}})));
      Modelica.Blocks.Math.Add dTIs(final k2=-1)
        annotation (Placement(transformation(extent={{-42,-16},{-22,4}})));
      Modelica.Blocks.Math.Product
                                product
        annotation (Placement(transformation(extent={{64,10},{84,-10}})));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMax=1, uMin=0)
        annotation (Placement(transformation(extent={{30,-22},{50,-2}})));
      Modelica.Blocks.Math.Add deltaLim(final k2=-1) annotation (Placement(
            transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={10,82})));
      Modelica.Blocks.Interfaces.RealOutput Q_flowERROR
        annotation (Placement(transformation(extent={{100,70},{120,90}})));
      Modelica.Blocks.Math.MultiProduct
                                multiProduct(nu=4)
        annotation (Placement(transformation(extent={{42,90},{62,70}})));
      Modelica.Blocks.Sources.Constant const_cp(final k=c_p_water)
        annotation (Placement(transformation(extent={{-46,88},{-26,108}})));
    equation
      connect(TSet, dTSet.u1) annotation (Line(points={{-120,-60},{-64,-60},{-64,-64},
              {-44,-64}}, color={0,0,127}));
      connect(constTCold.y, dTSet.u2) annotation (Line(points={{-59,-90},{-52,-90},{
              -52,-76},{-44,-76}}, color={0,0,127}));
      connect(dTSet.y, division.u1) annotation (Line(points={{-21,-70},{-16,-70},
              {-16,-18},{-10,-18}}, color={0,0,127}));
      connect(dTIs.y, division.u2)
        annotation (Line(points={{-21,-6},{-10,-6}}, color={0,0,127}));
      connect(product.y, m_flow_out)
        annotation (Line(points={{85,0},{110,0}}, color={0,0,127}));
      connect(m_flow_in, product.u2) annotation (Line(points={{-120,60},{36,60},
              {36,6},{62,6}}, color={0,0,127}));
      connect(constTCold.y, dTIs.u2) annotation (Line(points={{-59,-90},{-52,
              -90},{-52,-12},{-44,-12}}, color={0,0,127}));
      connect(division.y, limiter.u)
        annotation (Line(points={{13,-12},{28,-12}}, color={0,0,127}));
      connect(limiter.y, product.u1) annotation (Line(points={{51,-12},{56,-12},
              {56,-6},{62,-6}}, color={0,0,127}));
      connect(division.y, deltaLim.u1) annotation (Line(points={{13,-12},{16,
              -12},{16,-10},{18,-10},{18,20},{-14,20},{-14,88},{-2,88}}, color=
              {0,0,127}));
      connect(limiter.y, deltaLim.u2) annotation (Line(points={{51,-12},{22,-12},
              {22,46},{-10,46},{-10,76},{-2,76}}, color={0,0,127}));
      connect(deltaLim.y, multiProduct.u[1]) annotation (Line(points={{21,82},{
              31.5,82},{31.5,74.75},{42,74.75}}, color={0,0,127}));
      connect(m_flow_in, multiProduct.u[2]) annotation (Line(points={{-120,60},
              {34,60},{34,78.25},{42,78.25}}, color={0,0,127}));
      connect(const_cp.y, multiProduct.u[3]) annotation (Line(points={{-25,98},
              {36,98},{36,81.75},{42,81.75}}, color={0,0,127}));
      connect(multiProduct.y, Q_flowERROR) annotation (Line(points={{63.7,80},{
              110,80},{110,80}}, color={0,0,127}));
      connect(dTSet.y, multiProduct.u[4]) annotation (Line(points={{-21,-70},{
              28,-70},{28,85.25},{42,85.25}}, color={0,0,127}));
    end PartialcalcmFlowEqu;
  end BaseClasses;

  model PassThrough "Just extract the water from the DHW tank"
    extends BaseClasses.PartialDHW;
  equation
    connect(m_flow_in, m_flow_out) annotation (Line(points={{-120,60},{-6,60},{
            -6,0},{110,0}}, color={0,0,127}));
  end PassThrough;

  model calcmFlowEquStatic "Static way to calc m_flow_equivalent"
    extends BaseClasses.PartialcalcmFlowEqu;
    Modelica.Blocks.Sources.Constant constTSet(final k=TSetDHW)
      annotation (Placement(transformation(extent={{-82,-10},{-62,10}})));
    Modelica.Blocks.Interfaces.RealOutput Q_flowDELIVERED
      annotation (Placement(transformation(extent={{100,-84},{120,-64}})));
    Modelica.Blocks.Math.MultiProduct
                              multiProduct1(nu=3)
      annotation (Placement(transformation(extent={{46,-62},{66,-82}})));
    Modelica.Blocks.Sources.Constant const_cp1(final k=c_p_water)
      annotation (Placement(transformation(extent={{-2,-96},{18,-76}})));
  equation
    connect(TIs, dTIs.u1) annotation (Line(points={{-120,0},{-92,0},{-92,28},{
            -54,28},{-54,0},{-44,0}}, color={0,0,127}));
    connect(multiProduct1.y, Q_flowDELIVERED) annotation (Line(points={{67.7,
            -72},{88,-72},{88,-74},{110,-74}}, color={0,0,127}));
    connect(const_cp1.y, multiProduct1.u[1]) annotation (Line(points={{19,-86},
            {28,-86},{28,-76.6667},{46,-76.6667}}, color={0,0,127}));
    connect(product.y, m_flow_out)
      annotation (Line(points={{85,0},{110,0}}, color={0,0,127}));
    connect(m_flow_in, product.u2) annotation (Line(points={{-120,60},{36,60},{
            36,6},{62,6}}, color={0,0,127}));
    connect(m_flow_out, multiProduct1.u[2]) annotation (Line(points={{110,0},{
            124,0},{124,-56},{38,-56},{38,-72},{46,-72}}, color={0,0,127}));
    connect(dTIs.y, multiProduct1.u[3]) annotation (Line(points={{-21,-6},{-20,
            -6},{-20,-66},{14,-66},{14,-67.3333},{46,-67.3333}}, color={0,0,127}));
  end calcmFlowEquStatic;

  model calcmFlowEquDynamic "Dynamic way to calc m_flow_equivalent"
    extends BaseClasses.PartialcalcmFlowEqu;
    Modelica.Blocks.Continuous.Integrator
                              mDHWTapped
      annotation (Placement(transformation(extent={{-62,44},{-42,24}})));
  equation
    connect(TIs, dTIs.u1) annotation (Line(points={{-120,0},{-76,0},{-76,0},{-44,0}},
          color={0,0,127}));
    connect(m_flow_in, mDHWTapped.u) annotation (Line(points={{-120,60},{-92,60},
            {-92,34},{-64,34}}, color={0,0,127}));
  end calcmFlowEquDynamic;

  model Example
    extends Systems.BaseClasses.PartialBESExample;

    replaceable calcmFlowEquDynamic    calcm_flow(TSetDHW=systemParameters.TSetDHW)
                                                  annotation (choicesAllMatching=true, Placement(
          transformation(
          extent={{-18,-18},{18,18}},
          rotation=0,
          origin={0,0})));
    Systems.Subsystems.InputScenario.Scenario scenario(
        systemParameters=systemParameters)
      annotation (Placement(transformation(extent={{-112,-36},{-72,16}})));
    Interfaces.InputScenarioBus inputScenBus
      annotation (Placement(transformation(extent={{-70,-74},{-36,-34}})));
    Modelica.Blocks.Sources.Constant TIn(k=273.15 + 50)
      "Profiles for internal gains" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=180,
          origin={-68,50})));
    Modelica.Blocks.Continuous.Integrator integrator
      annotation (Placement(transformation(extent={{32,-10},{52,10}})));
  equation
    connect(scenario.inputScenBus, inputScenBus) annotation (Line(
        points={{-71.7,-10.1},{-68.35,-10.1},{-68.35,-54},{-53,-54}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%second",
        index=1,
        extent={{6,3},{6,3}},
        horizontalAlignment=TextAlignment.Left));
    connect(inputScenBus.TDemandDHW, calcm_flow.TSet) annotation (Line(
        points={{-52.915,-53.9},{-32,-53.9},{-32,-10.8},{-21.6,-10.8}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{-6,3},{-6,3}},
        horizontalAlignment=TextAlignment.Right));
    connect(inputScenBus.m_flowDHW, calcm_flow.m_flow_in) annotation (Line(
        points={{-52.915,-53.9},{-52.915,10.8},{-21.6,10.8}},
        color={255,204,51},
        thickness=0.5), Text(
        string="%first",
        index=-1,
        extent={{-6,3},{-6,3}},
        horizontalAlignment=TextAlignment.Right));
    connect(TIn.y, calcm_flow.TIs) annotation (Line(points={{-57,50},{-52,50},{-52,
            52},{-38,52},{-38,0},{-21.6,0}}, color={0,0,127}));
    connect(calcm_flow.m_flow_out, integrator.u)
      annotation (Line(points={{19.8,0},{30,0}}, color={0,0,127}));
    annotation (experiment(StopTime=86400, __Dymola_Algorithm="Dassl"));
  end Example;

  type DHWProfile = enumeration(
      S "Profile S",
      M "Profile M",
      L "Profile L",
      DHWCalc "DHWCalc",
      NoDHW "No DHW") "Enum for dhw profile type";
end DHW;
