using e_library_backend.Filters;
using e_library_backend.Models;
using e_library_backend.Repositories;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace e_library_backend.Endpoints;

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
        group.MapPost("/authors", async (HttpRequest request, IAuthorRepository authorRepository) =>
        {
            try
            {
                // قراءة البيانات من الطلب بطريقة أفضل
                using var reader = new StreamReader(request.Body);
                var requestBody = await reader.ReadToEndAsync();

                // طباعة البيانات المستلمة للتشخيص
                Console.WriteLine($"Received data: {requestBody}");

                var options = new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true,
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                    DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
                    WriteIndented = true
                };

                var authorData = JsonSerializer.Deserialize<Author>(requestBody, options);

                if (authorData == null)
                    return Results.BadRequest("Invalid author data");

                // طباعة البيانات بعد التحويل
                Console.WriteLine($"Deserialized data: FName={authorData.FName}, LName={authorData.LName}");

                var createdAuthor = await authorRepository.CreateAuthorAsync(authorData);
                return Results.Created($"/api/authors/{createdAuthor.Id}", createdAuthor);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error creating author: {ex.Message}");
                return Results.BadRequest($"Error creating author: {ex.Message}");
            }
        })
        .RequireAuthorization(policy => policy.RequireRole("Admin"));

        // Get author by ID
        group.MapGet("/authors/{id}", async (int id, IAuthorRepository authorRepository) =>
        {
            var author = await authorRepository.GetAuthorByIdAsync(id);
            if (author == null)
                return Results.NotFound();

            return Results.Ok(author);
        });

        // Update author (admin only)
        group.MapPut("/authors/{id}", async (int id, HttpRequest request, IAuthorRepository authorRepository) =>
        {
            try
            {
                // قراءة البيانات من الطلب
                using var reader = new StreamReader(request.Body);
                var requestBody = await reader.ReadToEndAsync();

                // طباعة البيانات المستلمة للتشخيص
                Console.WriteLine($"Received data for update: {requestBody}");

                var options = new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true,
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                    DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
                    WriteIndented = true
                };

                var authorData = JsonSerializer.Deserialize<Author>(requestBody, options);

                if (authorData == null)
                    return Results.BadRequest("Invalid author data");

                // طباعة البيانات بعد التحويل
                Console.WriteLine($"Deserialized data for update: FName={authorData.FName}, LName={authorData.LName}");

                var success = await authorRepository.UpdateAuthorAsync(id, authorData);
                if (!success)
                    return Results.NotFound();

                var updatedAuthor = await authorRepository.GetAuthorByIdAsync(id);
                return Results.Ok(updatedAuthor);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating author: {ex.Message}");
                return Results.BadRequest($"Error updating author: {ex.Message}");
            }
        })
        .RequireAuthorization(policy => policy.RequireRole("Admin"));

        // Add this endpoint for deleting authors
        group.MapDelete("/authors/{id}", async (int id, IAuthorRepository authorRepository) =>
        {
            try
            {
                var author = await authorRepository.GetAuthorByIdAsync(id);
                if (author == null)
                    return Results.NotFound();

                var success = await authorRepository.DeleteAuthorAsync(id);
                if (!success)
                    return Results.NotFound();

                return Results.Ok(new { message = "Author deleted successfully" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting author: {ex.Message}");
                return Results.BadRequest($"Error deleting author: {ex.Message}");
            }
        })
        .RequireAuthorization(policy => policy.RequireRole("Admin"));
    }
}



