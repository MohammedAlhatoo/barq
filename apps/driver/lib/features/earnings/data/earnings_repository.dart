import 'package:barq_core/barq_core.dart';

import 'earnings_models.dart';

/// The values of `period` in `GET /driver/earnings`.
enum EarningsPeriod { day, week, month }

abstract class EarningsRepository {
  Future<Earnings> earnings(EarningsPeriod period);
  Future<CashSummary> cash();
}

class ApiEarningsRepository implements EarningsRepository {
  ApiEarningsRepository(this._api);

  final ApiClient _api;

  @override
  Future<Earnings> earnings(EarningsPeriod period) async {
    final data = await _api.get(
      '/driver/earnings',
      query: {'period': period.name},
    );
    return Earnings.fromJson((data as Map).cast());
  }

  @override
  Future<CashSummary> cash() async =>
      CashSummary.fromJson((await _api.get('/driver/cash') as Map).cast());
}
