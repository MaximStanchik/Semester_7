using laba_4.Services.Interfaces;
using System.Text.Json;

namespace laba_4.Services;

public class SseService : ISseService
{
    private readonly List<HttpContext> _clients = new();
    private readonly object _clientsLock = new();

    public async Task SendEventAsync(string eventType, object data)
    {
        List<HttpContext> clientsCopy;
        lock (_clientsLock)
        {
            clientsCopy = new List<HttpContext>(_clients);
        }

        var jsonData = JsonSerializer.Serialize(data);
        var message = $"event: {eventType}\ndata: {jsonData}\n\n";

        var tasks = clientsCopy.Select(async client =>
        {
            try
            {
                await client.Response.WriteAsync(message);
                await client.Response.Body.FlushAsync();
            }
            catch
            {
                RemoveClient(client);
            }
        });

        await Task.WhenAll(tasks);
    }

    public void AddClient(HttpContext context)
    {
        lock (_clientsLock)
        {
            _clients.Add(context);
        }
    }

    public void RemoveClient(HttpContext context)
    {
        lock (_clientsLock)
        {
            _clients.Remove(context);
        }
    }
}