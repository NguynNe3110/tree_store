import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/tree/get_tree_detail_usecase.dart';

abstract class TreeEvent extends Equatable {
  const TreeEvent();
  @override
  List<Object?> get props => [];
}

class TreeLoad extends TreeEvent {
  final String id;
  const TreeLoad(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class TreeState extends Equatable {
  const TreeState();
  @override
  List<Object?> get props => [];
}

class TreeInitial extends TreeState {
  const TreeInitial();
}

class TreeLoading extends TreeState {
  const TreeLoading();
}

class TreeLoaded extends TreeState {
  final Product tree;
  const TreeLoaded(this.tree);
  @override
  List<Object?> get props => [tree];
}

class TreeError extends TreeState {
  final String message;
  const TreeError(this.message);
  @override
  List<Object?> get props => [message];
}

class TreeBloc extends Bloc<TreeEvent, TreeState> {
  final GetTreeDetailUsecase _getTreeDetail;

  TreeBloc({required GetTreeDetailUsecase getTreeDetail})
      : _getTreeDetail = getTreeDetail,
        super(const TreeInitial()) {
    on<TreeLoad>(_onLoad);
  }

  Future<void> _onLoad(TreeLoad event, Emitter<TreeState> emit) async {
    emit(const TreeLoading());
    final result = await _getTreeDetail(event.id);
    result.fold(
      (f) => emit(TreeError(f.message)),
      (tree) => emit(TreeLoaded(tree)),
    );
  }
}