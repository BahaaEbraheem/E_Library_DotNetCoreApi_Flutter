namespace E_Library.API.Models;

public class Author
{
    public int Id { get; set; }
    public string FName { get; set; } = string.Empty;
    public string LName { get; set; } = string.Empty;
    public string? Country { get; set; }
    public string? City { get; set; }
    public string? Address { get; set; }
    
    public ICollection<Book>? Books { get; set; }
}
