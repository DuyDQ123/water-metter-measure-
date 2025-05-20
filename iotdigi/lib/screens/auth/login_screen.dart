import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../user/home_screen.dart';
import '../admin/admin_home_screen.dart';

class LoginScreen extends StatelessWidget {
  final ApiService _apiService = ApiService();
  
  LoginScreen({super.key});

  void _showCodeEntryDialog(BuildContext context, bool isUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CodeEntryDialog(isUser: isUser, apiService: _apiService);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade300,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.home_work_rounded,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 30),
                const Text(
                  'CHỌN VAI TRÒ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 50),
                _buildRoleButton(
                  context: context,
                  isUser: true,
                  icon: Icons.person,
                  label: 'NGƯỜI DÙNG',
                  color: Colors.green,
                ),
                const SizedBox(height: 20),
                _buildRoleButton(
                  context: context,
                  isUser: false,
                  icon: Icons.admin_panel_settings,
                  label: 'QUẢN TRỊ',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required bool isUser,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(220, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      onPressed: () => _showCodeEntryDialog(context, isUser),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CodeEntryDialog extends StatefulWidget {
  final bool isUser;
  final ApiService apiService;

  const CodeEntryDialog({
    super.key,
    required this.isUser,
    required this.apiService,
  });

  @override
  State<CodeEntryDialog> createState() => _CodeEntryDialogState();
}

class _CodeEntryDialogState extends State<CodeEntryDialog> {
  final _codeController = TextEditingController();
  String? _errorText;
  bool _isValidating = false;

  Future<void> _validateCode() async {
    if (_codeController.text.isEmpty) {
      setState(() {
        _errorText = 'Vui lòng nhập mã truy cập';
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _errorText = null;
    });

    try {
      final response = await widget.apiService.validateAccessCode(
        _codeController.text,
        widget.isUser,
      );

      if (mounted) {
        if (response['valid'] == true) {
          if (widget.isUser) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(apiService: widget.apiService),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => AdminHomeScreen(apiService: widget.apiService),
              ),
            );
          }
        } else {
          setState(() {
            _errorText = 'Mã truy cập không hợp lệ';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = 'Lỗi xác thực mã truy cập';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isUser ? 'NHẬP MÃ NGƯỜI DÙNG' : 'NHẬP MÃ QUẢN TRỊ',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: 'Mã truy cập',
              errorText: _errorText,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.key),
            ),
            obscureText: true,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            enabled: !_isValidating,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isValidating ? null : () => Navigator.of(context).pop(),
          child: const Text('HỦY'),
        ),
        ElevatedButton(
          onPressed: _isValidating ? null : _validateCode,
          child: _isValidating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('XÁC NHẬN'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}