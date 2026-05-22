import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';
import 'package:walveroScanner/core/constant/validators.dart';

import '../../../core/constant/images.dart';
import '../../../core/error/failures.dart';
import '../../../core/router/app_router.dart';
import '../../../data/data_sources/remote/country_remote_data_source.dart';
import '../../../domain/entities/country/country_code.dart';
import '../../../domain/usecases/user/sign_in_usecase.dart';
import '../../../l10n/app_localizations.dart';

import '../../blocs/home/navbar_cubit.dart';

import '../../blocs/user/user_bloc.dart';
import '../../widgets/input_form_button.dart';
import '../../widgets/input_text_form_field.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPhoneMode = false;
  bool _isLoading = false; // local overlay state — EasyLoading race-from-bloc bypass
  List<CountryCode> _countryCodes = [];
  CountryCode? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _fetchCountryCodes();
  }

  Future<void> _fetchCountryCodes() async {
    try {
      final dataSource = CountryRemoteDataSourceImpl(client: http.Client());
      final codes = await dataSource.getCountryCodes();
      if (mounted) {
        setState(() {
          _countryCodes = codes;
          if (codes.isNotEmpty) _selectedCountry = codes.first;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) async {
        final l = AppLocalizations.of(context)!;
        // EasyLoading.show/dismiss race-ini bypass etmək üçün local _isLoading istifadə edirik.
        // Dismiss üçün əlavə olaraq EasyLoading.dismiss-i də çağırırıq (mövcud sessiya
        // kontekstində yan tərəfdən show çağırılıbsa təmizləmək üçün).
        if (state is UserLoading) {
          if (mounted) setState(() => _isLoading = true);
        } else if (state is UserLogged) {
          if (mounted) setState(() => _isLoading = false);
          await EasyLoading.dismiss(animation: false);
          if (context.mounted) {
            context.read<NavbarCubit>().update(0);
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.home,
              ModalRoute.withName(''),
            );
          }
        } else if (state is UserLoggedFail) {
          if (mounted) setState(() => _isLoading = false);
          await EasyLoading.dismiss(animation: false);

          final msg = state.failure is CredentialFailure
              ? l.invalidCredentials
              : state.failure is NetworkFailure
                  ? l.noInternet
                  : l.error;
          showToast(
            msg,
            position: ToastPosition.bottom,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red.shade700,
            textStyle: const TextStyle(color: Colors.white, fontSize: 14),
          );
        } else {
          if (mounted) setState(() => _isLoading = false);
          await EasyLoading.dismiss(animation: false);
        }
      },
      child: Stack(
        children: [
          _buildContent(l),
          if (_isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? constraints.maxWidth * 0.2 : 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: 480,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        // Logo
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00574C).withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 72,
                            child: Image.asset(kAppLogo),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          l.appTitle,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00574C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.loginSubtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Form card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Toggle: Username / Phone
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F7FA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _isPhoneMode = false),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: !_isPhoneMode ? const Color(0xFF00574C) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            l.userName,
                                            style: TextStyle(
                                              color: !_isPhoneMode ? Colors.white : Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _isPhoneMode = true),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: _isPhoneMode ? const Color(0xFF00574C) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            l.phone,
                                            style: TextStyle(
                                              color: _isPhoneMode ? Colors.white : Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (!_isPhoneMode)
                                InputTextFormField(
                                  controller: emailController,
                                  textInputAction: TextInputAction.next,
                                  hint: l.userName,
                                  validation: (String? val) =>
                                      Validators.validateField(val, l.userName),
                                )
                              else
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 110,
                                      child: DropdownButtonFormField<CountryCode>(
                                        value: _selectedCountry,
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          filled: true,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: Colors.transparent, width: 0),
                                          ),
                                        ),
                                        items: _countryCodes.map((c) {
                                          return DropdownMenuItem<CountryCode>(
                                            value: c,
                                            child: Text(
                                              '${c.flag} +${c.countryCode}',
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) => setState(() => _selectedCountry = val),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: InputTextFormField(
                                        controller: _phoneController,
                                        textInputAction: TextInputAction.next,
                                        hint: l.phonePlaceholder,
                                        keyboardType: TextInputType.phone,
                                        validation: (String? val) =>
                                            Validators.validateField(val, l.phonePlaceholder),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 16),
                              InputTextFormField(
                                controller: passwordController,
                                textInputAction: TextInputAction.go,
                                hint: l.password,
                                isSecureField: true,
                                validation: (String? val) =>
                                    Validators.validateField(val, l.password),
                                onFieldSubmitted: (_) => _onSignIn(context),
                              ),
                              const SizedBox(height: 24),
                              InputFormButton(
                                color: const Color(0xFF00574C),
                                onClick: () => _onSignIn(context),
                                titleText: l.loginTitle,
                                cornerRadius: 14,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
    );
  }

  void _onSignIn(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final String username;
      if (_isPhoneMode) {
        if (_selectedCountry == null) return;
        // Backend ApplicationUser.PhoneNumber E.164 ilə saxlanır ('+994...')
        var phone = _phoneController.text.trim();
        if (phone.startsWith('0')) phone = phone.substring(1);
        username = '+${_selectedCountry!.countryCode}$phone';
      } else {
        username = emailController.text;
      }
      context.read<UserBloc>().add(
            SignInUser(
              SignInParams(
                username: username,
                password: passwordController.text,
              ),
            ),
          );
    }
  }
}
