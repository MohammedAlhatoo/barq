import 'package:flutter_bloc/flutter_bloc.dart';

/// The state is the index of the visible onboarding page.
class OnboardingCubit extends Cubit<int> {
  OnboardingCubit() : super(0);

  static const pageCount = 3;

  bool get isLastPage => state == pageCount - 1;

  void pageChanged(int index) => emit(index);
}
