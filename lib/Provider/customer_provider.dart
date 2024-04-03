import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Customers/Model/customer_model.dart';
import 'package:mobile_pos/repository/customer_repo.dart';
import 'package:nb_utils/nb_utils.dart';

CustomerRepo customerRepo = CustomerRepo();
final customerProvider = FutureProvider.autoDispose<List<CustomerModel>>(
    (ref) => customerRepo.getAllCustomers());

final customerNotifier = ChangeNotifierProvider((ref) => CustomerNotifier());

class CustomerNotifier extends ChangeNotifier {
  getlengthofduelistcustomer(List<CustomerModel> customer) {
    var customerlist =
        customer.where((element) => element.dueAmount.toInt() > 0).toList();
    return customerlist.length;
  }
}
