abstract final class AuthValidation {
  static final RegExp _emailPattern = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  );

  static String? displayName(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return 'Ingresa tu nombre.';
    }
    if (normalized.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres.';
    }
    return null;
  }

  static String? email(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }
    if (!_emailPattern.hasMatch(normalized)) {
      return 'Ingresa un correo válido, por ejemplo nombre@dominio.com.';
    }
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) {
      return 'Ingresa tu contraseña.';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    return null;
  }
}
