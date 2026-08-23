import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Autenticação com a conta Google.
///
/// Sem isto o Firestore vê os pedidos da app como anónimos. As regras do
/// projecto só deixam ler e escrever a contas autorizadas, por isso a app tem
/// mesmo de autenticar — ver SECURITY.md no repositório amba-web.
class AuthService {
  AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

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
