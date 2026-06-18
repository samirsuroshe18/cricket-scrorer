class Either<R, F> {
  final R? _resultValue;

  final F? _fallbackValue;

  Either.result(R result) : _resultValue = result, _fallbackValue = null;

  Either.fallback(F fallback) : _resultValue = null, _fallbackValue = fallback;

  bool get isResult => _resultValue != null;

  bool get isFallback => _resultValue == null && _fallbackValue != null;

  R get result => _resultValue!;

  F get fallback => _fallbackValue!;

  C map<C>(C Function(R) ifResult, C Function(F) ifFallback) {
    if (isResult) {
      return ifResult(_resultValue as R);
    } else {
      return ifFallback(_fallbackValue as F);
    }
  }

  C mapResult<C>(C Function(R) ifResult) => ifResult(_resultValue as R);

  C mapFallback<C>(C Function(F) ifFallback) => ifFallback(_fallbackValue as F);
}
