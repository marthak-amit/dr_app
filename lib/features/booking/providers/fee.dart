import '../../appointments/presentation/widgets/appointment_utils.dart';

/// Fee breakdown shown in the summary + payment step.
class FeeBreakdown {
  const FeeBreakdown({required this.consult, required this.discount});
  final int consult, discount;

  int get platform => platformFee;
  int get gst => gstOn(platformFee);
  int get total => consult - discount + platform + gst;

  static const couponCode = 'MEDIQ20';

  /// 20% off the consultation fee, up to ₹200.
  static int couponDiscount(int consult) {
    final d = (consult * 0.2).round();
    return d > 200 ? 200 : d;
  }
}
