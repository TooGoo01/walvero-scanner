import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/services_locator.dart';
import '../../../domain/entities/statistics/dashboard_statistics.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/statistics/statistics_bloc.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  bool _isMonthly = false;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _displayDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  List<String> _localizedMonths(AppLocalizations l) => [
        '',
        l.monthJan,
        l.monthFeb,
        l.monthMar,
        l.monthApr,
        l.monthMay,
        l.monthJun,
        l.monthJul,
        l.monthAug,
        l.monthSep,
        l.monthOct,
        l.monthNov,
        l.monthDec,
      ];

  String _monthYear(DateTime d, AppLocalizations l) =>
      '${_localizedMonths(l)[d.month]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => sl<StatisticsBloc>()
        ..add(LoadDashboard(
          startDate: _formatDate(_startDate),
          endDate: _formatDate(_endDate),
        )),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(l.statsTitle),
          backgroundColor: const Color(0xFF00574C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            final l = AppLocalizations.of(context)!;
            if (state is StatisticsLoading || state is StatisticsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is StatisticsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 12),
                    Text(l.statsLoadFailed),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _reload(context),
                      child: Text(l.retry),
                    ),
                  ],
                ),
              );
            }
            if (state is StatisticsLoaded) {
              return _buildContent(context, state.statistics);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardStatistics stats) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.1 : 12.0;
    return RefreshIndicator(
      onRefresh: () async => _reload(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        children: [
          _buildDateFilter(context),
          const SizedBox(height: 16),
          _buildSummaryCards(stats),
          const SizedBox(height: 20),
          _buildPeriodToggle(),
          const SizedBox(height: 12),
          _buildDailyList(stats),
        ],
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        children: [
          // Date range row
          InkWell(
            onTap: () => _selectDateRange(context),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 18, color: Color(0xFF00574C)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_displayDate(_startDate)} - ${_displayDate(_endDate)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF00574C)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Quick filter chips
          Row(
            children: [
              Expanded(child: _buildQuickFilter(context, l.today, 0, isSmall)),
              const SizedBox(width: 6),
              Expanded(child: _buildQuickFilter(context, l.days7, 7, isSmall)),
              const SizedBox(width: 6),
              Expanded(child: _buildQuickFilter(context, l.days30, 30, isSmall)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilter(BuildContext context, String label, int days, bool isSmall) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _endDate = DateTime.now();
          _startDate = days == 0
              ? DateTime.now()
              : DateTime.now().subtract(Duration(days: days));
        });
        _reload(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 6 : 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF00574C).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 10 : 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF00574C),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(DashboardStatistics stats) {
    final l = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isSmall = screenWidth < 360;

    return GridView.count(
      crossAxisCount: isTablet ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: isTablet ? 1.4 : (isSmall ? 1.3 : 1.5),
      children: [
        _summaryCard(
          l.transactions,
          stats.totalTransactions.toString(),
          Icons.receipt_long_rounded,
          const Color(0xFF1976D2),
        ),
        _summaryCard(
          l.pointsEarned,
          stats.totalPointsEarned.toString(),
          Icons.trending_up_rounded,
          const Color(0xFF388E3C),
        ),
        _summaryCard(
          l.pointsSpent,
          stats.totalPointsSpent.toString(),
          Icons.trending_down_rounded,
          const Color(0xFFE64A19),
        ),
        _summaryCard(
          l.uniqueCustomers,
          stats.uniqueCustomers.toString(),
          Icons.people_outline_rounded,
          const Color(0xFF7B1FA2),
        ),
      ],
    );
  }

  Widget _summaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodToggle() {
    final l = AppLocalizations.of(context)!;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Text(
          l.detailedStats,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(l.daily)),
            ButtonSegment(value: true, label: Text(l.monthly)),
          ],
          selected: {_isMonthly},
          onSelectionChanged: (v) => setState(() => _isMonthly = v.first),
          style: ButtonStyle(
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 12),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyList(DashboardStatistics stats) {
    final l = AppLocalizations.of(context)!;
    if (stats.dailyStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Text(
          l.noTransactionsInRange,
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      );
    }

    List<_AggregatedStat> items;
    if (_isMonthly) {
      final grouped = <String, _AggregatedStat>{};
      for (final d in stats.dailyStats) {
        final key =
            '${d.date.year}-${d.date.month.toString().padLeft(2, '0')}';
        final existing = grouped[key];
        if (existing != null) {
          grouped[key] = _AggregatedStat(
            label: _monthYear(d.date, l),
            transactionCount:
                existing.transactionCount + d.transactionCount,
            pointsEarned: existing.pointsEarned + d.pointsEarned,
            pointsSpent: existing.pointsSpent + d.pointsSpent,
          );
        } else {
          grouped[key] = _AggregatedStat(
            label: _monthYear(d.date, l),
            transactionCount: d.transactionCount,
            pointsEarned: d.pointsEarned,
            pointsSpent: d.pointsSpent,
          );
        }
      }
      items = grouped.values.toList();
    } else {
      items = stats.dailyStats
          .map((d) => _AggregatedStat(
                label: _displayDate(d.date),
                transactionCount: d.transactionCount,
                pointsEarned: d.pointsEarned,
                pointsSpent: d.pointsSpent,
              ))
          .toList()
          .reversed
          .toList();
    }

    return Column(
      children: items.map((item) => _buildStatRow(item)).toList(),
    );
  }

  Widget _buildStatRow(_AggregatedStat item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 380;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isSmall ? 10 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isSmall ? _buildStatRowCompact(item) : _buildStatRowWide(item),
    );
  }

  Widget _buildStatRowWide(_AggregatedStat item) {
    final l = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            item.label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _statBadge('${item.transactionCount}', l.transactionShort, Colors.grey[700]!),
        const SizedBox(width: 8),
        _statBadge('+${item.pointsEarned}', l.earnedShort, const Color(0xFF388E3C)),
        const SizedBox(width: 8),
        _statBadge('-${item.pointsSpent}', l.spentShort, const Color(0xFFE64A19)),
      ],
    );
  }

  Widget _buildStatRowCompact(_AggregatedStat item) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statBadge('${item.transactionCount}', l.transactionShort, Colors.grey[700]!),
            _statBadge('+${item.pointsEarned}', l.earnedShort, const Color(0xFF388E3C)),
            _statBadge('-${item.pointsSpent}', l.spentShort, const Color(0xFFE64A19)),
          ],
        ),
      ],
    );
  }

  Widget _statBadge(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 9, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final bloc = context.read<StatisticsBloc>();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00574C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      bloc.add(LoadDashboard(
        startDate: _formatDate(_startDate),
        endDate: _formatDate(_endDate),
      ));
    }
  }

  void _reload(BuildContext context) {
    context.read<StatisticsBloc>().add(LoadDashboard(
          startDate: _formatDate(_startDate),
          endDate: _formatDate(_endDate),
        ));
  }
}

class _AggregatedStat {
  final String label;
  final int transactionCount;
  final int pointsEarned;
  final int pointsSpent;

  _AggregatedStat({
    required this.label,
    required this.transactionCount,
    required this.pointsEarned,
    required this.pointsSpent,
  });
}
