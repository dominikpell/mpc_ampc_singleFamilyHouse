within MA_Pell_SingleFamilyHouse.RecordsCollection;
package StorageData
    extends Modelica.Icons.RecordsPackage;

  partial record PartialStorageBaseDataDefinition
    extends Modelica.Icons.Record;
    parameter MA_Pell_SingleFamilyHouse.Components.DHW.DHWProfile tapping = MA_Pell_SingleFamilyHouse.Components.DHW.DHWProfile.M;
    parameter Modelica.SIunits.Volume V_dhw_day = if tapping == MA_Pell_SingleFamilyHouse.Components.DHW.DHWProfile.L then 248.517e-3 elseif tapping == MA_Pell_SingleFamilyHouse.Components.DHW.DHWProfile.M then 123.417e-3 else 43.5e-3;
    parameter Modelica.SIunits.Efficiency eps=0.8 "Heat exchanger effectiveness";
    parameter Modelica.SIunits.HeatFlowRate Q_flow_nominal "Nominal heat flow rate";
    parameter Real VPerQ_flow=23.5e-6 "Litre per W of nominal heat flow rate";

    parameter Modelica.SIunits.Volume V=VPerQ_flow*Q_flow_nominal
                                             "Volume of storage";
    parameter Real storage_H_dia_ratio = 2 "Storage tank height-diameter ration. SOURCE: Working Assumption of all paper before";
    parameter Integer nLayer = 4 "Number of layers in storage";
    parameter Modelica.SIunits.Diameter d=(V*4/(storage_H_dia_ratio*Modelica.Constants.pi))^(
    1/3) "Diameter of storage";
    parameter Modelica.SIunits.Height h=d*storage_H_dia_ratio;
    parameter Modelica.SIunits.CoefficientOfHeatTransfer hConIn=100 "Model assumptions heat transfer coefficient water <-> wall";
    parameter Modelica.SIunits.CoefficientOfHeatTransfer hConOut=10 "Model assumptions heat transfer coefficient insulation <-> air";
    parameter Modelica.SIunits.CoefficientOfHeatTransfer hConHC=100 "Model assumptions Coefficient of Heat Transfer HC1 <-> Heating Water";
      parameter Modelica.SIunits.ThermalConductivity lambda_ins=0.045
      "thermal conductivity of insulation";
    parameter Modelica.SIunits.Length s_ins=0.12 "thickness of insulation";
   annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end PartialStorageBaseDataDefinition;

  package SimpleStorage
    record DummySimpleStorage "Dummy data"
      extends SimpleStorageBaseDataDefinition;
    end DummySimpleStorage;

    record DirectLoadingStorage
      extends SimpleStorageBaseDataDefinition(
        k_HE=90000);
    end DirectLoadingStorage;

    record SimpleStorageBaseDataDefinition
      extends PartialStorageBaseDataDefinition;

      parameter Modelica.SIunits.Volume V_HE=0.005 "heat exchanger volume";
      parameter Modelica.SIunits.CoefficientOfHeatTransfer k_HE=450
        "heat exchanger heat transfer coefficient";
      parameter Modelica.SIunits.Area A_HE=2 "heat exchanger area";
      parameter Modelica.SIunits.RelativePressureCoefficient beta=350e-6;
      parameter Real kappa=0.4;

    end SimpleStorageBaseDataDefinition;
  end SimpleStorage;

  package BufferStorage
    record BufferStorageBaseDataDefinition
      extends PartialStorageBaseDataDefinition;

      parameter Boolean use_hr=false;
      parameter Modelica.SIunits.Power QHR_flow_nominal=0;
      parameter Modelica.SIunits.MassFlowRate mHC1_flow_nominal=1
        "Nominal mass flow rate of fluid 1 ports";
      parameter Modelica.SIunits.MassFlowRate mHC2_flow_nominal=1
        "Nominal mass flow rate of fluid 1 ports";
      parameter Modelica.SIunits.CoefficientOfHeatTransfer hConHC1=100
        "Model assumptions Coefficient of Heat Transfer HC1 <-> Heating Water";
      parameter Modelica.SIunits.CoefficientOfHeatTransfer hConHC2=100
        " Model assumptions Coefficient of Heat Transfer HC2 <-> Heating Water";
    end BufferStorageBaseDataDefinition;

    record bufferData "Simpler design for this repo"
      extends AixLib.DataBase.Storage.BufferStorageBaseDataDefinition(
        pipeHC1=AixLib.DataBase.Pipes.Copper.Copper_22x1(),
        roughness=2.5e-5,
        lengthHC1=floor((hHC1Up - hHC1Low)/(dTank*0.8*tan(0.17453292519943)))*cos(0.17453292519943)*dTank*0.8,
        cWall=cIns,
        rhoWall=rhoIns,
        lengthHC2=floor((hHC1Up - hHC1Low)/(dTank*0.8*tan(0.17453292519943)))*cos(
            0.17453292519943)*dTank*0.8,
        pipeHC2=pipeHC1,
        hTS2=hTank,
        hTS1=0,
        hHR=hTank/2,
        hHC2Low=0,
        hHC2Up=hTank/2,
        hHC1Low=hTank/2,
        hHC1Up=hTank,
        hUpperPortSupply=hTank,
        hLowerPortSupply=0,
        hUpperPortDemand=hTank,
        hLowerPortDemand=0);

    end bufferData;
  end BufferStorage;
end StorageData;
