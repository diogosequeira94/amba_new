import 'package:shared_preferences/shared_preferences.dart';

class QuotaSettingsService {
  static const _kDefaultQuotaAmount = 'default_quota_amount';

  /// fallback = 1.00
  Future<double> getDefaultAmount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_kDefaultQuotaAmount) ?? 1.00;
  }

  Future<void> setDefaultAmount(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kDefaultQuotaAmount, value);
  }
}