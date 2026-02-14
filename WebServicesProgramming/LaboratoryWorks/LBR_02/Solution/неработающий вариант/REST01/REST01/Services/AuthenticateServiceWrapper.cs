using ResultsAuthenticate.Interfaces;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace REST01.Services;

public class AuthenticateServiceWrapper : IAuthenticateService
{
    private readonly string _jwtKey;
    private readonly string _issuer;
    private readonly string _audience;

    public AuthenticateServiceWrapper(string jwtKey, string issuer, string audience)
    {
        _jwtKey = jwtKey;
        _issuer = issuer;
        _audience = audience;
    }

    public string? Authenticate(string login, string password)
    {
        // Проверяем учетные данные напрямую
        if (!IsValidCredentials(login, password))
        {
            return null;
        }

        // Создаем токен точно так же, как в оригинальном AuthenticateService
        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.ASCII.GetBytes(_jwtKey);

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.Name, login),
                new Claim(ClaimTypes.Role, GetRoleByLogin(login))
            }),
            Expires = DateTime.UtcNow.AddHours(1),
            Issuer = _issuer,
            Audience = _audience,
            SigningCredentials = new SigningCredentials(
                new SymmetricSecurityKey(key),
                SecurityAlgorithms.HmacSha256Signature)
        };

        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }

    private bool IsValidCredentials(string login, string password)
    {
        return (login == "reader" && password == "readme") || 
               (login == "writer" && password == "writeme");
    }

    private string GetRoleByLogin(string login)
    {
        return login switch
        {
            "reader" => "READER",
            "writer" => "WRITER",
            _ => "READER"
        };
    }
}