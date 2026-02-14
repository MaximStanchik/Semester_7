using laba_3.Models;
using laba_3.Services.Interfaces;
using Newtonsoft.Json.Linq;

namespace laba_3.Services;

public class JsonRpcProcessor(IMathService mathService) : IJsonRpcProcessor
{
    private readonly IMathService _mathService = mathService;


    public async Task<JsonRpcResponse> ProcessPequestAsync(JsonRpcRequest request)
    {
        await Task.CompletedTask;

        try
        {
            if (request.Method == null)
            {
                return CreateError("Invalid method", request.Id);
            }

            object result = request.Method.ToUpper() switch
            {
                "SUM" => ProcSum(request.Params, request.Method),
                "SUB" => ProcSub(request.Params, request.Method),
                "MUL" => ProcMul(request.Params, request.Method),
                "DIV" => ProcDiv(request.Params, request.Method),
                "FACT" => ProcFact(request.Params, request.Method),
                _ => throw new NotImplementedException("This method i dont know")
            };

            return new JsonRpcResponse
            {
                Result = result,
                Id = request.Id
            };
        }
        catch (Exception ex)
        {
            return CreateError(ex.Message, request.Id);
        }
    }

    public async Task<List<JsonRpcResponse>> ProcessBatchAsync(List<JsonRpcRequest> requests)
    {
        var tasks = requests.Select(ProcessPequestAsync);
        var res = await Task.WhenAll(tasks);
        return res.ToList();
    }

    private double ProcSum(object? param, string method)
    {
        var (x, y) = ExtractParams(param);
        return _mathService.Sum(x, y);
    }
    private double ProcSub(object? param, string method)
    {
        var (x, y) = ExtractParams(param);
        return _mathService.Sub(x, y);
    }
    private double ProcMul(object? param, string method)
    {
        var (x, y) = ExtractParams(param);
        return _mathService.Mul(x, y);
    }
    private double ProcDiv(object? param, string method)
    {
        var (x, y) = ExtractParams(param);
        return _mathService.Div(x, y);
    }
    private int ProcFact(object? param, string method)
    {
        var x = ExtractParam(param);
        return _mathService.Fact(x);
    }

    private (double, double) ExtractParams(object? param)
    {
        if (param == null)
        {
            throw new ArgumentException("Params is empty");
        }

        if (param is JArray paramArray)
        {
            if (paramArray.Count < 2)
            {
                throw new ArgumentException("You need get me 2 params");
            }

            return (paramArray[0].Value<double>(), paramArray[1].Value<double>());
        }
        else if (param is JObject paramObj)
        {
            var x = paramObj["x"];
            var y = paramObj["y"];

            if (x == null || y == null)
            {
                throw new ArgumentException("Some params have NULL");
            }

            return (x.Value<double>(), y.Value<double>());
        }

        throw new ArgumentException("Give me params in Array or with name");
    }

    private int ExtractParam(object? param)
    {
        if (param == null)
        {
            throw new ArgumentException("Params is empty");
        }

        if (param is JArray paramArray)
        {
            if (paramArray.Count < 1)
            {
                throw new ArgumentException("You need get me 1 params");
            }

            return paramArray[0].Value<int>();
        }
        else if (param is JObject paramObj)
        {
            var x = paramObj["x"];

            if (x == null)
            {
                throw new ArgumentException("Your params have NULL");
            }

            return x.Value<int>();
        }

        throw new ArgumentException("Give me params in Array or with name");
    }

    private JsonRpcResponse CreateError(string message, int? id)
    {
        return new JsonRpcResponse
        {
            Error = message,
            Id = id
        };
    }
}

