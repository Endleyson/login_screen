// ignore_for_file: file_names, use_build_context_synchronously

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:login_screen/app_localizations.dart';
import 'package:login_screen/bloc/login_bloc.dart';
import 'package:login_screen/helper_color.dart';
import 'package:login_screen/widget/input_field.dart';

import '../service/router_service.dart';
import '../validator/login_validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with LoginValidator {
  bool _obscurePwd = true;
  bool check = false;
  bool _isRememberPassword = false;
  final _google = Image.asset('assets/images/google.png');
  final _azure = Image.asset('assets/images/microsoftLogo.png');
  late Widget svg;

  @override
  void initState() {
    super.initState();
    BlocProvider.getBloc<LoginBloc>().emptyFilds();
    BlocProvider.getBloc<LoginBloc>().pageState = LoginPageState.auth;
    BlocProvider.getBloc<LoginBloc>().outState.listen((state) async {
      if (state == LoginState.success) {
        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
            context, RouterService.userPage, (r) => false);
      } else if (state == LoginState.fail ||
          state == LoginState.passwordWrong ||
          state == LoginState.loading ||
          state == LoginState.sso ||
          state == LoginState.recoveryPassError ||
          state == LoginState.emailEmpty ||
          state == LoginState.passwordEmpty ||
          state == LoginState.recoveryOK) {
        if (mounted) {
          _displayDialog(state);
        }
      }
    });
  }

  _displayDialog(LoginState state) async {
    double sizeH = MediaQuery.of(context).size.height;

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text(S.of(context)!.translate("atencao")!,
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w700,
                      fontSize: sizeH * 0.03)),
              content: _textAlert(state),
              actions: <Widget>[
                state == LoginState.loading
                    ? Padding(
                        padding: EdgeInsets.only(bottom: sizeH * 0.01),
                        child: Center(
                            child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              StaticClass.primaryColor),
                        )),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          backgroundColor: StaticClass.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(
                            sizeH * 0.025,
                          ))),
                        ),
                        child: Text(
                          'ok',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: sizeH * 0.02),
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, RouterService.loginRoute, (r) => false);

                          BlocProvider.getBloc<LoginBloc>().logout();
                        },
                      )
              ],
            ));
  }

  Widget _textAlert(state) {
    double sizeH = MediaQuery.of(context).size.height;
    String text = "";
    var pageState = BlocProvider.getBloc<LoginBloc>().valuePageState;
    if (state == LoginState.loading && pageState == LoginPageState.forgot) {
      text = "aguarde_processando";
    } else if (state == LoginState.passwordWrong) {
      text = 'usuario_senha_invalido';
    } else if (state == LoginState.sso) {
      text = "erro_sso";
    } else if (state == LoginState.loading) {
      text = "aguarde_carregando";
    } else if (state == LoginState.recoveryPassError) {
      text = "recuperar_senha_solicitacao_erro";
    } else if (state == LoginState.emailEmpty) {
      text = "informe_email_valido";
    } else if (state == LoginState.passwordEmpty) {
      text = "senha_vazia";
    } else if (state == LoginState.recoveryOK) {
      text = "recuperar_senha_solicitacao";
    } else {
      text = "verifique_conexao";
    }

    return Text(S.of(context)!.translate(text)!,
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: "Roboto", fontSize: sizeH * 0.018));
  }

  Widget emailCpfField(BuildContext context, LoginPageState loginPageState) {
    String text = 'Login';
    if (loginPageState == LoginPageState.forgot) {
      text = 'E-mail';
    }
    return InputField(
      keyboardType: TextInputType.emailAddress,
      icon: Icons.search,
      labelText: text,
      obscure: false,
      stream: BlocProvider.getBloc<LoginBloc>().outEmailCpf,
      onChanged: BlocProvider.getBloc<LoginBloc>().changeEmailCpf,
    );
  }

  Widget lembrarSenhaEsqueceuSenha() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        checkbox(
            S.of(context)!.translate('lembrar_senha')!, _isRememberPassword),
        esqueceuSenha()
      ],
    );
  }

  Widget checkbox(String title, bool boolValue) {
    double sizeH = MediaQuery.of(context).size.height;
    double sizeW = MediaQuery.of(context).size.width;
    bool boolValue_ = boolValue;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: ((sizeW * sizeH) / (sizeW + sizeH)) * 0.05,
          height: ((sizeW * sizeH) / (sizeW + sizeH)) * 0.05,
          child: Checkbox(
            activeColor: StaticClass.fontColor,
            checkColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            side: BorderSide(color: StaticClass.fontColor, width: 1.5),
            value: boolValue_,
            onChanged: (bool? value) {
              setState(() {
                _isRememberPassword = value!;
                BlocProvider.getBloc<LoginBloc>()
                    .setRememberPasswordController(value);
              });
            },
          ),
        ),
        const Padding(padding: EdgeInsets.only(right: 05)),
        GestureDetector(
          onTap: () {
            setState(() {
              _isRememberPassword = !_isRememberPassword;
              boolValue_ = _isRememberPassword;
              BlocProvider.getBloc<LoginBloc>()
                  .setRememberPasswordController(boolValue_);
            });
          },
          child: Text(
            title,
            style: TextStyle(
              fontFamily: "Roboto",
              color: StaticClass.fontColor,
              fontSize: sizeH * 0.018,
            ),
          ),
        ),
      ],
    );
  }

  Widget senhaField(BuildContext context) {
    double sizeH = MediaQuery.of(context).size.height;
    return StreamBuilder<String>(
        stream: BlocProvider.getBloc<LoginBloc>().outPassword,
        builder: (context, snapshot) {
          return TextField(
            keyboardType: TextInputType.text,
            obscureText: _obscurePwd,
            onChanged: BlocProvider.getBloc<LoginBloc>().changePassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: StaticClass.buttonLightColor,
              suffixIcon: IconButton(
                onPressed: () {
                  _obscurePwd = !_obscurePwd;
                  setState(() {});
                },
                color: StaticClass.fontColor,
                icon: !_obscurePwd
                    ? Icon(
                        Icons.visibility_outlined,
                        size: sizeH * 0.025,
                      )
                    : Icon(
                        Icons.visibility_off_outlined,
                        size: sizeH * 0.025,
                      ),
              ),
              errorStyle: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: sizeH * 0.02,
                  color: Colors.red[200]),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: StaticClass.fontColor,
                size: sizeH * 0.025,
              ),
              hintText: S.of(context)!.translate('senha')!,
              hintStyle:
                  TextStyle(fontFamily: "Roboto", color: StaticClass.fontColor),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  )),
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  )),
            ),
            style: TextStyle(
              fontFamily: "Roboto",
              color: StaticClass.fontColor,
              fontSize: sizeH * 0.02,
            ),
          );
        });
  }

  Widget esqueceuSenha() {
    double sizeH = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        BlocProvider.getBloc<LoginBloc>().pageState = LoginPageState.forgot;
      },
      child: FittedBox(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              S.of(context)!.translate('esqueceu_senha')!,
              style: TextStyle(
                fontFamily: "Roboto",
                color: StaticClass.fontColor,
                fontSize: sizeH * 0.02,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget acessarButton() {
    double sizeH = MediaQuery.of(context).size.height;
    return StreamBuilder<bool>(
        stream: BlocProvider.getBloc<LoginBloc>().outSubmitValid,
        initialData: false,
        builder: (context, snapshot) {
          return SizedBox(
            height: sizeH * 0.065,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: StaticClass.buttonDarkColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(
                  sizeH * 0.045,
                ))),
              ),
              onPressed: () async {
                if (snapshot.hasData && snapshot.data!) {
                  BlocProvider.getBloc<LoginBloc>().submit(
                      loadPassword: false, withGoogle: false, withAzure: false);
                }
              },
              child: Text(
                S.of(context)!.translate('acessar')!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: sizeH * 0.02,
                ),
              ),
            ),
          );
        });
  }

  Widget googleButton(BuildContext context) {
    double sizeH = MediaQuery.of(context).size.height;
    double sizeW = MediaQuery.of(context).size.width;
    return SizedBox(
        child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(
          sizeH * 0.045,
        ))),
        side: BorderSide(
          color: StaticClass.backGroundLight,
          width: 1,
        ),
      ),
      onPressed: () {
        BlocProvider.getBloc<LoginBloc>()
            .submit(loadPassword: false, withGoogle: true, withAzure: false);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: ((sizeW * sizeH) / (sizeW + sizeH)) * 0.085,
              padding: EdgeInsets.only(right: sizeW * 0.015),
              child: _google),
          Text("Google",
              style: TextStyle(
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w700,
                  color: StaticClass.fontDarkColor,
                  fontSize: sizeH * 0.02)),
        ],
      ),
    ));
  }

  Widget azureButton(BuildContext context) {
    double sizeH = MediaQuery.of(context).size.height;
    double sizeW = MediaQuery.of(context).size.width;
    return SizedBox(
      height: sizeH * 0.065,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(
              sizeH * 0.045,
            ))),
            side: BorderSide(
              color: StaticClass.backGroundLight,
              width: 1,
            ),
          ),
          child: FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: ((sizeW * sizeH) / (sizeW + sizeH)) * 0.085,
                    padding: EdgeInsets.only(right: sizeW * 0.015),
                    child: _azure),
                Text("Microsoft",
                    style: TextStyle(
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.w700,
                        color: StaticClass.fontDarkColor,
                        fontSize: sizeH * 0.02))
              ],
            ),
          ),
          onPressed: () {
            BlocProvider.getBloc<LoginBloc>().submit(
                loadPassword: false, withGoogle: false, withAzure: true);
          }),
    );
  }

  Widget recoveryPassButton(BuildContext context) {
    double sizeH = MediaQuery.of(context).size.height;
    return SizedBox(
        child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: StaticClass.buttonColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(
          sizeH * 0.045,
        ))),
        side: BorderSide(
          color: StaticClass.backGroundLight,
          width: 1,
        ),
      ),
      onPressed: () async {
        var mensagem = '';

        var resetSuccess = await BlocProvider.getBloc<LoginBloc>().resetSenha();
        if (resetSuccess) {
          BlocProvider.getBloc<LoginBloc>().pageState = LoginPageState.auth;
          mensagem = S.of(context)!.translate('recuperar_senha_solicitacao')!;
        } else {
          BlocProvider.getBloc<LoginBloc>().pageState = LoginPageState.forgot;
          mensagem =
              S.of(context)!.translate('recuperar_senha_solicitacao_erro')!;
        }

        final snackBar = SnackBar(
            duration: const Duration(seconds: 10),
            backgroundColor: /* resetSuccess ? */
                StaticClass.secondaryColor /* : Colors.red, */,
            content: Text(
              mensagem,
              style: const TextStyle(color: Colors.white),
            ));
        if (resetSuccess) ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: Text(S.of(context)!.translate('recuperar_senha')!,
          style: TextStyle(
              fontFamily: "Roboto",
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: sizeH * 0.02)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double sizeH = MediaQuery.of(context).size.height;
    double sizeW = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        if (check == false) {
          return false;
        }
        return true;
      },
      child: StreamBuilder<LoginPageState>(
          stream: BlocProvider.getBloc<LoginBloc>().outPageState,
          initialData: LoginPageState.auth,
          builder: (context, snapshot) {
            return Scaffold(
              backgroundColor: Colors.white,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.startTop,
              floatingActionButton: Padding(
                padding: EdgeInsets.fromLTRB(0, sizeH * 0.02, 0, 0),
                child: snapshot.data != LoginPageState.forgot
                    ? Container()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FloatingActionButton(
                            elevation: 0,
                            mini: true,
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                              Radius.circular(sizeH * 0.1),
                            )),
                            onPressed: () {
                              BlocProvider.getBloc<LoginBloc>().pageState =
                                  LoginPageState.auth;
                            },
                            child: Center(
                              child: Icon(Icons.arrow_back_rounded,
                                  size: sizeH * 0.03,
                                  color: StaticClass.primaryColor),
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                  width: sizeW * 0.35,
                                  child: Text(
                                      S
                                          .of(context)!
                                          .translate('esqueci_a_senha')!,
                                      style: TextStyle(
                                          fontFamily: "Roboto",
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                          fontSize: sizeH * 0.022))),
                              SizedBox(
                                width: sizeW * 0.33,
                              )
                            ],
                          ),
                        ],
                      ),
              ),
              body: Container(
                height: double.infinity,
                color: Colors.white,
                child: StreamBuilder<LoginPageState>(
                    stream: BlocProvider.getBloc<LoginBloc>().outPageState,
                    initialData: LoginPageState.auth,
                    builder: (context, snapshot) {
                      return SingleChildScrollView(
                          child: Center(
                        child: SizedBox(
                          height: sizeH,
                          child: snapshot.data == LoginPageState.auth
                              ? login_(
                                  acessarButton: acessarButton(),
                                  context: context,
                                  emailCpfField:
                                      emailCpfField(context, snapshot.data!),
                                  senhaField: senhaField(context),
                                  googleButton: googleButton(context),
                                  esqueceuSenha: lembrarSenhaEsqueceuSenha(),
                                  azureButton: azureButton(context))
                              : recoveryPassword(
                                  context: context,
                                  recoveryPassButton:
                                      recoveryPassButton(context),
                                  emailCpfField:
                                      emailCpfField(context, snapshot.data!),
                                ),
                        ),
                      ));
                    }),
              ),
            );
          }),
    );
  }

  Widget recoveryPassword({
    required BuildContext context,
    required Widget emailCpfField,
    required Widget recoveryPassButton,
  }) {
    double sizeH = MediaQuery.of(context).size.height;
    double sizeW = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: sizeH * 0.35,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(top: sizeH * 0.075, right: sizeH * 0.015),
                  child: Align(
                      alignment: AlignmentDirectional.topCenter,
                      child: Container()),
                ),
                SizedBox(
                  height: sizeH * 0.080,
                  width: sizeW * 0.85,
                  child: Text(S.of(context)!.translate('msg_esqueci_page')!,
                      style: TextStyle(
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontSize: sizeH * 0.02)),
                ),
                SizedBox(
                  height: sizeH * 0.065,
                  width: sizeW * 0.85,
                  child: emailCpfField,
                ),
              ]),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: sizeH * 0.05),
          child: SizedBox(
              height: sizeH * 0.065,
              width: sizeW * 0.85,
              child: recoveryPassButton),
        ),
      ],
    );
  }

  Widget login_(
      {required BuildContext context,
      required Widget emailCpfField,
      required Widget senhaField,
      required Widget esqueceuSenha,
      required Widget acessarButton,
      required Widget googleButton,
      required Widget azureButton}) {
    double sizeH = MediaQuery.of(context).size.height;
    double sizeW = MediaQuery.of(context).size.width;
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // sizeHdBox(
          //   height: sizeH / 5,
          //   width: sizeW / 1.8,
          //   child: Center(
          //     child: Text(
          //       S.of(context)!.translate("sua_logo")!,
          //       textAlign: TextAlign.center,
          //       style: TextStyle(
          //           fontFamily: "Roboto",
          //           color: StaticClass.fontDarkColor,
          //           fontSize: sizeH * 0.025,
          //           fontWeight: FontWeight.w700),
          //     ),
          //   ),
          // ),

          Padding(
            padding: EdgeInsets.only(top: sizeH * 0.1),
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: StaticClass.fontColor, width: sizeH * 0.002)),
              height: sizeH / 5,
              width: sizeW,
              child: CircleAvatar(
                backgroundColor: StaticClass.buttonLightColor,
                child: Icon(Icons.person_outline,
                    color: StaticClass.fontColor.withOpacity(0.6),
                    size: sizeH * 0.15),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: sizeH * 0.065,
                width: sizeW * 0.85,
                child: emailCpfField,
              ),
              SizedBox(height: sizeH * 0.02),
              SizedBox(
                  height: sizeH * 0.065,
                  width: sizeW * 0.85,
                  child: senhaField),
              SizedBox(height: sizeH * 0.01),
              SizedBox(
                height: sizeH * 0.025,
                width: sizeW * 0.8,
                child: esqueceuSenha,
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: sizeH * 0.15),
            child: Column(
              children: [
                SizedBox(
                    height: sizeH * 0.065,
                    width: sizeW * 0.85,
                    child: acessarButton),
                SizedBox(height: sizeH * 0.02),
                SizedBox(
                    height: sizeH * 0.065,
                    width: sizeW * 0.85,
                    child: googleButton),
                SizedBox(height: sizeH * 0.02),
                SizedBox(
                    height: sizeH * 0.065,
                    width: sizeW * 0.85,
                    child: azureButton),
              ],
            ),
          ),
        ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
