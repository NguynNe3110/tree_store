import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/tree/get_trees_usecase.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchQuery extends SearchEvent {
  final String keyword;
  const SearchQuery(this.keyword);
  @override
  List<Object?> get props => [keyword];
}

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<Product> results;
  const SearchLoaded(this.results);
  @override
  List<Object?> get props => [results];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object?> get props => [message];
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GetTreesUsecase _getTrees;

  SearchBloc({required GetTreesUsecase getTrees})
      : _getTrees = getTrees,
        super(const SearchInitial()) {
    on<SearchQuery>(_onSearch);
  }

  Future<void> _onSearch(SearchQuery event, Emitter<SearchState> emit) async {
    final kw = event.keyword.trim();
    if (kw.isEmpty) {
      emit(const SearchInitial());
      return;
    }
    emit(const SearchLoading());
    final result = await _getTrees(GetTreesParams(keyword: kw, limit: 20));
    result.fold(
      (f) => emit(SearchError(f.message)),
      (trees) => emit(SearchLoaded(trees)),
    );
  }
}