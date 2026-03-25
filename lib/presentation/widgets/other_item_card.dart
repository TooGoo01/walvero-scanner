import 'package:flutter/material.dart';

class OtherItemCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Function()? onClick;

  const OtherItemCard({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final hPadding = isTablet ? screenWidth * 0.15 : 20.0;
    return Padding(
      padding: EdgeInsets.only(left: hPadding, right: hPadding, bottom: 6, top: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onClick,
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 22, color: iconColor ?? const Color(0xFF00574C)),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
