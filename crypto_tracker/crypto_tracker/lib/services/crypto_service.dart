import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:crypto_tracker/models/crypto_model.dart';

class CryptoService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  Future<List<Crypto>> getTopCryptos({int limit = 100}) async {
    try {
      final response = await http.get(Uri.parse(
        '$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=$limit&page=1&sparkline=true'
      ));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Log first item for debugging
        if (data.isNotEmpty) {
          developer.log('First crypto data: ${json.encode(data[0])}');
          developer.log('Price from first crypto: ${data[0]['current_price']}');
        }

        return data.map((json) {
          final crypto = Crypto.fromJson(json);
          developer.log('Parsed crypto: ${crypto.name}, Price: ${crypto.currentPrice}');
          return crypto;
        }).toList();
      } else {
        developer.log('API Error: ${response.statusCode}', error: response.body);
        throw Exception('Failed to load cryptos: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in getTopCryptos', error: e);
      throw Exception('Error fetching data: $e');
    }
  }

  Future<Map<String, dynamic>> getCryptoDetails(String id) async {
    try {
      final response = await http.get(Uri.parse(
        '$baseUrl/coins/$id?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=true'
      ));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load crypto details');
      }
    } catch (e) {
      throw Exception('Error fetching crypto details: $e');
    }
  }
} 