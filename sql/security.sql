-- ==============================================================================
-- HỆ CƠ SỞ DỮ LIỆU NỀN TẢNG QUẢN LÝ GIA PHẢ & DÒNG HỌ SỐ FAMILYCONNECT
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- KỊCH BẢN AN TOÀN, BẢO MẬT & PHÂN QUYỀN (DATABASE SECURITY & RBAC)
-- ==============================================================================


-- ==============================================================================
-- 1. THIẾT LẬP VAI TRÒ VÀ PHÂN QUYỀN TRUY CẬP CSDL (ROLES & PRIVILEGES)
-- Nguyên tắc đặc quyền tối thiểu (Principle of Least Privilege)
-- ==============================================================================

-- 1.1. Tạo Role dành riêng cho ứng dụng Backend API kết nối qua Connection Pool
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_backend') THEN
        CREATE ROLE app_backend WITH LOGIN PASSWORD 'Secr3t_App_Pass!2026';
    END IF;
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO app_backend', current_database());
END $$;

-- Cấp quyền thao tác DML (CRUD) trên các bảng hiện tại và tương lai
GRANT USAGE ON SCHEMA public TO app_backend;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_backend;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO app_backend;

-- Mặc định cấp quyền cho các bảng mới tạo sau này
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_backend;

-- Thu hồi quyền can thiệp thay đổi cấu trúc bảng (DDL) của ứng dụng
REVOKE CREATE ON SCHEMA public FROM app_backend;


-- 1.2. Tạo Role chỉ đọc phục vụ báo cáo phân tích và trí tuệ doanh nghiệp (BI / Analytics)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'bi_readonly') THEN
        CREATE ROLE bi_readonly WITH LOGIN PASSWORD 'Report_ReadOnly_2026';
    END IF;
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO bi_readonly', current_database());
END $$;

GRANT USAGE ON SCHEMA public TO bi_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO bi_readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO bi_readonly;


-- 1.3. Tạo Role dành cho dịch vụ sao lưu tự động định kỳ (Backup Service)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'backup_service') THEN
        CREATE ROLE backup_service WITH LOGIN PASSWORD 'Backup_Passwd!2026';
    END IF;
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO backup_service', current_database());
END $$;

GRANT USAGE ON SCHEMA public TO backup_service;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO backup_service;


-- ==============================================================================
-- 2. BẢO MẬT CẤP HÀNG (ROW LEVEL SECURITY - RLS)
-- Phân lập hiển thị dữ liệu trực tiếp tại tầng nhân DBMS
-- ==============================================================================

-- 2.1. Bảo mật cấp hàng cho bảng BAI_VIET
ALTER TABLE "BAI_VIET" ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS policy_xem_bai_viet ON "BAI_VIET";

-- Chính sách: Thành viên chỉ đọc được bài viết nội bộ Dòng họ hoặc do chính mình tạo
CREATE POLICY policy_xem_bai_viet ON "BAI_VIET"
FOR SELECT
USING (
    "PhamViChiaSe" = 'DONG_HO'
    OR "MaNguoiTao" = NULLIF(CURRENT_SETTING('app.current_user_id', true), '')::uuid
);


-- 2.2. Bảo mật cấp hàng cho bảng THONG_BAO
ALTER TABLE "THONG_BAO" ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS policy_xem_thong_bao ON "THONG_BAO";

-- Chính sách: Người dùng chỉ được xem thông báo được gửi đến đích danh mình
CREATE POLICY policy_xem_thong_bao ON "THONG_BAO"
FOR SELECT
USING (
    "MaNguoiDung" = NULLIF(CURRENT_SETTING('app.current_user_id', true), '')::uuid
);


-- ==============================================================================
-- 3. CƠ CHẾ NHẬT KÝ KIỂM TOÁN TỰ ĐỘNG (AUDIT TRAIL LOGGING)
-- Tự động ghi vết mọi thao tác INSERT, UPDATE, DELETE vào NHAT_KY_HE_THONG
-- ==============================================================================

-- 3.1. Hàm kiểm toán thông tin thành viên gia phả
CREATE OR REPLACE FUNCTION fn_audit_thanh_vien()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id uuid;
BEGIN
    -- Lấy mã người dùng từ session ứng dụng, nếu không có gán UUID mặc định
    v_user_id := NULLIF(CURRENT_SETTING('app.current_user_id', true), '')::uuid;
    IF v_user_id IS NULL THEN
        v_user_id := '00000000-0000-0000-0000-000000000001'::uuid;
    END IF;

    INSERT INTO "NHAT_KY_HE_THONG" (
        "MaNhatKy",
        "MaNguoiDung",
        "ThoiDiem",
        "HanhDong",
        "DoiTuongTacDong",
        "DuLieuCu",
        "DuLieuMoi",
        "DiaChiIP"
    ) VALUES (
        gen_random_uuid(),
        v_user_id,
        CURRENT_TIMESTAMP,
        TG_OP,
        'THANH_VIEN',
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN row_to_json(OLD)::text ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW)::text ELSE NULL END,
        COALESCE(INET_CLIENT_ADDR()::varchar, '127.0.0.1')
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 3.2. Đăng ký Trigger kiểm toán trên bảng THANH_VIEN
DROP TRIGGER IF EXISTS trg_audit_thanh_vien ON "THANH_VIEN";
CREATE TRIGGER trg_audit_thanh_vien
AFTER INSERT OR UPDATE OR DELETE ON "THANH_VIEN"
FOR EACH ROW EXECUTE FUNCTION fn_audit_thanh_vien();


-- 3.3. Hàm kiểm toán phân quyền người dùng (Phòng chống gian lận leo thang đặc quyền)
CREATE OR REPLACE FUNCTION fn_audit_phan_quyen()
RETURNS TRIGGER AS $$
DECLARE
    v_user_id uuid;
BEGIN
    v_user_id := NULLIF(CURRENT_SETTING('app.current_user_id', true), '')::uuid;
    IF v_user_id IS NULL THEN
        v_user_id := '00000000-0000-0000-0000-000000000001'::uuid;
    END IF;

    INSERT INTO "NHAT_KY_HE_THONG" (
        "MaNhatKy",
        "MaNguoiDung",
        "ThoiDiem",
        "HanhDong",
        "DoiTuongTacDong",
        "DuLieuCu",
        "DuLieuMoi",
        "DiaChiIP"
    ) VALUES (
        gen_random_uuid(),
        v_user_id,
        CURRENT_TIMESTAMP,
        TG_OP,
        'NGUOI_DUNG_VAI_TRO',
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN row_to_json(OLD)::text ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW)::text ELSE NULL END,
        COALESCE(INET_CLIENT_ADDR()::varchar, '127.0.0.1')
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_phan_quyen ON "NGUOI_DUNG_VAI_TRO";
CREATE TRIGGER trg_audit_phan_quyen
AFTER INSERT OR UPDATE OR DELETE ON "NGUOI_DUNG_VAI_TRO"
FOR EACH ROW EXECUTE FUNCTION fn_audit_phan_quyen();


-- ==============================================================================
-- 4. HƯỚNG DẪN SAO LƯU VÀ PHỤC HỒI HỆ THỐNG (BACKUP & RECOVERY)
-- ==============================================================================
/*
-- 4.1. Lệnh thực hiện sao lưu Logic toàn diện bằng pg_dump (Chạy trên Terminal):
pg_dump -h localhost -p 5432 -U backup_service -d familyconnect_db -F c -b -v -f "/backup/familyconnect_$(date +%Y%m%d_%H%M%S).dump"

-- 4.2. Lệnh phục hồi dữ liệu từ bản sao lưu bằng pg_restore:
pg_restore -h localhost -p 5432 -U postgres -d familyconnect_db -v -c "/backup/familyconnect_20260926_020000.dump"
*/
