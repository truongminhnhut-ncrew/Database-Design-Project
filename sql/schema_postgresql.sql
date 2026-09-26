-- ==============================================================================
-- HỆ CƠ SỞ DỮ LIỆU NỀN TẢNG QUẢN LÝ GIA PHẢ & DÒNG HỌ SỐ FAMILYCONNECT
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- KỊCH BẢN DDL TẠO 22 BẢNG QUAN HỆ & RÀNG BUỘC KHÓA NGOẠI (FOREIGN KEYS)
-- ==============================================================================

-- 1. Kích hoạt tiện ích mở rộng pgcrypto
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ==============================================================================
-- 2. TẠO CÁC BẢNG DỮ LIỆU (22 TABLES)
-- ==============================================================================

-- 2.1. Phân hệ 1: Người dùng & Bảo mật (User & Security)
CREATE TABLE "NGUOI_DUNG" (
  "MaNguoiDung" uuid PRIMARY KEY,
  "Email" varchar UNIQUE NOT NULL,
  "SoDienThoai" varchar NOT NULL,
  "MatKhauHash" varchar NOT NULL,
  "TrangThai" varchar NOT NULL,
  "LanDangNhapCuoi" timestamp,
  "NgayTao" timestamp NOT NULL
);

CREATE TABLE "VAI_TRO" (
  "MaVaiTro" uuid PRIMARY KEY,
  "TenVaiTro" varchar NOT NULL,
  "MoTa" varchar
);

CREATE TABLE "QUYEN" (
  "MaQuyen" uuid PRIMARY KEY,
  "TenQuyen" varchar NOT NULL,
  "NhomChucNang" varchar NOT NULL
);

CREATE TABLE "NGUOI_DUNG_VAI_TRO" (
  "MaNguoiDung" uuid,
  "MaVaiTro" uuid,
  "NgayCap" timestamp,
  PRIMARY KEY ("MaNguoiDung", "MaVaiTro")
);

CREATE TABLE "VAI_TRO_QUYEN" (
  "MaVaiTro" uuid,
  "MaQuyen" uuid,
  PRIMARY KEY ("MaVaiTro", "MaQuyen")
);

CREATE TABLE "NHAT_KY_HE_THONG" (
  "MaNhatKy" uuid PRIMARY KEY,
  "MaNguoiDung" uuid NOT NULL,
  "ThoiDiem" timestamp NOT NULL,
  "HanhDong" varchar NOT NULL,
  "DoiTuongTacDong" varchar NOT NULL,
  "DuLieuCu" text,
  "DuLieuMoi" text,
  "DiaChiIP" varchar
);

-- 2.2. Phân hệ 2: Phả hệ & Gia tộc (Family & Genealogy)
CREATE TABLE "DONG_HO" (
  "MaDongHo" uuid PRIMARY KEY,
  "TenDongHo" varchar NOT NULL,
  "ThuyTo" varchar,
  "QueQuan" varchar NOT NULL,
  "NhaThoTo" varchar,
  "NgayGioTo" varchar,
  "LichSuHinhThanh" text
);

CREATE TABLE "CHI_TOC" (
  "MaChiToc" uuid PRIMARY KEY,
  "MaDongHo" uuid NOT NULL,
  "TenChiToc" varchar NOT NULL,
  "DoiThu" int NOT NULL,
  "DiaBanChinh" varchar,
  "GhiChu" varchar
);

CREATE TABLE "THANH_VIEN" (
  "MaThanhVien" uuid PRIMARY KEY,
  "MaChiToc" uuid NOT NULL,
  "MaNguoiDung" uuid UNIQUE,
  "MaCha" uuid,
  "MaMe" uuid,
  "HoVaTen" varchar NOT NULL,
  "TenThuongGoi" varchar,
  "GioiTinh" varchar NOT NULL,
  "NgaySinhDuongLich" date,
  "NgaySinhAmLich" varchar,
  "TheHe" int NOT NULL,
  "ConThu" int,
  "TinhTrang" varchar NOT NULL,
  "NgayMat" date,
  "NoiAnTang" varchar,
  "DiaChiHienTai" varchar,
  "AnhDaiDien" varchar
);

CREATE TABLE "HO_SO_NGHE_NGHIEP" (
  "MaHoSo" uuid PRIMARY KEY,
  "MaThanhVien" uuid UNIQUE NOT NULL,
  "TrinhDoHocVan" varchar,
  "ChuyenNganh" varchar,
  "NgheNghiep" varchar,
  "CoQuanCongTac" varchar,
  "LinhVucKinhDoanh" varchar,
  "KhaNangHoTro" varchar
);

CREATE TABLE "QUAN_HE_HON_NHAN" (
  "MaHonNhan" uuid PRIMARY KEY,
  "MaNguoi1" uuid NOT NULL,
  "MaNguoi2" uuid NOT NULL,
  "NgayKetHon" date,
  "TrangThai" varchar NOT NULL
);

CREATE TABLE "THANH_VIEN_NOI_TOC" (
  "MaThanhVien" uuid PRIMARY KEY,
  "DoiThu" int,
  "ThuocChi" varchar
);

CREATE TABLE "THANH_VIEN_DAU_RE" (
  "MaThanhVien" uuid PRIMARY KEY,
  "GiaTocGoc" varchar,
  "NgayVeLamDauRe" date
);

-- 2.3. Phân hệ 3: Mạng xã hội, Sự kiện & Truyền thông (Community & Events)
CREATE TABLE "BAI_VIET" (
  "MaBaiViet" uuid PRIMARY KEY,
  "MaNguoiTao" uuid NOT NULL,
  "TieuDe" varchar NOT NULL,
  "NoiDung" text NOT NULL,
  "PhamViChiaSe" varchar NOT NULL,
  "LoaiBaiViet" varchar NOT NULL,
  "ThoiGianDang" timestamp NOT NULL,
  "TrangThaiDuyet" varchar NOT NULL
);

CREATE TABLE "BINH_LUAN" (
  "MaBinhLuan" uuid PRIMARY KEY,
  "MaBaiViet" uuid NOT NULL,
  "MaThanhVien" uuid,
  "NoiDung" text NOT NULL,
  "ThoiGianTao" timestamp NOT NULL,
  "TrangThai" varchar NOT NULL
);

CREATE TABLE "TUONG_TAC" (
  "MaTuongTac" uuid PRIMARY KEY,
  "MaBaiViet" uuid NOT NULL,
  "MaThanhVien" uuid NOT NULL,
  "LoaiTuongTac" varchar NOT NULL,
  "ThoiDiem" timestamp NOT NULL
);

CREATE TABLE "ALBUM_ANH" (
  "MaAlbum" uuid PRIMARY KEY,
  "MaThanhVien" uuid NOT NULL,
  "TenAlbum" varchar NOT NULL,
  "MoTa" varchar,
  "NgayTao" timestamp NOT NULL
);

CREATE TABLE "SU_KIEN" (
  "MaSuKien" uuid PRIMARY KEY,
  "MaNguoiTao" uuid NOT NULL,
  "TenSuKien" varchar NOT NULL,
  "MoTa" text,
  "ThoiGianBatDau" timestamp NOT NULL,
  "ThoiGianKetThuc" timestamp,
  "DiaDiem" varchar NOT NULL,
  "NganSachDuKien" decimal,
  "TrangThai" varchar NOT NULL
);

CREATE TABLE "DANG_KY_SU_KIEN" (
  "MaDangKy" uuid PRIMARY KEY,
  "MaThanhVien" uuid NOT NULL,
  "MaSuKien" uuid NOT NULL,
  "TrangThaiThamGia" varchar NOT NULL,
  "SoNguoiDiCung" int NOT NULL,
  "GhiChu" varchar,
  "ThoiDiemPhanHoi" timestamp NOT NULL
);

CREATE TABLE "THONG_BAO" (
  "MaThongBao" uuid PRIMARY KEY,
  "MaNguoiDung" uuid NOT NULL,
  "TieuDe" varchar NOT NULL,
  "NoiDung" text NOT NULL,
  "LoaiThongBao" varchar NOT NULL,
  "DaDoc" boolean NOT NULL,
  "ThoiDiemTao" timestamp NOT NULL,
  "LienKetDieuHuong" varchar
);

-- 2.4. Phân hệ 4: Di sản số & Danh nhân (Heritage & Notable Figures)
CREATE TABLE "DI_SAN_LICH_SU" (
  "MaDiSan" uuid PRIMARY KEY,
  "MaThanhVien" uuid NOT NULL,
  "TieuDe" varchar NOT NULL,
  "LoaiDiSan" varchar NOT NULL,
  "NienDai" varchar,
  "NoiDungDichNghia" text,
  "DuongDanTepTin" varchar NOT NULL,
  "TomTatAI" text,
  "GiaTriLichSu" text
);

CREATE TABLE "NHAN_VAT_TIEU_BIEU" (
  "MaNhanVat" uuid PRIMARY KEY,
  "MaThanhVien" uuid UNIQUE NOT NULL,
  "DanhHieu" varchar NOT NULL,
  "TieuSuChiTiet" text NOT NULL,
  "CongLaoDongHo" text,
  "CongHienXaHoi" text,
  "TaiLieuThamKhao" text
);

-- ==============================================================================
-- 3. KHAI BÁO RÀNG BUỘC KHÓA NGOẠI (FOREIGN KEY CONSTRAINTS)
-- ==============================================================================

-- Liên kết Dòng họ - Chi tộc - Thành viên
ALTER TABLE "CHI_TOC" ADD FOREIGN KEY ("MaDongHo") REFERENCES "DONG_HO" ("MaDongHo") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "THANH_VIEN" ADD FOREIGN KEY ("MaChiToc") REFERENCES "CHI_TOC" ("MaChiToc") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "THANH_VIEN" ADD FOREIGN KEY ("MaNguoiDung") REFERENCES "NGUOI_DUNG" ("MaNguoiDung") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "THANH_VIEN" ADD FOREIGN KEY ("MaCha") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "THANH_VIEN" ADD FOREIGN KEY ("MaMe") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;

-- Liên kết Hồ sơ nghề nghiệp & Kế thừa thực thể con
ALTER TABLE "HO_SO_NGHE_NGHIEP" ADD FOREIGN KEY ("MaThanhVien") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "THANH_VIEN_NOI_TOC" ADD FOREIGN KEY ("MaThanhVien") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "THANH_VIEN_DAU_RE" ADD FOREIGN KEY ("MaThanhVien") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;

-- Quan hệ hôn phối đệ quy
ALTER TABLE "QUAN_HE_HON_NHAN" ADD FOREIGN KEY ("MaNguoi1") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "QUAN_HE_HON_NHAN" ADD FOREIGN KEY ("MaNguoi2") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;

-- Phân quyền RBAC & Nhật ký
ALTER TABLE "NGUOI_DUNG_VAI_TRO" ADD FOREIGN KEY ("MaNguoiDung") REFERENCES "NGUOI_DUNG" ("MaNguoiDung") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "NGUOI_DUNG_VAI_TRO" ADD FOREIGN KEY ("MaVaiTro") REFERENCES "VAI_TRO" ("MaVaiTro") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "VAI_TRO_QUYEN" ADD FOREIGN KEY ("MaVaiTro") REFERENCES "VAI_TRO" ("MaVaiTro") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "VAI_TRO_QUYEN" ADD FOREIGN KEY ("MaQuyen") REFERENCES "QUYEN" ("MaQuyen") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "NHAT_KY_HE_THONG" ADD FOREIGN KEY ("MaNguoiDung") REFERENCES "NGUOI_DUNG" ("MaNguoiDung") DEFERRABLE INITIALLY IMMEDIATE;

-- Mạng xã hội & Tương tác
ALTER TABLE "BAI_VIET" ADD FOREIGN KEY ("MaNguoiTao") REFERENCES "NGUOI_DUNG" ("MaNguoiDung") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "BINH_LUAN" ADD FOREIGN KEY ("MaBaiViet") REFERENCES "BAI_VIET" ("MaBaiViet") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "BINH_LUAN" ADD FOREIGN KEY ("MaThanhVien") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "TUONG_TAC" ADD FOREIGN KEY ("MaBaiViet") REFERENCES "BAI_VIET" ("MaBaiViet") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "TUONG_TAC" ADD FOREIGN KEY ("MaThanhVien") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;

-- Album, Sự kiện & Thông báo
ALTER TABLE "ALBUM_ANH" ADD FOREIGN KEY ("MaThanhVien") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "SU_KIEN" ADD FOREIGN KEY ("MaNguoiTao") REFERENCES "NGUOI_DUNG" ("MaNguoiDung") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "DANG_KY_SU_KIEN" ADD FOREIGN KEY ("MaSuKien") REFERENCES "SU_KIEN" ("MaSuKien") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "DANG_KY_SU_KIEN" ADD FOREIGN KEY ("MaThanhVien") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "THONG_BAO" ADD FOREIGN KEY ("MaNguoiDung") REFERENCES "NGUOI_DUNG" ("MaNguoiDung") DEFERRABLE INITIALLY IMMEDIATE;

-- Di sản số & Danh nhân
ALTER TABLE "DI_SAN_LICH_SU" ADD FOREIGN KEY ("MaThanhVien") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE "NHAN_VAT_TIEU_BIEU" ADD FOREIGN KEY ("MaThanhVien") REFERENCES "THANH_VIEN" ("MaThanhVien") DEFERRABLE INITIALLY IMMEDIATE;
