using Microsoft.AspNetCore.Mvc;

namespace laba_3.Models;

public class JsonRpcResponse 
{
    public object? Result { get; set; }
    public string? Error { get; set; } 
    public int? Id { get; set; }
}
