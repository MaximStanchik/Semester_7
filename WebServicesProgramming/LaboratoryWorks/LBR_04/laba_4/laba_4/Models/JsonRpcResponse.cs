using Microsoft.AspNetCore.Mvc;

namespace laba_4.Models;

public class JsonRpcResponse
{
    public string jsonrpc { get; set; } = "2.0";
    public object? Result { get; set; }
    public JsonError? Error { get; set; }
    public int? Id { get; set; }
}
