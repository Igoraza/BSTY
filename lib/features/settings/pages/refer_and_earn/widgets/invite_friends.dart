import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../utils/theme/colors.dart';
import '../../../widgets/social_icons.dart';

class InviteFriends extends StatelessWidget {
  InviteFriends({
    Key? key,
  }) : super(key: key);

  final String referralCode = Hive.box('user').get('referral_code');

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height;
    double appWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Text('Invite Friends',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: AppColors.black),
            textAlign: TextAlign.center),
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: appHeight * 0.01),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: appWidth * 0.03,
            runSpacing: appWidth * 0.03,
            children: [
              // SocialIcons(
              //   onTap: () async {
              //     String? response = await FlutterShareMe().shareToWhatsApp(
              //       msg:
              //           'Try Metfie app \nhttps://play.google.com/store/apps/details?id=com.bsty.app ,\n Use my Referral code: $referral_code',
              //     );
              //   },
              //   name: 'whatsapp',
              // ),
              // SocialIcons(
              //   onTap: () async {
              //     // String? response =
              //     //     await FlutterShareMe().shareToMessenger(
              //     //   msg:
              //     //       'Try Metfie app \nhttps://play.google.com/store/apps/details?id=com.bsty.app ,\n Use my Referral code: $referral_code',
              //     // );
              //   },
              //   name: 'facebook',
              // ),
              // SocialIcons(
              //   onTap: ()async {
              //   if (await launchUrl(
              // Uri(
              //   scheme: "https",
              //   host: 'www.instagram.com',
              //   path: "store/apps/details",
              // ),
              // mode: LaunchMode.externalNonBrowserApplication)) {}
              //   name: 'instagram',
              // ),
              SocialIcons(
                onTap: () async {
                  String body =
                      "Try Metfie app \nhttps://metfie.page.link/getapp ,\nUse my Referral code: $referralCode";
                  Uri sms = Uri.parse('sms:?&body=$body');
                  if (await launchUrl(sms)) {
                    //app opened
                  } else {
                    //app is not opened
                  }
                },
                name: 'bubble',
              ),
              SocialIcons(
                onTap: () async {
                  String subject = Uri.encodeComponent("Metfie");
                  String body = Uri.encodeComponent(
                      "Try Metfie app \nhttps://metfie.page.link/getapp ,\nUse my Referral code: $referralCode");
                  Uri mail = Uri.parse("mailto:?subject=$subject&body=$body");
                  if (await launchUrl(mail)) {
                    //email app opened
                  } else {
                    //email app is not opened
                  }
                },
                name: 'mail',
              ),
              SocialIcons(
                  onTap: () {
                    String msg =
                        'Try Metfie app \nhttps://metfie.page.link/getapp ,\nUse my Referral code: $referralCode';
                    debugPrint('Share Code');
                    final box = context.findRenderObject() as RenderBox;
                    Share.share(
                      msg,
                      subject: 'Refer',
                      sharePositionOrigin:
                          box.localToGlobal(Offset.zero) & box.size,
                    );
                  },
                  name: 'share')
            ],
          ),
        ),
      ],
    );
  }
}
