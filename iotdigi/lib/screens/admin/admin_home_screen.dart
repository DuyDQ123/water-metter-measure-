import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminHomeScreen extends StatefulWidget {
  final ApiService apiService;

  const AdminHomeScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<Map<String, dynamic>> bills = [];
  bool isLoading = true;
  String? selectedUserId;
  String selectedMonth = DateTime.now().month.toString();
  String selectedYear = DateTime.now().year.toString();
  
  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => isLoading = true);
    try {
      final response = await widget.apiService.getWaterBills(
        userId: selectedUserId,
        month: selectedMonth,
        year: selectedYear,
      );
      setState(() {
        bills = List<Map<String, dynamic>>.from(response['bills']);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _updateBillStatus(int billId, String status) async {
    try {
      await widget.apiService.updateBillStatus(billId, status);
      _loadBills();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật trạng thái')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QUẢN LÝ HÓA ĐƠN'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Month Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tháng',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedMonth,
                    items: List.generate(12, (index) => index + 1)
                        .map((month) => DropdownMenuItem(
                              value: month.toString(),
                              child: Text(month.toString()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                        _loadBills();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Year Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Năm',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedYear,
                    items: List.generate(5, (index) => DateTime.now().year - index)
                        .map((year) => DropdownMenuItem(
                              value: year.toString(),
                              child: Text(year.toString()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                        _loadBills();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bills List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : bills.isEmpty
                    ? const Center(child: Text('Không có hóa đơn nào'))
                    : ListView.builder(
                        itemCount: bills.length,
                        padding: const EdgeInsets.all(8.0),
                        itemBuilder: (context, index) {
                          final bill = bills[index];
                          return Card(
                            child: ListTile(
                              title: Text('Người dùng: ${bill['user_name']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Lượng nước: ${bill['usage_amount']} m³'),
                                  Text(
                                    'Số tiền: ${bill['bill_amount']} đ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  Text(
                                    'Trạng thái: ${bill['status'] == 'paid' ? 'Đã thanh toán' : 'Chưa thanh toán'}',
                                    style: TextStyle(
                                      color: bill['status'] == 'paid'
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) =>
                                    _updateBillStatus(bill['id'], value),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'paid',
                                    child: Text('Đánh dấu đã thanh toán'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'pending',
                                    child: Text('Đánh dấu chưa thanh toán'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}