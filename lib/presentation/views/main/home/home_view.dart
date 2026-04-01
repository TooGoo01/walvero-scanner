import 'dart:async';
// dart:math removed (confetti removed)

import 'package:cached_network_image/cached_network_image.dart';
// confetti removed
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../core/constant/colors.dart';
import '../../../../core/constant/images.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/services_locator.dart';
import '../../../../data/data_sources/local/user_local_data_source.dart';
import '../../../../data/data_sources/remote/redeem_remote_data_source.dart' show ReverseTransactionParams;
import '../../../../domain/entities/redeem/program_ui_config.dart';
import '../../../../domain/repositories/redeem_repository.dart';
import '../../../../domain/entities/redeem/redeem_lookup_response.dart';
import '../../../../domain/usecases/redeem/start_redeem_usecase.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../blocs/user/user_bloc.dart';
import 'package:walveroScanner/domain/usecases/redeem/get_lookup_bycode_usecase.dart'
    show LookupCodeParams;
import 'package:walveroScanner/presentation/blocs/redeem/redeem_bloc.dart'
    show
        LoadUiConfig,
        LookupByCodeRequested,
        RedeemBloc,
        RedeemCustomerCleared,
        RedeemError,
        RedeemLoading,
        RedeemOtpRequired,
        RedeemOtpSubmitted,
        RedeemStartLoaded,
        RedeemStartRequested,
        RedeemState;

enum RedeemMode { earn, pay }
enum PaymentMethod { cash, card }
enum RedeemType { points, freeReward }

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _deltaController = TextEditingController(text: '1');
  final _orderIdController = TextEditingController();
  final _spendCountController = TextEditingController(text: '1');

  RedeemMode _mode = RedeemMode.earn;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  RedeemType _redeemType = RedeemType.points;
  bool _isSubmitting = false;
  Timer? _lookupDebounceTimer;
  int? _selectedProgramId;

  // Animasiya controllers
  // confetti removed
  late final AnimationController _successAnimController;
  late final Animation<double> _successScaleAnim;
  bool _showSuccessOverlay = false;

  @override
  void initState() {
    super.initState();
    _successAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScaleAnim = CurvedAnimation(
      parent: _successAnimController,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Login-dən qalan loading-i bağla
      EasyLoading.dismiss(animation: false);

      // Əgər selectedProgramId yoxdursa, ilk programı seç
      final userState = context.read<UserBloc>().state;
      if (userState is UserLogged && userState.user.programs.isNotEmpty) {
        final savedProgramId = await sl<UserLocalDataSource>().getSelectedProgramId();
        if (savedProgramId == null) {
          final firstProgram = userState.user.programs.first;
          await sl<UserLocalDataSource>().saveSelectedProgramId(firstProgram.id);
          if (mounted) {
            setState(() => _selectedProgramId = firstProgram.id);
          }
        }
      }
      if (mounted) {
        context.read<RedeemBloc>().add(const LoadUiConfig());
      }
    });
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _lookupDebounceTimer?.cancel();
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    _deltaController.dispose();
    _orderIdController.dispose();
    _spendCountController.dispose();
    _successAnimController.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    final code = _codeController.text.trim();
    _lookupDebounceTimer?.cancel();
    if (code.length >= 9 && RegExp(r'^\d+$').hasMatch(code)) {
      _lookupDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted && _codeController.text.trim() == code) {
          _lookupByCode();
        }
      });
    }
  }

  Future<void> _lookupByCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    context
        .read<RedeemBloc>()
        .add(LookupByCodeRequested(LookupCodeParams(code: code, balance: 0)));
  }

  void _generateOrderId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer('ORD-');
    for (var i = 0; i < 8; i++) {
      buffer.write(chars[(random ~/ (i + 1) + i * 7) % chars.length]);
    }
    _orderIdController.text = buffer.toString();
  }

  void _clearAll() {
    _codeController.clear();
    _deltaController.text = '1';
    _orderIdController.clear();
    _spendCountController.text = '1';
    _redeemType = RedeemType.points;
    context.read<RedeemBloc>().add(const RedeemCustomerCleared());
  }

  Future<void> _showReverseDialog(LookupCard customer) async {
    final reasonController = TextEditingController();
    final l = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.undo_rounded, color: Color(0xFFef4444)),
            const SizedBox(width: 8),
            Text(l.reverseTransaction, style: const TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${customer.customerFullName} - son əməliyyatı geri al?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Səbəb',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.note_outlined),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFef4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l.reverseTransaction),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final reason = reasonController.text.trim();
      try {
        final repo = sl<RedeemRepository>();
        final result = await repo.reverseTransaction(
          ReverseTransactionParams(
            transactionId: 0,
            orderId: customer.cardNumber,
            originalType: 'earn',
            reason: reason.isEmpty ? 'Admin reverse' : reason,
          ),
        );
        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reverse uğursuz oldu'), backgroundColor: Colors.red),
              );
            }
          },
          (data) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reverse uğurla tamamlandı'), backgroundColor: Colors.green),
              );
              _clearAll();
            }
          },
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Xəta: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
    reasonController.dispose();
  }

  void _showSuccessAnimation() {
    setState(() => _showSuccessOverlay = true);
    _successAnimController.forward(from: 0);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSuccessOverlay = false);
      }
    });
  }

  Future<void> _showOtpDialog(
    BuildContext context,
    int redeemRequestId,
    String? infoMessage,
  ) async {
    final otpController = TextEditingController();
    final l = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l.otpRequired),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (infoMessage != null && infoMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child:
                      Text(infoMessage, style: const TextStyle(fontSize: 13)),
                ),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l.smsCode,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final otp = otpController.text.trim();
                if (otp.isEmpty) return;
                context.read<RedeemBloc>().add(
                      RedeemOtpSubmitted(
                        ConfirmRedeemOtpParams(
                          requestId: redeemRequestId,
                          otpCode: otp,
                        ),
                      ),
                    );
                Navigator.of(ctx).pop();
              },
              child: Text(l.confirm,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _adjustDeltaForMode({int? maxBalance}) {
    int current = int.tryParse(_deltaController.text.trim()) ?? 0;
    if (_mode == RedeemMode.earn) {
      _deltaController.text = current.abs().toString();
    } else {
      int val = -current.abs();
      if (maxBalance != null && maxBalance > 0 && (-val) > maxBalance) {
        val = -maxBalance;
      }
      _deltaController.text = val.toString();
    }
  }

  Future<void> _onApplyPressed() async {
    setState(() => _isSubmitting = true);

    final l = AppLocalizations.of(context)!;
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.enterCode)));
      return;
    }

    final redeemState = context.read<RedeemBloc>().state;
    final customer = redeemState.customer;
    final balance = customer?.currentPoints ?? 0;
    final isProgressBased = customer?.isProgressBased ?? false;

    int? spendCount;
    int delta = 0;

    if (isProgressBased && _redeemType == RedeemType.freeReward) {
      spendCount = int.tryParse(_spendCountController.text.trim()) ?? 1;
      if (spendCount < 1) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Say 1-den kicik ola bilmez')));
        return;
      }
      if (customer?.maxSpendCount != null &&
          spendCount > customer!.maxSpendCount!) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Maksimum ${customer.maxSpendCount}')));
        return;
      }
      if (customer?.completedCycles != null &&
          spendCount > customer!.completedCycles!) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Movcud mukafat ${customer.completedCycles}')));
        return;
      }
      delta = 0;
    } else {
      delta = int.tryParse(_deltaController.text.trim()) ?? 0;
      if (_mode == RedeemMode.earn) {
        if (delta <= 0) delta = delta.abs();
      } else {
        delta = -delta.abs();
        if (balance > 0 && (-delta) > balance) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Maksimum $balance')));
          return;
        }
      }
    }

    final orderId = _orderIdController.text.trim();
    final paymentMethodStr = _mode == RedeemMode.earn
        ? (_paymentMethod == PaymentMethod.cash ? 'cash' : 'card')
        : 'balance';

    final params = StartRedeemParams(
      code: code,
      delta: delta,
      orderId: orderId,
      operationType: _mode == RedeemMode.earn ? 'earn' : 'pay',
      paymentMethod: paymentMethodStr,
      spendCount: spendCount,
    );

    context.read<RedeemBloc>().add(RedeemStartRequested(params));
  }

  Future<void> _onScanPressed() async {
    final result =
        await Navigator.of(context).pushNamed(AppRouter.scanBarcode);
    if (result is String && result.isNotEmpty) {
      _codeController.text = result;
      await _lookupByCode();
    }
  }

  // ─── Helpers ───

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kCardShadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  InputDecoration _inputDecoration({
    String? hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: kPrimaryColor) : null,
      filled: true,
      fillColor: kSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: kPrimaryColor, width: 1.5),
      ),
    );
  }

  // ─── BUILD ───

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? screenWidth * 0.15 : 16.0;

    return Scaffold(
      backgroundColor: kSurfaceColor,
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: BlocListener<UserBloc, UserState>(
              listener: (context, state) {
                if (state is UserLogged) {
                  // User/hesab dəyişdikdə UI-ı tamamilə yenilə
                  _codeController.clear();
                  _deltaController.text = '1';
                  _orderIdController.clear();
                  _spendCountController.text = '1';
                  context.read<RedeemBloc>().add(RedeemCustomerCleared());
                  context.read<RedeemBloc>().add(const LoadUiConfig());
                  setState(() {});
                }
              },
              child: BlocListener<RedeemBloc, RedeemState>(
              listener: (context, state) async {
                final l = AppLocalizations.of(context)!;
                if (state is RedeemOtpRequired) {
                  setState(() => _isSubmitting = false);
                  await _showOtpDialog(
                      context, state.redeemRequestId, state.infoMessage);
                }
                if (state is RedeemStartLoaded && state.failure == null) {
                  setState(() => _isSubmitting = false);
                  _showSuccessAnimation();
                  _clearAll();
                }
                if (state is RedeemError && state.failure != null) {
                  if (_isSubmitting) {
                    setState(() => _isSubmitting = false);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.error),
                      backgroundColor: kErrorColor,
                    ),
                  );
                }
              },
              child: BlocBuilder<RedeemBloc, RedeemState>(
                builder: (context, redeemState) {
                  final l = AppLocalizations.of(context)!;
                  final ProgramUiConfig? config = redeemState.config;
                  final bool isLoading =
                      redeemState is RedeemLoading && config == null;
                  final bool isError =
                      redeemState is RedeemError && config == null;
                  final bool isTierBased = config?.templateType == 3;
                  final bool isProgressBased = config?.templateType == 1;
                  final bool showBalance = config?.showBalanceOnUi ?? true;
                  final customer = redeemState.customer;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        topPadding + 12,
                        horizontalPadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 8),
                          _buildProgramSelector(context),
                          const SizedBox(height: 16),
                          if (isLoading)
                            _buildLoadingState(l)
                          else if (isError)
                            _buildErrorState(l)
                          else
                            _buildContent(
                              context: context,
                              config: config,
                              isTierBased: isTierBased,
                              isProgressBased: isProgressBased,
                              showBalance: showBalance,
                              customer: customer,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          ),
          // Success overlay
          if (_showSuccessOverlay) _buildSuccessOverlay(),
          // confetti removed
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return AnimatedBuilder(
      animation: _successScaleAnim,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: Transform.scale(
              scale: _successScaleAnim.value,
              child: Container(
                width: MediaQuery.of(context).size.width > 600 ? 160 : 120,
                height: MediaQuery.of(context).size.width > 600 ? 160 : 120,
                decoration: BoxDecoration(
                  color: kSuccessColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kSuccessColor.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 64),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            CircularProgressIndicator(color: kPrimaryColor),
            const SizedBox(height: 12),
            Text(l.configLoading, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: kErrorColor, size: 32),
            const SizedBox(height: 8),
            Text(l.configFailed,
                style: TextStyle(fontSize: 15, color: kErrorColor)),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () =>
                  context.read<RedeemBloc>().add(const LoadUiConfig()),
              child:
                  Text(l.retry, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ───

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final isLogged = state is UserLogged;
        final user = isLogged ? state.user : null;

        return Row(
          children: [
            // Logo/Avatar
            GestureDetector(
              onTap: () {
                if (isLogged) {
                  Navigator.of(context).pushNamed(AppRouter.other);
                } else {
                  Navigator.of(context).pushNamed(AppRouter.signIn);
                }
              },
              child: _buildAvatar(user?.googleLogoUrl ?? user?.image),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLogged
                        ? '${user!.firstName} ${user.lastName}'.trim()
                        : 'Walvero Partner',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isLogged && user!.roles.isNotEmpty)
                    Text(
                      user.roles.first,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            // Settings
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: kCardShadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.settings_outlined,
                    color: Colors.grey.shade700, size: 22),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRouter.other),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar(String? imageUrl) {
    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, image) => CircleAvatar(
          radius: 22,
          backgroundImage: image,
          backgroundColor: Colors.transparent,
        ),
        errorWidget: (context, url, error) => const CircleAvatar(
          radius: 22,
          backgroundImage: AssetImage(kUserAvatar),
          backgroundColor: Colors.transparent,
        ),
      );
    }
    return const CircleAvatar(
      radius: 22,
      backgroundImage: AssetImage(kUserAvatar),
      backgroundColor: Colors.transparent,
    );
  }

  // ─── PROGRAM SELECTOR ───

  Widget _buildProgramSelector(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! UserLogged) return const SizedBox.shrink();
        final programs = state.user.programs;
        if (programs.length <= 1) return const SizedBox.shrink();

        _selectedProgramId ??= state.user.programId;
        if (_selectedProgramId == null ||
            !programs.any((p) => p.id == _selectedProgramId)) {
          _selectedProgramId = programs.first.id;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: _cardDecoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.swap_horiz, size: 18, color: kPrimaryColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedProgramId,
                    isExpanded: true,
                    isDense: true,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    items: programs.map((p) {
                      return DropdownMenuItem<int>(
                        value: p.id,
                        child: Text(
                          '${p.programName} (${p.programTypeLabel})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (newProgramId) async {
                      if (newProgramId == null ||
                          newProgramId == _selectedProgramId) return;
                      setState(() => _selectedProgramId = newProgramId);
                      await sl<UserLocalDataSource>()
                          .saveSelectedProgramId(newProgramId);
                      if (!mounted) return;
                      context.read<RedeemBloc>().add(const LoadUiConfig());
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── CONTENT ───

  Widget _buildContent({
    required BuildContext context,
    required ProgramUiConfig? config,
    required bool isTierBased,
    required bool isProgressBased,
    required bool showBalance,
    required LookupCard? customer,
  }) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Card 1: Scan & Kod ──
        Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.qr_code_2, size: 20, color: kPrimaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Scan & Kod',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  if (config != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        config.programName,
                        style: TextStyle(
                            fontSize: 11,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: _inputDecoration(
                        hint: 'Skan edin ve ya yazin...',
                        prefixIcon: Icons.confirmation_number_outlined,
                      ),
                      onSubmitted: (_) => _lookupByCode(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildScanButton(),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Card 2: Operation ──
        Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Operation type toggle (non-progress)
              if (!isProgressBased) ...[
                Row(
                  children: [
                    Icon(Icons.compare_arrows, size: 20, color: kPrimaryColor),
                    const SizedBox(width: 8),
                    Text(l.earn,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildModeToggle(l, customer),
                const SizedBox(height: 10),
                // Payment method toggle removed - user balance only
                const SizedBox(height: 14),
              ],

              // Progress-based: free reward info + selection
              if (isProgressBased &&
                  customer != null &&
                  customer.isProgressBased) ...[
                _buildFreeRewardInfo(customer),
                const SizedBox(height: 12),
                _buildRedeemTypeChips(l, customer),
                const SizedBox(height: 14),
              ],

              // Spend count (progress + free reward)
              if (customer != null &&
                  customer.isProgressBased &&
                  _redeemType == RedeemType.freeReward) ...[
                _buildSpendCountInput(customer),
                const SizedBox(height: 14),
              ],

              // Delta input (points mode or non-progress)
              if (customer == null ||
                  !customer.isProgressBased ||
                  _redeemType == RedeemType.points)
                _buildDeltaInput(),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Customer Card (animated) ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: customer != null
              ? _CustomerInfoCard(
                  key: ValueKey(customer.cardNumber),
                  customer: customer,
                  isTierBased: isTierBased,
                  showBalance: showBalance,
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
        if (customer != null) const SizedBox(height: 10),

        // ── Reverse Button ──
        if (customer != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showReverseDialog(customer),
              icon: const Icon(Icons.undo_rounded, size: 18),
              label: const Text('Reverse'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFef4444),
                side: const BorderSide(color: Color(0xFFef4444), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        if (customer != null) const SizedBox(height: 14),

        // ── Order ID ──
        Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, size: 20, color: kPrimaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Order ID',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _orderIdController,
                      style: const TextStyle(fontSize: 14),
                      decoration: _inputDecoration(
                        hint: 'Order ID (opsional)',
                        prefixIcon: Icons.tag,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _generateOrderId,
                      icon: const Icon(Icons.autorenew, size: 18),
                      label: const Text('Auto', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Apply Button ──
        _buildApplyButton(),
        const SizedBox(height: 6),

        // ── Clear Button ──
        Center(
          child: TextButton(
            onPressed: _clearAll,
            child: Text(
              'Temizle',
              style: TextStyle(
                fontSize: 14,
                color: kPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── SUB-WIDGETS ───

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: _onScanPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: MediaQuery.of(context).size.width > 600 ? 60 : 52,
        height: MediaQuery.of(context).size.width > 600 ? 60 : 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, kPrimaryGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.qr_code_scanner, size: 26, color: Colors.white),
      ),
    );
  }

  Widget _buildModeToggle(AppLocalizations l, LookupCard? customer) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: kSurfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _mode = RedeemMode.earn;
                      _adjustDeltaForMode(maxBalance: customer?.currentPoints);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _mode == RedeemMode.earn ? kEarnColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        l.earn,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _mode == RedeemMode.earn ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _mode = RedeemMode.pay;
                      _adjustDeltaForMode(maxBalance: customer?.currentPoints);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _mode == RedeemMode.pay ? kPayColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        l.pay,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _mode == RedeemMode.pay ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Payment method - yalnız qazan modunda
        if (_mode == RedeemMode.earn) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: kSurfaceColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _paymentMethod = PaymentMethod.cash),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _paymentMethod == PaymentMethod.cash ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _paymentMethod == PaymentMethod.cash
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)]
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.payments_outlined, size: 16, color: _paymentMethod == PaymentMethod.cash ? kPrimaryColor : Colors.grey),
                            const SizedBox(width: 4),
                            Text(l.cash, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _paymentMethod == PaymentMethod.cash ? kPrimaryColor : Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _paymentMethod = PaymentMethod.card),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _paymentMethod == PaymentMethod.card ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _paymentMethod == PaymentMethod.card
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)]
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.credit_card, size: 16, color: _paymentMethod == PaymentMethod.card ? kPrimaryColor : Colors.grey),
                            const SizedBox(width: 4),
                            Text(l.card, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _paymentMethod == PaymentMethod.card ? kPrimaryColor : Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFreeRewardInfo(LookupCard customer) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSuccessColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kSuccessColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kSuccessColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.card_giftcard, color: kSuccessColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${customer.completedCycles ?? 0} ${customer.freeRewardLabel ?? "Pulsuz"}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kSuccessColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Movcuddur',
                  style: TextStyle(
                    fontSize: 12,
                    color: kSuccessColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemTypeChips(AppLocalizations l, LookupCard customer) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _redeemType = RedeemType.points),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _redeemType == RedeemType.points
                      ? kPrimaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    l.bonusAdd,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _redeemType == RedeemType.points
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (customer.completedCycles == null ||
                    customer.completedCycles! <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Movcud mukafat yoxdur')));
                  return;
                }
                setState(() => _redeemType = RedeemType.freeReward);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _redeemType == RedeemType.freeReward
                      ? kPrimaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Bonusdan Istifade',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _redeemType == RedeemType.freeReward
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendCountInput(LookupCard customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Xerclem sayi',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _spendCountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 15),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'\d*')),
                ],
                decoration: _inputDecoration(),
                onChanged: (value) {
                  final count = int.tryParse(value) ?? 0;
                  if (customer.maxSpendCount != null &&
                      count > customer.maxSpendCount!) {
                    _spendCountController.text =
                        customer.maxSpendCount.toString();
                  }
                },
              ),
            ),
            if (customer.maxSpendCount != null) ...[
              const SizedBox(width: 8),
              Text('/ ${customer.maxSpendCount}',
                  style:
                      TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDeltaInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.monetization_on_outlined,
                size: 18, color: kPrimaryColor),
            const SizedBox(width: 6),
            const Text('Mebleg (delta / xal)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _deltaController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
          ],
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _onApplyPressed,
      child: AnimatedScale(
        scale: _isSubmitting ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width > 600 ? 62 : 54,
          decoration: BoxDecoration(
            gradient: _isSubmitting
                ? null
                : LinearGradient(
                    colors: [kPrimaryColor, kPrimaryGradientEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            color: _isSubmitting ? Colors.grey.shade400 : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isSubmitting
                ? []
                : [
                    BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Tetbiq et',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── CUSTOMER INFO CARD ───

class _CustomerInfoCard extends StatelessWidget {
  final LookupCard customer;
  final bool isTierBased;
  final bool showBalance;

  const _CustomerInfoCard({
    super.key,
    required this.customer,
    required this.isTierBased,
    required this.showBalance,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: kCardShadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + card number
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: kPrimaryColor,
                child:
                    const Icon(Icons.person_outline, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.customerFullName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.cardNumber,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (showBalance || isTierBased ||
              (customer.isProgressBased && customer.completedCycles != null))
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Balance
                    if (showBalance)
                      _infoRow(
                        Icons.account_balance_wallet_outlined,
                        const Color(0xFFf59e0b),
                        'Balans',
                        '${customer.currentPoints} ${customer.currency ?? 'AZN'}',
                      ),

                    // Progress reward
                    if (customer.isProgressBased &&
                        customer.completedCycles != null) ...[
                      if (showBalance) const SizedBox(height: 10),
                      _infoRow(
                        Icons.card_giftcard,
                        kSuccessColor,
                        'Mukafat',
                        '${customer.completedCycles!} ${customer.freeRewardLabel ?? "Pulsuz"}',
                      ),
                    ],

                    // Tier (tier adı + faiz)
                    if (isTierBased) ...[
                      const SizedBox(height: 10),
                      _tierRow(),
                    ],

                    // PointsBased - yalnız faizlər, tier adı yox
                    if (!isTierBased &&
                        !customer.isProgressBased &&
                        (customer.tierPercent > 0 || customer.tierPercentCash > 0)) ...[
                      const SizedBox(height: 10),
                      _infoRow(
                        Icons.percent,
                        Colors.orange,
                        'Cashback',
                        'Kart:${customer.tierPercent}% Nağd:${customer.tierPercentCash}%',
                      ),
                    ],

                    // Qazanma / Xərcləmə əməliyyat sayları
                    if (customer.earnCount > 0 || customer.spendCount > 0) ...[
                      const SizedBox(height: 10),
                      _infoRow(
                        Icons.arrow_upward,
                        const Color(0xFF22c55e),
                        'Qazanma',
                        '${customer.earnCount}',
                      ),
                      const SizedBox(height: 8),
                      _infoRow(
                        Icons.arrow_downward,
                        const Color(0xFFef4444),
                        'Xərcləmə',
                        '${customer.spendCount}',
                      ),
                    ],
                  ],
                ),
              ),
            ),

        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        const Spacer(),
        Text(value,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _tierRow() {
    return Row(
      children: [
        if (customer.tierIconUrl != null && customer.tierIconUrl!.isNotEmpty)
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(customer.tierIconUrl!),
            backgroundColor: Colors.transparent,
          )
        else
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.workspace_premium,
                size: 16, color: Color(0xFFFFD700)),
          ),
        const SizedBox(width: 10),
        Text('Tier',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              customer.tierName ?? 'Tier yoxdur',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            Text(
              'Kart:${customer.tierPercent}% Nagd:${customer.tierPercentCash}%',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }
}
