namespace REST01.DTO;

public class ResultRequestDTO
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
    
    public ResultRequestDTO() {}

    public ResultRequestDTO(string value)
    {
        this.value = value;
    }
}