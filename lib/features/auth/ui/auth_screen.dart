import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import 'widgets/biometric_setup_dialog.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  // Focus nodes for auto-focus
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  
  bool _isLoading = false;
  String? _errorMessage;
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  
  bool _canUseBiometric = false;

  bool _isDeviceSupported = false;
  bool _hasSavedCredentials = false;
  String _biometricName = 'Biométrie';



  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signUp(
        email: email,
        password: password,
        name: _nameController.text.trim(),
      );

      if (user != null && mounted) {
        // Check if biometric is available
        final biometricService = ref.read(biometricAuthServiceProvider);
        final canUseBiometric = await biometricService.checkBiometricAvailability();
        
        if (canUseBiometric) {
          // Show biometric setup dialog
          final enabled = await showDialog<bool>(
            context: context,
            builder: (context) => BiometricSetupDialog(
              email: email,
              password: password,
            ),
          );
        }
        
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      setState(() {
        // Better error messages
        if (e.toString().contains('email rate limit')) {
          _errorMessage = 'Trop de tentatives. Attendez quelques minutes.';
        } else if (e.toString().contains('email')) {
          _errorMessage = 'Cet email est déjà utilisé';
        } else if (e.toString().contains('password')) {
          _errorMessage = 'Mot de passe trop faible (min 6 caractères)';
        } else if (e.toString().contains('not confirmed')) {
           _errorMessage = 'Veuillez confirmer votre email avant de vous connecter.';
           // Switch to SignIn tab
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) _tabController.animateTo(0);
            });
        } else {
          _errorMessage = 'Erreur lors de la création du compte';
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signIn(
        email: email,
        password: password,
      );

      if (user != null && mounted) {
        // Check if biometric is available and not yet enabled
        final secureStorage = ref.read(secureStorageServiceProvider);
        final biometricEnabled = await secureStorage.isBiometricEnabled();
        
        if (!biometricEnabled) {
          final biometricService = ref.read(biometricAuthServiceProvider);
          final canUseBiometric = await biometricService.checkBiometricAvailability();
          
          if (canUseBiometric) {
            // Show biometric setup dialog
            await showDialog<bool>(
              context: context,
              builder: (context) => BiometricSetupDialog(
                email: email,
                password: password,
              ),
            );
          }
        }
        
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      setState(() {
        // Better error messages
        if (e.toString().contains('Invalid login')) {
          _errorMessage = 'Email ou mot de passe incorrect';
        } else if (e.toString().contains('email_not_confirmed') || e.toString().contains('Email not confirmed')) {
          _errorMessage = 'Email non confirmé. Vérifiez votre boîte de réception.';
        } else if (e.toString().contains('email')) {
          _errorMessage = 'Format d\'email invalide';
        } else if (e.toString().contains('rate limit')) {
          _errorMessage = 'Trop de tentatives. Réessayez plus tard.';
        } else {
          _errorMessage = 'Erreur de connexion. Vérifiez vos identifiants.';
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Listen to tab changes to update switcher UI
    _tabController.addListener(() {
      setState(() {});
    });
    
    // Listen to password changes for strength indicator
    _passwordController.addListener(_updatePasswordStrength);
    
    _checkBiometricAvailability();
  }
  
  Future<void> _checkBiometricAvailability() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    final biometricService = ref.read(biometricAuthServiceProvider);
    
    final hasCredentials = await secureStorage.hasSavedCredentials();
    final isSupported = await biometricService.isDeviceSupported();
    final name = await biometricService.getBiometricDisplayName();
    
    if (mounted) {
      setState(() {
        _hasSavedCredentials = hasCredentials;
        _isDeviceSupported = isSupported;
        _biometricName = name;
        _canUseBiometric = hasCredentials && isSupported;
      });
    }
  }
  
  void _updatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;
    String text = '';
    
    if (password.isEmpty) {
      strength = 0.0;
      text = '';
    } else if (password.length < 6) {
      strength = 0.25;
      text = 'Trop faible';
    } else if (password.length < 8) {
      strength = 0.5;
      text = 'Faible';
    } else if (password.length < 12 && password.contains(RegExp(r'[0-9]'))) {
      strength = 0.75;
      text = 'Bon';
    } else if (password.length >= 12 && 
               password.contains(RegExp(r'[0-9]')) && 
               password.contains(RegExp(r'[A-Z]'))) {
      strength = 1.0;
      text = 'Excellent';
    } else {
      strength = 0.6;
      text = 'Moyen';
    }
    
    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = text;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Logo & Title
              Center(
                child: Column(
                  children: [
                    Text(
                      '🧠',
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CoachFlow',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connectez-vous pour partager vos conversations',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Custom Segmented Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _tabController.animateTo(0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _tabController.index == 0
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _tabController.index == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            AppLocalizations.of(context).signIn,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: _tabController.index == 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: _tabController.index == 0
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _tabController.animateTo(1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _tabController.index == 1
                                ? Colors.black
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _tabController.index == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            AppLocalizations.of(context).signUp,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: _tabController.index == 1
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: _tabController.index == 1
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // TabBarView with height constraint
              SizedBox(
                height: 450,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSignInForm(),
                    _buildSignUpForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _signInFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(LucideIcons.mail),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return AppLocalizations.of(context).emailRequired;
              if (!value.contains('@')) return AppLocalizations.of(context).emailInvalid;
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(LucideIcons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) return AppLocalizations.of(context).passwordRequired;
              if (value.length < 6) return AppLocalizations.of(context).atLeast6Chars;
              return null;
            },
          ),
          
          // Old button removed
          const SizedBox(height: 8),
          

          
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertCircle, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                      ),
                    )
                  : Text(
                      'Se connecter',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(
              'Retour sans compte',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),

          if (_isDeviceSupported) ...[
            const SizedBox(height: 48), // Add more space to push it down
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                  border: Border.all(
                    color: isDark ? Colors.white : Colors.black,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    if (_hasSavedCredentials) {
                      context.push('/biometric-login');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Veuillez vous connecter une première fois pour activer la biométrie',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    _getBiometricIcon(_biometricName),
                    size: 32,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  tooltip: 'Se connecter avec $_biometricName',
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nom',
              prefixIcon: const Icon(LucideIcons.user),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Nom requis';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(LucideIcons.mail),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email requis';
              if (!value.contains('@')) return 'Email invalide';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(LucideIcons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Mot de passe requis';
              if (value.length < 6) return 'Au moins 6 caractères';
              return null;
            },
          ),
          
          // Password strength indicator
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _passwordStrength,
                      minHeight: 4,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _passwordStrength < 0.5
                            ? Colors.red
                            : _passwordStrength < 0.75
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _passwordStrengthText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _passwordStrength < 0.5
                        ? Colors.red
                        : _passwordStrength < 0.75
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
              ],
            ),
          ],
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertCircle, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                      ),
                    )
                  : Text(
                      'Créer mon compte',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text(
              'Retour sans compte',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  IconData _getBiometricIcon(String name) {
    if (name.toLowerCase().contains('face')) return LucideIcons.scanFace;
    if (name.toLowerCase().contains('iris')) return LucideIcons.eye;
    return LucideIcons.fingerprint;
  }
}
