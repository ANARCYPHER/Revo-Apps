import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/models/contact_model.dart';
import 'package:nyoba/pages/chat/chat_page.dart';
import 'package:nyoba/provider/chat_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:uiblock/uiblock.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_localizations.dart';
import '../../utils/utility.dart';

class ContactModal extends StatefulWidget {
  final int? idProduct;
  const ContactModal({Key? key, this.idProduct}) : super(key: key);

  @override
  State<ContactModal> createState() => _ContactModalState();
}

class _ContactModalState extends State<ContactModal> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController chatController = new TextEditingController();

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  _launchPhoneURL(String phoneNumber) async {
    String url = 'tel:' + phoneNumber;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchWAURL(String? phoneNumber) async {
    String url = 'https://api.whatsapp.com/send?phone=$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchChat() async {
    _showDialogChat();
  }

  void _showDialogChat() {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext contextdialog) {
        return SimpleDialog(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  Text(
                    "Chat to Admin",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "*After you send your message here, you will be redirect to our live chat",
                    style: TextStyle(fontSize: 12, color: HexColor('9e9e9e')),
                    softWrap: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: chatController,
                    maxLines: 5,
                    maxLength: 200,
                    style: TextStyle(
                      fontSize: responsiveFont(11),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: secondaryColor),
                            borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: new BorderSide(color: secondaryColor),
                            borderRadius: BorderRadius.circular(10)),
                        hintText: "Type your message here ...",
                        hintStyle: TextStyle(
                            fontSize: responsiveFont(11),
                            color: HexColor('9e9e9e')),
                        counterText: ''),
                    textInputAction: TextInputAction.done,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: secondaryColor),
                              borderRadius: BorderRadius.circular(5.0)),
                          elevation: 0,
                          height: 40,
                          color: secondaryColor,
                          onPressed: () async {
                            Navigator.pop(contextdialog, 200);
                          },
                          child: Text(
                            "Send",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == 200) {
        UIBlock.block(context);
        context
            .read<ChatProvider>()
            .sendChat(
                message: chatController.text,
                type: "product",
                postId: widget.idProduct)
            .then((data) {
          printLog("data : $data");
          if (data["status"] == "success") {
            UIBlock.unblock(context);

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(),
                ));
          } else {
            UIBlock.unblock(context);
            Navigator.pop(context);
            snackBar(context, message: "Failed to send message!");
          }
        });

        chatController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contacts = Provider.of<HomeProvider>(listen: false, context).contacts;
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 10.0,
          spacing: 10.0,
          children: [
            Container(
                padding: EdgeInsets.all(15),
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: ScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 4 / 0.8,
                  ),
                  itemCount: contacts!.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (contacts[index].id! == "phone") {
                      contacts[index].title =
                          AppLocalizations.of(context)!.translate('call')!;
                    } else if (contacts[index].id == "sms") {
                      contacts[index].title =
                          AppLocalizations.of(context)!.translate('sms')!;
                    }
                    return tag(contacts[index]);
                  },
                )),
          ]);
    });
  }

  Widget tag(ContactModel contact) {
    return InkWell(
      onTap: () async {
        if (contact.id == 'wa') {
          await _launchWAURL(contact.url);
        }
        if (contact.id == 'phone') {
          _launchPhoneURL(contact.url!);
        }
        if (contact.id == 'sms') {
          _sendSMS('', [contact.url!]);
        }
        if (contact.id == "chat") {
          _launchChat();
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: secondaryColor)),
        child: Text(
          contact.title!,
          style: TextStyle(color: primaryColor),
        ),
      ),
    );
  }
}
