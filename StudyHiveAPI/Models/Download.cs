namespace StudyHiveAPI.Models
{
    public class Download
    {
        public int Id { get; set; }
        public DateTime DownloadedAt { get; set; } = DateTime.UtcNow;
        public int UserId { get; set; }
        public User User { get; set; }
        public int MaterialId { get; set; }
        public Material Material { get; set; }
    }
}