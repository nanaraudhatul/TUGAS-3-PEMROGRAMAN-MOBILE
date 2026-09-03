// =============================================
// CUSTOM EXCEPTION - TiketHabisException
// =============================================
class TiketHabisException implements Exception {
  final String namaTiket;
  final String message;
  
  TiketHabisException(this.namaTiket, [this.message = '']);
  
  @override
  String toString() {
    return 'TiketHabisException: Tiket "$namaTiket" sudah terjual habis. '
        '${message.isNotEmpty ? message : 'Acara berikutnya akan segera hadir!'}';
  }
}

// =============================================
// CUSTOM EXCEPTION - NetworkException
// =============================================
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  
  NetworkException(this.message, {this.statusCode});
  
  @override
  String toString() => 'NetworkException: $message (Status: $statusCode)';
}

// =============================================
// CUSTOM EXCEPTION - ValidationException
// =============================================
class ValidationException implements Exception {
  final Map<String, String> errors;
  
  ValidationException(this.errors);
  
  @override
  String toString() => 'ValidationException: ${errors.toString()}';
}