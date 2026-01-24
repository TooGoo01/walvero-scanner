import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:walveroScanner/domain/usecases/redeem/get_lookup_bycode_usecase.dart' show LookupCodeParams;
import 'package:walveroScanner/presentation/blocs/redeem/redeem_bloc.dart' show LoadUiConfig, LookupByCodeRequested, RedeemBloc, RedeemCustomerCleared, RedeemError, RedeemLoading, RedeemOtpRequired, RedeemOtpSubmitted, RedeemStartLoaded, RedeemStartRequested, RedeemState;

import '../../../../core/constant/images.dart';
import '../../../../core/router/app_router.dart';
import '../../../../domain/entities/redeem/program_ui_config.dart';
import '../../../../domain/entities/redeem/redeem_lookup_response.dart';
import '../../../../domain/usecases/redeem/start_redeem_usecase.dart';
import '../../../blocs/user/user_bloc.dart';
enum RedeemMode { earn, pay }        // Qazan / Ödə
enum PaymentMethod { cash, card }    // Nağd / Kart
enum RedeemType { points, freeReward } // Points Xərclə / Free Reward Xərclə
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _codeController = TextEditingController();
  final _deltaController = TextEditingController(text: '1');
  final _orderIdController = TextEditingController();
  final _spendCountController = TextEditingController(text: '1');
  RedeemMode _mode = RedeemMode.earn;              // default: Qazan
  PaymentMethod _paymentMethod = PaymentMethod.cash; // default: Nağd
  RedeemType _redeemType = RedeemType.points; 

       // default: Points
  bool _isSubmitting = false;                    // Button loading state
  Timer? _lookupDebounceTimer;                     // Debounce timer for auto lookup

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RedeemBloc>().add(const LoadUiConfig());
    });
    
    // TextField-ə listener əlavə et
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
    super.dispose();
  }

  // Barcode 9+ rəqəm yazıldıqda avtomatik lookup
  void _onCodeChanged() {
    final code = _codeController.text.trim();
    
    // Əvvəlki timer-i ləğv et
    _lookupDebounceTimer?.cancel();
    
    // Əgər 9 və ya daha çox rəqəm varsa, 500ms sonra lookup çağır
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

    context.read<RedeemBloc>().add(
          LookupByCodeRequested(
            LookupCodeParams(code: code,balance:0)
          
          ),
        );
  }

  void _clearAll() {
    _codeController.clear();
    _deltaController.text = '1';
    _orderIdController.clear();
    _spendCountController.text = '1';
    _redeemType = RedeemType.points;
    context.read<RedeemBloc>().add(const RedeemCustomerCleared());
  }
Future<void> _showOtpDialog(
  BuildContext context,
  int redeemRequestId,
  String? infoMessage,
) async {
  final otpController = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('OTP təsdiqi tələb olunur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (infoMessage != null && infoMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  infoMessage,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'SMS kodu',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Ləğv et'),
          ),
          ElevatedButton(
            onPressed: () {
              final otp = otpController.text.trim();
              if (otp.isEmpty) return;

              // 🔹 BLoC-ə OTP submit event göndər
              context.read<RedeemBloc>().add(
                    RedeemOtpSubmitted(
                      ConfirmRedeemOtpParams(
                        requestId: redeemRequestId,
                        otpCode: otp,
                        // istəsən kodu da ötür
                      ),
                    ),
                  );

              Navigator.of(ctx).pop();
            },
            child: const Text('Təsdiqlə'),
          ),
        ],
      );
    },
  );
}
void _adjustDeltaForMode({int? maxBalance}) {
  int current = int.tryParse(_deltaController.text.trim()) ?? 0;

  if (_mode == RedeemMode.earn) {
    // Qazan → həmişə müsbət
    _deltaController.text = current.abs().toString();
  } else {
    // Ödə → həmişə mənfi, modul maxBalance-dan böyük olmasın
    int val = -current.abs();
    if (maxBalance != null && maxBalance > 0 && (-val) > maxBalance) {
      val = -maxBalance;
    }
    _deltaController.text = val.toString();
  }
}
Future<void> _onApplyPressed() async {
  // Loading state-i dərhal aktivləşdir
  setState(() {
    _isSubmitting = true;
  });

  final code = _codeController.text.trim();
  if (code.isEmpty) {
    setState(() {
      _isSubmitting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kod daxil edin')),
    );
    return;
  }

  // cari state-dən customer və balansı götür
  final redeemState = context.read<RedeemBloc>().state;
  final customer = redeemState.customer;
  final balance = customer?.currentPoints ?? 0;
  final isProgressBased = customer?.isProgressBased ?? false;

  int? spendCount;
  int delta = 0;

  // ProgressBased kart üçün free reward xərcləməsi
  if (isProgressBased && _redeemType == RedeemType.freeReward) {
    spendCount = int.tryParse(_spendCountController.text.trim()) ?? 1;
    
    // Validasiya
    if (spendCount < 1) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xərcləmə sayı 1-dən kiçik ola bilməz')),
      );
      return;
    }

    if (customer?.maxSpendCount != null && spendCount > customer!.maxSpendCount!) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maksimum xərcləmə sayı ${customer.maxSpendCount}-dir.',
          ),
        ),
      );
      return;
    }

    if (customer?.completedCycles != null && spendCount > customer!.completedCycles!) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mövcud mükafat sayı ${customer.completedCycles}-dir.',
          ),
        ),
      );
      return;
    }

    // Free reward xərcləməsi üçün delta 0 olmalıdır
    delta = 0;
  } else {
    // Points-based redeem (mövcud loqika)
    delta = int.tryParse(_deltaController.text.trim()) ?? 0;

    // 🔹 Qazan / Ödə loqikası
    if (_mode == RedeemMode.earn) {
      // Qazan → müsbət
      if (delta <= 0) {
        delta = delta.abs();
      }
    } else {
      // Ödə → mənfi, modul balansdan böyük olmasın
      delta = -delta.abs();

      if (balance > 0 && (-delta) > balance) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Maksimum çıxıla bilən say $balance Kofedir.',
            ),
          ),
        );
        return;
      }
    }
  }

  final orderId = _orderIdController.text.trim();

  // 🔹 Payment method string (backend necə istəyirsə elə map elə)
  final String paymentMethodStr =
      _paymentMethod == PaymentMethod.cash ? 'cash' : 'card';

  // 🔹 Backend parametrləri
  final params = StartRedeemParams(
    code: code,
    delta: delta,
    orderId: orderId,
    operationType: _mode == RedeemMode.earn ? 'earn' : 'pay',
    paymentMethod: paymentMethodStr,
    spendCount: spendCount, // Free reward üçün: 1, 2, 3, ... | Points üçün: null
  );

  context.read<RedeemBloc>().add(
        RedeemStartRequested(params),
      );
}


  Future<void> _onScanPressed() async {
    final result = await Navigator.of(context).pushNamed(AppRouter.scanBarcode);

    if (result is String && result.isNotEmpty) {
      _codeController.text = result;
       await _lookupByCode();
    }
  }


  @override
Widget build(BuildContext context) {
  final topPadding = MediaQuery.of(context).padding.top;

  return Scaffold(
    backgroundColor: const Color(0xFFF4F4F4),
    body: SafeArea(
      top: false,
      child: BlocListener<RedeemBloc, RedeemState>(
        listener: (context, state) async {
          // 🔹 OTP tələb olunursa -> popup aç
          if (state is RedeemOtpRequired) {
            setState(() {
              _isSubmitting = false; // OTP dialog açıldıqda button-u enable et
            });
            await _showOtpDialog(
              context,
              state.redeemRequestId,
              state.infoMessage,
            );
          }

          // Request uğurlu olduqda (yalnız start redeem üçün)
          if(state is RedeemStartLoaded && state.failure==null){
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Balans uğurla yeniləndi!',
                ),
                backgroundColor: Colors.green[300],
              ),
            );
            _clearAll();
          }

          // Request error olduqda (yalnız start redeem üçün)
          if (state is RedeemError && state.failure != null && _isSubmitting) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Xəta baş verdi',
                ),
              ),
            );
          }
        },
        child: BlocBuilder<RedeemBloc, RedeemState>(
          builder: (context, redeemState) {
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
                  16,
                  topPadding + 8,
                  16,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),

                    if (isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 12),
                              const Text(
                                'Konfiqurasiya yüklənir...',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isError)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade400,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'UiConfig yüklənmədi',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.red.shade400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<RedeemBloc>()
                                      .add(const LoadUiConfig());
                                },
                                child: const Text('Yenidən cəhd et'),
                              ),
                            ],
                          ),
                        ),
                      )
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
  );
}


  // HEADER
  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLogged) {
          return Row(
            children: [
             
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRouter.other);
                },
                child: state.user.googleLogoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: state.user.googleLogoUrl!,
                        imageBuilder: (context, image) => CircleAvatar(
                          radius: 24,
                          backgroundImage: image,
                          backgroundColor: Colors.transparent,
                        ),
                        errorWidget: (context, url, error) => const CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage(kUserAvatar),
                          backgroundColor: Colors.transparent,
                        ),
                      )
                    : state.user.image != null
                        ? CachedNetworkImage(
                            imageUrl: state.user.image!,
                            imageBuilder: (context, image) => CircleAvatar(
                              radius: 24,
                              backgroundImage: image,
                              backgroundColor: Colors.transparent,
                            ),
                            errorWidget: (context, url, error) => const CircleAvatar(
                              radius: 24,
                              backgroundImage: AssetImage(kUserAvatar),
                              backgroundColor: Colors.transparent,
                            ),
                          )
                        : const CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage(kUserAvatar),
                            backgroundColor: Colors.transparent,
                          ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome,',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Walvero Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(AppRouter.signIn);
              },
              child: const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(kUserAvatar),
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        );
      },
    );
  }

  // CONTENT – artıq Card yoxdur, sadəcə sadə mobil form
  Widget _buildContent({
    required BuildContext context,
    required ProgramUiConfig? config,
    required bool isTierBased,
    required bool isProgressBased,
    required bool showBalance,
    required LookupCard? customer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlıq + Program badge
        Row(
          children: [
            const Expanded(
              child: Text(
                'QR / Kod ilə xal tətbiqi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (config != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  config.programName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.teal.shade800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),

        // CODE
        const Text(
          'Kod (Barcode / QR)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Skan edin və ya yazın…',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFF0ea5e9), width: 1.4),
                  ),
                ),
                onSubmitted: (_) => _lookupByCode(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 50,
              width: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor:  Colors.teal[300],
                ),
                onPressed: _onScanPressed,
                child: const Icon(Icons.qr_code_scanner, size: 26),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Skanerdən gələn mətn bu xana düşür. Enter və ya skan sonrası məlumatlar yüklənir.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),

        // "Əməliyyat tipi" bölməsi - yalnız templateType != 1 olduqda göstərilir
        if (!isProgressBased) ...[
          Text(
            'Əməliyyat tipi',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              ChoiceChip(
                selectedColor: Colors.teal,
                backgroundColor: Colors.grey.shade200,
                label: const Text('Qazan'),
                selected: _mode == RedeemMode.earn,
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _mode = RedeemMode.earn;
                    _adjustDeltaForMode(
                      maxBalance: customer?.currentPoints,
                    );
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                selectedColor: Colors.teal,
                backgroundColor: Colors.grey.shade200,
                label: const Text('Ödə'),
                selected: _mode == RedeemMode.pay,
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _mode = RedeemMode.pay;
                    _adjustDeltaForMode(
                      maxBalance: customer?.currentPoints,
                    );
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // ProgressBased kart üçün Free Reward məlumatı (templateType == 1)
        if (isProgressBased && customer != null && customer.isProgressBased) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${customer.completedCycles ?? 0} ${customer.freeRewardLabel ?? "Pulsuz İçki"}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mövcuddur',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.card_giftcard,
                  color: Colors.green.shade700,
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ProgressBased kart üçün Redeem Type seçimi
          const Text(
            'Redeem Seçimi',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              ChoiceChip(
                selectedColor: Colors.teal,
                backgroundColor: Colors.grey.shade200,
                label: const Text('Bonus Artır'),
                selected: _redeemType == RedeemType.points,
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _redeemType = RedeemType.points;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                selectedColor: Colors.teal,
                backgroundColor: Colors.grey.shade200,
                label: Text(
                  'Bonusdan İstifadə',
                ),
                selected: _redeemType == RedeemType.freeReward,
                onSelected: (selected) {
                  if (!selected) return;
                  if (customer.completedCycles == null || customer.completedCycles! <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mövcud mükafat yoxdur'),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _redeemType = RedeemType.freeReward;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Free Reward Xərcləmə sayı (yalnız ProgressBased və freeReward seçildikdə)
        if (customer != null && 
            customer.isProgressBased && 
            _redeemType == RedeemType.freeReward) ...[
          const Text(
            'Xərcləmə sayı',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _spendCountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 15),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'\d*')),
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      borderSide:
                          BorderSide(color: Color(0xFF0ea5e9), width: 1.4),
                    ),
                  ),
                  onChanged: (value) {
                    final count = int.tryParse(value) ?? 0;
                    if (customer.maxSpendCount != null && count > customer.maxSpendCount!) {
                      _spendCountController.text = customer.maxSpendCount.toString();
                    }
                  },
                ),
              ),
              if (customer.maxSpendCount != null) ...[
                const SizedBox(width: 8),
                Text(
                  '/ ${customer.maxSpendCount}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Maksimum ${customer.maxSpendCount ?? 0} mükafat xərcləyə bilərsiniz.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 18),
        ],

        // DELTA (yalnız points redeem və ya non-ProgressBased kartlar üçün)
        if (customer == null || 
            !customer.isProgressBased || 
            _redeemType == RedeemType.points) ...[
          const Text(
            'Məbləğ (delta / xal)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _deltaController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 15),
                  inputFormatters: [
                    // rəqəm + optional minus işarəsi
                    FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
                  ],
                  decoration: InputDecoration(
                    filled: true,
                
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                     
                      borderSide:
                          BorderSide(color: Color(0xFF0ea5e9), width: 1.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Müsbət və ya mənfi dəyər verə bilərsiniz (məs: -1).',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 18),
        ],
           // 🔹 Qazan / Ödə seçimi
      

        // 🔹 Nağd / Kartla seçimi
      //   Text(
      //     'Ödəniş tipi',
      //     style: const TextStyle(
      //       fontWeight: FontWeight.w600,
      //       fontSize: 14,
      //     ),
      //   ),
      //   const SizedBox(height: 6),
      //   Row(
      //     children: [
      //       ChoiceChip(
      //          selectedColor: Colors.redAccent,
      // backgroundColor: Colors.grey.shade200,
      //         label: const Text('Nağd'),
      //         selected: _paymentMethod == PaymentMethod.cash,
      //         onSelected: (selected) {
      //           if (!selected) return;
      //           setState(() {
      //             _paymentMethod = PaymentMethod.cash;
      //           });
      //         },
      //       ),
      //       const SizedBox(width: 8),
      //       ChoiceChip(
      //          selectedColor: Colors.redAccent,
      // backgroundColor: Colors.grey.shade200,
      //         label: const Text('Kartla'),
      //         selected: _paymentMethod == PaymentMethod.card,
      //         onSelected: (selected) {
      //           if (!selected) return;
      //           setState(() {
      //             _paymentMethod = PaymentMethod.card;
      //           });
      //         },
      //       ),
      //     ],
      //   ),
      //   const SizedBox(height: 18),
        // // ORDER ID
        // const Text(
        //   'Order Number',
        //   style: TextStyle(
        //     fontWeight: FontWeight.w600,
        //     fontSize: 14,
        //   ),
        // ),
        // const SizedBox(height: 6),
        // TextField(
        //   controller: _orderIdController,
        //   style: const TextStyle(fontSize: 15),
        //   decoration: InputDecoration(
        //     hintText: 'Sifariş nömrəsini yazın',
        //     hintStyle: TextStyle(
        //       fontSize: 14,
        //       color: Colors.grey.shade500,
        //     ),
        //     prefixIcon: const Icon(Icons.receipt_long_outlined),
        //     filled: true,
        //     fillColor: Colors.white,
        //     contentPadding: const EdgeInsets.symmetric(
        //       horizontal: 12,
        //       vertical: 14,
        //     ),
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(16),
        //       borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        //     ),
        //     enabledBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(16),
        //       borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        //     ),
        //     focusedBorder: const OutlineInputBorder(
        //       borderRadius: BorderRadius.all(Radius.circular(16)),
        //       borderSide: BorderSide(color: Color(0xFF0ea5e9), width: 1.4),
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 24),

        // TƏTBİQ ET – full width, tək sətir
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _onApplyPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: _isSubmitting 
                  ? Colors.grey[400] 
                  : Colors.teal[500],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: _isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Yüklənir...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Tətbiq et',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),

        // Təmizlə – kiçik text button
        Center(
          child: TextButton(
            onPressed: _clearAll,
            child: const Text(
              'Təmizlə',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6D46F4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
         if (customer != null) ...[
        const SizedBox(height: 24),
        _CustomerInfoCard(
          customer: customer,
          isTierBased: isTierBased,
          showBalance: showBalance,
        ),
      ],
    ],
    );
  }

}
class _CustomerInfoCard extends StatelessWidget {
  final LookupCard customer;
  final bool isTierBased;
  final bool showBalance;

  const _CustomerInfoCard({
    required this.customer,
    required this.isTierBased,
    required this.showBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ad + Kart nömrəsi
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF0ea5e9),
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.customerFullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.cardNumber,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Xal / balans
          if (showBalance) ...[
            Row(
              children: [
                const Icon(Icons.money, size: 18, color: Color(0xFFf59e0b)),
                const SizedBox(width: 6),
                Text(
                  'Hesab Məlumatı:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${customer.currentPoints} ${customer.currency ?? 'AZN'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // ProgressBased kart üçün Free Reward məlumatı
          if (customer.isProgressBased && customer.completedCycles != null) ...[
            if (showBalance) const Divider(height: 18),
            Row(
              children: [
                const Icon(Icons.card_giftcard, size: 18, color: Color(0xFF10b981)),
                const SizedBox(width: 6),
                Text(
                  'Pulsuz Mükafat:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${customer.completedCycles!} ${customer.freeRewardLabel ?? "Pulsuz içki"}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10b981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Əgər tier-baseddirsə, tier məlumatı
          if (isTierBased) ...[
            const Divider(height: 18),
            Row(
              children: [
                if (customer.tierIconUrl != null &&
                    customer.tierIconUrl!.isNotEmpty)
                  CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        NetworkImage(customer.tierIconUrl!),
                    backgroundColor: Colors.transparent,
                  )
                else
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF6D46F4),
                    child: Icon(Icons.workspace_premium,
                        size: 18, color: Colors.white),
                  ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.tierName ?? 'Tier yoxdur',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kart:${customer.tierPercent}% Nağd:${customer.tierPercentCash}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

