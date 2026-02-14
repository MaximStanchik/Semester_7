using laba_3.Models;
using System.Collections.Generic;

namespace laba_3.Services.Interfaces;

public interface IJsonRpcProcessor
{
    Task<JsonRpcResponse> ProcessPequestAsync(JsonRpcRequest request);
    Task<List<JsonRpcResponse>> ProcessBatchAsync(List<JsonRpcRequest> requests);
}
