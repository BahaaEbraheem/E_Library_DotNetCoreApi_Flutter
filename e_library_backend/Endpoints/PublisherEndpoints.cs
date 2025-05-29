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
    }
}






