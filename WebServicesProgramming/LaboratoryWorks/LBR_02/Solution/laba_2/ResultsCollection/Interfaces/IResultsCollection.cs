using ResultsCollection.Services;

namespace ResultsCollection.Interfaces;

public interface IResultsCollection
{
    Dictionary<int, string> GetAll();
    ReturnedModel? GetById(int id);
    ReturnedModel Add(string value);
    ReturnedModel? Update(int id, string value);
    ReturnedModel? Delete(int id);
}
