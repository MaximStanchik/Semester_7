using ResultsCollection.DTO;

namespace ResultsCollection.Interfaces;

public interface IResultsService
{
    Dictionary<int, string> GetAll();
    StorageResponseDTO? GetById(int id);
    StorageResponseDTO Add(string value);
    StorageResponseDTO? Update(int id, string value);
    StorageResponseDTO? Delete(int id);
}