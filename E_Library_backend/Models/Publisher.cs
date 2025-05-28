namespace E_Library.API.Models;

public class Publisher
{
    public int Id { get; set; }
    public string PName { get; set; } = string.Empty;
    public string? City { get; set; }
    
    public ICollection<Book>? Books { get; set; }
}
