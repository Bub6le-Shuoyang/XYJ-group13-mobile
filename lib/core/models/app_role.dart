import 'package:flutter/material.dart';

enum AppRole {
  villager('村民用户', '取件 / 查件', Icons.person_pin_circle, Colors.green),
  courier('配送员', '抢单 / 派送', Icons.delivery_dining, Colors.orange),
  admin('站点管理员', '入库 / 出库', Icons.store_mall_directory, Colors.blue);

  const AppRole(this.title, this.subtitle, this.icon, this.color);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
