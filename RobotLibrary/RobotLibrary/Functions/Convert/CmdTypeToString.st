FUNCTION CmdTypeToString : String
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CmdTypeToString                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-11-16
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the LGPL-3.0 license.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// command type
  Value : CmdType;
END_VAR

  CASE Value 
  OF
    CmdType.RobotTask                   : CmdTypeToString := StrReplace('RobotTask ({0})','{0}'                  , UINT_TO_STRING(CmdType.RobotTask));   
  
    CmdType.ReadRobotData               : CmdTypeToString := StrReplace('ReadRobotData ({0})','{0}'              , UINT_TO_STRING(CmdType.ReadRobotData));
  
    CmdType.EnableRobot                 : CmdTypeToString := StrReplace('EnableRobot ({0})','{0}'                , UINT_TO_STRING(CmdType.EnableRobot));  
  
    CmdType.GroupReset                  : CmdTypeToString := StrReplace('GroupReset ({0})','{0}'                 , UINT_TO_STRING(CmdType.GroupReset));  
  
    CmdType.ReadActualPosition          : CmdTypeToString := StrReplace('ReadActualPosition ({0})','{0}'         , UINT_TO_STRING(CmdType.ReadActualPosition));
  
    CmdType.ReadActualPositionCyclic    : CmdTypeToString := StrReplace('ReadActualPositionCyclic ({0})','{0}'   , UINT_TO_STRING(CmdType.ReadActualPositionCyclic));  
  
    CmdType.ReadDHParameter             : CmdTypeToString := StrReplace('ReadDHParameter ({0})','{0}'            , UINT_TO_STRING(CmdType.ReadDHParameter));  
  
    CmdType.RestartController           : CmdTypeToString := StrReplace('RestartController ({0})','{0}'          , UINT_TO_STRING(CmdType.RestartController));  
  
    CmdType.ReadActualTCPVelocity       : CmdTypeToString := StrReplace('ReadActualTCPVelocity ({0})','{0}'      , UINT_TO_STRING(CmdType.ReadActualTCPVelocity));  
  
    CmdType.UserLogin                   : CmdTypeToString := StrReplace('UserLogin ({0})','{0}'                  , UINT_TO_STRING(CmdType.UserLogin));
  
    CmdType.SwitchLanguage              : CmdTypeToString := StrReplace('SwitchLanguage ({0})','{0}'             , UINT_TO_STRING(CmdType.SwitchLanguage));
  
    CmdType.ExchangeConfiguration       : CmdTypeToString := StrReplace('ExchangeConfiguration ({0})','{0}'      , UINT_TO_STRING(CmdType.ExchangeConfiguration));
  
    CmdType.SetSequence                 : CmdTypeToString := StrReplace('SetSequence ({0})','{0}'                , UINT_TO_STRING(CmdType.SetSequence));
  
    CmdType.ChangeSpeedOverride         : CmdTypeToString := StrReplace('ChangeSpeedOverride ({0})','{0}'        , UINT_TO_STRING(CmdType.ChangeSpeedOverride));
  
    CmdType.ReadMessages                : CmdTypeToString := StrReplace('ReadMessages ({0})','{0}'               , UINT_TO_STRING(CmdType.ReadMessages));
  
    CmdType.ReadRobotReferenceDynamics  : CmdTypeToString := StrReplace('ReadRobotReferenceDynamics ({0})','{0}' , UINT_TO_STRING(CmdType.ReadRobotReferenceDynamics));  
  
    CmdType.WriteFrameData              : CmdTypeToString := StrReplace('WriteFrameData ({0})','{0}'             , UINT_TO_STRING(CmdType.WriteFrameData));
  
    CmdType.WriteToolData               : CmdTypeToString := StrReplace('WriteToolData ({0})','{0}'              , UINT_TO_STRING(CmdType.WriteToolData));
  
    CmdType.WriteLoadData               : CmdTypeToString := StrReplace('WriteLoadData ({0})','{0}'              , UINT_TO_STRING(CmdType.WriteLoadData));
  
    CmdType.WriteRobotReferenceDynamics : CmdTypeToString := StrReplace('WriteRobotReferenceDynamics ({0})','{0}', UINT_TO_STRING(CmdType.WriteRobotReferenceDynamics));
  
    CmdType.WriteRobotDefaultDynamics   : CmdTypeToString := StrReplace('WriteRobotDefaultDynamics ({0})'  ,'{0}', UINT_TO_STRING(CmdType.WriteRobotDefaultDynamics));
  
    CmdType.ReadRobotDefaultDynamics    : CmdTypeToString := StrReplace('ReadRobotDefaultDynamics ({0})'   ,'{0}', UINT_TO_STRING(CmdType.ReadRobotDefaultDynamics));
  
    CmdType.ReadFrameData               : CmdTypeToString := StrReplace('ReadFrameData ({0})'              ,'{0}', UINT_TO_STRING(CmdType.ReadFrameData)); 
  
    CmdType.ReadToolData                : CmdTypeToString := StrReplace('ReadToolData ({0})','{0}'               , UINT_TO_STRING(CmdType.ReadToolData));
  
    CmdType.ReadLoadData                : CmdTypeToString := StrReplace('ReadLoadData ({0})','{0}'               , UINT_TO_STRING(CmdType.ReadLoadData));
  
    CmdType.ReadRobotSWLimits           : CmdTypeToString := StrReplace('ReadRobotSWLimits ({0})','{0}'          , UINT_TO_STRING(CmdType.ReadRobotSWLimits));
  
    CmdType.WriteRobotSWLimits          : CmdTypeToString := StrReplace('WriteRobotSWLimits ({0})','{0}'         , UINT_TO_STRING(CmdType.WriteRobotSWLimits));
  
    CmdType.SetOperationMode            : CmdTypeToString := StrReplace('SetOperationMode ({0})','{0}'           , UINT_TO_STRING(CmdType.SetOperationMode));
  
    CmdType.ReadWorkArea                : CmdTypeToString := StrReplace('ReadWorkArea ({0})','{0}'               , UINT_TO_STRING(CmdType.ReadWorkArea));
  
    CmdType.WriteWorkArea               : CmdTypeToString := StrReplace('WriteWorkArea ({0})','{0}'              , UINT_TO_STRING(CmdType.WriteWorkArea));
  
    CmdType.ActivateWorkArea            : CmdTypeToString := StrReplace('ActivateWorkArea ({0})','{0}'           , UINT_TO_STRING(CmdType.ActivateWorkArea));
  
    CmdType.MonitorWorkArea             : CmdTypeToString := StrReplace('MonitorWorkArea ({0})','{0}'            , UINT_TO_STRING(CmdType.MonitorWorkArea));
  
    CmdType.GroupJog                    : CmdTypeToString := StrReplace('GroupJog ({0})','{0}'                   , UINT_TO_STRING(CmdType.GroupJog));
  
    CmdType.MoveLinearAbsolute          : CmdTypeToString := StrReplace('MoveLinearAbsolute ({0})','{0}'         , UINT_TO_STRING(CmdType.MoveLinearAbsolute));
  
    CmdType.MoveDirectAbsolute          : CmdTypeToString := StrReplace('MoveDirectAbsolute ({0})','{0}'         , UINT_TO_STRING(CmdType.MoveDirectAbsolute));
  
    CmdType.MoveAxesAbsolute            : CmdTypeToString := StrReplace('MoveAxesAbsolute ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveAxesAbsolute));
  
    CmdType.GroupStop                   : CmdTypeToString := StrReplace('GroupStop ({0})','{0}'                  , UINT_TO_STRING(CmdType.GroupStop));
  
    CmdType.GroupInterrupt              : CmdTypeToString := StrReplace('GroupInterrupt ({0})','{0}'             , UINT_TO_STRING(CmdType.GroupInterrupt));
  
    CmdType.GroupContinue               : CmdTypeToString := StrReplace('GroupContinue ({0})','{0}'              , UINT_TO_STRING(CmdType.GroupContinue));
  
    CmdType.MoveLinearRelative          : CmdTypeToString := StrReplace('MoveLinearRelative ({0})','{0}'         , UINT_TO_STRING(CmdType.MoveLinearRelative));
  
    CmdType.MoveDirectRelative          : CmdTypeToString := StrReplace('MoveDirectRelative ({0})','{0}'         , UINT_TO_STRING(CmdType.MoveDirectRelative));
  
    CmdType.MoveAxesRelative            : CmdTypeToString := StrReplace('MoveAxesRelative ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveAxesRelative));
  
    CmdType.ReturnToPrimary             : CmdTypeToString := StrReplace('ReturnToPrimary ({0})','{0}'            , UINT_TO_STRING(CmdType.ReturnToPrimary));
  
    CmdType.MoveCircularAbsolute        : CmdTypeToString := StrReplace('MoveCircularAbsolute ({0})','{0}'       , UINT_TO_STRING(CmdType.MoveCircularAbsolute));
  
    CmdType.MoveCircularRelative        : CmdTypeToString := StrReplace('MoveCircularRelative ({0})','{0}'       , UINT_TO_STRING(CmdType.MoveCircularRelative));
  
    CmdType.MoveLinearOffset            : CmdTypeToString := StrReplace('MoveLinearOffset ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveLinearOffset));
  
    CmdType.MoveDirectOffset            : CmdTypeToString := StrReplace('MoveDirectOffset ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveDirectOffset));
  
    CmdType.WaitTime                    : CmdTypeToString := StrReplace('WaitTime ({0})','{0}'                   , UINT_TO_STRING(CmdType.WaitTime));
  
    CmdType.MoveApproachLinear          : CmdTypeToString := StrReplace('MoveApproachLinear ({0})','{0}'         , UINT_TO_STRING(CmdType.MoveApproachLinear));
  
    CmdType.MoveDepartLinear            : CmdTypeToString := StrReplace('MoveDepartLinear ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveDepartLinear));
  
    CmdType.MoveApproachDirect          : CmdTypeToString := StrReplace('MoveApproachDirect ({0})','{0}'         , UINT_TO_STRING(CmdType.MoveApproachDirect));
  
    CmdType.MoveDepartDirect            : CmdTypeToString := StrReplace('MoveDepartDirect ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveDepartDirect));
  
    CmdType.SearchHardstop              : CmdTypeToString := StrReplace('SearchHardstop ({0})','{0}'             , UINT_TO_STRING(CmdType.SearchHardstop));
  
    CmdType.SearchHardstopJ             : CmdTypeToString := StrReplace('SearchHardstopJ ({0})','{0}'            , UINT_TO_STRING(CmdType.SearchHardstopJ));
  
    CmdType.MovePickPlaceLinear         : CmdTypeToString := StrReplace('MovePickPlaceLinear ({0})','{0}'        , UINT_TO_STRING(CmdType.MovePickPlaceLinear));
  
    CmdType.MovePickPlaceDirect         : CmdTypeToString := StrReplace('MovePickPlaceDirect ({0})','{0}'        , UINT_TO_STRING(CmdType.MovePickPlaceDirect));  
  
    CmdType.ActivateConveyorTracking    : CmdTypeToString := StrReplace('ActivateConveyorTracking ({0})','{0}'   , UINT_TO_STRING(CmdType.ActivateConveyorTracking));
  
    CmdType.RedefineTrackingPos         : CmdTypeToString := StrReplace('RedefineTrackingPos ({0})','{0}'        , UINT_TO_STRING(CmdType.RedefineTrackingPos));
  
    CmdType.SyncToConveyor              : CmdTypeToString := StrReplace('SyncToConveyor ({0})','{0}'             , UINT_TO_STRING(CmdType.SyncToConveyor));
  
    CmdType.ConfigureConveyor           : CmdTypeToString := StrReplace('ConfigureConveyor ({0})','{0}'          , UINT_TO_STRING(CmdType.ConfigureConveyor));
  
    CmdType.MoveSuperImposed            : CmdTypeToString := StrReplace('MoveSuperImposed ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveSuperImposed));
  
    CmdType.MoveSuperImposedDynamic     : CmdTypeToString := StrReplace('MoveSuperImposedDynamic ({0})','{0}'    , UINT_TO_STRING(CmdType.MoveSuperImposedDynamic));
  
    CmdType.ReadDigitalInputs           : CmdTypeToString := StrReplace('ReadDigitalInputs ({0})','{0}'          , UINT_TO_STRING(CmdType.ReadDigitalInputs));
  
    CmdType.ReadDigitalOutputs          : CmdTypeToString := StrReplace('ReadDigitalOutputs ({0})','{0}'         , UINT_TO_STRING(CmdType.ReadDigitalOutputs));
  
    CmdType.WriteDigitalOutputs         : CmdTypeToString := StrReplace('WriteDigitalOutputs ({0})','{0}'        , UINT_TO_STRING(CmdType.WriteDigitalOutputs));
  
    CmdType.ReadIntegers                : CmdTypeToString := StrReplace('ReadIntegers ({0})','{0}'               , UINT_TO_STRING(CmdType.ReadIntegers));
  
    CmdType.ReadReals                   : CmdTypeToString := StrReplace('ReadReals ({0})','{0}'                  , UINT_TO_STRING(CmdType.ReadReals));
  
    CmdType.WriteIntegers               : CmdTypeToString := StrReplace('WriteIntegers ({0})','{0}'              , UINT_TO_STRING(CmdType.WriteIntegers));
  
    CmdType.WriteReals                  : CmdTypeToString := StrReplace('WriteReals ({0})','{0}'                 , UINT_TO_STRING(CmdType.WriteReals));
  
    CmdType.MoveLinearCam               : CmdTypeToString := StrReplace('MoveLinearCam ({0})','{0}'              , UINT_TO_STRING(CmdType.MoveLinearCam));
  
    CmdType.MoveDirectCam               : CmdTypeToString := StrReplace('MoveDirectCam ({0})','{0}'              , UINT_TO_STRING(CmdType.MoveDirectCam));
  
    CmdType.MoveCircularCam             : CmdTypeToString := StrReplace('MoveCircularCam ({0})','{0}'            , UINT_TO_STRING(CmdType.MoveCircularCam));
  
    CmdType.ReadAnalogInput             : CmdTypeToString := StrReplace('ReadAnalogInput ({0})','{0}'            , UINT_TO_STRING(CmdType.ReadAnalogInput));
  
    CmdType.ReadAnalogOutput            : CmdTypeToString := StrReplace('ReadAnalogOutput ({0})','{0}'           , UINT_TO_STRING(CmdType.ReadAnalogOutput));
  
    CmdType.WriteAnalogOutput           : CmdTypeToString := StrReplace('WriteAnalogOutput ({0})','{0}'          , UINT_TO_STRING(CmdType.WriteAnalogOutput));
  
    CmdType.MeasuringInput              : CmdTypeToString := StrReplace('MeasuringInput ({0})','{0}'             , UINT_TO_STRING(CmdType.MeasuringInput));
  
    CmdType.AbortMeasuringInput         : CmdTypeToString := StrReplace('AbortMeasuringInput ({0})','{0}'        , UINT_TO_STRING(CmdType.AbortMeasuringInput));
  
    CmdType.SetTriggerRegister          : CmdTypeToString := StrReplace('SetTriggerRegister ({0})','{0}'         , UINT_TO_STRING(CmdType.SetTriggerRegister));
  
    CmdType.SetTriggerLimit             : CmdTypeToString := StrReplace('SetTriggerLimit ({0})','{0}'            , UINT_TO_STRING(CmdType.SetTriggerLimit));
  
    CmdType.SetTriggerUser              : CmdTypeToString := StrReplace('SetTriggerUser ({0})','{0}'             , UINT_TO_STRING(CmdType.SetTriggerUser));
  
    CmdType.SetTriggerError             : CmdTypeToString := StrReplace('SetTriggerError ({0})','{0}'            , UINT_TO_STRING(CmdType.SetTriggerError));
  
    CmdType.ReactAtTrigger              : CmdTypeToString := StrReplace('ReactAtTrigger ({0})','{0}'             , UINT_TO_STRING(CmdType.ReactAtTrigger));
  
    CmdType.WaitForTrigger              : CmdTypeToString := StrReplace('WaitForTrigger ({0})','{0}'             , UINT_TO_STRING(CmdType.WaitForTrigger));
  
    CmdType.ReadSystemVariable          : CmdTypeToString := StrReplace('ReadSystemVariable ({0})','{0}'         , UINT_TO_STRING(CmdType.ReadSystemVariable));
  
    CmdType.WriteSystemVariable         : CmdTypeToString := StrReplace('WriteSystemVariable ({0})','{0}'        , UINT_TO_STRING(CmdType.WriteSystemVariable));
  
    CmdType.CalculateForwardKinematic   : CmdTypeToString := StrReplace('CalculateForwardKinematic ({0})','{0}'  , UINT_TO_STRING(CmdType.CalculateForwardKinematic));
  
    CmdType.CalculateInverseKinematic   : CmdTypeToString := StrReplace('CalculateInverseKinematic ({0})','{0}'  , UINT_TO_STRING(CmdType.CalculateInverseKinematic));
  
    CmdType.CalculateCartesianPosition  : CmdTypeToString := StrReplace('CalculateCartesianPosition ({0})','{0}' , UINT_TO_STRING(CmdType.CalculateCartesianPosition));
  
    CmdType.CalculateTool               : CmdTypeToString := StrReplace('CalculateTool ({0})','{0}'              , UINT_TO_STRING(CmdType.CalculateTool));
  
    CmdType.CalculateFrame              : CmdTypeToString := StrReplace('CalculateFrame ({0})','{0}'             , UINT_TO_STRING(CmdType.CalculateFrame));
  
    CmdType.ActivateNextCommand         : CmdTypeToString := StrReplace('ActivateNextCommand ({0})','{0}'        , UINT_TO_STRING(CmdType.ActivateNextCommand));
  
    CmdType.ShiftPosition               : CmdTypeToString := StrReplace('ShiftPosition ({0})','{0}'              , UINT_TO_STRING(CmdType.ShiftPosition));
  
    CmdType.SetTriggerMotion            : CmdTypeToString := StrReplace('SetTriggerMotion ({0})','{0}'           , UINT_TO_STRING(CmdType.SetTriggerMotion));
  
    CmdType.OpenBrake                   : CmdTypeToString := StrReplace('OpenBrake ({0})','{0}'                  , UINT_TO_STRING(CmdType.OpenBrake));
  
    CmdType.CallSubprogram              : CmdTypeToString := StrReplace('CallSubprogram ({0})','{0}'             , UINT_TO_STRING(CmdType.CallSubprogram));
  
    CmdType.WriteCallSubprogramCyclic   : CmdTypeToString := StrReplace('WriteCallSubprogramCyclic ({0})','{0}'  , UINT_TO_STRING(CmdType.WriteCallSubprogramCyclic));
  
    CmdType.ReadCallSubprogramCyclic    : CmdTypeToString := StrReplace('ReadCallSubprogramCyclic ({0})','{0}'   , UINT_TO_STRING(CmdType.ReadCallSubprogramCyclic));
  
    CmdType.StopSubprogram              : CmdTypeToString := StrReplace('StopSubprogram ({0})','{0}'             , UINT_TO_STRING(CmdType.StopSubprogram));
  
    CmdType.PathAccuracyMode            : CmdTypeToString := StrReplace('PathAccuracyMode ({0})','{0}'           , UINT_TO_STRING(CmdType.PathAccuracyMode));
  
    CmdType.AvoidSingularity            : CmdTypeToString := StrReplace('AvoidSingularity ({0})','{0}'           , UINT_TO_STRING(CmdType.AvoidSingularity));
  
    CmdType.ForceControl                : CmdTypeToString := StrReplace('ForceControl ({0})','{0}'               , UINT_TO_STRING(CmdType.ForceControl));
  
    CmdType.ForceLimit                  : CmdTypeToString := StrReplace('ForceLimit ({0})','{0}'                 , UINT_TO_STRING(CmdType.ForceLimit));
  
    CmdType.ReadActualForce             : CmdTypeToString := StrReplace('ReadActualForce ({0})','{0}'            , UINT_TO_STRING(CmdType.ReadActualForce));
  
    CmdType.BrakeTest                   : CmdTypeToString := StrReplace('BrakeTest ({0})','{0}'                  , UINT_TO_STRING(CmdType.BrakeTest));
  
    CmdType.SoftSwitchTCP               : CmdTypeToString := StrReplace('SoftSwitchTCP ({0})','{0}'              , UINT_TO_STRING(CmdType.SoftSwitchTCP));
  
    CmdType.CreateSpline                : CmdTypeToString := StrReplace('CreateSpline ({0})','{0}'               , UINT_TO_STRING(CmdType.CreateSpline));
  
    CmdType.DeleteSpline                : CmdTypeToString := StrReplace('DeleteSpline ({0})','{0}'               , UINT_TO_STRING(CmdType.DeleteSpline));
  
    CmdType.MoveSpline                  : CmdTypeToString := StrReplace('MoveSpline ({0})','{0}'                 , UINT_TO_STRING(CmdType.MoveSpline));
  
    CmdType.DynamicSpline               : CmdTypeToString := StrReplace('DynamicSpline ({0})','{0}'              , UINT_TO_STRING(CmdType.DynamicSpline));
  
    CmdType.LoadMeasurementAutomatic    : CmdTypeToString := StrReplace('LoadMeasurementAutomatic ({0})','{0}'   , UINT_TO_STRING(CmdType.LoadMeasurementAutomatic));
  
    CmdType.LoadMeasurementSequential   : CmdTypeToString := StrReplace('LoadMeasurementSequential ({0})','{0}'  , UINT_TO_STRING(CmdType.LoadMeasurementSequential));
  
    CmdType.CollisionDetection          : CmdTypeToString := StrReplace('CollisionDetection ({0})','{0}'         , UINT_TO_STRING(CmdType.CollisionDetection));
  
    CmdType.FreeDrive                   : CmdTypeToString := StrReplace('FreeDrive ({0})','{0}'                  , UINT_TO_STRING(CmdType.FreeDrive)); 
  
    CmdType.UnitMeasurement             : CmdTypeToString := StrReplace('UnitMeasurement ({0})','{0}'            , UINT_TO_STRING(CmdType.UnitMeasurement));
  
  ELSE
    CmdTypeToString := CONCAT('CmdTypeToString-Function: Error -> no parsing for value',UINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

