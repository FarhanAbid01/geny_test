import 'package:flutter/foundation.dart';
import '../models/business.dart';

enum BusinessState { 
  initial, 
  loading, 
  loaded, 
  empty, 
  error 
}

class BusinessProvider with ChangeNotifier {
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

  // Mock method for now - will be implemented with service in next commit
  Future<void> loadBusinesses({bool forceRefresh = false}) async {
    _setState(BusinessState.loading);
    
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data for testing state management
    _businesses = [
      const Business(
        id: '1',
        name: 'Sample Business',
        location: 'Sample Location',
        contactNumber: '+1 234 567 8900',
      ),
    ];
    
    _errorMessage = null;
    _setState(BusinessState.loaded);
  }

  // Retry loading
  Future<void> retry() async {
    await loadBusinesses(forceRefresh: true);
  }

  // Refresh data
  Future<void> refresh() async {
    await loadBusinesses(forceRefresh: true);
  }

  void _setState(BusinessState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }
}
