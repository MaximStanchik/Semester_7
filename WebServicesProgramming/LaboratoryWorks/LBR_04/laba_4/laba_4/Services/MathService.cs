using laba_4.Services.Interfaces;

namespace laba_4.Services;

public class MathService : IMathService
{
    public double Sum(double x, double y) => x + y;

    public double Sub(double x, double y) => x - y;

    public double Mul(double x, double y) => x * y;

    public double Div(double x, double y) => y != 0 ? x / y : throw new DivideByZeroException("Your y = 0");

    public int Fact(int x)
    {
        if (x < 0)
        {
            throw new ArgumentException("Uncorrect X");
        }

        int result = 1;

        for (int i = 2; i <= x; i++)
        {
            result *= i;
            if (result < 0)
            {
                throw new OverflowException("Your X is too big");
            }
        }

        return result;
    }
}
