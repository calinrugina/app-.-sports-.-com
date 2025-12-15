import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppConfig {
  // Starea de Debug.
  // În Flutter, kDebugMode este o constantă booleană care este true
  // doar în modurile Debug și Profile. Este cea mai bună practică.
  static const bool isDebugMode = false ; // kDebugMode;

  // URL-urile API
  static const String baseUrlProduction = 'https://sports-api.alpha.sports.com';
  static const String baseUrlDevelopment = 'https://beta.sports.com'; // Adresa locală tipică pentru emulator

  // Selectează URL-ul corect în funcție de starea de debug
  static String get baseUrl {
    return isDebugMode ? baseUrlDevelopment : baseUrlProduction;
  }

  // Alte constante
  static const int apiTimeoutSeconds = 30;
  static const String appName = 'Sport App';

  static const double bigSpace = 15;
  static const double smallSpace = 5;

  static const double appPadding = 10;

  // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
  // padding: EdgeInsets.all(15),

}

class SportsAppLogger {
  // Funcția statică de logare care primește orice argument
  static void log(Object? message) {
    // Verifică dacă suntem în modul Debug
    if (!AppConfig.isDebugMode) {

      return; // Nu face nimic în modul Release
    }

    // 1. Obținerea Stack Trace-ului
    final stackTrace = StackTrace.current.toString();

    // 2. Extrage informațiile despre apelant (fisier și linie)
    // Caută linia care NU este din pachetul 'app_logger' sau 'dart:async' (adică apelantul real)
    final lines = stackTrace.split('\n');
    String caller = 'Necunoscut';

    for (var line in lines) {
      if (!line.contains('app_logger.dart') && !line.contains('dart:async') && line.contains('package:')) {
        // Linia tipică este: #X      Clasa.Metoda (package:nume_proiect/cale/fisier.dart:linea:coloana)
        // Vrem doar 'cale/fisier.dart:linea'
        final regex = RegExp(r'\((package:.*?)\)');
        final match = regex.firstMatch(line);
        if (match != null) {
          caller = match.group(1)!;
          // Eliminăm path-ul complet al pachetului, lăsând doar calea relevanta
          // Ex: 'package:proiect/src/screens/home_screen.dart:150:24'
          break;
        }
      }
    }

    // 3. Formatarea mesajului (inclusiv a obiectelor complexe)
    String formattedMessage;
    try {
      if (message is Map || message is Iterable) {
        // Afișează hărțile și listele frumos formatate
        formattedMessage = _prettyPrint(message);
      } else {
        formattedMessage = message.toString();
      }
    } catch (e) {
      formattedMessage = message.toString();
    }

    // 4. Afișarea finală folosind developer.log pentru a folosi canalul de logare al IDE-ului
    debugPrint(
      '[$caller] $formattedMessage',
      // name: AppConfig.appName, // Numele aplicației ca tag în log-uri
      // error: message is Error || message is Exception ? message : null,
    );
  }

  // Funcție privată pentru formatarea obiectelor
  static String _prettyPrint(Object? object) {
    // O implementare simplă de pretty print.
    // Pentru JSON real, ați folosi dart:convert și JsonEncoder.
    const indent = '  ';
    if (object is Map) {
      final buffer = StringBuffer('{\n');
      object.forEach((key, value) {
        buffer.write('$indent$key: ${value.toString()},\n');
      });
      buffer.write('}');
      return buffer.toString();
    } else if (object is Iterable) {
      final buffer = StringBuffer('[\n');
      for (final item in object) {
        buffer.write('$indent${item.toString()},\n');
      }
      buffer.write(']');
      return buffer.toString();
    }
    return object.toString();
  }
}