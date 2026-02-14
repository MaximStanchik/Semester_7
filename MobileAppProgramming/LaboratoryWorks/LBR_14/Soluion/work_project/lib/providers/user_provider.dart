import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/hive_service.dart';

class UserProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService.instance;
  AppUser? _activeUser;
  bool _isLoading = true;

  AppUser? get activeUser => _activeUser;
  bool get isLoading => _isLoading;
  List<AppUser> get users => _hiveService.getUsers();

  UserProvider() {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final users = _hiveService.getUsers();
    _activeUser = users.isNotEmpty ? users.first : null;
    _isLoading = false;
    notifyListeners();
  }

  void selectUser(AppUser user) {
    if (_activeUser?.id != user.id) {
      _activeUser = user;
      notifyListeners();
    }
  }

  bool canManageProducts() {
    if (_activeUser == null) return false;
    return _hiveService.canManageProducts(_activeUser!);
  }
}

