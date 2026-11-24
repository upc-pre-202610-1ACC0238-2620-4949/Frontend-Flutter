import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../common/api_config.dart';
import '../../common/session.dart';
import '../../shared/presentation/app_theme.dart';
import '../../shared/presentation/main_shell.dart';
import '../../shared/presentation/terms_page.dart';
import '../data/auth_service.dart';

/// Registro de una cuenta nueva para cada segmento: hogar o restaurante.
/// Hay que aceptar los Terminos y Condiciones para crear la cuenta.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _service = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _districtController = TextEditingController();
  final _passwordController = TextEditingController();

  String _role = 'HomeOwner';
  bool _acceptedTerms = false;
  bool _loading = false;
  String? _error;

  bool get _isRestaurant => _role == 'RestaurantAdministrator';

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _businessController,
      _emailController,
      _phoneController,
      _districtController,
      _passwordController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _openTerms() => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPage()));

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      setState(() => _error = 'Debes aceptar los Términos y condiciones.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final account = await _service.signUp(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _role,
        businessName: _isRestaurant ? _businessController.text.trim() : null,
        phone: _phoneController.text.trim(),
        district: _districtController.text.trim(),
      );
      await Session.signIn(account);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
    } on ApiException catch (e) {
      setState(() => _error = e.statusCode == 409 ? 'Ese correo ya está registrado.' : 'Error del servidor (${e.statusCode}).');
    } catch (_) {
      setState(() => _error = 'No se pudo conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _required(String? value) => (value ?? '').trim().isEmpty ? 'Campo obligatorio' : null;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(10));
    InputDecoration field(String label, [String? hint]) => InputDecoration(labelText: label, hintText: hint, border: border);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              const Text('¿Dónde usarás SmartGas?', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'HomeOwner', label: Text('Hogar'), icon: Icon(Icons.home_outlined)),
                  ButtonSegment(value: 'RestaurantAdministrator', label: Text('Restaurante'), icon: Icon(Icons.restaurant)),
                ],
                selected: {_role},
                onSelectionChanged: (value) => setState(() => _role = value.first),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: field('Nombre completo'),
                validator: _required,
              ),
              if (_isRestaurant) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _businessController,
                  textCapitalization: TextCapitalization.words,
                  decoration: field('Nombre del restaurante'),
                  validator: _required,
                ),
              ],
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: field('Correo'),
                validator: (value) => (value ?? '').contains('@') ? null : 'Ingresa un correo válido',
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: field('Teléfono', '987 654 321'),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _districtController,
                textCapitalization: TextCapitalization.words,
                decoration: field('Distrito', 'Miraflores'),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                decoration: field('Contraseña'),
                validator: (value) => (value ?? '').length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(value: _acceptedTerms, onChanged: (value) => setState(() => _acceptedTerms = value ?? false)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          text: 'Acepto los ',
                          children: [
                            TextSpan(
                              text: 'Términos y condiciones',
                              style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w600),
                              recognizer: TapGestureRecognizer()..onTap = _openTerms,
                            ),
                            const TextSpan(text: ' y la Política de privacidad de SmartGas.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(color: AppColors.red)),
                ),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(shape: const StadiumBorder()),
                  onPressed: _loading || !_acceptedTerms ? null : _register,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Crear cuenta', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
