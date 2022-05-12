E enumFromString<E>(List<E> values, String s, {required E orElse}) =>
    values.singleWhere((v) => v.toString().split('.').last == s,
        orElse: () => orElse);
