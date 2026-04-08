import 'package:chassis_timeline_viewer/framework/dependency_injection/inject.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureMainDependencies({required String environment}) async {
  // IMPORTANT: clear old registrations before calling init again
  await getIt.reset(dispose: true);
  getIt.init(environment: environment);
}

abstract class Env {
  static const development = 'development';
  static const List<String> environments = [Env.development];
}
