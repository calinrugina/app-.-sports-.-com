// Widgetul care reprezintă un singur element de știre în Grid
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sports_config_app/features/news/data/article_item.dart';

import '../../../core/theme/colors.dart';

class ArticleGridItem extends StatelessWidget {
  final ArticleItem article;
  final VoidCallback onTap;
  final Map<String, String>? headers;

  const ArticleGridItem({
    Key? key,
    required this.article,
    required this.onTap,
    this.headers,
  }) : super(key: key);

  // Funcție utilitară pentru a formata data relativă (ca în VideoListItem)
  String _formatDateRelative(String dateString) {
    DateTime articleDate;
    try {
      articleDate = DateTime.parse(dateString).toLocal();
    } catch (e) {
      return 'Dată necunoscută';
    }

    final difference = DateTime.now().difference(articleDate);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()} ANI ÎN URMĂ';
    }
    if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()} LUNI ÎN URMĂ';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays} ZILE ÎN URMĂ';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} ORE ÎN URMĂ';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} MINUTE ÎN URMĂ';
    }
    return 'ACUM';
  }

  @override
  Widget build(BuildContext context) {
    // Accesarea stilurilor de text din tema curentă
    final textTheme = Theme.of(context).textTheme;
    final formattedDate = _formatDateRelative(article.publishDate);

    return InkWell(
      onTap: onTap,
      // Aplicăm un padding ușor pentru a ne asigura că GridView-ul aplică marginile
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Lăsăm Column-ul să ocupe doar spațiul necesar (Min size)
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Imaginea Articolului (Thumbnail)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: article.mediaUrl != null
                  ? Image.network(
                article.mediaUrl!,
                fit: BoxFit.cover,
                headers: headers ?? const {},
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: AppColors.gray60);
                },
              )
                  : Container(
                color: AppColors.gray60,
                child: const Center(child: Icon(Icons.article, color: Colors.white, size: 48)),
              ),
            ),
          ),

          const SizedBox(height: 2),

          // 3. itemTitle (Titlul principal al articolului)
          // Utilizăm titleLarge (16px, W700)
          Text(
            article.title,
            maxLines: 1, // Lăsăm 3 linii pentru titlu în formatul Grid
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 2), // Spațiu sub imagine

          // 2. itemDescription (Sursa / Categoria)
          // Utilizăm bodyMedium (14px, W600, culoare secundară/gri)
          SizedBox(
            height: 42,
            child: Text(
              article.description, // Adesea este ALL CAPS
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 2),

          // 4. itemDate (Data publicării)
          // Utilizăm labelSmall (12px, W600, gri)
          Text(
            formattedDate,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),

          const SizedBox(height: 4), // Mici spațiu de siguranță la final
        ],
      ),
    );
  }
}
