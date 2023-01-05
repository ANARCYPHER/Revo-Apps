import 'package:nyoba/constant/constants.dart';
import 'package:nyoba/constant/global_url.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/utils/utility.dart';

class BlogAPI {
  fetchBlog(search, page) async {
    var response = await baseAPI.getAsync(
        '$blog?search=$search&page=$page&per_page=6&_embed',
        version: 2);
    return response;
  }

  fetchBlogs(search, page) async {
    printLog("bahasa : ${Session.data.getString('language_code')}");
    String code = "id";
    if (Session.data.getString('language_code') != null) {
      code = Session.data.getString('language_code')!;
    }
    var response = await baseAPI.getAsync(
        '$listBlog?_embed=true&lang=$code&page=$page&per_page=6&search=$search',
        isCustom: true,
        printedLog: true);
    printLog("response blog : ${(response.body)}");
    return response;
  }

  fetchDetailBlog(int postId) async {
    String code = Session.data.getString('language_code')!;
    var response = await baseAPI.getAsync(
      '$listBlog?_embed=true&lang=$code&post_id=$postId',
      isCustom: true,
    );
    printLog("response blog detail : ${response.body}");
    return response;
  }

  postCommentBlog(String postId, String? comment) async {
    Map data = {
      'cookie': Session.data.getString('cookie'),
      'post': postId,
      'comment': comment
    };
    var response = await baseAPI.postAsync(
      '$postComment',
      data,
      isCustom: true,
    );
    return response;
  }

  fetchBlogComment(postId) async {
    var response =
        await baseAPI.getAsync('$listComment?post=$postId', version: 2);
    return response;
  }

  fetchBlogDetailById(postId) async {
    var response = await baseAPI.getAsync('$blog/$postId?_embed', version: 2);
    return response;
  }

  fetchBlogDetailBySlug(slug) async {
    var response =
        await baseAPI.getAsync('$blog/?_embed&slug=$slug', version: 2);
    return response;
  }
}
