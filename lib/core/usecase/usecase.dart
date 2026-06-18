/// A base contract for all use cases.
///
/// [T] Represents the return type
/// [P] Represents the input parameter
abstract class UseCase<T, P> {
  Future<T> call({P? params});
}