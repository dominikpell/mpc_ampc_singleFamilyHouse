within MA_Pell_SingleFamilyHouse.Components;
package Control
  extends Modelica.Icons.Package;

  model HeatingCurve
    "Defines T_supply of buffer storage tank (in dependency of ambient temperature)"

    parameter Modelica.SIunits.Temperature TRoomSet=295.15
      "Expected room temperature (22°C)";
    parameter Real GraHeaCurve=1 "Heat curve gradient";
    parameter Modelica.SIunits.Temperature THeaThres=273.15 + 15
      "Constant heating threshold temperature";
    parameter Modelica.SIunits.TemperatureDifference dTOffSet_HC = 2 "Additional Offset of heating curve";

    Modelica.Blocks.Interfaces.RealInput TOda
      annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
    Modelica.Blocks.Interfaces.RealOutput TSet
      annotation (Placement(transformation(extent={{100,-10},{120,10}})));

    Modelica.Blocks.Interfaces.RealInput T_Room_Set
      annotation (Placement(transformation(extent={{-140,50},{-100,90}})));
  equation
    if TOda < THeaThres then
      TSet = GraHeaCurve*(T_Room_Set - TOda) + T_Room_Set + dTOffSet_HC;
    else
      // No heating required.
      TSet = T_Room_Set + dTOffSet_HC;
    end if;
    annotation (Icon(graphics={Rectangle(
            extent={{-100,100},{100,-100}},
            lineColor={0,0,0},
            lineThickness=0.5,
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
                               Text(
            extent={{-100,230},{100,30}},
            lineColor={0,0,0},
            textString="%name")}));
  end HeatingCurve;

  package HeatPumpNSetController "Models for calculating the relative compressor speed n_set"

    package BaseClasses
      partial model PartialHPNSetController "Partial HP Controller model"
        Modelica.Blocks.Interfaces.BooleanInput HP_On
      "True if heat pump is turned on according to two point controller"
      annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
        Modelica.Blocks.Interfaces.RealOutput n_Set "Relative compressor set value"
      annotation (Placement(transformation(extent={{100,-10},{120,10}})));
        Modelica.Blocks.Interfaces.RealInput T_Set "Current set temperature"
      annotation (Placement(transformation(extent={{-140,40},{-100,80}})));
        Modelica.Blocks.Interfaces.RealInput T_Meas "Current measured temperature"
      annotation (Placement(transformation(
          extent={{-20,-20},{20,20}},
          rotation=90,
          origin={0,-120})));
        Modelica.Blocks.Math.Feedback feedback
      annotation (Placement(transformation(extent={{4,90},{24,110}})));
        Modelica.Blocks.Continuous.Integrator integrator
      annotation (Placement(transformation(extent={{70,104},{90,124}})));
        Modelica.Blocks.Interfaces.RealOutput IAE "Integral Absolute Error"
      annotation (Placement(transformation(extent={{100,90},{120,110}}),
          iconTransformation(extent={{100,50},{120,70}})));
        Modelica.Blocks.Interfaces.RealOutput ISE "Integral Square Error" annotation (
       Placement(transformation(extent={{100,70},{120,90}}), iconTransformation(
            extent={{100,50},{120,70}})));
        Modelica.Blocks.Math.Abs abs1
      annotation (Placement(transformation(extent={{36,104},{56,124}})));
        Modelica.Blocks.Continuous.Integrator integrator1
      annotation (Placement(transformation(extent={{70,70},{90,90}})));
        Modelica.Blocks.Math.Product product "Square the difference"
      annotation (Placement(transformation(extent={{38,70},{58,90}})));
      equation
        connect(
            T_Set, feedback.u1) annotation (Line(points={{-120,60},{-100,60},{
            -100,100},{6,100}}, color={0,0,127}));
        connect(
            T_Meas, feedback.u2) annotation (Line(points={{0,-120},{0,-84},{-88,
            -84},{-88,88},{14,88},{14,92}}, color={0,0,127}));
        connect(
            feedback.y, abs1.u) annotation (Line(points={{23,100},{24,100},{24,
            114},{34,114}}, color={0,0,127}));
        connect(
            abs1.y, integrator.u)
      annotation (Line(points={{57,114},{68,114}}, color={0,0,127}));
        connect(
            integrator.y, IAE) annotation (Line(points={{91,114},{96,114},{96,98},
            {110,98},{110,100}}, color={0,0,127}));
        connect(
            ISE, integrator1.y)
      annotation (Line(points={{110,80},{91,80}}, color={0,0,127}));
        connect(
            feedback.y, product.u1) annotation (Line(points={{23,100},{30,100},{
            30,86},{36,86}}, color={0,0,127}));
        connect(
            integrator1.u, product.y)
      annotation (Line(points={{68,80},{59,80}}, color={0,0,127}));
        connect(
            feedback.y, product.u2) annotation (Line(points={{23,100},{30,100},{
            30,74},{36,74}}, color={0,0,127}));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
              Rectangle(
                extent={{-100,100},{100,-100}},
                lineColor={0,0,0},
                fillColor={215,215,215},
                fillPattern=FillPattern.Solid,
                lineThickness=0.5)}), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
      end PartialHPNSetController;

      model PartialInverterHeatPumpController
        "Partial controller for inverter controlled heat pumps"
        extends BaseClasses.PartialHPNSetController;
        Modelica.Blocks.Continuous.LimPID PID(
          final k=P,
          final yMax=1,
          final yMin=nMin,
          final wp=1,
          final wd=0,
          final initType=Modelica.Blocks.Types.InitPID.DoNotUse_InitialIntegratorState,
          final strict=false,
          final xi_start=0,
          final xd_start=0,
          final y_start=0,
          final limitsAtInit=true)
          annotation (Placement(transformation(extent={{-30,22},{6,58}})));
        parameter Real P "Gain of PID-controller";

        Modelica.Blocks.Logical.Switch onOffSwitch
          annotation (Placement(transformation(extent={{38,-14},{68,16}})));
        Modelica.Blocks.Sources.Constant const(final k=0) "HP turned off"
          annotation (Placement(transformation(extent={{-6,-36},{10,-20}})));
        parameter Real nMin=0.5 "Lower limit of compressor frequency - default 0.5";
      equation
        connect(HP_On, onOffSwitch.u2) annotation (Line(points={{-120,0},{-68,0},{-68,
                1},{35,1}}, color={255,0,255}));
        connect(onOffSwitch.y, n_Set) annotation (Line(points={{69.5,1},{74,1},{74,0},
                {110,0}}, color={0,0,127}));
        connect(const.y, onOffSwitch.u3)
          annotation (Line(points={{10.8,-28},{35,-28},{35,-11}}, color={0,0,127}));
        connect(PID.y, onOffSwitch.u1) annotation (Line(points={{7.8,40},{14,40},{14,
                13},{35,13}}, color={0,0,127}));
        connect(T_Meas, PID.u_m) annotation (Line(points={{0,-120},{0,-60},{-12,-60},
                {-12,18.4}}, color={0,0,127}));
        connect(T_Set, PID.u_s) annotation (Line(points={{-120,60},{-70,60},{-70,40},
                {-33.6,40}}, color={0,0,127}));
      end PartialInverterHeatPumpController;
    end BaseClasses;

    model OnOffHeatPumpController
      "Controller for a on off heat pump, either zero or one"
      extends BaseClasses.PartialHPNSetController;

      parameter Real n_opt "Frequency of the heat pump map with an optimal isentropic efficiency. Necessary, as on-off HP will be optimized for this frequency and only used there.";

      Modelica.Blocks.Math.BooleanToReal hp_on_to_n_hp
        annotation (Placement(transformation(extent={{22,-22},{-22,22}},
            rotation=180,
            origin={-4,3.55271e-15})));
      Modelica.Blocks.Math.Gain gain(final k=n_opt)
        annotation (Placement(transformation(extent={{56,-10},{76,10}})));
    equation
      connect(HP_On, hp_on_to_n_hp.u) annotation (Line(points={{-120,0},{-76,0},{
              -76,7.54952e-15},{-30.4,7.54952e-15}}, color={255,0,255}));
      connect(hp_on_to_n_hp.y, gain.u) annotation (Line(points={{20.2,1.55431e-15},
              {28,1.55431e-15},{28,0},{54,0}},
                                       color={0,0,127}));
      connect(gain.y, n_Set) annotation (Line(points={{77,0},{110,0}},
                           color={0,0,127}));
      annotation (Icon(graphics={
          Line(points={{-100.0,0.0},{-45.0,0.0}},
            color={0,0,127}),
          Ellipse(lineColor={0,0,127},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid,
            extent={{-45.0,-10.0},{-25.0,10.0}}),
          Line(points={{-35.0,0.0},{30.0,35.0}},
            color={0,0,127}),
          Line(points={{45.0,0.0},{100.0,0.0}},
            color={0,0,127}),
          Ellipse(lineColor={0,0,127},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid,
            extent={{25.0,-10.0},{45.0,10.0}})}));
    end OnOffHeatPumpController;

    model P_InverterHeatPumpController
      "P-Controller for inverter controlled heat pumps"
      extends BaseClasses.PartialInverterHeatPumpController(PID(controllerType=
              Modelica.Blocks.Types.SimpleController.P));

      annotation (Icon(graphics={
            Polygon(
              points={{-80,90},{-88,68},{-72,68},{-80,90}},
              lineColor={192,192,192},
              fillColor={192,192,192},
              fillPattern=FillPattern.Solid),
            Line(points={{-80,78},{-80,-90}}, color={192,192,192}),
            Polygon(
              points={{90,-80},{68,-72},{68,-88},{90,-80}},
              lineColor={192,192,192},
              fillColor={192,192,192},
              fillPattern=FillPattern.Solid),
            Line(points={{-90,-80},{82,-80}}, color={192,192,192}),
            Line(points={{-80,-80},{-80,-20},{-80,2},{76,2}},  color={0,0,127})}));
    end P_InverterHeatPumpController;

    model PI_InverterHeatPumpController
      "PI-Controller for inverter controlled heat pumps"
      extends
        HeatPumpNSetController.BaseClasses.PartialInverterHeatPumpController(      PID(
          controllerType=Modelica.Blocks.Types.SimpleController.PI,
          Ti=T_I,
          final Ni=Ni));
      parameter Modelica.SIunits.Time T_I "Time constant of Integrator block";
      parameter Real Ni=0.9 "Ni*Ti is time constant of anti-windup compensation";
      annotation (Icon(graphics={
            Polygon(
              points={{-80,90},{-88,68},{-72,68},{-80,90}},
              lineColor={192,192,192},
              fillColor={192,192,192},
              fillPattern=FillPattern.Solid),
            Line(points={{-80,78},{-80,-90}}, color={192,192,192}),
            Polygon(
              points={{90,-80},{68,-72},{68,-88},{90,-80}},
              lineColor={192,192,192},
              fillColor={192,192,192},
              fillPattern=FillPattern.Solid),
            Line(points={{-90,-80},{82,-80}}, color={192,192,192}),
            Line(points={{-80,-80},{-80,-20},{-80,-20},{52,80}},
                                                               color={0,0,127})}));
    end PI_InverterHeatPumpController;

    model PID_InverterHeatPumpController
      "PID-Controller for inverter controlled heat pumps"
      extends
        HeatPumpNSetController.BaseClasses.PartialInverterHeatPumpController(      PID(
          controllerType=Modelica.Blocks.Types.SimpleController.PID,
          final Ti=T_I,
          final Td=T_D,
          final Ni=Ni,
          final Nd=Nd));
      parameter Modelica.SIunits.Time T_I "Time constant of Integrator block";
      parameter Modelica.SIunits.Time T_D "Time constant of Derivative block";
      parameter Real Ni=0.9 "Ni*Ti is time constant of anti-windup compensation";
      parameter Real Nd=10 "The higher Nd, the more ideal the derivative block";
      annotation (Icon(graphics={
            Line(points={{-78,-80},{-78,52},{-76,-52},{68,76}},color={0,0,127}),
            Polygon(
              points={{-80,90},{-88,68},{-72,68},{-80,90}},
              lineColor={192,192,192},
              fillColor={192,192,192},
              fillPattern=FillPattern.Solid),
            Line(points={{-80,78},{-80,-90}}, color={192,192,192}),
            Polygon(
              points={{90,-80},{68,-72},{68,-88},{90,-80}},
              lineColor={192,192,192},
              fillColor={192,192,192},
              fillPattern=FillPattern.Solid),
            Line(points={{-90,-80},{82,-80}}, color={192,192,192})}));
    end PID_InverterHeatPumpController;
  end HeatPumpNSetController;

  package HPFrosting "Package with models to account for possible frosting of a heat pump"

    package BaseClasses "Partial models for HPFrosting package"
      partial model partialIceFac "PartialIceFacCalculator"
        parameter Boolean use_reverse_cycle=true "If false, an eletrical heater will be used instead of reverse cycle method";
        parameter Modelica.SIunits.SpecificEnthalpy h_water_fusion=333.5e3 "Fusion enthalpy of water (Schmelzenthalpie)";
        parameter Real eta_hr=1 "Efficiency of used heating rod"
          annotation (Dialog(enable=not use_reverse_cycle));
        parameter Modelica.SIunits.Power P_el_hr=0 "Heating power of heating rod" annotation (Dialog(enable=not use_reverse_cycle));

        Modelica.Blocks.Interfaces.RealOutput P_el_add
          "Additional power required to defrost"       annotation (Placement(
              transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={0,-110}), iconTransformation(extent={{-10,-10},{10,10}},
              rotation=270,
              origin={2,-110})));
        Modelica.Blocks.Interfaces.RealInput relHum
          "Input relative humidity of outdoor air" annotation (Placement(
              transformation(extent={{-140,60},{-100,100}}), iconTransformation(
                extent={{-140,56},{-100,96}})));
        Interfaces.GenerationControlBus genConBus
          "Bus with the most relevant information for hp frosting calculation"
          annotation (Placement(transformation(extent={{-128,-20},{-88,20}}),
              iconTransformation(extent={{-130,-20},{-90,20}})));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
              Rectangle(
                extent={{-100,100},{100,-100}},
                lineColor={0,0,0},
                fillColor={215,215,215},
                fillPattern=FillPattern.Solid,
                lineThickness=0.5), Text(
                extent={{-76,102},{66,66}},
                lineColor={28,108,200},
                textString="%name%")}),                                Diagram(
              coordinateSystem(preserveAspectRatio=false)));
      end partialIceFac;
    end BaseClasses;

    model NoFrosting "Model for no frosting at all times"
      extends BaseClasses.partialIceFac(final use_reverse_cycle=true);
      Modelica.Blocks.Sources.Constant constZero(final k=0) "No energy  needed"
        annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=270,
            origin={0,-72})));
      Modelica.Blocks.Sources.BooleanConstant booleanConstant(final k=true)
        "Always heating" annotation (Placement(transformation(
            extent={{-10,10},{10,-10}},
            rotation=180,
            origin={-56,0})));
      Modelica.Blocks.Sources.Constant constOne(final k=1) "Always iceFac=1"
        annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=180,
            origin={-58,38})));
    equation
      connect(constZero.y, P_el_add)
        annotation (Line(points={{0,-83},{0,-110}}, color={0,0,127}));
      connect(booleanConstant.y, genConBus.hp_mode) annotation (Line(points={{-67,0},
              {-88,0},{-88,0},{-108,0}},       color={255,0,255}));
      connect(constOne.y, genConBus.iceFac) annotation (Line(points={{-69,38},{-90,
              38},{-90,0},{-108,0}},       color={0,0,127}), Text(
          string="%second",
          index=1,
          extent={{-6,3},{-6,3}},
          horizontalAlignment=TextAlignment.Right));
      annotation (Icon(graphics={Text(
              extent={{-68,-50},{80,48}},
              lineColor={0,0,0},
              textString="=1")}));
    end NoFrosting;
  end HPFrosting;

  package OnOffController "Package for models of simple on off controls"
    package BaseClasses
      partial model PartialOnOffController "Partial model for an on off controller"
        Modelica.Blocks.Interfaces.RealInput T_Top
          "Top layer temperature of the storage in distribution system"
          annotation (Placement(transformation(extent={{-140,40},{-100,80}}),
              iconTransformation(extent={{-120,60},{-100,80}})));
        Modelica.Blocks.Interfaces.BooleanOutput HP_On(start=true)
          "Turn the main the device of a HPS, the HP on or off" annotation (Placement(
              transformation(extent={{100,50},{120,70}}), iconTransformation(extent={
                  {100,56},{128,84}})));
        Modelica.Blocks.Interfaces.RealInput T_Set "Set point temperature"
          annotation (Placement(transformation(
                extent={{-20,-20},{20,20}},
              rotation=90,
              origin={0,-118}),                  iconTransformation(extent={{-10,-10},{10,10}},
              rotation=90,
              origin={0,-110})));
        Modelica.Blocks.Interfaces.RealInput T_bot
          "Supply temperature of the lower layers of the storage. Does not have to be the lowest layer, depending on comfort even the top may be selected"
          annotation (Placement(transformation(extent={{-140,-80},{-100,-40}}),
              iconTransformation(extent={{-120,-60},{-100,-40}})));
        Modelica.Blocks.Interfaces.BooleanOutput Auxilliar_Heater_On(start=true)
          "Turn the auxilliar heater (most times a heating rod) on or off"
          annotation (Placement(transformation(extent={{100,-70},{120,-50}}),
              iconTransformation(extent={{100,-64},{128,-36}})));
        Modelica.Blocks.Interfaces.RealInput T_oda "Ambient air temperature"
          annotation (Placement(transformation(
              extent={{-20,-20},{20,20}},
              rotation=270,
              origin={0,120}), iconTransformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={0,112})));
        Modelica.Blocks.Interfaces.RealOutput    Auxilliar_Heater_set(start=1)
          "Setpoint of the auxilliar heater"
          annotation (Placement(transformation(extent={{100,-90},{120,-70}}),
              iconTransformation(extent={{100,-100},{128,-72}})));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
              Rectangle(
                extent={{-100,100},{100,-100}},
                lineColor={0,0,0},
                fillColor={215,215,215},
                fillPattern=FillPattern.Solid,
                lineThickness=0.5)}), Diagram(coordinateSystem(preserveAspectRatio=
                  false)));
      end PartialOnOffController;
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
            Ellipse(
              extent={{-30.0,-30.0},{30.0,30.0}},
              lineColor={128,128,128},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid)}));
    end BaseClasses;

    model ConstantHysteresis
      "On-Off controller with a constant hysteresis"
      extends BaseClasses.PartialOnOffController;

      parameter Modelica.SIunits.TemperatureDifference Hysteresis = 10;
      parameter Modelica.SIunits.Time dt_hr = 20 * 60 "Seconds for regulation when hr should be activated: If lower set temperature is hurt for more than this time period";

      /******************************* Variables *******************************/

      Modelica.SIunits.Time t1(start=0) "Helper variable for hr algorithm";

    algorithm

       // For initialisation: activate both systems
       //when time > 1 then
       //  HP_On := true;
       //  Auxilliar_Heater_On :=true;
       //end when;

       // When upper temperature of storage tank is lower than lower hysteresis value, activate hp
       when T_Top < T_Set - Hysteresis/2 then
         HP_On := true;
         t1 :=time; // Start activation counter
       end when;
       // When second / lower temperature of storage tank is higher than upper hysteresis, deactivate hp
       when T_bot > T_Set + Hysteresis/2 then
         HP_On := false;
         Auxilliar_Heater_On := false;
         Auxilliar_Heater_set := 0;
       end when;

       // Activate hr in case temperature is below lower hysteresis and critical time period is passed
       when (T_Top < T_Set - Hysteresis/2) and time > (t1 + dt_hr) and HP_On then
         Auxilliar_Heater_On :=true;
         Auxilliar_Heater_set := 1;
       end when;

      annotation (Icon(graphics={     Polygon(
                points={{-65,89},{-73,67},{-57,67},{-65,89}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),Line(points={{-65,67},{-65,-81}},
              color={192,192,192}),Line(points={{-90,-70},{82,-70}}, color={192,
              192,192}),Polygon(
                points={{90,-70},{68,-62},{68,-78},{90,-70}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
                                Text(
                extent={{-65,93},{-12,75}},
                lineColor={160,160,164},
                textString="y"),Line(
                points={{-80,-70},{30,-70}},
                thickness=0.5),Line(
                points={{-50,10},{80,10}},
                thickness=0.5),Line(
                points={{-50,10},{-50,-70}},
                thickness=0.5),Line(
                points={{30,10},{30,-70}},
                thickness=0.5),Line(
                points={{-10,-65},{0,-70},{-10,-75}},
                thickness=0.5),Line(
                points={{-10,15},{-20,10},{-10,5}},
                thickness=0.5),Line(
                points={{-55,-20},{-50,-30},{-44,-20}},
                thickness=0.5),Line(
                points={{25,-30},{30,-19},{35,-30}},
                thickness=0.5),Text(
                extent={{-99,2},{-70,18}},
                lineColor={160,160,164},
                textString="true"),Text(
                extent={{-98,-87},{-66,-73}},
                lineColor={160,160,164},
                textString="false"),Text(
                extent={{19,-87},{44,-70}},
                lineColor={0,0,0},
                textString="uHigh"),Text(
                extent={{-63,-88},{-38,-71}},
                lineColor={0,0,0},
                textString="uLow"),Line(points={{-69,10},{-60,10}}, color={160,
              160,164})}));
    end ConstantHysteresis;

  model ConstantHysteresis2
      "On-Off controller with a constant hysteresis"
      Modelica.Blocks.Interfaces.BooleanOutput heating_On(start=true)
      "Turn the main the device of a HPS, the HP on or off" annotation (Placement(
          transformation(extent={{100,-10},{120,10}}), iconTransformation(extent={
              {100,56},{128,84}})));
      Modelica.Blocks.Interfaces.RealInput T_min "Set point temperature"
        annotation (Placement(transformation(
              extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-120,-50}),                iconTransformation(extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-110,-40})));
      Modelica.Blocks.Interfaces.RealInput T_Room
      "Supply temperature of the lower layers of the storage. Does not have to be the lowest layer, depending on comfort even the top may be selected"
      annotation (Placement(transformation(extent={{-140,-20},{-100,20}}),
          iconTransformation(extent={{-120,0},{-100,20}})));
      Modelica.Blocks.Interfaces.RealInput T_max "Ambient air temperature"
        annotation (Placement(transformation(
            extent={{-20,-20},{20,20}},
            rotation=0,
            origin={-120,80}),
                             iconTransformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={-110,60})));


      parameter Modelica.SIunits.Time dt_hr = 15 * 60 "minimum time span between on/off";

      /******************************* Variables *******************************/

      Modelica.SIunits.Time t1(start=0) "Helper variable for hr algorithm";

  algorithm

       // When lower temperature reached, activate heating mode
       when T_Room < T_min and time > (t1 + dt_hr) then
         heating_On := true;
         t1 :=time; // Start activation counter
       end when;
       // When higher temperature reached, deactivate heating mode
       when T_Room > T_max and time > (t1 + dt_hr) then
         heating_On := false;
         t1 :=time; // Start activation counter
       end when;

      annotation (Icon(graphics={     Polygon(
                points={{-65,89},{-73,67},{-57,67},{-65,89}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),Line(points={{-65,67},{-65,-81}},
              color={192,192,192}),Line(points={{-90,-70},{82,-70}}, color={192,
              192,192}),Polygon(
                points={{90,-70},{68,-62},{68,-78},{90,-70}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
                                Text(
                extent={{-65,93},{-12,75}},
                lineColor={160,160,164},
                textString="y"),Line(
                points={{-80,-70},{30,-70}},
                thickness=0.5),Line(
                points={{-50,10},{80,10}},
                thickness=0.5),Line(
                points={{-50,10},{-50,-70}},
                thickness=0.5),Line(
                points={{30,10},{30,-70}},
                thickness=0.5),Line(
                points={{-10,-65},{0,-70},{-10,-75}},
                thickness=0.5),Line(
                points={{-10,15},{-20,10},{-10,5}},
                thickness=0.5),Line(
                points={{-55,-20},{-50,-30},{-44,-20}},
                thickness=0.5),Line(
                points={{25,-30},{30,-19},{35,-30}},
                thickness=0.5),Text(
                extent={{-99,2},{-70,18}},
                lineColor={160,160,164},
                textString="true"),Text(
                extent={{-98,-87},{-66,-73}},
                lineColor={160,160,164},
                textString="false"),Text(
                extent={{19,-87},{44,-70}},
                lineColor={0,0,0},
                textString="uHigh"),Text(
                extent={{-63,-88},{-38,-71}},
                lineColor={0,0,0},
                textString="uLow"),Line(points={{-69,10},{-60,10}}, color={160,
              160,164})}));
  end ConstantHysteresis2;

    model DegreeMinuteController
      "OnOff controller based on degree minute approach"
      extends BaseClasses.PartialOnOffController;

      parameter Real DegreeMinute_HP_on(unit="K.min")=-60 "Degree minute when HP is turned on";
      parameter Real DegreeMinute_HP_off(unit="K.min")=0 "Degree minute when HP is turned off";
      parameter Real DegreeMinute_AuxHeater_on(unit="K.min")=-600 "Degree minute when auxilliar heater is turned on";
      parameter Real DegreeMinuteReset(unit="K.min")=300 "Degree minute when the value is reset. Value based on additional paper, to avoid errors in summer periods";
      parameter Modelica.SIunits.TemperatureDifference delta_T_AuxHeater_off=1 "Temperature difference when to turn off the auxilliar heater";
      parameter Modelica.SIunits.TemperatureDifference delta_T_reset=10 "Temperature difference when to reset the sum to 0";

      Real DegreeMinute(start=0) "Current degree minute value";
      Modelica.SIunits.TemperatureDifference delta_T = T_Top-T_Set;

    algorithm
      when DegreeMinute < DegreeMinute_HP_on then
        HP_On := true;
      end when;

      when DegreeMinute > DegreeMinute_HP_off then
        HP_On := false;
      end when;

      when DegreeMinute < DegreeMinute_AuxHeater_on then
        Auxilliar_Heater_On := true;
        Auxilliar_Heater_set := 1;
      end when;

      when delta_T > delta_T_AuxHeater_off then
        Auxilliar_Heater_On := false;
        Auxilliar_Heater_set := 0;
      end when;

    equation
      // TODO: Check why the simple hys wont work?!
      //HP_On = (not pre(HP_On) and DegreeMinute > DegreeMinute_HP_on) or (pre(HP_On) and DegreeMinute < DegreeMinute_HP_off);
      //Auxilliar_Heater_On = (not pre(Auxilliar_Heater_On) and DegreeMinute > DegreeMinute_AuxHeater_on) or (pre(Auxilliar_Heater_On) and delta_T < delta_T_AuxHeater_off);
      der(DegreeMinute) = delta_T /60;
      when (delta_T > delta_T_reset) then
        reinit(DegreeMinute, 0);
      elsewhen (DegreeMinute > DegreeMinuteReset) then
        reinit(DegreeMinute, 0);
      end when;
      annotation (Icon(graphics={Text(
              extent={{-44,58},{40,-60}},
              lineColor={0,0,0},
              textString="°C
_______

 minute")}),     Documentation(info="<html>
<p style=\"margin-left: 30px;\">The method is based on the following paper: https://www.sciencedirect.com/science/article/abs/pii/S037877881300282X</p>
<p><br>&bull; Turn on the heat pump when the sum is lower than &minus;60 degree&ndash;minute.</p>
<p>&bull; Turn off the heat pump when the sum goes back to 0 degree&ndash;minute.</p>
<p>&bull; Turn on the electrical auxiliary heater when the sum is lower than &minus;600 degree&ndash;minute.</p>
<p>&bull; Turn off the electrical auxiliary heater when the supply temperature is 1 K higher than the required temperature.</p>
<p>&bull; Reset the sum to zero whenever the supply temperature is 10 K higher than the required temperature.</p>
</html>"));
    end DegreeMinuteController;

    model FloatingHysteresis
      "OnOff controller based on the theory of floating hysteresis"
      extends BaseClasses.PartialOnOffController;

      parameter Modelica.SIunits.TemperatureDifference Hysteresis_max = 10 "Maximum hysteresis";
      parameter Modelica.SIunits.TemperatureDifference Hysteresis_min = 10 "Minimum hysteresis";
      parameter Modelica.SIunits.Time time_factor = 20 "The time which should be spent to have the floating hysteresis equal to the average of maximum and minimum hysteresis.";
      parameter Modelica.SIunits.Time dt_hr = 20 * 60 "Seconds for regulation when hr should be activated: If lower set temperature is hurt for more than this time period";

      /******************************* Variables *******************************/

      Modelica.SIunits.Time t1(start=0) "Helper variable for hr algorithm";
      Modelica.SIunits.TemperatureDifference Hysteresis_floating = Hysteresis_min + (Hysteresis_max-Hysteresis_min)/(1+(t1/time_factor));

    algorithm

       // For initialisation: activate both systems
       //when time > 1 then
       //  HP_On := true;
       //  Auxilliar_Heater_On :=true;
       //end when;

       // When upper temperature of storage tank is lower than lower hysteresis value, activate hp
       when T_Top < T_Set - Hysteresis_floating/2 then
         HP_On := true;
         t1 :=time; // Start activation counter
       end when;
       // When second / lower temperature of storage tank is higher than upper hysteresis, deactivate hp
       when T_bot > T_Set + Hysteresis_floating/2 then
         HP_On := false;
         Auxilliar_Heater_On := false;
         Auxilliar_Heater_set := 0;
       end when;

       // Activate hr in case temperature is below lower hysteresis and critical time period is passed
       when (T_Top < T_Set - Hysteresis_floating/2) and time > (t1 + dt_hr) and HP_On then
         Auxilliar_Heater_On :=true;
         Auxilliar_Heater_set := 1;
       end when;

      annotation (Icon(graphics={
                               Line(
                points={{-50,48},{80,48}},
                thickness=0.5),Line(
                points={{-10,53},{-20,48},{-10,43}},
                thickness=0.5),Line(
                points={{25,8},{30,19},{35,8}},
                thickness=0.5),Line(
                points={{30,48},{30,-32}},
                thickness=0.5),Line(
                points={{-10,-27},{0,-32},{-10,-37}},
                thickness=0.5), Line(
                points={{-80,-32},{30,-32}},
                thickness=0.5),Line(
                points={{-50,48},{-50,-32}},
                thickness=0.5),Line(
                points={{-55,18},{-50,8},{-44,18}},
                thickness=0.5),Text(
                extent={{-99,40},{-70,56}},
                lineColor={160,160,164},
                textString="true"),Text(
                extent={{-98,-49},{-66,-35}},
                lineColor={160,160,164},
                textString="false"),           Line(points={{-64,86},{-65,-43}},
              color={192,192,192}),Line(points={{-69,48},{-60,48}}, color={160,
              160,164}),Polygon(
                points={{90,-32},{68,-24},{68,-40},{90,-32}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
                                   Line(points={{-90,-32},{82,-32}}, color={192,
              192,192}),            Text(
                extent={{19,-49},{44,-32}},
                lineColor={0,0,0},
                textString="uHigh"),Text(
                extent={{-63,-50},{-38,-33}},
                lineColor={0,0,0},
                textString="uLow"),
                        Polygon(
                points={{11,0},{-11,8},{-11,-8},{11,0}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid,
              origin={-65,84},
              rotation=90),         Text(
                extent={{-87,-84},{84,-54}},
                lineColor={0,0,0},
              textString="uLow, uHigh=f(h_max, h_min, time)")}));
    end FloatingHysteresis;

    block StorageHysteresis "On-off controller for a storage control. "
      extends Modelica.Blocks.Icons.PartialBooleanBlock;
      Modelica.Blocks.Interfaces.RealInput T_set "Set temperature"
        annotation (Placement(transformation(extent={{-140,100},{-100,60}})));
      Modelica.Blocks.Interfaces.RealInput T_top
        "Connector of Real input signal used as measurement signal of upper level storage temperature"
        annotation (Placement(transformation(extent={{-140,20},{-100,-20}})));
      Modelica.Blocks.Interfaces.BooleanOutput y
        "Connector of Real output signal used as actuator signal"
        annotation (Placement(transformation(extent={{100,-10},{120,10}})));

      parameter Real bandwidth(start=0.1) "Bandwidth around reference signal";
      parameter Boolean pre_y_start=false "Value of pre(y) at initial time";

      Modelica.Blocks.Interfaces.RealInput T_bot
        "Connector of Real input signal used as measurement signal of bottom temperature of storage"
        annotation (Placement(transformation(extent={{-140,-60},{-100,-100}})));
    initial equation
      pre(y) = pre_y_start;
    equation
      y = pre(y) and (T_bot < T_set + bandwidth/2) or (T_top < T_set - bandwidth/2);
      annotation (Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,
                -100},{100,100}}), graphics={
            Text(
              extent={{-92,74},{44,44}},
              textString="reference"),
            Text(
              extent={{-94,-52},{-34,-74}},
              textString="u"),
            Line(points={{-76,-32},{-68,-6},{-50,26},{-24,40},{-2,42},{16,36},{32,28},{48,12},{58,-6},{68,-28}},
              color={0,0,127}),
            Line(points={{-78,-2},{-6,18},{82,-12}},
              color={255,0,0}),
            Line(points={{-78,12},{-6,30},{82,0}}),
            Line(points={{-78,-16},{-6,4},{82,-26}}),
            Line(points={{-82,-18},{-56,-18},{-56,-40},{64,-40},{64,-20},{90,-20}},
              color={255,0,255})}), Documentation(info="<html>
<p>The block StorageHysteresis sets the output signal <b>y</b> to <b>true</b> when the input signal <b>T_top</b> falls below the <b>T_set</b> signal minus half of the bandwidth and sets the output signal <b>y</b> to <b>false</b> when the input signal <b>T_bot</b> exceeds the <b>T_set</b> signal plus half of the bandwidth.</p>
<p>This control ensure that the whole storage has the required temperature. If you just want to control one layer, apply the same Temperature to both <b>T_top</b> and <b>T_bot</b>.</p>
</html>"));
    end StorageHysteresis;

    model AlternativeBivalentOnOffController "Controlls an alternative bivalent heat pump system with storages"
      extends BaseClasses.PartialOnOffController;
      StorageHysteresis storageHysteresis(final bandwidth=hysteresis, final
          pre_y_start=true)
        annotation (Placement(transformation(extent={{-40,22},{0,62}})));
      Modelica.Blocks.Logical.GreaterEqualThreshold greaterEqualT_biv(threshold=
            T_biv) annotation (Placement(transformation(extent={{20,80},{40,100}})));
      parameter Modelica.SIunits.Temperature T_biv=271.15 "Bivalent temperature";
      Modelica.Blocks.Logical.And greaterEqualT_biv1
        annotation (Placement(transformation(extent={{60,60},{80,80}})));
      Modelica.Blocks.Logical.And greaterEqualT_biv2
        annotation (Placement(transformation(extent={{60,-60},{80,-40}})));
      Modelica.Blocks.Logical.Not greaterEqualT_biv3 annotation (Placement(
            transformation(
            extent={{-10,-10},{10,10}},
            rotation=270,
            origin={50,-10})));
      parameter Real hysteresis=10 "Bandwidth around reference signal";
      Modelica.Blocks.Math.BooleanToReal
                                 or3(final realTrue=1, final realFalse=0)
                                     annotation (Placement(transformation(
            extent={{-6,-6},{6,6}},
            rotation=0,
            origin={82,-80})));
    equation
      connect(T_Set, storageHysteresis.T_set) annotation (Line(points={{0,-118},{
              -56,-118},{-56,58},{-44,58}},             color={0,0,127}));
      connect(T_Top, storageHysteresis.T_top) annotation (Line(points={{-120,60},{
              -74,60},{-74,42},{-44,42}},
                                        color={0,0,127}));
      connect(T_bot, storageHysteresis.T_bot) annotation (Line(points={{-120,-60},{
              -50,-60},{-50,26},{-44,26}},   color={0,0,127}));
      connect(T_oda, greaterEqualT_biv.u)
        annotation (Line(points={{0,120},{0,90},{18,90}}, color={0,0,127}));
      connect(HP_On, greaterEqualT_biv1.y) annotation (Line(points={{110,60},{96,60},
              {96,70},{81,70}}, color={255,0,255}));
      connect(greaterEqualT_biv.y, greaterEqualT_biv1.u1) annotation (Line(points={
              {41,90},{52,90},{52,70},{58,70}}, color={255,0,255}));
      connect(storageHysteresis.y, greaterEqualT_biv1.u2) annotation (Line(points={
              {2,42},{26.85,42},{26.85,62},{58,62}}, color={255,0,255}));
      connect(Auxilliar_Heater_On, greaterEqualT_biv2.y) annotation (Line(points={{
              110,-60},{96,-60},{96,-50},{81,-50}}, color={255,0,255}));
      connect(greaterEqualT_biv.y, greaterEqualT_biv3.u)
        annotation (Line(points={{41,90},{50,90},{50,2}}, color={255,0,255}));
      connect(greaterEqualT_biv3.y, greaterEqualT_biv2.u1)
        annotation (Line(points={{50,-21},{50,-50},{58,-50}}, color={255,0,255}));
      connect(storageHysteresis.y, greaterEqualT_biv2.u2) annotation (Line(points={
              {2,42},{28,42},{28,-58},{58,-58}}, color={255,0,255}));
      connect(Auxilliar_Heater_set, or3.y)
        annotation (Line(points={{110,-80},{88.6,-80}}, color={0,0,127}));
      connect(greaterEqualT_biv2.y, or3.u) annotation (Line(points={{81,-50},{82,
              -50},{82,-70},{74.8,-70},{74.8,-80}}, color={255,0,255}));
    end AlternativeBivalentOnOffController;

    model BivalentParallelOnOffController
      "Controlls an alternative bivalent heat pump system with storages"
      extends BaseClasses.PartialOnOffController;
      StorageHysteresis storageHysteresis(final bandwidth=hysteresis, final
          pre_y_start=true)
        annotation (Placement(transformation(extent={{-40,22},{0,62}})));
      Modelica.Blocks.Logical.GreaterEqualThreshold greaterEqualT_biv(threshold=
            T_biv) annotation (Placement(transformation(extent={{20,80},{40,100}})));
      parameter Modelica.SIunits.Temperature T_biv=271.15 "Bivalent temperature";
      Modelica.Blocks.Logical.And greaterEqualT_biv2
        annotation (Placement(transformation(extent={{60,-60},{80,-40}})));
      Modelica.Blocks.Logical.Not greaterEqualT_biv3 annotation (Placement(
            transformation(
            extent={{-10,-10},{10,10}},
            rotation=270,
            origin={50,-10})));
      parameter Real hysteresis=10 "Bandwidth around reference signal";
      Modelica.Blocks.Math.BooleanToReal
                                 or3(final realTrue=1, final realFalse=0)
                                     annotation (Placement(transformation(
            extent={{-6,-6},{6,6}},
            rotation=0,
            origin={82,-80})));
    equation
      connect(T_Set, storageHysteresis.T_set) annotation (Line(points={{0,-118},{
              -56,-118},{-56,58},{-44,58}},             color={0,0,127}));
      connect(T_Top, storageHysteresis.T_top) annotation (Line(points={{-120,60},{
              -74,60},{-74,42},{-44,42}},
                                        color={0,0,127}));
      connect(T_bot, storageHysteresis.T_bot) annotation (Line(points={{-120,-60},{
              -50,-60},{-50,26},{-44,26}},   color={0,0,127}));
      connect(T_oda, greaterEqualT_biv.u)
        annotation (Line(points={{0,120},{0,90},{18,90}}, color={0,0,127}));
      connect(Auxilliar_Heater_On, greaterEqualT_biv2.y) annotation (Line(points={{
              110,-60},{96,-60},{96,-50},{81,-50}}, color={255,0,255}));
      connect(greaterEqualT_biv.y, greaterEqualT_biv3.u)
        annotation (Line(points={{41,90},{50,90},{50,2}}, color={255,0,255}));
      connect(greaterEqualT_biv3.y, greaterEqualT_biv2.u1)
        annotation (Line(points={{50,-21},{50,-50},{58,-50}}, color={255,0,255}));
      connect(storageHysteresis.y, greaterEqualT_biv2.u2) annotation (Line(points={
              {2,42},{28,42},{28,-58},{58,-58}}, color={255,0,255}));
      connect(Auxilliar_Heater_set, or3.y)
        annotation (Line(points={{110,-80},{88.6,-80}}, color={0,0,127}));
      connect(greaterEqualT_biv2.y, or3.u) annotation (Line(points={{81,-50},{82,
              -50},{82,-70},{74.8,-70},{74.8,-80}}, color={255,0,255}));
      connect(storageHysteresis.y, HP_On) annotation (Line(points={{2,42},{68,
              42},{68,60},{110,60}}, color={255,0,255}));
    end BivalentParallelOnOffController;


    model ConstantHysteresisTimeBasedHR
      "On-Off controller with a constant hysteresis for a time-based hr control"
      extends
        MA_Pell_SingleFamilyHouse.Components.Control.OnOffController.BaseClasses.PartialOnOffController;

      parameter Modelica.SIunits.TemperatureDifference Hysteresis = 10;
      parameter Modelica.SIunits.Time dt_hr  "Seconds for regulation when hr should be activated: If lower set temperature is hurt for more than this time period";
      parameter Real addSet_dt_hr=1 "Each time dt_hr passes, the output of the heating rod is increased by this amount in percentage. Maximum and default is 100 (on-off hr)%";

      MA_Pell_SingleFamilyHouse.Components.Control.OnOffController.StorageHysteresis
        storageHysteresis(final bandwidth=Hysteresis, final pre_y_start=true)
        annotation (Placement(transformation(extent={{-58,18},{-18,58}})));
      MA_Pell_SingleFamilyHouse.Components.Control.TriggerTime triggerTime
        annotation (Placement(transformation(extent={{-32,-88},{-12,-68}})));
      Modelica.Blocks.Sources.RealExpression realExpression(y=min(floor((time -
            triggerTime.y)/dt_hr)*addSet_dt_hr, 1))
        annotation (Placement(transformation(extent={{6,-70},{26,-50}})));
      Modelica.Blocks.Logical.GreaterThreshold greaterThreshold(threshold=Modelica.Constants.eps)
        annotation (Placement(transformation(extent={{70,-68},{86,-52}})));

      Modelica.Blocks.Logical.Switch         switch1
        annotation (Placement(transformation(extent={{34,-86},{48,-72}})));
      Modelica.Blocks.Sources.Constant       const(final k=0)
        annotation (Placement(transformation(extent={{14,-98},{24,-88}})));
      Modelica.Blocks.Logical.OnOffController AuxilliarHeaterHys(bandwidth=
            Hysteresis/2, pre_y_start=true)
        "Generates the on/off signal depending on the temperature inputs"
        annotation (Placement(transformation(extent={{-62,-70},{-42,-50}})));
      Modelica.Blocks.Math.Add               add1(k1=-1)
        annotation (Placement(transformation(extent={{-7,-7},{7,7}},
            rotation=90,
            origin={-69,-95})));
      Modelica.Blocks.Sources.Constant       const2(final k=Hysteresis/4)
        annotation (Placement(transformation(extent={{-98,-118},{-88,-108}})));
    equation
      connect(T_Top, storageHysteresis.T_top) annotation (Line(points={{-120,60},{
              -86,60},{-86,38},{-62,38}},
                                      color={0,0,127}));
      connect(T_Set, storageHysteresis.T_set) annotation (Line(points={{0,-118},{0,
              -20},{-80,-20},{-80,54},{-62,54}},
                                            color={0,0,127}));
      connect(storageHysteresis.y, HP_On) annotation (Line(points={{-16,38},{30,38},
              {30,60},{110,60}}, color={255,0,255}));
      connect(greaterThreshold.y, Auxilliar_Heater_On)
        annotation (Line(points={{86.8,-60},{110,-60}},
                                                      color={255,0,255}));
      connect(const.y, switch1.u3) annotation (Line(points={{24.5,-93},{28,-93},{28,
              -84.6},{32.6,-84.6}}, color={0,0,127}));
      connect(switch1.y, Auxilliar_Heater_set) annotation (Line(points={{48.7,-79},
              {54,-79},{54,-80},{110,-80}}, color={0,0,127}));
      connect(switch1.y, greaterThreshold.u) annotation (Line(points={{48.7,-79},{
              56,-79},{56,-60},{68.4,-60}}, color={0,0,127}));
      connect(realExpression.y, switch1.u1) annotation (Line(points={{27,-60},{30,
              -60},{30,-73.4},{32.6,-73.4}}, color={0,0,127}));
      connect(T_Top, storageHysteresis.T_bot) annotation (Line(points={{-120,60},{
              -92,60},{-92,22},{-62,22}}, color={0,0,127}));
      connect(T_Top, AuxilliarHeaterHys.u) annotation (Line(points={{-120,60},{-92,
              60},{-92,-66},{-64,-66}}, color={0,0,127}));
      connect(const2.y, add1.u1) annotation (Line(points={{-87.5,-113},{-74,-113},{
              -74,-103.4},{-73.2,-103.4}}, color={0,0,127}));
      connect(add1.y, AuxilliarHeaterHys.reference) annotation (Line(points={{-69,
              -87.3},{-69,-54},{-64,-54}}, color={0,0,127}));
      connect(T_Set, add1.u2) annotation (Line(points={{0,-118},{0,-104},{-20,-104},
              {-20,-103.4},{-64.8,-103.4}}, color={0,0,127}));
      connect(AuxilliarHeaterHys.y, triggerTime.u) annotation (Line(points={{-41,
              -60},{-36,-60},{-36,-78},{-34,-78}}, color={255,0,255}));
      connect(AuxilliarHeaterHys.y, switch1.u2) annotation (Line(points={{-41,-60},
              {-28,-60},{-28,-58},{4,-58},{4,-79},{32.6,-79}}, color={255,0,255}));
      annotation (Icon(graphics={     Polygon(
                points={{-65,89},{-73,67},{-57,67},{-65,89}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),Line(points={{-65,67},{-65,-81}},
              color={192,192,192}),Line(points={{-90,-70},{82,-70}}, color={192,
              192,192}),Polygon(
                points={{90,-70},{68,-62},{68,-78},{90,-70}},
                lineColor={192,192,192},
                fillColor={192,192,192},
                fillPattern=FillPattern.Solid),
                                Text(
                extent={{-65,93},{-12,75}},
                lineColor={160,160,164},
                textString="y"),Line(
                points={{-80,-70},{30,-70}},
                thickness=0.5),Line(
                points={{-50,10},{80,10}},
                thickness=0.5),Line(
                points={{-50,10},{-50,-70}},
                thickness=0.5),Line(
                points={{30,10},{30,-70}},
                thickness=0.5),Line(
                points={{-10,-65},{0,-70},{-10,-75}},
                thickness=0.5),Line(
                points={{-10,15},{-20,10},{-10,5}},
                thickness=0.5),Line(
                points={{-55,-20},{-50,-30},{-44,-20}},
                thickness=0.5),Line(
                points={{25,-30},{30,-19},{35,-30}},
                thickness=0.5),Text(
                extent={{-99,2},{-70,18}},
                lineColor={160,160,164},
                textString="true"),Text(
                extent={{-98,-87},{-66,-73}},
                lineColor={160,160,164},
                textString="false"),Text(
                extent={{19,-87},{44,-70}},
                lineColor={0,0,0},
                textString="uHigh"),Text(
                extent={{-63,-88},{-38,-71}},
                lineColor={0,0,0},
                textString="uLow"),Line(points={{-69,10},{-60,10}}, color={160,
              160,164})}));
    end ConstantHysteresisTimeBasedHR;
  end OnOffController;

  package RuleBasedController "Package for all blocks controlling the system by fixed rules"
    model RuleBasedStorageSelection
      "Choose which storage should be loaded - DHW has priority"

      Modelica.Blocks.Interfaces.BooleanInput DemandDHW
        annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));

      Modelica.Blocks.Interfaces.BooleanOutput DHW_OnOff
        annotation (Placement(transformation(extent={{100,42},{120,62}})));
      Modelica.Blocks.Interfaces.BooleanOutput Buffer_OnOff
        annotation (Placement(transformation(extent={{100,-60},{120,-40}})));
    equation
      // DHW demand has always priority
      if DemandDHW then
        DHW_OnOff = true;
        Buffer_OnOff = false;
      else
        DHW_OnOff = false;
        Buffer_OnOff = true;
      end if;

      annotation (Icon(graphics={
            Rectangle(
              extent={{-100,-6},{100,-94}},
              lineColor={28,108,200},
              pattern=LinePattern.Dash,
              lineThickness=0.5,
              fillColor={215,215,215},
              fillPattern=FillPattern.Solid),
            Rectangle(
              extent={{-100,94},{100,6}},
              lineColor={28,108,200},
              pattern=LinePattern.Dash,
              lineThickness=0.5,
              fillColor={215,215,215},
              fillPattern=FillPattern.Solid),
            Text(
              extent={{-114,-10},{-6,-38}},
              lineColor={238,46,47},
              textString="T_Top"),
            Text(
              extent={{-112,98},{20,60}},
              lineColor={238,46,47},
              textString="T_Top"),
            Text(
              extent={{-78,42},{80,-4}},
              lineColor={217,67,180},
              textString="DHW"),
            Text(
              extent={{-64,-54},{66,-96}},
              lineColor={217,67,180},
              textString="Buffer")}));
    end RuleBasedStorageSelection;
  end RuleBasedController;

  package SecurityControls "Package with security controls for Integrated HPS"

    model AntiLegionellaControl "Control to avoid Legionella in the DHW"
      extends BaseClasses.PartialTSet_DHW_Control;
      parameter Modelica.Media.Interfaces.Types.Temperature T_DHW
        "Constant TSet DHW output value";
      parameter Modelica.SIunits.ThermodynamicTemperature TLegMin=333.15
        "Temperature at which the legionella in DWH dies";
      parameter Real percentageDeath=0.999 "Specify the percentage of legionella you want to kill. 100 Percent would be impossible, as the model is based on exponential growth/death";
      parameter Modelica.SIunits.Time triggerEvery "Time passed before next disinfection. Each day would be 86400 s"
        annotation (Dialog(enable=weekly));
      parameter Boolean aux_for_desinfection = true "Use aux heater for desinfection";
      Modelica.SIunits.Time minTimeAntLeg(displayUnit="min")=get_minTimeAntLeg_for_TLegMin(fitMinLegTime.y[1], percentageDeath)
        "Minimal duration of antilegionella control to ensure correct disinfection";
      function get_minTimeAntLeg_for_TLegMin
        input Modelica.SIunits.Temperature timeAtNinetyPercent;
        input Real percentageDeath;
        output Modelica.SIunits.Time minTimeAntLeg;
      algorithm
        minTimeAntLeg := log(1-percentageDeath) / log(1-0.9) * timeAtNinetyPercent * 3600;
      end get_minTimeAntLeg_for_TLegMin;
      AixLib.Utilities.Logical.SmoothSwitch switchTLeg
        "Switch to Legionalla control if needed"
        annotation (Placement(transformation(extent={{64,-6},{78,8}})));

      Modelica.Blocks.Sources.Constant constTLegMin(final k=TLegMin)
        "Temperature at which the legionella in DWH dies"
        annotation (Placement(transformation(extent={{-88,-84},{-70,-66}})));
      Modelica.Blocks.Sources.Constant const(final k=T_DHW)
        annotation (Placement(transformation(extent={{-6,78},{14,98}})));
      Modelica.Blocks.Logical.GreaterEqual
                                   TConLessTLegMin
        "Compare if current TCon is smaller than the minimal TLeg"
        annotation (Placement(transformation(extent={{-80,-32},{-60,-12}})));
      Modelica.Blocks.Logical.Timer timeAntiLeg "Time in which legionella will die"
        annotation (Placement(transformation(extent={{-30,-32},{-10,-12}})));
      Modelica.Blocks.Logical.Greater
                                   greaterThreshold
        annotation (Placement(transformation(extent={{4,-30},{18,-14}})));
      Modelica.Blocks.Logical.Pre pre1
        annotation (Placement(transformation(extent={{-54,-28},{-42,-16}})));
      Modelica.Blocks.MathInteger.TriggeredAdd triggeredAdd(
        use_reset=true,
        use_set=false,
        y_start=0)
                  "See info of model for description"
        annotation (Placement(transformation(extent={{-20,22},{-8,34}})));
      Modelica.Blocks.Sources.IntegerConstant intConPluOne(final k=1)
        "Value for counting"
        annotation (Placement(transformation(extent={{-44,22},{-32,34}})));
      Modelica.Blocks.Math.IntegerToReal intToReal "Converts Integer to Real"
        annotation (Placement(transformation(extent={{2,22},{14,34}})));
      Modelica.Blocks.Logical.LessThreshold    lessThreshold(final threshold=1)
        "Checks if value is less than one"
        annotation (Placement(transformation(extent={{26,18},{46,38}})));

      Modelica.Blocks.Sources.BooleanExpression triggerControl(y=((time - t1) >
            triggerEvery))
        annotation (Placement(transformation(extent={{-48,-6},{-28,14}})));

      Modelica.Blocks.Logical.Not not2
        annotation (Placement(transformation(extent={{60,-56},{72,-44}})));

      Modelica.Blocks.Sources.RealExpression realExpression(y=minTimeAntLeg)
        annotation (Placement(transformation(extent={{-30,-58},{-10,-38}})));
      Modelica.Blocks.Logical.And and1
        annotation (Placement(transformation(extent={{78,-64},{90,-52}})));
      Modelica.Blocks.Sources.BooleanConstant booleanConstant(final k=
            aux_for_desinfection)
        "Temperature at which the legionella in DWH dies"
        annotation (Placement(transformation(extent={{54,-92},{72,-74}})));
    protected
      Modelica.SIunits.Time t1 "Helper variable for control";
      Modelica.SIunits.Temp_C TLegMinDegC = TLegMin - 273.15;
      Modelica.Blocks.Tables.CombiTable1D fitMinLegTime(table=[45.5505451608561,62.916073325099134;
            48.78942881500426,7.736506444512433; 51.23771705478529,1.7687971042538275;
            53.542872526585,0.47986000155581393; 55.85049580472921,0.16470935490617822;
            58.450217615650374,0.07001663558934895; 62.20891102436398,0.028517297027731203;
            65.03006236819671,0.017814514615367875; 68.72055458338941,0.010893105323934898;
            73.06411809575089,0.007255730019232521; 75.88841028402207,0.006114735966220416;
            78.13366536545968,0.005494625286920662],
            u={TLegMinDegC});

    algorithm
      when greaterThreshold.y then
        t1 := time;
      end when;
    equation
      connect(switchTLeg.u3, constTLegMin.y) annotation (Line(points={{62.6,-4.6},{52,
              -4.6},{52,-75},{-69.1,-75}},color={0,0,127}));
      connect(switchTLeg.y, TSet_DHW) annotation (Line(points={{78.7,1},{92,1},{92,0},
              {110,0}},            color={0,0,127}));
      connect(const.y, switchTLeg.u1) annotation (Line(points={{15,88},{56,88},{56,6.6},
              {62.6,6.6}},        color={0,0,127}));
      connect(timeAntiLeg.u,pre1. y)
        annotation (Line(points={{-32,-22},{-41.4,-22}},
                                                     color={255,0,255}));
      connect(TConLessTLegMin.y,pre1. u)
        annotation (Line(points={{-59,-22},{-55.2,-22}},
                                                     color={255,0,255}));
      connect(greaterThreshold.y,triggeredAdd. reset) annotation (Line(points={{18.7,
              -22},{22,-22},{22,12},{-10.4,12},{-10.4,20.8}},color={255,0,255}));
      connect(intToReal.u,triggeredAdd. y)
        annotation (Line(points={{0.8,28},{-6.8,28}}, color={255,127,0}));
      connect(intConPluOne.y,triggeredAdd. u)
        annotation (Line(points={{-31.4,28},{-22.4,28}}, color={255,127,0}));
      connect(intToReal.y,lessThreshold. u) annotation (Line(points={{14.6,28},{24,28}},
                                    color={0,0,127}));
      connect(constTLegMin.y, TConLessTLegMin.u2) annotation (Line(points={{-69.1,-75},
              {-50,-75},{-50,-50},{-100,-50},{-100,-30},{-82,-30}}, color={0,0,127}));
      connect(sigBusDistr.T_StoDHW_bot, TConLessTLegMin.u1) annotation (Line(
          points={{-99.93,-0.935},{-94,-0.935},{-94,-22},{-82,-22}},
          color={255,204,51},
          thickness=0.5), Text(
          string="%first",
          index=-1,
          extent={{-6,3},{-6,3}},
          horizontalAlignment=TextAlignment.Right));
      connect(lessThreshold.y, switchTLeg.u2) annotation (Line(points={{47,28},{52,28},
              {52,1},{62.6,1}}, color={255,0,255}));
      connect(triggerControl.y, triggeredAdd.trigger) annotation (Line(points={{-27,
              4},{-17.6,4},{-17.6,20.8}}, color={255,0,255}));
      connect(lessThreshold.y, not2.u) annotation (Line(points={{47,28},{48,28},{48,
              -50},{58.8,-50}}, color={255,0,255}));
      connect(timeAntiLeg.y, greaterThreshold.u1)
        annotation (Line(points={{-9,-22},{2.6,-22}}, color={0,0,127}));
      connect(realExpression.y, greaterThreshold.u2) annotation (Line(points={{-9,-48},
              {-9,-38},{2.6,-38},{2.6,-28.4}}, color={0,0,127}));
      connect(not2.y, and1.u1) annotation (Line(points={{72.6,-50},{74,-50},{74,-58},
              {76.8,-58}}, color={255,0,255}));
      connect(y, and1.y)
        annotation (Line(points={{110,-58},{90.6,-58}}, color={255,0,255}));
      connect(booleanConstant.y, and1.u2) annotation (Line(points={{72.9,-83},{80,
              -83},{80,-62.8},{76.8,-62.8}}, color={255,0,255}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
                                Rectangle(
              extent={{-100,99.5},{100,-100}},
              lineColor={175,175,175},
              lineThickness=0.5,
              fillPattern=FillPattern.Solid,
              fillColor={255,255,170}),
            Ellipse(extent={{-80,98},{80,-62}}, lineColor={160,160,164},
              fillColor={215,215,215},
              fillPattern=FillPattern.Solid),
            Line(points={{0,98},{0,78}}, color={160,160,164}),
            Line(points={{80,18},{60,18}},
                                         color={160,160,164}),
            Line(points={{0,-62},{0,-42}}, color={160,160,164}),
            Line(points={{-80,18},{-60,18}},
                                           color={160,160,164}),
            Line(points={{37,88},{26,68}}, color={160,160,164}),
            Line(points={{70,56},{49,44}}, color={160,160,164}),
            Line(points={{71,-19},{52,-9}},  color={160,160,164}),
            Line(points={{39,-52},{29,-33}}, color={160,160,164}),
            Line(points={{-39,-52},{-29,-34}}, color={160,160,164}),
            Line(points={{-71,-19},{-50,-8}},  color={160,160,164}),
            Line(points={{-71,55},{-54,46}}, color={160,160,164}),
            Line(points={{-38,88},{-28,69}}, color={160,160,164}),
            Line(
              points={{0,18},{-50,68}},
              thickness=0.5),
            Line(
              points={{0,18},{40,18}},
              thickness=0.5),
            Line(
              points={{0,18},{0,86}},
              thickness=0.5,
              color={238,46,47}),
            Line(
              points={{0,18},{-18,-14}},
              thickness=0.5,
              color={238,46,47}),
            Text(
              extent={{-14,0},{72,-36}},
              lineColor={238,46,47},
              pattern=LinePattern.Dash,
              lineThickness=0.5,
              textString=DynamicSelect("%TLegMin K", String(TLegMin-273.15)+ "°C")),
            Text(
              extent={{-94,0},{56,-154}},
              lineColor={28,108,200},
              fillColor={215,215,215},
              fillPattern=FillPattern.Solid,
              textString="Day of week: %trigWeekDay
Hour of Day: %trigHour",
              horizontalAlignment=TextAlignment.Left),
            Text(
              extent={{-104,146},{100,92}},
              lineColor={28,108,200},
              fillColor={215,215,215},
              fillPattern=FillPattern.Solid,
              textString="%name")}),                                                           Diagram(
            coordinateSystem(preserveAspectRatio=false)),
        Documentation(info="<html>
<p>This model represents the anti legionella control of a real heat pump. Based on a daily or weekly approach, the given supply temperature is raised above the minimal temperature required for the thermal desinfection (at least 60 &deg;C) for a given duration minTimeAntLeg.</p>
</html>",     revisions="<html>
<ul>
<li>
<i>November 26, 2018&nbsp;</i> by Fabian Wüllhorst: <br/>
First implementation (see issue <a href=\"https://github.com/RWTH-EBC/AixLib/issues/577\">#577</a>)
</li>
</ul>
</html>"));
    end AntiLegionellaControl;

    package BaseClasses "Package with base classes for AixLib.Controls.HeatPump.SecurityControls"

      partial model PartialTSet_DHW_Control "Model to output the dhw set temperature"

        Modelica.Blocks.Interfaces.RealOutput TSet_DHW
          annotation (Placement(transformation(extent={{100,-10},{120,10}})));
        Interfaces.DistributionControlBus sigBusDistr
          "Necessary to control DHW temperatures" annotation (Placement(
              transformation(extent={{-114,-14},{-86,12}})));
        Modelica.Blocks.Interfaces.BooleanOutput
                                        y "Set auxilliar heater to true"
          annotation (Placement(transformation(extent={{100,-68},{120,-48}})));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
              Rectangle(
                extent={{-100,100},{100,-100}},
                lineColor={0,0,0},
                fillColor={215,215,215},
                fillPattern=FillPattern.Solid,
                lineThickness=0.5), Text(
                extent={{-128,28},{124,-18}},
                lineColor={28,108,200},
                lineThickness=1,
                textString="%name")}),                                 Diagram(
              coordinateSystem(preserveAspectRatio=false)));
      end PartialTSet_DHW_Control;
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
            Ellipse(
              extent={{-30.0,-30.0},{30.0,30.0}},
              lineColor={128,128,128},
              fillColor={255,255,255},
              fillPattern=FillPattern.Solid)}), Documentation(revisions="<html>
<ul>
<li>
<i>November 26, 2018&nbsp;</i> by Fabian Wüllhorst: <br/>
First implementation (see issue <a href=\"https://github.com/RWTH-EBC/AixLib/issues/577\">#577</a>)
</li>
</ul>
</html>",     info="<html>
<p>This package contains base classes that are used to construct the models in <a href=\"modelica://AixLib.Controls.HeatPump.SecurityControls\">SecurityControls</a></p>
</html>"));
    end BaseClasses;

    model ConstTSet_DHW "Constant DHW set temperature"
      extends BaseClasses.PartialTSet_DHW_Control;
      parameter Modelica.Media.Interfaces.Types.Temperature T_DHW
        "Constant TSet DHW output value";
      Modelica.Blocks.Sources.Constant const(final k=T_DHW)
        annotation (Placement(transformation(extent={{-18,-22},{28,24}})));

      Modelica.Blocks.Sources.BooleanConstant
                                       booleanConstant(final k=false)
        annotation (Placement(transformation(extent={{38,-66},{60,-48}})));
    equation
      connect(const.y, TSet_DHW) annotation (Line(points={{30.3,1},{68.15,1},{68.15,
              0},{110,0}}, color={0,0,127}));
      connect(booleanConstant.y, y) annotation (Line(points={{61.1,-57},{86.15,-57},
              {86.15,-58},{110,-58}}, color={255,0,255}));
      annotation (Icon(graphics={
            Polygon(
              points={{-80,90},{-86,68},{-74,68},{-80,90}},
              lineColor={95,95,95},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Line(points={{-80,68},{-80,-80}}, color={95,95,95}),
            Line(
              points={{-80,0},{80,0}},
              color={0,0,255},
              thickness=0.5),
            Polygon(
              points={{90,-70},{68,-64},{68,-76},{90,-70}},
              lineColor={95,95,95},
              fillColor={95,95,95},
              fillPattern=FillPattern.Solid),
            Text(
              extent={{70,-80},{94,-100}},
              textString="time"),
            Line(points={{-90,-70},{82,-70}}, color={95,95,95})}));
    end ConstTSet_DHW;
  annotation (Documentation(revisions="<html>
<ul>
<li>
<i>November 26, 2018&nbsp;</i> by Fabian Wüllhorst: <br/>
First implementation (see issue <a href=\"https://github.com/RWTH-EBC/AixLib/issues/577\">#577</a>)
</li>
</ul>
</html>",   info="<html>
<p>Package with models for simulation of heat pump relevant security control strategies.</p>
</html>"));
  end SecurityControls;

  package TransferSystem
    model TransferOnOff
      "Artificial on off controller for transfer system"
      parameter Integer nZones = 1 "Number of thermal zones in ROM";
      parameter Modelica.SIunits.Temperature TSetCool = 297.15 "Room set temperature for cooling";
      parameter Modelica.SIunits.Temperature TSetHeat = 294.15 "Room set temperature for heating";

      Modelica.Blocks.Interfaces.RealInput TRoom[nZones]
        annotation (Placement(transformation(extent={{-126,38},{-86,78}})));
      Modelica.Blocks.Interfaces.RealInput TAmb "Ambient temperature"
        annotation (Placement(transformation(extent={{-126,-20},{-86,20}})));
      Modelica.Blocks.Logical.GreaterThreshold CaseCooling(threshold=thresholdTCool)
        annotation (Placement(transformation(extent={{-52,-10},{-32,10}})));
      parameter Real thresholdTCool=297.15
        "Threshold temperature above which cooling starts";
      Modelica.Blocks.Logical.And TransferCoolingActive[nZones]
        annotation (Placement(transformation(extent={{-6,38},{14,58}})));
      Modelica.Blocks.Logical.LessThreshold CaseHeating(threshold=thresholdTHeat)
        annotation (Placement(transformation(extent={{-50,-58},{-30,-38}})));
      parameter Real thresholdTHeat=288.15
        "Temperature below which heating is active";
      Modelica.Blocks.Interfaces.BooleanOutput ActiveCooling[nZones]
        "Transfer is active for cooling model"
        annotation (Placement(transformation(extent={{72,38},{92,58}})));
      Modelica.Blocks.Logical.And TransferHeatingActive[nZones]
        annotation (Placement(transformation(extent={{-6,-46},{14,-26}})));
      Modelica.Blocks.Interfaces.BooleanOutput ActiveHeating[nZones]
        "Transfer active for heating mode"
        annotation (Placement(transformation(extent={{72,-46},{92,-26}})));
      Modelica.Blocks.Logical.Or AnyActive[nZones]
        annotation (Placement(transformation(extent={{60,2},{80,22}})));
      Modelica.Blocks.Interfaces.BooleanOutput ActiveTransfer[nZones]
        "Transfer system is active"
        annotation (Placement(transformation(extent={{94,2},{114,22}})));
      Modelica.Blocks.Interfaces.RealInput TSet_max
        annotation (Placement(transformation(extent={{-126,70},{-86,110}})));
      Modelica.Blocks.Logical.Less TRoomTooCold[nZones]
        annotation (Placement(transformation(extent={{-40,-92},{-20,-72}})));
      Modelica.Blocks.Logical.Greater TRoomTooHot[nZones]
        annotation (Placement(transformation(extent={{-50,48},{-30,68}})));
      Modelica.Blocks.Interfaces.RealInput TSet_min
        annotation (Placement(transformation(extent={{-120,-108},{-80,-68}})));
      OnOffController.ConstantHysteresis2 constantHysteresis2_1(dt_hr=0)
        annotation (Placement(transformation(extent={{30,-68},{50,-48}})));
    equation
      connect(TAmb, CaseCooling.u)
        annotation (Line(points={{-106,0},{-54,0}}, color={0,0,127}));
      connect(TAmb, CaseHeating.u) annotation (Line(points={{-106,0},{-77,0},{-77,-48},
              {-52,-48}}, color={0,0,127}));

      for i in 1:nZones loop
        connect(CaseCooling.y,TransferCoolingActive[i].u2);
        connect(CaseHeating.y,TransferHeatingActive[i].u1);
        connect(TSet_min, TRoomTooHot[i].u2);
        connect(TSet_min, TRoomTooCold[i].u2);
      end for;
      connect(TransferCoolingActive.y, AnyActive.u1) annotation (Line(points={{15,48},
              {36,48},{36,12},{58,12}}, color={255,0,255}));
      connect(TransferCoolingActive.y, ActiveCooling)
        annotation (Line(points={{15,48},{82,48}}, color={255,0,255}));
      connect(AnyActive.y, ActiveTransfer)
        annotation (Line(points={{81,12},{104,12}}, color={255,0,255}));
      connect(TRoom, TRoomTooHot.u1)
        annotation (Line(points={{-106,58},{-52,58}}, color={0,0,127}));
      connect(TRoomTooHot.y, TransferCoolingActive.u1) annotation (Line(points=
              {{-29,58},{-18,58},{-18,48},{-8,48}}, color={255,0,255}));
      connect(TRoom, TRoomTooCold.u1) annotation (Line(points={{-106,58},{-86,
              58},{-86,-76},{-64,-76},{-64,-82},{-42,-82}}, color={0,0,127}));
      connect(TRoomTooCold.y, TransferHeatingActive.u2) annotation (Line(points=
             {{-19,-82},{-14,-82},{-14,-44},{-8,-44}}, color={255,0,255}));
      connect(TSet_min, constantHysteresis2_1.T_min) annotation (Line(points={{
              -100,-88},{-78,-88},{-78,-102},{34,-102},{34,-62},{29,-62}},
            color={0,0,127}));
      connect(TSet_max, constantHysteresis2_1.T_max) annotation (Line(points={{
              -106,90},{-172,90},{-172,-132},{24,-132},{24,-52},{29,-52}},
            color={0,0,127}));
      connect(TRoom[1], constantHysteresis2_1.T_Room) annotation (Line(points={
              {-106,58},{-126,58},{-126,-116},{14,-116},{14,-57},{29,-57}},
            color={0,0,127}));
      connect(constantHysteresis2_1.heating_On, ActiveHeating[1]) annotation (
          Line(points={{51.4,-51},{62,-51},{62,-36},{82,-36}}, color={255,0,255}));
      connect(constantHysteresis2_1.heating_On, AnyActive[1].u2) annotation (
          Line(points={{51.4,-51},{51.4,4},{58,4}}, color={255,0,255}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false)));
    end TransferOnOff;

    model TransferOnOff2
        "Artificial on off controller for transfer system"
        parameter Integer nZones = 1 "Number of thermal zones in ROM";
        parameter Modelica.SIunits.Temperature TSetCool=297.15   "Room set temperature for cooling";
        parameter Modelica.SIunits.Temperature TSetHeat=294.15   "Room set temperature for heating";

        Modelica.Blocks.Interfaces.RealInput TRoom[nZones]
          annotation (Placement(transformation(extent={{-126,38},{-86,78}})));
        Modelica.Blocks.Interfaces.RealInput TAmb "Ambient temperature"
          annotation (Placement(transformation(extent={{-126,-20},{-86,20}})));
        Modelica.Blocks.Logical.GreaterThreshold CaseCooling(threshold=thresholdTCool)
          annotation (Placement(transformation(extent={{-52,-10},{-32,10}})));
        parameter Real thresholdTCool=297.15
          "Threshold temperature above which cooling starts";
        Modelica.Blocks.Logical.GreaterThreshold TRoomToHot[nZones](threshold=
            TSetCool - 0.5)
          "Room temperatures exceeds set temperature with small buffer"
          annotation (Placement(transformation(extent={{-64,48},{-44,68}})));
        Modelica.Blocks.Logical.And TransferCoolingActive[nZones]
          annotation (Placement(transformation(extent={{-6,38},{14,58}})));
        Modelica.Blocks.Logical.LessThreshold CaseHeating(threshold=thresholdTHeat)
          annotation (Placement(transformation(extent={{-50,-58},{-30,-38}})));
        parameter Real thresholdTHeat=288.15
          "Temperature below which heating is active";
        Modelica.Blocks.Interfaces.BooleanOutput ActiveCooling[nZones]
          "Transfer is active for cooling model"
          annotation (Placement(transformation(extent={{72,38},{92,58}})));
        Modelica.Blocks.Logical.And TransferHeatingActive[nZones]
          annotation (Placement(transformation(extent={{-6,-46},{14,-26}})));
        Modelica.Blocks.Logical.LessThreshold TRoomTooCold[nZones](threshold=
            TSetHeat + 0.5)
                   "Room temperatures falls below set temperature with small buffer"
          annotation (Placement(transformation(extent={{-62,-96},{-42,-76}})));
        Modelica.Blocks.Interfaces.BooleanOutput ActiveHeating[nZones]
          "Transfer active for heating mode"
          annotation (Placement(transformation(extent={{72,-46},{92,-26}})));
        Modelica.Blocks.Logical.Or AnyActive[nZones]
          annotation (Placement(transformation(extent={{60,2},{80,22}})));
        Modelica.Blocks.Interfaces.BooleanOutput ActiveTransfer[nZones]
          "Transfer system is active"
          annotation (Placement(transformation(extent={{94,2},{114,22}})));
    equation
        connect(TAmb, CaseCooling.u)
          annotation (Line(points={{-106,0},{-54,0}}, color={0,0,127}));
        connect(TRoom, TRoomToHot.u)
          annotation (Line(points={{-106,58},{-66,58}}, color={0,0,127}));
        connect(TAmb, CaseHeating.u) annotation (Line(points={{-106,0},{-77,0},{-77,-48},
                {-52,-48}}, color={0,0,127}));
        connect(TRoom, TRoomTooCold.u) annotation (Line(points={{-106,58},{-86,58},{-86,
                -86},{-64,-86}}, color={0,0,127}));
        connect(TRoomToHot.y, TransferCoolingActive.u1) annotation (Line(points={{-43,
                58},{-25.5,58},{-25.5,48},{-8,48}}, color={255,0,255}));
        connect(TRoomTooCold.y, TransferHeatingActive.u2) annotation (Line(points={{-41,
                -86},{-18,-86},{-18,-44},{-8,-44}}, color={255,0,255}));

        for i in 1:nZones loop
          connect(CaseCooling.y,TransferCoolingActive[i].u2);
          connect(CaseHeating.y,TransferHeatingActive[i].u1);
        end for;
        connect(TransferCoolingActive.y, AnyActive.u1) annotation (Line(points={{15,48},
                {36,48},{36,12},{58,12}}, color={255,0,255}));
        connect(TransferHeatingActive.y, AnyActive.u2) annotation (Line(points={{15,-36},
                {36,-36},{36,4},{58,4}}, color={255,0,255}));
        connect(TransferCoolingActive.y, ActiveCooling)
          annotation (Line(points={{15,48},{82,48}}, color={255,0,255}));
        connect(TransferHeatingActive.y, ActiveHeating) annotation (Line(points={{15,-36},
                {46,-36},{46,-36},{82,-36}}, color={255,0,255}));
        connect(AnyActive.y, ActiveTransfer)
          annotation (Line(points={{81,12},{104,12}}, color={255,0,255}));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
              coordinateSystem(preserveAspectRatio=false)));
    end TransferOnOff2;

  end TransferSystem;


  package Tests
  extends Modelica.Icons.ExamplesPackage;
    model OnOffControllerTest
      extends Modelica.Icons.Example;

      OnOffController.ConstantHysteresis constantHysteresis
        annotation (Placement(transformation(extent={{-28,42},{16,82}})));
      OnOffController.DegreeMinuteController degreeMinuteController(
          DegreeMinuteReset=100)                                    annotation (
          Placement(transformation(
            extent={{-21,-20},{21,20}},
            rotation=0,
            origin={-5,2})));
      OnOffController.FloatingHysteresis floatingHysteresis(Hysteresis_max=15,
          Hysteresis_min=2)
        annotation (Placement(transformation(extent={{-26,-76},{16,-38}})));
      Modelica.Blocks.Sources.Constant T_Set(k=323.15)
        annotation (Placement(transformation(extent={{-160,-20},{-124,16}})));
      Modelica.Blocks.Sources.Sine T_Top(
        amplitude=30,
        freqHz=1/3600,
        offset=313.15)
        annotation (Placement(transformation(extent={{-160,44},{-122,82}})));
      Modelica.Blocks.Sources.Constant T_Set1(k=273.15)
        annotation (Placement(transformation(extent={{-152,-90},{-116,-54}})));
    equation
      connect(T_Set.y, degreeMinuteController.T_Set) annotation (Line(points={{-122.2,
              -2},{-106,-2},{-106,0},{-70,0},{-70,-28},{-5,-28},{-5,-20}},
                     color={0,0,127}));
      connect(T_Set.y, floatingHysteresis.T_Set) annotation (Line(points={{-122.2,
              -2},{-86,-2},{-86,-94},{-5,-94},{-5,-77.9}},       color={0,0,127}));
      connect(T_Set.y, constantHysteresis.T_Set) annotation (Line(points={{-122.2,
              -2},{-112,-2},{-112,-4},{-80,-4},{-80,32},{-6,32},{-6,40}},
            color={0,0,127}));
      connect(T_Top.y, constantHysteresis.T_Top) annotation (Line(points={{-120.1,
              63},{-44,63},{-44,76},{-30.2,76}}, color={0,0,127}));
      connect(T_Top.y, constantHysteresis.T_bot) annotation (Line(points={{-120.1,
              63},{-72,63},{-72,40},{-44,40},{-44,52},{-30.2,52}}, color={0,0,127}));
      connect(T_Top.y, degreeMinuteController.T_Top) annotation (Line(points={{-120.1,
              63},{-96,63},{-96,16},{-28.1,16}},        color={0,0,127}));
      connect(T_Top.y, degreeMinuteController.T_bot) annotation (Line(points={{-120.1,
              63},{-88,63},{-88,-8},{-28.1,-8}},            color={0,0,127}));
      connect(T_Top.y, floatingHysteresis.T_Top) annotation (Line(points={{-120.1,
              63},{-92,63},{-92,-43.7},{-28.1,-43.7}},   color={0,0,127}));
      connect(T_Top.y, floatingHysteresis.T_bot) annotation (Line(points={{-120.1,
              63},{-90,63},{-90,-66.5},{-28.1,-66.5}},   color={0,0,127}));
      connect(T_Set1.y, floatingHysteresis.T_oda) annotation (Line(points={{-114.2,
              -72},{-60.1,-72},{-60.1,-35.72},{-5,-35.72}}, color={0,0,127}));
      connect(T_Set1.y, degreeMinuteController.T_oda) annotation (Line(points={{
              -114.2,-72},{-58,-72},{-58,24.4},{-5,24.4}}, color={0,0,127}));
      connect(T_Set1.y, constantHysteresis.T_oda) annotation (Line(points={{-114.2,
              -72},{-60,-72},{-60,84.4},{-6,84.4}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
            coordinateSystem(preserveAspectRatio=false)),
        experiment(StopTime=86400, Interval=1));
    end OnOffControllerTest;
  end Tests;

  block ThermostaticValvePControlled
      parameter Modelica.SIunits.Temperature T_RoomSet=293.15 "Room set temerature";

   parameter Real Kvs=1.2   "Kv value at full opening (=1)";
    parameter Real Kv_setT=1.4
      "Kv value when set temperature = measured temperature";
    parameter Real P = 2 "Deviation of P-controller when valve is closed";

      parameter Real leakageOpening = 0.0001
      "may be useful for simulation stability. Always check the influence it has on your results";
   Modelica.SIunits.TemperatureDifference TempDiff;
    //calculate the measured temperature difference
    Modelica.Blocks.Interfaces.RealInput TRoom
      annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
    Modelica.Blocks.Interfaces.RealOutput opening
      annotation (Placement(transformation(extent={{100,-20},{140,20}})));

  equation
    TempDiff =TRoom - T_RoomSet;
    //Calculating the valve opening depending on the temperature deviation
    if TempDiff > P * (1- leakageOpening * Kvs / Kv_setT) then
      opening = leakageOpening;
    else
      opening = min(1, (P - TempDiff) * (Kv_setT / Kvs) / P);
    end if;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end ThermostaticValvePControlled;

  block TriggerTime
    Modelica.Blocks.Interfaces.RealOutput y
      annotation (Placement(transformation(extent={{100,-10},{120,10}})));
    Modelica.Blocks.Interfaces.BooleanInput u
      annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));

  algorithm
    when edge(u) then
      y:=time;
    end when;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end TriggerTime;

  block CountTimeBelowThreshold
    Modelica.Blocks.Interfaces.RealOutput y
      annotation (Placement(transformation(extent={{100,-10},{120,10}})));
    Modelica.Blocks.Interfaces.BooleanInput u
      annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));

  algorithm
    when edge(u) then
      y:=time;
    end when;
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end CountTimeBelowThreshold;

  model HeatingCurveDayNight "Model of a heating curve"
    //General
    parameter Modelica.SIunits.ThermodynamicTemperature TOffset(displayUnit="K") = 0
      "Offset to heating curve temperature" annotation (Dialog(descriptionLabel = true));
    parameter Modelica.SIunits.ThermodynamicTemperature TSet_nominal(displayUnit="K") = 273.15 + 55
      "Nominal set temperature" annotation (Dialog(descriptionLabel = true));
    parameter Modelica.SIunits.ThermodynamicTemperature TOda_nominal "Nominal outdoor air temperature";

    //Dynamic room temperature
    parameter Modelica.SIunits.ThermodynamicTemperature TRoom_nominal=293.15 "Constant desired room temperature "
      annotation (Dialog(group="Dynamic room Temperature",enable=not use_dynTRoom));
    Modelica.Blocks.Interfaces.RealInput T_oda(unit="K", displayUnit="degC") "Outdoor air temperature"
      annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
    Modelica.Blocks.Interfaces.RealInput TRoom_in(unit="K", displayUnit="degC")
                                                  "Desired room temperature"
      annotation (Placement(transformation(extent={{-140,36},{-100,76}})));
    Modelica.Blocks.Interfaces.RealOutput TSet(unit="K", displayUnit="degC")
      "Set temperature calculated by heating curve"
      annotation (Placement(transformation(extent={{100,-10},{120,10}})));

  equation
    //Check if current outdoor air temperature is higher than the needed room temperature. If so, no heating is required
    //Else the needed offset is added and the temperature is adjusted according to the wished room temperature
    if T_oda >= TRoom_in then
      TSet = TRoom_in + TOffset;
    else
      TSet =((TSet_nominal - TRoom_in)/(TRoom_in - TOda_nominal)*(TRoom_in - T_oda) + TRoom_in + TOffset);
    end if;
    annotation (Icon(graphics={
          Rectangle(
            extent={{-100,100},{100,-100}},
            lineColor={28,108,200},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid),
          Text(
            lineColor={0,0,255},
            extent={{-150,105},{150,145}},
            textString="%name"),
          Ellipse(
            lineColor = {108,88,49},
            fillColor = {255,215,136},
            fillPattern = FillPattern.Solid,
            extent = {{-100,-100},{100,100}},
            visible = not use_tableData),
          Text(
            lineColor={108,88,49},
            extent={{-90.0,-90.0},{90.0,90.0}},
            textString="f",
            visible = not use_tableData),
          Line(points={{-112,-60},{-52,-92}}, color={28,108,200},visible = use_dynTRoom),
          Line(points={{-114,-64},{-110,-56}}, color={28,108,200},visible = use_dynTRoom),
          Line(points={{-100,-72},{-96,-64}}, color={28,108,200},visible = use_dynTRoom),
          Line(points={{-84,-80},{-80,-72}}, color={28,108,200},visible = use_dynTRoom),
          Line(points={{-68,-88},{-64,-80}}, color={28,108,200},visible = use_dynTRoom),
          Line(points={{-54,-96},{-50,-88}}, color={28,108,200},visible = use_dynTRoom),
          Line(points={{-82,-76},{-64,-42},{-38,-8},{2,28},{44,56},{86,78}}, color={238,46,47},visible = use_tableData and declination>=1.8 and declination <2.2),
          Line(points={{-82,-76},{-56,-50},{-28,-30},{8,-14},{48,-2},{86,4}}, color={238,46,47},visible = use_tableData and declination>=0 and declination <1.4),
          Line(points={{-82,-76},{-62,-48},{-34,-22},{2,2},{42,22},{86,34}}, color={238,46,47},visible = use_tableData and declination>=1.4 and declination <1.8),
          Line(points={{-82,-76},{-68,-28},{-44,18},{-14,54},{26,82}}, color={238,46,47},visible = use_tableData and declination>=2.2),
          Line(points={{-82,84}}, color={28,108,200}),
          Rectangle(
            extent={{-82,-76},{86,82}},
            lineColor={28,108,200},
            fillColor={255,255,255},
            fillPattern=FillPattern.None,
            visible = use_tableData),
          Text(
            extent={{-104,-102},{-74,-88}},
            lineColor={28,108,200},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid,
            textString="TRoom",
            visible = use_dynTRoom),
          Text(
            extent={{-102,82},{-72,96}},
            lineColor={28,108,200},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid,
            textString="TSet",
            visible = use_tableData),
          Text(
            extent={{34,-92},{96,-78}},
            lineColor={28,108,200},
            fillColor={255,255,255},
            fillPattern=FillPattern.Solid,
            textString="- TOda",
            visible = use_tableData)}), Documentation(revisions="<html><ul>
  <li>
    <i>November 26, 2018&#160;</i> by Fabian Wüllhorst:<br/>
    First implementation (see issue <a href=
    \"https://github.com/RWTH-EBC/AixLib/issues/577\">#577</a>)
  </li>
</ul>
</html>",   info="<html>
<p>
  Model of a heating curve. Either based on table input data or with a
  function, the set temperature for the heating system is calculated.
</p>
<p>
  This model is capable of:
</p>
<ul>
  <li>Day-Night Control
  </li>
  <li>Control based on dynamic room temperatures
  </li>
</ul>
</html>"));
  end HeatingCurveDayNight;

  model ThermostaticValvePIControlled
    parameter Real TRoomSet[:,2]=[0.0,293.15; 86400, 293.15] "Table matrix (time = first column; e.g., table=[0, 0; 1, 1; 2, 4])";
      parameter Real leakageOpening = 0.0001
      "may be useful for simulation stability. Always check the influence it has on your results";
    Modelica.Blocks.Interfaces.RealInput TRoom
      annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
    Modelica.Blocks.Interfaces.RealOutput opening
      annotation (Placement(transformation(extent={{100,-20},{140,20}})));

    Modelica.Blocks.Continuous.LimPID PI(
      controllerType=Modelica.Blocks.Types.SimpleController.PI,
      k=k,
      Ti=Ti,
      yMax=1,
      yMin=leakageOpening)
      annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
    Modelica.Blocks.Sources.CombiTimeTable TRoomSetScheduler(
      final tableOnFile=false,
      final table=TRoomSet,
      final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments,
      final extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
      final timeScale=1,
      final offset={0},
      final startTime=0,
      final shiftTime=0)
      annotation (Placement(transformation(extent={{-74,8},{-54,28}})));

    parameter Real k=0.2
                       "Gain of controller";
    parameter Modelica.SIunits.Time Ti=1800
                                           "Time constant of Integrator block";
  equation
    connect(TRoom, PI.u_m) annotation (Line(points={{-120,0},{-54,0},{-54,-26},{0,
            -26},{0,-12}}, color={0,0,127}));
    connect(PI.y, opening)
      annotation (Line(points={{11,0},{120,0}}, color={0,0,127}));
    connect(TRoomSetScheduler.y[1], PI.u_s) annotation (Line(points={{-53,18},{
            -32,18},{-32,0},{-12,0}}, color={0,0,127}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end ThermostaticValvePIControlled;
  annotation (Icon(graphics={
        Rectangle(
          extent={{-82,62},{82,60}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid), Rectangle(
          extent={{-60,72},{-30,50}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          radius=5,
          lineThickness=0.5),
        Rectangle(
          extent={{-82,2},{82,0}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-82,-58},{82,-60}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid), Rectangle(
          extent={{30,12},{60,-10}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          radius=5,
          lineThickness=0.5),             Rectangle(
          extent={{-14,-48},{16,-70}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          radius=5,
          lineThickness=0.5)}));
end Control;
