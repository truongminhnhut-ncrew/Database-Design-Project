-- ==============================================================================
-- HỆ CƠ SỞ DỮ LIỆU NỀN TẢNG QUẢN LÝ GIA PHẢ & DÒNG HỌ SỐ FAMILYCONNECT
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- KỊCH BẢN ĐÁNH CHỈ MỤC TỐI ƯU HÓA HIỆU NĂNG (INDEXING STRATEGY)
-- ==============================================================================

-- 0. Kích hoạt tiện ích mở rộng pg_trgm phục vụ tìm kiếm mờ (Fuzzy / Trigram Search)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";


-- ==============================================================================
-- 1. CHỈ MỤC B-TREE TRÊN CÁC CỘT KHÓA NGOẠI (FOREIGN KEY INDEXES)
-- Tối ưu hóa các phép JOIN và ngăn chặn Table Scan khi kiểm tra toàn vẹn tham chiếu
-- ==============================================================================

-- 1.1. Phân hệ Phả hệ & Gia tộc
CREATE INDEX IF NOT EXISTS "idx_fk_chi_toc_dong_ho"
    ON "CHI_TOC" ("MaDongHo");

CREATE INDEX IF NOT EXISTS "idx_fk_thanh_vien_chi_toc"
    ON "THANH_VIEN" ("MaChiToc");

CREATE INDEX IF NOT EXISTS "idx_fk_thanh_vien_user"
    ON "THANH_VIEN" ("MaNguoiDung");

CREATE INDEX IF NOT EXISTS "idx_fk_thanh_vien_cha"
    ON "THANH_VIEN" ("MaCha");

CREATE INDEX IF NOT EXISTS "idx_fk_thanh_vien_me"
    ON "THANH_VIEN" ("MaMe");

CREATE INDEX IF NOT EXISTS "idx_fk_hon_nhan_nguoi1"
    ON "QUAN_HE_HON_NHAN" ("MaNguoi1");

CREATE INDEX IF NOT EXISTS "idx_fk_hon_nhan_nguoi2"
    ON "QUAN_HE_HON_NHAN" ("MaNguoi2");


-- 1.2. Phân hệ Người dùng & Phân quyền RBAC
CREATE INDEX IF NOT EXISTS "idx_fk_user_role_user"
    ON "NGUOI_DUNG_VAI_TRO" ("MaNguoiDung");

CREATE INDEX IF NOT EXISTS "idx_fk_user_role_role"
    ON "NGUOI_DUNG_VAI_TRO" ("MaVaiTro");

CREATE INDEX IF NOT EXISTS "idx_fk_role_perm_role"
    ON "VAI_TRO_QUYEN" ("MaVaiTro");

CREATE INDEX IF NOT EXISTS "idx_fk_role_perm_perm"
    ON "VAI_TRO_QUYEN" ("MaQuyen");

CREATE INDEX IF NOT EXISTS "idx_fk_nhat_ky_user"
    ON "NHAT_KY_HE_THONG" ("MaNguoiDung");


-- 1.3. Phân hệ Mạng xã hội, Sự kiện, Thông báo & Di sản
CREATE INDEX IF NOT EXISTS "idx_fk_bai_viet_user"
    ON "BAI_VIET" ("MaNguoiTao");

CREATE INDEX IF NOT EXISTS "idx_fk_binh_luan_post"
    ON "BINH_LUAN" ("MaBaiViet");

CREATE INDEX IF NOT EXISTS "idx_fk_binh_luan_member"
    ON "BINH_LUAN" ("MaThanhVien");

CREATE INDEX IF NOT EXISTS "idx_fk_tuong_tac_post"
    ON "TUONG_TAC" ("MaBaiViet");

CREATE INDEX IF NOT EXISTS "idx_fk_tuong_tac_member"
    ON "TUONG_TAC" ("MaThanhVien");

CREATE INDEX IF NOT EXISTS "idx_fk_album_member"
    ON "ALBUM_ANH" ("MaThanhVien");

CREATE INDEX IF NOT EXISTS "idx_fk_su_kien_user"
    ON "SU_KIEN" ("MaNguoiTao");

CREATE INDEX IF NOT EXISTS "idx_fk_rsvp_event"
    ON "DANG_KY_SU_KIEN" ("MaSuKien");

CREATE INDEX IF NOT EXISTS "idx_fk_rsvp_member"
    ON "DANG_KY_SU_KIEN" ("MaThanhVien");

CREATE INDEX IF NOT EXISTS "idx_fk_thong_bao_user"
    ON "THONG_BAO" ("MaNguoiDung");

CREATE INDEX IF NOT EXISTS "idx_fk_di_san_member"
    ON "DI_SAN_LICH_SU" ("MaThanhVien");


-- ==============================================================================
-- 2. CHỈ MỤC TỔ HỢP ĐA CỘT (COMPOSITE INDEXES)
-- Tối ưu hóa truy vấn có nhiều điều kiện lọc và sắp xếp đồng thời
-- ==============================================================================

-- 2.1. Tối ưu hóa duyệt và vẽ cây gia phả: Chi tộc -> Thế hệ -> Con thứ
CREATE INDEX IF NOT EXISTS "idx_thanh_vien_cay_pha_he"
    ON "THANH_VIEN" ("MaChiToc", "TheHe" ASC, "ConThu" ASC);

-- 2.2. Tối ưu hóa bảng tin dòng họ: Lọc theo phạm vi chia sẻ và sắp xếp thời gian đăng mới nhất
CREATE INDEX IF NOT EXISTS "idx_bai_viet_feed"
    ON "BAI_VIET" ("PhamViChiaSe", "ThoiGianDang" DESC);

-- 2.3. Tối ưu hóa lịch sự kiện dòng họ: Lọc theo trạng thái và thời gian bắt đầu
CREATE INDEX IF NOT EXISTS "idx_su_kien_timeline"
    ON "SU_KIEN" ("TrangThai", "ThoiGianBatDau" ASC);


-- ==============================================================================
-- 3. CHỈ MỤC GIN / TRIGRAM PHỤC VỤ TÌM KIẾM MỜ (FUZZY SEARCH)
-- Tối ưu hóa truy vấn LIKE / ILIKE '%keyword%' không bị Full Table Scan
-- ==============================================================================

-- 3.1. Tìm kiếm họ và tên thành viên theo chuỗi con (không phân biệt hoa thường)
CREATE INDEX IF NOT EXISTS "idx_gin_thanh_vien_hovaten"
    ON "THANH_VIEN" USING GIN ("HoVaTen" gin_trgm_ops);

-- 3.2. Tìm kiếm bài viết theo từ khóa trong tiêu đề
CREATE INDEX IF NOT EXISTS "idx_gin_bai_viet_tieude"
    ON "BAI_VIET" USING GIN ("TieuDe" gin_trgm_ops);


-- ==============================================================================
-- 4. CHỈ MỤC MỘT PHẦN (PARTIAL INDEXES)
-- Chỉ lập chỉ mục trên tập dữ liệu thỏa mãn điều kiện WHERE, tiết kiệm dung lượng đĩa
-- ==============================================================================

-- 4.1. Thông báo chưa đọc của người dùng (bỏ qua hàng ngàn thông báo đã đọc cũ)
CREATE INDEX IF NOT EXISTS "idx_thong_bao_chua_doc"
    ON "THONG_BAO" ("MaNguoiDung", "ThoiDiemTao" DESC)
    WHERE "DaDoc" = false;

-- 4.2. Bài viết đã được phê duyệt để xuất bản ra trang tin cộng đồng
CREATE INDEX IF NOT EXISTS "idx_bai_viet_da_duyet"
    ON "BAI_VIET" ("ThoiGianDang" DESC)
    WHERE "TrangThaiDuyet" = 'DA_DUYET';

-- 4.3. Thành viên còn sống phục vụ mừng thọ và liên lạc nội bộ chi họ
CREATE INDEX IF NOT EXISTS "idx_thanh_vien_con_song"
    ON "THANH_VIEN" ("MaChiToc", "TheHe")
    WHERE "TinhTrang" = 'Còn sống';


-- ==============================================================================
-- 5. TRUY VẤN KIỂM TRA TẤT CẢ CHỈ MỤC TRONG CSDL
-- ==============================================================================
SELECT
    tablename AS "Bang",
    indexname AS "TenChiMuc",
    indexdef  AS "DinhNghia"
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
