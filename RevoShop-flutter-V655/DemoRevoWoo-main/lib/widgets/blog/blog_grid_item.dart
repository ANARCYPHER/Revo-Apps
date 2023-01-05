import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/models/blog_model.dart';
import 'package:nyoba/provider/blog_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/pages/blog/blog_detail_screen.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';
import '../../provider/home_provider.dart';

class BlogGridItem extends StatefulWidget {
  final BlogModel? blog;
  final int? index;

  BlogGridItem({Key? key, this.blog, this.index}) : super(key: key);

  @override
  _BlogGridItemState createState() => _BlogGridItemState();
}

class _BlogGridItemState extends State<BlogGridItem> {
  TextEditingController commentController = new TextEditingController();
  bool blogCommentFeature = false;

  @override
  void initState() {
    super.initState();
    loadCommentFeature();
    //check provider is list blog empty for first load
  }

  loadCommentFeature() async {
    await Provider.of<HomeProvider>(context, listen: false).fetchBlogComment();
  }

  loadComment(postId) async {
    await Provider.of<BlogProvider>(context, listen: false)
        .fetchBlogComment(postId, true);
  }

  @override
  Widget build(BuildContext context) {
    return
        // GestureDetector(
        //   onTap: () {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => BlogDetail(
        //                   id: widget.blog!.id.toString(),
        //                 )));
        //   },
        //   child: Container(
        //     decoration: BoxDecoration(
        //         color: Colors.white, borderRadius: BorderRadius.circular(5)),
        //     child: Card(
        //       elevation: 3,
        //       margin: EdgeInsets.only(bottom: 1),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Expanded(
        //             flex: 3,
        //             child: Container(
        //               width: double.infinity,
        //               decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(5),
        //                 color: HexColor("c4c4c4"),
        //               ),
        //               child: widget.blog!.blogImages != null
        //                   ? Image.network(
        //                       widget.blog!.blogImages![0].srcImg!,
        //                       fit: BoxFit.cover,
        //                     )
        //                   : Icon(
        //                       Icons.image_not_supported_outlined,
        //                       size: 64,
        //                     ),
        //             ),
        //           ),
        //           Expanded(
        //               flex: 4,
        //               child: Container(
        //                 margin: EdgeInsets.all(5),
        //                 child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       Flexible(
        //                         flex: 2,
        //                         child: Text(
        //                           widget.blog!.title!,
        //                           maxLines: 2,
        //                           overflow: TextOverflow.ellipsis,
        //                           style: TextStyle(fontSize: responsiveFont(10)),
        //                         ),
        //                       ),
        //                       Container(
        //                         height: 5,
        //                       ),
        //                       Row(
        //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                         children: [
        //                           Container(
        //                               padding: EdgeInsets.all(5),
        //                               decoration: BoxDecoration(
        //                                   color: secondaryColor,
        //                                   borderRadius: BorderRadius.circular(2)),
        //                               child: Text(
        //                                 "By : ${widget.blog!.author}",
        //                                 style: TextStyle(
        //                                     fontSize: responsiveFont(6),
        //                                     color: Colors.white),
        //                               )),
        //                           SizedBox(
        //                             width: 5,
        //                           ),
        //                           Expanded(
        //                               child: Text(
        //                             convertDateFormatShortMonth(
        //                                 DateTime.parse(widget.blog!.date!)),
        //                             style: TextStyle(fontSize: responsiveFont(8)),
        //                           ))
        //                         ],
        //                       ),
        //                       SizedBox(
        //                         height: 5,
        //                       ),
        //                       HtmlWidget(
        //                         widget.blog!.excerpt!.length < 90
        //                             ? widget.blog!.excerpt!
        //                             : widget.blog!.excerpt!.substring(0, 90) +
        //                                 '...',
        //                         textStyle: TextStyle(fontSize: responsiveFont(8)),
        //                       ),
        //                       SizedBox(
        //                         height: 5,
        //                       ),
        //                       Row(
        //                         children: [
        //                           Container(
        //                             width: 15.w,
        //                             height: 15.h,
        //                             child: Icon(
        //                               Icons.forum,
        //                               color: primaryColor,
        //                             ),
        //                             // Image.asset("images/blog/comment.png"),
        //                           ),
        //                           Container(
        //                             width: 10,
        //                           ),
        //                           Text(
        //                             widget.blog!.blogCommentaries != null
        //                                 ? widget.blog!.blogCommentaries!.length
        //                                     .toString()
        //                                 : "0",
        //                             style: TextStyle(
        //                                 fontWeight: FontWeight.w600,
        //                                 fontSize: responsiveFont(8)),
        //                           ),
        //                           Text(
        //                             AppLocalizations.of(context)!
        //                                 .translate('comments')!,
        //                             style: TextStyle(fontSize: responsiveFont(8)),
        //                           )
        //                         ],
        //                       )
        //                     ]),
        //               )),
        //         ],
        //       ),
        //     ),
        //   ),
        // );
        GestureDetector(onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BlogDetail(
                    id: widget.blog!.id.toString(),
                  )));
    }, child: Consumer<HomeProvider>(builder: (context, value, child) {
      return Container(
        decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(5)),
        child: Card(
          elevation: 3,
          margin: EdgeInsets.only(bottom: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: HexColor("c4c4c4"),
                  ),
                  child: widget.blog!.blogImages != null
                      ? Image.network(
                          widget.blog!.blogImages![0].srcImg!,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.image_not_supported_outlined,
                          size: 64,
                        ),
                ),
              ),
              Expanded(
                  flex: 4,
                  child: Container(
                    margin: EdgeInsets.all(5),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Text(
                              widget.blog!.title!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: responsiveFont(10)),
                            ),
                          ),
                          Container(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: secondaryColor,
                                      borderRadius: BorderRadius.circular(2)),
                                  child: Text(
                                    "By : ${widget.blog!.author}",
                                    style: TextStyle(
                                        fontSize: responsiveFont(6),
                                        color: Colors.white),
                                  )),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                  child: Text(
                                convertDateFormatShortMonth(
                                    DateTime.parse(widget.blog!.date!)),
                                style: TextStyle(fontSize: responsiveFont(8)),
                              ))
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          HtmlWidget(
                            widget.blog!.excerpt!.length < 90
                                ? widget.blog!.excerpt!
                                : widget.blog!.excerpt!.substring(0, 90) +
                                    '...',
                            textStyle: TextStyle(fontSize: responsiveFont(8)),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              value.blogCommentFeature
                                  ? Container(
                                      width: 15.w,
                                      height: 15.h,
                                      child: Icon(
                                        Icons.forum,
                                        color: primaryColor,
                                      ),
                                      // Image.asset("images/blog/comment.png"),
                                    )
                                  : Container(),
                              Container(
                                width: 10,
                              ),
                              value.blogCommentFeature
                                  ? Text(
                                      widget.blog!.blogCommentaries != null
                                          ? widget
                                              .blog!.blogCommentaries!.length
                                              .toString()
                                          : "0",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: responsiveFont(8)),
                                    )
                                  : Container(),
                              value.blogCommentFeature
                                  ? Text(
                                      AppLocalizations.of(context)!
                                          .translate('comments')!,
                                      style: TextStyle(
                                          fontSize: responsiveFont(8)),
                                    )
                                  : Container()
                            ],
                          )
                        ]),
                  )),
            ],
          ),
        ),
      );
    }));
  }
}
