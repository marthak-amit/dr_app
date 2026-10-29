import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_state.dart';
import 'shimmer_list.dart';

/// Renders loading shimmer / error state / data for an [AsyncValue].
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.builder, this.onRetry, this.loading});
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => loading ?? const ShimmerList(),
      error: (e, _) => ErrorState(onRetry: onRetry),
    );
  }
}
