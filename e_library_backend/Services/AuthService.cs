using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using e_library_backend.Data;
using e_library_backend.DTOs;
using e_library_backend.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace e_library_backend.Services;

public class AuthService : IAuthService
{
    private readonly LibraryDbContext _context;
    private readonly IPasswordService _passwordService;
    private readonly IConfiguration _configuration;

    public AuthService(LibraryDbContext context, IPasswordService passwordService, IConfiguration configuration)
    {
        _context = context;
        _passwordService = passwordService;
        _configuration = configuration;
    }

    public async Task<string?> AuthenticateAsync(string username, string password)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Username == username);

        if (user == null || !_passwordService.VerifyPassword(password, user.Password))
        {
            return null;
        }

        // Generate JWT token
        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"] ?? "YourSecretKeyHere12345678901234567890");

        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Role, user.IsAdmin ? "Admin" : "User")
        };

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.AddDays(7),
            SigningCredentials = new SigningCredentials(
                new SymmetricSecurityKey(key),
                SecurityAlgorithms.HmacSha256Signature)
        };

        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }

    public async Task<bool> RegisterUserAsync(RegisterUserDto userDto)
    {
        // Check if username already exists
        if (await _context.Users.AnyAsync(u => u.Username == userDto.Username))
        {
            return false;
        }

        // Create new user
        var user = new User
        {
            Username = userDto.Username,
            Password = _passwordService.HashPassword(userDto.Password),
            FName = userDto.FName,
            LName = userDto.LName,
            IsAdmin = userDto.IsAdmin
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return true;
    }
}


