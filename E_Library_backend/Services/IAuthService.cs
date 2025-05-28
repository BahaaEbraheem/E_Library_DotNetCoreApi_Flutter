using E_Library.API.DTOs;

namespace E_Library.API.Services;

public interface IAuthService
{
    Task<string?> AuthenticateAsync(string username, string password);
    Task<bool> RegisterUserAsync(RegisterUserDto userDto);
}



