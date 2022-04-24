within MA_Pell_SingleFamilyHouse.RecordsCollection;
package Movers "Record data for movers"
  extends Modelica.Icons.RecordsPackage;
  record AutomaticConfigurationData
    "Automatic configuration for BES Library"
    extends AixLib.Fluid.Movers.Data.Generic(
      final motorEfficiency(V_flow={0}, eta={0.7}),
      final hydraulicEfficiency(V_flow={0}, eta={0.7}),
      final speeds_rpm={speed_rpm_nominal},
      final constantSpeed_rpm=speed_rpm_nominal,
      final speeds=speeds_rpm/speed_rpm_nominal,
      final constantSpeed=constantSpeed_rpm/speed_rpm_nominal,
      final speed_nominal=1,
      final motorCooledByFluid=false,
      final use_powerCharacteristic=false,
      final pressure(V_flow={V_flowCurve[i] * m_flow_nominal / rho for i in 1:size(V_flowCurve, 1)},
                     dp={dpCurve[i] * dp_nominal for i in 1:size(dpCurve, 1)}));
     parameter Modelica.SIunits.MassFlowRate m_flow_nominal "Nominal mass flow rate";
     parameter Modelica.SIunits.PressureDifference dp_nominal "Nominal pressure difference";
     parameter Modelica.SIunits.Density rho "Density of fluid in use";
     parameter Real V_flowCurve[:] = {0, 1, 1.1, 1.15} "Relative V_flow curve to be used";
     parameter Real dpCurve[:] = {1.25, 1, 0.75, 0} "Relative dp curve to be used";
  end AutomaticConfigurationData;
end Movers;
