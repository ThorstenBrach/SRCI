FUNCTION CMD_TYPE_TO_STRING : String
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CMD_TYPE_TO_STRING                                       
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
    CmdType.RobotTask                   : CMD_TYPE_TO_STRING := StrReplace('RobotTask ({0})','{0}'                  , UINT_TO_STRING(CmdType.RobotTask));   
  
    CmdType.ReadRobotData               : CMD_TYPE_TO_STRING := StrReplace('ReadRobotData ({0})','{0}'              , UINT_TO_STRING(CmdType.ReadRobotData));
  
    CmdType.EnableRobot                 : CMD_TYPE_TO_STRING := StrReplace('EnableRobot ({0})','{0}'                , UINT_TO_STRING(CmdType.EnableRobot));  
  
    CmdType.GroupReset                  : CMD_TYPE_TO_STRING := StrReplace('GroupReset ({0})','{0}'                 , UINT_TO_STRING(CmdType.GroupReset));  
  
    CmdType.ReadActualPosition          : CMD_TYPE_TO_STRING := StrReplace('ReadActualPosition ({0})','{0}'         , UINT_TO_STRING(CmdType.ReadActualPosition));
  
    CmdType.ReadActualPositionCyclic    : CMD_TYPE_TO_STRING := StrReplace('ReadActualPositionCyclic ({0})','{0}'   , UINT_TO_STRING(CmdType.ReadActualPositionCyclic));  
  
    CmdType.ReadDHParameter             : CMD_TYPE_TO_STRING := StrReplace('ReadDHParameter ({0})','{0}'            , UINT_TO_STRING(CmdType.ReadDHParameter));  
  
    CmdType.RestartController           : CMD_TYPE_TO_STRING := StrReplace('RestartController ({0})','{0}'          , UINT_TO_STRING(CmdType.RestartController));  
  
    CmdType.ReadActualTCPVelocity       : CMD_TYPE_TO_STRING := StrReplace('ReadActualTCPVelocity ({0})','{0}'      , UINT_TO_STRING(CmdType.ReadActualTCPVelocity));  
  
    CmdType.UserLogin                   : CMD_TYPE_TO_STRING := StrReplace('UserLogin ({0})','{0}'                  , UINT_TO_STRING(CmdType.UserLogin));
  
    CmdType.SwitchLanguage              : CMD_TYPE_TO_STRING := StrReplace('SwitchLanguage ({0})','{0}'             , UINT_TO_STRING(CmdType.SwitchLanguage));
  
    CmdType.ExchangeConfiguration       : CMD_TYPE_TO_STRING := StrReplace('ExchangeConfiguration ({0})','{0}'      , UINT_TO_STRING(CmdType.ExchangeConfiguration));
  
    CmdType.SetSequence                 : CMD_TYPE_TO_STRING := StrReplace('SetSequence ({0})','{0}'                , UINT_TO_STRING(CmdType.SetSequence));
  
    CmdType.ChangeSpeedOverride         : CMD_TYPE_TO_STRING := StrReplace('ChangeSpeedOverride ({0})','{0}'        , UINT_TO_STRING(CmdType.ChangeSpeedOverride));
  
    CmdType.ReadMessages                : CMD_TYPE_TO_STRING := StrReplace('ReadMessages ({0})','{0}'               , UINT_TO_STRING(CmdType.ReadMessages));
  
    CmdType.ReadRobotReferenceDynamics  : CMD_TYPE_TO_STRING := StrReplace('ReadRobotReferenceDynamics ({0})','{0}' , UINT_TO_STRING(CmdType.ReadRobotReferenceDynamics));  
  
    CmdType.WriteFrameData              : CMD_TYPE_TO_STRING := StrReplace('WriteFrameData ({0})','{0}'             , UINT_TO_STRING(CmdType.WriteFrameData));
  
    CmdType.WriteToolData               : CMD_TYPE_TO_STRING := StrReplace('WriteToolData ({0})','{0}'              , UINT_TO_STRING(CmdType.WriteToolData));
  
    CmdType.WriteLoadData               : CMD_TYPE_TO_STRING := StrReplace('WriteLoadData ({0})','{0}'              , UINT_TO_STRING(CmdType.WriteLoadData));
  
    CmdType.WriteRobotReferenceDynamics : CMD_TYPE_TO_STRING := StrReplace('WriteRobotReferenceDynamics ({0})','{0}', UINT_TO_STRING(CmdType.WriteRobotReferenceDynamics));
  
    CmdType.WriteRobotDefaultDynamics   : CMD_TYPE_TO_STRING := StrReplace('WriteRobotDefaultDynamics ({0})'  ,'{0}', UINT_TO_STRING(CmdType.WriteRobotDefaultDynamics));
  
    CmdType.ReadRobotDefaultDynamics    : CMD_TYPE_TO_STRING := StrReplace('ReadRobotDefaultDynamics ({0})'   ,'{0}', UINT_TO_STRING(CmdType.ReadRobotDefaultDynamics));
  
    CmdType.ReadFrameData               : CMD_TYPE_TO_STRING := StrReplace('ReadFrameData ({0})'              ,'{0}', UINT_TO_STRING(CmdType.ReadFrameData)); 
  
    CmdType.ReadToolData                : CMD_TYPE_TO_STRING := StrReplace('ReadToolData ({0})','{0}'               , UINT_TO_STRING(CmdType.ReadToolData));
  
    CmdType.ReadLoadData                : CMD_TYPE_TO_STRING := StrReplace('ReadLoadData ({0})','{0}'               , UINT_TO_STRING(CmdType.ReadLoadData));
  
    CmdType.ReadRobotSWLimits           : CMD_TYPE_TO_STRING := StrReplace('ReadRobotSWLimits ({0})','{0}'          , UINT_TO_STRING(CmdType.ReadRobotSWLimits));
  
    CmdType.WriteRobotSWLimits          : CMD_TYPE_TO_STRING := StrReplace('WriteRobotSWLimits ({0})','{0}'         , UINT_TO_STRING(CmdType.WriteRobotSWLimits));
  
    CmdType.SetOperationMode            : CMD_TYPE_TO_STRING := StrReplace('SetOperationMode ({0})','{0}'           , UINT_TO_STRING(CmdType.SetOperationMode));
  
    CmdType.ReadWorkArea                : CMD_TYPE_TO_STRING := StrReplace('ReadWorkArea ({0})','{0}'               , UINT_TO_STRING(CmdType.ReadWorkArea));
  
    CmdType.WriteWorkArea               : CMD_TYPE_TO_STRING := StrReplace('WriteWorkArea ({0})','{0}'              , UINT_TO_STRING(CmdType.WriteWorkArea));
  
    CmdType.ActivateWorkArea            : CMD_TYPE_TO_STRING := StrReplace('ActivateWorkArea ({0})','{0}'           , UINT_TO_STRING(CmdType.ActivateWorkArea));
  
    CmdType.MonitorWorkArea             : CMD_TYPE_TO_STRING := StrReplace('MonitorWorkArea ({0})','{0}'            , UINT_TO_STRING(CmdType.MonitorWorkArea));
  
    CmdType.GroupJog                    : CMD_TYPE_TO_STRING := StrReplace('GroupJog ({0})','{0}'                   , UINT_TO_STRING(CmdType.GroupJog));
  
    CmdType.MoveLinearAbsolute          : CMD_TYPE_TO_STRING := StrReplace('MoveLinearAbsolute ({0})','{0}'         , UINT_TO_STRING(CmdType.MoveLinearAbsolute));
  
    CmdType.MoveDirectAbsolute          : CMD_TYPE_TO_STRING := StrReplace('MoveDirectAbsolute ({0})','{0}'         , UINT_TO_STRING(CmdType.MoveDirectAbsolute));
  
    CmdType.MoveAxesAbsolute            : CMD_TYPE_TO_STRING := StrReplace('MoveAxesAbsolute ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveAxesAbsolute));
  
    CmdType.GroupStop                   : CMD_TYPE_TO_STRING := StrReplace('GroupStop ({0})','{0}'                  , UINT_TO_STRING(CmdType.GroupStop));
  
    CmdType.GroupInterrupt              : CMD_TYPE_TO_STRING := StrReplace('GroupInterrupt ({0})','{0}'             , UINT_TO_STRING(CmdType.GroupInterrupt));
  
    CmdType.GroupContinue               : CMD_TYPE_TO_STRING := StrReplace('GroupContinue ({0})','{0}'              , UINT_TO_STRING(CmdType.GroupContinue));
  
    CmdType.MoveLinearRelative          : CMD_TYPE_TO_STRING := StrReplace('MoveLinearRelative ({0})','{0}'         , UINT_TO_STRING(CmdType.MoveLinearRelative));
  
    CmdType.MoveDirectRelative          : CMD_TYPE_TO_STRING := StrReplace('MoveDirectRelative ({0})','{0}'         , UINT_TO_STRING(CmdType.MoveDirectRelative));
  
    CmdType.MoveAxesRelative            : CMD_TYPE_TO_STRING := StrReplace('MoveAxesRelative ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveAxesRelative));
  
    CmdType.ReturnToPrimary             : CMD_TYPE_TO_STRING := StrReplace('ReturnToPrimary ({0})','{0}'            , UINT_TO_STRING(CmdType.ReturnToPrimary));
  
    CmdType.MoveCircularAbsolute        : CMD_TYPE_TO_STRING := StrReplace('MoveCircularAbsolute ({0})','{0}'       , UINT_TO_STRING(CmdType.MoveCircularAbsolute));
  
    CmdType.MoveCircularRelative        : CMD_TYPE_TO_STRING := StrReplace('MoveCircularRelative ({0})','{0}'       , UINT_TO_STRING(CmdType.MoveCircularRelative));
  
    CmdType.MoveLinearOffset            : CMD_TYPE_TO_STRING := StrReplace('MoveLinearOffset ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveLinearOffset));
  
    CmdType.MoveDirectOffset            : CMD_TYPE_TO_STRING := StrReplace('MoveDirectOffset ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveDirectOffset));
  
    CmdType.WaitTime                    : CMD_TYPE_TO_STRING := StrReplace('WaitTime ({0})','{0}'                   , UINT_TO_STRING(CmdType.WaitTime));
  
    CmdType.MoveApproachLinear          : CMD_TYPE_TO_STRING := StrReplace('MoveApproachLinear ({0})','{0}'         , UINT_TO_STRING(CmdType.MoveApproachLinear));
  
    CmdType.MoveDepartLinear            : CMD_TYPE_TO_STRING := StrReplace('MoveDepartLinear ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveDepartLinear));
  
    CmdType.MoveApproachDirect          : CMD_TYPE_TO_STRING := StrReplace('MoveApproachDirect ({0})','{0}'         , UINT_TO_STRING(CmdType.MoveApproachDirect));
  
    CmdType.MoveDepartDirect            : CMD_TYPE_TO_STRING := StrReplace('MoveDepartDirect ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveDepartDirect));
  
    CmdType.SearchHardstop              : CMD_TYPE_TO_STRING := StrReplace('SearchHardstop ({0})','{0}'             , UINT_TO_STRING(CmdType.SearchHardstop));
  
    CmdType.SearchHardstopJ             : CMD_TYPE_TO_STRING := StrReplace('SearchHardstopJ ({0})','{0}'            , UINT_TO_STRING(CmdType.SearchHardstopJ));
  
    CmdType.MovePickPlaceLinear         : CMD_TYPE_TO_STRING := StrReplace('MovePickPlaceLinear ({0})','{0}'        , UINT_TO_STRING(CmdType.MovePickPlaceLinear));
  
    CmdType.MovePickPlaceDirect         : CMD_TYPE_TO_STRING := StrReplace('MovePickPlaceDirect ({0})','{0}'        , UINT_TO_STRING(CmdType.MovePickPlaceDirect));  
  
    CmdType.ActivateConveyorTracking    : CMD_TYPE_TO_STRING := StrReplace('ActivateConveyorTracking ({0})','{0}'   , UINT_TO_STRING(CmdType.ActivateConveyorTracking));
  
    CmdType.RedefineTrackingPos         : CMD_TYPE_TO_STRING := StrReplace('RedefineTrackingPos ({0})','{0}'        , UINT_TO_STRING(CmdType.RedefineTrackingPos));
  
    CmdType.SyncToConveyor              : CMD_TYPE_TO_STRING := StrReplace('SyncToConveyor ({0})','{0}'             , UINT_TO_STRING(CmdType.SyncToConveyor));
  
    CmdType.ConfigureConveyor           : CMD_TYPE_TO_STRING := StrReplace('ConfigureConveyor ({0})','{0}'          , UINT_TO_STRING(CmdType.ConfigureConveyor));
  
    CmdType.MoveSuperImposed            : CMD_TYPE_TO_STRING := StrReplace('MoveSuperImposed ({0})','{0}'           , UINT_TO_STRING(CmdType.MoveSuperImposed));
  
    CmdType.MoveSuperImposedDynamic     : CMD_TYPE_TO_STRING := StrReplace('MoveSuperImposedDynamic ({0})','{0}'    , UINT_TO_STRING(CmdType.MoveSuperImposedDynamic));
  
    CmdType.ReadDigitalInputs           : CMD_TYPE_TO_STRING := StrReplace('ReadDigitalInputs ({0})','{0}'          , UINT_TO_STRING(CmdType.ReadDigitalInputs));
  
    CmdType.ReadDigitalOutputs          : CMD_TYPE_TO_STRING := StrReplace('ReadDigitalOutputs ({0})','{0}'         , UINT_TO_STRING(CmdType.ReadDigitalOutputs));
  
    CmdType.WriteDigitalOutputs         : CMD_TYPE_TO_STRING := StrReplace('WriteDigitalOutputs ({0})','{0}'        , UINT_TO_STRING(CmdType.WriteDigitalOutputs));
  
    CmdType.ReadIntegers                : CMD_TYPE_TO_STRING := StrReplace('ReadIntegers ({0})','{0}'               , UINT_TO_STRING(CmdType.ReadIntegers));
  
    CmdType.ReadReals                   : CMD_TYPE_TO_STRING := StrReplace('ReadReals ({0})','{0}'                  , UINT_TO_STRING(CmdType.ReadReals));
  
    CmdType.WriteIntegers               : CMD_TYPE_TO_STRING := StrReplace('WriteIntegers ({0})','{0}'              , UINT_TO_STRING(CmdType.WriteIntegers));
  
    CmdType.WriteReals                  : CMD_TYPE_TO_STRING := StrReplace('WriteReals ({0})','{0}'                 , UINT_TO_STRING(CmdType.WriteReals));
  
    CmdType.MoveLinearCam               : CMD_TYPE_TO_STRING := StrReplace('MoveLinearCam ({0})','{0}'              , UINT_TO_STRING(CmdType.MoveLinearCam));
  
    CmdType.MoveDirectCam               : CMD_TYPE_TO_STRING := StrReplace('MoveDirectCam ({0})','{0}'              , UINT_TO_STRING(CmdType.MoveDirectCam));
  
    CmdType.MoveCircularCam             : CMD_TYPE_TO_STRING := StrReplace('MoveCircularCam ({0})','{0}'            , UINT_TO_STRING(CmdType.MoveCircularCam));
  
    CmdType.ReadAnalogInput             : CMD_TYPE_TO_STRING := StrReplace('ReadAnalogInput ({0})','{0}'            , UINT_TO_STRING(CmdType.ReadAnalogInput));
  
    CmdType.ReadAnalogOutput            : CMD_TYPE_TO_STRING := StrReplace('ReadAnalogOutput ({0})','{0}'           , UINT_TO_STRING(CmdType.ReadAnalogOutput));
  
    CmdType.WriteAnalogOutput           : CMD_TYPE_TO_STRING := StrReplace('WriteAnalogOutput ({0})','{0}'          , UINT_TO_STRING(CmdType.WriteAnalogOutput));
  
    CmdType.MeasuringInput              : CMD_TYPE_TO_STRING := StrReplace('MeasuringInput ({0})','{0}'             , UINT_TO_STRING(CmdType.MeasuringInput));
  
    CmdType.AbortMeasuringInput         : CMD_TYPE_TO_STRING := StrReplace('AbortMeasuringInput ({0})','{0}'        , UINT_TO_STRING(CmdType.AbortMeasuringInput));
  
    CmdType.SetTriggerRegister          : CMD_TYPE_TO_STRING := StrReplace('SetTriggerRegister ({0})','{0}'         , UINT_TO_STRING(CmdType.SetTriggerRegister));
  
    CmdType.SetTriggerLimit             : CMD_TYPE_TO_STRING := StrReplace('SetTriggerLimit ({0})','{0}'            , UINT_TO_STRING(CmdType.SetTriggerLimit));
  
    CmdType.SetTriggerUser              : CMD_TYPE_TO_STRING := StrReplace('SetTriggerUser ({0})','{0}'             , UINT_TO_STRING(CmdType.SetTriggerUser));
  
    CmdType.SetTriggerError             : CMD_TYPE_TO_STRING := StrReplace('SetTriggerError ({0})','{0}'            , UINT_TO_STRING(CmdType.SetTriggerError));
  
    CmdType.ReactAtTrigger              : CMD_TYPE_TO_STRING := StrReplace('ReactAtTrigger ({0})','{0}'             , UINT_TO_STRING(CmdType.ReactAtTrigger));
  
    CmdType.WaitForTrigger              : CMD_TYPE_TO_STRING := StrReplace('WaitForTrigger ({0})','{0}'             , UINT_TO_STRING(CmdType.WaitForTrigger));
  
    CmdType.ReadSystemVariable          : CMD_TYPE_TO_STRING := StrReplace('ReadSystemVariable ({0})','{0}'         , UINT_TO_STRING(CmdType.ReadSystemVariable));
  
    CmdType.WriteSystemVariable         : CMD_TYPE_TO_STRING := StrReplace('WriteSystemVariable ({0})','{0}'        , UINT_TO_STRING(CmdType.WriteSystemVariable));
  
    CmdType.CalculateForwardKinematic   : CMD_TYPE_TO_STRING := StrReplace('CalculateForwardKinematic ({0})','{0}'  , UINT_TO_STRING(CmdType.CalculateForwardKinematic));
  
    CmdType.CalculateInverseKinematic   : CMD_TYPE_TO_STRING := StrReplace('CalculateInverseKinematic ({0})','{0}'  , UINT_TO_STRING(CmdType.CalculateInverseKinematic));
  
    CmdType.CalculateCartesianPosition  : CMD_TYPE_TO_STRING := StrReplace('CalculateCartesianPosition ({0})','{0}' , UINT_TO_STRING(CmdType.CalculateCartesianPosition));
  
    CmdType.CalculateTool               : CMD_TYPE_TO_STRING := StrReplace('CalculateTool ({0})','{0}'              , UINT_TO_STRING(CmdType.CalculateTool));
  
    CmdType.CalculateFrame              : CMD_TYPE_TO_STRING := StrReplace('CalculateFrame ({0})','{0}'             , UINT_TO_STRING(CmdType.CalculateFrame));
  
    CmdType.ActivateNextCommand         : CMD_TYPE_TO_STRING := StrReplace('ActivateNextCommand ({0})','{0}'        , UINT_TO_STRING(CmdType.ActivateNextCommand));
  
    CmdType.ShiftPosition               : CMD_TYPE_TO_STRING := StrReplace('ShiftPosition ({0})','{0}'              , UINT_TO_STRING(CmdType.ShiftPosition));
  
    CmdType.SetTriggerMotion            : CMD_TYPE_TO_STRING := StrReplace('SetTriggerMotion ({0})','{0}'           , UINT_TO_STRING(CmdType.SetTriggerMotion));
  
    CmdType.OpenBrake                   : CMD_TYPE_TO_STRING := StrReplace('OpenBrake ({0})','{0}'                  , UINT_TO_STRING(CmdType.OpenBrake));
  
    CmdType.CallSubprogram              : CMD_TYPE_TO_STRING := StrReplace('CallSubprogram ({0})','{0}'             , UINT_TO_STRING(CmdType.CallSubprogram));
  
    CmdType.WriteCallSubprogramCyclic   : CMD_TYPE_TO_STRING := StrReplace('WriteCallSubprogramCyclic ({0})','{0}'  , UINT_TO_STRING(CmdType.WriteCallSubprogramCyclic));
  
    CmdType.ReadCallSubprogramCyclic    : CMD_TYPE_TO_STRING := StrReplace('ReadCallSubprogramCyclic ({0})','{0}'   , UINT_TO_STRING(CmdType.ReadCallSubprogramCyclic));
  
    CmdType.StopSubprogram              : CMD_TYPE_TO_STRING := StrReplace('StopSubprogram ({0})','{0}'             , UINT_TO_STRING(CmdType.StopSubprogram));
  
    CmdType.PathAccuracyMode            : CMD_TYPE_TO_STRING := StrReplace('PathAccuracyMode ({0})','{0}'           , UINT_TO_STRING(CmdType.PathAccuracyMode));
  
    CmdType.AvoidSingularity            : CMD_TYPE_TO_STRING := StrReplace('AvoidSingularity ({0})','{0}'           , UINT_TO_STRING(CmdType.AvoidSingularity));
  
    CmdType.ForceControl                : CMD_TYPE_TO_STRING := StrReplace('ForceControl ({0})','{0}'               , UINT_TO_STRING(CmdType.ForceControl));
  
    CmdType.ForceLimit                  : CMD_TYPE_TO_STRING := StrReplace('ForceLimit ({0})','{0}'                 , UINT_TO_STRING(CmdType.ForceLimit));
  
    CmdType.ReadActualForce             : CMD_TYPE_TO_STRING := StrReplace('ReadActualForce ({0})','{0}'            , UINT_TO_STRING(CmdType.ReadActualForce));
  
    CmdType.BrakeTest                   : CMD_TYPE_TO_STRING := StrReplace('BrakeTest ({0})','{0}'                  , UINT_TO_STRING(CmdType.BrakeTest));
  
    CmdType.SoftSwitchTCP               : CMD_TYPE_TO_STRING := StrReplace('SoftSwitchTCP ({0})','{0}'              , UINT_TO_STRING(CmdType.SoftSwitchTCP));
  
    CmdType.CreateSpline                : CMD_TYPE_TO_STRING := StrReplace('CreateSpline ({0})','{0}'               , UINT_TO_STRING(CmdType.CreateSpline));
  
    CmdType.DeleteSpline                : CMD_TYPE_TO_STRING := StrReplace('DeleteSpline ({0})','{0}'               , UINT_TO_STRING(CmdType.DeleteSpline));
  
    CmdType.MoveSpline                  : CMD_TYPE_TO_STRING := StrReplace('MoveSpline ({0})','{0}'                 , UINT_TO_STRING(CmdType.MoveSpline));
  
    CmdType.DynamicSpline               : CMD_TYPE_TO_STRING := StrReplace('DynamicSpline ({0})','{0}'              , UINT_TO_STRING(CmdType.DynamicSpline));
  
    CmdType.LoadMeasurementAutomatic    : CMD_TYPE_TO_STRING := StrReplace('LoadMeasurementAutomatic ({0})','{0}'   , UINT_TO_STRING(CmdType.LoadMeasurementAutomatic));
  
    CmdType.LoadMeasurementSequential   : CMD_TYPE_TO_STRING := StrReplace('LoadMeasurementSequential ({0})','{0}'  , UINT_TO_STRING(CmdType.LoadMeasurementSequential));
  
    CmdType.CollisionDetection          : CMD_TYPE_TO_STRING := StrReplace('CollisionDetection ({0})','{0}'         , UINT_TO_STRING(CmdType.CollisionDetection));
  
    CmdType.FreeDrive                   : CMD_TYPE_TO_STRING := StrReplace('FreeDrive ({0})','{0}'                  , UINT_TO_STRING(CmdType.FreeDrive)); 
  
    CmdType.UnitMeasurement             : CMD_TYPE_TO_STRING := StrReplace('UnitMeasurement ({0})','{0}'            , UINT_TO_STRING(CmdType.UnitMeasurement));
  
  ELSE
    CMD_TYPE_TO_STRING := CONCAT('CMD_TYPE_TO_STRING Function: Error -> no parsing for value',UINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

