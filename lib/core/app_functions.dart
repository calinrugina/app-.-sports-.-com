import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

class SvgIconLoader extends StatefulWidget {
  final String iconUrl;
  final Map<String, String> headers;

  const SvgIconLoader({
    super.key,
    required this.iconUrl,
    required this.headers,
  });

  @override
  State<SvgIconLoader> createState() => _SvgIconLoaderState();
}

class _SvgIconLoaderState extends State<SvgIconLoader> {
  // O stare pentru a ține minte dacă URL-ul este valid
  late Future<bool> _isUrlValid;

  @override
  void initState() {
    super.initState();
    // Apelăm funcția de verificare la inițializare
    _isUrlValid = _checkUrlValidity();
  }

  // Funcție asincronă pentru a verifica dacă URL-ul returnează un cod 200 (OK)
  Future<bool> _checkUrlValidity() async {
    // Încercăm să folosim HEAD pentru a verifica existența resursei
    try {
      final response = await http.head(Uri.parse(widget.iconUrl), headers: widget.headers);

      // Dacă este 200 OK, returnăm true
      return response.statusCode == 200;

    } catch (e) {
      // Dacă apare o eroare de rețea sau altă excepție, returnăm false
      print('Eroare la verificarea URL-ului SVG: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: FutureBuilder<bool>(
        future: _isUrlValid,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Se încarcă - afișăm un indicator de progres
            return const Center(
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          // Dacă URL-ul este valid (cod 200 OK)
          if (snapshot.hasData && snapshot.data == true) {
            return SvgPicture.network(
              widget.iconUrl,
              headers: widget.headers,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              // FIX: placeholderBuilder este apelat de 'flutter_svg' în cazul
              // în care URL-ul este valid (200), dar conținutul (SVG-ul)
              // este invalid și nu poate fi parsat (XmlParserException).
              placeholderBuilder: (BuildContext context) => const Icon(
                Icons.warning, // Iconiță care indică o eroare de parsare/conținut
                color: Colors.red,
                size: 24,
              ),
            );
          }

          // Dacă URL-ul nu este valid (404, eroare de rețea, sau nu are date)
          return const Icon(
            Icons.block, // Iconiță pentru resursă lipsă/blocată
            color: Colors.white,
            size: 24,
          );
        },
      ),
    );
  }
}