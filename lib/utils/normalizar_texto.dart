/// Normaliza un texto para comparaciones:
/// - Quita espacios al inicio y final
/// - Convierte a minúsculas
/// - Quita acentos y diéresis
String normalizarTexto(String texto) {
  const conAcentos = 'áéíóúüñÁÉÍÓÚÜÑàèìòùÀÈÌÒÙäëïöÄËÏÖ';
  const sinAcentos = 'aeiouunAEIOUUNaeiouAEIOUaeioAEIO';

  String resultado = texto.trim().toLowerCase();

  for (int i = 0; i < conAcentos.length; i++) {
    resultado = resultado.replaceAll(conAcentos[i], sinAcentos[i]);
  }

  return resultado;
}