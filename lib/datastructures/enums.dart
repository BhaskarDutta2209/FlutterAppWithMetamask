enum TransactionState {
  success,
  failed,
  undefined, // This is when the state is not known
  timeout // When found undefined after multiple calls
}