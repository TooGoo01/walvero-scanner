//date
class ServerException implements Exception {
  final String? message;
  const ServerException({this.message});
}

class CacheException implements Exception {}

class UnauthorizedException implements Exception {}

class ForbiddenException implements Exception {}

//route
class RouteException implements Exception {
  final String message;
  const RouteException(this.message);
}