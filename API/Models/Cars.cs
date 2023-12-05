using System.ComponentModel.DataAnnotations;

namespace ProjetTMAPI.Models
{
    public class Cars {
        public int Id { get; set; }
        [Required]
        public string brandName { get; set; }
        [Required]
        public string modelName { get; set; }
        [Required]
        public string customName { get; set; }
        [Required]
        public int horsePower { get; set; }
        [Required]
        public int kilometersAge { get; set; }
        [Required]
        public int ownerId {  get; set; }
    }
}
