import '../iam/domain/account.dart';
import 'local_storage.dart';

/// Sesion del usuario. Se guarda en el telefono para no pedir el login cada vez que se abre la app.
class Session {
  static Account? currentAccount;

  static bool get isLoggedIn => currentAccount != null;

  static int get accountId => currentAccount?.id ?? 1;

  /// Lee la sesion guardada al abrir la app.
  static void restore() {
    final saved = LocalStorage.loadAccount();
    currentAccount = saved == null ? null : Account.fromJson(saved);
  }

  static Future<void> signIn(Account account) async {
    currentAccount = account;
    await LocalStorage.saveAccount(account.toJson());
    await LocalStorage.saveLastEmail(account.email);
  }

  static Future<void> clear() async {
    currentAccount = null;
    await LocalStorage.clearAccount();
  }
}
