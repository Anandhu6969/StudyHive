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
    public class MaterialsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IWebHostEnvironment _env;

        public MaterialsController(AppDbContext context, IWebHostEnvironment env)
        {
            _context = context;
            _env = env;
        }

        // =========================
        // Upload material
        // =========================
        [HttpPost("upload")]
        [Authorize]
        public async Task<IActionResult> Upload([FromForm] MaterialUploadDTO dto)
        {
            var userId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)
            );

            if (dto.File == null || dto.File.Length == 0)
                return BadRequest("File is required");

            var allowedExtensions = new[] { ".pdf", ".jpg", ".jpeg", ".png" };
            var extension = Path.GetExtension(dto.File.FileName).ToLower();

            if (!allowedExtensions.Contains(extension))
                return BadRequest("Only PDF, JPG, JPEG, and PNG files are allowed");

            var maxFileSize = 10 * 1024 * 1024;
            if (dto.File.Length > maxFileSize)
                return BadRequest("File size cannot exceed 10 MB");

            var uploadsFolder = Path.Combine(_env.ContentRootPath, "Uploads");
            Directory.CreateDirectory(uploadsFolder);

            var fileName = Guid.NewGuid().ToString() + extension;
            var filePath = Path.Combine(uploadsFolder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await dto.File.CopyToAsync(stream);
            }

            var material = new Material
            {
                Title = dto.Title,
                Description = dto.Description,
                Subject = dto.Subject,
                Course = dto.Course,
                Tags = dto.Tags,
                FilePath = fileName,
                FileType = extension.Replace(".", ""),
                UserId = userId
            };

            _context.Materials.Add(material);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Material uploaded successfully",
                materialId = material.Id
            });
        }

        // =========================
        // Get all materials
        // =========================
        [HttpGet]
        public async Task<IActionResult> GetAll(
            [FromQuery] string? subject,
            [FromQuery] string? search,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 5,
            [FromQuery] string? sortBy = "latest")
        {
            var query = _context.Materials
                .Include(m => m.User)
                .Include(m => m.Ratings)
                .AsQueryable();

            if (!string.IsNullOrEmpty(subject))
                query = query.Where(m => m.Subject.ToLower().Contains(subject.ToLower()));

            if (!string.IsNullOrEmpty(search))
                query = query.Where(m =>
                    m.Title.ToLower().Contains(search.ToLower()) ||
                    m.Tags.ToLower().Contains(search.ToLower()));

            query = sortBy?.ToLower() switch
            {
                "downloads" => query.OrderByDescending(m => m.DownloadCount),
                "rating" => query.OrderByDescending(m =>
                    m.Ratings.Any() ? m.Ratings.Average(r => r.Stars) : 0),
                _ => query.OrderByDescending(m => m.UploadedAt)
            };

            var totalCount = await query.CountAsync();

            var materials = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var result = materials.Select(m => new MaterialResponseDTO
            {
                Id = m.Id,
                Title = m.Title,
                Description = m.Description,
                Subject = m.Subject,
                Course = m.Course,
                Tags = m.Tags,
                FilePath = m.FilePath,  // ADDED
                FileType = m.FileType,
                DownloadCount = m.DownloadCount,
                AverageRating = m.Ratings.Any()
                    ? m.Ratings.Average(r => r.Stars) : 0,
                UploadedAt = m.UploadedAt,
                UploaderName = m.User.FullName,
                UserId = m.UserId
            });

            return Ok(new
            {
                page,
                pageSize,
                totalCount,
                totalPages = (int)Math.Ceiling(totalCount / (double)pageSize),
                data = result
            });
        }

        // =========================
        // Get single material
        // =========================
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var m = await _context.Materials
                .Include(m => m.User)
                .Include(m => m.Ratings)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (m == null)
                return NotFound();

            return Ok(new MaterialResponseDTO
            {
                Id = m.Id,
                Title = m.Title,
                Description = m.Description,
                Subject = m.Subject,
                Course = m.Course,
                Tags = m.Tags,
                FilePath = m.FilePath,  // ADDED
                FileType = m.FileType,
                DownloadCount = m.DownloadCount,
                AverageRating = m.Ratings.Any()
                    ? m.Ratings.Average(r => r.Stars) : 0,
                UploadedAt = m.UploadedAt,
                UploaderName = m.User.FullName,
                UserId = m.UserId
            });
        }

        // =========================
        // Download material
        // =========================
        [HttpGet("{id}/download")]
        [Authorize]
        public async Task<IActionResult> Download(int id)
        {
            var userId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)
            );

            var material = await _context.Materials.FindAsync(id);

            if (material == null)
                return NotFound();

            var filePath = Path.Combine(
                _env.ContentRootPath,
                "Uploads",
                material.FilePath
            );

            if (string.IsNullOrWhiteSpace(material.FilePath) ||
                !System.IO.File.Exists(filePath))
                return NotFound("File not found on server");

            material.DownloadCount++;

            _context.Downloads.Add(new Download
            {
                UserId = userId,
                MaterialId = id
            });

            await _context.SaveChangesAsync();

            var fileBytes = await System.IO.File.ReadAllBytesAsync(filePath);

            var contentType = material.FileType?.ToLower() switch
            {
                "pdf" => "application/pdf",
                "jpg" => "image/jpeg",
                "jpeg" => "image/jpeg",
                "png" => "image/png",
                _ => "application/octet-stream"
            };

            return File(fileBytes, contentType, material.FilePath);
        }

        // =========================
        // Update material
        // =========================
        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> UpdateMaterial(
            int id,
            MaterialUpdateDTO dto)
        {
            var userId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)
            );

            var material = await _context.Materials
                .FirstOrDefaultAsync(m => m.Id == id);

            if (material == null)
                return NotFound("Material not found");

            if (material.UserId != userId)
                return Forbid();

            material.Title = dto.Title;
            material.Description = dto.Description;
            material.Subject = dto.Subject;
            material.Course = dto.Course;
            material.Tags = dto.Tags;

            await _context.SaveChangesAsync();

            return Ok(new { message = "Material updated successfully" });
        }

        // =========================
        // Delete material
        // =========================
        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteMaterial(int id)
        {
            var userId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)
            );

            var material = await _context.Materials
                .Include(m => m.Ratings)
                .Include(m => m.Downloads)
                .Include(m => m.Bookmarks)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (material == null)
                return NotFound("Material not found");

            if (material.UserId != userId)
                return Forbid();

            var filePath = Path.Combine(
                _env.ContentRootPath,
                "Uploads",
                material.FilePath
            );

            if (System.IO.File.Exists(filePath))
                System.IO.File.Delete(filePath);

            _context.Ratings.RemoveRange(material.Ratings);
            _context.Downloads.RemoveRange(material.Downloads);
            _context.Bookmarks.RemoveRange(material.Bookmarks);
            _context.Materials.Remove(material);

            await _context.SaveChangesAsync();

            return Ok(new { message = "Material deleted successfully" });
        }
    }
}