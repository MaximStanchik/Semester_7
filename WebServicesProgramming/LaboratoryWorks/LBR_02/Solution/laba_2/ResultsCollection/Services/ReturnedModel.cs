namespace ResultsCollection.Services;

public class ReturnedModel
{
    public int Id { get; set; } 
    public string Value { get; set; } 

    public ReturnedModel()
    {
        Value = string.Empty;
    }
    public ReturnedModel(int id, string value)
    {
        Id = id;
        Value = value;
    }
}
