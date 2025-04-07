import 'dart:convert';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../models/looking_for_item_model.dart';
import 'looking_for_remote_data_source.dart';

/// Implementation of the remote data source for the "Looking For" feature
class LookingForRemoteDataSourceImpl implements LookingForRemoteDataSource {
  final ApiService apiService;

  LookingForRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<LookingForItemModel>> getLookingForItems() async {
    try {
      final response = await apiService.get('/looking-for-items?isActive=true');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => LookingForItemModel.fromJson(json))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<LookingForItemModel>> getUserLookingForItems(String userId) async {
    try {
      final response = await apiService.get('/looking-for-items?userId=$userId');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => LookingForItemModel.fromJson(json))
            .toList();
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<LookingForItemModel> getLookingForItemById(String id) async {
    try {
      final response = await apiService.get('/looking-for-items/$id');
      
      if (response.statusCode == 200) {
        return LookingForItemModel.fromJson(json.decode(response.body));
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<LookingForItemModel> createLookingForItem(LookingForItemModel item) async {
    try {
      final response = await apiService.post(
        '/looking-for-items',
        body: json.encode(item.toJson()),
      );
      
      if (response.statusCode == 201) {
        return LookingForItemModel.fromJson(json.decode(response.body));
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<LookingForItemModel> updateLookingForItem(LookingForItemModel item) async {
    try {
      final response = await apiService.put(
        '/looking-for-items/${item.id}',
        body: json.encode(item.toJson()),
      );
      
      if (response.statusCode == 200) {
        return LookingForItemModel.fromJson(json.decode(response.body));
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<bool> deleteLookingForItem(String id) async {
    try {
      final response = await apiService.delete('/looking-for-items/$id');
      
      if (response.statusCode == 204) {
        return true;
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<int> checkAndUpdateExpiredItems() async {
    try {
      final response = await apiService.post('/looking-for-items/check-expired');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['expiredCount'] as int;
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}
