import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Modèle de citation
class Quote {
  final String content;
  final String author;

  Quote({required this.content, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      content: json['content'], // Clé correcte pour quotable.io
      author: json['author'],
    );
  }
}

// Service qui récupère une citation
class QuoteService {
  final _baseUrl = 'https://zenquotes.io/api/random';

  Future<Quote> fetchRandomQuote() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // zenquotes.io renvoie une liste, on prend le premier élément
      final first = data[0];

      return Quote(
        content: first['q'],
        author: first['a'],
      );
    } else {
      throw Exception('Failed to load quote - status ${response.statusCode}');
    }
  }
}

