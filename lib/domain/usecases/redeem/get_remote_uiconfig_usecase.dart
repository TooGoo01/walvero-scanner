import 'package:dartz/dartz.dart';
import 'package:walveroScanner/domain/repositories/redeem_repository.dart' show RedeemRepository;

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/redeem/program_ui_config.dart';

class GetRemoteUiconfigUsecase implements UseCase<ProgramUiConfig, NoParams> {
  final RedeemRepository repository;
  GetRemoteUiconfigUsecase(this.repository);

  @override
  Future<Either<Failure, ProgramUiConfig>> call(NoParams params) async {
    return await repository.getRemoteUI();
  }
}
