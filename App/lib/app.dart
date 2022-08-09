import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import './routes/camera.dart';

class SolimageApp extends StatelessWidget {
	SolimageApp({Key? key}) : super(key: key);

  Future<CameraDescription> initializeCamera() async {
    return (await availableCameras()).first;
  }

	late final router = GoRouter(
    initialLocation: '/camera',
    routes: [
      GoRoute(
        path: '/camera',
        name: 'camera',
        builder: (context, state) => FutureBuilder(
					future: initializeCamera(),
					builder: (context, AsyncSnapshot<CameraDescription> snapshot) {
						if (snapshot.connectionState == ConnectionState.done) {
							return CameraScreen(camera: snapshot.data as CameraDescription);
						} else {
							return const Center(child: CircularProgressIndicator());
						}
					}
        ),
      )
    ]
	);

	@override
	Widget build(BuildContext context) => MaterialApp.router(
		title: 'Solimage',
		theme: ThemeData(
			primarySwatch: Colors.blue,
		),
		routerDelegate: router.routerDelegate,
		routeInformationParser: router.routeInformationParser,
		routeInformationProvider: router.routeInformationProvider,
	);
}