namespace REST01.Entity;

public class User
{
    private string login;
    private string password;
    
    // Публичные свойства для JSON десериализации
    public string Login 
    { 
        get => login; 
        set => login = value; 
    }
    
    public string Password 
    { 
        get => password; 
        set => password = value; 
    }
    
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
   
    public User() {}

    public User(string login, string password)
    {
        this.login = login;
        this.password = password;
    }
}