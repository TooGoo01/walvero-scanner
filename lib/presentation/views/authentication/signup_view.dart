import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constant/app_sizes.dart';
import '../../../core/constant/images.dart';
import '../../../core/constant/validators.dart';
import '../../../core/error/failures.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/usecases/user/sign_up_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/user/user_bloc.dart';
import '../../widgets/input_form_button.dart';
import '../../widgets/input_text_form_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        EasyLoading.dismiss();
        if (state is UserLoading) {
          EasyLoading.show(status: l.loading);
        } else if (state is UserLogged) {

          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.home,
            (Route<dynamic> route) => false,
          );
        } else if (state is UserLoggedFail) {
          String errorMessage = l.error;
          if (state.failure is CredentialFailure) {
            errorMessage = l.invalidCredentials;
          } else if (state.failure is NetworkFailure) {
            errorMessage = l.noInternet;
          }
          EasyLoading.showError(errorMessage);
        }
      },
      child: Scaffold(
          body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPaddingMedium),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                      height: 80,
                      child: Image.asset(
                        kAppLogo,
                        color: Colors.black,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    l.signUpSubtitle,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  InputTextFormField(
                    controller: _firstNameController,
                    hint: l.firstName,
                    textInputAction: TextInputAction.next,
                    validation: (String? val) =>
                        Validators.validateField(val, l.firstName),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  InputTextFormField(
                    controller: _lastNameController,
                    hint: l.lastName,
                    textInputAction: TextInputAction.next,
                    validation: (String? val) =>
                        Validators.validateField(val, l.lastName),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  InputTextFormField(
                    controller: _emailController,
                    hint: l.email,
                    textInputAction: TextInputAction.next,
                    validation: (String? val) => Validators.validateEmail(val),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  InputTextFormField(
                    controller: _passwordController,
                    hint: l.password,
                    textInputAction: TextInputAction.next,
                    isSecureField: true,
                    validation: (String? val) =>
                        Validators.validateField(val, l.password),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  InputTextFormField(
                    controller: _confirmPasswordController,
                    hint: l.password,
                    isSecureField: true,
                    textInputAction: TextInputAction.go,
                    validation: (String? val) =>
                        Validators.validatePasswordMatch(
                      val,
                      _passwordController.text,
                    ),
                    onFieldSubmitted: (_) => _onSignUp(context),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  InputFormButton(
                    color: Colors.black87,
                    onClick: () => _onSignUp(context),
                    titleText: l.signUp,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InputFormButton(
                    color: Colors.black87,
                    onClick: () {
                      Navigator.of(context).pop();
                    },
                    titleText: l.cancel,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }

  void _onSignUp(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        EasyLoading.showError(l.error);
        return;
      }
      context.read<UserBloc>().add(SignUpUser(SignUpParams(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          )));
    }
  }
}
