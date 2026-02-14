using laba_4.Services.Interfaces;
using laba_4.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers()
    .AddNewtonsoftJson(options =>
    {
        options.SerializerSettings.NullValueHandling = Newtonsoft.Json.NullValueHandling.Ignore;
    });

builder.Services.AddScoped<IMathService, MathService>();
builder.Services.AddScoped<IJsonRpcProcessor, JsonRpcProcessor>();
builder.Services.AddSingleton<ISseService, SseService>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.MapGet("/", async context =>
{
    await Task.CompletedTask;
    context.Response.Redirect("/sse/subscribe");
});

app.Run();