enum UserRole {
  admin,
  manager,
  user;
  
  String get name {
    switch (this) {
      case UserRole.admin:
        return 'Админ';
      case UserRole.manager:
        return 'Менеджер';
      case UserRole.user:
        return 'Пользователь';
    }
  }
}


