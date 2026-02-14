using RestService.Services;

namespace RestService.Services
{
    public interface IStackService
    {
        int GetResult();
        void SetResult(int value);
        void PushToStack(int value);
        int PopFromStack();
        int PeekStack();
        int GetStackCount();
        int GetTotalResult();
        ServiceResult<int> TryPopFromStack();
        ServiceResult<int> TryPeekStack();
    }
}