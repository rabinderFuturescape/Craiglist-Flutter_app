import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final int page;
  final int pageSize;

  const LoadProducts({
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object> get props => [page, pageSize];
}

class FilterProducts extends ProductEvent {
  final String? searchQuery;
  final Map<String, dynamic> filters;

  const FilterProducts({
    this.searchQuery,
    this.filters = const {},
  });

  @override
  List<Object?> get props => [searchQuery, filters];
}
