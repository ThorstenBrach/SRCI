{attribute 'qualified_only'}
TYPE TelegramState :
(
  /// Default
  UNDEFINED := 0,
  /// Telegram control does not match the telegram state
  ERROR_161_TELEGRAM_CONTROL_MISMATCH_TELEGRAM_STATE := 161,
  /// Initialization lost for unknown reason. See message log after reinitializing
  ERROR_162_INIT_LOST_UNKNOWN := 162,
  /// Telegram length does not match the length provided in the communication interface.
  ERROR_163_TELEGRAM_LENGTH_MISMATCH := 163,
  /// Incompatible major SRCI version
  ERROR_164_SRCI_MAJOR_VERSION_INCOMPATIBLE := 164,
  /// Lifesign timeout
  ERROR_165_LIFESIGN_TIMEOUT := 165,
  /// The selected optional cyclic data does not fit in the given telegram size
  ERROR_166_CYCLIC_DATA_TOO_LARGE := 166,
  /// The robot interface was reset after being initialized
  ERROR_167_INTERFACE_WAS_RESET_AFTER_INIT := 167,
  /// Telegram sequence timeout
  ERROR_168_TELEGRAM_SEQ_TIMEOUT := 168,
  /// The telegram number changed after initialization
  ERROR_169_TELEGRAM_NO_CHANGED_AFTER_INIT := 169,
  /// Invalid AxesGroupID
  ERROR_170_AXESGROUP_ID_INVALID := 170,
  /// Telegram number is invalid. E.g. TwoSequences is only activated in one direction
  ERROR_171_TELEGRAM_NUMBER_INVALID := 171,
  /// Telegram Number is not supported
  ERROR_172_TELEGRAM_NUMBER_NOT_SUPPORTED := 172,
  /// Server connection lost
  ERROR_173_SERVER_CONNECTION_LOST := 173,
  /// The RC is currently not initialized but has state in the ACR
  READY_TO_RESUME := 253,
  /// The RC is currently not initialized and has no state in the ACR
  READY_FOR_INITIALIZATION := 254,
  /// The RC state is Initialized
  INITIALIZED := 255  
)USINT;
END_TYPE


