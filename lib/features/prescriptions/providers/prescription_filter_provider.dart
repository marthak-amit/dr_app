import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected patient chip on the prescriptions list ('' = All).
final prescriptionPatientFilterProvider = StateProvider.autoDispose<String>((_) => '');
final prescriptionQueryProvider = StateProvider.autoDispose<String>((_) => '');
