using System.Text.Json;
using System.Text.Json.Serialization;
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
        group.MapPost("/books", async (HttpRequest request, IBookRepository bookRepository) =>
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

                var bookDto = JsonSerializer.Deserialize<CreateBookDto>(requestBody, options);

                if (bookDto == null)
                    return Results.BadRequest("Invalid book data");

                // طباعة البيانات بعد التحويل
                Console.WriteLine($"Deserialized data: Title={bookDto.Title}, AuthorId={bookDto.AuthorId}, PublisherId={bookDto.PublisherId}");

                var book = await bookRepository.CreateBookAsync(bookDto);
                return Results.Created($"/api/books/{book.Id}", book);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error creating book: {ex.Message}");
                return Results.BadRequest($"Error creating book: {ex.Message}");
            }
        })
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

        // Update book (admin only)
        group.MapPut("/books/{id}", async (int id, HttpRequest request, IBookRepository bookRepository) =>
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

                var bookDto = JsonSerializer.Deserialize<CreateBookDto>(requestBody, options);

                if (bookDto == null)
                    return Results.BadRequest("Invalid book data");

                // طباعة البيانات بعد التحويل
                Console.WriteLine($"Deserialized data for update: Title={bookDto.Title}, AuthorId={bookDto.AuthorId}, PublisherId={bookDto.PublisherId}");

                var success = await bookRepository.UpdateBookAsync(id, bookDto);
                if (!success)
                    return Results.NotFound();

                var updatedBook = await bookRepository.GetBookByIdAsync(id);
                return Results.Ok(updatedBook);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating book: {ex.Message}");
                return Results.BadRequest($"Error updating book: {ex.Message}");
            }
        })
        .AddEndpointFilter<AdminAuthFilter>();

        // Delete book (admin only)
        group.MapDelete("/books/{id}", async (int id, IBookRepository bookRepository) =>
        {
            try
            {
                var book = await bookRepository.GetBookByIdAsync(id);
                if (book == null)
                    return Results.NotFound();

                var success = await bookRepository.DeleteBookAsync(id);
                if (!success)
                    return Results.NotFound();

                return Results.Ok(new { message = "Book deleted successfully" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting book: {ex.Message}");
                return Results.BadRequest($"Error deleting book: {ex.Message}");
            }
        })
        .AddEndpointFilter<AdminAuthFilter>();
    }
}





