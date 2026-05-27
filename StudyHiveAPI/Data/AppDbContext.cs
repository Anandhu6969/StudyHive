using Microsoft.EntityFrameworkCore;
using StudyHiveAPI.Models;

namespace StudyHiveAPI.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Material> Materials { get; set; }
        public DbSet<Rating> Ratings { get; set; }
        public DbSet<Download> Downloads { get; set; }
        public DbSet<Bookmark> Bookmarks { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Downloads - disable cascade to avoid multiple cascade paths
            modelBuilder.Entity<Download>()
                .HasOne(d => d.User)
                .WithMany(u => u.Downloads)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Download>()
                .HasOne(d => d.Material)
                .WithMany(m => m.Downloads)
                .HasForeignKey(d => d.MaterialId)
                .OnDelete(DeleteBehavior.NoAction);

            // Ratings - same fix
            modelBuilder.Entity<Rating>()
                .HasOne(r => r.User)
                .WithMany(u => u.Ratings)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Rating>()
                .HasOne(r => r.Material)
                .WithMany(m => m.Ratings)
                .HasForeignKey(r => r.MaterialId)
                .OnDelete(DeleteBehavior.NoAction);

            // Bookmarks
            modelBuilder.Entity<Bookmark>()
                .HasOne(b => b.User)
                .WithMany(u => u.Bookmarks)
                .HasForeignKey(b => b.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Bookmark>()
                .HasOne(b => b.Material)
                .WithMany(m => m.Bookmarks)
                .HasForeignKey(b => b.MaterialId)
                .OnDelete(DeleteBehavior.NoAction);
        }
    }
}