using e_library_backend.Data;
using e_library_backend.DTOs;
using e_library_backend.Models;
using Microsoft.EntityFrameworkCore;

namespace e_library_backend.Repositories;

public class BookRepository : IBookRepository
{
    private readonly LibraryDbContext _context;

    public BookRepository(LibraryDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<BookDto>> GetAllBooksAsync()
    {
        var books = await _context.Books
            .Include(b => b.Author)
            .Include(b => b.Publisher)
            .ToListAsync();

        return books.Select(b => new BookDto
        {
            Id = b.Id,
            Title = b.Title,
            Type = b.Type,
            Price = b.Price,
            PublisherId = b.PublisherId,
            PublisherName = b.Publisher?.PName ?? string.Empty,
            AuthorId = b.AuthorId,
            AuthorFullName = $"{b.Author?.FName} {b.Author?.LName}".Trim()
        });
    }

    public async Task<IEnumerable<BookDto>> SearchBooksByTitleAsync(string title)
    {
        var books = await _context.Books
            .Include(b => b.Author)
            .Include(b => b.Publisher)
            .Where(b => b.Title.Contains(title))
            .ToListAsync();

        return books.Select(b => new BookDto
        {
            Id = b.Id,
            Title = b.Title,
            Type = b.Type,
            Price = b.Price,
            PublisherId = b.PublisherId,
            PublisherName = b.Publisher?.PName ?? string.Empty,
            AuthorId = b.AuthorId,
            AuthorFullName = $"{b.Author?.FName} {b.Author?.LName}".Trim()
        });
    }

    public async Task<Book> CreateBookAsync(CreateBookDto bookDto)
    {
        var book = new Book
        {
            Title = bookDto.Title,
            Type = bookDto.Type,
            Price = bookDto.Price,
            PublisherId = bookDto.PublisherId,
            AuthorId = bookDto.AuthorId
        };

        _context.Books.Add(book);
        await _context.SaveChangesAsync();

        return book;
    }

    public async Task<BookDto?> GetBookByIdAsync(int id)
    {
        var book = await _context.Books
            .Include(b => b.Author)
            .Include(b => b.Publisher)
            .FirstOrDefaultAsync(b => b.Id == id);

        if (book == null)
            return null;

        return new BookDto
        {
            Id = book.Id,
            Title = book.Title,
            Type = book.Type,
            Price = book.Price,
            PublisherId = book.PublisherId,
            PublisherName = book.Publisher?.PName ?? string.Empty,
            AuthorId = book.AuthorId,
            AuthorFullName = $"{book.Author?.FName} {book.Author?.LName}".Trim()
        };
    }

    public async Task<IEnumerable<BookDto>> GetBooksByAuthorIdAsync(int authorId)
    {
        var books = await _context.Books
            .Include(b => b.Author)
            .Include(b => b.Publisher)
            .Where(b => b.AuthorId == authorId)
            .ToListAsync();

        return books.Select(b => new BookDto
        {
            Id = b.Id,
            Title = b.Title,
            Type = b.Type,
            Price = b.Price,
            PublisherId = b.PublisherId,
            PublisherName = b.Publisher?.PName ?? string.Empty,
            AuthorId = b.AuthorId,
            AuthorFullName = $"{b.Author?.FName} {b.Author?.LName}".Trim()
        });
    }

    public async Task<IEnumerable<BookDto>> GetBooksByPublisherIdAsync(int publisherId)
    {
        var books = await _context.Books
            .Include(b => b.Author)
            .Include(b => b.Publisher)
            .Where(b => b.PublisherId == publisherId)
            .ToListAsync();

        return books.Select(b => new BookDto
        {
            Id = b.Id,
            Title = b.Title,
            Type = b.Type,
            Price = b.Price,
            PublisherId = b.PublisherId,
            PublisherName = b.Publisher?.PName ?? string.Empty,
            AuthorId = b.AuthorId,
            AuthorFullName = $"{b.Author?.FName} {b.Author?.LName}".Trim()
        });
    }
}

