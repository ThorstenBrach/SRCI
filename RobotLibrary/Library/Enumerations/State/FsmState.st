/// finite state machine
{attribute 'qualified_only'}
TYPE FsmState :
(
  /// READY
  READY := 0,
  /// START
  START,
  /// RUNNING
  RUNNING,
  /// DONE
  DONE,
  /// CANCEL
  CANCEL,
  /// ERROR
  ERROR,
  /// ERROR_CLEAR
  ERROR_CLEAR
);
END_TYPE


