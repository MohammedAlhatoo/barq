import 'package:barq_core/barq_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../browse/state/search_cubit.dart';
import '../../cart/state/cart_cubit.dart';

/// Removes what belongs to the user from this phone, so the next person who
/// logs in here does not see it. The token goes last: clearing it opens the
/// login screen.
class LocalSession {
  LocalSession({
    required this._auth,
    required this._cart,
    required this._prefs,
  });

  final AuthStore _auth;
  final CartCubit _cart;
  final SharedPreferences _prefs;

  Future<void> end() async {
    _cart.clear();
    await _prefs.remove(SearchCubit.recentKey);
    await _auth.clear();
  }
}
