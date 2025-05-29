using e_library_backend.Models;

namespace e_library_backend.Repositories;

public interface IUserRepository
{
    Task<User?> GetUserByIdAsync(int id);
    Task<User?> GetUserByUsernameAsync(string username);
    Task<bool> IsUserAdminByTokenAsync(string token);
}