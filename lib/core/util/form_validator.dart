class FormValidator {
  static String? validateId(String? noRegistrasi, bool isOrtu) {
    String? tempNIK = noRegistrasi?.replaceAll(' ', '');
    if (tempNIK?.isEmpty ?? true) {
      return (isOrtu)
          ? 'Mohon isi No Registrasi putra/putri anda'
          : 'Isi dulu No Registrasi kamu ya sobat';
    }

    bool isNumeric =
        double.tryParse(tempNIK!) != null || int.tryParse(tempNIK) != null;
    if (!isNumeric) return 'Format No Registrasi harus angka';

    if (tempNIK.length < 11) return 'No Registrasi minimal 11 digit';

    return null;
  }

  static String? validateEmail(String? email) {
    String pattern =
        r"^(([^<>()[\]\\.,;:\s@\']+(\.[^<>()[\]\\.,;:\s@\']+)*)|(\'.+\'))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$";
    RegExp regExp = RegExp(pattern);

    if (email?.isEmpty ?? true) return 'Mohon isi E-Mail anda';
    if (!regExp.hasMatch(email!)) return 'Format E-Mail tidak valid';

    return null;
  }

  static String? validatePhoneNumber(String? phoneNumber, bool isOrtu) {
    if (phoneNumber?.isEmpty ?? true) {
      return (isOrtu)
          ? 'Mohon isi nomor handphone anda'
          : 'isi dulu nomor handphone kamu ya sobat';
    }

    bool isNumeric = double.tryParse(phoneNumber!) != null ||
        int.tryParse(phoneNumber) != null;

    if (!isNumeric) return 'Format nomor handphone harus angka';

    if (phoneNumber.length < 9) return 'Nomor Handphone minimal 9 digit';

    String expression = r"^\+?[08][0-9]{7,12}$";
    RegExp regExp = RegExp(expression);
    if (!regExp.hasMatch(phoneNumber)) {
      return "Format nomor hp tidak valid. ex: 08xxx atau 8xxx";
    }

    return null;
  }

  static String? validateNamaSiswa(String? namaLengkap) {
    return (namaLengkap?.isEmpty ?? true)
        ? 'Isi nama lengkap kamu dulu ya Sobat'
        : null;
  }
}
