/// One page of a list. [nextPage] is null on the last page.
class Paged<T> {
  const Paged({required this.items, this.nextPage, this.total, this.meta});

  /// Reads the server's `meta`: `{ page, per_page, total, last_page }`.
  factory Paged.fromMeta(List<T> items, Map<String, dynamic>? meta) {
    final page = meta?['page'] as int?;
    final lastPage = meta?['last_page'] as int?;
    return Paged(
      items: items,
      nextPage: page != null && lastPage != null && page < lastPage
          ? page + 1
          : null,
      total: meta?['total'] as int?,
      meta: meta,
    );
  }

  final List<T> items;
  final int? nextPage;
  final int? total;

  /// The whole `meta`, for lists with their own fields such as `next_since`.
  final Map<String, dynamic>? meta;
}
