namespace e_library_backend.Models;

public class Publisher
{
    public int Id { get; set; }
    public string PName { get; set; } = string.Empty;
    public string? City { get; set; }

    public ICollection<Book>? Books { get; set; }
}
