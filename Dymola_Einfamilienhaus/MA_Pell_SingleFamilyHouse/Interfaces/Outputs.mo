within MA_Pell_SingleFamilyHouse.Interfaces;
package Outputs
  expandable connector DemandOutputs "Bus with ouputs of the demand system"
    extends Modelica.Icons.SignalBus;


    Real dch_DHW;
    Real T_Air;
    Real t_rad;
    Real dT_vio;
    Real T_Win;
    Real T_ExtWall;
    Real T_IntWall;
    Real T_Floor;
    Real T_Roof;
    annotation (
    defaultComponentName = "outBusDem",
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

  end DemandOutputs;

  expandable connector TransferOutputs "Bus with ouputs of the tramsfer system"
    extends Modelica.Icons.SignalBus;

    parameter Integer nZones;
    Real T_supply_UFH;
    Real T_return_UFH;
    Real Q_conv_UFH;
    Real Q_rad_UFH;
    Real dch_TES;
    Real T_panel_heating1;
    Real T_thermalCapacity_top;
    Real T_thermalCapacity_down;

    Real mFlow[nZones] "mass flow to thermal zones";
    Real TZone[nZones](
      final quantity="ThermodynamicTemperature",
      final unit="K",
      displayUnit="degC")
      "Indoor air temperature" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={110,84}),  iconTransformation(extent={{-10,-10},{10,10}},
          rotation=180,
          origin={110,84})));
    annotation (
    defaultComponentName = "outBusTra",
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

  end TransferOutputs;

  expandable connector GenerationOutputs
    "Bus with ouputs of the generation system"
    extends Modelica.Icons.SignalBus;
    Real x_HP_on;
    Real power_HP;
    Real heat_rod;
    Real heat_HP;
    Real power_rod;
    Real T_supply_HP_heat;
    Real T_supply_HP;
    Real T_supply;
    Real T_supply_heat;
    Real T_return_heat;
    Real T_return;
    annotation (
    defaultComponentName = "outBusGen",
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

  end GenerationOutputs;

  expandable connector DistributionOutputs
    "Bus with ouputs of the distribution system"
    extends Modelica.Icons.SignalBus;

    Modelica.SIunits.Temperature t_DHW "Temperature of uppest layer of DHW storage";
    Modelica.SIunits.Temperature t_TES "Temperature of uppest layer of DHW storage";
    Real ch_TES;
    Real ch_DHW;


    Modelica.SIunits.Temperature T_DHW_4 "Temperature of uppest layer of DHW storage";
    Modelica.SIunits.Temperature T_DHW_3 "Temperature of uppest layer of buffer storage";
    Modelica.SIunits.Temperature T_DHW_2 "Temperature of uppest layer of DHW storage";
    Modelica.SIunits.Temperature T_DHW_1 "Temperature of uppest layer of buffer storage";
    Modelica.SIunits.Temperature T_TES_4 "Temperature of uppest layer of DHW storage";
    Modelica.SIunits.Temperature T_TES_3 "Temperature of uppest layer of DHW storage";
    Modelica.SIunits.Temperature T_TES_2 "Temperature of uppest layer of DHW storage";
    Modelica.SIunits.Temperature T_TES_1 "Temperature of uppest layer of DHW storage";
    Modelica.SIunits.Temperature T_HE_DHW_4 "Temperature of uppest layer of DHW storage";
    Modelica.SIunits.Temperature T_HE_DHW_3 "Temperature of uppest layer of buffer storage";
    Modelica.SIunits.Temperature T_HE_DHW_2 "Temperature of uppest layer of DHW storage";
    Modelica.SIunits.Temperature T_HE_DHW_1 "Temperature of uppest layer of buffer storage";
    Modelica.SIunits.Temperature T_HE_TES_4 "Temperature of uppest layer of DHW storage";
    Modelica.SIunits.Temperature T_HE_TES_3 "Temperature of uppest layer of DHW storage";
    Modelica.SIunits.Temperature T_HE_TES_2 "Temperature of uppest layer of DHW storage";
    Modelica.SIunits.Temperature T_HE_TES_1 "Temperature of uppest layer of DHW storage";

    annotation (
    defaultComponentName = "outBusDist",
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

  end DistributionOutputs;

  expandable connector SystemOutputs
    "Bus with ouputs of the overall system"
    extends Modelica.Icons.SignalBus;
    parameter Integer nZones;
    Outputs.DistributionOutputs outputsDist "Outputs of the distribtion system";
    Outputs.GenerationOutputs outputsGen "Outputs of the generation system";
    Outputs.DemandOutputs outputsDem "Outputs of the demand system";
    Outputs.ControlOutputs outputsCtrl "Outputs of the control system";
    Outputs.TransferOutputs outputsTra(nZones = nZones) "Outputs of the transfer system";
    Outputs.VentilationOutputs outputsVen "Outputs of the ventilation system";
    Outputs.ElectricityOutputs outputsElec "Outputs of the electrical system";
    annotation (
    defaultComponentName = "outBusGen",
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

  end SystemOutputs;

  expandable connector ControlOutputs
    "Bus with ouputs of the control system"
    extends Modelica.Icons.SignalBus;

    annotation (
    defaultComponentName = "outBusCtrl",
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

  end ControlOutputs;

  expandable connector VentilationOutputs
    "Bus with ouputs of the ventilation system"
    extends Modelica.Icons.SignalBus;

    annotation (
    defaultComponentName = "outBusVen",
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

  end VentilationOutputs;

  expandable connector ElectricityOutputs
    "Bus with ouputs of the ventilation system"
    extends Modelica.Icons.SignalBus;
    Real ts_power_PV;
    Real power_use_PV;
    Real power_to_grid_PV;
    Real power_to_BAT_PV;
    Real power_use_BAT;
    Real power_to_grid_BAT;
    Real power_to_BAT_from_grid;
    Real ch_BAT;
    Real dch_BAT;
    Real soc_BAT;

    Real power_to_grid;
    Real power_from_grid;
    Real res_elec;
    annotation (
    defaultComponentName = "outBusElec",
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)));

  end ElectricityOutputs;
end Outputs;
