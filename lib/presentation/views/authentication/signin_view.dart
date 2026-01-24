
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:walveroScanner/core/constant/validators.dart';

import '../../../core/constant/images.dart';
import '../../../core/error/failures.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/usecases/user/sign_in_usecase.dart';

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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        EasyLoading.dismiss();
        if (state is UserLoading) {
          EasyLoading.show(status: 'Loading...');
        } else if (state is UserLogged) {
          context.read<NavbarCubit>().update(0);
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.home,
            ModalRoute.withName(''),
          );
        } else if (state is UserLoggedFail) {
          if (state.failure is CredentialFailure) {
            EasyLoading.showError("Username/Password Wrong!");
          } else {
            EasyLoading.showError("Error");
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // default-da da true-dur
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // ekranın minimum hündürlüyü qədər olsun,
                    // daha çoxdursa – scroll eləsin
                    minHeight: constraints.maxHeight,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        SizedBox(
                          height: 80,
                          child: Image.asset(kAppLogo),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Please enter your e-mail address and password to sign-in",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF00574C),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        InputTextFormField(
                          controller: emailController,
                          textInputAction: TextInputAction.next,
                          hint: 'username',
                          validation: (String? val) =>
                              Validators.validateField(val, "username"),
                        ),
                        const SizedBox(height: 12),
                        InputTextFormField(
                          controller: passwordController,
                          textInputAction: TextInputAction.go,
                          hint: 'Password',
                          isSecureField: true,
                          validation: (String? val) =>
                              Validators.validateField(val, "Password"),
                          onFieldSubmitted: (_) => _onSignIn(context),
                        ),
                        const SizedBox(height: 24),
                        InputFormButton(
                          color: const Color(0xFF00574C),
                          onClick: () => _onSignIn(context),
                          titleText: 'Sign In',
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onSignIn(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<UserBloc>().add(
            SignInUser(
              SignInParams(
                username: emailController.text,
                password: passwordController.text,
              ),
            ),
          );
    }
  }
}