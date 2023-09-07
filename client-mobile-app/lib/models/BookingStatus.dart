class BookingStatus {
  static const String NEW = "NEW"; // Moi tao
  static const String COORDINATING = "COORDINATING"; // Dang dinh vi
  static const String PROCESSING = "PROCESSING"; // Dang xu ly tim tai xe
  static const String ASSIGNED = "ASSIGNED"; // Tai xe xac nhan
  static const String ON_GOING = "ON_GOING"; // Tai xe dang di
  static const String DRIVER_CANCELLED = "DRIVER_CANCELLED"; // Tai xe huy
  static const String CUSTOMER_CANCELLED =
      "CUSTOMER_CANCELLED"; // Khach hang huy
  static const String FAILED = "FAILED"; // That bai
  static const String DONE = "DONE"; // Hoan thanh
}
