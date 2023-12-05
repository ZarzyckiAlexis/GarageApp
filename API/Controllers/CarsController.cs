using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ProjetTMAPI.Data;
using ProjetTMAPI.Models;

namespace ProjetTMAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CarsController : ControllerBase
    {
        private readonly ProjetTMAPIContext _context;

        public CarsController(ProjetTMAPIContext context)
        {
            _context = context;
        }

        // GET: api/Cars
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Cars>>> GetCars()
        {
            return await _context.Cars.ToListAsync();
        }

        [HttpGet("CarsByOwnerId/{ownerId}")]
        public async Task<ActionResult<IEnumerable<Cars>>> GetCarsByOwnerId(int ownerId)
        {
            // Filtrer les voitures pour obtenir celles avec l'ownerId spécifique
            var cars = await _context.Cars.Where(c => c.ownerId == ownerId).ToListAsync();

            if (cars == null || !cars.Any())
            {
                return NotFound("No cars found for this owner");
            }

            return cars;
        }

        // GET: api/Cars/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Cars>> GetCars(int id)
        {
            var cars = await _context.Cars.FindAsync(id);

            if (cars == null)
            {
                return NotFound();
            }

            return cars;
        }

        // PUT: api/Cars/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutCars(int id, Cars cars)
        {
            if (id != cars.Id)
            {
                return BadRequest();
            }

            if (!_context.User.Any(u => u.Id == cars.ownerId))
            {
                // Si l'utilisateur n'existe pas, retourner NotFound
                return NotFound("Owner not found");
            }

            _context.Entry(cars).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!CarsExists(id))
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

        // POST: api/Cars
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<Cars>> PostCars(Cars cars)
        {
            _context.Cars.Add(cars);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetCars", new { id = cars.Id }, cars);
        }

        // DELETE: api/Cars/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCars(int id)
        {
            var cars = await _context.Cars.FindAsync(id);
            if (cars == null)
            {
                return NotFound();
            }

            _context.Cars.Remove(cars);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool CarsExists(int id)
        {
            return _context.Cars.Any(e => e.Id == id);
        }
    }
}
