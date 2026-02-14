using Microsoft.AspNetCore.Http;

namespace RestService.Services
{
    public class StackService : IStackService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        
        private static int _globalResult = 0;

        public StackService(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        private HttpContext HttpContext => _httpContextAccessor.HttpContext;

        private Stack<int> GetStack()
        {
            var stackData = HttpContext.Session.GetString("Stack");
            if (string.IsNullOrEmpty(stackData))
            {
                return new Stack<int>();
            }
            
            var values = stackData.Split(',').Where(x => !string.IsNullOrEmpty(x)).Select(int.Parse).ToArray();
            return new Stack<int>(values);
        }

        private void SetStack(Stack<int> stack)
        {
            var values = stack.ToArray();
            HttpContext.Session.SetString("Stack", string.Join(",", values.Reverse()));
        }

        public int GetResult()
        {
            return _globalResult;
        }

        public void SetResult(int value)
        {
            _globalResult = value;
        }

        public void PushToStack(int value)
        {
            var stack = GetStack();
            stack.Push(value);
            SetStack(stack);
        }

        public int PopFromStack()
        {
            var stack = GetStack();
            if (stack.Count == 0)
            {
                throw new InvalidOperationException("Stack is empty");
            }

            int value = stack.Pop();
            SetStack(stack);
            return value;
        }

        public int PeekStack()
        {
            var stack = GetStack();
            if (stack.Count == 0)
            {
                throw new InvalidOperationException("Stack is empty");
            }
            return stack.Peek();
        }

        public int GetStackCount()
        {
            var stack = GetStack();
            return stack.Count;
        }

        public int GetTotalResult()
        {
            int totalResult = _globalResult;
            
            if (GetStackCount() > 0)
            {
                totalResult += PeekStack();
            }

            return totalResult;
        }

        public ServiceResult<int> TryPopFromStack()
        {
            try
            {
                int value = PopFromStack();
                return ServiceResult<int>.Success(value);
            }
            catch (InvalidOperationException ex)
            {
                return ServiceResult<int>.Failure(ex.Message, "StackEmpty");
            }
            catch (Exception ex)
            {
                return ServiceResult<int>.Failure($"Unexpected error: {ex.Message}", "Unexpected");
            }
        }

        public ServiceResult<int> TryPeekStack()
        {
            try
            {
                int value = PeekStack();
                return ServiceResult<int>.Success(value);
            }
            catch (InvalidOperationException ex)
            {
                return ServiceResult<int>.Failure(ex.Message, "StackEmpty");
            }
            catch (Exception ex)
            {
                return ServiceResult<int>.Failure($"Unexpected error: {ex.Message}", "Unexpected");
            }
        }
    }
}
