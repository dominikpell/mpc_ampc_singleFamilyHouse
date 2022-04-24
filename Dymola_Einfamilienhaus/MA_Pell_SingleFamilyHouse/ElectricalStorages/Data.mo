within MA_Pell_SingleFamilyHouse.ElectricalStorages;
package Data "Data base with parameter sets of electrical batteries"
  package LeadAcid "Data base with parameter sets of lead acid batteries"
    record Chloride200Ah =
        MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral
        (
        E_nominal=2.4*1000*3600,
        U_nominal=12.0,
        SOC_min=0.2,
        c=0.315,
        k=1.24/3600.0,
        etaCharge=0.92736,
        etaLoad=0.92736,
        fDis=0.01/(7*24.0*3600.0),
        PLoad_max=8400.0,
        PCharge_max=336.0,
        p=1.17,
        a_mcr=0.96/3600.0)
      "Lead acid 'CLH12-200': 2.4 kWh"
      annotation(Documentation(info= "<html>Source: Datasheet for Chloride 'Lighthouse' CLH12-200, www.chloride-batteries.com<br/></html>"));
    record LeadAcidGeneric =
        MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral
        (
        E_nominal=2.88*1000*3600,
        U_nominal=12.0,
        SOC_min=0.3,
        c=0.315,
        k=1.24/3600.0,
        etaCharge=0.92736,
        etaLoad=0.92736,
        fDis=0.05/(30*24.0*3600.0),
        PLoad_max=23520.0,
        PCharge_max=864.0,
        p=1.3,
        a_mcr=0.96/3600.0)
      "Lead Acid generic: 2.88 kWh"
      annotation(Documentation(info= "<html>Source: PolySun version 9.2.9 except loss factor fDis after http://www.batteryeducation.com<br/></html>"));
    record Long7Ah =
        MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral
        (
        E_nominal=86.4*3600,
        U_nominal=12.0,
        SOC_min=0.5,
        c=0.315,
        k=1.24/3600.0,
        etaCharge=0.92736,
        etaLoad=0.92736,
        fDis=0.2/(182.5*24.0*3600.0),
        PLoad_max=1296.0,
        PCharge_max=25.9,
        p=1.23,
        a_mcr=0.96/3600.0)
      "Lead acid 'WP7.2-12': 86.4 Wh"
      annotation(Documentation(info= "<html>Source: Datasheet for Long WP7.2-12, https://www.kunglong.com/product_pdf/en/WP7.2-12.pdf<br/></html>"));
  end LeadAcid;

  package LithiumIon "Data base with parameter sets of lead acid batteries"
    record LithiumIonAquion =
        MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral
        (
        E_nominal=25.9*1000*3600,
        U_nominal=48.0,
        SOC_min=0.0,
        c=0.4,
        k=8.0/3600.0,
        etaCharge=0.93,
        etaLoad=0.93,
        fDis=0.1/(30.*24.0*3600.0),
        PLoad_max=11700.0,
        PCharge_max=11700.0,
        p=1.05,
        a_mcr=0.96/3600.0)
      "Lithium Ion Aquion: 25.9 kWh"
      annotation(Documentation(info= "<html>Source: PolySun version 10.0.11 except loss factor fDis after http://www.batteryeducation.com<br/></html>"));
    record LithiumIonTeslaPowerwall1 =
        MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral
        (
        E_nominal=6.4*1000*3600,
        U_nominal=400.0,
        SOC_min=0.0,
        c=0.4,
        k=8.0/3600.0,
        etaCharge=0.92,
        etaLoad=0.92,
        fDis=0.1/(30.*24.0*3600.0),
        PLoad_max=3300.0,
        PCharge_max=3300.0,
        p=1.05,
        a_mcr=0.96/3600.0)
      "Lithium Ion Tesla Powerwall 1: 6.4 kWh"
      annotation(Documentation(info= "<html>Source: PolySun version 10.0.11 and Tesla except loss factor fDis after http://www.batteryeducation.com<br/></html>"));
    record LithiumIonTeslaPowerwall2 =
        MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral
        (
        E_nominal=13.5*1000*3600,
        U_nominal=400.0,
        SOC_min=0.0,
        c=0.4,
        k=8.0/3600.0,
        etaCharge=0.92,
        etaLoad=0.92,
        fDis=0.1/(30.*24.0*3600.0),
        PLoad_max=4600.0,
        PCharge_max=4600.0,
        p=1.05,
        a_mcr=0.96/3600.0)
      "Lithium Ion Tesla Powerwall 2: 13.5 kWh"
      annotation(Documentation(info= "<html>Source: PolySun version 10.0.11 and Tesla except loss factor fDis after http://www.batteryeducation.com<br/></html>"));
    record LithiumIonViessmann =
        MA_Pell_SingleFamilyHouse.ElectricalStorages.Data.BaseClasses.ElectricBatteryGeneral
        (
        E_nominal=4.7*1000*3600,
        U_nominal=52.0,
        SOC_min=0.2,
        c=0.4,
        k=8.0/3600.0,
        etaCharge=0.93,
        etaLoad=0.93,
        fDis=0.1/(30.*24.0*3600.0),
        PLoad_max=2850.0,
        PCharge_max=2850.0,
        p=1.05,
        a_mcr=0.96/3600.0)
      "Lithium Ion Viessmann: 4.7 kWh"
      annotation(Documentation(info= "<html>Source: PolySun version 10.0.11 except loss factor fDis after http://www.batteryeducation.com<br/></html>"));
  end LithiumIon;

  package BaseClasses "Templates for data base with parameter sets of electric batteries"
    record ElectricBatteryGeneral
      parameter Modelica.SIunits.Energy E_nominal
        "Nominal capacity";
      parameter Modelica.SIunits.Voltage U_nominal
        "Nominal voltage";
      parameter Real SOC_min
        "Minimal accepted charge level (SOC)";
      parameter Real c(unit="1")
        "Capacity relation available to bound energy";
      parameter Real k(unit="1/s")
        "Battery rate";
      parameter Modelica.SIunits.Efficiency etaCharge
        "Charge efficiency";
      parameter Modelica.SIunits.Efficiency etaLoad
        "Load efficiency";
      parameter Real fDis
        "Self-discharge factor (percentage per day)";
      parameter Modelica.SIunits.Power PLoad_max
        "Maximal discharging power";
      parameter Modelica.SIunits.Power PCharge_max
        "Maximal charging power";
      parameter Real p(unit="1")
        "Peukert coefficient";
      parameter Real a_mcr(unit="W/J")
        "Maximum charge rate parameter";
    end ElectricBatteryGeneral;
  end BaseClasses;
end Data;
