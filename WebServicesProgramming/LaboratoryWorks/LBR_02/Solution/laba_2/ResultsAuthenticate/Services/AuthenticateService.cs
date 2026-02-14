using Microsoft.IdentityModel.Tokens;
using ResultsAuthenticate.Interfaces;
using System.IdentityModel.Tokens.Jwt;
using System.IO.Pipes;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace ResultsAuthenticate.Services;

public class AuthenticateService(string securetyKey) : IAuthenticateService
{
    private readonly List<User> users = new()
    {
        new User("reader", "readme", "READER"),
        new User("writer", "writeme", "WRITER")
    };
    private readonly string _securetyKey = securetyKey;

    public string? Authenticate(string login, string password)
    {
        var user = users.FirstOrDefault(u => u.Login == login && u.Password == password);
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
                new Claim(ClaimTypes.Name, user.Login),
                new Claim(ClaimTypes.Role, user.Role)
            }),
            Expires = DateTime.UtcNow.AddHours(1),
            SigningCredentials = new SigningCredentials(
                new SymmetricSecurityKey(key),
                SecurityAlgorithms.HmacSha256Signature)
        };

        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }
}
