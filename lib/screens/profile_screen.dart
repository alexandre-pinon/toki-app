import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toki_app/main.dart';
import 'package:toki_app/providers/auth_provider.dart';
import 'package:toki_app/providers/user_provider.dart';
import 'package:toki_app/screens/change_user_name_screen.dart';
import 'package:toki_app/screens/home_sceen.dart';
import 'package:toki_app/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loggerInUser = context.watch<UserProvider>().user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Profile'),
      ),
      body: loggerInUser != null
          ? Center(
              child: Column(
                children: [
                  SizedBox(height: 48),
                  Column(
                    children: [
                      Transform.scale(
                        scale: 1.5,
                        child: CircleAvatar(
                          child: Text(loggerInUser.initials),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(loggerInUser.name),
                      Text(
                        loggerInUser.email,
                        style: theme.textTheme.labelSmall,
                      )
                    ],
                  ),
                  SizedBox(height: 48),
                  ...ListTile.divideTiles(
                    context: context,
                    tiles: [
                      ListTile(
                        title: Text('Change name'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeUserNameScreen(
                                user: loggerInUser,
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: Text('Log out'),
                        trailing: Icon(Icons.logout),
                        onTap: () async {
                          final authProvider = context.read<AuthProvider>();
                          final navigator = Navigator.of(context);
                          final confirm = await showConfirmationDialog(
                            context: context,
                            title: 'Log out?',
                          );

                          if (confirm) {
                            await authProvider.logout();
                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
