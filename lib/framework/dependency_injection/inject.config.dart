// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:chassis_timeline_viewer/framework/controller/canvas_map/canvas_map_controller.dart'
    as _i841;
import 'package:chassis_timeline_viewer/ui/routing/delegate.dart' as _i776;
import 'package:chassis_timeline_viewer/ui/routing/navigation_stack_item.dart'
    as _i886;
import 'package:chassis_timeline_viewer/ui/routing/parser.dart' as _i45;
import 'package:chassis_timeline_viewer/ui/routing/stack.dart' as _i631;
import 'package:flutter/material.dart' as _i409;
import 'package:flutter_riverpod/flutter_riverpod.dart' as _i729;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i841.CanvasMapController>(() => _i841.CanvasMapController());
    gh.factoryParam<
      _i45.MainRouterInformationParser,
      _i729.WidgetRef,
      _i409.BuildContext
    >((ref, context) => _i45.MainRouterInformationParser(ref, context));
    gh.factoryParam<
      _i631.NavigationStack,
      List<_i886.NavigationStackItem>,
      dynamic
    >((items, _) => _i631.NavigationStack(items));
    gh.factoryParam<_i776.MainRouterDelegate, _i631.NavigationStack, dynamic>(
      (stack, _) => _i776.MainRouterDelegate(stack),
    );
    return this;
  }
}
