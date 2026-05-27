using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using StudyHiveAPI.Data;
using StudyHiveAPI.DTOs;
using System.Security.Claims;

namespace StudyHiveAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ProfileController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ProfileController(AppDbContext context)
        {
            _context = context;
        }

        // =========================
        // Get logged-in user info
        // =========================
        [HttpGet("me")]
        public async Task<IActionResult> Me()
        {
            var userId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)
            );

            var user = await _context.Users
                .Where(u => u.Id == userId)
                .Select(u => new
                {
                    u.Id,
                    u.FullName,
                    u.Email,
                    u.Role,
                    u.CreatedAt
                })
                .FirstOrDefaultAsync();

            if (user == null)
                return NotFound();

            return Ok(user);
        }

        // =========================
        // My uploads
        // =========================
        [HttpGet("my-uploads")]
        public async Task<IActionResult> MyUploads()
        {
            var userId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)
            );

            var uploads = await _context.Materials
                .Where(m => m.UserId == userId)
                .Include(m => m.Ratings)
                .OrderByDescending(m => m.UploadedAt)
                .Select(m => new MaterialResponseDTO
                {
                    Id = m.Id,
                    Title = m.Title,
                    Description = m.Description,
                    Subject = m.Subject,
                    Course = m.Course,
                    Tags = m.Tags,
                    FileType = m.FileType,
                    DownloadCount = m.DownloadCount,
                    AverageRating = m.Ratings.Any()
                        ? m.Ratings.Average(r => r.Stars)
                        : 0,
                    UploadedAt = m.UploadedAt,
                    UploaderName = m.User.FullName,
                    UserId = m.UserId
                })
                .ToListAsync();

            return Ok(uploads);
        }

        // =========================
        // My downloads
        // =========================
        [HttpGet("my-downloads")]
        public async Task<IActionResult> MyDownloads()
        {
            var userId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)
            );

            var downloads = await _context.Downloads
                .Where(d => d.UserId == userId)
                .OrderByDescending(d => d.DownloadedAt)
                .Include(d => d.Material)
                .ThenInclude(m => m.User)
                .Include(d => d.Material.Ratings)
                .Select(d => new
                {
                    d.Id,
                    d.DownloadedAt,

                    Material = new MaterialResponseDTO
                    {
                        Id = d.Material.Id,
                        Title = d.Material.Title,
                        Description = d.Material.Description,
                        Subject = d.Material.Subject,
                        Course = d.Material.Course,
                        Tags = d.Material.Tags,
                        FileType = d.Material.FileType,
                        DownloadCount = d.Material.DownloadCount,
                        AverageRating = d.Material.Ratings.Any()
                            ? d.Material.Ratings.Average(r => r.Stars)
                            : 0,
                        UploadedAt = d.Material.UploadedAt,
                        UploaderName = d.Material.User.FullName,
                        UserId = d.Material.UserId
                    }
                })
                .ToListAsync();

            return Ok(downloads);
        }
    }
}