namespace ResultsAuthenticate.DTO;

public class UserDTO
{
    private string login;
    private string password;
    private string role;
    
    public string getLogin()
    {
        return this.login;
    }
    
    public void setLogin(string login)
    {
        this.login = login;
    }
    
    public string getPassword()
    {
        return this.password;
    }
    
    public void setPassword(string password)
    {
        this.password = password;
    }
    
    public string getRole()
    {
        return this.role;
    }
    
    public void setRole(string role)
    {
        this.role = role;
    }

    public UserDTO() {}

    public UserDTO(string login, string password, string role)
    {
        this.login = login;
        this.password = password;
        this.role = role;
    }
}