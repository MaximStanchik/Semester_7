using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using REST01.DTO;
using REST01.Entity;
using ResultsAuthenticate.Interfaces;
using ResultsCollection.Interfaces;

[ApiController]
[Route("api/Results")]
public class ResultsController : Controller
{
    private readonly IResultsService _resultsService;
    private readonly IAuthenticateService _authService;
    
    public ResultsController(IResultsService resultsService, IAuthenticateService authService)
    {
        _resultsService = resultsService;
        _authService = authService;
    }
    
    [HttpPost("SignIn")]
    public IActionResult SignIn([FromBody] User user)
    {
        if (user == null || string.IsNullOrEmpty(user.Login) || string.IsNullOrEmpty(user.Password))
        {
            return BadRequest("Login and password are required");
        }

        var token = _authService.Authenticate(user.Login, user.Password);
        if (token == null)
        {
            return NotFound("Invalid credentials");
        }

        return Ok(new { Token = token });
    }
    
    // GET: /api/Results/
    [Authorize(Roles = "READER")]
    [HttpGet]
    public IActionResult GetAllResults()
    {
        var results = _resultsService.GetAll();
        return results.Count == 0 ? NoContent() : Ok(results);
    }
    
    // GET: /api/Results/{k:int}
    [Authorize(Roles = "READER")]
    [HttpGet("{k:int}")]
    public IActionResult GetResultById(int k)
    {
        var result = _resultsService.GetById(k);
        return result == null ? NotFound() : Ok(result);
    }

    // POST: /api/Results/
    [Authorize(Roles = "WRITER")]
    [HttpPost]
    public IActionResult AddResult([FromBody] ResultRequestDTO request)
    {
        if (request == null || string.IsNullOrWhiteSpace(request.getValue()))
        {
            return BadRequest("Value is required");
        }

        try
        {
            var newItem = _resultsService.Add(request.getValue());
            return CreatedAtAction(nameof(GetResultById), new { k = newItem.getId() }, newItem);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    // PUT: /api/Results/{k:int}
    [Authorize(Roles = "WRITER")]
    [HttpPut("{k:int}")]
    public IActionResult UpdateResult(int k, [FromBody] ResultRequestDTO request) 
    {
        if (request == null || string.IsNullOrWhiteSpace(request.getValue()))
        {
            return BadRequest("Value is required");
        }

            var updatedItem = _resultsService.Update(k, request.getValue());
        return updatedItem == null ? NotFound() : Ok(updatedItem);
    }

    // DELETE: /api/Results/{k:int}
    [Authorize(Roles = "WRITER")]
    [HttpDelete("{k:int}")]
    public IActionResult DeleteResult(int k)
    {
        var deletedItem = _resultsService.Delete(k);
        return deletedItem == null ? NotFound() : Ok(deletedItem);
    }
}