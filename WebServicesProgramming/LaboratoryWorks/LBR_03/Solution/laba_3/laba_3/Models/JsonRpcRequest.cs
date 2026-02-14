using Microsoft.AspNetCore.Mvc;

namespace laba_3.Models;

public class JsonRpcRequest 
{
    public string Method { get; set; } = string.Empty;
    public object? Params { get; set; }
    public int? Id { get; set; }
};
