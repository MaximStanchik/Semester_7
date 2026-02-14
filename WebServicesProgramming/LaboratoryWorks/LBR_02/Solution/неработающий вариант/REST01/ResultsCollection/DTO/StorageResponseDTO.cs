namespace ResultsCollection.DTO;

public class StorageResponseDTO
{
    
    private int id;
    private string value;
    
    public int getId()
    {
        return this.id;
    }
    
    public void setId(int id)
    {
        this.id = id;
    }
    
    public string getValue()
    {
        return this.value;
    }
    
    public void setValue(string value)
    {
        this.value = value;
    }

    public StorageResponseDTO()
    {
        this.value = string.Empty;
    }
    public StorageResponseDTO(int id, string value)
    {
        this.id = id;
        this.value = value;
    }
}