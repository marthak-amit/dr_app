import '../models/models.dart';

/// Deterministic mock slot generator: 9:00–13:00 morning, 14:00–17:30 afternoon, 18:00–20:30 evening.
/// Some slots are unavailable (hash based) and past slots today are disabled.
List<Slot> generateSlots(String doctorId, DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  final seed = doctorId.hashCode ^ (day.day * 31 + day.month * 7);
  final out = <Slot>[];
  void add(int h, int m, SlotPeriod p) {
    final t = DateTime(day.year, day.month, day.day, h, m);
    final taken = ((seed + h * 13 + m) % 5) == 0 || ((seed + h * 7 + m * 3) % 7) == 0;
    final past = t.isBefore(DateTime.now().add(const Duration(minutes: 20)));
    out.add(Slot(time: t, period: p, available: !taken && !past));
  }

  for (var h = 9; h < 13; h++) {
    add(h, 0, SlotPeriod.morning);
    add(h, 30, SlotPeriod.morning);
  }
  for (var h = 14; h < 18; h++) {
    add(h, 0, SlotPeriod.afternoon);
    add(h, 30, SlotPeriod.afternoon);
  }
  for (var h = 18; h < 21; h++) {
    add(h, 0, SlotPeriod.evening);
    add(h, 30, SlotPeriod.evening);
  }
  return out;
}
