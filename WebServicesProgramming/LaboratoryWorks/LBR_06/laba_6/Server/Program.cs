using Server.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddGrpc();

builder.Services.AddLogging(configure =>
{
    configure.AddConsole();
    configure.AddDebug();
});

var app = builder.Build();

app.MapGrpcService<CalculatorService>();

app.MapGet("/", () => "gRPC Server is running.");

app.Run();