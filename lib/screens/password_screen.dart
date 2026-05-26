import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';

enum PasswordMode { set, confirm, confirmForEdit, confirmForRemove, lockScreen }

class PasswordScreen extends StatefulWidget {
  final PasswordMode mode;
  final String? firstPass; // اضافه شدن متغیر برای دریافت رمز اول

  const PasswordScreen({Key? key, required this.mode, this.firstPass}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  String _enteredPass = '';
  late String _firstPass;
  bool _isLoading = false;
  String _title = '';

  @override
  void initState() {
    super.initState();
    // دریافت رمز اول از ویجت قبلی (اگر وجود داشت)
    _firstPass = widget.firstPass ?? '';
    _setTitle();
  }

  void _setTitle() {
    if (widget.mode == PasswordMode.set) _title = 'تنظیم رمز عبور';
    else if (widget.mode == PasswordMode.confirm) _title = 'تایید رمز عبور';
    else if (widget.mode == PasswordMode.confirmForEdit) _title = 'وارد کردن رمز فعلی';
    else if (widget.mode == PasswordMode.confirmForRemove) _title = 'تایید برای حذف رمز';
    else if (widget.mode == PasswordMode.lockScreen) _title = 'رمز عبور';
  }

  void _onKeyTap(String value) {
    if (_enteredPass.length < 6) {
      setState(() => _enteredPass += value);
      if (_enteredPass.length == 6) _handleFullPass();
    }
  }

  void _onDeleteTap() {
    if (_enteredPass.isNotEmpty) setState(() => _enteredPass = _enteredPass.substring(0, _enteredPass.length - 1));
  }

  void _handleFullPass() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPass = prefs.getString('appPassword');

    if (widget.mode == PasswordMode.set) {
      _firstPass = _enteredPass;
      setState(() => _enteredPass = '');
      // ارسال رمز اول به صفحه تایید از طریق آرگومان firstPass
      Future.delayed(const Duration(milliseconds: 300), () {
        if(mounted) Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => PasswordScreen(mode: PasswordMode.confirm, firstPass: _firstPass))
        );
      });
    } 
    else if (widget.mode == PasswordMode.confirm) {
      if (_firstPass == _enteredPass) {
        await prefs.setString('appPassword', _enteredPass);
        await prefs.setBool('hasPassword', true);
        _showAlertSuccess('رمز با موفقیت ثبت شد');
      } else {
        _showAlertError('رمز تطابق ندارد');
        setState(() => _enteredPass = '');
      }
    }
    else if (widget.mode == PasswordMode.confirmForEdit) {
      if (_enteredPass == savedPass) {
        if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PasswordScreen(mode: PasswordMode.set)));
      } else {
        _showAlertError('رمز اشتباه است');
        setState(() => _enteredPass = '');
      }
    }
    else if (widget.mode == PasswordMode.confirmForRemove) {
      if (_enteredPass == savedPass) {
        await prefs.remove('appPassword');
        await prefs.setBool('hasPassword', false);
        _showAlertSuccess('رمز با موفقیت حذف شد');
      } else {
        _showAlertError('رمز اشتباه است');
        setState(() => _enteredPass = '');
      }
    }
    else if (widget.mode == PasswordMode.lockScreen) {
      if (_enteredPass == savedPass) {
        Navigator.pop(context, true);
      } else {
        _showAlertError('رمز اشتباه است');
        setState(() => _enteredPass = '');
      }
    }
  }

  // الرت شناور سبز (موفقیت)
  void _showAlertSuccess(String msg) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, left: 16, right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)]),
            child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: 'Peyda', fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry?.remove();
      Navigator.pop(context); // بستن صفحه بعد از نمایش الرت
    });
  }

  // الرت شناور قرمز (خطا)
  void _showAlertError(String msg) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, left: 16, right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)]),
            child: Text(msg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: 'Peyda', fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry?.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: widget.mode == PasswordMode.lockScreen 
          ? const SizedBox.shrink() 
          : IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
        title: Text(_title, style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Peyda', fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          const Spacer(),
          _isLoading 
            ? const CircularProgressIndicator(color: AppColors.primary)
            : const Icon(Icons.lock_outline, size: 60, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            widget.mode == PasswordMode.set && _firstPass.isEmpty ? 'رمز عبور جدید خود را وارد کنید' : 'رمز عبور را تایید کنید',
            style: const TextStyle(fontFamily: 'Peyda', color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _buildDots(),
          const Spacer(),
          // قرار دادن کیبورد در Directionality LTR تا برعکس نشود
          Directionality(
            textDirection: TextDirection.ltr,
            child: _buildKeyboard(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        bool isActive = index < _enteredPass.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: isActive ? AppColors.primary : Colors.grey, width: 2),
          ),
        );
      }),
    );
  }

  Widget _buildKeyboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(children: [ _buildKey('1'), _buildKey('2'), _buildKey('3') ]),
          Row(children: [ _buildKey('4'), _buildKey('5'), _buildKey('6') ]),
          Row(children: [ _buildKey('7'), _buildKey('8'), _buildKey('9') ]),
          Row(children: [ _buildDeleteText(), _buildKey('0'), _buildDeleteIcon() ]),
        ],
      ),
    );
  }

  Widget _buildKey(String num) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onKeyTap(num),
        child: Container(
          margin: const EdgeInsets.all(6), height: 50,
          decoration: BoxDecoration(color: AppColors.mattedGrey, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(num, style: const TextStyle(fontSize: 22, fontFamily: 'Peyda', fontWeight: FontWeight.w700))),
        ),
      ),
    );
  }

  Widget _buildDeleteIcon() {
    return Expanded(
      child: GestureDetector(
        onTap: _onDeleteTap,
        child: Container(
          margin: const EdgeInsets.all(6), height: 50,
          decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Center(child: Icon(Icons.backspace_outlined, color: AppColors.danger, size: 20)),
        ),
      ),
    );
  }

  Widget _buildDeleteText() {
    return Expanded(
      child: GestureDetector(
        onTap: _onDeleteTap,
        child: Container(
          margin: const EdgeInsets.all(6), height: 50,
          decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Center(child: Text('Clear', style: TextStyle(color: AppColors.danger, fontFamily: 'Peyda', fontSize: 12, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}