namespace e_library_backend.Models;

public class Book
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public decimal Price { get; set; }

    public int PublisherId { get; set; }
    public Publisher? Publisher { get; set; }

    public int AuthorId { get; set; }
    public Author? Author { get; set; }
}



