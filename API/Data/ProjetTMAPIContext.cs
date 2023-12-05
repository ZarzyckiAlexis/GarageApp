using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ProjetTMAPI.Models;

namespace ProjetTMAPI.Data
{
    public class ProjetTMAPIContext : DbContext
    {
        public ProjetTMAPIContext (DbContextOptions<ProjetTMAPIContext> options)
            : base(options)
        {
        }

        public DbSet<ProjetTMAPI.Models.User> User { get; set; } = default!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Fluent API to define unique constraint on Username
            modelBuilder.Entity<User>()
                .HasIndex(u => u.username)
                .IsUnique();
        }
        public DbSet<ProjetTMAPI.Models.Cars> Cars { get; set; } = default!;
    }
}
