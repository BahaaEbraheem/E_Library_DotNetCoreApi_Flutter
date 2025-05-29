using e_library_backend.DTOs;
using e_library_backend.Models;

namespace e_library_backend.Repositories;

public interface IBookRepository
{
    Task<IEnumerable<BookDto>> GetAllBooksAsync();
    Task<IEnumerable<BookDto>> SearchBooksByTitleAsync(string title);
    Task<Book> CreateBookAsync(CreateBookDto bookDto);
    Task<BookDto?> GetBookByIdAsync(int id);
    Task<IEnumerable<BookDto>> GetBooksByAuthorIdAsync(int authorId);
    Task<IEnumerable<BookDto>> GetBooksByPublisherIdAsync(int publisherId);
}

