import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_config.dart';
import '../../../../core/widgets/widgets.dart';
import '../../providers/payment_provider.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.pal;
    final s = ref.watch(paymentsProvider);
    final n = ref.read(paymentsProvider.notifier);

    return Scaffold(
      appBar: const AppTopBar(title: 'Payment methods'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 8, AppSpacing.screenH, 40),
        children: [
          _WalletCard(balance: s.wallet, onAdd: () => _addMoney(context, ref)).animate().fadeIn(duration: 350.ms).slideY(begin: .06, end: 0),
          Gap.v(24),
          Row(children: [
            Expanded(child: Text('UPI', style: context.tt.titleLarge)),
            TapScale(onTap: () => _addUpi(context, ref), child: Text('+ Add UPI', style: context.tt.labelMedium!.copyWith(color: p.primary))),
          ]),
          Gap.v(12),
          if (s.upis.isEmpty) _emptyHint(context, 'No UPI IDs saved'),
          for (final u in s.upis)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MethodTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: p.successSoft, borderRadius: AppRadius.rMd),
                  child: Icon(Icons.qr_code_2_rounded, color: p.success),
                ),
                title: u.handle,
                subtitle: u.app,
                selected: s.defaultId == u.id,
                onSelect: () {
                  n.setDefault(u.id);
                  showAppSnack(context, '${u.handle} set as default');
                },
                onRemove: () => _remove(context, ref, u.id, u.handle),
              ),
            ),
          Gap.v(14),
          Row(children: [
            Expanded(child: Text('Cards', style: context.tt.titleLarge)),
            TapScale(onTap: () => _addCard(context, ref), child: Text('+ Add card', style: context.tt.labelMedium!.copyWith(color: p.primary))),
          ]),
          Gap.v(12),
          if (s.cards.isEmpty) _emptyHint(context, 'No cards saved'),
          for (final c in s.cards)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _CardVisual(
                card: c,
                isDefault: s.defaultId == c.id,
                onDefault: () {
                  n.setDefault(c.id);
                  showAppSnack(context, '${c.brand} •••• ${c.last4} set as default');
                },
                onRemove: () => _remove(context, ref, c.id, '${c.brand} •••• ${c.last4}'),
              ),
            ),
          Gap.v(10),
          AppCard(
            color: p.primarySoft,
            border: false,
            shadow: false,
            child: Row(children: [
              Icon(Icons.lock_rounded, color: p.primary, size: 20),
              Gap.h(12),
              Expanded(child: Text('Payments are simulated in this prototype. No real money is charged by ${AppConfig.appName}.', style: context.tt.bodySmall!.copyWith(color: p.textSecondary))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _emptyHint(BuildContext context, String t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(t, style: context.tt.bodyMedium));

  Future<void> _remove(BuildContext context, WidgetRef ref, String id, String label) async {
    final ok = await showConfirmSheet(context, title: 'Remove $label?', message: 'This payment method will be deleted from your account.', confirmLabel: 'Remove', destructive: true, icon: Icons.delete_outline_rounded);
    if (ok && context.mounted) {
      ref.read(paymentsProvider.notifier).remove(id);
      showAppSnack(context, '$label removed', icon: Icons.delete_outline_rounded);
    }
  }

  void _addMoney(BuildContext context, WidgetRef ref) {
    showAppBottomSheet<void>(context, title: 'Add money', builder: (ctx) {
      return Column(children: [
        Text('Choose an amount to top up your ${AppConfig.appName} credits', style: ctx.tt.bodyMedium),
        Gap.v(16),
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final a in [100, 250, 500, 1000])
            ChoicePill(label: '₹$a', selected: false, onTap: () {
              Navigator.pop(ctx);
              ref.read(paymentsProvider.notifier).addMoney(a);
              showAppSnack(context, '₹$a added to your wallet', icon: Icons.account_balance_wallet_rounded);
            }),
        ]),
      ]);
    });
  }

  void _addUpi(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showAppBottomSheet<void>(context, title: 'Add UPI ID', builder: (ctx) {
      String? err;
      return StatefulBuilder(builder: (ctx, set) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppTextField(controller: ctrl, label: 'UPI ID', hint: 'name@bank', prefixIcon: Icons.alternate_email_rounded, autofocus: true),
          if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: ctx.tt.bodySmall!.copyWith(color: ctx.pal.danger))),
          Gap.v(20),
          AppButton(label: 'Verify & save', onPressed: () {
            final v = ctrl.text.trim();
            if (!RegExp(r'^[\w.\-]{2,}@[\w]{2,}$').hasMatch(v)) {
              set(() => err = 'Enter a valid UPI ID, e.g. name@okaxis');
              return;
            }
            ref.read(paymentsProvider.notifier).addUpi(v, 'UPI');
            Navigator.pop(ctx);
            showAppSnack(context, 'UPI ID verified and saved');
          }),
        ]);
      });
    }).whenComplete(ctrl.dispose);
  }

  void _addCard(BuildContext context, WidgetRef ref) {
    final num = TextEditingController();
    final name = TextEditingController();
    final exp = TextEditingController();
    showAppBottomSheet<void>(context, title: 'Add card', builder: (ctx) {
      String? err;
      return StatefulBuilder(builder: (ctx, set) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppTextField(controller: num, label: 'Card number', hint: '1234 5678 9012 3456', prefixIcon: Icons.credit_card_rounded, keyboardType: TextInputType.number, maxLength: 16, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          Gap.v(14),
          AppTextField(controller: name, label: 'Name on card', hint: 'AMIT MARTHAK', prefixIcon: Icons.person_outline_rounded),
          Gap.v(14),
          AppTextField(controller: exp, label: 'Expiry', hint: 'MM/YY', prefixIcon: Icons.event_rounded, maxLength: 5, keyboardType: TextInputType.datetime),
          if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: ctx.tt.bodySmall!.copyWith(color: ctx.pal.danger))),
          Gap.v(20),
          AppButton(label: 'Save card', onPressed: () {
            if (num.text.length < 12 || name.text.trim().length < 2 || exp.text.length < 4) {
              set(() => err = 'Please fill in all card details');
              return;
            }
            final first = num.text[0];
            final brand = first == '4' ? 'Visa' : (first == '5' ? 'Mastercard' : 'RuPay');
            ref.read(paymentsProvider.notifier).addCard(brand, num.text.substring(num.text.length - 4), name.text.trim().toUpperCase(), exp.text);
            Navigator.pop(ctx);
            showAppSnack(context, '$brand card saved securely', icon: Icons.lock_rounded);
          }),
        ]);
      });
    }).whenComplete(() {
      num.dispose();
      name.dispose();
      exp.dispose();
    });
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.balance, required this.onAdd});
  final int balance;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: AppRadius.rXl, boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .3), blurRadius: 22, offset: const Offset(0, 10))]),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${AppConfig.appName} credits', style: context.tt.labelMedium!.copyWith(color: Colors.white.withValues(alpha: .85))),
            Gap.v(4),
            Text('₹$balance', style: context.tt.displaySmall!.copyWith(color: Colors.white)),
            Text('Usable on consults & lab tests', style: context.tt.bodySmall!.copyWith(color: Colors.white.withValues(alpha: .8))),
          ]),
        ),
        TapScale(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.rMd),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
              Gap.h(4),
              Text('Add', style: context.tt.labelMedium!.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.leading, required this.title, required this.subtitle, required this.selected, required this.onSelect, required this.onRemove});
  final Widget leading;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onSelect, onRemove;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AppCard(
      onTap: onSelect,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        leading,
        Gap.h(12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(children: [
              Flexible(child: Text(subtitle, style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (selected) ...[Gap.h(8), StatusChip(label: 'Default', color: p.primary, bg: p.primarySoft, dense: true)],
            ]),
          ]),
        ),
        Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? p.primary : p.textTertiary),
        IconButton(visualDensity: VisualDensity.compact, onPressed: onRemove, icon: Icon(Icons.delete_outline_rounded, color: p.textTertiary, size: 20)),
      ]),
    );
  }
}

class _CardVisual extends StatelessWidget {
  const _CardVisual({required this.card, required this.isDefault, required this.onDefault, required this.onRemove});
  final SavedCard card;
  final bool isDefault;
  final VoidCallback onDefault, onRemove;
  @override
  Widget build(BuildContext context) {
    final visa = card.brand == 'Visa';
    final colors = visa ? const [Color(0xFF1B2B65), Color(0xFF3B5BDB)] : const [Color(0xFF3A1C71), Color(0xFFD76D77)];
    return TapScale(
      onTap: onDefault,
      scale: .98,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: AppRadius.rLg,
          boxShadow: [BoxShadow(color: colors.last.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(card.brand.toUpperCase(), style: context.tt.titleMedium!.copyWith(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .2), borderRadius: AppRadius.rPill),
                child: Text('DEFAULT', style: context.tt.labelSmall!.copyWith(color: Colors.white)),
              ),
            InkWell(onTap: onRemove, borderRadius: AppRadius.rPill, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.delete_outline_rounded, color: Colors.white70, size: 20))),
          ]),
          Gap.v(18),
          Text('••••  ••••  ••••  ${card.last4}', style: context.tt.titleLarge!.copyWith(color: Colors.white, letterSpacing: 2)),
          Gap.v(16),
          Row(children: [
            Expanded(child: Text(card.holder, style: context.tt.labelMedium!.copyWith(color: Colors.white.withValues(alpha: .9)), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Text(card.expiry, style: context.tt.labelMedium!.copyWith(color: Colors.white.withValues(alpha: .9))),
          ]),
        ]),
      ),
    );
  }
}
