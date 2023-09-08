class AppException implements Exception {
  final String _message;

  AppException(this._message);

  @override
  String toString() => _message;
}

class BasicException extends AppException {
  BasicException({required String message}) : super(message);
}

class NoConnectionException extends AppException {
  NoConnectionException({required String message}) : super(message);
}

class BadRequestException extends AppException {
  BadRequestException({required String message}) : super(message);
}

class UnauthorisedException extends AppException {
  UnauthorisedException({required String message}) : super(message);
}

class InvalidInputException extends AppException {
  InvalidInputException({required String message}) : super(message);
}

class NotFoundException extends AppException {
  NotFoundException({required String message}) : super(message);
}

class DataException extends AppException {
  DataException({required String message}) : super(message);
}

class QRException extends AppException {
  QRException({required String message}) : super(message);
}

class LocationException extends AppException {
  LocationException({required String message}) : super(message);
}
