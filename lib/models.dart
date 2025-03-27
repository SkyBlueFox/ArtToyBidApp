import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final double buyNowPrice;
  final String type;
  final DateTime endTime;
  final List<String> images;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.buyNowPrice,
    required this.type,
    required this.endTime,
    required this.images,
    required this.category,
  });
}

class Category {
  final String name;
  final IconData icon;
  final String id;

  Category(this.name, this.icon, this.id);
}

class Bid {
  final double amount;
  final String user;
  final DateTime time;

  Bid({
    required this.amount,
    required this.user,
    required this.time,
  });
}