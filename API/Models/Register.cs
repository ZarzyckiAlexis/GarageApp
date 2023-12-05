using System.ComponentModel.DataAnnotations;

namespace ProjetTMAPI.Models
{
    public class Register{

        public int Id { get; set; }
        [Required]
        public string username { get; set; }
        [Required]
        public string Password { get; set; }
        [Required]
        public string ConfirmPassword { get; set; }
    }
}
