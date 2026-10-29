import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediq/core/utils/fake_latency.dart';
import 'package:mediq/data/repositories/providers.dart';

enum SortOption {
  relevance('Relevance'),
  ratingHigh('Rating: high to low'),
  feeLow('Fee: low to high'),
  feeHigh('Fee: high to low'),
  experience('Most experienced'),
  nearest('Nearest first');

  const SortOption(this.label);
  final String label;
}

const kMaxFee = 1500.0;
const kLanguages = ['English', 'Hindi', 'Gujarati', 'Marathi', 'Tamil'];

class SearchFilter {
  const SearchFilter({
    this.specialtyId,
    this.minRating,
    this.fee = const RangeValues(0, kMaxFee),
    this.maxDistance,
    this.availableToday = false,
    this.gender,
    this.language,
    this.sort = SortOption.relevance,
  });

  final String? specialtyId;
  final double? minRating;
  final RangeValues fee;
  final double? maxDistance;
  final bool availableToday;
  final Gender? gender;
  final String? language;
  final SortOption sort;

  bool get feeActive => fee.start > 0 || fee.end < kMaxFee;

  /// Number of active filters (sort & specialty chip row excluded; specialty counted when set).
  int get activeCount =>
      (specialtyId != null ? 1 : 0) +
      (minRating != null ? 1 : 0) +
      (feeActive ? 1 : 0) +
      (maxDistance != null ? 1 : 0) +
      (availableToday ? 1 : 0) +
      (gender != null ? 1 : 0) +
      (language != null ? 1 : 0);

  SearchFilter copyWith({
    String? specialtyId,
    bool clearSpecialty = false,
    double? minRating,
    bool clearRating = false,
    RangeValues? fee,
    double? maxDistance,
    bool clearDistance = false,
    bool? availableToday,
    Gender? gender,
    bool clearGender = false,
    String? language,
    bool clearLanguage = false,
    SortOption? sort,
  }) =>
      SearchFilter(
        specialtyId: clearSpecialty ? null : (specialtyId ?? this.specialtyId),
        minRating: clearRating ? null : (minRating ?? this.minRating),
        fee: fee ?? this.fee,
        maxDistance: clearDistance ? null : (maxDistance ?? this.maxDistance),
        availableToday: availableToday ?? this.availableToday,
        gender: clearGender ? null : (gender ?? this.gender),
        language: clearLanguage ? null : (language ?? this.language),
        sort: sort ?? this.sort,
      );
}

class SearchFilterNotifier extends AutoDisposeNotifier<SearchFilter> {
  @override
  SearchFilter build() => const SearchFilter();
  void set(SearchFilter f) => state = f;
  void reset() => state = SearchFilter(sort: state.sort);
  void setSpecialty(String? id) => state = id == null ? state.copyWith(clearSpecialty: true) : state.copyWith(specialtyId: id);
}

final searchFilterProvider = AutoDisposeNotifierProvider<SearchFilterNotifier, SearchFilter>(SearchFilterNotifier.new);

/// Text query is applied locally (no latency) on top of the filtered results.
final searchQueryProvider = StateProvider.autoDispose<String>((_) => '');

/// Filtered + sorted doctors; refetches (with fake latency) whenever filters change.
final searchResultsProvider = FutureProvider.autoDispose<List<Doctor>>((ref) async {
  final f = ref.watch(searchFilterProvider);
  await fakeLatency(400, 700);
  var list = mockDoctors.where((d) {
    if (f.specialtyId != null && d.specialtyId != f.specialtyId) return false;
    if (f.minRating != null && d.rating < f.minRating!) return false;
    if (d.fee < f.fee.start || d.fee > f.fee.end) return false;
    if (f.maxDistance != null && clinicById(d.clinicId).distanceKm > f.maxDistance!) return false;
    if (f.availableToday && !d.availableToday) return false;
    if (f.gender != null && d.gender != f.gender) return false;
    if (f.language != null && !d.languages.contains(f.language)) return false;
    return true;
  }).toList();
  int cmp(Doctor a, Doctor b) {
    switch (f.sort) {
      case SortOption.relevance:
        final t = (b.isTop ? 1 : 0) - (a.isTop ? 1 : 0);
        return t != 0 ? t : b.rating.compareTo(a.rating);
      case SortOption.ratingHigh:
        return b.rating.compareTo(a.rating);
      case SortOption.feeLow:
        return a.fee.compareTo(b.fee);
      case SortOption.feeHigh:
        return b.fee.compareTo(a.fee);
      case SortOption.experience:
        return b.experienceYears.compareTo(a.experienceYears);
      case SortOption.nearest:
        return clinicById(a.clinicId).distanceKm.compareTo(clinicById(b.clinicId).distanceKm);
    }
  }

  list.sort(cmp);
  return list;
});
