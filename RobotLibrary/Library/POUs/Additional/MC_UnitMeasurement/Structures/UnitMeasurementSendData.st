{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      UnitMeasurementSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-30
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
TYPE UnitMeasurementSendData EXTENDS CmdHeader: 
STRUCT
  EmitterID     : ARRAY [0..3] OF SINT;
  /// ID of the trigger function that may be triggered:
  /// • 0: Immediately (default). - Start executing THIS function immediately.
  /// • >0: Triggero Start executing when the trigger function with the identical EmitterID is called.
  /// For more information see chapter 5.5.12.4.
  ListenerID    : SINT;
  /// Reserve
  Reserve       : BYTE;
  ///  Reaction type of measurement in relation to the trigger signal with the "ListenerID > 0" (at least one option must be supported):
  TriggerMode   : TriggerModeMeasurement;
  /// Relates to "TriggerMode" "No trigger related behavior".
  /// Set TRUE to start first measurement. Set TRUE again to receive new result data referring to previous rising edge of NewMeasurement.
  MeasurementNo : USINT;
  /// Type of measurement (at least one option must be supported). 
  /// If the parameter is changed during the active measurement, the RC returns an error
  MeasuringMode : MeasuringUnitMode;


END_STRUCT
END_TYPE


