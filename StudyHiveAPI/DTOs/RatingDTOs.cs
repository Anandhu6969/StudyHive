using System.ComponentModel.DataAnnotations;

namespace StudyHiveAPI.DTOs
{
    public class RatingCreateDTO
    {
        [Required]
        public int MaterialId { get; set; }

        [Range(1, 5)]
        public int Stars { get; set; }
    }

    public class RatingResponseDTO
    {
        public int Id { get; set; }

        public int Stars { get; set; }

        public string UserName { get; set; }

        public int MaterialId { get; set; }
    }
}