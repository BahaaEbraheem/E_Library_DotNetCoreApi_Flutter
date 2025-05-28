using e_library_backend.DTOs;

namespace e_library_backend.Services;

public interface IAuthService
{
    Task<string?> AuthenticateAsync(string username, string password);
    Task<bool> RegisterUserAsync(RegisterUserDto userDto);
}



