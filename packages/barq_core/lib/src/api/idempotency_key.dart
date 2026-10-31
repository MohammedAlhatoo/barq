import 'package:uuid/uuid.dart';

/// A new value for the `Idempotency-Key` header. Sending the same value again
/// makes the server return the first answer instead of repeating the action.
String newIdempotencyKey() => const Uuid().v4();
