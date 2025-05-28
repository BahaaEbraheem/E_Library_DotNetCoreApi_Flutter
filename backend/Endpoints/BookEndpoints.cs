using E_Library.API.DTOs;
using E_Library.API.Filters;
using E_Library.API.Repositories;

namespace E_Library.API.Endpoints;

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
    }
}