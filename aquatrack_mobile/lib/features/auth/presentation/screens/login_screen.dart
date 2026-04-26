import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../../home/presentation/screens/role_gate_screen.dart';
import '../widgets/login_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final AuthProvider authProvider = context.read<AuthProvider>();
    final bool isSuccess = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (isSuccess) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const RoleGateScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login gagal.'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 34),
                    child: LoginHeader(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Text(
                              'Selamat Datang',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Masuk sebagai Admin / Petugas untuk mengelola\nlayanan air digital.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF7C8C9B),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          const Text(
                            'Email atau Username',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Masukkan kredensial Anda',
                              hintStyle: const TextStyle(
                                color: Color(0xFFB2BFCC),
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                size: 18,
                                color: Color(0xFF96A4B2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7FAFD),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E7EF),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: <Widget>[
                              const Expanded(
                                child: Text(
                                  'Kata Sandi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Lupa sandi?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Masukkan kata sandi',
                              hintStyle: const TextStyle(
                                color: Color(0xFFB2BFCC),
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                size: 18,
                                color: Color(0xFF96A4B2),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: const Color(0xFF96A4B2),
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7FAFD),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E7EF),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    blurRadius: 12,
                                    color: Color(0x2A0A84CF),
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _onSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'Masuk Sekarang',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Icon(Icons.arrow_forward, size: 16),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 34,
                                  child: Divider(
                                    color: Color(0xFFD8E0EA),
                                    thickness: 1,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Butuh bantuan akses?',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFB6C2CF),
                                  ),
                                ),
                                SizedBox(width: 10),
                                SizedBox(
                                  width: 34,
                                  child: Divider(
                                    color: Color(0xFFD8E0EA),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFD8E1EB),
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              icon: const Icon(
                                Icons.support_agent_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              label: const Text(
                                'Hubungi Support',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Center(
                            child: Text(
                              '© SECURE ADMIN ACCESS',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
