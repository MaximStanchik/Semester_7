namespace ResultsCollection.Services;

public class StorageModel
{
    public Dictionary<int, string> Items { get; set; } = new();
    public int NextId { get; set; } = 0;
}
