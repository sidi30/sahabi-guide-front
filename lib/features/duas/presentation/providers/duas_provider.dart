import 'package:flutter/foundation.dart';
import '../../../../shared/models/dua_model.dart';
import '../../domain/repositories/duas_repository.dart';

class DuasProvider extends ChangeNotifier {
  final DuasRepository repository;
  
  List<DuaModel> _duas = [];
  List<DuaModel> _filteredDuas = [];
  List<DuaModel> _favoriteDuas = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  final Set<String> _favoriteDuaIds = {};

  DuasProvider({required this.repository});

  // Getters
  List<DuaModel> get duas => _filteredDuas.isEmpty && _searchQuery.isEmpty ? _duas : _filteredDuas;
  List<DuaModel> get favoriteDuas => _favoriteDuas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  bool isFavorite(String duaId) => _favoriteDuaIds.contains(duaId);

  Future<void> loadDuas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _duas = await repository.getDuas();
      _filteredDuas = _duas;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavoriteDuas() async {
    try {
      _favoriteDuas = await repository.getFavoriteDuas();
      for (var dua in _favoriteDuas) {
        _favoriteDuaIds.add(dua.id);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String duaId) async {
    try {
      await repository.toggleFavorite(duaId);
      if (_favoriteDuaIds.contains(duaId)) {
        _favoriteDuaIds.remove(duaId);
        _favoriteDuas.removeWhere((dua) => dua.id == duaId);
      } else {
        _favoriteDuaIds.add(duaId);
        final dua = _duas.firstWhere((d) => d.id == duaId);
        _favoriteDuas.add(dua);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchDuas(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredDuas = _duas;
    } else {
      _filteredDuas = await repository.searchDuas(query);
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredDuas = _duas;
    notifyListeners();
  }
}
