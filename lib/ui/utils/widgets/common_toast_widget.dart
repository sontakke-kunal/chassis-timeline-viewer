import 'package:chassis_timeline_viewer/ui/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/context_extension.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/extension.dart';
import 'package:chassis_timeline_viewer/framework/utils/extension/string_extension.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/app_colors.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/app_strings.g.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/assets.gen.dart';
import 'package:chassis_timeline_viewer/ui/utils/theme/text_style.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_svg.dart';
import 'package:chassis_timeline_viewer/ui/utils/widgets/common_text.dart';


GlobalKey snackBarKey =GlobalKey();

showToast({required BuildContext context,bool? isSuccess,String? title, String? message,int? duration,bool? showAtBottom}){
  if(snackBarKey.currentContext == null){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:CommonToastWidget(isSuccess:isSuccess,message:message,title: title,),
        duration: Duration(milliseconds: duration??5000),
        backgroundColor:AppColors.transparent,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
            right: context.width*0.005,
            left: context.width*0.7,
            bottom: showAtBottom??false?context.height*0.08:context.height *0.84
        ),
      ),
    );
  }
}

class CommonToastWidget extends StatelessWidget {
  final bool? isSuccess;
  final String? message;
  final String? title;
  const CommonToastWidget({super.key,this.isSuccess,this.message,this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: isSuccess??true?AppColors.clr34C759: AppColors.clrFF3B30,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          /// Icon,title and message
          Expanded(
            child: Row(
              children: [
                CommonSVG(
                  strIcon: isSuccess??true? Assets.svgs.svgToastSuccess.keyName:Assets.svgs.svgToastFailure.keyName,
                ).paddingOnly(right: 20),

                /// If only title is passed then it should be in center
                (title?.isNotEmpty??true) && (message?.isEmpty??true)?
                Flexible(
                  child: CommonText(
                    title: title?.isEmpty??true
                        ? isSuccess??true? '${LocaleKeys.keySuccess.localized}!': LocaleKeys.keySomeThingWentWrong.localized
                        :title??'',
                    maxLines: 3,
                    style: TextStyles.bold.copyWith(
                      fontSize: 16,
                      color: AppColors.black,
                    ),
                  ),
                ):
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: CommonText(
                          title: title?.isEmpty??true
                              ? isSuccess??true? '${LocaleKeys.keySuccess.localized}!': LocaleKeys.keySomeThingWentWrong.localized
                          :title??'',
                          maxLines: 3,
                          style: TextStyles.bold.copyWith(
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      Flexible(
                        child: CommonText(
                          title: message??'',
                          maxLines: 3,
                          style: TextStyles.regular.copyWith(
                            fontSize: 12,
                            color: AppColors.clr2F3F53,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          /// Hide snackbar
          InkWell(
            onTap: (){
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
            child: CommonSVG(
              strIcon: Assets.svgs.svgCrossIcon.keyName,
              colorFilter: ColorFilter.mode(AppColors.clr979FA9, BlendMode.srcATop),
            ),
          )
        ],
      ).paddingOnly(left: 20,bottom: 10,top: 10,right: 16),
    );
  }
}
