namespace ResultsAuthenticate.DTO;

public class LoginDTO
{
    private string login;
    private string password;

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
    
    public LoginDTO() {}

    public LoginDTO(string login, string password)
    {
        this.login = login;
        this.password = password;
    }
}