namespace StudyHiveAPI.Models
{
    public class Rating
    {
        public int Id { get; set; }
        public int Stars { get; set; }
        public int UserId { get; set; }
        public User User { get; set; }
        public int MaterialId { get; set; }
        public Material Material { get; set; }
    }
}