namespace StudyHiveAPI.Models
{
    public class Material
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Subject { get; set; }
        public string Course { get; set; }
        public string Tags { get; set; }
        public string FilePath { get; set; }
        public string FileType { get; set; }
        public int DownloadCount { get; set; } = 0;
        public DateTime UploadedAt { get; set; } = DateTime.UtcNow;

        public int UserId { get; set; }
        public User User { get; set; }

        public ICollection<Rating> Ratings { get; set; }
        public ICollection<Download> Downloads { get; set; }
        public ICollection<Bookmark> Bookmarks { get; set; }
    }
}