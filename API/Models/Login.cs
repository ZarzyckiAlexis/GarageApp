using System.ComponentModel.DataAnnotations;

namespace ProjetTMAPI.Models
{
    public class Login{
        [Required]
        public string username { get; set; }
        [Required]
        public string password { get; set; }
    }
}
