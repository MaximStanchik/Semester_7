namespace ResultsAuthenticate.Interfaces;

public interface IAuthenticateService
{
    string? Authenticate(string login, string password);
}