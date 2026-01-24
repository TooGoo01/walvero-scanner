import 'package:dartz/dartz.dart';

import 'package:walveroScanner/domain/repositories/redeem_repository.dart' show RedeemRepository;

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';

import '../../entities/redeem/redeem_lookup_response.dart';


class GetLookupUseCase
    implements UseCase<LookupCard, LookupCodeParams> {
  final RedeemRepository repository;
  GetLookupUseCase(this.repository);

  @override
  Future<Either<Failure, LookupCard>> call(
      LookupCodeParams params) async {
    return await repository.getLookupCard(params);
  }
}

class LookupCodeParams {
  final String? code;
  
  final double balance;


  const LookupCodeParams({
    this.code = '',
   
    this.balance = 0,
    
  });

  LookupCodeParams copyWith({
    
    String? code,
   
    double? balance,
   
  }) =>
      LookupCodeParams(
        code: code ?? this.code,
      
        balance: balance ?? this.balance,
       
      );
}
