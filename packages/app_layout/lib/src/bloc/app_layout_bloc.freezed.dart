// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_layout_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
mixin _$AppLayoutEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLayoutEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppLayoutEvent()';
}


}

class $AppLayoutEventCopyWith<$Res>  {
$AppLayoutEventCopyWith(AppLayoutEvent _, $Res Function(AppLayoutEvent) __);
}


extension AppLayoutEventPatterns on AppLayoutEvent {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _RouteChanged value)?  routeChanged,TResult Function( _TabChanged value)?  tabChanged,TResult Function( _ToggleBottomBar value)?  toggleBottomBar,TResult Function( _ToggleHeader value)?  toggleHeader,TResult Function( _TogglePrimaryAction value)?  togglePrimaryAction,TResult Function( _TogglePrimaryActionExpanded value)?  togglePrimaryActionExpanded,TResult Function( _ScrollToTop value)?  scrollToTop,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _RouteChanged() when routeChanged != null:
return routeChanged(_that);case _TabChanged() when tabChanged != null:
return tabChanged(_that);case _ToggleBottomBar() when toggleBottomBar != null:
return toggleBottomBar(_that);case _ToggleHeader() when toggleHeader != null:
return toggleHeader(_that);case _TogglePrimaryAction() when togglePrimaryAction != null:
return togglePrimaryAction(_that);case _TogglePrimaryActionExpanded() when togglePrimaryActionExpanded != null:
return togglePrimaryActionExpanded(_that);case _ScrollToTop() when scrollToTop != null:
return scrollToTop(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _RouteChanged value)  routeChanged,required TResult Function( _TabChanged value)  tabChanged,required TResult Function( _ToggleBottomBar value)  toggleBottomBar,required TResult Function( _ToggleHeader value)  toggleHeader,required TResult Function( _TogglePrimaryAction value)  togglePrimaryAction,required TResult Function( _TogglePrimaryActionExpanded value)  togglePrimaryActionExpanded,required TResult Function( _ScrollToTop value)  scrollToTop,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _RouteChanged():
return routeChanged(_that);case _TabChanged():
return tabChanged(_that);case _ToggleBottomBar():
return toggleBottomBar(_that);case _ToggleHeader():
return toggleHeader(_that);case _TogglePrimaryAction():
return togglePrimaryAction(_that);case _TogglePrimaryActionExpanded():
return togglePrimaryActionExpanded(_that);case _ScrollToTop():
return scrollToTop(_that);}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _RouteChanged value)?  routeChanged,TResult? Function( _TabChanged value)?  tabChanged,TResult? Function( _ToggleBottomBar value)?  toggleBottomBar,TResult? Function( _ToggleHeader value)?  toggleHeader,TResult? Function( _TogglePrimaryAction value)?  togglePrimaryAction,TResult? Function( _TogglePrimaryActionExpanded value)?  togglePrimaryActionExpanded,TResult? Function( _ScrollToTop value)?  scrollToTop,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _RouteChanged() when routeChanged != null:
return routeChanged(_that);case _TabChanged() when tabChanged != null:
return tabChanged(_that);case _ToggleBottomBar() when toggleBottomBar != null:
return toggleBottomBar(_that);case _ToggleHeader() when toggleHeader != null:
return toggleHeader(_that);case _TogglePrimaryAction() when togglePrimaryAction != null:
return togglePrimaryAction(_that);case _TogglePrimaryActionExpanded() when togglePrimaryActionExpanded != null:
return togglePrimaryActionExpanded(_that);case _ScrollToTop() when scrollToTop != null:
return scrollToTop(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<AppLayoutTabConfig> tabs)?  started,TResult Function( String location,  AppLayoutChromeConfig chrome)?  routeChanged,TResult Function( int displayIndex,  int branchIndex,  String tabId)?  tabChanged,TResult Function( bool show)?  toggleBottomBar,TResult Function( bool show)?  toggleHeader,TResult Function( bool show)?  togglePrimaryAction,TResult Function( bool expanded)?  togglePrimaryActionExpanded,TResult Function( String tabId)?  scrollToTop,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that.tabs);case _RouteChanged() when routeChanged != null:
return routeChanged(_that.location,_that.chrome);case _TabChanged() when tabChanged != null:
return tabChanged(_that.displayIndex,_that.branchIndex,_that.tabId);case _ToggleBottomBar() when toggleBottomBar != null:
return toggleBottomBar(_that.show);case _ToggleHeader() when toggleHeader != null:
return toggleHeader(_that.show);case _TogglePrimaryAction() when togglePrimaryAction != null:
return togglePrimaryAction(_that.show);case _TogglePrimaryActionExpanded() when togglePrimaryActionExpanded != null:
return togglePrimaryActionExpanded(_that.expanded);case _ScrollToTop() when scrollToTop != null:
return scrollToTop(_that.tabId);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<AppLayoutTabConfig> tabs)  started,required TResult Function( String location,  AppLayoutChromeConfig chrome)  routeChanged,required TResult Function( int displayIndex,  int branchIndex,  String tabId)  tabChanged,required TResult Function( bool show)  toggleBottomBar,required TResult Function( bool show)  toggleHeader,required TResult Function( bool show)  togglePrimaryAction,required TResult Function( bool expanded)  togglePrimaryActionExpanded,required TResult Function( String tabId)  scrollToTop,}) {final _that = this;
switch (_that) {
case _Started():
return started(_that.tabs);case _RouteChanged():
return routeChanged(_that.location,_that.chrome);case _TabChanged():
return tabChanged(_that.displayIndex,_that.branchIndex,_that.tabId);case _ToggleBottomBar():
return toggleBottomBar(_that.show);case _ToggleHeader():
return toggleHeader(_that.show);case _TogglePrimaryAction():
return togglePrimaryAction(_that.show);case _TogglePrimaryActionExpanded():
return togglePrimaryActionExpanded(_that.expanded);case _ScrollToTop():
return scrollToTop(_that.tabId);}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<AppLayoutTabConfig> tabs)?  started,TResult? Function( String location,  AppLayoutChromeConfig chrome)?  routeChanged,TResult? Function( int displayIndex,  int branchIndex,  String tabId)?  tabChanged,TResult? Function( bool show)?  toggleBottomBar,TResult? Function( bool show)?  toggleHeader,TResult? Function( bool show)?  togglePrimaryAction,TResult? Function( bool expanded)?  togglePrimaryActionExpanded,TResult? Function( String tabId)?  scrollToTop,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that.tabs);case _RouteChanged() when routeChanged != null:
return routeChanged(_that.location,_that.chrome);case _TabChanged() when tabChanged != null:
return tabChanged(_that.displayIndex,_that.branchIndex,_that.tabId);case _ToggleBottomBar() when toggleBottomBar != null:
return toggleBottomBar(_that.show);case _ToggleHeader() when toggleHeader != null:
return toggleHeader(_that.show);case _TogglePrimaryAction() when togglePrimaryAction != null:
return togglePrimaryAction(_that.show);case _TogglePrimaryActionExpanded() when togglePrimaryActionExpanded != null:
return togglePrimaryActionExpanded(_that.expanded);case _ScrollToTop() when scrollToTop != null:
return scrollToTop(_that.tabId);case _:
  return null;

}
}

}



class _Started implements AppLayoutEvent {
  const _Started({required final  List<AppLayoutTabConfig> tabs}): _tabs = tabs;
  

 final  List<AppLayoutTabConfig> _tabs;
 List<AppLayoutTabConfig> get tabs {
  if (_tabs is EqualUnmodifiableListView) return _tabs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabs);
}


@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StartedCopyWith<_Started> get copyWith => __$StartedCopyWithImpl<_Started>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started&&const DeepCollectionEquality().equals(other._tabs, _tabs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tabs));

@override
String toString() {
  return 'AppLayoutEvent.started(tabs: $tabs)';
}


}

abstract mixin class _$StartedCopyWith<$Res> implements $AppLayoutEventCopyWith<$Res> {
  factory _$StartedCopyWith(_Started value, $Res Function(_Started) _then) = __$StartedCopyWithImpl;
@useResult
$Res call({
 List<AppLayoutTabConfig> tabs
});




}
class __$StartedCopyWithImpl<$Res>
    implements _$StartedCopyWith<$Res> {
  __$StartedCopyWithImpl(this._self, this._then);

  final _Started _self;
  final $Res Function(_Started) _then;

@pragma('vm:prefer-inline') $Res call({Object? tabs = null,}) {
  return _then(_Started(
tabs: null == tabs ? _self._tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<AppLayoutTabConfig>,
  ));
}


}



class _RouteChanged implements AppLayoutEvent {
  const _RouteChanged({required this.location, required this.chrome});
  

 final  String location;
 final  AppLayoutChromeConfig chrome;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteChangedCopyWith<_RouteChanged> get copyWith => __$RouteChangedCopyWithImpl<_RouteChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteChanged&&(identical(other.location, location) || other.location == location)&&(identical(other.chrome, chrome) || other.chrome == chrome));
}


@override
int get hashCode => Object.hash(runtimeType,location,chrome);

@override
String toString() {
  return 'AppLayoutEvent.routeChanged(location: $location, chrome: $chrome)';
}


}

abstract mixin class _$RouteChangedCopyWith<$Res> implements $AppLayoutEventCopyWith<$Res> {
  factory _$RouteChangedCopyWith(_RouteChanged value, $Res Function(_RouteChanged) _then) = __$RouteChangedCopyWithImpl;
@useResult
$Res call({
 String location, AppLayoutChromeConfig chrome
});




}
class __$RouteChangedCopyWithImpl<$Res>
    implements _$RouteChangedCopyWith<$Res> {
  __$RouteChangedCopyWithImpl(this._self, this._then);

  final _RouteChanged _self;
  final $Res Function(_RouteChanged) _then;

@pragma('vm:prefer-inline') $Res call({Object? location = null,Object? chrome = null,}) {
  return _then(_RouteChanged(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,chrome: null == chrome ? _self.chrome : chrome // ignore: cast_nullable_to_non_nullable
as AppLayoutChromeConfig,
  ));
}


}



class _TabChanged implements AppLayoutEvent {
  const _TabChanged({required this.displayIndex, required this.branchIndex, required this.tabId});
  

 final  int displayIndex;
 final  int branchIndex;
 final  String tabId;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TabChangedCopyWith<_TabChanged> get copyWith => __$TabChangedCopyWithImpl<_TabChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TabChanged&&(identical(other.displayIndex, displayIndex) || other.displayIndex == displayIndex)&&(identical(other.branchIndex, branchIndex) || other.branchIndex == branchIndex)&&(identical(other.tabId, tabId) || other.tabId == tabId));
}


@override
int get hashCode => Object.hash(runtimeType,displayIndex,branchIndex,tabId);

@override
String toString() {
  return 'AppLayoutEvent.tabChanged(displayIndex: $displayIndex, branchIndex: $branchIndex, tabId: $tabId)';
}


}

abstract mixin class _$TabChangedCopyWith<$Res> implements $AppLayoutEventCopyWith<$Res> {
  factory _$TabChangedCopyWith(_TabChanged value, $Res Function(_TabChanged) _then) = __$TabChangedCopyWithImpl;
@useResult
$Res call({
 int displayIndex, int branchIndex, String tabId
});




}
class __$TabChangedCopyWithImpl<$Res>
    implements _$TabChangedCopyWith<$Res> {
  __$TabChangedCopyWithImpl(this._self, this._then);

  final _TabChanged _self;
  final $Res Function(_TabChanged) _then;

@pragma('vm:prefer-inline') $Res call({Object? displayIndex = null,Object? branchIndex = null,Object? tabId = null,}) {
  return _then(_TabChanged(
displayIndex: null == displayIndex ? _self.displayIndex : displayIndex // ignore: cast_nullable_to_non_nullable
as int,branchIndex: null == branchIndex ? _self.branchIndex : branchIndex // ignore: cast_nullable_to_non_nullable
as int,tabId: null == tabId ? _self.tabId : tabId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}



class _ToggleBottomBar implements AppLayoutEvent {
  const _ToggleBottomBar({required this.show});
  

 final  bool show;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToggleBottomBarCopyWith<_ToggleBottomBar> get copyWith => __$ToggleBottomBarCopyWithImpl<_ToggleBottomBar>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleBottomBar&&(identical(other.show, show) || other.show == show));
}


@override
int get hashCode => Object.hash(runtimeType,show);

@override
String toString() {
  return 'AppLayoutEvent.toggleBottomBar(show: $show)';
}


}

abstract mixin class _$ToggleBottomBarCopyWith<$Res> implements $AppLayoutEventCopyWith<$Res> {
  factory _$ToggleBottomBarCopyWith(_ToggleBottomBar value, $Res Function(_ToggleBottomBar) _then) = __$ToggleBottomBarCopyWithImpl;
@useResult
$Res call({
 bool show
});




}
class __$ToggleBottomBarCopyWithImpl<$Res>
    implements _$ToggleBottomBarCopyWith<$Res> {
  __$ToggleBottomBarCopyWithImpl(this._self, this._then);

  final _ToggleBottomBar _self;
  final $Res Function(_ToggleBottomBar) _then;

@pragma('vm:prefer-inline') $Res call({Object? show = null,}) {
  return _then(_ToggleBottomBar(
show: null == show ? _self.show : show // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}



class _ToggleHeader implements AppLayoutEvent {
  const _ToggleHeader({required this.show});
  

 final  bool show;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToggleHeaderCopyWith<_ToggleHeader> get copyWith => __$ToggleHeaderCopyWithImpl<_ToggleHeader>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleHeader&&(identical(other.show, show) || other.show == show));
}


@override
int get hashCode => Object.hash(runtimeType,show);

@override
String toString() {
  return 'AppLayoutEvent.toggleHeader(show: $show)';
}


}

abstract mixin class _$ToggleHeaderCopyWith<$Res> implements $AppLayoutEventCopyWith<$Res> {
  factory _$ToggleHeaderCopyWith(_ToggleHeader value, $Res Function(_ToggleHeader) _then) = __$ToggleHeaderCopyWithImpl;
@useResult
$Res call({
 bool show
});




}
class __$ToggleHeaderCopyWithImpl<$Res>
    implements _$ToggleHeaderCopyWith<$Res> {
  __$ToggleHeaderCopyWithImpl(this._self, this._then);

  final _ToggleHeader _self;
  final $Res Function(_ToggleHeader) _then;

@pragma('vm:prefer-inline') $Res call({Object? show = null,}) {
  return _then(_ToggleHeader(
show: null == show ? _self.show : show // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}



class _TogglePrimaryAction implements AppLayoutEvent {
  const _TogglePrimaryAction({required this.show});
  

 final  bool show;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TogglePrimaryActionCopyWith<_TogglePrimaryAction> get copyWith => __$TogglePrimaryActionCopyWithImpl<_TogglePrimaryAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TogglePrimaryAction&&(identical(other.show, show) || other.show == show));
}


@override
int get hashCode => Object.hash(runtimeType,show);

@override
String toString() {
  return 'AppLayoutEvent.togglePrimaryAction(show: $show)';
}


}

abstract mixin class _$TogglePrimaryActionCopyWith<$Res> implements $AppLayoutEventCopyWith<$Res> {
  factory _$TogglePrimaryActionCopyWith(_TogglePrimaryAction value, $Res Function(_TogglePrimaryAction) _then) = __$TogglePrimaryActionCopyWithImpl;
@useResult
$Res call({
 bool show
});




}
class __$TogglePrimaryActionCopyWithImpl<$Res>
    implements _$TogglePrimaryActionCopyWith<$Res> {
  __$TogglePrimaryActionCopyWithImpl(this._self, this._then);

  final _TogglePrimaryAction _self;
  final $Res Function(_TogglePrimaryAction) _then;

@pragma('vm:prefer-inline') $Res call({Object? show = null,}) {
  return _then(_TogglePrimaryAction(
show: null == show ? _self.show : show // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}



class _TogglePrimaryActionExpanded implements AppLayoutEvent {
  const _TogglePrimaryActionExpanded({required this.expanded});
  

 final  bool expanded;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TogglePrimaryActionExpandedCopyWith<_TogglePrimaryActionExpanded> get copyWith => __$TogglePrimaryActionExpandedCopyWithImpl<_TogglePrimaryActionExpanded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TogglePrimaryActionExpanded&&(identical(other.expanded, expanded) || other.expanded == expanded));
}


@override
int get hashCode => Object.hash(runtimeType,expanded);

@override
String toString() {
  return 'AppLayoutEvent.togglePrimaryActionExpanded(expanded: $expanded)';
}


}

abstract mixin class _$TogglePrimaryActionExpandedCopyWith<$Res> implements $AppLayoutEventCopyWith<$Res> {
  factory _$TogglePrimaryActionExpandedCopyWith(_TogglePrimaryActionExpanded value, $Res Function(_TogglePrimaryActionExpanded) _then) = __$TogglePrimaryActionExpandedCopyWithImpl;
@useResult
$Res call({
 bool expanded
});




}
class __$TogglePrimaryActionExpandedCopyWithImpl<$Res>
    implements _$TogglePrimaryActionExpandedCopyWith<$Res> {
  __$TogglePrimaryActionExpandedCopyWithImpl(this._self, this._then);

  final _TogglePrimaryActionExpanded _self;
  final $Res Function(_TogglePrimaryActionExpanded) _then;

@pragma('vm:prefer-inline') $Res call({Object? expanded = null,}) {
  return _then(_TogglePrimaryActionExpanded(
expanded: null == expanded ? _self.expanded : expanded // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}



class _ScrollToTop implements AppLayoutEvent {
  const _ScrollToTop({required this.tabId});
  

 final  String tabId;

@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScrollToTopCopyWith<_ScrollToTop> get copyWith => __$ScrollToTopCopyWithImpl<_ScrollToTop>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScrollToTop&&(identical(other.tabId, tabId) || other.tabId == tabId));
}


@override
int get hashCode => Object.hash(runtimeType,tabId);

@override
String toString() {
  return 'AppLayoutEvent.scrollToTop(tabId: $tabId)';
}


}

abstract mixin class _$ScrollToTopCopyWith<$Res> implements $AppLayoutEventCopyWith<$Res> {
  factory _$ScrollToTopCopyWith(_ScrollToTop value, $Res Function(_ScrollToTop) _then) = __$ScrollToTopCopyWithImpl;
@useResult
$Res call({
 String tabId
});




}
class __$ScrollToTopCopyWithImpl<$Res>
    implements _$ScrollToTopCopyWith<$Res> {
  __$ScrollToTopCopyWithImpl(this._self, this._then);

  final _ScrollToTop _self;
  final $Res Function(_ScrollToTop) _then;

@pragma('vm:prefer-inline') $Res call({Object? tabId = null,}) {
  return _then(_ScrollToTop(
tabId: null == tabId ? _self.tabId : tabId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

mixin _$AppLayoutState {

 bool get showHeader; bool get showBottomBar; bool get showPrimaryAction; bool get primaryActionExpanded; int get activeDisplayIndex; int get activeBranchIndex; String get activeTabId; List<AppLayoutTabConfig> get tabs; Map<String, bool> get scrollToTopFlagsById; String? get currentRoute; String? get previousRoute;
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLayoutStateCopyWith<AppLayoutState> get copyWith => _$AppLayoutStateCopyWithImpl<AppLayoutState>(this as AppLayoutState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLayoutState&&(identical(other.showHeader, showHeader) || other.showHeader == showHeader)&&(identical(other.showBottomBar, showBottomBar) || other.showBottomBar == showBottomBar)&&(identical(other.showPrimaryAction, showPrimaryAction) || other.showPrimaryAction == showPrimaryAction)&&(identical(other.primaryActionExpanded, primaryActionExpanded) || other.primaryActionExpanded == primaryActionExpanded)&&(identical(other.activeDisplayIndex, activeDisplayIndex) || other.activeDisplayIndex == activeDisplayIndex)&&(identical(other.activeBranchIndex, activeBranchIndex) || other.activeBranchIndex == activeBranchIndex)&&(identical(other.activeTabId, activeTabId) || other.activeTabId == activeTabId)&&const DeepCollectionEquality().equals(other.tabs, tabs)&&const DeepCollectionEquality().equals(other.scrollToTopFlagsById, scrollToTopFlagsById)&&(identical(other.currentRoute, currentRoute) || other.currentRoute == currentRoute)&&(identical(other.previousRoute, previousRoute) || other.previousRoute == previousRoute));
}


@override
int get hashCode => Object.hash(runtimeType,showHeader,showBottomBar,showPrimaryAction,primaryActionExpanded,activeDisplayIndex,activeBranchIndex,activeTabId,const DeepCollectionEquality().hash(tabs),const DeepCollectionEquality().hash(scrollToTopFlagsById),currentRoute,previousRoute);

@override
String toString() {
  return 'AppLayoutState(showHeader: $showHeader, showBottomBar: $showBottomBar, showPrimaryAction: $showPrimaryAction, primaryActionExpanded: $primaryActionExpanded, activeDisplayIndex: $activeDisplayIndex, activeBranchIndex: $activeBranchIndex, activeTabId: $activeTabId, tabs: $tabs, scrollToTopFlagsById: $scrollToTopFlagsById, currentRoute: $currentRoute, previousRoute: $previousRoute)';
}


}

abstract mixin class $AppLayoutStateCopyWith<$Res>  {
  factory $AppLayoutStateCopyWith(AppLayoutState value, $Res Function(AppLayoutState) _then) = _$AppLayoutStateCopyWithImpl;
@useResult
$Res call({
 bool showHeader, bool showBottomBar, bool showPrimaryAction, bool primaryActionExpanded, int activeDisplayIndex, int activeBranchIndex, String activeTabId, List<AppLayoutTabConfig> tabs, Map<String, bool> scrollToTopFlagsById, String? currentRoute, String? previousRoute
});




}
class _$AppLayoutStateCopyWithImpl<$Res>
    implements $AppLayoutStateCopyWith<$Res> {
  _$AppLayoutStateCopyWithImpl(this._self, this._then);

  final AppLayoutState _self;
  final $Res Function(AppLayoutState) _then;

@pragma('vm:prefer-inline') @override $Res call({Object? showHeader = null,Object? showBottomBar = null,Object? showPrimaryAction = null,Object? primaryActionExpanded = null,Object? activeDisplayIndex = null,Object? activeBranchIndex = null,Object? activeTabId = null,Object? tabs = null,Object? scrollToTopFlagsById = null,Object? currentRoute = freezed,Object? previousRoute = freezed,}) {
  return _then(_self.copyWith(
showHeader: null == showHeader ? _self.showHeader : showHeader // ignore: cast_nullable_to_non_nullable
as bool,showBottomBar: null == showBottomBar ? _self.showBottomBar : showBottomBar // ignore: cast_nullable_to_non_nullable
as bool,showPrimaryAction: null == showPrimaryAction ? _self.showPrimaryAction : showPrimaryAction // ignore: cast_nullable_to_non_nullable
as bool,primaryActionExpanded: null == primaryActionExpanded ? _self.primaryActionExpanded : primaryActionExpanded // ignore: cast_nullable_to_non_nullable
as bool,activeDisplayIndex: null == activeDisplayIndex ? _self.activeDisplayIndex : activeDisplayIndex // ignore: cast_nullable_to_non_nullable
as int,activeBranchIndex: null == activeBranchIndex ? _self.activeBranchIndex : activeBranchIndex // ignore: cast_nullable_to_non_nullable
as int,activeTabId: null == activeTabId ? _self.activeTabId : activeTabId // ignore: cast_nullable_to_non_nullable
as String,tabs: null == tabs ? _self.tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<AppLayoutTabConfig>,scrollToTopFlagsById: null == scrollToTopFlagsById ? _self.scrollToTopFlagsById : scrollToTopFlagsById // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,currentRoute: freezed == currentRoute ? _self.currentRoute : currentRoute // ignore: cast_nullable_to_non_nullable
as String?,previousRoute: freezed == previousRoute ? _self.previousRoute : previousRoute // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


extension AppLayoutStatePatterns on AppLayoutState {

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppLayoutState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppLayoutState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppLayoutState value)  $default,){
final _that = this;
switch (_that) {
case _AppLayoutState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppLayoutState value)?  $default,){
final _that = this;
switch (_that) {
case _AppLayoutState() when $default != null:
return $default(_that);case _:
  return null;

}
}

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool showHeader,  bool showBottomBar,  bool showPrimaryAction,  bool primaryActionExpanded,  int activeDisplayIndex,  int activeBranchIndex,  String activeTabId,  List<AppLayoutTabConfig> tabs,  Map<String, bool> scrollToTopFlagsById,  String? currentRoute,  String? previousRoute)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppLayoutState() when $default != null:
return $default(_that.showHeader,_that.showBottomBar,_that.showPrimaryAction,_that.primaryActionExpanded,_that.activeDisplayIndex,_that.activeBranchIndex,_that.activeTabId,_that.tabs,_that.scrollToTopFlagsById,_that.currentRoute,_that.previousRoute);case _:
  return orElse();

}
}

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool showHeader,  bool showBottomBar,  bool showPrimaryAction,  bool primaryActionExpanded,  int activeDisplayIndex,  int activeBranchIndex,  String activeTabId,  List<AppLayoutTabConfig> tabs,  Map<String, bool> scrollToTopFlagsById,  String? currentRoute,  String? previousRoute)  $default,) {final _that = this;
switch (_that) {
case _AppLayoutState():
return $default(_that.showHeader,_that.showBottomBar,_that.showPrimaryAction,_that.primaryActionExpanded,_that.activeDisplayIndex,_that.activeBranchIndex,_that.activeTabId,_that.tabs,_that.scrollToTopFlagsById,_that.currentRoute,_that.previousRoute);case _:
  throw StateError('Unexpected subclass');

}
}

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool showHeader,  bool showBottomBar,  bool showPrimaryAction,  bool primaryActionExpanded,  int activeDisplayIndex,  int activeBranchIndex,  String activeTabId,  List<AppLayoutTabConfig> tabs,  Map<String, bool> scrollToTopFlagsById,  String? currentRoute,  String? previousRoute)?  $default,) {final _that = this;
switch (_that) {
case _AppLayoutState() when $default != null:
return $default(_that.showHeader,_that.showBottomBar,_that.showPrimaryAction,_that.primaryActionExpanded,_that.activeDisplayIndex,_that.activeBranchIndex,_that.activeTabId,_that.tabs,_that.scrollToTopFlagsById,_that.currentRoute,_that.previousRoute);case _:
  return null;

}
}

}



class _AppLayoutState implements AppLayoutState {
  const _AppLayoutState({this.showHeader = true, this.showBottomBar = true, this.showPrimaryAction = true, this.primaryActionExpanded = false, this.activeDisplayIndex = 0, this.activeBranchIndex = 0, this.activeTabId = 'home', final  List<AppLayoutTabConfig> tabs = const <AppLayoutTabConfig>[], final  Map<String, bool> scrollToTopFlagsById = const <String, bool>{}, this.currentRoute, this.previousRoute}): _tabs = tabs,_scrollToTopFlagsById = scrollToTopFlagsById;
  

@override@JsonKey() final  bool showHeader;
@override@JsonKey() final  bool showBottomBar;
@override@JsonKey() final  bool showPrimaryAction;
@override@JsonKey() final  bool primaryActionExpanded;
@override@JsonKey() final  int activeDisplayIndex;
@override@JsonKey() final  int activeBranchIndex;
@override@JsonKey() final  String activeTabId;
 final  List<AppLayoutTabConfig> _tabs;
@override@JsonKey() List<AppLayoutTabConfig> get tabs {
  if (_tabs is EqualUnmodifiableListView) return _tabs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabs);
}

 final  Map<String, bool> _scrollToTopFlagsById;
@override@JsonKey() Map<String, bool> get scrollToTopFlagsById {
  if (_scrollToTopFlagsById is EqualUnmodifiableMapView) return _scrollToTopFlagsById;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_scrollToTopFlagsById);
}

@override final  String? currentRoute;
@override final  String? previousRoute;

@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppLayoutStateCopyWith<_AppLayoutState> get copyWith => __$AppLayoutStateCopyWithImpl<_AppLayoutState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppLayoutState&&(identical(other.showHeader, showHeader) || other.showHeader == showHeader)&&(identical(other.showBottomBar, showBottomBar) || other.showBottomBar == showBottomBar)&&(identical(other.showPrimaryAction, showPrimaryAction) || other.showPrimaryAction == showPrimaryAction)&&(identical(other.primaryActionExpanded, primaryActionExpanded) || other.primaryActionExpanded == primaryActionExpanded)&&(identical(other.activeDisplayIndex, activeDisplayIndex) || other.activeDisplayIndex == activeDisplayIndex)&&(identical(other.activeBranchIndex, activeBranchIndex) || other.activeBranchIndex == activeBranchIndex)&&(identical(other.activeTabId, activeTabId) || other.activeTabId == activeTabId)&&const DeepCollectionEquality().equals(other._tabs, _tabs)&&const DeepCollectionEquality().equals(other._scrollToTopFlagsById, _scrollToTopFlagsById)&&(identical(other.currentRoute, currentRoute) || other.currentRoute == currentRoute)&&(identical(other.previousRoute, previousRoute) || other.previousRoute == previousRoute));
}


@override
int get hashCode => Object.hash(runtimeType,showHeader,showBottomBar,showPrimaryAction,primaryActionExpanded,activeDisplayIndex,activeBranchIndex,activeTabId,const DeepCollectionEquality().hash(_tabs),const DeepCollectionEquality().hash(_scrollToTopFlagsById),currentRoute,previousRoute);

@override
String toString() {
  return 'AppLayoutState(showHeader: $showHeader, showBottomBar: $showBottomBar, showPrimaryAction: $showPrimaryAction, primaryActionExpanded: $primaryActionExpanded, activeDisplayIndex: $activeDisplayIndex, activeBranchIndex: $activeBranchIndex, activeTabId: $activeTabId, tabs: $tabs, scrollToTopFlagsById: $scrollToTopFlagsById, currentRoute: $currentRoute, previousRoute: $previousRoute)';
}


}

abstract mixin class _$AppLayoutStateCopyWith<$Res> implements $AppLayoutStateCopyWith<$Res> {
  factory _$AppLayoutStateCopyWith(_AppLayoutState value, $Res Function(_AppLayoutState) _then) = __$AppLayoutStateCopyWithImpl;
@override @useResult
$Res call({
 bool showHeader, bool showBottomBar, bool showPrimaryAction, bool primaryActionExpanded, int activeDisplayIndex, int activeBranchIndex, String activeTabId, List<AppLayoutTabConfig> tabs, Map<String, bool> scrollToTopFlagsById, String? currentRoute, String? previousRoute
});




}
class __$AppLayoutStateCopyWithImpl<$Res>
    implements _$AppLayoutStateCopyWith<$Res> {
  __$AppLayoutStateCopyWithImpl(this._self, this._then);

  final _AppLayoutState _self;
  final $Res Function(_AppLayoutState) _then;

@override @pragma('vm:prefer-inline') $Res call({Object? showHeader = null,Object? showBottomBar = null,Object? showPrimaryAction = null,Object? primaryActionExpanded = null,Object? activeDisplayIndex = null,Object? activeBranchIndex = null,Object? activeTabId = null,Object? tabs = null,Object? scrollToTopFlagsById = null,Object? currentRoute = freezed,Object? previousRoute = freezed,}) {
  return _then(_AppLayoutState(
showHeader: null == showHeader ? _self.showHeader : showHeader // ignore: cast_nullable_to_non_nullable
as bool,showBottomBar: null == showBottomBar ? _self.showBottomBar : showBottomBar // ignore: cast_nullable_to_non_nullable
as bool,showPrimaryAction: null == showPrimaryAction ? _self.showPrimaryAction : showPrimaryAction // ignore: cast_nullable_to_non_nullable
as bool,primaryActionExpanded: null == primaryActionExpanded ? _self.primaryActionExpanded : primaryActionExpanded // ignore: cast_nullable_to_non_nullable
as bool,activeDisplayIndex: null == activeDisplayIndex ? _self.activeDisplayIndex : activeDisplayIndex // ignore: cast_nullable_to_non_nullable
as int,activeBranchIndex: null == activeBranchIndex ? _self.activeBranchIndex : activeBranchIndex // ignore: cast_nullable_to_non_nullable
as int,activeTabId: null == activeTabId ? _self.activeTabId : activeTabId // ignore: cast_nullable_to_non_nullable
as String,tabs: null == tabs ? _self._tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<AppLayoutTabConfig>,scrollToTopFlagsById: null == scrollToTopFlagsById ? _self._scrollToTopFlagsById : scrollToTopFlagsById // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,currentRoute: freezed == currentRoute ? _self.currentRoute : currentRoute // ignore: cast_nullable_to_non_nullable
as String?,previousRoute: freezed == previousRoute ? _self.previousRoute : previousRoute // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
