/// All route paths. Use `context.push(Routes.xxx)` / `context.go(...)`.
class Routes {
  Routes._();

  // Auth / onboarding
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static String otp(String phone) => '/otp?phone=${Uri.encodeComponent(phone)}';
  static const profileSetup = '/profile-setup';

  // Patient shell tabs
  static const home = '/home';
  static const appointments = '/appointments';
  static const records = '/records';
  static const profile = '/profile';

  // Patient pushed screens
  static String search({String? specialty, bool focus = false}) {
    final q = <String>[if (specialty != null) 'specialty=$specialty', if (focus) 'focus=1'];
    return '/search${q.isEmpty ? '' : '?${q.join('&')}'}';
  }

  static String doctor(String id, {String heroSuffix = ''}) => '/doc/$id${heroSuffix.isEmpty ? '' : '?hero=$heroSuffix'}';

  /// [type]: 'clinic' | 'video'. [reschedule]: appointment id being rescheduled.
  static String book(String doctorId, {String? type, String? reschedule}) {
    final q = <String>[if (type != null) 'type=$type', if (reschedule != null) 'reschedule=$reschedule'];
    return '/book/$doctorId${q.isEmpty ? '' : '?${q.join('&')}'}';
  }

  static String bookingSuccess(String appointmentId) => '/booking-success/$appointmentId';
  static String appointment(String id) => '/appointment/$id';
  static const queue = '/queue';
  static String video(String appointmentId) => '/video/$appointmentId';
  static const prescriptions = '/prescriptions';
  static String prescription(String id) => '/prescription/$id';
  static const reminders = '/reminders';
  static String recordFolder(String kind) => '/records/folder/$kind'; // lab | xray | prescription
  static String recordFile(String id) => '/records/file/$id';
  static const labTests = '/lab-tests';
  static const vitals = '/vitals';
  static const chat = '/chat';
  static const notifications = '/notifications';
  static const family = '/profile/family';
  static const payments = '/profile/payments';
  static const language = '/profile/language';
  static const settings = '/profile/settings';
  static const editProfile = '/profile/edit';

  // Doctor mode
  static const drDashboard = '/dr/dashboard';
  static const drQueue = '/dr/queue';
  static const drSchedule = '/dr/schedule';
  static const drMore = '/dr/more';
  static String drPatient(String id) => '/dr/patient/$id';
  static String drRx(String patientId) => '/dr/rx/$patientId';
}
