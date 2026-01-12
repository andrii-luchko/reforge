import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/constants/env.dart';

@module
abstract class AuthProviderModule {
  @preResolve
  Future<GoogleSignIn> get googleSignIn async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(
      serverClientId: Env.googleServerClientId,
    );

    return googleSignIn;
  }
}
