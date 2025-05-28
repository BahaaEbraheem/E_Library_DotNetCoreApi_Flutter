using System.ComponentModel.DataAnnotations;

namespace E_Library.API.DTOs;

public class CreateBookDto
{
    [Required]
    public string Title { get; set; } = string.Empty;
    
    [Required]
    public string Type { get; set; } = string.Empty;
    
    [Required]
    [Range(0.01, double.MaxValue)]
    public decimal Price { get; set; }
    
    [Required]
    public int PublisherId { get; set; }
    
    [Required]
    public int AuthorId { get; set; }
}