using laba_4.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace laba_4.Controllers;

[ApiController]
[Route("sse")]
public class SseController(ISseService sseService) : ControllerBase
{
    private readonly ISseService _sseService = sseService;

    [HttpGet]
    [Route("subscribe")]
    public async Task Subscribe()
    {
        Response.Headers.Append("Content-Type", "text/event-stream");
        Response.Headers.Append("Cache-Control", "no-cache");
        Response.Headers.Append("Connection", "keep-alive");
        Response.Headers.Append("Access-Control-Allow-Origin", "*");

        _sseService.AddClient(HttpContext);

        try
        {
            await Response.WriteAsync("data: Connected to SSE server\n\n");
            await Response.Body.FlushAsync();

            while (!HttpContext.RequestAborted.IsCancellationRequested)
            {
                await Task.Delay(1000);
            }
        }
        finally
        {
            _sseService.RemoveClient(HttpContext);
        }
    }
}