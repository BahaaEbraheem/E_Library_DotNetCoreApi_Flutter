namespace E_Library.API.Services;

public class PasswordService : IPasswordService
{
    // In a real app, use a proper password hashing library like BCrypt
    public string HashPassword(string password)
    {
        // This is a placeholder. In a real app, use a secure hashing algorithm
        return password;
    }

    public bool VerifyPassword(string password, string hash)
    {
        // This is a placeholder. In a real app, use a secure verification method
        return password == hash;
    }
}

