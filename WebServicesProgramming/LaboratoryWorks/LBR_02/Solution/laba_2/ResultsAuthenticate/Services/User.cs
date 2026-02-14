namespace ResultsAuthenticate.Services;

public class User(string login, string password, string role)
{
    public string Login { get; set; } = login;
    public string Password { get; set; } = password;
    public string Role { get; set; } = role;
}
