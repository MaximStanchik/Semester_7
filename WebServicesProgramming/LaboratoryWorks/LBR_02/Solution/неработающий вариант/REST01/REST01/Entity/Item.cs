namespace REST01.Entity;

public class Item
{
    private string value;
    
    public string getValue()
    {
        return this.value;
    }
    
    public void setValue(string value)
    {
        this.value = value;
    }
    
    public Item() {}

    public Item(string value)
    {
        this.value = value;
    }
}