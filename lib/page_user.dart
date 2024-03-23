import 'package:flutter/material.dart';

import 'model_user.dart';
import 'repository.dart';

class PageUser extends StatefulWidget {
  const PageUser({
    super.key,
    required this.authorization,
    required this.userId,
  });
  final String authorization;
  final String userId;
  @override
  State<PageUser> createState() => _PageUserState();
}

class _PageUserState extends State<PageUser> {
  User? _user;

  void _getUser() async {
    final response =
        await Repository.getUser(widget.authorization, widget.userId);
    if (mounted) {
      if (response.statusCode < 400) {
        final user = User.fromJson(response.body);
        setState(() {
          _user = user;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    return _user == null
        ? const SizedBox(
            height: 80,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Nome: ${_user!.nomeCompleto}'),
                Text('Email: ${_user!.email}'),
                Text('Criado em: ${_user!.createdAt}'),
              ],
            ),
          );
  }
}
