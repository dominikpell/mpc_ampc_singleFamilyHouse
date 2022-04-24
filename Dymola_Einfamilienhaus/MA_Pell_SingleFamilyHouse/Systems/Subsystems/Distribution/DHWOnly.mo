within MA_Pell_SingleFamilyHouse.Systems.Subsystems.Distribution;
model DHWOnly "only loads DHW"
  extends BaseClasses.PartialDistribution(final nParallelGen=1);
equation
  connect(portDHW_out, portGen_in[1]) annotation (Line(points={{100,-22},{2,-22},
          {2,80},{-100,80}}, color={0,127,255}));
  connect(portGen_out[1], portDHW_in) annotation (Line(points={{-100,40},{-6,40},
          {-6,-82},{100,-82}}, color={0,127,255}));
  connect(portBui_out, portBui_in) annotation (Line(points={{100,80},{84,80},{
          84,40},{100,40}}, color={0,127,255}));
end DHWOnly;
