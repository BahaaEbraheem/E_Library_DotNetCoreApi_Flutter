namespace E_Library.API.DTOs;

public class UserDto
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string FName { get; set; } = string.Empty;
    public string LName { get; set; } = string.Empty;
    public bool IsAdmin { get; set; }
}


