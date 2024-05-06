//// tela basica para um primeiro momento

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:login_screen/bloc/login_bloc.dart';
import 'package:login_screen/helper_color.dart';
import 'package:login_screen/model/authentication.dart';
import 'package:login_screen/service/router_service.dart';
import 'package:shimmer/shimmer.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.getBloc<LoginBloc>().outState.listen((state) async {
      if (state == LoginState.idle) {
        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
            context, RouterService.loginRoute, (r) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double sizeH = MediaQuery.of(context).size.height;
    double sizeW = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: EdgeInsets.fromLTRB(0, sizeH * 0.02, 0, 0),
        child: FloatingActionButton(
          elevation: 0,
          mini: true,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
            Radius.circular(sizeH * 0.1),
          )),
          onPressed: () {
            BlocProvider.getBloc<LoginBloc>().loginState = LoginState.idle;
          },
          child: Center(
            child: Icon(Icons.arrow_back_rounded,
                size: sizeH * 0.03, color: StaticClass.fontColor),
          ),
        ),

        // ),
      ),
      body: Container(
          height: double.infinity,
          color: Colors.white,
          child: SizedBox(
              height: sizeH,
              child: StreamBuilder<Authentication>(
                  stream: BlocProvider.getBloc<LoginBloc>().outAuthentication,
                  initialData: Authentication(userImage: null),
                  builder: (context, snapshot) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: sizeH * 0.05,
                          width: sizeW,
                          child: Text(
                            "Bem vindo",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: StaticClass.fontColor,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w700,
                                fontSize: sizeH * 0.05),
                          ),
                        ),
                        SizedBox(
                          height: sizeH * 0.035,
                          width: sizeW,
                          child: FittedBox(
                            child: Text(
                              snapshot.data!.fullName == null
                                  ? "${snapshot.data!.email}"
                                  : "${snapshot.data!.fullName}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: StaticClass.fontColor,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: StaticClass.fontColor,
                                  width: sizeH * 0.002)),
                          height: sizeH * 0.22,
                          width: sizeW,
                          child: CircleAvatar(
                              backgroundColor:
                                  snapshot.data!.userImage == null ||
                                          snapshot.data!.userImage!.isEmpty
                                      ? StaticClass.buttonLightColor
                                      : Colors.transparent,
                              backgroundImage:
                                  (snapshot.data!.userImage == null ||
                                          snapshot.data!.userImage!.isEmpty)
                                      ? null
                                      : NetworkImage(snapshot.data!.userImage!,
                                          scale: 5),
                              child: snapshot.data!.userImage == null
                                  ? Icon(Icons.person_outline,
                                      color: StaticClass.fontColor
                                          .withOpacity(0.6),
                                      size: sizeH * 0.15)
                                  : snapshot.data!.userImage!.isEmpty
                                      ? Shimmer.fromColors(
                                          baseColor: StaticClass.fontColor
                                              .withOpacity(0.3),
                                          highlightColor: StaticClass.fontColor,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                // color: StaticClass.fontColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color:
                                                        StaticClass.fontColor,
                                                    width: sizeH * 0.005)),
                                            height: sizeH * 0.22,
                                            width: sizeW,
                                          ),
                                        )
                                      : Container()),
                        ),
                        SizedBox(
                          height: sizeH * 0.25,
                          width: sizeW,
                        )
                      ],
                    );
                  }))),
    );
  }
}
