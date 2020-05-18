typedef NotNull<T> = T; // Not Null
typedef NN<T> = T; // Not Null
typedef Nullable<T> = T?; // Nullable
typedef N<T> = T?; // Nullable
typedef Int = NonNull<int>;
typedef Bool = NonNull<bool>;
typedef IntList = NonNull<List<Int>>;
typedef Double = NN<Double>;