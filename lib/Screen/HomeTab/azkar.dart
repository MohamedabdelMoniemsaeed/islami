import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/models/azkar_model.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';

class AzkarTab extends StatefulWidget {
  const AzkarTab({super.key});

  @override
  State<AzkarTab> createState() => _AzkarTabState();
}

class _AzkarTabState extends State<AzkarTab> {
  final ApiService _apiService = ApiService();

  // الطلب اتولد مرة واحدة في initState (مش كل rebuild من Provider)
  late final Future<AzkarResponse> _azkar;

  @override
  void initState() {
    super.initState();
    _azkar = _apiService.getAzkar();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.azkar,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.yellow,
            fontSize: 28,
          ),
        ),
        const Divider(color: AppColors.yellow, thickness: 2),
        Expanded(
          child: FutureBuilder<AzkarResponse>(
            future: _azkar,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
              } else if (snapshot.hasError) {
                return const Center(child: Text("خطأ في تحميل الأذكار"));
              }

              final categories = snapshot.data!.categories;

              return ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (context, index) => const Divider(color: AppColors.yellow, thickness: 1),
                itemBuilder: (context, index) {
                  return MaterialButton(
                    onPressed: () {
                      _showAzkarList(context, categories[index], provider.isDarkMode());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        categories[index].categoryName,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: provider.isDarkMode() ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAzkarList(BuildContext context, AzkarCategory category, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.yellowDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                category.categoryName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.yellow),
              ),
              const Divider(color: AppColors.yellow),
              Expanded(
                child: ListView.builder(
                  itemCount: category.azkar.length,
                  itemBuilder: (context, index) {
                    final item = category.azkar[index];
                    return _AzkarItemCard(item: item, isDark: isDark);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AzkarItemCard extends StatefulWidget {
  final AzkarItem item;
  final bool isDark;

  const _AzkarItemCard({required this.item, required this.isDark});

  @override
  State<_AzkarItemCard> createState() => _AzkarItemCardState();
}

class _AzkarItemCardState extends State<_AzkarItemCard> {
  late int _remaining;
  late final int _total;

  @override
  void initState() {
    super.initState();
    _total = int.tryParse(widget.item.count) ?? 1;
    _remaining = _total;
  }

  void _decrement() {
    if (_remaining > 0) {
      setState(() {
        _remaining--;
      });
    }
  }

  void _reset() {
    setState(() {
      _remaining = _total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _remaining == 0;
    return Card(
      color: widget.isDark
          ? (isDone ? Colors.green.withValues(alpha: 0.15) : Colors.white10)
          : (isDone ? Colors.green.shade50 : Colors.grey[100]),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDone ? Colors.green : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: _decrement,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.item.zekr,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : Colors.black87,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              if (widget.item.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  widget.item.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.yellow,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ],
              if (widget.item.reference.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  widget.item.reference,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isDark ? Colors.white54 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _decrement,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green : AppColors.yellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDone ? Icons.check_circle : Icons.touch_app_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isDone ? 'تم الانتهاء' : '$_remaining / $_total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isDone) ...[
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 22),
                      color: AppColors.yellow,
                      tooltip: 'إعادة التكرار',
                      onPressed: _reset,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
