using E_Library.API.Data;
using E_Library.API.Models;
using Microsoft.EntityFrameworkCore;

namespace E_Library.API.Repositories;

public class AuthorRepository : IAuthorRepository
{
    private readonly LibraryDbContext _context;

    public AuthorRepository(LibraryDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Author>> GetAllAuthorsAsync()
    {
        return await _context.Authors.ToListAsync();
    }

    public async Task<IEnumerable<Author>> SearchAuthorsByNameAsync(string name)
    {
        return await _context.Authors
            .Where(a => a.FName.Contains(name) || a.LName.Contains(name))
            .ToListAsync();
    }

    public async Task<Author> CreateAuthorAsync(Author author)
    {
        _context.Authors.Add(author);
        await _context.SaveChangesAsync();
        return author;
    }
}