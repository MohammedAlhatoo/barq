/// Which status keys each screen's timeline shows, matching the design.
///
/// The only place status keys may be written in code (AGENTS.md rule 4).
/// Labels and colors still come from the server config.
abstract final class OrderTimelines {
  /// Customer waiting screen, `04_order_status_01`.
  static const waiting = [
    'awaiting_vendor',
    'preparing',
    'pending',
    'on_the_way',
    'delivered',
  ];

  /// Customer tracking screen, `04_order_status_04`.
  static const tracking = [
    'accepted',
    'picked_up',
    'on_the_way',
    'arrived',
    'delivered',
  ];
}
