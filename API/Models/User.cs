using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ProjetTMAPI.Models
{
    public class User{

        public int Id { get; set; }
        [Required]
        public string username { get; set; }
        [Required]
        public byte[] PasswordSalt { get; set; }
        [Required]
        public byte[] PasswordHash { get; set; }

    }
}
