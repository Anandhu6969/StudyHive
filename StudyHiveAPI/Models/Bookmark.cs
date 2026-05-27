namespace StudyHiveAPI.Models
{
    public class Bookmark
    {
        public int Id { get; set; }

        public DateTime CreatedAt { get; set; }
            = DateTime.UtcNow;

        // User
        public int UserId { get; set; }

        public User User { get; set; }

        // Material
        public int MaterialId { get; set; }

        public Material Material { get; set; }
    }
}