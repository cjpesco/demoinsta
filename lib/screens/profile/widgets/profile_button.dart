import 'package:demoinsta/screens/screens.dart';
import 'package:flutter/material.dart';

class ProfileButton extends StatelessWidget {
  final bool isCurrentUser;
  final bool isFollowing;
  const ProfileButton({
    Key key,
    @required this.isCurrentUser,
    @required this.isFollowing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isCurrentUser
        ? TextButton(
            onPressed: () => Navigator.of(context).pushNamed(
              EditProfileScreen.routeName,
              arguments: EditProfileScreenArgs(context: context),
            ),
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              textStyle: TextStyle(
                fontSize: 16.0,
              ),
            ),
            child: const Text('Edit Profile'),
          )
        : TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: isFollowing
                  ? Colors.grey[300]
                  : Theme.of(context).primaryColor,
              primary: isFollowing ? Colors.black : Colors.white,
              textStyle: TextStyle(
                fontSize: 16.0,
              ),
            ),
            child: Text(
              isFollowing ? 'Unfollow' : 'Follow',
            ),
          );
  }
}
