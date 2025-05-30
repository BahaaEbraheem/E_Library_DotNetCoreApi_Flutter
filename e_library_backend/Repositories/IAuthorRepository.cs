using e_library_backend.Models;

namespace e_library_backend.Repositories;

public interface IAuthorRepository
{
    Task<IEnumerable<Author>> GetAllAuthorsAsync();
    Task<Author?> GetAuthorByIdAsync(int id);
    Task<IEnumerable<Author>> SearchAuthorsByNameAsync(string name);
    Task<Author> CreateAuthorAsync(Author author);
    Task<bool> UpdateAuthorAsync(int id, Author author);
    Task<bool> DeleteAuthorAsync(int id);
}



