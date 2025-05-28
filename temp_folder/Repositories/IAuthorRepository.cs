using E_Library.API.Models;

namespace E_Library.API.Repositories;

public interface IAuthorRepository
{
    Task<IEnumerable<Author>> GetAllAuthorsAsync();
    Task<IEnumerable<Author>> SearchAuthorsByNameAsync(string name);
    Task<Author> CreateAuthorAsync(Author author);
}