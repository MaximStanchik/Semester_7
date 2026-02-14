using RestService.Services;

namespace RestService.config;

public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddControllersWithViews();
        
        services.AddDistributedMemoryCache();
        services.AddSession(options =>
        {
            options.IdleTimeout = TimeSpan.FromMinutes(30); 
            options.Cookie.HttpOnly = true;
            options.Cookie.IsEssential = true;
        });

        services.AddHttpContextAccessor();
        services.AddScoped<IStackService, StackService>();
    }

    public void Configure(IApplicationBuilder app)
    {
        app.UseRouting();
        
        app.UseSession();
        
        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllerRoute(
                name: "default",
                pattern: "{controller=Stack}/{action=Index}/{id?}");
            endpoints.MapControllers();
        });
    }
}