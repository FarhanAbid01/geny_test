import 'package:flutter/foundation.dart';
import '../models/business.dart';
import '../services/business_service.dart';

enum BusinessState { 
  initial, 
  loading, 
  loaded, 
  empty, 
  error 
}

class BusinessProvider with ChangeNotifier {
  final BusinessService _businessService;

  BusinessProvider(this._businessService);

  BusinessState _state = BusinessState.initial;
  List<Business> _businesses = [];
  String? _errorMessage;

  // Getters
  BusinessState get state => _state;
  List<Business> get businesses => List.unmodifiable(_businesses);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == BusinessState.loading;
  bool get hasError => _state == BusinessState.error;
  bool get isEmpty => _state == BusinessState.empty;
  bool get hasData => _businesses.isNotEmpty;

  // Get business by ID
  Business? getBusinessById(String id) {
    try {
      return _businesses.firstWhere((business) => business.id == id);
    } catch (e) {
      return null;
    }
  }

  // Load businesses with proper service integration
  Future<void> loadBusinesses({bool forceRefresh = false}) async {
    try {
      _setState(BusinessState.loading);
      
      final businesses = await _businessService.getBusinesses(forceRefresh: forceRefresh);
      
      _businesses = businesses;
      _errorMessage = null;
      
      if (businesses.isEmpty) {
        _setState(BusinessState.empty);
      } else {
        _setState(BusinessState.loaded);
      }
    } on BusinessServiceException catch (e) {
      _errorMessage = e.message;
      _setState(BusinessState.error);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _setState(BusinessState.error);
    }
  }

  // Retry loading
  Future<void> retry() async {
    await loadBusinesses(forceRefresh: true);
  }

  // Refresh data
  Future<void> refresh() async {
    await loadBusinesses(forceRefresh: true);
  }

  // Clear cache and reload
  Future<void> clearCacheAndReload() async {
    try {
      await _businessService.clearCache();
      await loadBusinesses(forceRefresh: true);
    } catch (e) {
      _errorMessage = 'Failed to clear cache: ${e.toString()}';
      _setState(BusinessState.error);
    }
  }

  void _setState(BusinessState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }
}
