using e_library_backend.Models;

namespace e_library_backend.Repositories;

public interface IPublisherRepository
{
    Task<IEnumerable<Publisher>> GetAllPublishersAsync();
    Task<IEnumerable<Publisher>> SearchPublishersByNameAsync(string name);
    Task<Publisher> CreatePublisherAsync(Publisher publisher);
    Task<Publisher?> GetPublisherByIdAsync(int id);
    Task<bool> UpdatePublisherAsync(int id, Publisher publisher);
    Task<bool> DeletePublisherAsync(int id);
}



