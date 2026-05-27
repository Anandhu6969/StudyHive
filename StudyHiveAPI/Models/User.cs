namespace StudyHiveAPI.Models
{
    public class User
    {
        public int Id { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string Role { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public ICollection<Material> Materials { get; set; }
        public ICollection<Rating> Ratings { get; set; }
        public ICollection<Download> Downloads { get; set; }
        public ICollection<Bookmark> Bookmarks { get; set; }
    }
}