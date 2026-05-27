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
    [Authorize]
    public class BookmarksController : ControllerBase
    {
        private readonly AppDbContext _context;

        public BookmarksController(AppDbContext context)
        {
            _context = context;
        }

        // =========================
        // Add bookmark
        // =========================
        [HttpPost("{materialId}")]
        public async Task<IActionResult> AddBookmark(int materialId)
        {
            var userId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)
            );

            // Check material exists
            var materialExists = await _context.Materials
                .AnyAsync(m => m.Id == materialId);

            if (!materialExists)
            {
                return NotFound("Material not found");
            }

            // Prevent duplicate bookmark
            var alreadyBookmarked = await _context.Bookmarks
                .AnyAsync(b =>
                    b.UserId == userId &&
                    b.MaterialId == materialId);

            if (alreadyBookmarked)
            {
                return BadRequest("Already bookmarked");
            }

            var bookmark = new Bookmark
            {
                UserId = userId,
                MaterialId = materialId
            };

            _context.Bookmarks.Add(bookmark);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Material bookmarked successfully"
            });
        }

        // =========================
        // Remove bookmark
        // =========================
        [HttpDelete("{materialId}")]
        public async Task<IActionResult> RemoveBookmark(int materialId)
        {
            var userId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)
            );

            var bookmark = await _context.Bookmarks
                .FirstOrDefaultAsync(b =>
                    b.UserId == userId &&
                    b.MaterialId == materialId);

            if (bookmark == null)
            {
                return NotFound("Bookmark not found");
            }

            _context.Bookmarks.Remove(bookmark);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Bookmark removed successfully"
            });
        }

        // =========================
        // Get my bookmarks
        // =========================
        [HttpGet]
        public async Task<IActionResult> GetMyBookmarks()
        {
            var userId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)
            );

            var bookmarks = await _context.Bookmarks
                .Where(b => b.UserId == userId)
                .Include(b => b.Material)
                .ThenInclude(m => m.User)
                .Include(b => b.Material.Ratings)
                .Select(b => new MaterialResponseDTO
                {
                    Id = b.Material.Id,
                    Title = b.Material.Title,
                    Description = b.Material.Description,
                    Subject = b.Material.Subject,
                    Course = b.Material.Course,
                    Tags = b.Material.Tags,
                    FileType = b.Material.FileType,
                    DownloadCount = b.Material.DownloadCount,

                    AverageRating = b.Material.Ratings.Any()
                        ? b.Material.Ratings.Average(r => r.Stars)
                        : 0,

                    UploadedAt = b.Material.UploadedAt,
                    UploaderName = b.Material.User.FullName,
                    UserId = b.Material.UserId
                })
                .ToListAsync();

            return Ok(bookmarks);
        }
    }
}