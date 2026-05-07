-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 07, 2026 at 08:50 AM
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
-- Database: `db_logistik_xendit`
--

-- --------------------------------------------------------

--
-- Table structure for table `cabang`
--

CREATE TABLE `cabang` (
  `id` int(11) NOT NULL,
  `kode_cabang` varchar(10) DEFAULT NULL,
  `nama_cabang` varchar(100) DEFAULT NULL,
  `kota` varchar(100) DEFAULT NULL,
  `provinsi` varchar(100) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `no_telp` varchar(20) DEFAULT NULL,
  `tipe` enum('cabang','gateway','pusat') DEFAULT 'cabang',
  `status` enum('aktif','nonaktif') DEFAULT 'aktif',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cabang`
--

INSERT INTO `cabang` (`id`, `kode_cabang`, `nama_cabang`, `kota`, `provinsi`, `alamat`, `no_telp`, `tipe`, `status`, `created_at`) VALUES
(1, 'JKT-PST', 'Jakarta Pusat', 'Jakarta Pusat', 'DKI Jakarta', 'Jl. Merdeka No. 1, Jakarta Pusat', '021-12345678', 'pusat', 'aktif', '2026-04-19 12:59:30'),
(2, 'JKT-GTW', 'Jakarta Gateway', 'Jakarta Utara', 'DKI Jakarta', 'Jl. Yos Sudarso No. 5, Jakarta Utara', '021-98765432', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(3, 'BDG-GTW', 'Bandung Gateway', 'Bandung', 'Jawa Barat', 'Jl. Soekarno Hatta No. 89, Bandung', '022-87654321', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(4, 'SBY-GTW', 'Surabaya Gateway', 'Surabaya', 'Jawa Timur', 'Jl. Perak Timur No. 10, Surabaya', '031-12345678', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(5, 'YOG-GTW', 'Yogyakarta Gateway', 'Yogyakarta', 'DI Yogyakarta', 'Jl. Magelang No. 15, Sleman', '0274-987654', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(6, 'CMH-GTW', 'Cimahi Gateway', 'Cimahi', 'Jawa Barat', 'Jl. Amir Machmud No. 50, Cimahi', '022-66554433', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(7, 'TRG-GTW', 'Tangerang Gateway', 'Tangerang', 'Banten', 'Jl. Daan Mogot No. 25, Tangerang', '021-55667788', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(8, 'BGR-GTW', 'Bogor Gateway', 'Bogor', 'Jawa Barat', 'Jl. Pajajaran No. 12, Bogor', '0251-778899', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(9, 'SMG-GTW', 'Semarang Gateway', 'Semarang', 'Jawa Tengah', 'Jl. Ahmad Yani No. 20, Semarang', '024-1234567', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(10, 'SKT-GTW', 'Surakarta Gateway', 'Surakarta', 'Jawa Tengah', 'Jl. Slamet Riyadi No. 100, Solo', '0271-765432', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(11, 'MLG-GTW', 'Malang Gateway', 'Malang', 'Jawa Timur', 'Jl. Ijen No. 45, Malang', '0341-112233', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(12, 'SRG-GTW', 'Serang Gateway', 'Serang', 'Banten', 'Jl. Veteran No. 8, Serang', '0254-998877', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(13, 'MGL-GTW', 'Magelang Gateway', 'Magelang', 'Jawa Tengah', 'Jl. Sudirman No. 30, Magelang', '0293-445566', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(14, 'BKS-GTW', 'Bekasi Gateway', 'Bekasi', 'Jawa Barat', 'Jl. Ahmad Yani No. 1, Bekasi', '021-88997766', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(15, 'KDR-GTW', 'Kediri Gateway', 'Kediri', 'Jawa Timur', 'Jl. Dhoho No. 77, Kediri', '0354-223344', 'gateway', 'aktif', '2026-04-19 12:59:30'),
(16, 'JKT-001', 'Jakarta Utara', 'Jakarta Utara', 'DKI Jakarta', 'Jl. Sunter Agung No. 10, Jakarta Utara', '021-99887766', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(17, 'BDG-001', 'Bandung Utara', 'Bandung', 'Jawa Barat', 'Jl. Setiabudi No. 10, Bandung', '022-11223344', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(18, 'SBY-001', 'Surabaya Pusat', 'Surabaya', 'Jawa Timur', 'Jl. Basuki Rahmat No. 20, Surabaya', '031-55667788', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(19, 'YOG-001', 'Yogyakarta Kota', 'Yogyakarta', 'DI Yogyakarta', 'Jl. Malioboro No. 88, Yogyakarta', '0274-998877', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(20, 'CMH-001', 'Cimahi Tengah', 'Cimahi', 'Jawa Barat', 'Jl. Gandawijaya No. 5, Cimahi', '022-33445566', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(21, 'TRG-001', 'Tangerang Kota', 'Tangerang', 'Banten', 'Jl. MH Thamrin No. 12, Tangerang', '021-22334455', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(22, 'BGR-001', 'Bogor Kota', 'Bogor', 'Jawa Barat', 'Jl. Juanda No. 3, Bogor', '0251-667788', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(23, 'SMG-001', 'Semarang Kota', 'Semarang', 'Jawa Tengah', 'Jl. Pandanaran No. 9, Semarang', '024-334455', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(24, 'SKT-001', 'Surakarta Kota', 'Surakarta', 'Jawa Tengah', 'Jl. Urip Sumoharjo No. 11, Solo', '0271-223344', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(25, 'MLG-001', 'Malang Kota', 'Malang', 'Jawa Timur', 'Jl. Kawi No. 2, Malang', '0341-556677', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(26, 'SRG-001', 'Serang Kota', 'Serang', 'Banten', 'Jl. Ahmad Yani No. 7, Serang', '0254-112233', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(27, 'MGL-001', 'Magelang Kota', 'Magelang', 'Jawa Tengah', 'Jl. Pemuda No. 15, Magelang', '0293-778899', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(28, 'BKS-001', 'Bekasi Kota', 'Bekasi', 'Jawa Barat', 'Jl. Ir. Juanda No. 50, Bekasi', '021-44556677', 'cabang', 'aktif', '2026-04-19 12:59:30'),
(29, 'KDR-001', 'Kediri Kota', 'Kediri', 'Jawa Timur', 'Jl. Hayam Wuruk No. 22, Kediri', '0354-667788', 'cabang', 'aktif', '2026-04-19 12:59:30');

-- --------------------------------------------------------

--
-- Table structure for table `layanan`
--

CREATE TABLE `layanan` (
  `id` int(11) NOT NULL,
  `kode` varchar(10) DEFAULT NULL,
  `nama` varchar(50) DEFAULT NULL,
  `deskripsi` text DEFAULT NULL,
  `estimasi_hari` int(11) DEFAULT NULL,
  `harga_per_kg` decimal(10,2) DEFAULT NULL,
  `status` enum('aktif','nonaktif') DEFAULT 'aktif'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `layanan`
--

INSERT INTO `layanan` (`id`, `kode`, `nama`, `deskripsi`, `estimasi_hari`, `harga_per_kg`, `status`) VALUES
(1, 'REG', 'Reguler', 'Layanan pengiriman reguler, estimasi 2-5 hari', 4, 9000.00, 'aktif'),
(2, 'YES', 'Yakin Esok Sampai', 'Garansi sampai keesokan harinya', 1, 18000.00, 'aktif'),
(3, 'OKE', 'Ongkos Kirim Ekonomis', 'Layanan hemat, estimasi 5-8 hari', 6, 7000.00, 'aktif'),
(4, 'JTR', 'JTR Trucking', 'Layanan darat trucking, berat volumetrik ÷5000', 7, 5000.00, 'aktif');

-- --------------------------------------------------------

--
-- Table structure for table `paket`
--

CREATE TABLE `paket` (
  `id` int(11) NOT NULL,
  `no_resi` varchar(30) DEFAULT NULL,
  `pengirim_id` int(11) DEFAULT NULL,
  `nama_penerima` varchar(100) DEFAULT NULL,
  `no_hp_penerima` varchar(20) DEFAULT NULL,
  `alamat_penerima` text DEFAULT NULL,
  `kota_asal` varchar(100) DEFAULT NULL,
  `kota_tujuan` varchar(100) DEFAULT NULL,
  `cabang_asal_id` int(11) DEFAULT NULL,
  `gateway_id` int(11) DEFAULT NULL,
  `gateway_tujuan_id` int(11) DEFAULT NULL,
  `layanan_id` int(11) DEFAULT NULL,
  `berat` decimal(8,2) DEFAULT NULL,
  `panjang` decimal(8,2) DEFAULT 0.00,
  `lebar` decimal(8,2) DEFAULT 0.00,
  `tinggi` decimal(8,2) DEFAULT 0.00,
  `berat_volume` decimal(8,2) DEFAULT 0.00,
  `berat_bayar` decimal(8,2) DEFAULT NULL,
  `isi_paket` text DEFAULT NULL,
  `nilai_barang` decimal(12,2) DEFAULT 0.00,
  `biaya_kirim` decimal(12,2) DEFAULT NULL,
  `biaya_asuransi` decimal(12,2) DEFAULT 0.00,
  `total_biaya` decimal(12,2) DEFAULT NULL,
  `status` enum('created','sorting_origin','in_transit_gateway','gateway_origin','on_transit','arrived_gateway_dest','out_for_delivery','delivered','failed_delivery','on_hold','return_process','returned','problem') DEFAULT 'created',
  `jalur` enum('darat','udara') DEFAULT 'darat',
  `kurir_id` int(11) DEFAULT NULL,
  `driver_id` int(11) DEFAULT NULL,
  `pod_penerima` varchar(100) DEFAULT NULL,
  `pod_waktu` timestamp NULL DEFAULT NULL,
  `pod_foto` varchar(255) DEFAULT NULL,
  `pod_catatan` text DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  `hold_until` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `paket`
--

INSERT INTO `paket` (`id`, `no_resi`, `pengirim_id`, `nama_penerima`, `no_hp_penerima`, `alamat_penerima`, `kota_asal`, `kota_tujuan`, `cabang_asal_id`, `gateway_id`, `gateway_tujuan_id`, `layanan_id`, `berat`, `panjang`, `lebar`, `tinggi`, `berat_volume`, `berat_bayar`, `isi_paket`, `nilai_barang`, `biaya_kirim`, `biaya_asuransi`, `total_biaya`, `status`, `jalur`, `kurir_id`, `driver_id`, `pod_penerima`, `pod_waktu`, `pod_foto`, `pod_catatan`, `catatan`, `hold_until`, `created_at`, `updated_at`) VALUES
(1, 'LGSJKT001251001080001', 48, 'Wulandari Safitri', '082200000101', 'Jl. Raya Darmo No. 7, Surabaya', 'Jakarta Utara', 'Surabaya', 16, 2, 4, 1, 3.00, 30.00, 25.00, 20.00, 3.00, 3.00, 'Pakaian - Baju & Celana', 800000.00, 27000.00, 1600.00, 28600.00, 'delivered', 'darat', 41, NULL, 'Wulandari Safitri', '2025-10-05 07:30:00', NULL, NULL, NULL, NULL, '2025-10-01 01:00:00', '2025-10-05 07:30:00'),
(2, 'LGSBDG001251008093002', 49, 'Rendra Kusuma', '082200000102', 'Jl. Malioboro No. 25, Yogyakarta', 'Bandung', 'Yogyakarta', 17, 3, 5, 3, 2.50, 25.00, 20.00, 15.00, 1.50, 2.50, 'Buku & Alat Tulis', 300000.00, 17500.00, 600.00, 18100.00, 'delivered', 'darat', 46, NULL, 'Rendra Kusuma', '2025-10-12 03:15:00', NULL, NULL, NULL, NULL, '2025-10-08 02:30:00', '2025-10-12 03:15:00'),
(3, 'LGSBY001251105130003', 50, 'Annisa Kurniawati', '082200000103', 'Jl. Pandanaran No. 40, Semarang', 'Surabaya', 'Semarang', 18, 4, 9, 2, 0.50, 15.00, 10.00, 8.00, 0.20, 0.50, 'Dokumen Kontrak Kerja', 0.00, 9000.00, 0.00, 9000.00, 'delivered', 'udara', 43, NULL, 'Annisa Kurniawati', '2025-11-06 02:00:00', NULL, NULL, NULL, NULL, '2025-11-05 06:00:00', '2025-11-06 02:00:00'),
(4, 'LGSPYOG001251115100004', 51, 'Bintang Erlangga', '082200000104', 'Jl. MH Thamrin No. 55, Tangerang', 'Yogyakarta', 'Tangerang', 19, 5, 7, 3, 5.00, 40.00, 30.00, 20.00, 4.80, 5.00, 'Kerajinan Batik Tulis', 750000.00, 35000.00, 1500.00, 36500.00, 'delivered', 'darat', 45, NULL, 'Bintang Erlangga', '2025-11-21 09:00:00', NULL, NULL, NULL, NULL, '2025-11-15 03:00:00', '2025-11-21 09:00:00'),
(5, 'LGSCMH001251120083005', 52, 'Dewi Maharani', '082200000105', 'Jl. Pajajaran No. 33, Bogor', 'Cimahi', 'Bogor', 20, 6, 8, 1, 3.00, 25.00, 20.00, 15.00, 1.50, 3.00, 'Sepatu & Sandal', 400000.00, 27000.00, 800.00, 27800.00, 'delivered', 'darat', 34, NULL, 'Dewi Maharani', '2025-11-24 04:30:00', NULL, NULL, NULL, NULL, '2025-11-20 01:30:00', '2025-11-24 04:30:00'),
(6, 'LGSTRG001251201090006', 53, 'Fitriani Lestari', '082200000106', 'Jl. Ahmad Yani No. 18, Bekasi', 'Tangerang', 'Bekasi', 21, 7, 14, 2, 1.00, 20.00, 15.00, 10.00, 0.50, 1.00, 'Kosmetik & Skincare', 300000.00, 18000.00, 600.00, 18600.00, 'delivered', 'udara', 35, NULL, 'Fitriani Lestari', '2025-12-02 06:45:00', NULL, NULL, NULL, NULL, '2025-12-01 02:00:00', '2025-12-02 06:45:00'),
(7, 'LGSBGR001251210110007', 54, 'Gunawan Triastanto', '082200000107', 'Jl. Slamet Riyadi No. 100, Surakarta', 'Bogor', 'Surakarta', 22, 8, 10, 4, 8.00, 50.00, 40.00, 30.00, 12.00, 12.00, 'Peralatan Dapur - Panci & Wajan', 1200000.00, 60000.00, 2400.00, 62400.00, 'delivered', 'darat', 42, NULL, 'Gunawan Triastanto', '2025-12-17 08:00:00', NULL, NULL, NULL, NULL, '2025-12-10 04:00:00', '2025-12-17 08:00:00'),
(8, 'LGSSMG001251220080008', 55, 'Hardianti Putri', '082200000108', 'Jl. Dhoho No. 50, Kediri', 'Semarang', 'Kediri', 23, 9, 15, 1, 2.50, 30.00, 20.00, 15.00, 1.80, 2.50, 'Mainan Anak & Boneka', 350000.00, 22500.00, 700.00, 23200.00, 'delivered', 'darat', 38, NULL, 'Hardianti Putri', '2025-12-24 03:00:00', NULL, NULL, NULL, NULL, '2025-12-20 01:00:00', '2025-12-24 03:00:00'),
(9, 'LGSJKT001260105100009', 56, 'Indraswara Yudha', '082200000109', 'Jl. Setiabudi No. 66, Bandung', 'Jakarta Utara', 'Bandung', 16, 2, 3, 1, 4.00, 35.00, 25.00, 20.00, 3.50, 4.00, 'Elektronik - Earphone & Charger', 800000.00, 36000.00, 1600.00, 37600.00, 'delivered', 'darat', 33, NULL, 'Indraswara Yudha', '2026-01-09 05:00:00', NULL, NULL, NULL, NULL, '2026-01-05 03:00:00', '2026-01-09 05:00:00'),
(10, 'LGSBDG001260115140010', 57, 'Jelita Amelia', '082200000110', 'Jl. Basuki Rahmat No. 77, Surabaya', 'Bandung', 'Surabaya', 17, 3, 4, 2, 0.30, 10.00, 8.00, 5.00, 0.07, 0.30, 'Surat & Dokumen Kontrak', 0.00, 5400.00, 0.00, 5400.00, 'delivered', 'udara', 41, NULL, 'Jelita Amelia', '2026-01-16 01:30:00', NULL, NULL, NULL, NULL, '2026-01-15 07:00:00', '2026-01-16 01:30:00'),
(11, 'LGSBY001260201090011', 58, 'Kurniawan Adi', '082200000111', 'Jl. Kaliurang No. 8, Yogyakarta', 'Surabaya', 'Yogyakarta', 18, 4, 5, 3, 6.00, 45.00, 35.00, 25.00, 7.88, 7.88, 'Furniture Kecil - Rak Buku', 2000000.00, 55160.00, 4000.00, 59160.00, 'delivered', 'darat', 46, NULL, 'Kurniawan Adi', '2026-02-08 07:00:00', NULL, NULL, NULL, NULL, '2026-02-01 02:00:00', '2026-02-08 07:00:00'),
(12, 'LGSPYOG001260214080012', 59, 'Lestari Ningrum', '082200000112', 'Jl. Amir Machmud No. 44, Cimahi', 'Yogyakarta', 'Cimahi', 19, 5, 6, 1, 1.50, 20.00, 15.00, 10.00, 0.60, 1.50, 'Oleh-oleh Makanan Khas Yogya', 250000.00, 13500.00, 500.00, 14000.00, 'delivered', 'darat', 36, NULL, 'Lestari Ningrum', '2026-02-18 04:00:00', NULL, NULL, NULL, NULL, '2026-02-14 01:00:00', '2026-02-18 04:00:00'),
(13, 'LGSBGR001260301110013', 60, 'Marcelino Santoso', '082200000113', 'Jl. Daan Mogot No. 99, Tangerang', 'Bogor', 'Tangerang', 22, 8, 7, 2, 0.50, 15.00, 10.00, 5.00, 0.12, 0.50, 'Obat-obatan & Suplemen', 150000.00, 9000.00, 300.00, 9300.00, 'delivered', 'udara', 45, NULL, 'Marcelino Santoso', '2026-03-02 03:30:00', NULL, NULL, NULL, NULL, '2026-03-01 04:00:00', '2026-03-02 03:30:00'),
(14, 'LGSCMH001260310080014', 61, 'Novita Susanti', '082200000114', 'Jl. Juanda No. 22, Bogor', 'Cimahi', 'Bogor', 20, 6, 8, 4, 10.00, 60.00, 50.00, 40.00, 24.00, 24.00, 'Spare Part Motor - Kopling & Karburator', 1500000.00, 120000.00, 3000.00, 123000.00, 'delivered', 'darat', 34, NULL, 'Novita Susanti', '2026-03-17 08:30:00', NULL, NULL, NULL, NULL, '2026-03-10 01:00:00', '2026-03-17 08:30:00'),
(15, 'LGSTRG001260320093015', 62, 'Octavian Putra', '082200000115', 'Jl. Ahmad Yani No. 12, Semarang', 'Tangerang', 'Semarang', 21, 7, 9, 1, 3.50, 30.00, 25.00, 20.00, 3.00, 3.50, 'Pakaian Batik Pekalongan', 600000.00, 31500.00, 1200.00, 32700.00, 'delivered', 'darat', 43, NULL, 'Octavian Putra', '2026-03-24 06:00:00', NULL, NULL, NULL, NULL, '2026-03-20 02:30:00', '2026-03-24 06:00:00'),
(16, 'LGSJKT001260410100016', 63, 'Patricia Dewi', '082200000116', 'Jl. Pemuda No. 77, Surakarta', 'Jakarta Utara', 'Surakarta', 16, 2, 10, 1, 2.00, 25.00, 20.00, 15.00, 1.50, 2.00, 'Aksesoris HP - Case & Tempered Glass', 180000.00, 18000.00, 360.00, 18360.00, 'out_for_delivery', 'darat', 42, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-10 03:00:00', '2026-04-27 05:53:33'),
(17, 'LGSBDG001260412083017', 64, 'Qomarudin Hakim', '082200000117', 'Jl. Ijen No. 30, Malang', 'Bandung', 'Malang', 17, 3, 11, 2, 0.80, 15.00, 10.00, 8.00, 0.20, 0.80, 'Kacamata - Frame & Lensa Premium', 500000.00, 14400.00, 1000.00, 15400.00, 'out_for_delivery', 'udara', 40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-12 01:30:00', '2026-05-03 20:30:55'),
(18, 'LGSSMG001260415070018', 65, 'Renata Puspita', '082200000118', 'Jl. Magelang Km 5 No. 10, Yogyakarta', 'Semarang', 'Yogyakarta', 23, 9, 5, 3, 7.00, 50.00, 40.00, 30.00, 12.00, 12.00, 'Buku Teks & Modul Kuliah', 900000.00, 84000.00, 1800.00, 85800.00, 'delivered', 'darat', 46, NULL, 'Renata Puspita', '2026-04-21 08:30:00', NULL, NULL, NULL, NULL, '2026-04-15 00:00:00', '2026-04-21 08:30:00'),
(19, 'LGSBY001260420110019', 66, 'Septian Wahyu', '082200000119', 'Jl. Dhoho No. 15, Kediri', 'Surabaya', 'Kediri', 18, 4, 15, 1, 1.20, 20.00, 15.00, 10.00, 0.60, 1.20, 'Tas Kulit Wanita', 450000.00, 10800.00, 900.00, 11700.00, 'delivered', 'darat', 38, NULL, 'Septian Wahyu', '2026-04-24 09:00:00', NULL, NULL, NULL, NULL, '2026-04-20 04:00:00', '2026-04-24 09:00:00'),
(20, 'LGSBGR001260424090020', 67, 'Trisnawati Handoyo', '082200000120', 'Jl. Veteran No. 5, Serang', 'Bogor', 'Serang', 22, 8, 12, 4, 15.00, 80.00, 60.00, 50.00, 48.00, 48.00, 'Mesin Jahit Industrial', 3500000.00, 240000.00, 7000.00, 247000.00, 'on_transit', 'darat', NULL, 76, NULL, NULL, NULL, NULL, 'Barang berat & fragile, tangani hati-hati', NULL, '2026-04-24 02:00:00', '2026-05-03 14:14:14'),
(21, 'LGSBDG-00126042711440601', 68, 'Salsa Anjani', '08989091764', 'Jl. kolonel No 90', 'Bandung', 'Cimahi', 17, 3, 6, 1, 1.00, 20.00, 20.00, 20.00, 1.60, 1.60, '', 1999999.00, 14400.00, 4000.00, 18400.00, 'delivered', 'darat', 36, NULL, 'Salsa', '2026-04-29 12:57:33', NULL, NULL, NULL, NULL, '2026-04-27 04:44:49', '2026-04-29 12:57:33'),
(22, 'LGSBDG-00126042911562590', 69, 'Anggi', '0898654433', 'Jl. lurah No. 90', 'Bandung', 'Cimahi', 17, 3, 6, 4, 20.00, 50.00, 50.00, 50.00, 25.00, 25.00, 'Elektronik', 4000000.00, 125000.00, 8000.00, 143000.00, 'in_transit_gateway', 'darat', NULL, 70, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-29 04:56:16', '2026-05-05 11:22:58'),
(23, 'LGSCMH-00126050403177358', 84, 'Nadine Puteri', '08765908623', 'Jl. Nyimas Melati No.21, RT.003/RW.001, Kelurahan Sukarasa, Kecamatan Tangerang, Kota Tangerang, Banten 15111', 'Cimahi', 'Tangerang', 20, 6, 7, 1, 3.00, 50.00, 10.00, 40.00, 4.00, 4.00, 'Elektronik', 2999998.00, 36000.00, 6000.00, 47000.00, 'delivered', 'darat', 45, 70, 'Nadine Puteri', '2026-05-03 20:24:57', NULL, NULL, NULL, NULL, '2026-05-03 20:17:46', '2026-05-03 20:24:57'),
(24, 'LGSBDG-00126050411141280', 85, 'Alya', '0896754654', 'Jl. Cipageran No.89 Cimahi ', 'Bandung', 'Cimahi', 17, 3, 6, 1, 2.00, 20.00, 20.00, 20.00, 1.60, 2.00, 'Elektronik', 2000000.00, 18000.00, 4000.00, 27000.00, 'delivered', 'darat', 36, 70, 'alya', '2026-05-04 04:18:13', NULL, NULL, NULL, NULL, '2026-05-04 04:14:02', '2026-05-04 04:18:13'),
(25, 'LGSBDG-00126050518293137', 86, 'Anjani', '08967546547', 'jl. braga', 'Bandung', 'Jakarta Utara', 17, 3, 2, 1, 2.00, 20.00, 20.00, 20.00, 1.60, 2.00, 'Elektronik', 2000000.00, 18000.00, 4000.00, 27000.00, 'in_transit_gateway', 'darat', NULL, 70, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-05 11:29:38', '2026-05-05 11:30:09');

-- --------------------------------------------------------

--
-- Table structure for table `pembayaran`
--

CREATE TABLE `pembayaran` (
  `id` int(11) NOT NULL,
  `paket_id` int(11) DEFAULT NULL,
  `jumlah` decimal(12,2) DEFAULT NULL,
  `metode` enum('tunai','transfer','qris','virtual_account','credit_card') DEFAULT 'tunai',
  `xendit_invoice_id` varchar(100) DEFAULT NULL,
  `xendit_invoice_url` text DEFAULT NULL,
  `xendit_external_id` varchar(100) DEFAULT NULL,
  `xendit_paid_at` timestamp NULL DEFAULT NULL,
  `xendit_payment_method` varchar(50) DEFAULT NULL,
  `status` enum('pending','lunas','batal') DEFAULT 'pending',
  `dicatat_oleh` int(11) DEFAULT NULL,
  `catatan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pembayaran`
--

INSERT INTO `pembayaran` (`id`, `paket_id`, `jumlah`, `metode`, `xendit_invoice_id`, `xendit_invoice_url`, `xendit_external_id`, `xendit_paid_at`, `xendit_payment_method`, `status`, `dicatat_oleh`, `catatan`, `created_at`, `updated_at`) VALUES
(1, 1, 28600.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 17, NULL, '2025-10-01 01:02:00', '2025-10-01 01:02:00'),
(2, 2, 18100.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 18, NULL, '2025-10-08 02:32:00', '2026-04-27 11:55:13'),
(3, 3, 9000.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 19, NULL, '2025-11-05 06:02:00', '2025-11-05 06:02:00'),
(4, 4, 36500.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 20, NULL, '2025-11-15 03:02:00', '2025-11-15 03:02:00'),
(5, 5, 27800.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 21, NULL, '2025-11-20 01:32:00', '2025-11-20 01:32:00'),
(6, 6, 18600.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 22, NULL, '2025-12-01 02:02:00', '2025-12-01 02:02:00'),
(7, 7, 62400.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 23, NULL, '2025-12-10 04:02:00', '2025-12-10 04:02:00'),
(8, 8, 23200.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 24, NULL, '2025-12-20 01:02:00', '2025-12-20 01:02:00'),
(9, 9, 37600.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 17, NULL, '2026-01-05 03:02:00', '2026-01-05 03:02:00'),
(10, 10, 5400.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 18, NULL, '2026-01-15 07:02:00', '2026-01-15 07:02:00'),
(11, 11, 59160.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 19, NULL, '2026-02-01 02:02:00', '2026-02-01 02:02:00'),
(12, 12, 14000.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 7, NULL, '2026-02-14 01:02:00', '2026-04-29 12:58:12'),
(13, 13, 9300.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 23, NULL, '2026-03-01 04:02:00', '2026-03-01 04:02:00'),
(14, 14, 123000.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 21, NULL, '2026-03-10 01:02:00', '2026-03-10 01:02:00'),
(15, 15, 32700.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 22, NULL, '2026-03-20 02:32:00', '2026-03-20 02:32:00'),
(16, 16, 18360.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 17, NULL, '2026-04-10 03:02:00', '2026-04-10 03:02:00'),
(17, 17, 15400.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 18, NULL, '2026-04-12 01:32:00', '2026-04-12 01:32:00'),
(18, 18, 85800.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 24, NULL, '2026-04-15 00:02:00', '2026-04-15 00:02:00'),
(19, 19, 11700.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 19, NULL, '2026-04-20 04:02:00', '2026-04-20 04:05:00'),
(20, 20, 247000.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 23, NULL, '2026-04-24 02:02:00', '2026-04-24 02:10:00'),
(21, 21, 18400.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 7, NULL, '2026-04-27 04:44:49', '2026-04-29 13:00:15'),
(22, 22, 143000.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 18, NULL, '2026-04-29 04:56:16', '2026-05-02 07:59:10'),
(23, 23, 47000.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 21, NULL, '2026-05-03 20:17:46', '2026-05-03 20:17:53'),
(24, 24, 27000.00, 'tunai', NULL, NULL, NULL, NULL, NULL, 'lunas', 18, NULL, '2026-05-04 04:14:02', '2026-05-04 04:14:17'),
(25, 25, 27000.00, 'transfer', '69fc13d1171632a4f74768af', 'https://checkout-staging.xendit.co/web/69fc13d1171632a4f74768af', 'LGS-LGSBDG-00126050518293137-25-06E56754', '2026-05-06 08:28:15', 'QRIS', 'pending', 18, ' | [SIMULASI] Dibayar via QRIS — 06/05/2026 15:11 | [SIMULASI] Dibayar via DANA — 06/05/2026 15:11 | [SIMULASI] Dibayar via CREDIT_CARD — 06/05/2026 15:11 | [SIMULASI] Dibayar via QRIS — 06/05/2026 15:28', '2026-05-05 11:29:38', '2026-05-07 04:23:45');

-- --------------------------------------------------------

--
-- Table structure for table `riwayat_status`
--

CREATE TABLE `riwayat_status` (
  `id` int(11) NOT NULL,
  `paket_id` int(11) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `keterangan` text DEFAULT NULL,
  `lokasi` varchar(200) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `riwayat_status`
--

INSERT INTO `riwayat_status` (`id`, `paket_id`, `status`, `keterangan`, `lokasi`, `user_id`, `created_at`, `latitude`, `longitude`) VALUES
(1, 1, 'created', 'Paket diterima dari Bagas Prasetyo. Layanan: Reguler. Tunai lunas.', 'Cabang Jakarta Utara', 17, '2025-10-01 01:00:00', NULL, NULL),
(2, 1, 'sorting_origin', 'Paket selesai disortir di Cabang Jakarta Utara, siap dikirim ke gateway.', 'Cabang Jakarta Utara', 17, '2025-10-01 03:30:00', NULL, NULL),
(3, 1, 'in_transit_gateway', 'Paket dikirim dari Cabang Jakarta Utara menuju Jakarta Gateway.', 'Jakarta Utara ke Jakarta Gateway', 3, '2025-10-01 07:00:00', NULL, NULL),
(4, 1, 'gateway_origin', 'Paket diterima dan diproses di Jakarta Gateway. Siap berangkat antar kota.', 'Jakarta Gateway', 3, '2025-10-01 10:00:00', NULL, NULL),
(5, 1, 'on_transit', 'Paket berangkat dari Jakarta Gateway menuju Surabaya Gateway via jalur darat.', 'Jakarta menuju Surabaya', 3, '2025-10-01 23:00:00', NULL, NULL),
(6, 1, 'arrived_gateway_dest', 'Paket tiba di Surabaya Gateway. Menunggu penugasan kurir.', 'Surabaya Gateway', 5, '2025-10-04 03:00:00', NULL, NULL),
(7, 1, 'out_for_delivery', 'Kurir Budi Santoso keluar mengantar paket ke Wulandari Safitri.', 'Surabaya', 5, '2025-10-05 01:00:00', NULL, NULL),
(8, 1, 'delivered', 'Paket berhasil diterima oleh Wulandari Safitri. Tanda terima OK.', 'Jl. Raya Darmo No. 7, Surabaya', 41, '2025-10-05 07:30:00', NULL, NULL),
(9, 2, 'created', 'Paket diterima dari Citra Dewi. Layanan: OKE Ekonomis. Transfer BCA lunas.', 'Cabang Bandung Utara', 18, '2025-10-08 02:30:00', NULL, NULL),
(10, 2, 'sorting_origin', 'Paket disortir di Cabang Bandung Utara. Antrian OKE, jadwal normal.', 'Cabang Bandung Utara', 18, '2025-10-08 04:00:00', NULL, NULL),
(11, 2, 'in_transit_gateway', 'Paket dikirim dari Bandung Utara menuju Bandung Gateway.', 'Bandung Utara ke Bandung Gateway', 4, '2025-10-08 07:00:00', NULL, NULL),
(12, 2, 'gateway_origin', 'Paket diproses di Bandung Gateway. Armada darat ke Yogyakarta disiapkan.', 'Bandung Gateway', 4, '2025-10-08 10:00:00', NULL, NULL),
(13, 2, 'on_transit', 'Paket berangkat dari Bandung Gateway menuju Yogyakarta Gateway via jalur darat.', 'Bandung menuju Yogyakarta', 4, '2025-10-08 23:00:00', NULL, NULL),
(14, 2, 'arrived_gateway_dest', 'Paket tiba di Yogyakarta Gateway. Kurir akan segera ditugaskan.', 'Yogyakarta Gateway', 6, '2025-10-11 05:00:00', NULL, NULL),
(15, 2, 'out_for_delivery', 'Kurir Dimas Pratama keluar mengantar paket ke Rendra Kusuma.', 'Yogyakarta', 6, '2025-10-12 01:00:00', NULL, NULL),
(16, 2, 'delivered', 'Paket buku diterima oleh Rendra Kusuma. Kondisi baik.', 'Jl. Malioboro No. 25, Yogyakarta', 46, '2025-10-12 03:15:00', NULL, NULL),
(17, 3, 'created', 'Paket diterima dari Darmawan Putra. Layanan: YES (Yakin Esok Sampai). QRIS lunas.', 'Cabang Surabaya Pusat', 19, '2025-11-05 06:00:00', NULL, NULL),
(18, 3, 'sorting_origin', 'Paket sortir ekspres YES di Surabaya Pusat. Prioritas tinggi.', 'Cabang Surabaya Pusat', 19, '2025-11-05 07:00:00', NULL, NULL),
(19, 3, 'in_transit_gateway', 'Paket dikirim dari Surabaya Pusat ke Surabaya Gateway untuk penerbangan.', 'Surabaya Pusat ke Surabaya Gateway', 5, '2025-11-05 09:00:00', NULL, NULL),
(20, 3, 'gateway_origin', 'Paket diproses di Surabaya Gateway. Dijadwalkan penerbangan malam ke Semarang.', 'Surabaya Gateway', 5, '2025-11-05 11:00:00', NULL, NULL),
(21, 3, 'on_transit', 'Paket dalam penerbangan dari Surabaya menuju Semarang via jalur udara.', 'Surabaya menuju Semarang udara', 5, '2025-11-05 14:00:00', NULL, NULL),
(22, 3, 'arrived_gateway_dest', 'Paket tiba di Semarang Gateway dini hari. Kurir siap bertugas pagi.', 'Semarang Gateway', 10, '2025-11-05 22:00:00', NULL, NULL),
(23, 3, 'out_for_delivery', 'Kurir Teguh Wibowo keluar mengantar ke Annisa Kurniawati.', 'Semarang', 10, '2025-11-06 00:00:00', NULL, NULL),
(24, 3, 'delivered', 'Dokumen kontrak diterima oleh Annisa Kurniawati. Kondisi aman.', 'Jl. Pandanaran No. 40, Semarang', 43, '2025-11-06 02:00:00', NULL, NULL),
(25, 4, 'created', 'Paket diterima dari Elvira Suharto. Layanan: OKE Ekonomis. Tunai lunas.', 'Cabang Yogyakarta Kota', 20, '2025-11-15 03:00:00', NULL, NULL),
(26, 4, 'sorting_origin', 'Paket disortir di Cabang Yogyakarta Kota.', 'Cabang Yogyakarta Kota', 20, '2025-11-15 05:00:00', NULL, NULL),
(27, 4, 'in_transit_gateway', 'Paket dikirim dari Yogyakarta Kota ke Yogyakarta Gateway.', 'Yogyakarta Kota ke Yogyakarta Gateway', 6, '2025-11-15 09:00:00', NULL, NULL),
(28, 4, 'gateway_origin', 'Paket diproses di Yogyakarta Gateway. Armada darat ke Tangerang disiapkan.', 'Yogyakarta Gateway', 6, '2025-11-15 12:00:00', NULL, NULL),
(29, 4, 'on_transit', 'Paket berangkat dari Yogyakarta ke Tangerang Gateway via jalur darat.', 'Yogyakarta menuju Tangerang', 6, '2025-11-15 22:00:00', NULL, NULL),
(30, 4, 'arrived_gateway_dest', 'Paket tiba di Tangerang Gateway. Menunggu penugasan kurir.', 'Tangerang Gateway', 8, '2025-11-20 04:00:00', NULL, NULL),
(31, 4, 'out_for_delivery', 'Kurir Fajar Nugroho keluar mengantar ke Bintang Erlangga.', 'Tangerang', 8, '2025-11-21 02:00:00', NULL, NULL),
(32, 4, 'delivered', 'Kerajinan batik diterima oleh Bintang Erlangga. Kondisi baik.', 'Jl. MH Thamrin No. 55, Tangerang', 45, '2025-11-21 09:00:00', NULL, NULL),
(33, 5, 'created', 'Paket diterima dari Fachri Ramadan. Layanan: Reguler. Transfer BNI lunas.', 'Cabang Cimahi Tengah', 21, '2025-11-20 01:30:00', NULL, NULL),
(34, 5, 'sorting_origin', 'Paket disortir di Cabang Cimahi Tengah.', 'Cabang Cimahi Tengah', 21, '2025-11-20 03:00:00', NULL, NULL),
(35, 5, 'in_transit_gateway', 'Paket dikirim dari Cimahi Tengah ke Cimahi Gateway.', 'Cimahi Tengah ke Cimahi Gateway', 7, '2025-11-20 06:00:00', NULL, NULL),
(36, 5, 'gateway_origin', 'Paket diproses di Cimahi Gateway. Siap berangkat ke Bogor.', 'Cimahi Gateway', 7, '2025-11-20 09:00:00', NULL, NULL),
(37, 5, 'on_transit', 'Paket berangkat dari Cimahi menuju Bogor Gateway via jalur darat.', 'Cimahi menuju Bogor', 7, '2025-11-20 23:00:00', NULL, NULL),
(38, 5, 'arrived_gateway_dest', 'Paket tiba di Bogor Gateway. Kurir segera ditugaskan.', 'Bogor Gateway', 9, '2025-11-22 03:00:00', NULL, NULL),
(39, 5, 'out_for_delivery', 'Kurir Eko Prasetyo keluar mengantar ke Dewi Maharani.', 'Bogor', 9, '2025-11-24 01:00:00', NULL, NULL),
(40, 5, 'delivered', 'Sepatu dan sandal diterima oleh Dewi Maharani. Kondisi baik.', 'Jl. Pajajaran No. 33, Bogor', 34, '2025-11-24 04:30:00', NULL, NULL),
(41, 6, 'created', 'Paket diterima dari Gilang Nugraha. Layanan: YES. QRIS lunas.', 'Cabang Tangerang Kota', 22, '2025-12-01 02:00:00', NULL, NULL),
(42, 6, 'sorting_origin', 'Paket sortir ekspres YES di Tangerang Kota. Prioritas pengiriman hari ini.', 'Cabang Tangerang Kota', 22, '2025-12-01 03:00:00', NULL, NULL),
(43, 6, 'in_transit_gateway', 'Paket dikirim dari Tangerang Kota ke Tangerang Gateway.', 'Tangerang Kota ke Tangerang Gateway', 8, '2025-12-01 05:00:00', NULL, NULL),
(44, 6, 'gateway_origin', 'Paket diproses di Tangerang Gateway. Jadwal penerbangan sore ke Bekasi.', 'Tangerang Gateway', 8, '2025-12-01 06:30:00', NULL, NULL),
(45, 6, 'on_transit', 'Paket dalam pengiriman udara dari Tangerang ke Bekasi.', 'Tangerang menuju Bekasi udara', 8, '2025-12-01 08:00:00', NULL, NULL),
(46, 6, 'arrived_gateway_dest', 'Paket tiba di Bekasi Gateway. Kurir pagi ditugaskan.', 'Bekasi Gateway', 15, '2025-12-02 00:00:00', NULL, NULL),
(47, 6, 'out_for_delivery', 'Kurir Arif Rahman keluar mengantar ke Fitriani Lestari.', 'Bekasi', 15, '2025-12-02 01:30:00', NULL, NULL),
(48, 6, 'delivered', 'Kosmetik diterima oleh Fitriani Lestari. Kondisi baik.', 'Jl. Ahmad Yani No. 18, Bekasi', 35, '2025-12-02 06:45:00', NULL, NULL),
(49, 7, 'created', 'Paket diterima dari Hana Permatasari. Layanan: JTR Trucking. Vol 12kg > aktual 8kg. Tunai lunas.', 'Cabang Bogor Kota', 23, '2025-12-10 04:00:00', NULL, NULL),
(50, 7, 'sorting_origin', 'Paket JTR disortir di Bogor Kota. Dimensi besar 50x40x30cm, berat volumetrik 12 kg.', 'Cabang Bogor Kota', 23, '2025-12-10 06:00:00', NULL, NULL),
(51, 7, 'in_transit_gateway', 'Paket trucking dikirim dari Bogor Kota ke Bogor Gateway.', 'Bogor Kota ke Bogor Gateway', 9, '2025-12-10 09:00:00', NULL, NULL),
(52, 7, 'gateway_origin', 'Paket JTR diproses di Bogor Gateway. Menunggu armada trucking ke Surakarta.', 'Bogor Gateway', 9, '2025-12-10 12:00:00', NULL, NULL),
(53, 7, 'on_transit', 'Armada trucking berangkat dari Bogor menuju Surakarta via jalur darat.', 'Bogor menuju Surakarta', 9, '2025-12-10 22:00:00', NULL, NULL),
(54, 7, 'arrived_gateway_dest', 'Paket tiba di Surakarta Gateway. Kurir barang besar ditugaskan.', 'Surakarta Gateway', 11, '2025-12-15 07:00:00', NULL, NULL),
(55, 7, 'out_for_delivery', 'Kurir Agus Setiawan keluar mengantar ke Gunawan Triastanto.', 'Surakarta', 11, '2025-12-17 01:00:00', NULL, NULL),
(56, 7, 'delivered', 'Peralatan dapur diterima oleh Gunawan Triastanto. Kondisi baik.', 'Jl. Slamet Riyadi No. 100, Surakarta', 42, '2025-12-17 08:00:00', NULL, NULL),
(57, 8, 'created', 'Paket diterima dari Irfan Maulana. Layanan: Reguler. Transfer Mandiri lunas.', 'Cabang Semarang Kota', 24, '2025-12-20 01:00:00', NULL, NULL),
(58, 8, 'sorting_origin', 'Paket disortir di Cabang Semarang Kota.', 'Cabang Semarang Kota', 24, '2025-12-20 03:00:00', NULL, NULL),
(59, 8, 'in_transit_gateway', 'Paket dikirim dari Semarang Kota ke Semarang Gateway.', 'Semarang Kota ke Semarang Gateway', 10, '2025-12-20 06:00:00', NULL, NULL),
(60, 8, 'gateway_origin', 'Paket diproses di Semarang Gateway. Siap berangkat ke Kediri.', 'Semarang Gateway', 10, '2025-12-20 09:00:00', NULL, NULL),
(61, 8, 'on_transit', 'Paket berangkat dari Semarang ke Kediri Gateway via jalur darat.', 'Semarang menuju Kediri', 10, '2025-12-20 23:00:00', NULL, NULL),
(62, 8, 'arrived_gateway_dest', 'Paket tiba di Kediri Gateway. Kurir ditugaskan menjelang Natal.', 'Kediri Gateway', 16, '2025-12-23 04:00:00', NULL, NULL),
(63, 8, 'out_for_delivery', 'Kurir Hendra Wijaya keluar mengantar ke Hardianti Putri.', 'Kediri', 16, '2025-12-24 01:00:00', NULL, NULL),
(64, 8, 'delivered', 'Mainan anak diterima oleh Hardianti Putri. Kondisi baik.', 'Jl. Dhoho No. 50, Kediri', 38, '2025-12-24 03:00:00', NULL, NULL),
(65, 9, 'created', 'Paket diterima dari Julia Rahayu. Layanan: Reguler. Tunai lunas.', 'Cabang Jakarta Utara', 17, '2026-01-05 03:00:00', NULL, NULL),
(66, 9, 'sorting_origin', 'Paket disortir di Cabang Jakarta Utara.', 'Cabang Jakarta Utara', 17, '2026-01-05 04:30:00', NULL, NULL),
(67, 9, 'in_transit_gateway', 'Paket dikirim dari Jakarta Utara ke Jakarta Gateway.', 'Jakarta Utara ke Jakarta Gateway', 3, '2026-01-05 07:00:00', NULL, NULL),
(68, 9, 'gateway_origin', 'Paket diproses di Jakarta Gateway. Siap berangkat ke Bandung.', 'Jakarta Gateway', 3, '2026-01-05 10:00:00', NULL, NULL),
(69, 9, 'on_transit', 'Paket berangkat dari Jakarta ke Bandung Gateway via jalur darat.', 'Jakarta menuju Bandung', 3, '2026-01-05 23:00:00', NULL, NULL),
(70, 9, 'arrived_gateway_dest', 'Paket tiba di Bandung Gateway. Kurir ditugaskan.', 'Bandung Gateway', 4, '2026-01-07 03:00:00', NULL, NULL),
(71, 9, 'out_for_delivery', 'Kurir Rizky Maulana keluar mengantar ke Indraswara Yudha.', 'Bandung', 4, '2026-01-09 01:00:00', NULL, NULL),
(72, 9, 'delivered', 'Elektronik diterima oleh Indraswara Yudha. Kondisi baik.', 'Jl. Setiabudi No. 66, Bandung', 33, '2026-01-09 05:00:00', NULL, NULL),
(73, 10, 'created', 'Paket diterima dari Kevin Satria. Layanan: YES. QRIS lunas.', 'Cabang Bandung Utara', 18, '2026-01-15 07:00:00', NULL, NULL),
(74, 10, 'sorting_origin', 'Paket sortir ekspres YES di Bandung Utara.', 'Cabang Bandung Utara', 18, '2026-01-15 08:00:00', NULL, NULL),
(75, 10, 'in_transit_gateway', 'Paket dikirim dari Bandung Utara ke Bandung Gateway.', 'Bandung Utara ke Bandung Gateway', 4, '2026-01-15 10:00:00', NULL, NULL),
(76, 10, 'gateway_origin', 'Paket diproses di Bandung Gateway. Jadwal penerbangan malam ke Surabaya.', 'Bandung Gateway', 4, '2026-01-15 12:00:00', NULL, NULL),
(77, 10, 'on_transit', 'Paket dalam penerbangan dari Bandung ke Surabaya via jalur udara.', 'Bandung menuju Surabaya udara', 4, '2026-01-15 15:00:00', NULL, NULL),
(78, 10, 'arrived_gateway_dest', 'Paket tiba di Surabaya Gateway dini hari. Kurir pagi ditugaskan.', 'Surabaya Gateway', 5, '2026-01-15 21:00:00', NULL, NULL),
(79, 10, 'out_for_delivery', 'Kurir Budi Santoso keluar mengantar ke Jelita Amelia.', 'Surabaya', 5, '2026-01-16 00:00:00', NULL, NULL),
(80, 10, 'delivered', 'Dokumen kontrak diterima oleh Jelita Amelia. Kondisi aman.', 'Jl. Basuki Rahmat No. 77, Surabaya', 41, '2026-01-16 01:30:00', NULL, NULL),
(81, 11, 'created', 'Paket diterima dari Laras Wulandari. Layanan: OKE. Vol 7.88kg > aktual 6kg. Transfer BRI lunas.', 'Cabang Surabaya Pusat', 19, '2026-02-01 02:00:00', NULL, NULL),
(82, 11, 'sorting_origin', 'Paket OKE disortir di Surabaya Pusat. Dimensi 45x35x25cm, berat volumetrik 7.88 kg.', 'Cabang Surabaya Pusat', 19, '2026-02-01 04:00:00', NULL, NULL),
(83, 11, 'in_transit_gateway', 'Paket dikirim dari Surabaya Pusat ke Surabaya Gateway.', 'Surabaya Pusat ke Surabaya Gateway', 5, '2026-02-01 08:00:00', NULL, NULL),
(84, 11, 'gateway_origin', 'Paket diproses di Surabaya Gateway. Armada darat ke Yogyakarta disiapkan.', 'Surabaya Gateway', 5, '2026-02-01 11:00:00', NULL, NULL),
(85, 11, 'on_transit', 'Paket berangkat dari Surabaya ke Yogyakarta Gateway via jalur darat.', 'Surabaya menuju Yogyakarta', 5, '2026-02-01 22:00:00', NULL, NULL),
(86, 11, 'arrived_gateway_dest', 'Paket tiba di Yogyakarta Gateway. Kurir barang besar ditugaskan.', 'Yogyakarta Gateway', 6, '2026-02-05 04:00:00', NULL, NULL),
(87, 11, 'out_for_delivery', 'Kurir Dimas Pratama keluar mengantar ke Kurniawan Adi.', 'Yogyakarta', 6, '2026-02-08 01:00:00', NULL, NULL),
(88, 11, 'delivered', 'Rak buku diterima oleh Kurniawan Adi. Kondisi baik.', 'Jl. Kaliurang No. 8, Yogyakarta', 46, '2026-02-08 07:00:00', NULL, NULL),
(89, 12, 'created', 'Paket diterima dari Mahendra Kusuma. Layanan: Reguler. Tunai lunas.', 'Cabang Yogyakarta Kota', 20, '2026-02-14 01:00:00', NULL, NULL),
(90, 12, 'sorting_origin', 'Paket disortir di Cabang Yogyakarta Kota.', 'Cabang Yogyakarta Kota', 20, '2026-02-14 03:00:00', NULL, NULL),
(91, 12, 'in_transit_gateway', 'Paket dikirim dari Yogyakarta Kota ke Yogyakarta Gateway.', 'Yogyakarta Kota ke Yogyakarta Gateway', 6, '2026-02-14 06:00:00', NULL, NULL),
(92, 12, 'gateway_origin', 'Paket diproses di Yogyakarta Gateway. Siap berangkat ke Cimahi.', 'Yogyakarta Gateway', 6, '2026-02-14 09:00:00', NULL, NULL),
(93, 12, 'on_transit', 'Paket berangkat dari Yogyakarta ke Cimahi Gateway via jalur darat.', 'Yogyakarta menuju Cimahi', 6, '2026-02-14 22:00:00', NULL, NULL),
(94, 12, 'arrived_gateway_dest', 'Paket tiba di Cimahi Gateway. Kurir ditugaskan.', 'Cimahi Gateway', 7, '2026-02-17 04:00:00', NULL, NULL),
(95, 12, 'out_for_delivery', 'Kurir Asep Hidayat keluar mengantar ke Lestari Ningrum.', 'Cimahi', 7, '2026-02-18 01:00:00', NULL, NULL),
(96, 12, 'delivered', 'Oleh-oleh Yogya diterima oleh Lestari Ningrum. Kondisi baik.', 'Jl. Amir Machmud No. 44, Cimahi', 36, '2026-02-18 04:00:00', NULL, NULL),
(97, 13, 'created', 'Paket diterima dari Nadia Fitri. Layanan: YES. QRIS lunas.', 'Cabang Bogor Kota', 23, '2026-03-01 04:00:00', NULL, NULL),
(98, 13, 'sorting_origin', 'Paket sortir ekspres YES di Bogor Kota.', 'Cabang Bogor Kota', 23, '2026-03-01 05:00:00', NULL, NULL),
(99, 13, 'in_transit_gateway', 'Paket dikirim dari Bogor Kota ke Bogor Gateway.', 'Bogor Kota ke Bogor Gateway', 9, '2026-03-01 06:30:00', NULL, NULL),
(100, 13, 'gateway_origin', 'Paket diproses di Bogor Gateway. Jadwal penerbangan sore ke Tangerang.', 'Bogor Gateway', 9, '2026-03-01 07:30:00', NULL, NULL),
(101, 13, 'on_transit', 'Paket dalam pengiriman udara dari Bogor ke Tangerang.', 'Bogor menuju Tangerang udara', 9, '2026-03-01 09:00:00', NULL, NULL),
(102, 13, 'arrived_gateway_dest', 'Paket tiba di Tangerang Gateway. Kurir pagi ditugaskan.', 'Tangerang Gateway', 8, '2026-03-01 23:00:00', NULL, NULL),
(103, 13, 'out_for_delivery', 'Kurir Fajar Nugroho keluar mengantar ke Marcelino Santoso.', 'Tangerang', 8, '2026-03-02 01:00:00', NULL, NULL),
(104, 13, 'delivered', 'Obat-obatan diterima oleh Marcelino Santoso. Kondisi baik.', 'Jl. Daan Mogot No. 99, Tangerang', 45, '2026-03-02 03:30:00', NULL, NULL),
(105, 14, 'created', 'Paket diterima dari Oscar Hidayat. Layanan: JTR Trucking. Vol 24kg > aktual 10kg. Tunai lunas.', 'Cabang Cimahi Tengah', 21, '2026-03-10 01:00:00', NULL, NULL),
(106, 14, 'sorting_origin', 'Paket JTR disortir di Cimahi Tengah. Dimensi 60x50x40cm, berat volumetrik 24 kg.', 'Cabang Cimahi Tengah', 21, '2026-03-10 03:00:00', NULL, NULL),
(107, 14, 'in_transit_gateway', 'Paket trucking dikirim dari Cimahi Tengah ke Cimahi Gateway.', 'Cimahi Tengah ke Cimahi Gateway', 7, '2026-03-10 07:00:00', NULL, NULL),
(108, 14, 'gateway_origin', 'Paket JTR diproses di Cimahi Gateway. Armada trucking ke Bogor disiapkan.', 'Cimahi Gateway', 7, '2026-03-10 10:00:00', NULL, NULL),
(109, 14, 'on_transit', 'Armada trucking berangkat dari Cimahi ke Bogor Gateway via jalur darat.', 'Cimahi menuju Bogor', 7, '2026-03-10 23:00:00', NULL, NULL),
(110, 14, 'arrived_gateway_dest', 'Paket tiba di Bogor Gateway. Kurir khusus barang berat ditugaskan.', 'Bogor Gateway', 9, '2026-03-15 05:00:00', NULL, NULL),
(111, 14, 'out_for_delivery', 'Kurir Eko Prasetyo keluar mengantar ke Novita Susanti.', 'Bogor', 9, '2026-03-17 01:00:00', NULL, NULL),
(112, 14, 'delivered', 'Spare part motor diterima oleh Novita Susanti. Kondisi baik.', 'Jl. Juanda No. 22, Bogor', 34, '2026-03-17 08:30:00', NULL, NULL),
(113, 15, 'created', 'Paket diterima dari Prita Anggraeni. Layanan: Reguler. Transfer BCA lunas.', 'Cabang Tangerang Kota', 22, '2026-03-20 02:30:00', NULL, NULL),
(114, 15, 'sorting_origin', 'Paket disortir di Cabang Tangerang Kota.', 'Cabang Tangerang Kota', 22, '2026-03-20 04:00:00', NULL, NULL),
(115, 15, 'in_transit_gateway', 'Paket dikirim dari Tangerang Kota ke Tangerang Gateway.', 'Tangerang Kota ke Tangerang Gateway', 8, '2026-03-20 07:00:00', NULL, NULL),
(116, 15, 'gateway_origin', 'Paket diproses di Tangerang Gateway. Siap berangkat ke Semarang.', 'Tangerang Gateway', 8, '2026-03-20 10:00:00', NULL, NULL),
(117, 15, 'on_transit', 'Paket berangkat dari Tangerang ke Semarang Gateway via jalur darat.', 'Tangerang menuju Semarang', 8, '2026-03-20 22:00:00', NULL, NULL),
(118, 15, 'arrived_gateway_dest', 'Paket tiba di Semarang Gateway. Kurir ditugaskan.', 'Semarang Gateway', 10, '2026-03-23 04:00:00', NULL, NULL),
(119, 15, 'out_for_delivery', 'Kurir Teguh Wibowo keluar mengantar ke Octavian Putra.', 'Semarang', 10, '2026-03-24 01:00:00', NULL, NULL),
(120, 15, 'delivered', 'Batik Pekalongan diterima oleh Octavian Putra. Kondisi baik.', 'Jl. Ahmad Yani No. 12, Semarang', 43, '2026-03-24 06:00:00', NULL, NULL),
(121, 16, 'created', 'Paket diterima dari Rizal Firmansyah. Layanan: Reguler. QRIS lunas.', 'Cabang Jakarta Utara', 17, '2026-04-10 03:00:00', NULL, NULL),
(122, 16, 'sorting_origin', 'Paket disortir di Cabang Jakarta Utara.', 'Cabang Jakarta Utara', 17, '2026-04-10 05:00:00', NULL, NULL),
(123, 16, 'in_transit_gateway', 'Paket dikirim dari Jakarta Utara ke Jakarta Gateway.', 'Jakarta Utara ke Jakarta Gateway', 3, '2026-04-10 08:00:00', NULL, NULL),
(124, 16, 'gateway_origin', 'Paket diproses di Jakarta Gateway. Siap berangkat ke Surakarta.', 'Jakarta Gateway', 3, '2026-04-10 11:00:00', NULL, NULL),
(125, 16, 'on_transit', 'Paket berangkat dari Jakarta ke Surakarta Gateway via jalur darat.', 'Jakarta menuju Surakarta', 3, '2026-04-10 23:00:00', NULL, NULL),
(126, 16, 'arrived_gateway_dest', 'Paket tiba di Surakarta Gateway. Kurir Agus Setiawan ditugaskan.', 'Surakarta Gateway', 11, '2026-04-13 05:00:00', NULL, NULL),
(127, 16, 'out_for_delivery', 'Kurir Agus Setiawan sedang mengantar ke Patricia Dewi. Estimasi tiba hari ini.', 'Surakarta', 11, '2026-04-14 01:00:00', NULL, NULL),
(128, 17, 'created', 'Paket diterima dari Salma Khoiriyah. Layanan: YES. Transfer BNI lunas.', 'Cabang Bandung Utara', 18, '2026-04-12 01:30:00', NULL, NULL),
(129, 17, 'sorting_origin', 'Paket sortir ekspres YES di Bandung Utara.', 'Cabang Bandung Utara', 18, '2026-04-12 03:00:00', NULL, NULL),
(130, 17, 'in_transit_gateway', 'Paket dikirim dari Bandung Utara ke Bandung Gateway.', 'Bandung Utara ke Bandung Gateway', 4, '2026-04-12 06:00:00', NULL, NULL),
(131, 17, 'gateway_origin', 'Paket diproses di Bandung Gateway. Jadwal penerbangan malam ke Malang.', 'Bandung Gateway', 4, '2026-04-12 09:00:00', NULL, NULL),
(132, 17, 'on_transit', 'Paket dalam penerbangan dari Bandung ke Malang via jalur udara.', 'Bandung menuju Malang udara', 4, '2026-04-12 13:00:00', NULL, NULL),
(133, 17, 'arrived_gateway_dest', 'Paket tiba di Malang Gateway. Menunggu penugasan kurir untuk pengantaran ke Qomarudin Hakim.', 'Malang Gateway', 12, '2026-04-13 09:00:00', NULL, NULL),
(134, 18, 'created', 'Paket diterima dari Taufiq Hidayat. Layanan: OKE. Vol 12kg > aktual 7kg. Tunai lunas.', 'Cabang Semarang Kota', 24, '2026-04-15 00:00:00', NULL, NULL),
(135, 18, 'sorting_origin', 'Paket OKE disortir di Semarang Kota. Dimensi 50x40x30cm, berat volumetrik 12 kg.', 'Cabang Semarang Kota', 24, '2026-04-15 02:00:00', NULL, NULL),
(136, 18, 'in_transit_gateway', 'Paket dikirim dari Semarang Kota ke Semarang Gateway.', 'Semarang Kota ke Semarang Gateway', 10, '2026-04-15 06:00:00', NULL, NULL),
(137, 18, 'gateway_origin', 'Paket diproses di Semarang Gateway. Armada darat ke Yogyakarta disiapkan.', 'Semarang Gateway', 10, '2026-04-15 10:00:00', NULL, NULL),
(138, 18, 'on_transit', 'Paket sedang dalam perjalanan darat dari Semarang menuju Yogyakarta Gateway.', 'Semarang menuju Yogyakarta', 10, '2026-04-16 03:00:00', NULL, NULL),
(139, 18, 'arrived_gateway_dest', 'Paket tiba di Yogyakarta Gateway. Kurir ditugaskan untuk pengantaran.', 'Yogyakarta Gateway, Jl. Magelang No. 15, Sleman', 6, '2026-04-18 07:00:00', NULL, NULL),
(140, 18, 'out_for_delivery', 'Kurir Dimas Pratama keluar mengantar ke Renata Puspita.', 'Yogyakarta', 6, '2026-04-21 07:00:00', NULL, NULL),
(141, 18, 'delivered', 'Buku teks dan modul kuliah diterima oleh Renata Puspita. Kondisi baik.', 'Jl. Magelang Km 5 No. 10, Yogyakarta', 46, '2026-04-21 08:30:00', NULL, NULL),
(142, 19, 'created', 'Paket diterima dari Ulfa Mardhiyah. Layanan: Reguler. Tunai lunas.', 'Cabang Surabaya Pusat, Jl. Basuki Rahmat No. 20, Surabaya', 19, '2026-04-20 04:00:00', NULL, NULL),
(143, 19, 'sorting_origin', 'Paket sedang dalam proses sortir di Cabang Surabaya Pusat.', 'Cabang Surabaya Pusat, Jl. Basuki Rahmat No. 20, Surabaya', 19, '2026-04-20 06:30:00', NULL, NULL),
(144, 19, 'in_transit_gateway', 'Paket dikirim dari Surabaya Pusat ke Surabaya Gateway.', 'Surabaya Pusat ke Surabaya Gateway, Jl. Perak Timur No. 10, Surabaya', 5, '2026-04-20 10:00:00', NULL, NULL),
(145, 19, 'gateway_origin', 'Paket diproses di Surabaya Gateway. Armada darat ke Kediri disiapkan.', 'Surabaya Gateway, Jl. Perak Timur No. 10, Surabaya', 5, '2026-04-20 14:00:00', NULL, NULL),
(146, 19, 'on_transit', 'Paket berangkat dari Surabaya ke Kediri Gateway via jalur darat.', 'Surabaya menuju Kediri', 5, '2026-04-21 00:00:00', NULL, NULL),
(147, 19, 'arrived_gateway_dest', 'Paket tiba di Kediri Gateway. Kurir Hendra Wijaya ditugaskan.', 'Kediri Gateway, Jl. Dhoho No. 77, Kediri', 16, '2026-04-22 05:00:00', NULL, NULL),
(148, 19, 'out_for_delivery', 'Kurir Hendra Wijaya keluar mengantar ke Septian Wahyu.', 'Kediri', 16, '2026-04-24 08:00:00', NULL, NULL),
(149, 19, 'delivered', 'Tas kulit wanita diterima oleh Septian Wahyu. Kondisi baik.', 'Jl. Dhoho No. 15, Kediri', 38, '2026-04-24 09:00:00', NULL, NULL),
(150, 20, 'created', 'Paket diterima dari Vandra Setiawan. Layanan: JTR Trucking. Dimensi 80x60x50cm, berat volumetrik 48 kg >> aktual 15 kg. Tunai lunas. Catatan: fragile.', 'Cabang Bogor Kota, Jl. Juanda No. 3, Bogor', 23, '2026-04-24 02:00:00', NULL, NULL),
(151, 20, 'sorting_origin', 'Paket JTR disortir di Cabang Bogor Kota. Dimensi besar 80x60x50cm, berat volumetrik 48 kg. Penanganan khusus fragile.', 'Cabang Bogor Kota, Jl. Juanda No. 3, Bogor', 23, '2026-04-24 05:00:00', NULL, NULL),
(152, 20, 'in_transit_gateway', 'Paket trucking dikirim dari Bogor Kota ke Bogor Gateway.', 'Bogor Kota ke Bogor Gateway, Jl. Pajajaran No. 12, Bogor', 9, '2026-04-24 09:00:00', NULL, NULL),
(153, 20, 'gateway_origin', 'Paket JTR diproses di Bogor Gateway. Menunggu armada trucking ke Serang.', 'Bogor Gateway, Jl. Pajajaran No. 12, Bogor', 9, '2026-04-24 13:00:00', NULL, NULL),
(154, 20, 'on_transit', 'Armada trucking berangkat dari Bogor menuju Serang Gateway via jalur darat.', 'Bogor menuju Serang', 9, '2026-04-25 06:00:00', NULL, NULL),
(155, 21, 'created', 'Paket diterima di Cabang Bandung Utara dari Gendis Ayu. Layanan: Reguler. Tunai lunas.', 'Cabang Bandung Utara, Jl. Setiabudi No. 10, Bandung', 18, '2026-04-27 04:44:49', NULL, NULL),
(156, 21, 'sorting_origin', 'Paket disortir di Cabang Bandung Utara. Siap dikirim ke Bandung Gateway.', 'Cabang Bandung Utara, Jl. Setiabudi No. 10, Bandung', 18, '2026-04-27 04:45:00', NULL, NULL),
(157, 16, 'failed_delivery', 'Gagal antar: Penerima tidak ada di tempat. Kurir akan kembali esok hari.', 'Jl. Pemuda No. 77, Surakarta', 42, '2026-04-27 05:53:27', NULL, NULL),
(158, 16, 'out_for_delivery', 'Pengiriman dijadwalkan ulang. Kurir Agus Setiawan kembali mengantar ke Patricia Dewi.', 'Surakarta', 42, '2026-04-27 05:53:33', NULL, NULL),
(159, 22, 'created', 'Paket diterima di Cabang Bandung Utara dari Gendis Ayu. Layanan: JTR Trucking + Packing Kayu. Tunai lunas.', 'Cabang Bandung Utara, Jl. Setiabudi No. 10, Bandung', 18, '2026-04-29 04:56:16', NULL, NULL),
(160, 22, 'sorting_origin', 'Paket JTR disortir di Cabang Bandung Utara. Packing kayu dipasang. Dimensi 50x50x50cm, berat volumetrik 25 kg.', 'Cabang Bandung Utara, Jl. Setiabudi No. 10, Bandung', 18, '2026-04-29 04:56:25', NULL, NULL),
(161, 21, 'in_transit_gateway', 'Paket dikirim dari Bandung Utara ke Bandung Gateway.', 'Bandung Utara ke Bandung Gateway, Jl. Soekarno Hatta No. 89, Bandung', 18, '2026-04-29 11:07:51', NULL, NULL),
(162, 21, 'gateway_origin', 'Paket diproses di Bandung Gateway. Siap berangkat ke Cimahi.', 'Bandung Gateway, Jl. Soekarno Hatta No. 89, Bandung', 4, '2026-04-29 11:09:07', NULL, NULL),
(163, 21, 'on_transit', 'Paket berangkat dari Bandung Gateway menuju Cimahi Gateway via jalur darat.', 'Bandung menuju Cimahi', 4, '2026-04-29 11:09:16', NULL, NULL),
(164, 21, 'arrived_gateway_dest', 'Paket tiba di Cimahi Gateway. Kurir Asep Hidayat ditugaskan untuk pengantaran.', 'Cimahi Gateway, Jl. Amir Machmud No. 50, Cimahi', 4, '2026-04-29 11:09:23', NULL, NULL),
(165, 21, 'out_for_delivery', 'Kurir Asep Hidayat keluar mengantar paket ke Salsa Anjani.', 'Cimahi', 7, '2026-04-29 11:11:42', NULL, NULL),
(166, 21, 'delivered', 'Paket berhasil diterima oleh Salsa Anjani. Kondisi baik.', 'Jl. Kolonel Masturi No. 90, Cimahi', 36, '2026-04-29 12:57:33', NULL, NULL),
(167, 20, 'on_transit', '', '', 9, '2026-05-03 14:14:14', NULL, NULL),
(168, 20, 'on_transit', '', '', 9, '2026-05-03 14:14:25', NULL, NULL),
(169, 23, 'created', 'Paket diterima di cabang Cimahi. Layanan: Reguler | Packing Kayu (+ Rp5.000)', 'Cimahi', 21, '2026-05-03 20:17:46', NULL, NULL),
(170, 23, 'sorting_origin', '', '', 21, '2026-05-03 20:18:00', NULL, NULL),
(171, 23, 'in_transit_gateway', '', 'antar ke gateway Cimahi', 21, '2026-05-03 20:18:48', NULL, NULL),
(172, 23, 'in_transit_gateway', '', 'antar ke gateway Cimahi oleh wahyu', 21, '2026-05-03 20:20:45', NULL, NULL),
(173, 23, 'in_transit_gateway', 'Paket diambil driver untuk dikirim ke Gateway. Gateway Cimahi', 'Cimahi', 70, '2026-05-03 20:21:35', NULL, NULL),
(174, 23, 'gateway_origin', 'Paket tiba di Gateway Kota Asal. ', 'Cimahi', 70, '2026-05-03 20:21:54', NULL, NULL),
(175, 23, 'arrived_gateway_dest', '', '', 8, '2026-05-03 20:23:03', NULL, NULL),
(176, 23, 'out_for_delivery', '', '', 8, '2026-05-03 20:23:13', NULL, NULL),
(177, 23, 'delivered', 'Paket diterima oleh Nadine Puteri', 'Alamat Penerima', 45, '2026-05-03 20:24:57', NULL, NULL),
(178, 17, 'out_for_delivery', '', '', 12, '2026-05-03 20:30:55', NULL, NULL),
(179, 17, 'out_for_delivery', 'Diantar oleh kurir Rudi', '', 12, '2026-05-03 20:31:19', NULL, NULL),
(180, 24, 'created', 'Paket diterima di cabang Bandung. Layanan: Reguler | Packing Kayu (+ Rp5.000)', 'Bandung', 18, '2026-05-04 04:14:02', NULL, NULL),
(181, 24, 'in_transit_gateway', '', '', 18, '2026-05-04 04:14:41', NULL, NULL),
(182, 24, 'in_transit_gateway', 'Paket diambil driver untuk dikirim ke Gateway. ', 'Bandung', 70, '2026-05-04 04:15:14', NULL, NULL),
(183, 24, 'gateway_origin', 'Paket tiba di Gateway Kota Asal. ', 'Bandung', 70, '2026-05-04 04:15:20', NULL, NULL),
(184, 24, 'on_transit', '', '', 4, '2026-05-04 04:16:05', NULL, NULL),
(185, 24, 'on_transit', 'Paket diambil driver, dalam perjalanan antar kota. ', '', 70, '2026-05-04 04:16:53', NULL, NULL),
(186, 24, 'arrived_gateway_dest', 'Paket tiba di Gateway Kota Tujuan. ', 'Cimahi', 70, '2026-05-04 04:16:58', NULL, NULL),
(187, 24, 'out_for_delivery', '', '', 7, '2026-05-04 04:17:33', NULL, NULL),
(188, 24, 'delivered', 'Paket diterima oleh alya', 'Alamat Penerima', 36, '2026-05-04 04:18:13', NULL, NULL),
(189, 22, 'in_transit_gateway', '', '', 18, '2026-05-05 11:22:58', NULL, NULL),
(190, 25, 'created', 'Paket diterima di cabang Bandung. Layanan: Reguler | Packing Kayu (+ Rp5.000)', 'Bandung', 18, '2026-05-05 11:29:38', NULL, NULL),
(191, 25, 'in_transit_gateway', '', '', 18, '2026-05-05 11:29:49', NULL, NULL),
(192, 25, 'in_transit_gateway', '', '', 18, '2026-05-05 11:30:09', NULL, NULL),
(193, 22, 'in_transit_gateway', '', '', 18, '2026-05-05 11:30:09', NULL, NULL),
(194, 25, 'in_transit_gateway', '', '', 18, '2026-05-05 11:30:46', NULL, NULL),
(195, 22, 'in_transit_gateway', '', '', 18, '2026-05-05 11:30:46', NULL, NULL),
(196, 25, 'created', '[SIMULASI] Pembayaran diterima via QRIS — Rp27,000', 'Simulasi Pembayaran', NULL, '2026-05-06 08:11:11', NULL, NULL),
(197, 25, 'created', '[SIMULASI] Pembayaran diterima via DANA — Rp27,000', 'Simulasi Pembayaran', NULL, '2026-05-06 08:11:28', NULL, NULL),
(198, 25, 'created', '[SIMULASI] Pembayaran diterima via CREDIT_CARD — Rp27,000', 'Simulasi Pembayaran', NULL, '2026-05-06 08:11:58', NULL, NULL),
(199, 25, 'created', '[SIMULASI] Pembayaran diterima via QRIS — Rp27,000', 'Simulasi Pembayaran', NULL, '2026-05-06 08:28:15', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` enum('pengelola','admin_cabang','kurir','driver','pelanggan','pengirim_tamu') DEFAULT 'pelanggan',
  `no_hp` varchar(20) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `cabang_id` int(11) DEFAULT NULL,
  `status` enum('aktif','nonaktif') DEFAULT 'aktif',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `nama`, `username`, `email`, `password`, `role`, `no_hp`, `alamat`, `cabang_id`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Super Admin', 'superadmin', 'superadmin@logistik.com', 'pengelola123', 'pengelola', '081234567894', NULL, NULL, 'aktif', '2026-04-19 13:03:02', '2026-04-19 13:03:02'),
(2, 'Jakarta Pusat', 'jkt.pst', 'jkt-pst@logistik.com', 'admin123', 'admin_cabang', '021-12345678', 'Jl. Merdeka No. 1, Jakarta Pusat', 1, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(3, 'Jakarta Gateway', 'jkt.gtw', 'jkt-gtw@logistik.com', 'admin123', 'admin_cabang', '021-98765432', 'Jl. Yos Sudarso No. 5, Jakarta Utara', 2, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(4, 'Bandung Gateway', 'bdg.gtw', 'bdg-gtw@logistik.com', 'admin123', 'admin_cabang', '022-87654321', 'Jl. Soekarno Hatta No. 89, Bandung', 3, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(5, 'Surabaya Gateway', 'sby.gtw', 'sby-gtw@logistik.com', 'admin123', 'admin_cabang', '031-12345678', 'Jl. Perak Timur No. 10, Surabaya', 4, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(6, 'Yogyakarta Gateway', 'yog.gtw', 'yog-gtw@logistik.com', 'admin123', 'admin_cabang', '0274-987654', 'Jl. Magelang No. 15, Sleman', 5, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(7, 'Cimahi Gateway', 'cmh.gtw', 'cmh-gtw@logistik.com', 'admin123', 'admin_cabang', '022-66554433', 'Jl. Amir Machmud No. 50, Cimahi', 6, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(8, 'Tangerang Gateway', 'trg.gtw', 'trg-gtw@logistik.com', 'admin123', 'admin_cabang', '021-55667788', 'Jl. Daan Mogot No. 25, Tangerang', 7, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(9, 'Bogor Gateway', 'bgr.gtw', 'bgr-gtw@logistik.com', 'admin123', 'admin_cabang', '0251-778899', 'Jl. Pajajaran No. 12, Bogor', 8, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(10, 'Semarang Gateway', 'smg.gtw', 'smg-gtw@logistik.com', 'admin123', 'admin_cabang', '024-1234567', 'Jl. Ahmad Yani No. 20, Semarang', 9, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(11, 'Surakarta Gateway', 'skt.gtw', 'skt-gtw@logistik.com', 'admin123', 'admin_cabang', '0271-765432', 'Jl. Slamet Riyadi No. 100, Solo', 10, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(12, 'Malang Gateway', 'mlg.gtw', 'mlg-gtw@logistik.com', 'admin123', 'admin_cabang', '0341-112233', 'Jl. Ijen No. 45, Malang', 11, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(13, 'Serang Gateway', 'srg.gtw', 'srg-gtw@logistik.com', 'admin123', 'admin_cabang', '0254-998877', 'Jl. Veteran No. 8, Serang', 12, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(14, 'Magelang Gateway', 'mgl.gtw', 'mgl-gtw@logistik.com', 'admin123', 'admin_cabang', '0293-445566', 'Jl. Sudirman No. 30, Magelang', 13, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(15, 'Bekasi Gateway', 'bks.gtw', 'bks-gtw@logistik.com', 'admin123', 'admin_cabang', '021-88997766', 'Jl. Ahmad Yani No. 1, Bekasi', 14, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(16, 'Kediri Gateway', 'kdr.gtw', 'kdr-gtw@logistik.com', 'admin123', 'admin_cabang', '0354-223344', 'Jl. Dhoho No. 77, Kediri', 15, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(17, 'Jakarta Utara', 'jkt.001', 'jkt-001@logistik.com', 'admin123', 'admin_cabang', '021-99887766', 'Jl. Sunter Agung No. 10, Jakarta Utara', 16, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(18, 'Bandung Utara', 'bdg.001', 'bdg-001@logistik.com', 'admin123', 'admin_cabang', '022-11223344', 'Jl. Setiabudi No. 10, Bandung', 17, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(19, 'Surabaya Pusat', 'sby.001', 'sby-001@logistik.com', 'admin123', 'admin_cabang', '031-55667788', 'Jl. Basuki Rahmat No. 20, Surabaya', 18, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(20, 'Yogyakarta Kota', 'yog.001', 'yog-001@logistik.com', 'admin123', 'admin_cabang', '0274-998877', 'Jl. Malioboro No. 88, Yogyakarta', 19, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(21, 'Cimahi Tengah', 'cmh.001', 'cmh-001@logistik.com', 'admin123', 'admin_cabang', '022-33445566', 'Jl. Gandawijaya No. 5, Cimahi', 20, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(22, 'Tangerang Kota', 'trg.001', 'trg-001@logistik.com', 'admin123', 'admin_cabang', '021-22334455', 'Jl. MH Thamrin No. 12, Tangerang', 21, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(23, 'Bogor Kota', 'bgr.001', 'bgr-001@logistik.com', 'admin123', 'admin_cabang', '0251-667788', 'Jl. Juanda No. 3, Bogor', 22, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(24, 'Semarang Kota', 'smg.001', 'smg-001@logistik.com', 'admin123', 'admin_cabang', '024-334455', 'Jl. Pandanaran No. 9, Semarang', 23, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(25, 'Surakarta Kota', 'skt.001', 'skt-001@logistik.com', 'admin123', 'admin_cabang', '0271-223344', 'Jl. Urip Sumoharjo No. 11, Solo', 24, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(26, 'Malang Kota', 'mlg.001', 'mlg-001@logistik.com', 'admin123', 'admin_cabang', '0341-556677', 'Jl. Kawi No. 2, Malang', 25, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(27, 'Serang Kota', 'srg.001', 'srg-001@logistik.com', 'admin123', 'admin_cabang', '0254-112233', 'Jl. Ahmad Yani No. 7, Serang', 26, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(28, 'Magelang Kota', 'mgl.001', 'mgl-001@logistik.com', 'admin123', 'admin_cabang', '0293-778899', 'Jl. Pemuda No. 15, Magelang', 27, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(29, 'Bekasi Kota', 'bks.001', 'bks-001@logistik.com', 'admin123', 'admin_cabang', '021-44556677', 'Jl. Ir. Juanda No. 50, Bekasi', 28, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(30, 'Kediri Kota', 'kdr.001', 'kdr-001@logistik.com', 'admin123', 'admin_cabang', '0354-667788', 'Jl. Hayam Wuruk No. 22, Kediri', 29, 'aktif', '2026-04-19 13:07:30', '2026-04-19 13:07:30'),
(33, 'Rizky Maulana', 'kurir.rizky', 'kurir.rizky@logistik.com', 'kurir123', 'kurir', '08', NULL, 3, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(34, 'Eko Prasetyo', 'kurir.eko', 'kurir.eko@logistik.com', 'kurir123', 'kurir', '08', NULL, 8, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(35, 'Arif Rahman', 'kurir.arif', 'kurir.arif@logistik.com', 'kurir123', 'kurir', '08', NULL, 14, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(36, 'Asep Hidayat', 'kurir.asep', 'kurir.asep@logistik.com', 'kurir123', 'kurir', '08', NULL, 6, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(37, 'Andi Saputra', 'kurir.andi', 'kurir.andi@logistik.com', 'kurir123', 'kurir', '08', NULL, 2, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(38, 'Hendra Wijaya', 'kurir.hendra', 'kurir.hendra@logistik.com', 'kurir123', 'kurir', '08', NULL, 15, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(39, 'Bayu Kurniawan', 'kurir.bayu', 'kurir.bayu@logistik.com', 'kurir123', 'kurir', '08', NULL, 13, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(40, 'Rudi Hartono', 'kurir.rudi', 'kurir.rudi@logistik.com', 'kurir123', 'kurir', '08', NULL, 11, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(41, 'Budi Santoso', 'kurir.budi', 'kurir.budi@logistik.com', 'kurir123', 'kurir', '08', NULL, 4, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(42, 'Agus Setiawan', 'kurir.agus', 'kurir.agus@logistik.com', 'kurir123', 'kurir', '08', NULL, 10, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(43, 'Teguh Wibowo', 'kurir.teguh', 'kurir.teguh@logistik.com', 'kurir123', 'kurir', '08', NULL, 9, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(44, 'Joko Susilo', 'kurir.joko', 'kurir.joko@logistik.com', 'kurir123', 'kurir', '08', NULL, 12, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(45, 'Fajar Nugroho', 'kurir.fajar', 'kurir.fajar@logistik.com', 'kurir123', 'kurir', '08', NULL, 7, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(46, 'Dimas Pratama', 'kurir.dimas', 'kurir.dimas@logistik.com', 'kurir123', 'kurir', '08', NULL, 5, 'aktif', '2026-04-19 13:08:14', '2026-04-19 13:08:14'),
(48, 'Bagas Prasetyo', 'bagas.prasetyo', 'tamu_251001080000@tamu.local', 'nologin', 'pengirim_tamu', '081311110001', NULL, NULL, 'aktif', '2025-10-01 01:00:00', '2026-04-27 05:38:30'),
(49, 'Citra Dewi', 'citra.dewi', 'tamu_251008093000@tamu.local', 'nologin', 'pengirim_tamu', '081311110002', NULL, NULL, 'aktif', '2025-10-08 02:30:00', '2025-10-08 02:30:00'),
(50, 'Darmawan Putra', 'darmawan.putra', 'tamu_251105130000@tamu.local', 'nologin', 'pengirim_tamu', '081311110003', NULL, NULL, 'aktif', '2025-11-05 06:00:00', '2025-11-05 06:00:00'),
(51, 'Elvira Suharto', 'elvira.suharto', 'tamu_251115100000@tamu.local', 'nologin', 'pengirim_tamu', '081311110004', NULL, NULL, 'aktif', '2025-11-15 03:00:00', '2025-11-15 03:00:00'),
(52, 'Fachri Ramadan', 'fachri.ramadan', 'tamu_251120083000@tamu.local', 'nologin', 'pengirim_tamu', '081311110005', NULL, NULL, 'aktif', '2025-11-20 01:30:00', '2025-11-20 01:30:00'),
(53, 'Gilang Nugraha', 'gilang.nugraha', 'tamu_251201090000@tamu.local', 'nologin', 'pengirim_tamu', '081311110006', NULL, NULL, 'aktif', '2025-12-01 02:00:00', '2025-12-01 02:00:00'),
(54, 'Hana Permatasari', 'hana.permatasari', 'tamu_251210110000@tamu.local', 'nologin', 'pengirim_tamu', '081311110007', NULL, NULL, 'aktif', '2025-12-10 04:00:00', '2025-12-10 04:00:00'),
(55, 'Irfan Maulana', 'irfan.maulana', 'tamu_251220080000@tamu.local', 'nologin', 'pengirim_tamu', '081311110008', NULL, NULL, 'aktif', '2025-12-20 01:00:00', '2025-12-20 01:00:00'),
(56, 'Julia Rahayu', 'julia.rahayu', 'tamu_260105100000@tamu.local', 'nologin', 'pengirim_tamu', '081311110009', NULL, NULL, 'aktif', '2026-01-05 03:00:00', '2026-01-05 03:00:00'),
(57, 'Kevin Satria', 'kevin.satria', 'tamu_260115140000@tamu.local', 'nologin', 'pengirim_tamu', '081311110010', NULL, NULL, 'aktif', '2026-01-15 07:00:00', '2026-01-15 07:00:00'),
(58, 'Laras Wulandari', 'laras.wulandari', 'tamu_260201090000@tamu.local', 'nologin', 'pengirim_tamu', '081311110011', NULL, NULL, 'aktif', '2026-02-01 02:00:00', '2026-02-01 02:00:00'),
(59, 'Mahendra Kusuma', 'mahendra.kusuma', 'tamu_260214080000@tamu.local', 'nologin', 'pengirim_tamu', '081311110012', NULL, NULL, 'aktif', '2026-02-14 01:00:00', '2026-02-14 01:00:00'),
(60, 'Nadia Fitri', 'nadia.fitri', 'tamu_260301110000@tamu.local', 'nologin', 'pengirim_tamu', '081311110013', NULL, NULL, 'aktif', '2026-03-01 04:00:00', '2026-03-01 04:00:00'),
(61, 'Oscar Hidayat', 'oscar.hidayat', 'tamu_260310080000@tamu.local', 'nologin', 'pengirim_tamu', '081311110014', NULL, NULL, 'aktif', '2026-03-10 01:00:00', '2026-03-10 01:00:00'),
(62, 'Prita Anggraeni', 'prita.anggraeni', 'tamu_260320093000@tamu.local', 'nologin', 'pengirim_tamu', '081311110015', NULL, NULL, 'aktif', '2026-03-20 02:30:00', '2026-03-20 02:30:00'),
(63, 'Rizal Firmansyah', 'rizal.firmansyah', 'tamu_260410100000@tamu.local', 'nologin', 'pengirim_tamu', '081311110016', NULL, NULL, 'aktif', '2026-04-10 03:00:00', '2026-04-10 03:00:00'),
(64, 'Salma Khoiriyah', 'salma.khoiriyah', 'tamu_260412083000@tamu.local', 'nologin', 'pengirim_tamu', '081311110017', NULL, NULL, 'aktif', '2026-04-12 01:30:00', '2026-04-12 01:30:00'),
(65, 'Taufiq Hidayat', 'taufiq.hidayat', 'tamu_260415070000@tamu.local', 'nologin', 'pengirim_tamu', '081311110018', NULL, NULL, 'aktif', '2026-04-15 00:00:00', '2026-04-15 00:00:00'),
(66, 'Ulfa Mardhiyah', 'ulfa.mardhiyah', 'tamu_260420110000@tamu.local', 'nologin', 'pengirim_tamu', '081311110019', NULL, NULL, 'aktif', '2026-04-20 04:00:00', '2026-04-20 04:00:00'),
(67, 'Vandra Setiawan', 'vandra.setiawan', 'tamu_260424090000@tamu.local', 'nologin', 'pengirim_tamu', '081311110020', NULL, NULL, 'aktif', '2026-04-24 02:00:00', '2026-04-24 02:00:00'),
(68, 'Gendis Ayu', NULL, 'tamu_260427114449@tamu.local', 'nologin', 'pengirim_tamu', '08973612830', NULL, NULL, 'aktif', '2026-04-27 04:44:49', '2026-04-27 04:44:49'),
(69, 'Gendis Ayu', NULL, 'tamu_260429115616@tamu.local', 'nologin', 'pengirim_tamu', '0987654324678', NULL, NULL, 'aktif', '2026-04-29 04:56:16', '2026-04-29 04:56:16'),
(70, 'Wahyu Nugroho', 'driver.wahyu', 'driver.wahyu@logistik.com', 'driver123', 'driver', '08111000001', NULL, 2, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(71, 'Slamet Riyadi', 'driver.slamet', 'driver.slamet@logistik.com', 'driver123', 'driver', '08111000002', NULL, 3, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(72, 'Hendro Susanto', 'driver.hendro', 'driver.hendro@logistik.com', 'driver123', 'driver', '08111000003', NULL, 4, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(73, 'Yusuf Prasetyo', 'driver.yusuf', 'driver.yusuf@logistik.com', 'driver123', 'driver', '08111000004', NULL, 5, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(74, 'Iman Setiawan', 'driver.iman', 'driver.iman@logistik.com', 'driver123', 'driver', '08111000005', NULL, 6, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(75, 'Dodi Firmansyah', 'driver.dodi', 'driver.dodi@logistik.com', 'driver123', 'driver', '08111000006', NULL, 7, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(76, 'Tono Wibowo', 'driver.tono', 'driver.tono@logistik.com', 'driver123', 'driver', '08111000007', NULL, 8, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(77, 'Hadi Santoso', 'driver.hadi', 'driver.hadi@logistik.com', 'driver123', 'driver', '08111000008', NULL, 9, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(78, 'Bambang Kurniawan', 'driver.bambang', 'driver.bambang@logistik.com', 'driver123', 'driver', '08111000009', NULL, 10, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(79, 'Supri Hartono', 'driver.supri', 'driver.supri@logistik.com', 'driver123', 'driver', '08111000010', NULL, 11, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(80, 'Gatot Nugroho', 'driver.gatot', 'driver.gatot@logistik.com', 'driver123', 'driver', '08111000011', NULL, 12, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(81, 'Purnomo Adi', 'driver.purnomo', 'driver.purnomo@logistik.com', 'driver123', 'driver', '08111000012', NULL, 13, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(82, 'Sugeng Raharjo', 'driver.sugeng', 'driver.sugeng@logistik.com', 'driver123', 'driver', '08111000013', NULL, 14, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(83, 'Mulyono Basuki', 'driver.mulyono', 'driver.mulyono@logistik.com', 'driver123', 'driver', '08111000014', NULL, 15, 'aktif', '2026-04-19 13:09:00', '2026-04-19 13:09:00'),
(84, 'Kirana dewi', NULL, 'tamu_260504031746@tamu.local', 'nologin', 'pengirim_tamu', '08973612830', NULL, NULL, 'aktif', '2026-05-03 20:17:46', '2026-05-03 20:17:46'),
(85, 'Salsa', NULL, 'tamu_260504111402@tamu.local', 'nologin', 'pengirim_tamu', '08973612830', NULL, NULL, 'aktif', '2026-05-04 04:14:02', '2026-05-04 04:14:02'),
(86, 'Budi', NULL, 'tamu_260505182938@tamu.local', 'nologin', 'pengirim_tamu', '0898765432467', NULL, NULL, 'aktif', '2026-05-05 11:29:38', '2026-05-05 11:29:38');

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
-- Indexes for table `paket`
--
ALTER TABLE `paket`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `no_resi` (`no_resi`),
  ADD KEY `pengirim_id` (`pengirim_id`),
  ADD KEY `layanan_id` (`layanan_id`),
  ADD KEY `cabang_asal_id` (`cabang_asal_id`),
  ADD KEY `gateway_id` (`gateway_id`),
  ADD KEY `gateway_tujuan_id` (`gateway_tujuan_id`),
  ADD KEY `kurir_id` (`kurir_id`);

--
-- Indexes for table `pembayaran`
--
ALTER TABLE `pembayaran`
  ADD PRIMARY KEY (`id`),
  ADD KEY `paket_id` (`paket_id`),
  ADD KEY `dicatat_oleh` (`dicatat_oleh`),
  ADD KEY `idx_xendit_invoice_id` (`xendit_invoice_id`),
  ADD KEY `idx_xendit_external_id` (`xendit_external_id`);

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
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `cabang_id` (`cabang_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cabang`
--
ALTER TABLE `cabang`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `layanan`
--
ALTER TABLE `layanan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `paket`
--
ALTER TABLE `paket`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `pembayaran`
--
ALTER TABLE `pembayaran`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `riwayat_status`
--
ALTER TABLE `riwayat_status`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=200;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=87;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `paket`
--
ALTER TABLE `paket`
  ADD CONSTRAINT `paket_ibfk_1` FOREIGN KEY (`pengirim_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `paket_ibfk_2` FOREIGN KEY (`layanan_id`) REFERENCES `layanan` (`id`),
  ADD CONSTRAINT `paket_ibfk_3` FOREIGN KEY (`cabang_asal_id`) REFERENCES `cabang` (`id`),
  ADD CONSTRAINT `paket_ibfk_4` FOREIGN KEY (`gateway_id`) REFERENCES `cabang` (`id`),
  ADD CONSTRAINT `paket_ibfk_5` FOREIGN KEY (`gateway_tujuan_id`) REFERENCES `cabang` (`id`),
  ADD CONSTRAINT `paket_ibfk_6` FOREIGN KEY (`kurir_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `pembayaran`
--
ALTER TABLE `pembayaran`
  ADD CONSTRAINT `pembayaran_ibfk_1` FOREIGN KEY (`paket_id`) REFERENCES `paket` (`id`),
  ADD CONSTRAINT `pembayaran_ibfk_2` FOREIGN KEY (`dicatat_oleh`) REFERENCES `users` (`id`);

--
-- Constraints for table `riwayat_status`
--
ALTER TABLE `riwayat_status`
  ADD CONSTRAINT `riwayat_status_ibfk_1` FOREIGN KEY (`paket_id`) REFERENCES `paket` (`id`),
  ADD CONSTRAINT `riwayat_status_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`cabang_id`) REFERENCES `cabang` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
