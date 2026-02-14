import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:laba3/bloc/app_bloc.dart';
import 'package:laba3/models/user.dart';
import 'package:laba3/models/role.dart';
import 'package:laba3/models/product.dart';
import 'package:laba3/models/favorite.dart';
import 'package:laba3/models/history.dart';
import 'package:laba3/providers/app_provider.dart';

class MockAppProvider extends Mock implements AppProvider {
  @override
  List<AppUser> get users => super.noSuchMethod(
        Invocation.getter(#users),
        returnValue: <AppUser>[],
        returnValueForMissingStub: <AppUser>[],
      );

  @override
  AppUser? get currentUser => super.noSuchMethod(
        Invocation.getter(#currentUser),
        returnValue: null,
        returnValueForMissingStub: null,
      );

  @override
  List<Product> get products => super.noSuchMethod(
        Invocation.getter(#products),
        returnValue: <Product>[],
        returnValueForMissingStub: <Product>[],
      );

  @override
  List<FavoriteItem> get favorites => super.noSuchMethod(
        Invocation.getter(#favorites),
        returnValue: <FavoriteItem>[],
        returnValueForMissingStub: <FavoriteItem>[],
      );

  @override
  List<SearchHistory> get history => super.noSuchMethod(
        Invocation.getter(#history),
        returnValue: <SearchHistory>[],
        returnValueForMissingStub: <SearchHistory>[],
      );

  @override
  Future<void> setCurrentUser(user) => super.noSuchMethod(
        Invocation.method(#setCurrentUser, [user]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<void> toggleFavorite(String userId, String productId) =>
      super.noSuchMethod(
        Invocation.method(#toggleFavorite, [userId, productId]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<void> addSearchHistory(String userId, String query) =>
      super.noSuchMethod(
        Invocation.method(#addSearchHistory, [userId, query]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
}

void main() {
  late MockAppProvider mockAppProvider;
  late AppBloc appBloc;
  final user = AppUser(id: '1', name: 'Alice', role: UserRole.user);
  final admin = AppUser(id: 'admin', name: 'Admin', role: UserRole.admin);
  final product = Product(
    id: 'p1',
    title: 'Rome Trip',
    imagePath: 'assets/mountain.jpg',
    price: 100,
    location: 'Rome',
    reviewsCount: 10,
    description: 'Trip',
    liked: false,
  );

  Future<void> pumpBloc() async {
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() {
    mockAppProvider = MockAppProvider();
    appBloc = AppBloc(appProvider: mockAppProvider);
  });

  tearDown(() async {
    await appBloc.close();
  });

  test('AppStarted loads data from provider', () async {
    when(mockAppProvider.users).thenReturn(<AppUser>[user, admin]);
    when(mockAppProvider.products).thenReturn(<Product>[product]);
    appBloc.add(const AppStarted());
    await pumpBloc();
    expect(appBloc.state.users.length, 2);
    expect(appBloc.state.products.single.title, 'Rome Trip');
  });

  test('SetCurrentUser stores value and calls provider', () async {
    when(mockAppProvider.currentUser).thenReturn(user);

    appBloc.add(SetCurrentUser(user));
    await pumpBloc();

    verify(mockAppProvider.setCurrentUser(user)).called(1);
    expect(appBloc.state.currentUser, user);
  });

  test('ToggleFavoriteEvent updates favorites list', () async {
    var favorites = <FavoriteItem>[];
    when(mockAppProvider.toggleFavorite(user.id, product.id))
        .thenAnswer((invocation) async {
      favorites = [
        FavoriteItem(userId: user.id, productId: product.id),
      ];
    });
    when(mockAppProvider.favorites).thenAnswer((_) => favorites);

    appBloc.add(ToggleFavoriteEvent(user.id, product.id));
    await pumpBloc();

    verify(mockAppProvider.toggleFavorite(user.id, product.id)).called(1);
    expect(appBloc.state.favorites, isNotEmpty);
  });

  test('AddSearchHistoryEvent ignored when user is null', () async {
    appBloc.add(const AddSearchHistoryEvent('Rome -> Milan'));
    await pumpBloc();

    verifyNever(mockAppProvider.addSearchHistory(user.id, 'Rome -> Milan'));
    expect(appBloc.state.history, isEmpty);
  });

  test('AddSearchHistoryEvent stores queries when user exists', () async {
    when(mockAppProvider.setCurrentUser(any)).thenAnswer((_) async {});
    when(mockAppProvider.currentUser).thenReturn(user);
    var history = <SearchHistory>[
      SearchHistory(id: 'h1', userId: user.id, query: 'Rome', createdAt: DateTime.now()),
    ];
    when(mockAppProvider.addSearchHistory(user.id, 'Rome'))
        .thenAnswer((_) async {});
    when(mockAppProvider.history).thenAnswer((_) => history);

    appBloc.add(SetCurrentUser(user));
    await pumpBloc();
    appBloc.add(const AddSearchHistoryEvent('Rome'));
    await pumpBloc();

    verify(mockAppProvider.addSearchHistory(user.id, 'Rome')).called(1);
    expect(appBloc.state.history.length, 1);
  });
}

