/// One page of a list. [nextPage] is null on the last page.
class Paged<T> {
  const Paged({required this.items, this.nextPage, this.total});

  /// Reads the response `meta`. openapi.json leaves its fields open, so this
  /// accepts next_page, or current_page + last_page.
  factory Paged.fromMeta(List<T> items, Map<String, dynamic>? meta) {
    final current = meta?['current_page'] as int?;
    final last = meta?['last_page'] as int?;
    final derivedNext = current != null && last != null && current < last
        ? current + 1
        : null;
    return Paged(
      items: items,
      nextPage: meta?['next_page'] as int? ?? derivedNext,
      total: meta?['total'] as int?,
    );
  }

  final List<T> items;
  final int? nextPage;
  final int? total;
}
