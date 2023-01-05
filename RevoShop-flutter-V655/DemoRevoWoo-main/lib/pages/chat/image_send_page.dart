import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyoba/models/chat_detail_model.dart';
import 'package:nyoba/provider/chat_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

class ImageSend extends StatefulWidget {
  final File? image;

  final ChatImage? urlImage;
  const ImageSend({Key? key, this.image, this.urlImage}) : super(key: key);

  @override
  State<ImageSend> createState() => _ImageSendState();
}

class _ImageSendState extends State<ImageSend> {
  void addText() async {
    FocusScope.of(context).unfocus();
    printLog("url image : ${widget.urlImage!.image}");
    Provider.of<ChatProvider>(context, listen: false)
        .sendChat(image: widget.urlImage!.image, message: "", type: "chat")
        .then(
      (value) {
        print(value);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.grey.withOpacity(0.18),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 18,
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              "LIVE CHAT",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.file(
                  widget.image!,
                  width: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.grey.withOpacity(0.23),
                    offset: Offset(0, 0),
                  )
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  addText();
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.all(16),
                  child:
                      Icon(Icons.send, color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
