using e_library_backend.Data;
using e_library_backend.Models;
using Microsoft.EntityFrameworkCore;

namespace e_library_backend.Repositories;

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

    public async Task<Author?> GetAuthorByIdAsync(int id)
    {
        return await _context.Authors.FindAsync(id);
    }
}
