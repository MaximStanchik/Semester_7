using laba_4.Models;
using System.Collections.Generic;

namespace laba_4.Services.Interfaces;

public interface IJsonRpcProcessor
{
    Task<JsonRpcResponse> ProcessPequestAsync(JsonRpcRequest request);
    Task<List<JsonRpcResponse>> ProcessBatchAsync(List<JsonRpcRequest> requests);
}
