import 'dart:io';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error.toString().contains('Failed host lookup')) {
      return 'Unable to connect to server. Please check your internet connection.';
    } else if (error.toString().contains('Connection refused')) {
      return 'Server is unreachable. Please try again later.';
    } else if (error.toString().contains('Connection timed out')) {
      return 'Connection timed out. Please check your internet speed and try again.';
    } else {
      return 'An error occurred. Please try again later.';
    }
  }

  static bool isNetworkError(dynamic error) {
    return error is SocketException || 
           error.toString().contains('Failed host lookup') ||
           error.toString().contains('Connection refused') ||
           error.toString().contains('Connection timed out');
  }
}
