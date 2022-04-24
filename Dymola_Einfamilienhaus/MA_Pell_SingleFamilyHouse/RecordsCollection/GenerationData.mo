within MA_Pell_SingleFamilyHouse.RecordsCollection;
package GenerationData
  extends Modelica.Icons.RecordsPackage;
  partial record HeatingRodBaseDataDefinition
    extends Modelica.Icons.Record;
  // Generation: Heating Rod
    parameter Real eta_hr = 0.97 "Heating rod efficiency";
    parameter Modelica.SIunits.Volume V_hr=0.001
      "Volume to model thermal inertia of water";
    parameter Modelica.SIunits.Power Q_HR_Nom=5000
                                              "First Stage: Nominal heating rod power";
      parameter Modelica.SIunits.PressureDifference dp_nominal=1000
      "Pressure difference";
     parameter Modelica.SIunits.MassFlowRate m_flowGen=0.2
      "Mass flow rate";
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end HeatingRodBaseDataDefinition;

  partial record HeatPumpBaseDataDefinition
    extends Modelica.Icons.Record;
    // Generation: Heat Pump
    parameter Modelica.SIunits.MassFlowRate mFlow_eva=1
      "Mass flow rate through evaporator";
    parameter Modelica.SIunits.MassFlowRate m_flowGen=0.2
      "Mass flow rate";
    parameter Modelica.SIunits.Volume VEva=0.004
      "Manual input of the evaporator volume (if not automatically calculated)";
    parameter Modelica.SIunits.Volume VCon=0.001
      "Manual input of the condenser volume";
    parameter Modelica.SIunits.Power Q_HP_Nom=5000
                                              "First Stage: Nominal heat pump power";
    parameter String refrigerant="R410A" "Binary: Refigrerant in use";
    parameter String flowsheet="VIPhaseSeparatorFlowsheet" "Binary: Flowsheet being used. Other option is: StandardFlowsheet";
    parameter Boolean useAirSource=true "Turn false to use water as temperature source.";
    parameter Modelica.SIunits.PressureDifference dpCon_nominal=1000
      "Pressure difference";
    parameter Modelica.SIunits.PressureDifference dpEva_nominal=1000
      "Pressure difference";

    parameter Boolean addPowerToMedium=false
      "Set to false to avoid any power (=heat and flow work) being added to medium (may give simpler equations)"
      annotation (Dialog(tab="Pump"));
    parameter Boolean use_inputFilter=true
      "= true, if speed is filtered with a 2nd order CriticalDamping filter"
                                                                            annotation (Dialog(tab="Pump"));
    parameter Modelica.SIunits.Time riseTime=30
      "Rise time of the filter (time to reach 99.6 % of the speed)"
                                                                   annotation (Dialog(tab="Pump"));
    parameter Modelica.SIunits.Time tau=1
      "Time constant of fluid volume for nominal flow, used if energy or mass balance is dynamic"
                                                                                                 annotation (Dialog(tab="Pump"));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end HeatPumpBaseDataDefinition;

  record DummyHP
    extends HeatPumpBaseDataDefinition;
  end DummyHP;

  record DummyHR
    extends HeatingRodBaseDataDefinition;
  end DummyHR;

  partial record SolarThermalBaseDataDefinition
    extends Modelica.Icons.Record;
    parameter Real pressureDropCoeff=2500/(A*2.5e-5)^2
      "Pressure drop coefficient, delta_p[Pa] = PD * Q_flow[m^3/s]^2";
    parameter Modelica.SIunits.MassFlowRate m_flow_nominal
      "Nominal mass flow rate";

    parameter Modelica.SIunits.Area A=2 "Area of solar thermal collector";
    parameter Modelica.SIunits.Volume volPip "Water volume of piping";
    parameter AixLib.DataBase.SolarThermal.SolarThermalBaseDataDefinition
      Collector
      "Properties of Solar Thermal Collector" annotation(choicesAllMatching=true);
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end SolarThermalBaseDataDefinition;

  record DummySolarThermal "DummyParameters"
    extends SolarThermalBaseDataDefinition(
      volPip=5e-3,
      m_flow_nominal=0.1,
      Collector=AixLib.DataBase.SolarThermal.FlatCollector());

  end DummySolarThermal;
end GenerationData;
