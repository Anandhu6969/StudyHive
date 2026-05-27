using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using StudyHiveAPI.Data;
using StudyHiveAPI.DTOs;
using StudyHiveAPI.Models;
using System.Security.Claims;

namespace StudyHiveAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RatingsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RatingsController(AppDbContext context)
        {
            _context = context;
        }

        // Add rating
        [HttpPost]
        [Authorize]
        public async Task<IActionResult> AddRating(RatingCreateDTO dto)
        {
            var userId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)
            );

            // Validate stars
            if (dto.Stars < 1 || dto.Stars > 5)
            {
                return BadRequest("Stars must be between 1 and 5");
            }

            // Check material exists
            var materialExists = await _context.Materials
                .AnyAsync(m => m.Id == dto.MaterialId);

            if (!materialExists)
            {
                return NotFound("Material not found");
            }

            // Prevent duplicate rating
            var existingRating = await _context.Ratings
                .FirstOrDefaultAsync(r =>
                    r.UserId == userId &&
                    r.MaterialId == dto.MaterialId);

            if (existingRating != null)
            {
                existingRating.Stars = dto.Stars;

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = "Rating updated"
                });
            }

            // Create new rating
            var rating = new Rating
            {
                Stars = dto.Stars,
                UserId = userId,
                MaterialId = dto.MaterialId
            };

            _context.Ratings.Add(rating);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Rating added successfully"
            });
        }

        // Get ratings for material
        [HttpGet("material/{materialId}")]
        public async Task<IActionResult> GetRatings(int materialId)
        {
            var ratings = await _context.Ratings
                .Include(r => r.User)
                .Where(r => r.MaterialId == materialId)
                .Select(r => new RatingResponseDTO
                {
                    Id = r.Id,
                    Stars = r.Stars,
                    UserName = r.User.FullName,
                    MaterialId = r.MaterialId
                })
                .ToListAsync();

            return Ok(ratings);
        }
    }
}