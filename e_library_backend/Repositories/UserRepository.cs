using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using e_library_backend.Data;
using e_library_backend.Models;
using Microsoft.EntityFrameworkCore;

namespace e_library_backend.Repositories;

public class UserRepository : IUserRepository
{
    private readonly LibraryDbContext _context;

    public UserRepository(LibraryDbContext context)
    {
        _context = context;
    }

    public async Task<User?> GetUserByIdAsync(int id)
    {
        return await _context.Users.FindAsync(id);
    }

    public async Task<User?> GetUserByUsernameAsync(string username)
    {
        return await _context.Users
            .FirstOrDefaultAsync(u => u.Username == username);
    }

    public async Task<bool> IsUserAdminByTokenAsync(string token)
    {
        try
        {
            // فك تشفير التوكن
            var tokenHandler = new JwtSecurityTokenHandler();
            var jwtToken = tokenHandler.ReadJwtToken(token);

            // استخراج معرف المستخدم من التوكن
            var userIdClaim = jwtToken.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
            if (userIdClaim == null)
                return false;

            // التحقق من وجود دور المسؤول
            var roleClaim = jwtToken.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role);
            if (roleClaim != null && roleClaim.Value == "Admin")
                return true;

            // إذا لم يكن هناك دور محدد، تحقق من قاعدة البيانات
            if (int.TryParse(userIdClaim.Value, out var userId))
            {
                var user = await GetUserByIdAsync(userId);
                return user?.IsAdmin ?? false;
            }

            return false;
        }
        catch
        {
            return false;
        }
    }
}