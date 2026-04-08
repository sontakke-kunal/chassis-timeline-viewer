import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:chassis_timeline_viewer/ui/routing/navigation_stack_item.dart';
import 'package:chassis_timeline_viewer/ui/routing/navigation_stack_keys.dart';
import 'package:chassis_timeline_viewer/ui/routing/route_manager.dart';
import 'package:chassis_timeline_viewer/ui/routing/stack.dart';
import 'package:chassis_timeline_viewer/ui/utils/app_constants.dart';

@injectable
class MainRouterInformationParser
    extends RouteInformationParser<NavigationStack> {
  WidgetRef ref;
  BuildContext context;

  MainRouterInformationParser(
    @factoryParam this.ref,
    @factoryParam this.context,
  );

  @override
  Future<NavigationStack> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    List<String> queryParam = [];
    var startUri = NavigationStackKeyMapper.mapper.currentLocation.isNotEmpty
        ? NavigationStackKeyMapper.mapper.currentLocation
        : routeInformation.uri.toString();
    List<String> tempUrlList = startUri.split('/');
    tempUrlList.removeAt(0);
    List<String> tempPathList = [];
    for (var element in tempUrlList) {
      tempPathList.add(element.split('?').first);
      if (element.split('?').length > 1) {
        queryParam.add(element.split('?').last);
      }
    }
    String mainUrl =
        '/${tempPathList.join('/')}${queryParam.isNotEmpty ? '?${queryParam.join('&')}' : ''}';
    AppConstants.constant.showLog('........URL......$mainUrl');
    final Uri uri = Uri.parse(mainUrl);
    final queryParams = uri.queryParameters;

    AppConstants.constant.showLog('........queryParams....$queryParams');
    NavigationStackKeyMapper.mapper.keysList = uri.pathSegments;
    final items = <NavigationStackItem>[];
    AppConstants.constant.showLog('Path Segments-> ${uri.pathSegments}');

    ///Will remove all the empty path from segments
    RouteManager.route.removeEmptyPath(uri.pathSegments);

    ///Will check validation for routes
    var pathValidation = RouteManager.route.checkPathValidation();
    // if (Session.userAccessToken.isNotEmpty) {
    //   await ref
    //       .read(profileController)
    //       .getProfileDetail(context, ref, isNotify: false)
    //       .then((value) async {
    //         if (ref
    //                 .read(profileController)
    //                 .profileDetailState
    //                 .success
    //                 ?.status ==
    //             ApiEndPoints.apiStatus_200) {
    //           await ref
    //               .read(drawerController)
    //               .getSideMenuListAPI(context, isNotify: false);
    //         }
    //       });
    // }

    for (var i = 0; i < uri.pathSegments.length; i = i + 1) {
      ///To add error page at the end and return no widget if error is found
      final key = uri.pathSegments[i];
      getKeysHandler(items, key, queryParams, uri.pathSegments);
    }

    if (items.isEmpty) {
      const fallback = NavigationStackItem.splash();
      if (items.isNotEmpty && items.first is NavigationStackItemSplashPage) {
        items[0] = fallback;
      } else {
        items.insert(0, fallback);
      }
    }

    return NavigationStack(items);
  }

  Map<String, Function()> keysHandler(
    List<NavigationStackItem> items,
    Map<String, String> queryParams,
  ) => <String, Function()>{
    Keys.splash: () => items.add(const NavigationStackItem.splash()),
  };

  void getKeysHandler(
    List<NavigationStackItem> items,
    String key,
    Map<String, String> queryParams,
    List<String> pathSegments,
  ) {
    NavigationStackKeyMapper.mapper.currentKey = key;
    final handler = keysHandler(items, queryParams)[key];
    if (handler != null) {
      handler();
    } else {
      items.add(const NavigationStackItem.splash());
    }
  }

  ///THIS IS IMPORTANT: Here we restore the web history
  @override
  RouteInformation? restoreRouteInformation(NavigationStack configuration) {
    String mainUrl = NavigationStackKeyMapper.mapper.fetchMainUrl(
      configuration.items,
      ref: ref,
    );
    Uri routeUrl = Uri.parse(mainUrl);
    return RouteInformation(uri: routeUrl);
  }
}
