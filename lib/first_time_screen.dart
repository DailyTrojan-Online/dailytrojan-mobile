import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'main.dart';

class FirstTimeScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> homeNavigatorKey;
  final List<String> selectedChannels = [];

  void addNotificationChannel(String channelId) {
    print('adding channel: $channelId');
    selectedChannels.add(channelId);
  }

  void removeNotificationChannel(String channelId) {
    print('re channel: $channelId');
    selectedChannels.remove(channelId);
  }

  Future<void> addNotificationChannels() async {
    // You may set the permission requests to "provisional" which allows the user to choose what type
// of notifications they would like to receive once the user receives a notification.
    FirebaseMessaging.instance
        .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true)
        .then((notificationSettings) async {
      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.provisional) {
        for (var channelId in selectedChannels) {
          PreferencesService.setNotificationChannelEnabled(channelId, true);

          var success = await FirebaseMessagingService.setTopicSubscription(
              channelId, true);
          if (!success) {
            // Revert the change if it failed
            PreferencesService.setNotificationChannelEnabled(
                channelId, false);
          }
        }
        PreferencesService.setNotificationPermissionsEnabled(true);
      } else {
        print('User declined or has not accepted permission');
        PreferencesService.setNotificationPermissionsEnabled(false);
      }
      homeNavigatorKey.currentState?.pop();
    }).catchError((error) {
      print('Error requesting notification permissions: $error');
      PreferencesService.setNotificationPermissionsEnabled(false);
      homeNavigatorKey.currentState?.pop();
    });
  }

  FirstTimeScreen({super.key, required this.homeNavigatorKey});
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontSize: 28,
        fontWeight: FontWeight.bold);
    final authorStyle = theme.textTheme.labelSmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant, fontFamily: "Inter");
    final excerptStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 14.0,
        fontFamily: "SourceSerif4");
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(children: [
            Padding(
              padding: horizontalContentPadding
                  .add(EdgeInsets.only(top: 48.0, bottom: 8)),
              child: Column(
                children: [
                  Text(
                    "Get everything first",
                    style: headlineStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Select the channels you want to receive notifications\u00A0for.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) => NotificationToggler(
                    channel:
                        PreferencesService.getNotificationChannels()[index],
                    addChannel: addNotificationChannel,
                    removeChannel: removeNotificationChannel),
                itemCount: PreferencesService.getNotificationChannels().length,
                separatorBuilder: (context, index) => Padding(
                  padding: horizontalContentPadding,
                  child: Divider(height: 1),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: horizontalContentPadding
                    .add(EdgeInsets.only(bottom: 8.0, top: 8)),
                child: OutlinedButton(
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        BorderSide(
                          width: 0.0,
                          color: Colors.transparent,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                          theme.colorScheme.primaryContainer),
                      overlayColor: MaterialStateProperty.all(
                          theme.colorScheme.primaryFixed.withOpacity(0.1)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      addNotificationChannels();
                    },
                    child: Text(
                      'ENABLE NOTIFICATIONS',
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: horizontalContentPadding
                    .add(EdgeInsets.only(bottom: 32.0, top: 8)),
                child: OutlinedButton(
                    style: ButtonStyle(
                      side: MaterialStateProperty.all<BorderSide>(
                        BorderSide(
                          width: 2.0,
                          color: theme.colorScheme.primaryFixed,
                        ),
                      ),
                      overlayColor: MaterialStateProperty.all(
                          theme.colorScheme.primaryFixed.withOpacity(0.1)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      homeNavigatorKey.currentState?.pop();
                    },
                    child: Text('SKIP (NO NOTIFICATIONS)',
                        style: theme.textTheme.labelLarge!.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.bold,
                        ))),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class NotificationToggler extends StatefulWidget {
  const NotificationToggler({
    super.key,
    required this.channel,
    this.addChannel,
    this.removeChannel,
  });

  final NotificationChannel channel;

  final void Function(String channelId)? addChannel;
  final void Function(String channelId)? removeChannel;

  @override
  State<NotificationToggler> createState() => _NotificationTogglerState();
}

class _NotificationTogglerState extends State<NotificationToggler> {
  bool enabled = false;
  void toggleChannel(bool value) async {
    setState(() {
      enabled = value;
    });
    if (value) {
      widget.addChannel?.call(widget.channel.id);
    } else {
      widget.removeChannel?.call(widget.channel.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final infoStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 14.0,
        fontFamily: "Inter");
    final headerStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onSurface, fontFamily: "Inter");
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: 12.0).add(horizontalContentPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.channel.name, style: headerStyle),
              Text(widget.channel.description, style: infoStyle),
            ],
          ),
          Switch.adaptive(value: enabled, onChanged: toggleChannel),
        ],
      ),
    );
  }
}
