using Microsoft.AspNetCore.Mvc;

namespace laba_4.Models;

public class JsonRpcRequest
{
    public string jsonrpc { get; set; } = "2.0";
    public string Method { get; set; } = string.Empty;
    public object? Params { get; set; }
    public int? Id { get; set; }
};
