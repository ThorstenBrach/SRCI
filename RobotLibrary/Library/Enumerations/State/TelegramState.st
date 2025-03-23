{attribute 'qualified_only'}
TYPE TelegramState :
(
  /// Default
  UNDEFINED := 0,
  /// Telegram control does not match the telegram state
  ERROR_161 := 161,
  /// Initialization lost for unknown reason. See message log after reinitializing
  ERROR_162 := 162,
  /// Telegram length does not match the length provided in the communication interface.
  ERROR_163 := 163,
  /// Incompatible major SRCI version
  ERROR_164 := 164,
  /// Lifesign timeout
  ERROR_165 := 165,
  /// The selected optional cyclic data does not fit in the given telegram size
  ERROR_166 := 166,
  /// The robot interface was reset after being initialized
  ERROR_167 := 167,
  /// Telegram sequence timeout
  ERROR_168 := 168,
  /// The telegram number changed after initialization
  ERROR_169 := 169,
  /// Invalid AxesGroupID
  ERROR_170 := 170,
  /// Telegram number is invalid. E.g. TwoSequences is only activated in one direction
  ERROR_171 := 171,
  /// Telegram Number is not supported
  ERROR_172 := 172,
  /// Server connection lost
  ERROR_173 := 173,
  /// The RC is currently not initialized but has state in the ACR
  READY_TO_RESUME := 253,
  /// The RC is currently not initialized and has no state in the ACR
  READY_FOR_INITIALIZATION := 254,
  /// The RC state is Initialized
  INITIALIZED := 255  
)USINT;
END_TYPE


