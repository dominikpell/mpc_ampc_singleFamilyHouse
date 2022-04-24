within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution;
model BuildingOnly "Only loads building"
  extends BaseClasses.PartialDistribution;
equation
  connect(portDHW_out, portDHW_in) annotation (Line(points={{100,-22},{88,-22},{
          88,-16},{76,-16},{76,-82},{100,-82}}, color={0,127,255}));
  connect(portGen_in[1], portBui_out)
    annotation (Line(points={{-100,80},{100,80}}, color={0,127,255}));
  connect(portGen_out[1], portBui_in)
    annotation (Line(points={{-100,40},{100,40}}, color={0,127,255}));
end BuildingOnly;
