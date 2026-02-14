using laba_3.Models;
using laba_3.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace laba_3.Controllers;

[ApiController]
[Route("jsonrpc")]
public class JsonRpcController(IJsonRpcProcessor jsonProcessor) : ControllerBase
{
    private readonly IJsonRpcProcessor _rpcProcessor = jsonProcessor;

    [HttpPost]
    public async Task<IActionResult> HandleRequest([FromBody] object req)
    {
        try
        {
            if (req is JArray batchRequest)
            {
                var requests = batchRequest.ToObject<List<JsonRpcRequest>>();

                if (requests == null || !requests.Any())
                {
                    return BadRequest(CreateErrorResponse("Invalid Request", null));
                }

                var responses = await _rpcProcessor.ProcessBatchAsync(requests);
                return Ok(responses);
            }
            else if (req is JObject singleRequest)
            {
                var rpcRequest = singleRequest.ToObject<JsonRpcRequest>();

                if (rpcRequest == null)
                {
                    return BadRequest(CreateErrorResponse("Invalid Request", null));
                }

                var response = await _rpcProcessor.ProcessPequestAsync(rpcRequest);

                return Ok(response);
            }

            return BadRequest(CreateErrorResponse("Invalid Request", null));
        }
        catch (Exception ex)
        {
            return BadRequest(CreateErrorResponse(ex.Message, null));
        }
    }

    private JsonRpcResponse CreateErrorResponse(string message, int? id)
    {
        return new JsonRpcResponse
        {
            Error = message,
            Id = id
        };
    }
}
