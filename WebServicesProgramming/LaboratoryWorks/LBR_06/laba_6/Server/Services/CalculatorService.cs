using Grpc.Core;

namespace Server.Services
{
    public class CalculatorService : Calculator.CalculatorBase
    {
        private readonly ILogger<CalculatorService> _logger;

        public CalculatorService(ILogger<CalculatorService> logger)
        {
            _logger = logger;
        }

        public override Task<CalculationResult> Sum(BinaryOperationRequest request, ServerCallContext context)
        {
            _logger.LogInformation($"SUM({request.X}, {request.Y})");

            try
            {
                var result = request.X + request.Y;

                return Task.FromResult(new CalculationResult
                {
                    Result = result,
                    Success = true
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SUM Error");
                return Task.FromResult(new CalculationResult
                {
                    ErrorMessage = "SUM Error",
                    Success = false
                });
            }
        }

        public override Task<CalculationResult> Sub(BinaryOperationRequest request, ServerCallContext context)
        {
            _logger.LogInformation($"SUB({request.X}, {request.Y})");

            try
            {
                var result = request.X - request.Y;
                return Task.FromResult(new CalculationResult
                {
                    Result = result,
                    Success = true
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SUB Error");
                return Task.FromResult(new CalculationResult
                {
                    ErrorMessage = "SUB Error",
                    Success = false
                });
            }
        }

        public override Task<CalculationResult> Mul(BinaryOperationRequest request, ServerCallContext context)
        {
            _logger.LogInformation($"MUL({request.X}, {request.Y})");

            try
            {
                var result = request.X * request.Y;
                return Task.FromResult(new CalculationResult
                {
                    Result = result,
                    Success = true
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "MUL Error");
                return Task.FromResult(new CalculationResult
                {
                    ErrorMessage = "MUL Error",
                    Success = false
                });
            }
        }

        public override Task<CalculationResult> Div(BinaryOperationRequest request, ServerCallContext context)
        {
            _logger.LogInformation($"DIV({request.X}, {request.Y})");

            try
            {
                if (request.Y == 0)
                {
                    throw new RpcException(new Status(StatusCode.InvalidArgument,
                        "y = 0"));
                }

                var result = request.X / request.Y;
                return Task.FromResult(new CalculationResult
                {
                    Result = result,
                    Success = true
                });
            }
            catch (RpcException)
            {
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "DIV Error");
                return Task.FromResult(new CalculationResult
                {
                    ErrorMessage = "DIV Error",
                    Success = false
                });
            }
        }

        public override Task<CalculationResult> Fact(UnaryOperationRequest request, ServerCallContext context)
        {
            _logger.LogInformation($"FACT({request.X})");

            try
            {
                if (request.X < 0)
                {
                    throw new RpcException(new Status(StatusCode.InvalidArgument,
                        "Uncorrect x"));
                }

                long result = CalculateFactorial(request.X);

                return Task.FromResult(new CalculationResult
                {
                    Result = result,
                    Success = true
                });
            }
            catch (RpcException)
            {
                throw;
            }
            catch (OverflowException)
            {
                throw new RpcException(new Status(StatusCode.OutOfRange,
                    "x is too big"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "FACT Error");
                return Task.FromResult(new CalculationResult
                {
                    ErrorMessage = "FACT Error",
                    Success = false
                });
            }
        }

        private long CalculateFactorial(int n)
        {
            if (n == 0 || n == 1) return 1;

            long result = 1;
            for (int i = 2; i <= n; i++)
            {
                if (result > long.MaxValue / i)
                {
                    throw new OverflowException();
                }
                result *= i;
            }

            return result;
        }
    }
}