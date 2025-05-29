using e_library_backend.DTOs;
using e_library_backend.Filters;
using e_library_backend.Repositories;

namespace e_library_backend.Endpoints;

public static class BookEndpoints
{
    public static void MapBookEndpoints(this IEndpointRouteBuilder routes)
    {
        var group = routes.MapGroup("/api");

        // Get all books
        group.MapGet("/books", async (IBookRepository bookRepository) =>
            await bookRepository.GetAllBooksAsync());

        // Search books by title
        group.MapGet("/books/search", async (string title, IBookRepository bookRepository) =>
            await bookRepository.SearchBooksByTitleAsync(title));

        // Create new book (admin only)
        group.MapPost("/books", async (CreateBookDto bookDto, IBookRepository bookRepository) =>
        {
            var book = await bookRepository.CreateBookAsync(bookDto);
            return Results.Created($"/api/books/{book.Id}", book);
        })
        .AddEndpointFilter<ValidationFilter<CreateBookDto>>()
        .AddEndpointFilter<AdminAuthFilter>();

        // Get book by ID
        group.MapGet("/books/{id}", async (int id, IBookRepository bookRepository) =>
        {
            var book = await bookRepository.GetBookByIdAsync(id);
            if (book == null)
                return Results.NotFound();
            
            return Results.Ok(book);
        });

        // Get books by author ID
        group.MapGet("/books/author/{authorId}", async (int authorId, IBookRepository bookRepository) =>
        {
            var books = await bookRepository.GetBooksByAuthorIdAsync(authorId);
            return Results.Ok(books);
        });

        // Get books by publisher ID
        group.MapGet("/books/publisher/{publisherId}", async (int publisherId, IBookRepository bookRepository) =>
        {
            var books = await bookRepository.GetBooksByPublisherIdAsync(publisherId);
            return Results.Ok(books);
        });
    }
}


