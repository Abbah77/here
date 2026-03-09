import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:here/providers/auth_provider.dart';
import 'package:here/main_navigation.dart';  // Add this line

enum AuthMode { login, signup, forgot }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  
  // State
  AuthMode _authMode = AuthMode.login;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _rememberMe = false;
  
  // Animations
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final AnimationController _modeSwitchController;

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
    
    _modeSwitchController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    _modeSwitchController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    if (_authMode == mode) return;
    
    _modeSwitchController.reset();
    _modeSwitchController.forward();
    
    setState(() {
      _authMode = mode;
      _formKey.currentState?.reset();
    });
  }

  String _getTitle() {
    switch (_authMode) {
      case AuthMode.login:
        return 'Welcome Back!';
      case AuthMode.signup:
        return 'Create Account';
      case AuthMode.forgot:
        return 'Reset Password';
    }
  }

  String _getSubtitle() {
    switch (_authMode) {
      case AuthMode.login:
        return 'Sign in to continue your journey';
      case AuthMode.signup:
        return 'Join our community today';
      case AuthMode.forgot:
        return 'We\'ll send you a reset link';
    }
  }

  String _getButtonText() {
    switch (_authMode) {
      case AuthMode.login:
        return 'Login';
      case AuthMode.signup:
        return 'Sign Up';
      case AuthMode.forgot:
        return 'Send Reset Link';
    }
  }

  Future<void> _handleSubmit() async {
  if (!_formKey.currentState!.validate()) return;
  
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  bool success = false;
  
  switch (_authMode) {
    case AuthMode.login:
      success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      break;
      
    case AuthMode.signup:
      success = await authProvider.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      break;
      
    case AuthMode.forgot:
      success = await authProvider.resetPassword(
        email: _emailController.text.trim(),
      );
      if (success && mounted) {
        _showSuccessSnackBar('Reset link sent! Check your email.');
        Future.delayed(const Duration(seconds: 2), () {
          _switchMode(AuthMode.login);
        });
      }
      return;
  }
  
  if (success && mounted) {
    _showSuccessSnackBar(
      _authMode == AuthMode.login 
          ? 'Welcome back!' 
          : 'Account created successfully!'
    );
    
    // ✅ NAVIGATE DIRECTLY HERE
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }
}

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _listenToAuthState(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    if (authProvider.hasError && authProvider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        authProvider.clearError();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _listenToAuthState(context);
    final isLoading = Provider.of<AuthProvider>(context).isLoading;
    final colors = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colors.background,
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
                      _buildBackButton(colors),
                      const SizedBox(height: 32),
                      _buildHeader(colors),
                      const SizedBox(height: 40),
                      
                      _buildModeToggle(colors),
                      const SizedBox(height: 30),
                      
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _buildFormFields(isLoading, colors, key: ValueKey(_authMode)),
                      ),
                      
                      const SizedBox(height: 24),
                      _buildSubmitButton(isLoading, colors),
                      const SizedBox(height: 24),
                      _buildFooterLinks(colors),
                      
                      if (_authMode != AuthMode.forgot) ...[
                        const SizedBox(height: 32),
                        _buildDivider(colors),
                        const SizedBox(height: 24),
                        _buildSocialButtons(isLoading, colors),
                      ],
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

  Widget _buildBackButton(ColorScheme colors) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: colors.surfaceContainerHighest,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colors.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Column(
      children: [
        Text(
          _getTitle(),
          style: GoogleFonts.urbanist(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colors.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _getSubtitle(),
          textAlign: TextAlign.center,
          style: GoogleFonts.urbanist(
            color: colors.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildToggleButton('Login', AuthMode.login, colors),
          _buildToggleButton('Sign Up', AuthMode.signup, colors),
          _buildToggleButton('Forgot', AuthMode.forgot, colors),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, AuthMode mode, ColorScheme colors) {
    final isSelected = _authMode == mode;
    
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: () => _switchMode(mode),
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? colors.onPrimary : colors.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields(bool isLoading, ColorScheme colors, {required Key key}) {
    return Container(
      key: key,
      child: Column(
        children: [
          if (_authMode == AuthMode.signup) ...[
            _buildInputField(
              controller: _nameController,
              hintText: 'Full Name',
              prefixIcon: Icons.person_outline,
              colors: colors,
              enabled: !isLoading,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Name required';
                if (v.length < 2) return 'Name too short';
                return null;
              },
            ),
            const SizedBox(height: 20),
          ],
          
          _buildInputField(
            controller: _emailController,
            hintText: 'Email address',
            prefixIcon: Icons.email_outlined,
            colors: colors,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return 'Invalid email';
              }
              return null;
            },
          ),
          
          if (_authMode != AuthMode.forgot) ...[
            const SizedBox(height: 20),
            _buildInputField(
              controller: _passwordController,
              hintText: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              colors: colors,
              isPassword: true,
              isPasswordVisible: _isPasswordVisible,
              enabled: !isLoading,
              onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password required';
                if (v.length < 6) return 'Min 6 characters';
                return null;
              },
            ),
          ],
          
          if (_authMode == AuthMode.signup) ...[
            const SizedBox(height: 20),
            _buildInputField(
              controller: _confirmPasswordController,
              hintText: 'Confirm Password',
              prefixIcon: Icons.lock_outline_rounded,
              colors: colors,
              isPassword: true,
              isPasswordVisible: _isConfirmPasswordVisible,
              enabled: !isLoading,
              onTogglePassword: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirm password';
                if (v != _passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
          ],
          
          if (_authMode == AuthMode.login)
            _buildRememberRow(colors, isLoading),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required ColorScheme colors,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isPasswordVisible = false,
    bool enabled = true,
    VoidCallback? onTogglePassword,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && !isPasswordVisible,
        enabled: enabled,
        style: TextStyle(color: colors.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
          prefixIcon: Icon(prefixIcon, color: colors.onSurface, size: 20),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: colors.onSurface,
                  size: 20,
                ),
                onPressed: enabled ? onTogglePassword : null,
              ) 
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildRememberRow(ColorScheme colors, bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe, 
              activeColor: colors.primary,
              onChanged: isLoading ? null : (v) => setState(() => _rememberMe = v ?? false),
            ),
            Text('Remember me', style: TextStyle(color: colors.onSurface)),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading, ColorScheme colors) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading 
          ? CircularProgressIndicator(color: colors.onPrimary) 
          : Text(
              _getButtonText(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
      ),
    );
  }

  Widget _buildFooterLinks(ColorScheme colors) {
    if (_authMode == AuthMode.login) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Don't have an account? ", style: TextStyle(color: colors.onSurface)),
          GestureDetector(
            onTap: () => _switchMode(AuthMode.signup),
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else if (_authMode == AuthMode.signup) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Already have an account? ", style: TextStyle(color: colors.onSurface)),
          GestureDetector(
            onTap: () => _switchMode(AuthMode.login),
            child: Text(
              'Login',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Remember your password? ", style: TextStyle(color: colors.onSurface)),
          GestureDetector(
            onTap: () => _switchMode(AuthMode.login),
            child: Text(
              'Login',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDivider(ColorScheme colors) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Or Continue With', style: TextStyle(color: colors.onSurface)),
        ),
        Expanded(child: Divider(color: colors.outline)),
      ],
    );
  }

  Widget _buildSocialButtons(bool isLoading, ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _socialIcon('G', colors, isLoading),
        _socialIcon('f', colors, isLoading),
        _socialIcon('', colors, isLoading),
      ],
    );
  }

  Widget _socialIcon(String label, ColorScheme colors, bool isLoading) {
    return InkWell(
      onTap: isLoading ? null : () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label login coming soon!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surfaceContainerHighest,
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.1),
              blurRadius: 8,
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}
