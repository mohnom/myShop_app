import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:myshop/core/utils/share_helper.dart';

class CustomHeaderMerchant extends StatelessWidget {
  const CustomHeaderMerchant({
    super.key,
    required this.name,
    required this.id,
  });

  final String name;
  final int id;

  void _copyId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: id.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ الرقم التعريفي ($id) بنجاح!',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: const Color(0xFF0fa30f),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareStoreCode(BuildContext context) {
    ShareHelper.shareRawText(
      context: context,
      message:
          'أهلاً بك في *$name* 🏪\n'
          'يمكنك متابعة حسابك وفواتيرك لحظياً عبر تطبيق «بقالتي».\n'
          'الرقم التعريفي لإضافة المتجر: *$id*',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      color: Colors.white.withValues(alpha: 0.9),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0ff05a), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0ff05a,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? 'المتجر' : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _copyId(context),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'الرقم التعريفي: #$id',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF0fa30f),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.copy_rounded,
                                        size: 13,
                                        color: Color(0xFF0fa30f),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _shareStoreCode(context),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF25D366,
                                    ).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    size: 14,
                                    color: Color(0xFF25D366),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildSettingsButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/merchantSettingView'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.gear, size: 18, color: Colors.black87),
        ),
      ),
    );
  }
}
