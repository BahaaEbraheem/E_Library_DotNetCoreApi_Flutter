using E_Library.API.Filters;
using E_Library.API.Models;
using E_Library.API.Repositories;

namespace E_Library.API.Endpoints;

public static class AuthorEndpoints
{
    public static void MapAuthorEndpoints(this IEndpointRouteBuilder routes)
    {
        var group = routes.MapGroup("/api");
        
        // Get all authors
        group.MapGet("/authors", async (IAuthorRepository authorRepository) =>
            await authorRepository.GetAllAuthorsAsync());

        // Search authors by name
        group.MapGet("/authors/search", async (string name, IAuthorRepository authorRepository) =>
            await authorRepository.SearchAuthorsByNameAsync(name));

        // Create new author (admin only)
        group.MapPost("/authors", async (Author author, IAuthorRepository authorRepository) =>
        {
            var createdAuthor = await authorRepository.CreateAuthorAsync(author);
            return Results.Created($"/api/authors/{createdAuthor.Id}", createdAuthor);
        })
        .AddEndpointFilter<AdminAuthFilter>();
    }
}