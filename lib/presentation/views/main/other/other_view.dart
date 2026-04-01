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
            // User profile header with account switcher
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
      onLongPress: () => _showAccountSwitcher(context, state),
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
        child: Column(
          children: [
            Row(
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
                // Account switcher button - həmişə göstər
                GestureDetector(
                  onTap: () => _showAccountSwitcher(context, state),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      color: Color(0xFF00574C),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            // Saved accounts preview or add account hint
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showAccountSwitcher(context, state),
              child: Row(
                children: [
                  // Show other account avatars
                  ...state.savedAccounts
                      .where((a) => a.userId != state.user.id)
                      .take(3)
                      .map((a) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFF00574C),
                              child: Text(
                                a.firstName.isNotEmpty
                                    ? a.firstName[0].toUpperCase()
                                    : a.userName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )),
                  if (state.savedAccounts.where((a) => a.userId != state.user.id).isEmpty)
                    Icon(Icons.person_add_outlined, size: 18, color: Colors.grey[500]),
                  const SizedBox(width: 8),
                  Text(
                    state.savedAccounts.where((a) => a.userId != state.user.id).isNotEmpty
                        ? AppLocalizations.of(context)!.switchAccount
                        : AppLocalizations.of(context)!.addAccount,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.grey[400], size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountSwitcher(BuildContext context, UserLogged state) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                l.switchAccount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              // Current active account
              _buildAccountTile(
                context: context,
                name: '${state.user.firstName} ${state.user.lastName}'.trim(),
                subtitle: state.user.userName,
                isActive: true,
                imageUrl: state.user.image ?? state.user.googleLogoUrl,
                onTap: () => Navigator.pop(context),
              ),
              // Saved accounts
              ...state.savedAccounts
                  .where((a) => a.userId != state.user.id)
                  .map((account) => _buildAccountTile(
                        context: context,
                        name: account.displayName,
                        subtitle: account.userName,
                        isActive: false,
                        onTap: () {
                          Navigator.pop(context);
                          context
                              .read<UserBloc>()
                              .add(SwitchAccount(account.userId));
                        },
                        onRemove: () {
                          context
                              .read<UserBloc>()
                              .add(RemoveSavedAccount(account.userId));
                          Navigator.pop(context);
                        },
                      )),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              // Add account button
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_add_outlined,
                    color: Color(0xFF00574C),
                    size: 22,
                  ),
                ),
                title: Text(
                  l.addAccount,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Save current account, then navigate to sign-in (no logout)
                  context.read<UserBloc>().add(SaveCurrentAccount());
                  Navigator.of(context).pushNamed(AppRouter.signIn);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountTile({
    required BuildContext context,
    required String name,
    required String subtitle,
    required bool isActive,
    String? imageUrl,
    VoidCallback? onTap,
    VoidCallback? onRemove,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFF00574C),
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
        child: imageUrl == null
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              )
            : null,
      ),
      title: Text(
        name.isEmpty ? subtitle : name,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00574C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppLocalizations.of(context)!.active,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00574C),
                ),
              ),
            ),
          if (!isActive && onRemove != null)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: Colors.grey[400]),
              onPressed: onRemove,
            ),
        ],
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
