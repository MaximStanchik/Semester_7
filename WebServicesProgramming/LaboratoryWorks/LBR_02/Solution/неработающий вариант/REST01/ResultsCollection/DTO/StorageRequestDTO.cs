namespace ResultsCollection.DTO;

public class StorageRequestDTO
{
    private Dictionary<int, string> items = new();
    private int nextId = 0;

    public Dictionary<int, string> getItems()
    {
        return this.items;
    }

    public void setItems(Dictionary<int, string> items)
    {
        this.items = items;
    }

    public int getNextId()
    {
        return this.nextId;
    }

    public void setNextId(int nextId)
    {
        this.nextId = nextId;
    }

    public StorageRequestDTO() {}

    public StorageRequestDTO(Dictionary<int, string> items, int nextId)
    {
        this.items = items;
        this.nextId = nextId;
    }
}