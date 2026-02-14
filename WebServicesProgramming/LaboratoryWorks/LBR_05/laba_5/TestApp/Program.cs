using Microsoft.AspNetCore.SignalR.Client;

namespace SignalRClient
{
    class Program
    {
        private static HubConnection _connection = null!;
        private static double x;
        private static double y;

        static async Task Main(string[] args)
        {
            await InitializeConnection();

            bool exit = false;

            WriteNewValues();

            while (!exit)
            {
                exit = await ShowMenu();
                Console.WriteLine("Enter something to continue...");
                Console.ReadKey();
                Console.Clear();
            }

            await Disconnect();
        }

        private static async Task InitializeConnection()
        {
            try
            {
                _connection = new HubConnectionBuilder()
                    .WithUrl("http://localhost:5199/calculatorHub")
                    .WithAutomaticReconnect()
                    .Build();

                _connection.Closed += async (error) =>
                {
                    Console.WriteLine("Connection closed. Trying reconnect...");
                    await Task.Delay(new Random().Next(0, 5) * 1000);
                    await _connection.StartAsync();
                };

                _connection.Reconnecting += error =>
                {
                    Console.WriteLine("Connection lost. Reconnecting...");
                    return Task.CompletedTask;
                };

                _connection.Reconnected += connectionId =>
                {
                    Console.WriteLine("Reconnected to server.");
                    return Task.CompletedTask;
                };

                Console.WriteLine("Connecting to server...");
                await _connection.StartAsync();
                Console.WriteLine("Connected to server successfully!");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Connection failed: {ex.Message}");
                Console.WriteLine("Make sure the SignalR server is running on http://localhost:5199");
            }
        }

        private static async Task<bool> ShowMenu()
        {
            Console.WriteLine($"Current Values:\nx = {x};\ny = {y};\n");
            Console.WriteLine("Choose an operation:");
            Console.WriteLine("0) Enter new values");
            Console.WriteLine("1) SUM (x + y)");
            Console.WriteLine("2) SUB (x - y)");
            Console.WriteLine("3) MUL (x * y)");
            Console.WriteLine("4) DIV (x / y)");
            Console.WriteLine("5) FACT (x)");
            Console.WriteLine("6) Test All Operations");
            Console.WriteLine("7) Exit");
            Console.Write("Enter your choice (1-7): ");

            var choice = Console.ReadKey().KeyChar;
            Console.WriteLine();

            switch (choice)
            {
                case '0':
                    WriteNewValues();
                    return false;
                case '1':
                    await Calculator("SUM");
                    return false;
                case '2':
                    await Calculator("SUB");
                    return false;
                case '3':
                    await Calculator("MUL");
                    return false;
                case '4':
                    await Calculator("DIV");
                    return false;
                case '5':
                    await CallFact();
                    return false;
                case '6':
                    await TestAllOperations();
                    return false;
                case '7':
                    return true;
                default:
                    Console.WriteLine("Invalid choice. Please try again.");
                    return false;
            }
        }

        private static async Task Calculator(string meth)
        {
            if (!await CheckConnection())
            {
                return;
            }

            try
            {
                Console.WriteLine($"Calling {meth}({x}, {y})...");
                double result = await _connection.InvokeAsync<double>(meth, x, y);
                Console.WriteLine($"{meth}({x}, {y}) = {result}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        private static async Task CallFact()
        {
            if (!await CheckConnection())
            {
                return;
            }

            try
            {
                var f = Convert.ToInt32(x);
                Console.WriteLine($"Calling FACT({f})...");
                int result = await _connection.InvokeAsync<int>("FACT", f);
                Console.WriteLine($"FACT({f}) = {result}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        private static void WriteNewValues()
        {
            double res;
            while (true)
            {
                Console.Write("Write X value: ");
                var xValue = Console.ReadLine();

                if (double.TryParse(xValue, out res))
                {
                    x = res;
                    break;
                }

                Console.WriteLine("We need double value");
            }
            while (true)
            {
                Console.Write("Write Y value: ");
                var yValue = Console.ReadLine();

                if (double.TryParse(yValue, out res))
                {
                    y = res;
                    break;
                }

                Console.WriteLine("We need double value");
            }

            Console.Clear();
        }

        private static async Task TestAllOperations()
        {
            if (!await CheckConnection())
            {
                return;
            }

            var random = new Random();
            var x = random.Next(-1000, 1000) / 100d;
            var y = random.Next(-1000, 1000) / 100d;
            var methods = new List<string> { "SUM", "SUB", "MUL", "DIV" };

            Console.WriteLine("Testing all operations...\n");

            try
            {
                foreach (var method in methods)
                {
                    double result = await _connection.InvokeAsync<double>(method, x, y);
                    Console.WriteLine($"{method}({x}, {y}) = {result}");
                }

                int f = Convert.ToInt32(x);
                int factResult = await _connection.InvokeAsync<int>("FACT", f);
                Console.WriteLine($"FACT({f}) = {factResult}");

                await TestErrorCases();

                Console.WriteLine("All tests completed successfully!");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Test failed: {ex.Message}");
            }
        }

        private static async Task TestErrorCases()
        {
            Console.WriteLine();
            Console.WriteLine("Testing error cases...");

            try
            {
                await _connection.InvokeAsync<double>("DIV", 10d, 0d);
                Console.WriteLine("All correct in test but y uncorrect");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }

            try
            {
                await _connection.InvokeAsync<int>("FACT", 20);
                Console.WriteLine("All correct in test but x uncorrect");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }

            try
            {
                await _connection.InvokeAsync<int>("FACT", -5);
                Console.WriteLine("All correct in test but x uncorrect");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
            }
        }

        private static async Task<bool> CheckConnection()
        {
            if (_connection?.State == HubConnectionState.Connected)
            {
                return true;
            }

            Console.WriteLine("Not connected to server.");

            Console.Write("Would you like to try to reconnect? (y/n): ");
            var response = (Console.ReadKey().KeyChar.ToString().ToLower());
            Console.WriteLine();

            if (response == "y")
            {
                await InitializeConnection();
                return _connection?.State == HubConnectionState.Connected;
            }

            return false;
        }

        private static async Task Disconnect()
        {
            if (_connection != null)
            {
                await _connection.StopAsync();
                await _connection.DisposeAsync();
                Console.WriteLine("Disconnected from server.");
            }
        }
    }
}