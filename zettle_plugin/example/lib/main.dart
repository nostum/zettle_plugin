import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zettle/zettle.dart';

import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zettle/zettle_models.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _zettlePlugin = ZettlePlugin();
  final createPaymentController = TextEditingController();
  final paymentRefInputController = TextEditingController();
  final refundPaymentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // * ============== SDK ACTIONS  HANDLERS ==================  * //
  Future<void> initialize() async {
    final zettleRedirectUrl = dotenv.env["ZETTLE_REDIRECT_URL"];
    final zettleClientID = dotenv.env["ZETTLE_CLIENT_ID"];
    final checkVariables = [zettleRedirectUrl, zettleClientID];
    if (checkVariables.any((val) => val == null)) {
      throw ErrorDescription("REQUIRED ENVIRONMENT VARIABLES NOT FOUND");
    }
    // * -- Init zettle plugin
    await _zettlePlugin.initialize(
        iosClientId: Platform.isIOS ? zettleClientID : null,
        androidClientId: Platform.isAndroid ? zettleClientID : null,
        redirectUrl: zettleRedirectUrl!);
  }

  Future<void> login() async {
    await _zettlePlugin.login();
  }

  Future<void> logout() async {
    await _zettlePlugin.logout();
  }

  Future<void> showSettings() async {
    await _zettlePlugin.showSettings();
  }

  Future<void> createPayment(BuildContext ctx) async {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
                padding: const EdgeInsets.only(top: 30),
                height: 60 * 4,
                child: Column(
                  children: <Widget>[
                    buildTextField(
                      label: "Amount of money:",
                      controller: createPaymentController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black)),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          requestPayment(createPaymentController.text, ctx);
                          createPaymentController.clear();
                        },
                        child: const Text("Create Payment"))
                  ],
                )));
      },
    );
  }

  Future<void> requestPayment(String value, BuildContext ctx) async {
    final val = double.parse(value);
    final reference = const Uuid().v4();
    print("payment reference: $reference");
    final request = ZettlePaymentRequest(amount: val, reference: reference);
    final response = await _zettlePlugin.requestPayment(request);
    if (response.status == ZettlePluginPaymentStatus.completed) {
      if (!mounted) return;
      showPaymentInfo(ctx, response);
    }
  }

  Future<void> showPaymentInfo(
      BuildContext ctx, ZettlePluginPaymentResponse payment) async {
    showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        builder: (context) {
          return Container(
              padding: const EdgeInsetsDirectional.all(20),
              color: CupertinoColors.white,
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).copyWith().size.height * 0.35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CupertinoListTile(
                      title: Text(
                    "Payment Information",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Reference number:",
                    style: textStyleLabels(),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        payment.reference ?? "---",
                        style: textStyleLabels(),
                        overflow: TextOverflow.clip,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      if (payment.reference != null)
                        InkWell(
                          onTap: () {
                            copyToClipboard(payment.reference ?? "", ctx);
                          },
                          child: Icon(
                            Icons.copy,
                            size: 18,
                            color: Colors.blue.shade500,
                          ),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  infoRow("Status:", payment.status.name),
                  const SizedBox(
                    height: 10,
                  ),
                  infoRow("Amount:", "\$${payment.amount.toString()}"),
                  const SizedBox(
                    height: 10,
                  ),
                  infoRow("Card Type:", payment.cardType),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ));
        });
  }

  Future<void> refundPaymentModal(BuildContext ctx) async {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
                padding: const EdgeInsets.only(top: 30),
                height: 60 * 5,
                child: Column(
                  children: <Widget>[
                    buildTextField(
                        label: "Payment Reference:",
                        controller: paymentRefInputController,
                        icon: Icons.numbers),
                    const SizedBox(height: 30),
                    buildTextField(
                        label: "Amount to be returned:",
                        controller: refundPaymentController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black)),
                        onPressed: () {
                          refundPayment(ctx, paymentRefInputController.text,
                              refundPaymentController.text);

                          paymentRefInputController.clear();
                          refundPaymentController.clear();
                        },
                        child: const Text("Request refund payment"))
                  ],
                )));
      },
    );
  }

  Future<void> getPaymentInfo(BuildContext ctx,
      {required Future<void> Function(BuildContext ctx, String reference)
          onSubmit,
      String? buttonText}) async {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
                padding: const EdgeInsets.only(top: 30),
                height: 60 * 4,
                child: Column(
                  children: <Widget>[
                    buildTextField(
                      label: "Payment Reference:",
                      controller: paymentRefInputController,
                      icon: Icons.numbers,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black)),
                        onPressed: () {
                          onSubmit(ctx, paymentRefInputController.text);
                          paymentRefInputController.clear();
                        },
                        child: Text(buttonText ?? "Get payment info"))
                  ],
                )));
      },
    );
  }

  Future<void> retrievePayment(BuildContext ctx, String value) async {
    final response = await _zettlePlugin.retrievePayment(value);
    if (!mounted) return;
    showPaymentInfo(ctx, response);
  }

  Future<void> refundPayment(
      BuildContext ctx, String reference, String refundAmount) async {
    final amount = double.tryParse(refundAmount) ?? 0;

    final request =
        ZettleRefundRequest(reference: reference, refundAmount: amount);
    await _zettlePlugin.requestRefund(request);
  }

  // * ============== SDK BUTTON ACTIONS ==================  * //
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.light(),
        home: Builder(builder: (context) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Zettle Plugin'),
                backgroundColor: Colors.black,
              ),
              body: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Auth",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoButton(
                              onPressed: login, child: const Text("Login")),
                          CupertinoButton(
                              onPressed: logout, child: const Text("Logout")),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Settings",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      CupertinoButton(
                          onPressed: showSettings,
                          child: const Text("Show settings")),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Payments",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      CupertinoButton(
                          onPressed: () => createPayment(context),
                          child: const Text("Create payment")),
                      CupertinoButton(
                          onPressed: () => getPaymentInfo(
                                context,
                                onSubmit: (ctx, reference) async {
                                  retrievePayment(ctx, reference);
                                },
                              ),
                          child: const Text("Retrieve payment")),
                      CupertinoButton(
                          onPressed: () => refundPaymentModal(context),
                          child: const Text("Refund payment")),
                    ],
                  ),
                ),
              ));
        }));
  }

  // * ============== UTIL FUNCTIONS ==================  * //
  Future<void> copyToClipboard(String val, BuildContext ctx) async {
    await Clipboard.setData(ClipboardData(text: val));

    if (!mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
      content: Text('Copiado'),
    ));
  }

  Widget buildTextField(
      {required String label,
      required TextEditingController controller,
      IconData? icon,
      TextInputType? keyboardType}) {
    return Column(children: <Widget>[
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Container(
        constraints: const BoxConstraints(maxWidth: 200),
        child: TextField(
          autofocus: true,
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
              focusColor: Colors.black,
              prefixIconColor: Colors.black,
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)),
              prefixIcon: Icon(icon ?? Icons.attach_money_rounded)),
        ),
      )
    ]);
  }

  TextStyle textStyleLabels() => const TextStyle(
      fontSize: 13,
      color: Colors.black,
      decorationStyle: null,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.normal);

  Row infoRow(String title, String? value, {Widget? valueWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textStyleLabels(),
        ),
        valueWidget ??
            Text(
              value ?? "---",
              style: textStyleLabels(),
            )
      ],
    );
  }
}
