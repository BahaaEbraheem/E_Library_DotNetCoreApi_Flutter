using e_library_backend.Models;

namespace e_library_backend.Repositories;

public interface IAuthorRepository
{
    Task<IEnumerable<Author>> GetAllAuthorsAsync();
    Task<IEnumerable<Author>> SearchAuthorsByNameAsync(string name);
    Task<Author> CreateAuthorAsync(Author author);
    Task<Author?> GetAuthorByIdAsync(int id);
}
