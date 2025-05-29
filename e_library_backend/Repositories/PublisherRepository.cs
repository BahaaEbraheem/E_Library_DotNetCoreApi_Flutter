using e_library_backend.Data;
using e_library_backend.Models;
using Microsoft.EntityFrameworkCore;

namespace e_library_backend.Repositories;

public class PublisherRepository : IPublisherRepository
{
    private readonly LibraryDbContext _context;

    public PublisherRepository(LibraryDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Publisher>> GetAllPublishersAsync()
    {
        return await _context.Publishers.ToListAsync();
    }

    public async Task<IEnumerable<Publisher>> SearchPublishersByNameAsync(string name)
    {
        return await _context.Publishers
            .Where(p => p.PName.Contains(name))
            .ToListAsync();
    }

    public async Task<Publisher> CreatePublisherAsync(Publisher publisher)
    {
        _context.Publishers.Add(publisher);
        await _context.SaveChangesAsync();
        return publisher;
    }

    public async Task<Publisher?> GetPublisherByIdAsync(int id)
    {
        return await _context.Publishers.FindAsync(id);
    }
}
