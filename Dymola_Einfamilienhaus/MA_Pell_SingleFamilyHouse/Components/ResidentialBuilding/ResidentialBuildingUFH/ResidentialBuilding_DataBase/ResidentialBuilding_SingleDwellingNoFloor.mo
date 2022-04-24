within MA_Pell_SingleFamilyHouse.Components.ResidentialBuilding.ResidentialBuildingUFH.ResidentialBuilding_DataBase;
record ResidentialBuilding_SingleDwellingNoFloor
  "ResidentialBuilding_SingleDwelling suitable for UFH as no floor area"
  extends AixLib.DataBase.ThermalZones.ZoneBaseRecord(
    T_start = 293.15,
    withAirCap = true,
    VAir = 480.0,
    AZone = 150.0,
    hRad = 5.0,
    lat = 0.88645272708792,
    nOrientations = 4,
    AWin = {7.5, 7.5, 7.5, 7.5},
    ATransparent = {7.5, 7.5, 7.5, 7.5},
    hConWin = 2.7,
    RWin = 0.011940298507462687,
    gWin = 0.67,
    UWin= 1.8936557576825386,
    ratioWinConRad = 0.029999999999999995,
    AExt = {33.75, 33.75, 33.75, 33.75},
    hConExt = 2.7,
    nExt = 1,
    RExt = {0.0002022296625696948},
    RExtRem = 0.013378017251010553,
    CExt = {56749960.15495383},
    AInt = 550.0000000000001,
    hConInt = 2.4272727272727277,
    nInt = 1,
    RInt = {0.0001319970403943968},
    CInt = {58082478.38670303},
    AFloor = 0.01,
    hConFloor = 1.7,
    nFloor = 1,
    RFloor = {2.3128627720345007},
    RFloorRem =  158.16332770415596,
    CFloor = {804.4926929625199},
    ARoof = 99.75,
    hConRoof = 1.7000000000000006,
    nRoof = 1,
    RRoof = {0.00023847706069558312},
    RRoofRem = 0.019354880878527013,
    CRoof = {36494842.83228058},
    nOrientationsRoof = 1,
    tiltRoof = {0.0},
    aziRoof = {0.0},
    wfRoof = {1.0},
    aRoof = 0.5,
    aExt = 0.5,
    TSoil = 286.15,
    hConWallOut = 20.0,
    hRadWall = 5.0,
    hConWinOut = 20.0,
    hConRoofOut = 20.000000000000004,
    hRadRoof = 5.0,
    tiltExtWalls = {1.5707963267948966, 1.5707963267948966, 1.5707963267948966, 1.5707963267948966},
    aziExtWalls = {0.0, 1.5707963267948966, 3.141592653589793, -1.5707963267948966},
    wfWall = {0.25, 0.25, 0.25, 0.25},
    wfWin = {0.25, 0.25, 0.25, 0.25},
    wfGro = 0.0,
    specificPeople = 0.02,
    internalGainsMoistureNoPeople = 0.5,
    fixedHeatFlowRatePersons = 70,
    activityDegree = 1.2,
    ratioConvectiveHeatPeople = 0.5,
    internalGainsMachinesSpecific = 2.0,
    ratioConvectiveHeatMachines = 0.75,
    lightingPowerSpecific = 7.0,
    ratioConvectiveHeatLighting = 0.5,
    useConstantACHrate = false,
    baseACH = 0.2,
    maxUserACH = 1.0,
    maxOverheatingACH = {3.0, 2.0},
    maxSummerACH = {1.0, 283.15, 290.15},
    winterReduction = {0.2, 273.15, 283.15},
    maxIrr = {100.0, 100.0, 100.0, 100.0},
    shadingFactor = {1.0, 1.0, 1.0, 1.0},
    withAHU = false,
    minAHU = 0.3,
    maxAHU = 0.6,
    hHeat = 6532.315671669887,
    lHeat = 0,
    KRHeat = 10000,
    TNHeat = 1,
    HeaterOn = true,
    hCool = 0,
    lCool = -6532.315671669887,
    KRCool = 10000,
    TNCool = 1,
    CoolerOn = false,
    withIdealThresholds = false,
    TThresholdHeater = 288.15,
    TThresholdCooler = 295.15);
end ResidentialBuilding_SingleDwellingNoFloor;
