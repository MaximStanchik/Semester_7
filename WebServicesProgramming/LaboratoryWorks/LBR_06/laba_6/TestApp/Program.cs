using Grpc.Core;
using Grpc.Net.Client;
using Server;

namespace gRPCClient
{
    class Program
    {
        private static Calculator.CalculatorClient client = null!;
        private static GrpcChannel channel = null!;
        private static double x;
        private static double y;

        static async Task Main(string[] args)
        {
            try
            {
                channel = GrpcChannel.ForAddress("http://localhost:5115");
                client = new Calculator.CalculatorClient(channel);

                EnterNewValues();

                await RunCalculator();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
            finally
            {
                channel?.Dispose();
                Console.WriteLine("End...");
                Console.ReadKey();
            }
        }

        private static async Task RunCalculator()
        {
            while (true)
            {
                DisplayMenu();

                var choice = Console.ReadKey().KeyChar;
                Console.WriteLine();

                switch (choice)
                {
                    case '0':
                        EnterNewValues();
                        break;
                    case '1':
                        await PerformSum();
                        break;
                    case '2':
                        await PerformSub();
                        break;
                    case '3':
                        await PerformMul();
                        break;
                    case '4':
                        await PerformDiv();
                        break;
                    case '5':
                        await PerformFact();
                        break;
                    case '6':
                        await PerformAllOperations();
                        break;
                    case '7':
                        Console.WriteLine("Exit...");
                        return;
                    default:
                        Console.WriteLine("Try again.");
                        break;
                }

                Console.WriteLine("Enter something...");
                Console.ReadKey();
            }
        }

        private static void DisplayMenu()
        {
            Console.Clear();
            Console.WriteLine($"Current Values: \nx = {x}; \ny = {y};\n");
            Console.WriteLine("Choise potions:");
            Console.WriteLine("0) New Values");
            Console.WriteLine("1) SUM");
            Console.WriteLine("2) SUB");
            Console.WriteLine("3) MUL");
            Console.WriteLine("4) DIV");
            Console.WriteLine("5) FACT");
            Console.WriteLine("6) All operetion");
            Console.WriteLine("7) Exit");
            Console.Write("Enter: ");
        }

        private static async Task PerformSum()
        {
            try
            {
                var request = new BinaryOperationRequest { X = x, Y = y };
                var response = await client.SumAsync(request);

                if (response.Success)
                {
                    Console.WriteLine($"SUM({x}, {y}) = {response.Result}");
                }
                else
                {
                    Console.WriteLine($"Error: {response.ErrorMessage}");
                }
            }
            catch (RpcException rpcEx)
            {
                HandleRpcException(rpcEx, "SUM");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        private static async Task PerformSub()
        {
            try
            {
                var request = new BinaryOperationRequest { X = x, Y = y };
                var response = await client.SubAsync(request);

                if (response.Success)
                {
                    Console.WriteLine($"SUB({x}, {y}) = {response.Result}");
                }
                else
                {
                    Console.WriteLine($"Error: {response.ErrorMessage}");
                }
            }
            catch (RpcException rpcEx)
            {
                HandleRpcException(rpcEx, "SUB");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        private static async Task PerformMul()
        {
            try
            {
                var request = new BinaryOperationRequest { X = x, Y = y };
                var response = await client.MulAsync(request);

                if (response.Success)
                {
                    Console.WriteLine($"MUL({x}, {y}) = {response.Result}");
                }
                else
                {
                    Console.WriteLine($"Error: {response.ErrorMessage}");
                }
            }
            catch (RpcException rpcEx)
            {
                HandleRpcException(rpcEx, "MUL");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        private static async Task PerformDiv(bool error = false)
        {
            try
            {
                BinaryOperationRequest request;
                if (!error)
                {
                    request = new BinaryOperationRequest { X = x, Y = y };
                }
                else
                {
                    request = new BinaryOperationRequest { X = x, Y = 0 };
                }

                var response = await client.DivAsync(request);

                if (response.Success)
                {
                    Console.WriteLine($"DIV({x}, {y}) = {response.Result}");
                }
                else
                {
                    Console.WriteLine($"Error: {response.ErrorMessage}");
                }
            }
            catch (RpcException rpcEx)
            {
                HandleRpcException(rpcEx, "DIV");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        private static async Task PerformFact()
        {
            try
            {
                var f = Convert.ToInt32(x);
                var request = new UnaryOperationRequest { X = f };
                var response = await client.FactAsync(request);

                if (response.Success)
                {
                    Console.WriteLine($"FACT({f}) = {response.Result}");
                }
                else
                {
                    Console.WriteLine($"Error: {response.ErrorMessage}");
                }
            }
            catch (RpcException rpcEx)
            {
                HandleRpcException(rpcEx, "FACT");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        private static async Task PerformAllOperations()
        {
            try
            {
                await PerformSum();
                await PerformSub();
                await PerformMul();
                await PerformDiv();
                await PerformFact();
                await PerformDiv(true);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        private static void EnterNewValues()
        {
            var result = 0d;

            while (true)
            {
                Console.Write("x = ");
                var xValue = Console.ReadLine();

                if (double.TryParse(xValue, out result))
                {
                    x = result;
                    break;
                }

                Console.WriteLine("This is not a number, try again");
            }
            while (true)
            {
                Console.Write("y = ");
                var yValue = Console.ReadLine();

                if (double.TryParse(yValue, out result))
                {
                    y = result;
                    break;
                }

                Console.WriteLine("This is not a number, try again");
            }
        }

        private static void HandleRpcException(RpcException ex, string operationName)
        {
            var errorMessage = ex.StatusCode switch
            {
                StatusCode.InvalidArgument => $"Invalid Argument - {operationName}",
                StatusCode.OutOfRange => $"Uncorrect result - {operationName}",
                StatusCode.Unavailable => $"gRPC is not active",
                StatusCode.DeadlineExceeded => $"Time out - {operationName}",
                _ => $"Error {operationName}: {ex.Status.Detail}"
            };

            Console.WriteLine($"Error: {errorMessage}");
        }
    }
}