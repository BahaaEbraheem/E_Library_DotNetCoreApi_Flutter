using E_Library.API.Filters;
using E_Library.API.Models;
using E_Library.API.Repositories;

namespace E_Library.API.Endpoints;

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
        group.MapPost("/publishers", async (Publisher publisher, IPublisherRepository publisherRepository) =>
        {
            var createdPublisher = await publisherRepository.CreatePublisherAsync(publisher);
            return Results.Created($"/api/publishers/{createdPublisher.Id}", createdPublisher);
        })
        .AddEndpointFilter<AdminAuthFilter>();
    }
}