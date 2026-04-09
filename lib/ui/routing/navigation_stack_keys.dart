import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chassis_timeline_viewer/ui/routing/navigation_stack_item.dart';

class Keys {
  Keys._();

  static Keys keys = Keys._();

  static String get splash => 'splash';
  static String get timeline => 'timeline';
}

class NavigationStackKeyMapper {
  NavigationStackKeyMapper._();

  String currentLocation = '';
  List<String> keysList = [];
  String currentKey = '';
  static NavigationStackKeyMapper mapper = NavigationStackKeyMapper._();
  static Map<String, String> keyValueMapper = {Keys.splash: 'Splash'};

  static value(String key) => keyValueMapper[key] ?? '';

  String fetchMainUrl(List<NavigationStackItem> items, {WidgetRef? ref}) {
    final location = items.fold<String>('', (previousValue, element) {
      return previousValue + element.when(splash: () => '/', timeline: () => Keys.timeline);
    });
    List<String> queryParam = [];
    List<String> tempUrlList = location.toString().split('/');
    tempUrlList.removeAt(0);
    List<String> tempPathList = [];
    for (var element in tempUrlList) {
      tempPathList.add(element.split('?').first);
      if (element.split('?').length > 1) {
        queryParam.add(element.split('?').last);
      }
    }
    NavigationStackKeyMapper.mapper.keysList = tempPathList;
    NavigationStackKeyMapper.mapper.currentKey = tempPathList.last;
    tempPathList = tempPathList.toSet().toList();
    queryParam = queryParam.toSet().toList();
    String mainUrl =
        '/${tempPathList.join('/')}${queryParam.isNotEmpty ? '?${queryParam.join('&')}' : ''}';
    NavigationStackKeyMapper.mapper.currentLocation = mainUrl;
    //Call from parser, then only update the key
    if (ref != null) {
      currentKey = tempPathList
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(',')
          .last
          .trim();
    }
    return mainUrl;
  }
}
