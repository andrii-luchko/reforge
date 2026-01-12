import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract interface class AuthProvidersDatasource {
  Future<String?> signWithGoogle();
  Future<String?> signWithApple();
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
  Future<String?> signWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    logger.d(credential);
    //TODO finished tihs stuff
    return credential.identityToken;
  }
}
