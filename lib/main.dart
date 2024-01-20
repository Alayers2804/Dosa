import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<ServiceNotificationEvent>? _subscription;
  List<ServiceNotificationEvent> events = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dosa'),
        ),
        body: Center(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final res = await NotificationListenerService
                            .requestPermission();
                        log("Is enabled: $res");
                      },
                      child: const Text("Request Permission"),
                    ),
                    const SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () async {
                        final bool res = await NotificationListenerService
                            .isPermissionGranted();
                        log("Is enabled: $res");
                        Fluttertoast.showToast(
                            msg: "Already Enabled",
                            toastLength: Toast.LENGTH_LONG);
                      },
                      child: const Text("Check Permission"),
                    ),
                    const SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () {
                        Fluttertoast.showToast(msg: "Program Started");
                        _subscription = NotificationListenerService
                            .notificationsStream
                            .listen((event) {
                          log("$event.packageName");
                          if (event.packageName == "com.whatsapp" ||
                              event.packageName == "com.whatsapp.w4b" &&
                                  event.hasRemoved == false) {
                            setState(() {
                              events.add(event);
                            });
                          } else {
                            log("Not Whatsapp");
                          }
                        });
                      },
                      child: const Text("Start Getting Notifications"),
                    ),
                    const SizedBox(height: 20.0),
                    TextButton(
                      onPressed: () {
                        events.clear();
                        setState(() {
                          events = [];
                        });
                        _subscription?.cancel();
                      },
                      child: const Text("Clear List"),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (_, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(events[index].title ?? "No title"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            events[index].content ?? "no content",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          events[index].largeIcon != null
                              ? Image.memory(
                                  events[index].largeIcon!,
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
