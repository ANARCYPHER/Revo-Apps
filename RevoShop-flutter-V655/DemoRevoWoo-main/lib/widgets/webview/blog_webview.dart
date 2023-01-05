import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nyoba/models/blog_model.dart';
import 'package:nyoba/provider/blog_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app_localizations.dart';

class BlogWebView extends StatefulWidget {
  final url;
  final String? id;
  final String? slug;

  BlogWebView({Key? key, this.url, this.slug, this.id}) : super(key: key);
  @override
  BlogWebViewState createState() => BlogWebViewState();
}

class BlogWebViewState extends State<BlogWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  late WebViewController _webViewController;
  bool isLoading = true;
  bool isLoadingData = true;

  TextEditingController commentController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  BlogModel? blogModel;

  @override
  void initState() {
    super.initState();
    loadDetail();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  loadDetail() async {
    if (widget.slug == null) {
      await Provider.of<BlogProvider>(context, listen: false)
          .fetchBlogDetailById(widget.id)
          .then((value) {
        setState(() {
          blogModel = value;
          isLoadingData = false;
        });
        loadComment(blogModel!.id);
      });
    } else {
      await Provider.of<BlogProvider>(context, listen: false)
          .fetchBlogDetailBySlug(widget.slug)
          .then((value) {
        setState(() {
          blogModel = value;
          isLoadingData = false;
        });
        loadComment(blogModel!.id);
      });
    }
  }

  loadComment(postId) async {
    await Provider.of<BlogProvider>(context, listen: false)
        .fetchBlogComment(postId, true);
  }

  @override
  Widget build(BuildContext context) {
    final blog = Provider.of<BlogProvider>(context, listen: false);

    Widget buildComments = ListenableProvider.value(
      value: blog,
      child: Consumer<BlogProvider>(builder: (context, value, child) {
        if (value.loadingComment) {
          return customLoading();
        }
        return blog.blogComment.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "${blog.blogComment.length} ${AppLocalizations.of(context)!.translate('comments')} :",
                      style: TextStyle(fontSize: responsiveFont(12)),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  ListView.separated(
                      primary: false,
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 15,
                        );
                      },
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: blog.blogComment.length,
                      itemBuilder: (context, i) {
                        return comment(blog.blogComment[i]);
                      }),
                ],
              )
            : Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: primaryColor,
                    ),
                    Text(AppLocalizations.of(context)!
                        .translate('comment_empty')!)
                  ],
                ),
              );
      }),
    );

    var postComment = () async {
      if (commentController.text.isNotEmpty) {
        print('Start Commenting...');
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        final Future<Map<String, dynamic>?> postResponse =
            blog.postComment(blogModel!.id, comment: commentController.text);

        postResponse.then((value) {
          commentController.clear();
          if (value!['data']['status'] == 200) {
            // UserModel user = UserModel.fromJson(value['user']);
            _scrollController
                .jumpTo(_scrollController.position.minScrollExtent);
            loadComment(blogModel!.id);
          } else {
            snackBar(context, message: value['message'], color: Colors.red);
          }
        });
      } else {
        snackBar(context, message: 'Username & password should not empty');
      }
    };

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.translate('blog')!,
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
            icon: Platform.isIOS
                ? Icon(Icons.arrow_back_ios)
                : Icon(Icons.arrow_back),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: WebView(
                    initialUrl: widget.url,
                    javascriptMode: JavascriptMode.unrestricted,
                    onProgress: (int progress) {
                      print("WebView is loading (progress : $progress%)");
                      _webViewController.runJavascript(
                          "document.getElementById('headerwrap').style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementById('footerwrap').style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByTagName('header')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByTagName('footer')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('return-to-shop')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('page-title')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('woocommerce-error')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('woocommerce-breadcrumb')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('useful-links')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('widget woocommerce widget_product_search')[1].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('woocommerce-breadcrumb')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('comments-area')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('cat-links')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('nav-links')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('wws-popup-container wws-popup-container--position')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('tawk-min-container')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementById('hhponm6cl17o1643852772637')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementById('wws-layout-1')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('wws-popup__footer')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('post-author-info')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('tawk-custom-color tawk-custom-border-color tawk-button tawk-button-circle tawk-button-large')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('tawk-button')[0].style.display= 'none';");
                    },
                    onWebViewCreated: (WebViewController webViewController) {
                      _webViewController = webViewController;
                      _controller.complete(webViewController);
                    },
                    onPageStarted: (String url) {
                      print('Page started loading: $url');
                    },
                    onPageFinished: (String url) {
                      print('Page finished loading: $url');
                      setState(() {
                        isLoading = false;
                      });
                      _webViewController.runJavascript(
                          "document.getElementById('headerwrap').style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementById('footerwrap').style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByTagName('header')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByTagName('footer')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('return-to-shop')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('page-title')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('woocommerce-error')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('woocommerce-breadcrumb')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('useful-links')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('widget woocommerce widget_product_search')[1].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('comments-area')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('cat-links')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('nav-links')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('wws-popup-container wws-popup-container--position')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('tawk-min-container')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementById('hhponm6cl17o1643852772637')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementById('wws-layout-1')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('wws-popup__footer')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('post-author-info')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('tawk-custom-color tawk-custom-border-color tawk-button tawk-button-circle tawk-button-large')[0].style.display= 'none';");
                      _webViewController.runJavascript(
                          "document.getElementsByClassName('tawk-button')[0].style.display= 'none';");
                    },
                    gestureNavigationEnabled: true,
                  ),
                ),
                Visibility(
                    visible: !isLoadingData && !isLoading,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          showMaterialModalBottomSheet(
                            context: context,
                            builder: (context) => SingleChildScrollView(
                              controller: ModalScrollController.of(context),
                              child: buildComment(postComment, buildComments),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: secondaryColor,
                            minimumSize:
                                Size(MediaQuery.of(context).size.width, 40.0),
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 6)),
                        child: Text(
                          AppLocalizations.of(context)!.translate('comment')!,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )),
              ],
            ),
            isLoading
                ? Center(
                    child: customLoading(),
                  )
                : Stack(),
          ],
        ));
  }

  Widget buildComment(postComment, buildComments) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 15),
          color: HexColor("c4c4c4"),
          height: 1,
          width: double.infinity,
        ),
        buildComments,
        SizedBox(
          height: 15,
        ),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Text(
            AppLocalizations.of(context)!.translate('leave_comment')!,
            style: TextStyle(
                fontSize: responsiveFont(12),
                color: secondaryColor,
                fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              TextField(
                  controller: commentController,
                  maxLines: 5,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!
                          .translate('hint_comment'),
                      hintStyle: TextStyle(fontSize: responsiveFont(12)),
                      filled: true)),
              SizedBox(
                height: 15,
              ),
              Visibility(
                visible: Session.data.getBool('isLogin') == null ||
                    !Session.data.getBool('isLogin')!,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: primaryColor,
                      ),
                      Text(AppLocalizations.of(context)!
                          .translate('logged_comment')!)
                    ],
                  ),
                ),
              ),
              Visibility(
                  visible: Session.data.getBool('isLogin') != null &&
                      Session.data.getBool('isLogin')!,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: postComment,
                      style: TextButton.styleFrom(
                          backgroundColor: secondaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 6)),
                      child: Text(
                        AppLocalizations.of(context)!.translate('comment')!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ))
            ],
          ),
        )
      ],
    );
  }

  Widget comment(BlogCommentModel blogComment) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2),
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: HexColor("c4c4c4")),
            ),
            child: ClipOval(child: Image.asset("images/lobby/laptop.png")),
          ),
          Container(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      blogComment.authorName!,
                      style: TextStyle(
                          fontSize: responsiveFont(10),
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      convertDateFormatFull(DateTime.parse(blogComment.date!)),
                      style: TextStyle(
                          fontSize: responsiveFont(10),
                          fontWeight: FontWeight.w400,
                          color: primaryColor),
                    )
                  ],
                ),
                Container(
                  height: 5,
                ),
                HtmlWidget(
                  blogComment.content!,
                  textStyle: TextStyle(fontSize: responsiveFont(8)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget tag(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: secondaryColor)),
      child: Text(
        title,
        style: TextStyle(color: primaryColor),
      ),
    );
  }
}
