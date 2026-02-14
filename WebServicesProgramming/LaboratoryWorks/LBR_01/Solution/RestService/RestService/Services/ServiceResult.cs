namespace RestService.Services;

public class ServiceResult<T>
{
    public bool IsSuccess { get; set; }
    public T Value { get; set; }
    public string ErrorMessage { get; set; }
    public string ErrorType { get; set; }

    public static ServiceResult<T> Success(T value)
    {
        return new ServiceResult<T> { IsSuccess = true, Value = value };
    }

    public static ServiceResult<T> Failure(string errorMessage, string errorType = "General")
    {
        return new ServiceResult<T> { IsSuccess = false, ErrorMessage = errorMessage, ErrorType = errorType };
    }
}