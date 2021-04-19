import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/Provider/auth_repository.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void BottomSheetWidget(BuildContext context,var loginWidgetInst, AuthRepository authRep ){
  showMaterialModalBottomSheet(
      context: context,
      builder: (context) {
        return AnimatedPadding(
          padding: MediaQuery
              .of(context)
              .viewInsets,
          duration: const Duration(milliseconds: 100),
          curve: Curves.decelerate,
          child: SingleChildScrollView(
            child:
            Column(mainAxisSize: MainAxisSize.min, children: [
              Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Please confirm your password below",
                      style: TextStyle(fontSize: 15),
                    ),
                  )),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextFormField(
                  controller: loginWidgetInst.bottomSheetController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (loginWidgetInst.passwordController.text ==
                        loginWidgetInst.bottomSheetController.text &&
                        loginWidgetInst.emailController.text != "") {
                      loginWidgetInst.createUser(authRep, loginWidgetInst.emailController.text,
                          loginWidgetInst.passwordController.text);
                    } else {
                      final snackBar = SnackBar(
                        content: Text('Passwords must match'),
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: Text('Confirm'),
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(
                        Colors.green[700]!),
                    minimumSize: MaterialStateProperty.all<Size>(
                        Size(90, 35)),
                  ),
                ),
              )
            ]),
          ),
        );
      });
}