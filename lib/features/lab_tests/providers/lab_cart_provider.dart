import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/providers.dart';

/// testId → quantity (people).
class LabCartNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void add(String id) => state = {...state, id: 1};
  void inc(String id) => state = {...state, id: (state[id] ?? 0) + 1};
  void dec(String id) {
    final q = (state[id] ?? 0) - 1;
    final m = {...state};
    if (q <= 0) {
      m.remove(id);
    } else {
      m[id] = q;
    }
    state = m;
  }

  void clear() => state = {};
}

final labCartProvider = NotifierProvider<LabCartNotifier, Map<String, int>>(LabCartNotifier.new);

class CartSummary {
  const CartSummary(this.items, this.count, this.total, this.mrp);
  final List<(LabTest, int)> items;
  final int count, total, mrp;
  int get saved => mrp - total;
}

CartSummary summarize(List<LabTest> tests, Map<String, int> cart) {
  final items = <(LabTest, int)>[for (final t in tests) if (cart.containsKey(t.id)) (t, cart[t.id]!)];
  var count = 0, total = 0, mrp = 0;
  for (final (t, q) in items) {
    count += q;
    total += t.price * q;
    mrp += t.mrp * q;
  }
  return CartSummary(items, count, total, mrp);
}

/// Mock saved addresses.
class LabAddress {
  const LabAddress(this.id, this.label, this.line, this.icon);
  final String id, label, line;
  final String icon;
}

const labAddresses = <LabAddress>[
  LabAddress('ad1', 'Home', '12, Shreeji Apartments, Bodakdev, Ahmedabad 380054', 'house-plus'),
  LabAddress('ad2', 'Office', '3rd Floor, Orbit Tower, Ghod Dod Road, Surat 395007', 'activity'),
];
