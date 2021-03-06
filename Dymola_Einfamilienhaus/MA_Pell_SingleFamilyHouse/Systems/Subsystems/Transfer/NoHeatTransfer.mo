within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Transfer;
model NoHeatTransfer "No heat tranfser to building"
  extends BaseClasses.PartialTransfer;
  Modelica.Thermal.HeatTransfer.Sources.FixedHeatFlow fixedHeatFlow[
    systemParameters.nZones](each final Q_flow=0)
    annotation (Placement(transformation(extent={{54,-10},{74,10}})));
equation
  connect(portTra_in, portTra_out) annotation (Line(points={{-100,38},{-74,38},
          {-74,-42},{-100,-42}}, color={0,127,255}));
  connect(fixedHeatFlow.port, heatPortCon)
    annotation (Line(points={{74,0},{100,0},{100,40}}, color={191,0,0}));
  connect(fixedHeatFlow.port, heatPortRad)
    annotation (Line(points={{74,0},{100,0},{100,-40}}, color={191,0,0}));
end NoHeatTransfer;
