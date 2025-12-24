import 'package:dio/dio.dart';
import 'package:reforge/app/utils/helpers/base_response.dart';

import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/auth/data/requests/refresh_token_request.dart';
import 'package:reforge/core/auth/data/requests/sign_up_request.dart';
import 'package:reforge/core/auth/data/requests/signin_request.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Auth endpoints
  @POST('/auth/signin')
  Future<BaseResponse<AuthTokens>> signin(@Body() SignInRequest request);

  @POST('/auth/signup')
  Future<BaseResponse<AuthTokens>> signup(@Body() SignUpRequest request);

  @POST('/auth/refresh')
  Future<BaseResponse<AuthTokens>> refreshToken(@Body() RefreshTokenRequest request);

  @GET('/auth/me')
  Future<BaseResponse<User>> getCurrentUser();

  @POST('/auth/logout')
  Future<void> logout();

  // User endpoints
  @GET('/users/{id}')
  Future<User> getUser(@Path('id') String id);
}
