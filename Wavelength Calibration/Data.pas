// *****************************************************************************
// * wlmData.pas                                                               *
// *   (header file for wlmData.dll)                                           *
// *                                                                2013-03-26 *
// *****************************************************************************

const LibName = 'wlmData.dll';

{$if not Declared(IntPtr)}
  type IntPtr  = {$if Defined(WIN64)} INT64  {$else} Integer  {$ifend};
  type UIntPtr = {$if Defined(WIN64)} UINT64 {$else} Cardinal {$ifend};
{$ifend}

// ***********  Functions for general usage  ****************************
function Instantiate(RFC, Mode: Integer; P1: IntPtr; P2: Integer): IntPtr; stdcall; external LibName;

//procedure CallbackProc(Mode: Integer; IntVal: Integer; DblVal: Double); stdcall;
//procedure CallbackProcEx(Rev, Mode, IntVal: Integer; DblVal: Double; Res: Integer); stdcall;
function WaitForWLMEvent(var Mode, IntVal: Integer; var DblVal: Double): Integer; stdcall; external LibName;
function WaitForWLMEventEx(var Ver, Mode, IntVal: Integer; var DblVal: Double; var Res1: Integer): Integer; stdcall; external LibName;
function WaitForNextWLMEvent(var Mode, IntVal: Integer; var DblVal: Double): Integer; stdcall; external LibName;
function WaitForNextWLMEventEx(var Ver, Mode, IntVal: Integer; var DblVal: Double; var Res1: Integer): Integer; stdcall; external LibName;
procedure ClearWLMEvents; stdcall; external LibName;

function ControlWLM(Action: Integer; App: IntPtr; Res1: Integer): Integer; stdcall; external LibName;
function ControlWLMEx(Action: Integer; App: IntPtr; Res1, Ex1, Ex2: Integer): Integer; stdcall; external LibName;
function SynchroniseWLM(Mode: Integer; TS: INT64): INT64; stdcall; external LibName;
function SetMeasurementDelayMethod(Mode, Delay: Integer): Integer; stdcall; external LibName;
function SetWLMPriority(PPC, Res1, Res2: Integer): Integer; stdcall; external LibName;
function PresetWLMIndex(V: Integer): Integer; stdcall; external LibName;

function GetWLMVersion(V: Integer): Integer; stdcall; external LibName;
function GetWLMIndex(Rev: Integer): Integer; stdcall; external LibName;
function GetWLMCount(V: Integer): Integer; stdcall; external LibName;


// ***********  General Get... & Set...-functions  **********************
function GetWavelength(WL: Double): Double; stdcall; external LibName;
function GetWavelength2(WL2: Double): Double; stdcall; external LibName;
function GetWavelengthNum(num: Integer; WL: Double): Double; stdcall; external LibName;
function GetCalWavelength(ba: Integer; WL: Double): Double; stdcall; external LibName;
function GetCalibrationEffect(CE: Double): Double; stdcall; external LibName;
function GetFrequency(F: Double): Double; stdcall; external LibName;
function GetFrequency2(F2: Double): Double; stdcall; external LibName;
function GetFrequencyNum(num: Integer; F: Double): Double; stdcall; external LibName;
function GetLinewidth(Index: Integer; LW: Double): Double; stdcall; external LibName;
function GetLinewidthNum(num: Integer; LW: Double): Double; stdcall; external LibName;
function GetDistance(D: Double): Double; stdcall; external LibName;
function GetAnalogIn(AI: Double): Double; stdcall; external LibName;
function GetTemperature(T: Double): Double; stdcall; external LibName;
function SetTemperature(T: Double): Integer; stdcall; external LibName;
function GetPressure(P: Double): Double; stdcall; external LibName;
function SetPressure(Mode: Integer; P: Double): Integer; stdcall; external LibName;
function GetExternalInput(Index: Integer; T: Double): Double; stdcall; external LibName;
function SetExternalInput(Index: Integer; T: Double): Integer; stdcall; external LibName;

function GetExposure(E: Word): Word; stdcall; external LibName;
function SetExposure(E: Word): Integer; stdcall; external LibName;
function GetExposure2(E2: Word): Word; stdcall; external LibName;
function SetExposure2(E2: Word): Integer; stdcall; external LibName;
function GetExposureNum(num, arr, E: Integer): Integer; stdcall; external LibName;
function SetExposureNum(num, arr, E: Integer): Integer; stdcall; external LibName;
function GetExposureMode(EM: Boolean): Boolean; stdcall; external LibName;
function SetExposureMode(EM: Boolean): Integer; stdcall; external LibName;
function GetExposureModeNum(num: Integer; EM: Boolean): Integer; stdcall; external LibName;
function SetExposureModeNum(num: Integer; EM: Boolean): Integer; stdcall; external LibName;
function GetExposureRange(ER: Integer): Integer; stdcall; external LibName;

function GetResultMode(RM: Word): Word; stdcall; external LibName;
function SetResultMode(RM: Word): Integer; stdcall; external LibName;
function GetRange(R: Word): Word; stdcall; external LibName;
function SetRange(R: Word): Integer; stdcall; external LibName;
function GetPulseMode(PM: Word): Word; stdcall; external LibName;
function SetPulseMode(PM: Word): Integer; stdcall; external LibName;
function GetWideMode(WM: Word): Word; stdcall; external LibName;
function SetWideMode(WM: Word): Integer; stdcall; external LibName;

function GetDisplayMode(FM: Integer): Integer; stdcall; external LibName;
function SetDisplayMode(DM: Integer): Integer; stdcall; external LibName;
function GetFastMode(FM: Boolean): Boolean; stdcall; external LibName;
function SetFastMode(FM: Boolean): Integer; stdcall; external LibName;

function GetLinewidthMode(LM: Boolean): Boolean; stdcall; external LibName;
function SetLinewidthMode(LM: Boolean): Integer; stdcall; external LibName;

function GetDistanceMode(DM: Boolean): Boolean; stdcall; external LibName;
function SetDistanceMode(DM: Boolean): Integer; stdcall; external LibName;

function GetSwitcherMode(SM: Integer): Integer; stdcall; external LibName;
function SetSwitcherMode(SM: Integer): Integer; stdcall; external LibName;
function GetSwitcherChannel(CH: Integer): Integer; stdcall; external LibName;
function SetSwitcherChannel(Channel: Integer): Integer; stdcall; external LibName;
function GetSwitcherSignalStates(Signal: Integer; var Use, Show: Integer): Integer; stdcall; external LibName;
function SetSwitcherSignalStates(Signal, Use, Show: Integer): Integer; stdcall; external LibName;
function SetSwitcherSignal(Signal, Use, Show: Integer): Integer; stdcall; external LibName;

function GetAutoCalMode(ACM: Integer): Integer; stdcall; external LibName;
function SetAutoCalMode(ACM: Integer): Integer; stdcall; external LibName;
function GetAutoCalSetting(ACS: Integer; var val: Integer; Res1: Integer; var Res2: Integer): Integer; stdcall; external LibName;
function SetAutoCalSetting(ACS, val, Res1, Res2: Integer): Integer; stdcall; external LibName;

function GetActiveChannel(Mode: Integer; var Port: Integer; Res1: Integer): Integer; stdcall; external LibName;
function SetActiveChannel(Mode, Port, CH, Res1: Integer): Integer; stdcall; external LibName;
function GetChannelsCount(C: Integer): Integer; stdcall; external LibName;

function GetOperationState(OS: Word): Word; stdcall; external LibName;
function Operation(Op: Word): Integer; stdcall; external LibName;
function SetOperationFile(Filename: PChar): Integer; stdcall; external LibName;
function Calibration(iType, iUnit: Integer; Value: Double; iChannel: Integer): Integer; stdcall; external LibName;
function RaiseMeasurementEvent(Mode: Integer): Integer; stdcall; external LibName;
function TriggerMeasurement(Action: Integer): Integer; stdcall; external LibName;
function GetTriggerState(TS: Integer): Integer; stdcall; external LibName;
function GetInterval(I: Integer): Integer; stdcall; external LibName;
function SetInterval(I: Integer): Integer; stdcall; external LibName;
function GetIntervalMode(IM: Boolean): Boolean; stdcall; external LibName;
function SetIntervalMode(IM: Boolean): Integer; stdcall; external LibName;
function GetBackground(BG: Integer): Integer; stdcall; external LibName;
function SetBackground(BG: Integer): Integer; stdcall; external LibName;

function GetLinkState(LS: Boolean): Boolean; stdcall; external LibName;
function SetLinkState(LS: Boolean): Integer; stdcall; external LibName;
procedure LinkSettingsDlg; stdcall; external LibName;

function GetPatternItemSize(Index: Integer): Integer; stdcall; external LibName;
function GetPatternItemCount(Index: Integer): Integer; stdcall; external LibName;
function GetPattern(Index: Integer): UIntPtr; stdcall; external LibName;
function GetPatternNum(Chn, Index: Integer): UIntPtr; stdcall; external LibName;
// Use the V1-version pointing to your address location or array
// function GetPatternDataV1(Index: Integer; PArray: UIntPtr): Integer; stdcall; external LibName; name 'GetPatternData';
// Use the V2-version with your array directly
// function GetPatternDataV2(Index: Integer; var MyArray: TMyArray1): Integer; stdcall; external LibName; name 'GetPatternData';
function GetPatternData(Index: Integer; PArray: UIntPtr): Integer; stdcall; external LibName;
function GetPatternDataNum(Chn, Index: Integer; PArray: UIntPtr): Integer; stdcall; external LibName;
function SetPattern(Index, Enable: Integer): Integer; stdcall; external LibName;
function SetPatternData(Index: Integer; PArray: UIntPtr): Integer; stdcall; external LibName;

function GetAnalysisMode(AM: Boolean): Boolean; stdcall; external LibName;
function SetAnalysisMode(AM: Boolean): Integer; stdcall; external LibName;
function GetAnalysisItemSize(Index: Integer): Integer; stdcall; external LibName;
function GetAnalysisItemCount(Index: Integer): Integer; stdcall; external LibName;
function GetAnalysis(Index: Integer): UIntPtr; stdcall; external LibName;
// Use the V1-version pointing to your address location or array
// function GetAnalysisDataV1(Index: Integer; PArray: UIntPtr): Integer; stdcall; external LibName; name 'GetAnalyisData';
// Use the V2-version with your array directly
// function GetAnalysisDataV2(Index: Integer; var MyArray: TMyArray2): Integer; stdcall; external LibName; name 'GetAnalysisData';
function GetAnalysisData(Index: Integer; PArray: UIntPtr): Integer; stdcall; external LibName;
function SetAnalysis(Index, Enable: Integer): Integer; stdcall; external LibName;

function GetMinPeak(M1: Integer): Integer; stdcall; external LibName;
function GetMinPeak2(M2: Integer): Integer; stdcall; external LibName;
function GetMaxPeak(X1: Integer): Integer; stdcall; external LibName;
function GetMaxPeak2(X2: Integer): Integer; stdcall; external LibName;
function GetAvgPeak(A1: Integer): Integer; stdcall; external LibName;
function GetAvgPeak2(A2: Integer): Integer; stdcall; external LibName;
function SetAvgPeak(PA: Integer): Integer; stdcall; external LibName;

function GetAmplitudeNum(num, Index, A: Integer): Integer; stdcall; external LibName;
function GetIntensityNum(num: Integer; I: Double): Double; stdcall; external LibName;
function GetPowerNum(num: Integer; P: Double): Double; stdcall; external LibName;

function GetDelay(D: Word): Word; stdcall; external LibName;
function SetDelay(D: Word): Integer; stdcall; external LibName;
function GetShift(S: Word): Word; stdcall; external LibName;
function SetShift(S: Word): Integer; stdcall; external LibName;
function GetShift2(S2: Word): Word; stdcall; external LibName;
function SetShift2(S2: Word): Integer; stdcall; external LibName;


// ***********  Deviation (Laser Control) and PID-functions  ************
function GetDeviationMode(DM: Boolean): Boolean; stdcall; external LibName;
function SetDeviationMode(DM: Boolean): Integer; stdcall; external LibName;
function GetDeviationReference(DR: Double): Double; stdcall; external LibName;
function SetDeviationReference(DR: Double): Integer; stdcall; external LibName;
function GetDeviationSensitivity(DS: Integer): Integer; stdcall; external LibName;
function SetDeviationSensitivity(DS: Integer): Integer; stdcall; external LibName;
function GetDeviationSignal(DS: Double): Double; stdcall; external LibName;
function GetDeviationSignalNum(Num: Integer; DS: Double): Double; stdcall; external LibName;
function SetDeviationSignal(DS: Double): Integer; stdcall; external LibName;
function SetDeviationSignalNum(Port: Integer; DS: Double): Integer; stdcall; external LibName;
function RaiseDeviationSignal(iType: Integer; Signal: Double): Double; stdcall; external LibName;

function GetPIDCourse(PIDC: PChar): Integer; stdcall; external LibName;
function SetPIDCourse(PIDC: PChar): Integer; stdcall; external LibName;
function GetPIDCourseNum(Port: Integer; PIDC: PChar): Integer; stdcall; external LibName;
function SetPIDCourseNum(Port: Integer; PIDC: PChar): Integer; stdcall; external LibName;
function GetPIDSetting(PS, Port: Integer; var iVal: Integer; var dVal: Double): Integer; stdcall; external LibName;
function SetPIDSetting(PS, Port, iVal: Integer; dVal: Double): Integer; stdcall; external LibName;
function ClearPIDHistory(Port: Integer): Integer; stdcall; external LibName;


// ***********  Other...-functions  *************************************
function ConvertUnit(Val: Double; uFrom, uTo: Integer): Double ; stdcall; external LibName;
function ConvertDeltaUnit(Base, Delta: Double; uBase, uFrom, uTo: Integer): Double; stdcall; external LibName;


// ***********  Obsolete...-functions  **********************************
function GetReduced(R: Boolean): Boolean; stdcall; external LibName;
function SetReduced(R: Boolean): Integer; stdcall; external LibName;
function GetScale(S: Word): Word; stdcall; external LibName;
function SetScale(S: Word): Integer; stdcall; external LibName;


// ***********  Constants  **********************************************

const
// Instantiating Constants for 'RFC' parameter
      cInstCheckForWLM = -1;
      cInstResetCalc = 0;
      cInstReturnMode = cInstResetCalc;
      cInstNotification = 1;
      cInstCopyPattern = 2;
      cInstCopyAnalysis = cInstCopyPattern;
      cInstControlWLM = 3;
      cInstControlDelay = 4;
      cInstControlPriority = 5;

// Notification Constants for 'Mode' parameter
      cNotifyInstallCallback = 0;
      cNotifyRemoveCallback = 1;
      cNotifyInstallWaitEvent = 2;
      cNotifyRemoveWaitEvent = 3;
      cNotifyInstallCallbackEx = 4;
      cNotifyInstallWaitEventEx = 5;

// ResultError Constants of Set...-functions
      ResERR_NoErr = 0;
      ResERR_WlmMissing = -1;
      ResERR_CouldNotSet = -2;
      ResERR_ParmOutOfRange = -3;
      ResERR_WlmOutOfResources = -4;
      ResERR_WlmInternalError = -5;
      ResERR_NotAvailable = -6;
      ResERR_WlmBusy = -7;
      ResERR_NotInMeasurementMode = -8;
      ResERR_OnlyInMeasurementMode = -9;
      ResERR_ChannelNotAvailable = -10;
      ResERR_ChannelTemporarilyNotAvailable = -11;
      ResERR_CalOptionNotAvailable = -12;
      ResERR_CalWavelengthOutOfRange = -13;
      ResERR_BadCalibrationSignal = -14;
      ResERR_UnitNotAvailable = -15;
      ResERR_FileNotFound = -16;
      ResERR_FileCreation = -17;
      ResERR_TriggerPending = -18;
      ResERR_TriggerWaiting = -19;

// cmi Mode Constants for Callback-Export and WaitForWLMEvent-function
      cmiResultMode = 1;
      cmiRange = 2;
      cmiPulse = 3;
      cmiPulseMode = cmiPulse;
      cmiWideLine = 4;
      cmiWideMode = cmiWideLine;
      cmiFast = 5;
      cmiFastMode = cmiFast;
      cmiExposureMode = 6;
      cmiExposureValue1 = 7;
      cmiExposureValue2 = 8;
      cmiDelay = 9;
      cmiShift = 10;
      cmiShift2 = 11;
      cmiReduce = 12;
      cmiReduced = cmiReduce;
      cmiScale = 13;
      cmiTemperature = 14;
      cmiLink = 15;
      cmiOperation = 16;
      cmiDisplayMode = 17;
      cmiPattern1a = 18;
      cmiPattern1b = 19;
      cmiPattern2a = 20;
      cmiPattern2b = 21;
      cmiMin1 = 22;
      cmiMax1 = 23;
      cmiMin2 = 24;
      cmiMax2 = 25;
      cmiNowTick = 26;
      cmiCallback = 27;
      cmiFrequency1 = 28;
      cmiFrequency2 = 29;
      cmiDLLDetach = 30;
      cmiVersion = 31;
      cmiAnalysisMode = 32;
      cmiDeviationMode = 33;
      cmiDeviationReference = 34;
      cmiDeviationSensitivity = 35;
      cmiAppearance = 36;
      cmiAutoCalMode = 37;
      cmiWavelength1 = 42;
      cmiWavelength2 = 43;
      cmiLinewidth = 44;
      cmiLinewidthMode = 45;
      cmiLinkDlg = 56;
      cmiAnalysis = 57;
      cmiAnalogIn = 66;
      cmiAnalogOut = 67;
      cmiDistance = 69;
      cmiWavelength3 = 90;
      cmiWavelength4 = 91;
      cmiWavelength5 = 92;
      cmiWavelength6 = 93;
      cmiWavelength7 = 94;
      cmiWavelength8 = 95;
      cmiVersion0 = cmiVersion;
      cmiVersion1 = 96;
      cmiDLLAttach = 121;
      cmiSwitcherSignal = 123;
      cmiSwitcherMode = 124;
      cmiExposureValue11 = cmiExposureValue1;
      cmiExposureValue12 = 125;
      cmiExposureValue13 = 126;
      cmiExposureValue14 = 127;
      cmiExposureValue15 = 128;
      cmiExposureValue16 = 129;
      cmiExposureValue17 = 130;
      cmiExposureValue18 = 131;
      cmiExposureValue21 = cmiExposureValue2;
      cmiExposureValue22 = 132;
      cmiExposureValue23 = 133;
      cmiExposureValue24 = 134;
      cmiExposureValue25 = 135;
      cmiExposureValue26 = 136;
      cmiExposureValue27 = 137;
      cmiExposureValue28 = 138;
      cmiPatternAverage = 139;
      cmiPatternAvg1 = 140;
      cmiPatternAvg2 = 141;
      cmiAnalogOut1 = cmiAnalogOut;
      cmiAnalogOut2 = 142;
      cmiMin11 = cmiMin1;
      cmiMin12 = 146;
      cmiMin13 = 147;
      cmiMin14 = 148;
      cmiMin15 = 149;
      cmiMin16 = 150;
      cmiMin17 = 151;
      cmiMin18 = 152;
      cmiMin21 = cmiMin2;
      cmiMin22 = 153;
      cmiMin23 = 154;
      cmiMin24 = 155;
      cmiMin25 = 156;
      cmiMin26 = 157;
      cmiMin27 = 158;
      cmiMin28 = 159;
      cmiMax11 = cmiMax1;
      cmiMax12 = 160;
      cmiMax13 = 161;
      cmiMax14 = 162;
      cmiMax15 = 163;
      cmiMax16 = 164;
      cmiMax17 = 165;
      cmiMax18 = 166;
      cmiMax21 = cmiMax2;
      cmiMax22 = 167;
      cmiMax23 = 168;
      cmiMax24 = 169;
      cmiMax25 = 170;
      cmiMax26 = 171;
      cmiMax27 = 172;
      cmiMax28 = 173;
      cmiAvg11 = cmiPatternAvg1;
      cmiAvg12 = 174;
      cmiAvg13 = 175;
      cmiAvg14 = 176;
      cmiAvg15 = 177;
      cmiAvg16 = 178;
      cmiAvg17 = 179;
      cmiAvg18 = 180;
      cmiAvg21 = cmiPatternAvg2;
      cmiAvg22 = 181;
      cmiAvg23 = 182;
      cmiAvg24 = 183;
      cmiAvg25 = 184;
      cmiAvg26 = 185;
      cmiAvg27 = 186;
      cmiAvg28 = 187;
      cmiPatternAnalysisWritten = 202;
      cmiSwitcherChannel = 203;
      cmiAnalogOut3 = 237;
      cmiAnalogOut4 = 238;
      cmiAnalogOut5 = 239;
      cmiAnalogOut6 = 240;
      cmiAnalogOut7 = 241;
      cmiAnalogOut8 = 242;
      cmiIntensity = 251;
      cmiPower = 267;
      cmiActiveChannel = 300;
      cmiPIDCourse = 1030;
      cmiPIDUseTa = 1031;
      cmiPIDUseT = cmiPIDUseTa;
      cmiPID_T = 1033;
      cmiPID_P = 1034;
      cmiPID_I = 1035;
      cmiPID_D = 1036;
      cmiDeviationSensitivityDim = 1040;
      cmiDeviationSensitivityFactor = 1037;
      cmiDeviationPolarity = 1038;
      cmiDeviationSensitivityEx = 1039;
      cmiDeviationUnit = 1041;
      cmiPIDConstdt = 1059;
      cmiPID_dt = 1060;
      cmiPID_AutoClearHistory = 1061;
      cmiDeviationChannel = 1063;
      cmiAutoCalPeriod = 1120;
      cmiAutoCalUnit = 1121;
      cmiServerInitialized = 1124;
      cmiWavelength9 = 1130;
      cmiExposureValue19 = 1155;
      cmiExposureValue29 = 1180;
      cmiMin19 = 1205;
      cmiMin29 = 1230;
      cmiMax19 = 1255;
      cmiMax29 = 1280;
      cmiAvg19 = 1305;
      cmiAvg29 = 1330;
      cmiWavelength10 = 1355;
      cmiWavelength11 = 1356;
      cmiWavelength12 = 1357;
      cmiWavelength13 = 1358;
      cmiWavelength14 = 1359;
      cmiWavelength15 = 1360;
      cmiWavelength16 = 1361;
      cmiWavelength17 = 1362;
      cmiExternalInputFirst = 1400;
      cmiExternalInputLast = 1462;
      cmiExternalInput = cmiExternalInputFirst;
      cmiPressure = 1465;
      cmiBackground = 1475;
      cmiDistanceMode = 1476;
      cmiInterval = 1477;
      cmiIntervalMode = 1478;
      cmiCalibrationEffect = 1480;
      cmiLinewidth1 = cmiLinewidth;
      cmiLinewidth2 = 1481;
      cmiLinewidth3 = 1482;
      cmiLinewidth4 = 1483;
      cmiLinewidth5 = 1484;
      cmiLinewidth6 = 1485;
      cmiLinewidth7 = 1486;
      cmiLinewidth8 = 1487;
      cmiLinewidth9 = 1488;
      cmiLinewidth10 = 1489;
      cmiLinewidth11 = 1490;
      cmiLinewidth12 = 1491;
      cmiLinewidth13 = 1492;
      cmiLinewidth14 = 1493;
      cmiLinewidth15 = 1494;
      cmiLinewidth16 = 1495;
      cmiLinewidth17 = 1496;
      cmiTriggerState = 1497;
      cmiDeviceAttach = 1501;
      cmiDeviceDetach = 1502;

// WLM Control Mode Constants
      cCtrlWLMShow = 1;
      cCtrlWLMHide = 2;
      cCtrlWLMExit = 3;
      cCtrlWLMStore = 4;
      cCtrlWLMWait        = $0010;
      cCtrlWLMStartSilent = $0020;
      cCtrlWLMSilent      = $0040;
      cCtrlWLMStartDelay  = $0080;

// Operation Mode Constants (for "Operation" and "GetOperationState" functions)
      cStop = 0;
      cAdjustment = 1;
      cMeasurement = 2;

// Base Operation Constants (To be used exclusively, only one of this list at a time,
// but still can be combined with "Measurement Action Addition Constants". See below.)
      cCtrlStopAll = cStop;
      cCtrlStartAdjustment = cAdjustment;
      cCtrlStartMeasurement = cMeasurement;
      cCtrlStartRecord = $0004;
      cCtrlStartReplay = $0008;
      cCtrlStoreArray  = $0010;
      cCtrlLoadArray   = $0020;

// Additional Operation Flag Constants (combine with "Base Operation Constants" above.)
      cCtrlDontOverwrite = $0000;
      cCtrlOverwrite     = $1000; // don't combine with cCtrlFileDialog
      cCtrlFileGiven     = $0000;
      cCtrlFileDialog    = $2000; // don't combine with cCtrlOverwrite and cCtrlFileASCII
      cCtrlFileBinary    = $0000; // *.smr, *.ltr
      cCtrlFileASCII     = $4000; // *.smx, *.ltx, don't combine with cCtrlFileDialog

// Measurement Control Mode Constants
      cCtrlMeasDelayRemove = 0;
      cCtrlMeasDelayGenerally = 1;
      cCtrlMeasDelayOnce = 2;
      cCtrlMeasDelayDenyUntil = 3;
      cCtrlMeasDelayIdleOnce = 4;
      cCtrlMeasDelayIdleEach = 5;
      cCtrlMeasDelayDefault = 6;

// Measurement Triggering Action Constants
      cCtrlMeasurementContinue = 0;
      cCtrlMeasurementInterrupt = 1;
      cCtrlMeasurementTriggerPoll = 2;
      cCtrlMeasurementTriggerSuccess = 3;
      cCtrlMeasurementEx = $0100;

// ExposureRange Constants
      cExpoMin = 0;
      cExpoMax = 1;
      cExpo2Min = 2;
      cExpo2Max = 3;

// Amplitude Constants
      cMin1 = 0;
      cMin2 = 1;
      cMax1 = 2;
      cMax2 = 3;
      cAvg1 = 4;
      cAvg2 = 5;

// Measurement Range Constants
      cRange_250_410 = 4;
      cRange_250_425 = 0;
      cRange_300_410 = 3;
      cRange_350_500 = 5;
      cRange_400_725 = 1;
      cRange_700_1100 = 2;
      cRange_800_1300 = 6;
      cRange_900_1500 = cRange_800_1300;
      cRange_1100_1700 = 7;
      cRange_1100_1800 = cRange_1100_1700;

// Unit Constants for Get-/SetResultMode, GetLinewidth, Convert... and Calibration
      cReturnWavelengthVac = 0;
      cReturnWavelengthAir = 1;
      cReturnFrequency = 2;
      cReturnWavenumber = 3;
      cReturnPhotonEnergy = 4;

// Power Unit Constants
      cPower_muW = 0;
      cPower_dBm = 1;

// Source Type Constants for Calibration
      cHeNe633 = 0;
      cHeNe1152 = 0;
      cNeL = 1;
      cOther = 2;
      cFreeHeNe = 3;

// Unit Constants for Autocalibration
      cACOnceOnStart = 0;
      cACMeasurements = 1;
      cACDays = 2;
      cACHours = 3;
      cACMinutes = 4;

// ExposureRange Constants
      cGetSync = 1;
      cSetSync = 2;

// Pattern- and Analysis Constants
      cPatternDisable = 0;
      cPatternEnable = 1;
      cAnalysisDisable = cPatternDisable;
      cAnalysisEnable = cPatternEnable;

      cSignal1Interferometers = 0;
      cSignal1WideInterferometer = 1;
      cSignal1Grating = 1;
      cSignal2Interferometers = 2;
      cSignal2WideInterferometer = 3;
      cSignalAnalysis = 4;
      cSignalAnalysisX = cSignalAnalysis;
      cSignalAnalysisY = cSignalAnalysis + 1;

// Return errorvalues of GetFrequency, GetWavelength and GetWLMVersion
      ErrNoValue = 0;
      ErrNoSignal = -1;
      ErrBadSignal = -2;
      ErrLowSignal = -3;
      ErrBigSignal = -4;
      ErrWlmMissing = -5;
      ErrNotAvailable = -6;
      InfNothingChanged = -7;
      ErrNoPulse = -8;
      ErrDiv0 = -13;
      ErrOutOfRange = -14;
      ErrUnitNotAvailable = -15;
      ErrMaxErr = ErrUnitNotAvailable;

// Return errorvalues of GetTemperature and GetPressure
      ErrTemperature = -1000;
      ErrTempNotMeasured = ErrTemperature + ErrNoValue;
      ErrTempNotAvailable = ErrTemperature + ErrNotAvailable;
      ErrTempWlmMissing = ErrTemperature + ErrWlmMissing;

// Return errorvalues of GetDistance
	// real errorvalues are ErrDistance combined with those of GetWavelength
      ErrDistance = -1000000000;
      ErrDistanceNotAvailable = ErrDistance + ErrNotAvailable;
      ErrDistanceWlmMissing = ErrDistance + ErrWlmMissing;

// Return flags of ControlWLMEx in combination with Show or Hide, Wait and Res = 1
      flServerStarted           = $00000001;
      flErrDeviceNotFound       = $00000002;
      flErrDriverError          = $00000004;
      flErrUSBError             = $00000008;
      flErrUnknownDeviceError   = $00000010;
      flErrWrongSN              = $00000020;
      flErrUnknownSN            = $00000040;
      flErrTemperatureError     = $00000080;
      flErrPressureError        = $00000100;
      flErrCancelledManually    = $00000200;
      flErrWLMBusy              = $00000400;
      flErrUnknownError         = $00001000;
      flNoInstalledVersionFound = $00002000;
      flDesiredVersionNotFound  = $00004000;
      flAppFileNotFound         = $00008000;
      flErrParmOutOfRange       = $00010000;
      flErrCouldNotSet          = $00020000;

// Return file info flags of SetOperationFile
      flFileInfoDoesntExist = $0000;
      flFileInfoExists      = $0001;
      flFileInfoCantWrite   = $0002;
      flFileInfoCantRead    = $0004;
      flFileInfoInvalidName = $0008;
      cFileParameterError = -1;

// *** end of Data.pas
