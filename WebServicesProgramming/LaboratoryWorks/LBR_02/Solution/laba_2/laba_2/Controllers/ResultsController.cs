using laba_2.Model;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ResultsAuthenticate.Interfaces;
using ResultsCollection.Interfaces;

namespace laba_2.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ResultsController : ControllerBase
    {
        private readonly IResultsCollection _resultsService;
        private readonly IAuthenticateService _authService;

        public ResultsController(IResultsCollection resultsService, IAuthenticateService authService)
        {
            _resultsService = resultsService;
            _authService = authService;
        }

        [HttpPost("SignIn")]
        public IActionResult SignIn([FromBody] Model.LoginModel model)
        {
            if (model == null || string.IsNullOrEmpty(model.Login) || string.IsNullOrEmpty(model.Password))
            {
                return BadRequest("Login and password are required");
            }

            var token = _authService.Authenticate(model.Login, model.Password);
            if (token == null)
            {
                return NotFound("Invalid credentials");
            }

            return Ok(new { Token = token });
        }

        [HttpGet]
        [Authorize(Roles = "READER")]
        public IActionResult GetAll()
        {
            var results = _resultsService.GetAll();
            return results.Count == 0 ? NoContent() : Ok(results);
        }

        [HttpGet("{id:int}")]
        [Authorize(Roles = "READER")]
        public IActionResult GetById(int id)
        {
            var result = _resultsService.GetById(id);
            return result == null ? NotFound() : Ok(result);
        }

        [HttpPost]
        [Authorize(Roles = "WRITER")]
        public IActionResult Create([FromBody] CreateItemModel model)
        {
            if (model == null || string.IsNullOrWhiteSpace(model.Value))
            {
                return BadRequest("Value is required");
            }

            try
            {
                var newItem = _resultsService.Add(model.Value);
                return CreatedAtAction(nameof(GetById), new { id = newItem.Id }, newItem);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "WRITER")]
        public IActionResult Update(int id, [FromBody] UpdateItemModel model)
        {
            if (model == null || string.IsNullOrWhiteSpace(model.Value))
            {
                return BadRequest("Value is required");
            }

            var updatedItem = _resultsService.Update(id, model.Value);
            return updatedItem == null ? NotFound() : Ok(updatedItem);
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "WRITER")]
        public IActionResult Delete(int id)
        {
            var deletedItem = _resultsService.Delete(id);
            return deletedItem == null ? NotFound() : Ok(deletedItem);
        }
    }
}
