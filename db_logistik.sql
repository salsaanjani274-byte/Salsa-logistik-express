-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 21, 2026 at 05:45 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_logistik`
--

-- --------------------------------------------------------

--
-- Table structure for table `cabang`
--

CREATE TABLE `cabang` (
  `id` int(11) NOT NULL,
  `kode_cabang` varchar(10) NOT NULL,
  `nama_cabang` varchar(100) NOT NULL,
  `kota` varchar(100) NOT NULL,
  `provinsi` varchar(100) NOT NULL,
  `alamat` text NOT NULL,
  `no_telp` varchar(20) DEFAULT NULL,
  `tipe` enum('cabang','gateway','pusat') DEFAULT 'cabang',
  `status` enum('aktif','nonaktif') DEFAULT 'aktif',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cabang`
--

INSERT INTO `cabang` (`id`, `kode_cabang`, `nama_cabang`, `kota`, `provinsi`, `alamat`, `no_telp`, `tipe`, `status`, `created_at`) VALUES
(1, 'JKT-PST', 'Jakarta Pusat', 'Jakarta Pusat', 'DKI Jakarta', 'Jl. Merdeka No. 1, Jakarta Pusat', '021-12345678', 'pusat', 'aktif', '2026-03-19 16:08:08'),
(2, 'JKT-GTW', 'Jakarta Gateway', 'Jakarta Utara', 'DKI Jakarta', 'Jl. Pelabuhan No. 5, Jakarta Utara', '021-98765432', 'gateway', 'aktif', '2026-03-19 16:08:08'),
(3, 'BDG-001', 'Bandung Utara', 'Bandung', 'Jawa Barat', 'Jl. Pasteur No. 10, Bandung', '022-11223344', 'cabang', 'aktif', '2026-03-19 16:08:08'),
(4, 'SBY-001', 'Surabaya Pusat', 'Surabaya', 'Jawa Timur', 'Jl. Pemuda No. 20, Surabaya', '031-55667788', 'cabang', 'aktif', '2026-03-19 16:08:08'),
(5, 'YOG-001', 'Yogyakarta', 'Yogyakarta', 'DI Yogyakarta', 'Jl. Malioboro No. 88, Yogyakarta', '0274-998877', 'cabang', 'aktif', '2026-03-19 16:08:08'),
(6, 'MDN-001', 'Medan', 'Medan', 'Sumatera Utara', 'Jl. Sudirman No. 15, Medan', '061-33445566', 'cabang', 'aktif', '2026-03-19 16:08:08');

-- --------------------------------------------------------

--
-- Table structure for table `layanan`
--

CREATE TABLE `layanan` (
  `id` int(11) NOT NULL,
  `kode` varchar(10) NOT NULL,
  `nama` varchar(50) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `estimasi_hari` int(11) NOT NULL,
  `harga_per_kg` decimal(10,2) NOT NULL,
  `status` enum('aktif','nonaktif') DEFAULT 'aktif'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `layanan`
--

INSERT INTO `layanan` (`id`, `kode`, `nama`, `deskripsi`, `estimasi_hari`, `harga_per_kg`, `status`) VALUES
(1, 'REG', 'Reguler', 'Layanan pengiriman reguler, estimasi 2-5 hari', 4, 9000.00, 'aktif'),
(2, 'YES', 'Yakin Esok Sampai', 'Garansi sampai keesokan harinya', 1, 18000.00, 'aktif'),
(3, 'OKE', 'Ongkos Kirim Ekonomis', 'Layanan hemat, estimasi 5-8 hari', 6, 7000.00, 'aktif');

-- --------------------------------------------------------

--
-- Table structure for table `notifikasi`
--

CREATE TABLE `notifikasi` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `judul` varchar(200) NOT NULL,
  `pesan` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifikasi`
--

INSERT INTO `notifikasi` (`id`, `user_id`, `judul`, `pesan`, `is_read`, `created_at`) VALUES
(1, 6, 'Paket Berhasil Dibuat', 'No Resi: LGSJKT-PST26032020455568 | Tujuan: Bandung | Total: Rp187,670', 0, '2026-03-20 13:45:37'),
(2, 7, 'Paket Berhasil Dibuat', 'No Resi: LGSBDG-00126032022365209 | Tujuan: Surabaya | Total: Rp34,100', 0, '2026-03-20 15:36:07');

-- --------------------------------------------------------

--
-- Table structure for table `paket`
--

CREATE TABLE `paket` (
  `id` int(11) NOT NULL,
  `no_resi` varchar(30) NOT NULL,
  `pengirim_id` int(11) NOT NULL,
  `nama_penerima` varchar(100) NOT NULL,
  `no_hp_penerima` varchar(20) NOT NULL,
  `alamat_penerima` text NOT NULL,
  `kota_asal` varchar(100) NOT NULL,
  `kota_tujuan` varchar(100) NOT NULL,
  `cabang_asal_id` int(11) NOT NULL,
  `cabang_tujuan_id` int(11) DEFAULT NULL,
  `layanan_id` int(11) NOT NULL,
  `berat` decimal(8,2) NOT NULL COMMENT 'dalam kg',
  `panjang` decimal(8,2) DEFAULT 0.00,
  `lebar` decimal(8,2) DEFAULT 0.00,
  `tinggi` decimal(8,2) DEFAULT 0.00,
  `berat_volume` decimal(8,2) DEFAULT 0.00,
  `berat_bayar` decimal(8,2) NOT NULL,
  `isi_paket` text DEFAULT NULL,
  `nilai_barang` decimal(12,2) DEFAULT 0.00,
  `biaya_kirim` decimal(12,2) NOT NULL,
  `biaya_asuransi` decimal(12,2) DEFAULT 0.00,
  `total_biaya` decimal(12,2) NOT NULL,
  `status` enum('created','sorting_origin','in_transit_gateway','gateway_processing','on_transit','arrived_destination','out_for_delivery','delivered','returned','problem') DEFAULT 'created',
  `jalur` enum('darat','udara') DEFAULT 'darat',
  `kurir_id` int(11) DEFAULT NULL,
  `pod_penerima` varchar(100) DEFAULT NULL,
  `pod_waktu` timestamp NULL DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `paket`
--

INSERT INTO `paket` (`id`, `no_resi`, `pengirim_id`, `nama_penerima`, `no_hp_penerima`, `alamat_penerima`, `kota_asal`, `kota_tujuan`, `cabang_asal_id`, `cabang_tujuan_id`, `layanan_id`, `berat`, `panjang`, `lebar`, `tinggi`, `berat_volume`, `berat_bayar`, `isi_paket`, `nilai_barang`, `biaya_kirim`, `biaya_asuransi`, `total_biaya`, `status`, `jalur`, `kurir_id`, `pod_penerima`, `pod_waktu`, `catatan`, `created_at`, `updated_at`) VALUES
(1, 'LGSJKT-PST26032020455568', 6, 'Angga', '08765908623', 'Jl. Ir. H. Juanda', 'Jakarta Pusat', 'Bandung', 1, 3, 1, 2.00, 50.00, 50.00, 50.00, 20.83, 20.83, 'Elektronik', 100000.00, 187470.00, 200.00, 187670.00, 'created', 'darat', NULL, NULL, NULL, NULL, '2026-03-20 13:45:37', '2026-03-20 13:45:37'),
(2, 'LGSBDG-00126032022365209', 7, 'Ayu Puspa', '08967546547', 'Jl. Panglima Sudirman', 'Bandung', 'Surabaya', 3, 4, 3, 4.30, 20.00, 20.00, 20.00, 1.33, 4.30, 'pakaian', 2000000.00, 30100.00, 4000.00, 34100.00, 'created', 'darat', NULL, NULL, NULL, NULL, '2026-03-20 15:36:07', '2026-03-20 15:36:07');

-- --------------------------------------------------------

--
-- Table structure for table `riwayat_status`
--

CREATE TABLE `riwayat_status` (
  `id` int(11) NOT NULL,
  `paket_id` int(11) NOT NULL,
  `status` varchar(50) NOT NULL,
  `keterangan` text DEFAULT NULL,
  `lokasi` varchar(200) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `riwayat_status`
--

INSERT INTO `riwayat_status` (`id`, `paket_id`, `status`, `keterangan`, `lokasi`, `user_id`, `created_at`) VALUES
(1, 1, 'created', 'Paket diterima di cabang Jakarta Pusat. Layanan: Reguler', 'Jakarta Pusat', 2, '2026-03-20 13:45:37'),
(2, 2, 'created', 'Paket diterima di cabang Bandung. Layanan: Ongkos Kirim Ekonomis', 'Bandung', 3, '2026-03-20 15:36:07');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('pengelola','admin_cabang','kurir','pelanggan') NOT NULL DEFAULT 'pelanggan',
  `no_hp` varchar(20) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `cabang_id` int(11) DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL,
  `status` enum('aktif','nonaktif') DEFAULT 'aktif',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `nama`, `email`, `password`, `role`, `no_hp`, `alamat`, `cabang_id`, `foto`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Super Admin', 'admin@logistik.com', 'password123', 'pengelola', '081234567890', NULL, 1, NULL, 'aktif', '2026-03-19 16:08:38', '2026-03-19 16:08:38'),
(2, 'Admin Jakarta', 'admin.jkt@logistik.com', 'password123', 'admin_cabang', '081234567891', NULL, 1, NULL, 'aktif', '2026-03-19 16:08:38', '2026-03-19 16:08:38'),
(3, 'Admin Bandung', 'admin.bdg@logistik.com', 'password123', 'admin_cabang', '081234567892', NULL, 3, NULL, 'aktif', '2026-03-19 16:08:38', '2026-03-19 16:08:38'),
(4, 'Kurir Budi', 'kurir.budi@logistik.com', 'password123', 'kurir', '081234567893', NULL, 1, NULL, 'aktif', '2026-03-19 16:08:38', '2026-03-20 15:26:06'),
(5, 'Kurir Anto', 'kurir.anto@logistik.com', 'password123', 'kurir', '081234567894', NULL, 3, NULL, 'aktif', '2026-03-19 16:08:38', '2026-03-19 16:08:38'),
(6, 'Budi Santoso', 'Budi@gmail.com', 'password123', 'pelanggan', '081234567895', NULL, NULL, NULL, 'aktif', '2026-03-19 16:08:38', '2026-03-20 13:41:12'),
(7, 'Siti Rahayu', 'Siti@gmail.com', 'password123', 'pelanggan', '081234567896', NULL, NULL, NULL, 'aktif', '2026-03-19 16:08:38', '2026-03-20 14:10:36'),
(8, 'Admin Surabaya', 'admin.sby@logistik.com', 'password123', 'admin_cabang', '089786675645', NULL, 4, NULL, 'aktif', '2026-03-21 03:48:32', '2026-03-21 04:33:58');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cabang`
--
ALTER TABLE `cabang`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_cabang` (`kode_cabang`);

--
-- Indexes for table `layanan`
--
ALTER TABLE `layanan`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode` (`kode`);

--
-- Indexes for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `paket`
--
ALTER TABLE `paket`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `no_resi` (`no_resi`),
  ADD KEY `pengirim_id` (`pengirim_id`),
  ADD KEY `layanan_id` (`layanan_id`),
  ADD KEY `cabang_asal_id` (`cabang_asal_id`);

--
-- Indexes for table `riwayat_status`
--
ALTER TABLE `riwayat_status`
  ADD PRIMARY KEY (`id`),
  ADD KEY `paket_id` (`paket_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cabang`
--
ALTER TABLE `cabang`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `layanan`
--
ALTER TABLE `layanan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `notifikasi`
--
ALTER TABLE `notifikasi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `paket`
--
ALTER TABLE `paket`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `riwayat_status`
--
ALTER TABLE `riwayat_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD CONSTRAINT `notifikasi_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `paket`
--
ALTER TABLE `paket`
  ADD CONSTRAINT `paket_ibfk_1` FOREIGN KEY (`pengirim_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `paket_ibfk_2` FOREIGN KEY (`layanan_id`) REFERENCES `layanan` (`id`),
  ADD CONSTRAINT `paket_ibfk_3` FOREIGN KEY (`cabang_asal_id`) REFERENCES `cabang` (`id`);

--
-- Constraints for table `riwayat_status`
--
ALTER TABLE `riwayat_status`
  ADD CONSTRAINT `riwayat_status_ibfk_1` FOREIGN KEY (`paket_id`) REFERENCES `paket` (`id`),
  ADD CONSTRAINT `riwayat_status_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
