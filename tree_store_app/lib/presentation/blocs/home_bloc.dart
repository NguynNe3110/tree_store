import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/remote/models/responses/home_response.dart';
import '../../domain/usecases/home/get_home_blocks_usecase.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class HomeLoad extends HomeEvent {
  const HomeLoad();
  @override
  List<Object?> get props => [];
}

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();
  @override
  List<Object?> get props => [];
}

class HomeLoaded extends HomeState {
  final List<UiBlockResponse> blocks;
  const HomeLoaded(this.blocks);
  @override
  List<Object?> get props => [blocks];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeBlocksUsecase _getHomeBlocks;

  HomeBloc({required GetHomeBlocksUsecase getHomeBlocks})
      : _getHomeBlocks = getHomeBlocks,
        super(const HomeInitial()) {
    on<HomeLoad>(_onLoad);
  }

  Future<void> _onLoad(HomeLoad event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    final result = await _getHomeBlocks();
    result.fold(
      (f) => emit(HomeError(f.message)),
      (response) => emit(HomeLoaded(response.blocks)),
    );
  }
}
