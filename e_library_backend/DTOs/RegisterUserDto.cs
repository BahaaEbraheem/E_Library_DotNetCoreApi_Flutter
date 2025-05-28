using System.ComponentModel.DataAnnotations;

namespace e_library_backend.DTOs;

public class RegisterUserDto
{
    [Required]
    public string Username { get; set; } = string.Empty;

    [Required]
    [MinLength(6)]
    public string Password { get; set; } = string.Empty;

    [Required]
    public string FName { get; set; } = string.Empty;

    [Required]
    public string LName { get; set; } = string.Empty;

    public bool IsAdmin { get; set; } = false;
}