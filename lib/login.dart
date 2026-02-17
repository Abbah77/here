import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MyNavigationBar(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  void _listenToAuthState(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    if (authProvider.hasError && authProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(authProvider.errorMessage!);
        authProvider.clearError();
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: Colors.orange.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _listenToAuthState(context);
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBackButton(),
                      const SizedBox(height: 32),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildInputField(
                        controller: _emailController,
                        hintText: 'Email address',
                        prefixIcon: Icons.email_outlined,
                        enabled: !isLoading,
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        enabled: !isLoading,
                        onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                      ),
                      _buildRememberRow(isLoading),
                      const SizedBox(height: 32),
                      _buildLoginButton(isLoading),
                      const SizedBox(height: 24),
                      _buildSignUpLink(isLoading),
                      const SizedBox(height: 32),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildSocialButtons(isLoading),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text('Welcome Back!', style: GoogleFonts.urbanist(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Access your account securely.', 
          textAlign: TextAlign.center,
          style: GoogleFonts.urbanist(color: Colors.grey.shade600, fontSize: 16)),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    bool enabled = true,
    VoidCallback? onTogglePassword,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, size: 20),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, size: 20),
                onPressed: onTogglePassword,
              ) 
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildRememberRow(bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe, 
              activeColor: Colors.orange,
              onChanged: (v) => setState(() => _rememberMe = v ?? false)
            ),
            const Text('Remember me'),
          ],
        ),
        TextButton(
          onPressed: () => _showComingSoon('Forgot password'),
          child: const Text('Forgot Password?', style: TextStyle(color: Colors.orange)),
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSignUpLink(bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        GestureDetector(
          onTap: () => _showComingSoon('Sign up'),
          child: const Text('Sign Up', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Or Continue With')),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons(bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _socialIcon('G', Colors.red, isLoading),
        _socialIcon('f', Colors.blue, isLoading),
        _socialIcon('', Colors.black, isLoading),
      ],
    );
  }

  Widget _socialIcon(String label, Color color, bool isLoading) {
    return InkWell(
      onTap: isLoading ? null : () => _showComingSoon('$label login'),
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}
