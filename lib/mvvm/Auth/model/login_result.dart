class LoginResult {
  final String? jwt;
  final String? userId;
  final String? springResponse;
  final String? errorMessage;

  LoginResult({this.jwt, this.userId, this.springResponse, this.errorMessage});
}
