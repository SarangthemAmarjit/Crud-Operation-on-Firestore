part of 'fetchdata_cubit.dart';

enum Status { initial, loading, loaded, error }

class FetchdataState extends Equatable {
  final Status status;
  const FetchdataState({required this.status});

  @override
  List get props => [status];
}
