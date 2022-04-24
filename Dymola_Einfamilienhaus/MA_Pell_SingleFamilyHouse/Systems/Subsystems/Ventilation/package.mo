within MA_Pell_SingleFamilyHouse.Systems.Subsystems;
package Ventilation "Subsystem for ventilation of thermal zone"

annotation (Icon(graphics={
        Rectangle(
          lineColor={200,200,200},
          fillColor={248,248,248},
          fillPattern=FillPattern.HorizontalCylinder,
          extent={{-98,-100},{102,100}},
          radius=25.0),
        Rectangle(
          lineColor={128,128,128},
          extent={{-98,-100},{102,100}},
          radius=25.0),
        Rectangle(
          lineColor={128,128,128},
          extent={{-98,-100},{102,100}},
          radius=25.0),
      Rectangle(extent={{-78,66},{-16,-42}}, lineColor={0,0,0}),
      Rectangle(extent={{26,66},{90,8}}, lineColor={0,0,0}),
      Rectangle(extent={{26,-24},{90,-82}}, lineColor={0,0,0}),
      Line(points={{-18,50},{26,50}}, color={0,0,0}),
      Line(points={{-18,24},{26,24}}, color={0,0,0}),
      Line(points={{76,-24},{76,8}}, color={0,0,0}),
      Line(points={{40,-24},{40,8}}, color={0,0,0})}));
end Ventilation;
