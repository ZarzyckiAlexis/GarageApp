using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using ProjetTMAPI.Data;
using ProjetTMAPI.Models;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace ProjetTMAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly ProjetTMAPIContext _context;

        public UsersController(ProjetTMAPIContext context)
        {
            _context = context;
        }

        // GET: api/Users
        [HttpGet]
        public async Task<ActionResult<IEnumerable<User>>> GetUser()
        {
            if (_context.User == null)
            {
                return NotFound();
            }
            return await _context.User.ToListAsync();
        }

        // GET: api/Users/5
        [HttpGet("{id}")]
        public async Task<ActionResult<User>> GetUser(int id)
        {
            var user = await _context.User.FindAsync(id);

            if (user == null)
            {
                return NotFound();
            }

            return user;
        }

        // PUT: api/Users/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutUser(int id, User user)
        {
            if (id != user.Id)
            {
                return BadRequest();
            }

            _context.Entry(user).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!UserExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/Users
        [HttpPost]
        public async Task<ActionResult<User>> PostUser(User user)
        {
            _context.User.Add(user);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetUser", new { id = user.Id }, user);
        }

        // DELETE: api/Users/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var user = await _context.User.FindAsync(id);
            if (user == null)
            {
                return NotFound();
            }

            _context.User.Remove(user);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        [HttpPost("Login")]
        public IActionResult Login([FromBody] Login model)
        {
            if (_context.User == null)
            {
                return StatusCode(500, "Internal Server Error");
            }

            var user = _context.User.FirstOrDefault(x => x.username == model.username);

            if (user == null)
            {
                return BadRequest("Username not found");
            }

            var match = CheckPassword(model.password, user);

            if (!match)
            {
                return BadRequest("Username Or Password Was Invalid");
            }

            var returnUser = new
            {
                Id = user.Id,
                username = user.username
            };

            return Ok(returnUser);

        }

        [HttpPost("Register")]
        public async Task<ActionResult<User>> Register([FromBody] Register model)
        {
            // Vérifier si le nom d'utilisateur existe déjà dans la base de données
            var existingUser = await _context.User.FirstOrDefaultAsync(u => u.username == model.username);

            if (existingUser != null)
            {
                return BadRequest("Username already exists. Please choose a different username.");
            }

            var user = new User
            {
                username = model.username
            };

            if (model.ConfirmPassword == model.Password)
            {
                using HMACSHA512? hmac = new();
                user.PasswordSalt = hmac.Key;
                user.PasswordHash = hmac.ComputeHash(System.Text.Encoding.UTF8.GetBytes(model.Password));
            }
            else
            {
                return BadRequest("Passwords Don't Match");
            }

            if (_context.User == null)
            {
                return Problem("Entity set 'AuthentificationTinderContext.Users' is null.");
            }

            _context.User.Add(user);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetUser", new { id = user.Id }, user);
        }


        private bool UserExists(int id)
        {
            return _context.User.Any(e => e.Id == id);
        }

        private bool CheckPassword(string password, User user)
        {
            bool result;

            using (HMACSHA512? hmac = new HMACSHA512(user.PasswordSalt))
            {
                var compute = hmac.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
                result = compute.SequenceEqual(user.PasswordHash);
            }

            return result;
        }

    }
}
