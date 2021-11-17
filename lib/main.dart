import 'package:flutter/material.dart';
import 'package:sms_bot/components/MessagesPage.dart';
import 'package:sms_bot/repo/telegram.dart';
import 'package:sms_bot/utils/utils.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "";
  final telephony = Telephony.instance;
  List<Telegram> telegrams = [];
  List<Telegram> messages = [];
  List<String> orderedKeys = [];
  Map<String, List<Telegram>> conversations = {};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    Telegram newTele = Telegram(
        body: message.body, address: message.address, isCurrentUser: false);
    setState(() {
      telegrams.add(newTele);
      String text = "body: ${message.body} sender: ${message.address}";
      _message = text ?? "Error reading message body.";
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool result = await telephony.requestPhoneAndSmsPermissions;
    List<SmsMessage> inConverses = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
    );
    int inCounter = 0;

    List<SmsMessage> outConverses = await telephony.getSentSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
    );
    int outCounter = 0;

    print("==========${outConverses.length + inConverses.length}===========");

    List<Telegram> converses = [];
    Map<String, List<Telegram>> newConv = {};
    List<String> newOrderedKeys = [];

    while (inCounter < inConverses.length || outCounter < outConverses.length) {
      if (inCounter < inConverses.length &&
          (outCounter >= outConverses.length ||
              inConverses[inCounter].date > outConverses[outCounter].date)) {
        SmsMessage message = inConverses[inCounter];
        Telegram telegram = Telegram(
          body: message.body,
          address: message.address,
          unixDate: message.date,
          isCurrentUser: false,
        );
        inCounter++;
        converses.add(telegram);
        if (newConv.containsKey(telegram.address)) {
          newConv[telegram.address].add(telegram);
        } else {
          newOrderedKeys.add(telegram.address);
          newConv[telegram.address] = [telegram];
        }
      }

      if (outCounter < outConverses.length &&
          (inCounter >= inConverses.length ||
              outConverses[outCounter].date > inConverses[inCounter].date)) {
        SmsMessage message = outConverses[outCounter];
        outCounter++;
        Telegram telegram = Telegram(
          body: message.body,
          address: message.address,
          unixDate: message.date,
          isCurrentUser: true,
        );
        converses.add(telegram);
        if (newConv.containsKey(telegram.address)) {
          newConv[telegram.address].add(telegram);
        } else {
          newOrderedKeys.add(telegram.address);
          newConv[telegram.address] = [telegram];
        }
      }
    }

    newConv.keys.forEach((key) {
      newConv[key] = newConv[key].reversed.toList();
    });

    setState(() {
      messages = converses;
      conversations = newConv;
      orderedKeys = newOrderedKeys;
    });

    print("++++++++++++++++++++++++++++++++++");
    print("number of messages: ${converses.length}");
    print("++++++++++++++++++++++++++++++++++");

    if (result != null && result) {
      telephony.listenIncomingSms(
        onNewMessage: onMessage,
        onBackgroundMessage: onBackgroundMessage,
      );
    }

    if (!mounted) return;
  }

  final String mkey = "+249930077211";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: orderedKeys.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MessagesPage(
                      contact: orderedKeys[index],
                      messages: conversations[orderedKeys[index]],
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 15,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      CircleAvatar(
                        radius: 25,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(orderedKeys[index]),
                            Text(
                              firstNChars(
                                conversations[orderedKeys[index]].last.body,
                                20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            unixToMonthDay(
                              conversations[orderedKeys[index]].last.unixDate,
                            ),
                          ),
                        ),
                      ),
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
}
