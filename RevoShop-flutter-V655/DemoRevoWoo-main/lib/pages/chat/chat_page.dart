import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyoba/models/chat_detail_model.dart';
import 'package:nyoba/pages/chat/detail_image_page.dart';
import 'package:nyoba/pages/chat/image_send_page.dart';
import 'package:nyoba/pages/order/order_detail_screen.dart';
import 'package:nyoba/pages/product/product_detail_screen.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/chat_provider.dart';
import 'package:nyoba/utils/currency_format.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController? _scrollController = ScrollController();
  final text = TextEditingController();
  final picker = ImagePicker();
  File? _image;
  ChatProvider? chatProvider;
  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchDetailChat();
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print("MASUKKK ${_scrollController!.hasClients}");
      if (_scrollController!.hasClients) {
        Timer(Duration(milliseconds: 500), () {
          _scrollController!.animateTo(
              _scrollController!.position.maxScrollExtent * 2.5,
              duration: Duration(milliseconds: 1000),
              curve: Curves.easeInOut);
        });
      }
    });
  }

  fetchDetailChat() async {
    await context
        .read<ChatProvider>()
        .fetchDetailChat()
        .then((value) => scrollToBottom());
  }

  void insertChat({String? message, String? image}) async {
    await context
        .read<ChatProvider>()
        .sendChat(message: message, type: "chat", image: image)
        .then((value) async {
      await context
          .read<ChatProvider>()
          .fetchDetailChat()
          .then((value) => scrollToBottom());
    });
  }

  @override
  void dispose() {
    _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = context.select((ChatProvider n) => n.listDetailChat);
    final loadingChat = context.select((ChatProvider n) => n.loadingDetailChat);
    return Scaffold(
      appBar: _buildAppBar(),
      body: chatProvider!.loadingDetailChat
          ? customLoading()
          : Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 60),
                  physics: ScrollPhysics(),
                  controller: _scrollController,
                  child: Container(
                    margin: EdgeInsets.only(right: 10, left: 10, bottom: 10),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        _buildList(chats: list, isLoading: loadingChat),
                      ],
                    ),
                  ),
                ),
                _buildBottomSection(false)
              ]),
            ),
    );
  }

  Widget _buildList({List<ChatDetailModel?>? chats, required bool isLoading}) {
    return isLoading
        ? customLoading()
        : Container(
            margin: EdgeInsets.only(top: 10),
            child: ListView.builder(
              itemCount: chats!.length,
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemBuilder: (_, index) {
                return Column(
                  children: [
                    Container(
                      child: Text(
                        chats[index]!.date!,
                        style:
                            TextStyle(fontSize: 14, color: HexColor("c8c8c8")),
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: chats[index]!.chatDetail!.length,
                        itemBuilder: (_, j) {
                          return _buildCardChat(chats[index]!.chatDetail![j]);
                        })
                  ],
                );
              },
            ),
          );
  }

  _buildCardChat(ChatModel chat) {
    return Container(
      child: Column(
        children: [
          chat.subject != null ? _buildCardOrder(chat) : Container(),
          chat.image == null
              ? Row(
                  mainAxisAlignment: chat.potition == "left"
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 250),
                        alignment: chat.potition == "left"
                            ? Alignment.topLeft
                            : Alignment.topRight,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: chat.potition == "right"
                              ? Border.all(width: 1, color: HexColor("808080"))
                              : Border.all(width: 0),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                            topLeft: chat.potition == "left"
                                ? Radius.circular(0)
                                : Radius.circular(10),
                            topRight: chat.potition == "right"
                                ? Radius.circular(0)
                                : Radius.circular(10),
                          ),
                          color: chat.potition == "left"
                              ? secondaryColor
                              : Colors.white,
                        ),
                        child: Column(
                            crossAxisAlignment: chat.potition == "left"
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              Text(
                                chat.message!,
                                textAlign: chat.potition == "left"
                                    ? TextAlign.left
                                    : TextAlign.right,
                                style: TextStyle(
                                    color: chat.potition == "left"
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14),
                              ),
                              Text(
                                chat.time!,
                                textAlign: chat.potition == "left"
                                    ? TextAlign.right
                                    : TextAlign.end,
                                style: TextStyle(
                                    color: chat.potition == "left"
                                        ? HexColor("c8c8c8")
                                        : HexColor("c8c8c8"),
                                    fontSize: 11),
                              )
                            ]),
                      ),
                    ])
              : GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return DetailScreen(
                        image: chat.image,
                      );
                    }));
                  },
                  child: Row(
                      mainAxisAlignment: chat.potition == "left"
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: 250),
                          alignment: chat.potition == "left"
                              ? Alignment.topLeft
                              : Alignment.topRight,
                          padding: const EdgeInsets.only(
                              bottom: 5, top: 8, left: 8, right: 8),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            border: chat.potition == "right"
                                ? Border.all(
                                    width: 1, color: HexColor("808080"))
                                : Border.all(width: 0),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                              topLeft: chat.potition == "left"
                                  ? Radius.circular(0)
                                  : Radius.circular(10),
                              topRight: chat.potition == "right"
                                  ? Radius.circular(0)
                                  : Radius.circular(10),
                            ),
                            color: chat.potition == "left"
                                ? secondaryColor
                                : Colors.white,
                          ),
                          child: Column(
                              crossAxisAlignment: chat.potition == "left"
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Container(
                                  child: CachedNetworkImage(
                                    imageUrl: chat.image!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        customLoading(),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.image_not_supported_rounded,
                                      size: 25,
                                    ),
                                  ),
                                ),
                                Text(
                                  chat.time!,
                                  textAlign: chat.potition == "left"
                                      ? TextAlign.right
                                      : TextAlign.end,
                                  style: TextStyle(
                                      color: chat.potition == "left"
                                          ? Colors.white
                                          : HexColor("c8c8c8"),
                                      fontSize: 11),
                                )
                              ]),
                        ),
                      ]),
                )
        ],
      ),
    );
  }

  _buildCardOrder(ChatModel chat) {
    String name = "";
    if (chat.subject!.status != "Product") {
      name = chat.subject!.name!;
    } else if (chat.subject!.name!.length > 11) {
      name = chat.subject!.name!.substring(0, 11) + "...";
    } else if (chat.subject!.name!.length <= 11) {
      name = chat.subject!.name!;
    }
    return chat.subject == null
        ? Container()
        : GestureDetector(
            onTap: () async {
              if (chat.subject!.status!.toLowerCase() == "product") {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProductDetail(productId: chat.postId)));
              } else {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetail(orderId: chat.postId),
                    ));
              }
            },
            child: Row(
                mainAxisAlignment: chat.potition == "left"
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 250),
                    alignment: chat.potition == "left"
                        ? Alignment.topLeft
                        : Alignment.topRight,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 2, color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1, color: HexColor("c8c8c8")),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Image.network(
                              chat.subject!.imageFirst!,
                              height: 50,
                              width: 50,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(chat.subject!.status!),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    child: Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    "${stringToCurrency(double.parse(chat.subject!.price!), context)}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ]),
                          ),
                        ]),
                  ),
                ]),
          );
  }

  _buildAppBar() {
    return AppBar(
      title: Text(
        "Live Chat",
        // style: TextStyle(color: Colors.black),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          // color: Colors.black
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      // backgroundColor: Colors.white,
    );
  }

  Future<ChatImage?> uploadImage(File file) async {
    List<int> imageBytes = file.readAsBytesSync();
    ChatImage? result;
    String base64Image = base64Encode(imageBytes);
    await Provider.of<ChatProvider>(context, listen: false)
        .uploadImage(title: "${"image".toLowerCase()}.jpg", media: base64Image)
        .then((value) {
      result = value;
      return result;
    });
    return result;
  }

  Future getImageFromGallery() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return customLoading();
        });
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      uploadImage(_image!).then((value) {
        print(value);
        if (value != null) {
          Navigator.pop(context);
          printLog(value.toString());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageSend(image: _image, urlImage: value),
            ),
          ).then(getBackProsesKirim);
        } else {
          Navigator.pop(context);
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  getBackProsesKirim(dynamic value) {
    context
        .read<ChatProvider>()
        .fetchDetailChat()
        .then((value) => scrollToBottom());
  }

  Future getImageFromCamera() async {
    try {
      print("Picking Image");
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
      if (pickedFile == null) return;
      final imageTemporary = File(pickedFile.path);
      setState(() {
        _image = imageTemporary;
      });
      print("Image Picked");

      if (_image != null) {
        print("Sending Image");
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return customLoading();
            });

        await uploadImage(_image!).then((value) {
          if (value != null) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageSend(
                  image: _image,
                  urlImage: value,
                ),
              ),
            ).then(getBackProsesKirim);
          } else {
            Navigator.pop(context);
          }
        });
      } else {
        Navigator.pop(context);
      }
    } catch (error) {
      printLog("error: $error");
    }
  }

  void _detailModalBottomSheet(context) {
    showModalBottomSheet(
      // backgroundColor: Colors.white,
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              child: Wrap(
                children: <Widget>[
                  Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 15, left: 20, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 100),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 30, horizontal: 60),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        getImageFromGallery();
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.image,
                                            size: 30,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Text(
                                              "Image Gallery",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        getImageFromCamera();
                                      },
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            size: 30,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Text(
                                              "Camera",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool sendOrder = false;
  _buildBottomSection(bool loading) {
    final isDarkMode =
        Provider.of<AppNotifier>(context, listen: false).isDarkMode;
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: isDarkMode ? null : Colors.grey[200],
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.grey.withOpacity(0.23),
              offset: Offset(0, 0),
            )
          ],
        ),
        child: Container(
          child: Row(children: [
            !sendOrder
                ? GestureDetector(
                    onTap: () {
                      _detailModalBottomSheet(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Icon(Icons.image, color: secondaryColor),
                    ),
                  )
                : Container(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(5),
                child: TextField(
                  controller: text,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Text Here ...",
                    hintStyle: TextStyle(fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                    contentPadding: const EdgeInsets.fromLTRB(17, 5, 0, 5),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (text.text == "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please write a message first")));
                } else {
                  if (!loading) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      insertChat(message: text.text, image: "");
                      setState(() {
                        sendOrder = false;
                      });
                      text.clear();
                    });
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Icon(Icons.send, color: secondaryColor),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
