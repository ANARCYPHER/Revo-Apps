import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/provider/app_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SocmedScreen extends StatefulWidget {
  const SocmedScreen({Key? key}) : super(key: key);

  @override
  _SocmedScreenState createState() => _SocmedScreenState();
}

class _SocmedScreenState extends State<SocmedScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Provider.of<AppNotifier>(context, listen: false).isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? null : HexColor('ecf2f9'),
      appBar: AppBar(
        // backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              // color: Colors.black,
            )),
        title: Text(
          "Social Media",
          style: TextStyle(
            fontSize: responsiveFont(16),
            fontWeight: FontWeight.w500,
            // color: Colors.black
          ),
        ),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    final socmed = Provider.of<HomeProvider>(context, listen: false).sosmedLink;
    return ListView(children: [
      Container(
        child: ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: [
            SizedBox(
              height: 10,
            ),
            Visibility(
              visible: socmed.description['whatsapp'] != "",
              child: cardMenu(
                  'whatsapp-logo', 'icon-message', 'WhatsApp', 'Chat Us'),
            ),
            Visibility(
                visible: socmed.description['facebook'] != "",
                child: cardMenu('facebook-logo', 'icon-message', 'Facebook',
                    'Follow Our Account')),
            Visibility(
                visible: socmed.description['instagram'] != "",
                child: cardMenu('instagram-logo', 'icon-message', 'Instagram',
                    'Follow Our Account')),
            Visibility(
                visible: socmed.description['youtube'] != "",
                child: cardMenu('youtube-logo', 'icon-message', 'YouTube',
                    'Subscribe Our Channel')),
            Visibility(
                visible: socmed.description['tiktok'] != "",
                child: cardMenu('tiktok-logo', 'icon-message', 'TikTok',
                    'Follow Our Account')),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      )
    ]);
  }

  Container cardMenu(
      String iconLeading, String iconBtn, String title, String subtitle) {
    final socmed = Provider.of<HomeProvider>(context, listen: false).sosmedLink;
    final isDarkMode =
        Provider.of<AppNotifier>(context, listen: false).isDarkMode;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: isDarkMode ? null : Colors.white,
          borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Image.asset(
              'images/lobby/$iconLeading.png',
              width: 45.w,
              height: 45.h,
            ),
            SizedBox(
              width: 15.w,
            ),
            Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: responsiveFont(19)),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: responsiveFont(11),
                          fontWeight: FontWeight.w500,
                          color: HexColor('818181')),
                    ),
                  ]),
            )
          ]),
        ),
        Container(
          width: double.infinity,
          child: TextButton.icon(
            icon: Image.asset(
              'images/lobby/$iconBtn.png',
              width: 20.w,
              height: 20.h,
            ),
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0))),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all(primaryColor)),
            onPressed: () {
              if (iconLeading == 'whatsapp-logo') {
                _launchURL(socmed.description['whatsapp']);
              } else if (iconLeading == 'instagram-logo') {
                _launchURL(socmed.description['instagram']);
              } else if (iconLeading == 'youtube-logo') {
                _launchURL(socmed.description['youtube']);
              } else if (iconLeading == 'facebook-logo') {
                _launchFacebook(socmed.description['facebook']);
              } else if (iconLeading == 'tiktok-logo') {
                _launchURL(socmed.description['tiktok']);
              }
            },
            label: Text(
              AppLocalizations.of(context)!.translate('connect')!,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: responsiveFont(14)),
            ),
          ),
        )
      ]),
    );
  }

  _launchFacebook(String url) async {
    if (url != "") {
      try {
        await launchUrl(Uri.parse("fb://facewebmodal/f?href=$url"),
            mode: LaunchMode.externalApplication);
      } catch (e) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      printLog("url : $url");
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
