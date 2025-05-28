using E_Library.API.Models;

namespace E_Library.API.Repositories;

public interface IPublisherRepository
{
    Task<IEnumerable<Publisher>> GetAllPublishersAsync();
    Task<IEnumerable<Publisher>> SearchPublishersByNameAsync(string name);
    Task<Publisher> CreatePublisherAsync(Publisher publisher);
}