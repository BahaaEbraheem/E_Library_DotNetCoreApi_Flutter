using E_Library.API.DTOs;
using E_Library.API.Models;

namespace E_Library.API.Repositories;

public interface IBookRepository
{
    Task<IEnumerable<BookDto>> GetAllBooksAsync();
    Task<IEnumerable<BookDto>> SearchBooksByTitleAsync(string title);
    Task<Book> CreateBookAsync(CreateBookDto bookDto);
}