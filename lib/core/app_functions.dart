import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import '../features/media/data/video_item.dart';
import '../features/media/presentation/video_player_dialog.dart';

// Calea către iconița SVG implicită din assets
const String kDefaultSvgAsset = 'assets/images/default.svg';

class SvgIconLoader extends StatefulWidget {
  final String iconUrl;
  final String? localAssetPath; // Noua proprietate pentru încărcare locală
  final Map<String, String> headers;
  final double size;
  final Color color;
  final Color? backgroundColor; // Proprietate nouă pentru fundal (opțional)

  const SvgIconLoader({
    super.key,
    this.localAssetPath, // Acum opțional
    required this.iconUrl,
    required this.headers,
    this.size = 24.0, // Dimensiune implicită
    this.color = Colors.white, // Culoare implicită
    this.backgroundColor, // Poate fi null (fără fundal) sau o culoare (inclusiv alpha)
  });

  @override
  State<SvgIconLoader> createState() => _SvgIconLoaderState();
}

class _SvgIconLoaderState extends State<SvgIconLoader> {
  // O stare pentru a ține minte conținutul SVG (String) sau null în caz de eroare.
  // Folosit doar dacă nu este furnizat un asset local.
  late Future<String?> _svgContentFuture;

  @override
  void initState() {
    super.initState();
    // Inițializăm Future-ul DOAR dacă nu avem un asset local de încărcat
    if (widget.localAssetPath == null) {
      _svgContentFuture = _loadSvgContent();
    }
  }

  // Funcție asincronă pentru a descărca și valida conținutul SVG (doar pentru URL-uri).
  Future<String?> _loadSvgContent() async {
    if (widget.iconUrl.isEmpty) {
      return null;
    }

    try {
      // Folosim http.get pentru a obține conținutul
      final response =
          await http.get(Uri.parse(widget.iconUrl), headers: widget.headers);

      if (response.statusCode == 200) {
        final content = response.body;

        // Verificăm dacă fișierul este SVG valid înainte de a-l returna.
        try {
          // Această linie va arunca XmlParserException dacă SVG-ul este invalid.
          // O rulăm aici pentru a prinde eroarea în Future, nu în widget build.
          SvgPicture.string(
            content,
            // Adăugăm un placeholderBuilder intern, deși excepțiile majore
            // sunt prinse de try-catch-ul exterior.
            placeholderBuilder: (_) =>
                throw Exception("SVG Parsing failed internally"),
          );
          return content;
        } catch (e) {
          // Prinde eroarea XmlParserException
          print('Eroare de parsare SVG (conținut invalid): $e');
          return null;
        }
      } else {
        print(
            'SVG URL invalid (Cod: ${response.statusCode}): ${widget.iconUrl}');
        return null;
      }
    } catch (e) {
      // Prinde erorile de rețea/DNS
      print('Eroare la descărcarea URL-ului SVG (Rețea/DNS): $e');
      return null;
    }
  }

  // Widget utilitar pentru a înfășura iconița (Asset sau Network) în Container (pentru fundal)
  Widget _wrapIconWithContainer({required Widget child}) {
    // Dacă nu există fundal, returnăm doar iconița înfășurată în SizedBox
    if (widget.backgroundColor == null) {
      return SizedBox(
        height: widget.size,
        width: widget.size,
        child: child,
      );
    }

    // Dacă există fundal, folosim Container pentru a aplica culoarea
    return Container(
      height: widget.size,
      width: widget.size,
      alignment: Alignment.center, // Centrarea iconiței
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(
            widget.size / 2), // Fundal circular (ca un buton de play)
      ),
      child: Padding(
        padding:
            EdgeInsets.all(widget.size * 0.15), // Mărime iconiță puțin mai mică
        child: child,
      ),
    );
  }

  // Widget utilitar pentru a afișa iconița SVG din Assets (local)
  Widget _buildAssetSvg(BuildContext context, String assetPath) {
    return SvgPicture.asset(
      assetPath,
      width: widget.size,
      height: widget.size,
      colorFilter: ColorFilter.mode(
        widget.color,
        BlendMode.srcIn,
      ),
      // Dacă nici Asset-ul nu poate fi citit (foarte rar)
      placeholderBuilder: (context) => Icon(
        Icons.error_outline,
        color: widget.color,
        size: widget.size,
      ),
    );
  }

  // Widget utilitar pentru a afișa iconița SVG implicită (Fallback)
  Widget _buildDefaultAssetSvg(BuildContext context) {
    return _buildAssetSvg(context, kDefaultSvgAsset);
  }

  @override
  Widget build(BuildContext context) {
    // PRIORITATE 1: Dacă este furnizată o cale locală, o folosim imediat.
    if (widget.localAssetPath != null && widget.localAssetPath!.isNotEmpty) {
      return _wrapIconWithContainer(
        child: _buildAssetSvg(context, widget.localAssetPath!),
      );
    }

    // Dacă nu avem asset local, continuăm cu logica de rețea.
    return _wrapIconWithContainer(
      child: FutureBuilder<String?>(
        future: _svgContentFuture,
        builder: (context, snapshot) {
          // 1. Stare de Așteptare (Loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                height: widget.size * 0.7,
                width: widget.size * 0.7,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          // 2. Stare Conținut SVG Valid (Descărcat și Parsat)
          final svgContent = snapshot.data;
          if (snapshot.hasData && svgContent != null) {
            return SvgPicture.string(
              // Afișăm SVG-ul din string-ul deja validat
              svgContent,
              width: widget.size,
              height: widget.size,
              colorFilter: ColorFilter.mode(
                widget.color,
                BlendMode.srcIn,
              ),
              // Dacă totuși apare o eroare de randare (puțin probabil), folosim fallback-ul
              placeholderBuilder: (BuildContext context) {
                // print('Eroare de randare SVG, folosim asset-ul implicit.');
                return _buildDefaultAssetSvg(context);
              },
            );
          }

          // 3. Stare Eșuată (URL Invalid, Rețea Eșuată sau Parsare Eșuată)
          return _buildDefaultAssetSvg(context);
        },
      ),
    );
  }
}

class SportsFunction {
  String formatDateRelative(String dateString) {
    DateTime videoDate;
    try {
      // 🚀 CONVERSIE DIN STRING LA DATETIME 🚀
      videoDate = DateTime.parse(dateString).toLocal();
    } catch (e) {
      // Gestionarea erorilor de parsare (dacă stringul nu este un format ISO 8601 valid)
      print('Eroare la parsarea datei "$dateString": $e');
      return 'Dată necunoscută';
    }

    final difference = DateTime.now().difference(videoDate);

    // Logica de calcul a diferenței relative
    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    }
    if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()} mounths ago';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    }
    return 'No';
  }

  double scale(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const referenceWidth = 430.0; // luat pentru referinta !!!
    final scale = screenWidth / referenceWidth;
    return scale;
  }

  void openPlayer(VideoItem v, BuildContext context) {
    final url = v.videoUrl;
    if (url == null || url.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => VideoPlayerDialog(
        videoUrl: url,
        title: v.title,
      ),
    );
  }
}
