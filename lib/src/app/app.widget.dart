import 'package:firestorecrud/logic/fetchdata/cubit/fetchdata_cubit.dart';
import 'package:firestorecrud/router/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _appRouter = AppRouter();
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (content) => FetchdataCubit(),
        ),
      ],
      child: MaterialApp.router(
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
        debugShowCheckedModeBanner: false,
        title: 'Firestorecrud',
        theme: ThemeData(),
        builder: EasyLoading.init(),
      ),
    );
  }
}
