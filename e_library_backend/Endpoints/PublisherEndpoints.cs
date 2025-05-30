using e_library_backend.Filters;
using e_library_backend.Models;
using e_library_backend.Repositories;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.IO;

namespace e_library_backend.Endpoints;

public static class PublisherEndpoints
{
    public static void MapPublisherEndpoints(this IEndpointRouteBuilder routes)
    {
        var group = routes.MapGroup("/api");

        // Get all publishers
        group.MapGet("/publishers", async (IPublisherRepository publisherRepository) =>
            await publisherRepository.GetAllPublishersAsync());

        // Search publishers by name
        group.MapGet("/publishers/search", async (string name, IPublisherRepository publisherRepository) =>
            await publisherRepository.SearchPublishersByNameAsync(name));

        // Create new publisher (admin only)
        group.MapPost("/publishers", async (HttpRequest request, IPublisherRepository publisherRepository) =>
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
                    DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull,
                    WriteIndented = true
                };

                var publisherData = System.Text.Json.JsonSerializer.Deserialize<Publisher>(requestBody, options);

                if (publisherData == null)
                    return Results.BadRequest("Invalid publisher data");

                // طباعة البيانات بعد التحويل
                Console.WriteLine($"Deserialized data: PName={publisherData.PName}, City={publisherData.City}");

                if (string.IsNullOrEmpty(publisherData.PName))
                    return Results.BadRequest("Publisher name is required");

                var createdPublisher = await publisherRepository.CreatePublisherAsync(publisherData);
                return Results.Created($"/api/publishers/{createdPublisher.Id}", createdPublisher);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error creating publisher: {ex.Message}");
                return Results.BadRequest($"Error creating publisher: {ex.Message}");
            }
        }).RequireAuthorization(policy => policy.RequireRole("Admin"));

        // Get publisher by ID
        group.MapGet("/publishers/{id}", async (int id, IPublisherRepository publisherRepository) =>
        {
            var publisher = await publisherRepository.GetPublisherByIdAsync(id);
            if (publisher == null)
                return Results.NotFound();

            return Results.Ok(publisher);
        });

        // Update publisher (admin only)
        group.MapPut("/publishers/{id}", async (int id, HttpRequest request, IPublisherRepository publisherRepository) =>
        {
            try
            {
                // طباعة معلومات التفويض للتشخيص
                Console.WriteLine($"Authorization header: {request.Headers["Authorization"]}");
                Console.WriteLine($"User identity: {request.HttpContext.User.Identity?.Name}, IsAuthenticated: {request.HttpContext.User.Identity?.IsAuthenticated}");

                // طباعة جميع الهيدرز للتشخيص
                foreach (var header in request.Headers)
                {
                    Console.WriteLine($"Header: {header.Key} = {header.Value}");
                }

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

                var publisherData = JsonSerializer.Deserialize<Publisher>(requestBody, options);

                if (publisherData == null)
                    return Results.BadRequest("Invalid publisher data");

                // طباعة البيانات بعد التحويل
                Console.WriteLine($"Deserialized data for update: PName={publisherData.PName}, City={publisherData.City}");

                var success = await publisherRepository.UpdatePublisherAsync(id, publisherData);
                if (!success)
                    return Results.NotFound();

                var updatedPublisher = await publisherRepository.GetPublisherByIdAsync(id);
                return Results.Ok(updatedPublisher);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating publisher: {ex.Message}");
                return Results.BadRequest($"Error updating publisher: {ex.Message}");
            }
        })
        .RequireAuthorization("AdminOnly"); // تحقق من وجود سياسة تفويض خاصة

        // Add this endpoint for deleting publishers
        group.MapDelete("/publishers/{id}", async (int id, IPublisherRepository publisherRepository) =>
        {
            try
            {
                var publisher = await publisherRepository.GetPublisherByIdAsync(id);
                if (publisher == null)
                    return Results.NotFound();

                var success = await publisherRepository.DeletePublisherAsync(id);
                if (!success)
                    return Results.NotFound();

                return Results.Ok(new { message = "Publisher deleted successfully" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting publisher: {ex.Message}");
                return Results.BadRequest($"Error deleting publisher: {ex.Message}");
            }
        })
        .RequireAuthorization(policy => policy.RequireRole("Admin")); ;
    }
}









