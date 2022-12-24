import 'package:auto_route/auto_route.dart';
import 'package:firestorecrud/pages/homepage.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: DashboardPage, initial: true),
  ],
)
class $AppRouter {}
