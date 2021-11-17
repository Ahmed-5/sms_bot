import 'package:flutter/material.dart';
import 'package:sms_bot/components/ChatBubble.dart';
import 'package:sms_bot/repo/telegram.dart';

class MessagesPage extends StatelessWidget {
  final String contact;
  final List<Telegram> messages;
  const MessagesPage({Key key, this.contact, this.messages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return ChatBubble(
            text:
                "${messages[index].address}:\n${messages[index].body}\n${DateTime.fromMillisecondsSinceEpoch(messages[index].unixDate)}",
            isCurrentUser: messages[index].isCurrentUser,
          );
        },
      ),
    );
  }
}
