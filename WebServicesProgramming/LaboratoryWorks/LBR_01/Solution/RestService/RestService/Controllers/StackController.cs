using Microsoft.AspNetCore.Mvc;
using RestService.Services;

[ApiController]
    [Route("api/SMA")]
    public class StackController : Controller
    {
        private readonly IStackService _stackService;

        public StackController(IStackService stackService)
        {
            _stackService = stackService;
        }
        
        [Route("")]
        [Route("/")]
        public IActionResult Index()
        {
            return View();
        }
        
        // GET: /api/SMA/result/get
        [HttpGet("result/get")]
        public IActionResult GetResult()
        {
            int totalResult = _stackService.GetTotalResult();
            
            return Ok(new 
            { 
                RESULT = totalResult, 
                Message = "RESULT calculated successfully"
            }); 
        }
    
        // POST: /api/SMA/result/set
        [HttpPost("result/set")]
        public IActionResult SetResult([FromQuery] int RESULT)
        {
            _stackService.SetResult(RESULT);
            return Ok(new { Message = $"RESULT successfully set to {RESULT}" });
        }
    
        // PUT: /api/SMA/stack/add
        [HttpPut("stack/add")]
        public IActionResult Push([FromQuery] int ADD) 
        {
            _stackService.PushToStack(ADD);
            return Ok(new { Message = $"Value {ADD} successfully added to the stack" });
        }
    
        // DELETE: /api/SMA/stack/pop
        [HttpDelete("stack/pop")]  
        public IActionResult Pop()
        {
            var result = _stackService.TryPopFromStack();
        
            if (result.IsSuccess)
            {
                return Ok(new 
                { 
                    Value = result.Value, 
                    Message = $"Value {result.Value} successfully removed from the stack" 
                });
            }
        
            return result.ErrorType switch
            {
                "StackEmpty" => NotFound(new { Message = result.ErrorMessage }),
                "Unexpected" => StatusCode(500, new { Message = result.ErrorMessage }),
                _ => BadRequest(new { Message = result.ErrorMessage })
            };
        }
    }

