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

    public async Task<bool> UpdateAuthorAsync(int id, Author authorData)
    {
        var author = await _context.Authors.FindAsync(id);
        if (author == null)
            return false;

        // تحديث بيانات المؤلف
        author.FName = authorData.FName;
        author.LName = authorData.LName;
        author.Country = authorData.Country;
        author.City = authorData.City;
        author.Address = authorData.Address;

        _context.Authors.Update(author);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> DeleteAuthorAsync(int id)
    {
        try
        {
            var author = await _context.Authors.FindAsync(id);
            if (author == null)
                return false;

            // Check if author has books
            var hasBooks = await _context.Books
                .AnyAsync(b => b.AuthorId == id);

            if (hasBooks)
            {
                // Optional: Handle books or throw exception
                // For now, we'll just return false
                return false;
            }

            _context.Authors.Remove(author);
            await _context.SaveChangesAsync();
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error deleting author: {ex.Message}");
            return false;
        }
    }
}



