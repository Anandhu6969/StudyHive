using System.ComponentModel.DataAnnotations;
namespace StudyHiveAPI.DTOs
{
    // =========================
    // Upload Material DTO
    // =========================
    public class MaterialUploadDTO
    {
        [Required]
        [StringLength(150)]
        public string Title { get; set; }
        [Required]
        [StringLength(1000)]
        public string Description { get; set; }
        [Required]
        [StringLength(100)]
        public string Subject { get; set; }
        [Required]
        [StringLength(100)]
        public string Course { get; set; }
        [Required]
        [StringLength(200)]
        public string Tags { get; set; }
        [Required]
        public IFormFile File { get; set; }
    }
    // =========================
    // Material Response DTO
    // =========================
    public class MaterialResponseDTO
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Subject { get; set; }
        public string Course { get; set; }
        public string Tags { get; set; }
        public string? FilePath { get; set; }   // ADDED
        public string FileType { get; set; }
        public int DownloadCount { get; set; }
        public double AverageRating { get; set; }
        public DateTime UploadedAt { get; set; }
        public string UploaderName { get; set; }
        public int UserId { get; set; }
    }
    // =========================
    // Update Material DTO
    // =========================
    public class MaterialUpdateDTO
    {
        [Required]
        [StringLength(150)]
        public string Title { get; set; }
        [Required]
        [StringLength(1000)]
        public string Description { get; set; }
        [Required]
        [StringLength(100)]
        public string Subject { get; set; }
        [Required]
        [StringLength(100)]
        public string Course { get; set; }
        [Required]
        [StringLength(200)]
        public string Tags { get; set; }
    }
}