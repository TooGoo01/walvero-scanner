import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constant/images.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';

import '../../../blocs/user/user_bloc.dart';
import '../../../widgets/other_item_card.dart';

class OtherView extends StatelessWidget {
  const OtherView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.15 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 16),
            // User profile header
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLogged) {
                    return _buildUserHeader(context, state);
                  } else {
                    return _buildGuestHeader(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                l.menu,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Profile
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                return OtherItemCard(
                  icon: Icons.person_outline_rounded,
                  onClick: () {
                    if (state is UserLogged) {
                      Navigator.of(context).pushNamed(
                        AppRouter.userProfile,
                        arguments: state.user,
                      );
                    } else {
                      Navigator.of(context).pushNamed(AppRouter.signIn);
                    }
                  },
                  title: l.profile,
                );
              },
            ),
            // Statistics - yalnız Tenant Admin üçün
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLogged && state.user.isTenantAdmin) {
                  return OtherItemCard(
                    icon: Icons.bar_chart_rounded,
                    iconColor: const Color(0xFF1976D2),
                    onClick: () {
                      Navigator.of(context)
                          .pushNamed(AppRouter.statistics);
                    },
                    title: l.statistics,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Müştərilər - yalnız Tenant Admin üçün
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLogged && state.user.isTenantAdmin) {
                  return OtherItemCard(
                    icon: Icons.people_outline_rounded,
                    iconColor: const Color(0xFF7B1FA2),
                    onClick: () {
                      Navigator.of(context)
                          .pushNamed(AppRouter.customers);
                    },
                    title: l.customers,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Language selector
            _buildLanguageSelector(context, l),
            const SizedBox(height: 16),
            // Sign out
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLogged) {
                  return OtherItemCard(
                    icon: Icons.logout_rounded,
                    iconColor: Colors.red[400],
                    onClick: () {
                      context.read<UserBloc>().add(SignOutUser());
                    },
                    title: l.logout,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            SizedBox(height: (MediaQuery.of(context).padding.bottom + 50)),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, AppLocalizations l) {
    final currentCode = localeProvider.locale.languageCode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.language, size: 18, color: Color(0xFF00574C)),
                  const SizedBox(width: 8),
                  Text(
                    l.language,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LocaleProvider.localeLabels.entries.map((entry) {
                final isSelected = entry.key == currentCode;
                return GestureDetector(
                  onTap: () => localeProvider.setLocale(entry.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF00574C)
                          : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, UserLogged state) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRouter.userProfile,
          arguments: state.user,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(state),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${state.user.firstName} ${state.user.lastName}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.user.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (state.user.isTenantAdmin) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF00574C).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.tenantAdmin,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00574C),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserLogged state) {
    if (state.user.googleLogoUrl != null) {
      return CachedNetworkImage(
        imageUrl: state.user.googleLogoUrl!,
        imageBuilder: (context, image) => CircleAvatar(
          radius: 24.sp,
          backgroundImage: image,
          backgroundColor: Colors.transparent,
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: 24.sp,
          backgroundImage: AssetImage(kUserAvatar),
          backgroundColor: Colors.transparent,
        ),
      );
    } else if (state.user.image != null) {
      return CachedNetworkImage(
        imageUrl: state.user.image!,
        imageBuilder: (context, image) => CircleAvatar(
          radius: 24.sp,
          backgroundImage: image,
          backgroundColor: Colors.transparent,
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: 24.sp,
          backgroundImage: AssetImage(kUserAvatar),
          backgroundColor: Colors.transparent,
        ),
      );
    }
    return CircleAvatar(
      radius: 24.sp,
      backgroundImage: AssetImage(kUserAvatar),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildGuestHeader(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRouter.signIn);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.sp,
              backgroundImage: AssetImage(kUserAvatar),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.loginSubtitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}
