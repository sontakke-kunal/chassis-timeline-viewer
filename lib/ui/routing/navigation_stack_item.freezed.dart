// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'navigation_stack_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NavigationStackItem {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationStackItem);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationStackItem()';
}


}

/// @nodoc
class $NavigationStackItemCopyWith<$Res>  {
$NavigationStackItemCopyWith(NavigationStackItem _, $Res Function(NavigationStackItem) __);
}


/// Adds pattern-matching-related methods to [NavigationStackItem].
extension NavigationStackItemPatterns on NavigationStackItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NavigationStackItemSplashPage value)?  splash,TResult Function( NavigationStackItemTimelinePage value)?  timeline,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NavigationStackItemSplashPage() when splash != null:
return splash(_that);case NavigationStackItemTimelinePage() when timeline != null:
return timeline(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NavigationStackItemSplashPage value)  splash,required TResult Function( NavigationStackItemTimelinePage value)  timeline,}){
final _that = this;
switch (_that) {
case NavigationStackItemSplashPage():
return splash(_that);case NavigationStackItemTimelinePage():
return timeline(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NavigationStackItemSplashPage value)?  splash,TResult? Function( NavigationStackItemTimelinePage value)?  timeline,}){
final _that = this;
switch (_that) {
case NavigationStackItemSplashPage() when splash != null:
return splash(_that);case NavigationStackItemTimelinePage() when timeline != null:
return timeline(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  splash,TResult Function()?  timeline,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NavigationStackItemSplashPage() when splash != null:
return splash();case NavigationStackItemTimelinePage() when timeline != null:
return timeline();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  splash,required TResult Function()  timeline,}) {final _that = this;
switch (_that) {
case NavigationStackItemSplashPage():
return splash();case NavigationStackItemTimelinePage():
return timeline();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  splash,TResult? Function()?  timeline,}) {final _that = this;
switch (_that) {
case NavigationStackItemSplashPage() when splash != null:
return splash();case NavigationStackItemTimelinePage() when timeline != null:
return timeline();case _:
  return null;

}
}

}

/// @nodoc


class NavigationStackItemSplashPage implements NavigationStackItem {
  const NavigationStackItemSplashPage();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationStackItemSplashPage);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationStackItem.splash()';
}


}




/// @nodoc


class NavigationStackItemTimelinePage implements NavigationStackItem {
  const NavigationStackItemTimelinePage();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationStackItemTimelinePage);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NavigationStackItem.timeline()';
}


}




// dart format on
