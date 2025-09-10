import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business.dart';

class BusinessService {
  static const String _cacheKey = 'cached_businesses';
  static const String _lastFetchKey = 'last_fetch_time';
  static const Duration _cacheExpiry = Duration(hours: 24);

  final Dio _dio;
  late SharedPreferences _prefs;

  BusinessService({Dio? dio}) : _dio = dio ?? Dio() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Business>> getBusinesses({bool forceRefresh = false}) async {
    try {
      // Check cache first unless force refresh
      if (!forceRefresh) {
        final cached = await _getCachedBusinesses();
        if (cached.isNotEmpty) {
          return cached;
        }
      }

      // Simulate network request using Dio (loading from assets)
      final response = await _fetchFromAssets();
      
      final List<dynamic> jsonList = json.decode(response.data);
      final businesses = jsonList
          .asMap()
          .entries
          .map((entry) => Business.fromJson(entry.value, index: entry.key))
          .where((business) => business.isValid)
          .toList();

      // Cache the results
      await _cacheBusinesses(businesses);
      
      return businesses;
    } catch (e) {
      // Return cached data if available on error
      final cached = await _getCachedBusinesses();
      if (cached.isNotEmpty) {
        return cached;
      }
      throw BusinessServiceException('Failed to load businesses: ${e.toString()}');
    }
  }

  Future<Response> _fetchFromAssets() async {
    // Simulate network delay and use Dio for consistency
    await Future.delayed(const Duration(seconds: 1));
    
    final jsonString = await rootBundle.loadString('assets/data/businesses.json');
    
    // Use Dio to create consistent response pattern (even with local data)
    return Response(
      data: jsonString,
      statusCode: 200,
      requestOptions: RequestOptions(path: 'assets/data/businesses.json'),
    );
  }

  Future<List<Business>> _getCachedBusinesses() async {
    try {
      await _initPrefs();
      
      final lastFetch = _prefs.getInt(_lastFetchKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Check if cache is expired
      if (now - lastFetch > _cacheExpiry.inMilliseconds) {
        return [];
      }

      final cachedJson = _prefs.getString(_cacheKey);
      if (cachedJson == null) return [];

      final List<dynamic> jsonList = json.decode(cachedJson);
      return jsonList.map((json) => Business.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _cacheBusinesses(List<Business> businesses) async {
    try {
      await _initPrefs();
      
      final jsonList = businesses.map((b) => b.toJson()).toList();
      await _prefs.setString(_cacheKey, json.encode(jsonList));
      await _prefs.setInt(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail on cache errors
    }
  }

  Future<void> clearCache() async {
    await _initPrefs();
    await _prefs.remove(_cacheKey);
    await _prefs.remove(_lastFetchKey);
  }
}

class BusinessServiceException implements Exception {
  final String message;
  BusinessServiceException(this.message);
  
  @override
  String toString() => message;
}
