class Utils {
  static nonEmptyValidator(value) {
    return value.isEmpty ? 'Campo Obrigatório' : null;
  }
}
