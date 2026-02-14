namespace laba_4.Services.Interfaces;

public interface ISseService
{
    Task SendEventAsync(string eventType, object data);
    void AddClient(HttpContext context);
    void RemoveClient(HttpContext context);
}
