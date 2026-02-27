import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/constants/env.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract interface class AuthProvidersDatasource {
  Future<String?> signWithGoogle();
  Future<({String? token, String? name, String? surname})> signWithApple();
  Future<void> logout();
}

@Injectable(as: AuthProvidersDatasource)
class AuthProvidersDatasourceImpl implements AuthProvidersDatasource {
  AuthProvidersDatasourceImpl(this._googleSignIn);

  final GoogleSignIn _googleSignIn;

  @override
  Future<String?> signWithGoogle() async {
    return (await _googleSignIn.authenticate()).authentication.idToken;
  }

  @override
  Future<({String? token, String? name, String? surname})> signWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        clientId: Env.appleAuthServiceID,
        redirectUri: Uri.parse(Env.appleAuthServiceURL),
      ),
    );

    logger.d(credential);

    return (token: credential.identityToken, name: credential.givenName, surname: credential.familyName);
  }

  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
  }
}
