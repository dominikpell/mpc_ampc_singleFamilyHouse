within MA_Pell_SingleFamilyHouse.RecordsCollection;
package TransferData
  extends Modelica.Icons.RecordsPackage;

  record ThermostaticValveDataDefinition
    extends Modelica.Icons.Record;
      //Demand - Building
    parameter Real Kvs=1.2   "Kv value at full opening (=1)";
    parameter Real Kv_setT=1.4
      "Kv value when set temperature = measured temperature";
    parameter Real P = 2 "Deviation of P-controller when valve is closed";

    parameter Real leakageOpening = 0.0001
      "may be useful for simulation stability. Always check the influence it has on your results";
    parameter Real k=0.2
                       "Gain of controller";
    parameter Modelica.SIunits.Time Ti=1800
                                           "Time constant of Integrator block";

      parameter Modelica.SIunits.PressureDifference dpFixed_nominal=1000
      "Pressure drop of pipe and other resistances that are in series";
    parameter Modelica.SIunits.PressureDifference dpValve_nominal=1000
      "Nominal pressure drop of fully open valve, used if CvData=AixLib.Fluid.Types.CvTypes.OpPoint";
    annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end ThermostaticValveDataDefinition;

  record RadiatorTransferData
    extends Modelica.Icons.Record;

    parameter Integer nEle=5 "Number of elements used in the discretization";
    parameter Real fraRad=0.35 "Fraction radiant heat transfer";
    parameter Real n=1.24 "Exponent for heat transfer";

  end RadiatorTransferData;

  record UFHData
    extends Modelica.Icons.Record;

    parameter Integer nZones=1 "Number of zones to transfer heat to";
    parameter Modelica.SIunits.CoefficientOfHeatTransfer k_top[nZones]=fill(4.47, nZones) "Heat transfer coefficient for layers above tubes";
    parameter Modelica.SIunits.CoefficientOfHeatTransfer k_down[nZones]=fill(0.37, nZones) "Heat transfer coefficient for layers underneath tubes";
    parameter AixLib.Fluid.HeatExchangers.ActiveWalls.BaseClasses.HeatCapacityPerArea C_ActivatedElement[nZones] = fill(380, nZones);
    parameter Real c_top_ratio[nZones]=fill(0.19, nZones);
    parameter Modelica.SIunits.Diameter diameter=18e-3 "Pipe diameter";
    //parameter Modelica.SIunits.Length Spacing = 0.2 "Spacing between pipes";
    parameter Modelica.SIunits.Temperature T_floor=281.65 "Fixed temperature at floor (soil)";

  end UFHData;
end TransferData;
