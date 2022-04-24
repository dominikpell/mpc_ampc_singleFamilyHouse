within MA_Pell_SingleFamilyHouse.Components.Electrical;
model Inverter "Inverter for DC to AC transformation"
  parameter Real P_Max "Maximum inverter power";
  parameter Real P_Min "Minimum inverter power";

  parameter Real a1 = 0.002409 "curve parameter" annotation (choicesAllMatching, Dialog(group="Parameter"));
  parameter Real a2 = 0.00561 "curve parameter" annotation (choicesAllMatching, Dialog(group="Parameter"));
  parameter Real a3 = 0.01228 "curve parameter" annotation (choicesAllMatching, Dialog(group="Parameter"));

  Real eta "Load-dependend inverter efficiency";

  Real P_AC_out "AC power after inverter";
  Real P_0 "Initial relative power";

  Modelica.Blocks.Interfaces.RealInput P_DC
    annotation (Placement(transformation(extent={{-126,-18},{-86,22}})));
  Modelica.Blocks.Sources.RealExpression P_out(y=P_AC_out)
    annotation (Placement(transformation(extent={{6,-10},{26,10}})));
  Modelica.Blocks.Nonlinear.Limiter InverterLimits(uMax=P_Max, uMin=P_Min)
    annotation (Placement(transformation(extent={{46,-10},{66,10}})));
  Modelica.Blocks.Interfaces.RealOutput P_AC "Connector of Real output signal"
    annotation (Placement(transformation(extent={{94,-10},{114,10}})));
equation
  P_0 = P_DC / P_Max;
  eta = max(Modelica.Constants.eps,P_0 / (P_0 + a1 + a2* P_0 + a3 * P_0^2));
  P_AC_out = P_DC * eta;
  connect(P_out.y, InverterLimits.u)
    annotation (Line(points={{27,0},{44,0}}, color={0,0,127}));
  connect(InverterLimits.y, P_AC)
    annotation (Line(points={{67,0},{104,0}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end Inverter;
