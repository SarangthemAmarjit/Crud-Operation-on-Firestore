import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'fetchdata_state.dart';

class FetchdataCubit extends Cubit<FetchdataState> {
  FetchdataCubit() : super(const FetchdataState(status: Status.initial));
  bool get isLoading => Status.loading == state.status;
  final CollectionReference expenditurelist =
      FirebaseFirestore.instance.collection('expenditure');

  Future getdatalist() async {
    List itemsList = [];
    if (isLoading) return;
    emit(const FetchdataState(status: Status.loading));
    try {
      final messages = await expenditurelist.get();
      for (var message in messages.docs) {
        itemsList.add(message.data());
        print(message.data());
      }
      emit(const FetchdataState(status: Status.loaded));
      return itemsList;
    } catch (e) {
      emit(const FetchdataState(status: Status.error));
      return null;
    }
  }
}
