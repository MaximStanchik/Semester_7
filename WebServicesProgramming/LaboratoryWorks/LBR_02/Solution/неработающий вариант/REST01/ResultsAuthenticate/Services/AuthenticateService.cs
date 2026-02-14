namespace ResultsAuthenticate.Services;

using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using ResultsAuthenticate.DTO;
using ResultsAuthenticate.Interfaces;


public class AuthenticateService : IAuthenticateService
{
    private readonly List<UserDTO> users = new()
    {
        new UserDTO("reader", "readme", "READER"),
        new UserDTO("writer", "writeme", "WRITER")
    };
    private readonly string _securetyKey;
    private readonly string _issuer;
    private readonly string _audience;

    public AuthenticateService(string securetyKey, string issuer = "REST01", string audience = "REST01")
    {
        _securetyKey = securetyKey;
        _issuer = issuer;
        _audience = audience;
    }

    public string? Authenticate(string login, string password)
    {
        var user = users.FirstOrDefault(u => u.getLogin() == login && u.getPassword() == password);
        if (user == null)
        {
            return null;
        }

        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.ASCII.GetBytes(_securetyKey);

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.Name, user.getLogin()),
                new Claim(ClaimTypes.Role, user.getRole())
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
}