import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpiId {
  const UpiId(this.id, this.handle, this.app);
  final String id, handle, app;
}

class SavedCard {
  const SavedCard(this.id, this.brand, this.last4, this.holder, this.expiry);
  final String id, brand, last4, holder, expiry;
}

class PaymentsState {
  const PaymentsState({required this.upis, required this.cards, required this.defaultId, required this.wallet});
  final List<UpiId> upis;
  final List<SavedCard> cards;
  final String defaultId;
  final int wallet;

  PaymentsState copyWith({List<UpiId>? upis, List<SavedCard>? cards, String? defaultId, int? wallet}) =>
      PaymentsState(upis: upis ?? this.upis, cards: cards ?? this.cards, defaultId: defaultId ?? this.defaultId, wallet: wallet ?? this.wallet);
}

class PaymentsNotifier extends Notifier<PaymentsState> {
  @override
  PaymentsState build() => const PaymentsState(
        upis: [UpiId('u1', 'amit@okhdfcbank', 'Google Pay'), UpiId('u2', '9876543210@ybl', 'PhonePe')],
        cards: [SavedCard('c1', 'Visa', '4242', 'AMIT MARTHAK', '08/28'), SavedCard('c2', 'Mastercard', '9910', 'AMIT MARTHAK', '03/27')],
        defaultId: 'u1',
        wallet: 250,
      );

  void setDefault(String id) => state = state.copyWith(defaultId: id);
  void addUpi(String handle, String app) => state = state.copyWith(upis: [...state.upis, UpiId('u${DateTime.now().microsecondsSinceEpoch}', handle, app)]);
  void addCard(String brand, String last4, String holder, String expiry) =>
      state = state.copyWith(cards: [...state.cards, SavedCard('c${DateTime.now().microsecondsSinceEpoch}', brand, last4, holder, expiry)]);
  void remove(String id) {
    final upis = state.upis.where((e) => e.id != id).toList();
    final cards = state.cards.where((e) => e.id != id).toList();
    var def = state.defaultId;
    if (def == id) def = upis.isNotEmpty ? upis.first.id : (cards.isNotEmpty ? cards.first.id : '');
    state = state.copyWith(upis: upis, cards: cards, defaultId: def);
  }

  void addMoney(int amt) => state = state.copyWith(wallet: state.wallet + amt);
}

final paymentsProvider = NotifierProvider<PaymentsNotifier, PaymentsState>(PaymentsNotifier.new);
