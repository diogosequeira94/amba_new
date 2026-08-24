import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Autenticação com a conta Google.
///
/// Sem isto o Firestore vê os pedidos da app como anónimos. As regras do
/// projecto só deixam ler e escrever a contas autorizadas, por isso a app tem
/// mesmo de autenticar — ver SECURITY.md no repositório amba-web.
class AuthService {
  /// ID do cliente OAuth **web** do projecto amba-8809b.
  ///
  /// Este projecto não usa `google-services.json` — o Firebase é configurado
  /// pelo `firebase_options.dart`. Sem esse ficheiro o plugin Gradle da Google
  /// não gera o recurso `default_web_client_id`, e sem ele o `google_sign_in`
  /// devolve `idToken: null`, que o Firebase recusa.
  ///
  /// Passar o `serverClientId` à mão resolve isso sem ter de trazer o
  /// google-services.json para o projecto.
  static const _serverClientId =
      '178830511133-1bnpa07olb1tm0cl0dnag4o2fsnhsr4j.apps.googleusercontent.com';

  AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(serverClientId: _serverClientId);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  /// A sessão do Firebase persiste entre arranques — só se entra uma vez.
  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Devolve null se o utilizador fechar o diálogo do Google a meio.
  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    // Falha cedo e com uma causa legível. Um idToken nulo aqui costuma
    // significar serverClientId errado ou SHA-1 por registar — e mais à frente
    // apareceria só como um erro genérico de credencial inválida.
    if (googleAuth.idToken == null) {
      throw StateError('missing-id-token');
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  Future<void> signOut() async {
    // Também ao Google, senão o próximo login entra logo na mesma conta sem
    // dar hipótese de escolher outra.
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

/// Mensagens de erro do Firebase traduzidas para algo accionável.
String describeAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'account-exists-with-different-credential':
        return 'Já existe uma conta com este email criada de outra forma.';
      case 'invalid-credential':
        return 'As credenciais do Google não foram aceites. Tenta novamente.';
      case 'operation-not-allowed':
        return 'O login com Google não está activado no Firebase.';
      case 'user-disabled':
        return 'Esta conta foi desactivada.';
      case 'network-request-failed':
        return 'Falha de rede. Verifica a ligação e tenta outra vez.';
      default:
        return error.message ?? 'Não foi possível entrar.';
    }
  }

  final text = error.toString();

  if (text.contains('missing-id-token')) {
    return 'O Google não devolveu um token de identidade. Verifica o '
        'serverClientId e o SHA-1 registado no Firebase.';
  }

  // Erro típico quando falta registar o SHA-1 no Firebase.
  if (text.contains('ApiException: 10')) {
    return 'A app não está registada no Firebase para esta assinatura '
        '(falta o SHA-1). Ver SECURITY.md.';
  }
  if (text.contains('ApiException: 12501')) {
    return 'Login cancelado.';
  }

  return 'Não foi possível entrar.';
}
