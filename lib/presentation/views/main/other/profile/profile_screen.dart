import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walveroScanner/core/constant/images.dart' show kUserAvatar;

import '../../../../../core/services/services_locator.dart';
import '../../../../../domain/entities/customer/customer.dart';
import '../../../../../domain/entities/user/user.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../blocs/customer/customer_bloc.dart';
import '../../../customer/customer_detail_view.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;
  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final isTenantAdmin = widget.user.isTenantAdmin;

    return BlocProvider(
      create: (_) {
        final bloc = sl<CustomerBloc>();
        if (isTenantAdmin) bloc.add(LoadCustomers());
        return bloc;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFF00574C),
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00574C), Color(0xFF008066)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          _buildAvatar(),
                          const SizedBox(height: 10),
                          Text(
                            '${widget.user.firstName} ${widget.user.lastName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user.email,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                          if (isTenantAdmin) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.tenantAdmin,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: isTenantAdmin
              ? _buildAdminBody()
              : _buildRegularBody(),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    Widget avatar(ImageProvider image) => CircleAvatar(
          radius: 36,
          backgroundImage: image,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
        );

    if (widget.user.googleLogoUrl != null) {
      return CachedNetworkImage(
        imageUrl: widget.user.googleLogoUrl!,
        imageBuilder: (_, img) => avatar(img),
        errorWidget: (_, __, ___) => avatar(AssetImage(kUserAvatar)),
      );
    }
    if (widget.user.image != null) {
      return CachedNetworkImage(
        imageUrl: widget.user.image!,
        imageBuilder: (_, img) => avatar(img),
        errorWidget: (_, __, ___) => avatar(AssetImage(kUserAvatar)),
      );
    }
    return avatar(AssetImage(kUserAvatar));
  }

  // ─── Regular user: just profile info ───
  Widget _buildRegularBody() {
    final l = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final pad = isTablet ? screenWidth * 0.15 : 20.0;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 20),
      children: [
        _infoCard(Icons.person_outline, l.firstName, widget.user.firstName),
        _infoCard(Icons.person_outline, l.lastName, widget.user.lastName),
        _infoCard(Icons.email_outlined, l.email, widget.user.email),
        if (widget.user.phone != null && widget.user.phone!.isNotEmpty)
          _infoCard(Icons.phone_outlined, l.phone, widget.user.phone!),
      ],
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF00574C)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tenant admin: profile info + tenant info ───
  Widget _buildAdminBody() {
    final l = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final pad = isTablet ? screenWidth * 0.15 : 20.0;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 20),
      children: [
        // User info section
        _sectionHeader(Icons.person_outline, l.profile),
        const SizedBox(height: 8),
        _infoCard(Icons.account_circle_outlined, 'Username', widget.user.userName),
        _infoCard(Icons.person_outline, l.firstName, widget.user.firstName),
        _infoCard(Icons.person_outline, l.lastName, widget.user.lastName),
        _infoCard(Icons.email_outlined, l.email, widget.user.email),
        if (widget.user.phone != null && widget.user.phone!.isNotEmpty)
          _infoCard(Icons.phone_outlined, l.phone, widget.user.phone!),
        _infoCard(Icons.badge_outlined, 'Rol', widget.user.roles.join(', ')),

        const SizedBox(height: 20),

        // Tenant info section
        _sectionHeader(Icons.business_outlined, 'Tenant'),
        const SizedBox(height: 8),
        if (widget.user.tenantName != null && widget.user.tenantName!.isNotEmpty)
          _infoCard(Icons.store_outlined, 'Tenant', widget.user.tenantName!),
        if (widget.user.tenantId != null)
          _infoCard(Icons.tag, 'Tenant ID', widget.user.tenantId.toString()),
        if (widget.user.subscriptionExpiryDate != null)
          _infoCard(
            Icons.event_outlined,
            'Abunəlik bitmə tarixi',
            '${widget.user.subscriptionExpiryDate!.day.toString().padLeft(2, '0')}.${widget.user.subscriptionExpiryDate!.month.toString().padLeft(2, '0')}.${widget.user.subscriptionExpiryDate!.year}',
          ),
        if (widget.user.programs.isNotEmpty) ...[
          _infoCard(
            Icons.loyalty_outlined,
            'Proqramlar',
            widget.user.programs.map((p) => '${p.programName} (${p.programTypeLabel})').join('\n'),
          ),
        ],

        const SizedBox(height: 20),

        // Customers button
        _buildCustomersButton(context),
      ],
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00574C)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00574C),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomersButton(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _CustomerListPage(user: widget.user),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF00574C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              l.customers,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

}

// ─── Separate page for customer list ───
class _CustomerListPage extends StatefulWidget {
  final User user;
  const _CustomerListPage({required this.user});

  @override
  State<_CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<_CustomerListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Customer> _filterCustomers(List<Customer> customers) {
    if (_searchQuery.isEmpty) return customers;
    final q = _searchQuery.toLowerCase();
    return customers.where((c) {
      return c.fullName.toLowerCase().contains(q) ||
          c.phoneNumber.toLowerCase().contains(q) ||
          (c.email?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => sl<CustomerBloc>()..add(LoadCustomers()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(l.customers),
          backgroundColor: const Color(0xFF00574C),
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Search bar
            Container(
              color: const Color(0xFF00574C),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: l.searchByNamePhoneEmail,
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.7)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  if (state is CustomersLoading || state is CustomerInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is CustomerError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                          const SizedBox(height: 12),
                          Text(l.dataLoadFailed),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.read<CustomerBloc>().add(LoadCustomers()),
                            child: Text(l.retry),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is CustomersLoaded) {
                    final filtered = _filterCustomers(state.customers);
                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty ? l.noResults : l.noCustomers,
                              style: TextStyle(color: Colors.grey[500], fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => context.read<CustomerBloc>().add(LoadCustomers()),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final customer = filtered[index];
                          final hasCards = customer.loyaltyCards.isNotEmpty;
                          final card = hasCards ? customer.loyaltyCards.first : null;
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CustomerDetailView(customer: customer)),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
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
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: const Color(0xFF00574C).withValues(alpha: 0.1),
                                    child: Text(
                                      customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : '?',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00574C)),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(customer.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.phone_outlined, size: 14, color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(customer.phoneNumber, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                          ],
                                        ),
                                        if (hasCards && card != null) ...[
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF388E3C).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${card.currentPoints} ${l.points}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF388E3C)),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 24),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
