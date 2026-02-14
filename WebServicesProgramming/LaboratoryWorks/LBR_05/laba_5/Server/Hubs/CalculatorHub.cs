using Microsoft.AspNetCore.SignalR;

namespace Server.Hubs
{
    public class CalculatorHub : Hub
    {
        public double SUM(double x, double y) => x + y;

        public double SUB(double x, double y) => x - y;

        public double MUL(double x, double y) => x * y;

        public double DIV(double x, double y)
        {
            if (y == 0)
            {
                throw new HubException("Y = 0");
            }

            return x / y;
        }

        public int FACT(int x)
        {
            if (x < 0)
            {
                throw new HubException("x uncorrect");
            }

            if (x > 12)
            {
                throw new HubException("x too big");
            }

            int result = 1;

            for (int i = 2; i <= x; i++)
            {
                result *= i;
            }

            return result;
        }
    }
}
