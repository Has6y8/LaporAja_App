-- ============================================
-- Database: laporaja
-- Untuk aplikasi LaporAja (Web + Flutter)
-- ============================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
SET NAMES utf8mb4;

-- --------------------------------------------
-- Tabel: users
-- --------------------------------------------
CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('user','staff','admin','super_admin') NOT NULL DEFAULT 'user',
  `nis_nip` varchar(255) DEFAULT NULL,
  `kelas` varchar(255) DEFAULT NULL,
  `alasan_pengajuan` text DEFAULT NULL,
  `no_telepon` varchar(255) DEFAULT NULL,
  `is_approved` tinyint(1) NOT NULL DEFAULT 1,
  `status_akun` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `catatan_penolakan` text DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------
-- Tabel: laporans
-- --------------------------------------------
CREATE TABLE `laporans` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `judul` varchar(255) NOT NULL,
  `deskripsi` text NOT NULL,
  `lokasi` varchar(255) NOT NULL,
  `foto_bukti` varchar(255) DEFAULT NULL,
  `foto_perbaikan` varchar(255) DEFAULT NULL,
  `status` enum('pending','diproses','selesai','ditolak') NOT NULL DEFAULT 'pending',
  `staff_id` bigint(20) UNSIGNED DEFAULT NULL,
  `verified_by` bigint(20) UNSIGNED DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `moderation_status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `alasan_moderasi` text DEFAULT NULL,
  `catatan_staff` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `laporans_user_id_foreign` (`user_id`),
  KEY `laporans_staff_id_foreign` (`staff_id`),
  KEY `laporans_verified_by_foreign` (`verified_by`),
  CONSTRAINT `laporans_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `laporans_staff_id_foreign` FOREIGN KEY (`staff_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `laporans_verified_by_foreign` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------
-- Tabel: status_laporans (timeline log)
-- --------------------------------------------
CREATE TABLE `status_laporans` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `laporan_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `status` varchar(255) NOT NULL,
  `keterangan` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `status_laporans_laporan_id_foreign` (`laporan_id`),
  KEY `status_laporans_user_id_foreign` (`user_id`),
  CONSTRAINT `status_laporans_laporan_id_foreign` FOREIGN KEY (`laporan_id`) REFERENCES `laporans` (`id`) ON DELETE CASCADE,
  CONSTRAINT `status_laporans_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------
-- Tabel: komplains
-- --------------------------------------------
CREATE TABLE `komplains` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `laporan_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `tipe` enum('lambat_respon','kurang_jelas','foto_tidak_pantas','kata_kasar','minta_hapus_laporan','lainnya') DEFAULT NULL,
  `isi` text NOT NULL,
  `status` enum('pending','direspon') NOT NULL DEFAULT 'pending',
  `admin_id` bigint(20) UNSIGNED DEFAULT NULL,
  `respon_admin` text DEFAULT NULL,
  `respon_at` timestamp NULL DEFAULT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `komplains_laporan_id_foreign` (`laporan_id`),
  KEY `komplains_user_id_foreign` (`user_id`),
  KEY `komplains_admin_id_foreign` (`admin_id`),
  CONSTRAINT `komplains_laporan_id_foreign` FOREIGN KEY (`laporan_id`) REFERENCES `laporans` (`id`) ON DELETE CASCADE,
  CONSTRAINT `komplains_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `komplains_admin_id_foreign` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- DATA DEMO (akun untuk login)
-- Password semua di-hash bcrypt:
--   super123, admin123, staff123, user123
-- ============================================
INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `nis_nip`, `kelas`, `no_telepon`, `is_approved`, `status_akun`, `created_at`, `updated_at`) VALUES
(1, 'Super Admin',      'super@laporaja.id', '$2y$12$3.K7CSZMaztX6J6Zbu0XsuOWHX5IejkPNFwyeg/ktYRQs6p.a3G.q', 'super_admin', NULL, NULL, NULL,          1, 'approved', NOW(), NOW()),
(2, 'Admin Sekolah',    'admin@laporaja.id', '$2y$12$miVIILaF9o6F271NVqQ9YuGoiWt/yp/OK/27eGMbRqPTiZgBRuC0G', 'admin',       NULL, NULL, NULL,          1, 'approved', NOW(), NOW()),
(3, 'Staff Sarpras',    'staff@laporaja.id', '$2y$12$zSyQLuVzFlhlwvc5EiLhtOiLcdKhRipb433qYfam4RZkDrDW3QiYW', 'staff',       NULL, NULL, NULL,          1, 'approved', NOW(), NOW()),
(4, 'Pranaja Abi Praya','user@laporaja.id',  '$2y$12$fL37FTn29ndY3KEoAVRdrOVzpLSHuY8FD6bx76X6Ufr1PIWIrFSfm', 'user',        '27', 'XII RPL C', '08123456789', 1, 'approved', NOW(), NOW());