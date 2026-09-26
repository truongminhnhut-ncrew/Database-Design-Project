/* ============================================================
   FAMILYCONNECT - FULL DATABASE FUNCTION TEST
   PostgreSQL
   ============================================================ */

CREATE EXTENSION IF NOT EXISTS pgcrypto;


/* ============================================================
   TEST 0 - KIỂM TRA CÁC BẢNG
   ============================================================ */

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;


/* ============================================================
   TEST 1 - NGƯỜI DÙNG
   Chức năng: tạo tài khoản
   ============================================================ */

INSERT INTO "NGUOI_DUNG"
(
    "MaNguoiDung",
    "Email",
    "SoDienThoai",
    "MatKhauHash",
    "TrangThai",
    "LanDangNhapCuoi",
    "NgayTao"
)
VALUES
(
    '00000000-0000-0000-0000-000000000001',
    'nhut@familyconnect.vn',
    '0901000001',
    'hash_nhut',
    'ACTIVE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    '00000000-0000-0000-0000-000000000002',
    'nhanh@familyconnect.vn',
    '0901000002',
    'hash_nhanh',
    'ACTIVE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
),
(
    '00000000-0000-0000-0000-000000000003',
    'ngan@familyconnect.vn',
    '0901000003',
    'hash_ngan',
    'ACTIVE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

SELECT *
FROM "NGUOI_DUNG";


/* ============================================================
   TEST 2 - VAI TRÒ
   ============================================================ */

INSERT INTO "VAI_TRO"
("MaVaiTro", "TenVaiTro", "MoTa")
VALUES
(
    '10000000-0000-0000-0000-000000000001',
    'ADMIN',
    'Quản trị hệ thống'
),
(
    '10000000-0000-0000-0000-000000000002',
    'TRUONG_HO',
    'Quản lý dòng họ'
),
(
    '10000000-0000-0000-0000-000000000003',
    'THANH_VIEN',
    'Thành viên thông thường'
);

SELECT * FROM "VAI_TRO";


/* ============================================================
   TEST 3 - QUYỀN
   ============================================================ */

INSERT INTO "QUYEN"
("MaQuyen", "TenQuyen", "NhomChucNang")
VALUES
(
    '20000000-0000-0000-0000-000000000001',
    'genealogy.edit',
    'GENEALOGY'
),
(
    '20000000-0000-0000-0000-000000000002',
    'post.create',
    'POST'
),
(
    '20000000-0000-0000-0000-000000000003',
    'event.create',
    'EVENT'
),
(
    '20000000-0000-0000-0000-000000000004',
    'post.approve',
    'POST'
);

SELECT * FROM "QUYEN";


/* ============================================================
   TEST 4 - GÁN VAI TRÒ CHO NGƯỜI DÙNG
   Test quan hệ N:M
   ============================================================ */

INSERT INTO "NGUOI_DUNG_VAI_TRO"
("MaNguoiDung", "MaVaiTro", "NgayCap")
VALUES
(
    '00000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    CURRENT_TIMESTAMP
),
(
    '00000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000002',
    CURRENT_TIMESTAMP
),
(
    '00000000-0000-0000-0000-000000000003',
    '10000000-0000-0000-0000-000000000003',
    CURRENT_TIMESTAMP
);


/* ============================================================
   TEST 5 - GÁN QUYỀN CHO VAI TRÒ
   ============================================================ */

INSERT INTO "VAI_TRO_QUYEN"
("MaVaiTro", "MaQuyen")
VALUES
(
    '10000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000001'
),
(
    '10000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002'
),
(
    '10000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000003'
),
(
    '10000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000004'
),
(
    '10000000-0000-0000-0000-000000000002',
    '20000000-0000-0000-0000-000000000001'
);


/* ============================================================
   TEST 6 - KIỂM TRA RBAC
   ============================================================ */

SELECT
    nd."Email",
    vt."TenVaiTro",
    q."TenQuyen",
    q."NhomChucNang"
FROM "NGUOI_DUNG" nd
JOIN "NGUOI_DUNG_VAI_TRO" ndvt
    ON nd."MaNguoiDung" = ndvt."MaNguoiDung"
JOIN "VAI_TRO" vt
    ON ndvt."MaVaiTro" = vt."MaVaiTro"
LEFT JOIN "VAI_TRO_QUYEN" vtq
    ON vt."MaVaiTro" = vtq."MaVaiTro"
LEFT JOIN "QUYEN" q
    ON vtq."MaQuyen" = q."MaQuyen"
ORDER BY nd."Email", q."TenQuyen";


/* ============================================================
   TEST 7 - NHẬT KÝ HỆ THỐNG
   ============================================================ */

INSERT INTO "NHAT_KY_HE_THONG"
(
    "MaNhatKy",
    "MaNguoiDung",
    "ThoiDiem",
    "HanhDong",
    "DoiTuongTacDong",
    "DuLieuCu",
    "DuLieuMoi",
    "DiaChiIP"
)
VALUES
(
    '30000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    CURRENT_TIMESTAMP,
    'CREATE',
    'DONG_HO',
    NULL,
    '{"TenDongHo":"Dòng họ Trương"}',
    '127.0.0.1'
);

SELECT * FROM "NHAT_KY_HE_THONG";


/* ============================================================
   TEST 8 - TẠO DÒNG HỌ
   ============================================================ */

INSERT INTO "DONG_HO"
(
    "MaDongHo",
    "TenDongHo",
    "ThuyTo",
    "QueQuan",
    "NhaThoTo",
    "NgayGioTo",
    "LichSuHinhThanh"
)
VALUES
(
    '40000000-0000-0000-0000-000000000001',
    'Dòng họ Trương',
    'Trương Thủy Tổ',
    'Việt Nam',
    'Nhà thờ họ Trương',
    '15 tháng 3 âm lịch',
    'Lịch sử hình thành dòng họ Trương'
);

SELECT * FROM "DONG_HO";


/* ============================================================
   TEST 9 - TẠO CHI TỘC
   ============================================================ */

INSERT INTO "CHI_TOC"
(
    "MaChiToc",
    "MaDongHo",
    "TenChiToc",
    "DoiThu",
    "DiaBanChinh",
    "GhiChu"
)
VALUES
(
    '50000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000001',
    'Chi Trương Thanh',
    1,
    'TP. Hồ Chí Minh',
    'Chi tộc dùng để kiểm thử'
);

SELECT * FROM "CHI_TOC";


/* ============================================================
   TEST 10 - THÊM CHA: TRƯƠNG THANH NHANH
   ============================================================ */

INSERT INTO "THANH_VIEN"
(
    "MaThanhVien",
    "MaChiToc",
    "MaNguoiDung",
    "HoVaTen",
    "GioiTinh",
    "NgaySinhDuongLich",
    "TheHe",
    "ConThu",
    "TinhTrang",
    "DiaChiHienTai"
)
VALUES
(
    '60000000-0000-0000-0000-000000000001',
    '50000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002',
    'Trương Thanh Nhanh',
    'Nam',
    '1975-05-10',
    1,
    1,
    'Còn sống',
    'TP. Hồ Chí Minh'
);


/* ============================================================
   TEST 11 - THÊM MẸ: PHẠM THUÝ NGÂN
   ============================================================ */

INSERT INTO "THANH_VIEN"
(
    "MaThanhVien",
    "MaChiToc",
    "MaNguoiDung",
    "HoVaTen",
    "GioiTinh",
    "NgaySinhDuongLich",
    "TheHe",
    "TinhTrang",
    "DiaChiHienTai"
)
VALUES
(
    '60000000-0000-0000-0000-000000000002',
    '50000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000003',
    'Phạm Thuý Ngân',
    'Nữ',
    '1978-08-20',
    1,
    'Còn sống',
    'TP. Hồ Chí Minh'
);


/* ============================================================
   TEST 12 - THÊM TRƯƠNG MINH NHỰT
   + Quan hệ cha mẹ
   ============================================================ */

INSERT INTO "THANH_VIEN"
(
    "MaThanhVien",
    "MaChiToc",
    "MaNguoiDung",
    "MaCha",
    "MaMe",
    "HoVaTen",
    "TenThuongGoi",
    "GioiTinh",
    "NgaySinhDuongLich",
    "TheHe",
    "ConThu",
    "TinhTrang",
    "DiaChiHienTai"
)
VALUES
(
    '60000000-0000-0000-0000-000000000003',
    '50000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',

    '60000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000002',

    'Trương Minh Nhựt',
    'Nhựt',
    'Nam',
    '2005-01-01',
    2,
    1,
    'Còn sống',
    'TP. Hồ Chí Minh'
);


/* ============================================================
   TEST 13 - KIỂM TRA CHA MẸ CON
   ============================================================ */

SELECT
    con."HoVaTen" AS "Con",
    cha."HoVaTen" AS "Cha",
    me."HoVaTen" AS "Mẹ",
    con."TheHe" AS "Thế hệ"
FROM "THANH_VIEN" con

LEFT JOIN "THANH_VIEN" cha
    ON con."MaCha" = cha."MaThanhVien"

LEFT JOIN "THANH_VIEN" me
    ON con."MaMe" = me."MaThanhVien"

WHERE con."HoVaTen" = 'Trương Minh Nhựt';


/* ============================================================
   TEST 14 - TRA CỨU CON CỦA MỘT NGƯỜI
   ============================================================ */

SELECT
    cha."HoVaTen" AS "Cha",
    con."HoVaTen" AS "Con"
FROM "THANH_VIEN" cha
JOIN "THANH_VIEN" con
    ON con."MaCha" = cha."MaThanhVien"
WHERE cha."HoVaTen" = 'Trương Thanh Nhanh';


/* ============================================================
   TEST 15 - DÒNG HỌ → CHI TỘC → THÀNH VIÊN
   ============================================================ */

SELECT
    dh."TenDongHo",
    ct."TenChiToc",
    tv."HoVaTen",
    tv."TheHe"
FROM "DONG_HO" dh

JOIN "CHI_TOC" ct
    ON dh."MaDongHo" = ct."MaDongHo"

JOIN "THANH_VIEN" tv
    ON ct."MaChiToc" = tv."MaChiToc"

ORDER BY tv."TheHe", tv."HoVaTen";


/* ============================================================
   TEST 16 - HỒ SƠ NGHỀ NGHIỆP
   ============================================================ */

INSERT INTO "HO_SO_NGHE_NGHIEP"
(
    "MaHoSo",
    "MaThanhVien",
    "TrinhDoHocVan",
    "ChuyenNganh",
    "NgheNghiep",
    "CoQuanCongTac",
    "LinhVucKinhDoanh",
    "KhaNangHoTro"
)
VALUES
(
    '70000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000003',
    'Đại học',
    'Công nghệ thông tin',
    'Sinh viên',
    'UTH',
    'Công nghệ',
    'Hỗ trợ kỹ thuật'
);

SELECT
    tv."HoVaTen",
    hs."TrinhDoHocVan",
    hs."ChuyenNganh",
    hs."NgheNghiep"
FROM "THANH_VIEN" tv
JOIN "HO_SO_NGHE_NGHIEP" hs
    ON tv."MaThanhVien" = hs."MaThanhVien";


/* ============================================================
   TEST 17 - HÔN NHÂN CHA MẸ
   ============================================================ */

INSERT INTO "QUAN_HE_HON_NHAN"
(
    "MaHonNhan",
    "MaNguoi1",
    "MaNguoi2",
    "NgayKetHon",
    "TrangThai"
)
VALUES
(
    '80000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000002',
    '2000-01-01',
    'Đang kết hôn'
);

SELECT
    n1."HoVaTen" AS "Người 1",
    n2."HoVaTen" AS "Người 2",
    hn."NgayKetHon",
    hn."TrangThai"
FROM "QUAN_HE_HON_NHAN" hn
JOIN "THANH_VIEN" n1
    ON hn."MaNguoi1" = n1."MaThanhVien"
JOIN "THANH_VIEN" n2
    ON hn."MaNguoi2" = n2."MaThanhVien";


/* ============================================================
   TEST 18 - THÀNH VIÊN NỘI TỘC
   ============================================================ */

INSERT INTO "THANH_VIEN_NOI_TOC"
(
    "MaThanhVien",
    "DoiThu",
    "ThuocChi"
)
VALUES
(
    '60000000-0000-0000-0000-000000000003',
    2,
    'Chi Trương Thanh'
);

SELECT
    tv."HoVaTen",
    nt."DoiThu",
    nt."ThuocChi"
FROM "THANH_VIEN_NOI_TOC" nt
JOIN "THANH_VIEN" tv
    ON nt."MaThanhVien" = tv."MaThanhVien";


/* ============================================================
   TEST 19 - BÀI VIẾT
   ============================================================ */

INSERT INTO "BAI_VIET"
(
    "MaBaiViet",
    "MaNguoiTao",
    "TieuDe",
    "NoiDung",
    "PhamViChiaSe",
    "LoaiBaiViet",
    "ThoiGianDang",
    "TrangThaiDuyet"
)
VALUES
(
    '90000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'Họp mặt dòng họ năm 2026',
    'Thông báo họp mặt toàn thể thành viên dòng họ.',
    'DONG_HO',
    'THONG_BAO',
    CURRENT_TIMESTAMP,
    'DA_DUYET'
);

SELECT * FROM "BAI_VIET";


/* ============================================================
   TEST 20 - BÌNH LUẬN
   ============================================================ */

INSERT INTO "BINH_LUAN"
(
    "MaBinhLuan",
    "MaBaiViet",
    "MaThanhVien",
    "NoiDung",
    "ThoiGianTao",
    "TrangThai"
)
VALUES
(
    '91000000-0000-0000-0000-000000000001',
    '90000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000003',
    'Em sẽ tham gia buổi họp mặt.',
    CURRENT_TIMESTAMP,
    'HIEN_THI'
);


/* ============================================================
   TEST 21 - TƯƠNG TÁC
   ============================================================ */

INSERT INTO "TUONG_TAC"
(
    "MaTuongTac",
    "MaBaiViet",
    "MaThanhVien",
    "LoaiTuongTac",
    "ThoiDiem"
)
VALUES
(
    '92000000-0000-0000-0000-000000000001',
    '90000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000003',
    'LIKE',
    CURRENT_TIMESTAMP
);


/* ============================================================
   TEST 22 - XEM BÀI VIẾT + BÌNH LUẬN
   ============================================================ */

SELECT
    bv."TieuDe",
    tv."HoVaTen" AS "Người bình luận",
    bl."NoiDung",
    bl."ThoiGianTao"
FROM "BAI_VIET" bv
LEFT JOIN "BINH_LUAN" bl
    ON bv."MaBaiViet" = bl."MaBaiViet"
LEFT JOIN "THANH_VIEN" tv
    ON bl."MaThanhVien" = tv."MaThanhVien";


/* ============================================================
   TEST 23 - ĐẾM TƯƠNG TÁC BÀI VIẾT
   ============================================================ */

SELECT
    bv."TieuDe",
    COUNT(tt."MaTuongTac") AS "SoTuongTac"
FROM "BAI_VIET" bv
LEFT JOIN "TUONG_TAC" tt
    ON bv."MaBaiViet" = tt."MaBaiViet"
GROUP BY bv."MaBaiViet", bv."TieuDe";


/* ============================================================
   TEST 24 - ALBUM ẢNH
   ============================================================ */

INSERT INTO "ALBUM_ANH"
(
    "MaAlbum",
    "MaThanhVien",
    "TenAlbum",
    "MoTa",
    "NgayTao"
)
VALUES
(
    '93000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000003',
    'Ảnh gia đình 2026',
    'Album lưu ảnh gia đình',
    CURRENT_TIMESTAMP
);

SELECT
    tv."HoVaTen",
    a."TenAlbum",
    a."MoTa"
FROM "ALBUM_ANH" a
JOIN "THANH_VIEN" tv
    ON a."MaThanhVien" = tv."MaThanhVien";


/* ============================================================
   TEST 25 - SỰ KIỆN
   ============================================================ */

INSERT INTO "SU_KIEN"
(
    "MaSuKien",
    "MaNguoiTao",
    "TenSuKien",
    "MoTa",
    "ThoiGianBatDau",
    "ThoiGianKetThuc",
    "DiaDiem",
    "NganSachDuKien",
    "TrangThai"
)
VALUES
(
    '94000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'Họp mặt FamilyConnect 2026',
    'Họp mặt các thành viên dòng họ',
    '2026-12-20 08:00:00',
    '2026-12-20 17:00:00',
    'TP. Hồ Chí Minh',
    10000000,
    'SAP_DIEN_RA'
);


/* ============================================================
   TEST 26 - ĐĂNG KÝ SỰ KIỆN
   ============================================================ */

INSERT INTO "DANG_KY_SU_KIEN"
(
    "MaDangKy",
    "MaThanhVien",
    "MaSuKien",
    "TrangThaiThamGia",
    "SoNguoiDiCung",
    "GhiChu",
    "ThoiDiemPhanHoi"
)
VALUES
(
    '95000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000003',
    '94000000-0000-0000-0000-000000000001',
    'THAM_GIA',
    2,
    'Đi cùng gia đình',
    CURRENT_TIMESTAMP
);


/* ============================================================
   TEST 27 - DANH SÁCH THAM GIA SỰ KIỆN
   ============================================================ */

SELECT
    sk."TenSuKien",
    tv."HoVaTen",
    dk."TrangThaiThamGia",
    dk."SoNguoiDiCung"
FROM "DANG_KY_SU_KIEN" dk
JOIN "THANH_VIEN" tv
    ON dk."MaThanhVien" = tv."MaThanhVien"
JOIN "SU_KIEN" sk
    ON dk."MaSuKien" = sk."MaSuKien";


/* ============================================================
   TEST 28 - TỔNG SỐ NGƯỜI DỰ KIẾN THAM GIA
   Thành viên + người đi cùng
   ============================================================ */

SELECT
    sk."TenSuKien",
    COUNT(dk."MaDangKy")
        + COALESCE(SUM(dk."SoNguoiDiCung"), 0)
        AS "TongSoNguoi"
FROM "SU_KIEN" sk
LEFT JOIN "DANG_KY_SU_KIEN" dk
    ON sk."MaSuKien" = dk."MaSuKien"
GROUP BY sk."MaSuKien", sk."TenSuKien";


/* ============================================================
   TEST 29 - THÔNG BÁO
   ============================================================ */

INSERT INTO "THONG_BAO"
(
    "MaThongBao",
    "MaNguoiDung",
    "TieuDe",
    "NoiDung",
    "LoaiThongBao",
    "DaDoc",
    "ThoiDiemTao",
    "LienKetDieuHuong"
)
VALUES
(
    '96000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    'Thông báo sự kiện',
    'Bạn có lời mời tham gia họp mặt.',
    'SU_KIEN',
    FALSE,
    CURRENT_TIMESTAMP,
    '/events/2026'
);


/* ============================================================
   TEST 30 - THÔNG BÁO CHƯA ĐỌC
   ============================================================ */

SELECT
    nd."Email",
    tb."TieuDe",
    tb."NoiDung"
FROM "THONG_BAO" tb
JOIN "NGUOI_DUNG" nd
    ON tb."MaNguoiDung" = nd."MaNguoiDung"
WHERE tb."DaDoc" = FALSE;


/* ============================================================
   TEST 31 - ĐÁNH DẤU THÔNG BÁO ĐÃ ĐỌC
   UPDATE TEST
   ============================================================ */

UPDATE "THONG_BAO"
SET "DaDoc" = TRUE
WHERE "MaThongBao"
    = '96000000-0000-0000-0000-000000000001';

SELECT * FROM "THONG_BAO";


/* ============================================================
   TEST 32 - DI SẢN LỊCH SỬ
   ============================================================ */

INSERT INTO "DI_SAN_LICH_SU"
(
    "MaDiSan",
    "MaThanhVien",
    "TieuDe",
    "LoaiDiSan",
    "NienDai",
    "NoiDungDichNghia",
    "DuongDanTepTin",
    "TomTatAI",
    "GiaTriLichSu"
)
VALUES
(
    '97000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000001',
    'Gia phả dòng họ Trương',
    'GIA_PHA',
    'Thế kỷ XX',
    'Tài liệu ghi chép lịch sử dòng họ.',
    '/heritage/giapha.pdf',
    'Tóm tắt nội dung gia phả bằng AI',
    'Có giá trị lưu giữ lịch sử dòng họ'
);

SELECT
    tv."HoVaTen",
    ds."TieuDe",
    ds."LoaiDiSan",
    ds."NienDai"
FROM "DI_SAN_LICH_SU" ds
JOIN "THANH_VIEN" tv
    ON ds."MaThanhVien" = tv."MaThanhVien";


/* ============================================================
   TEST 33 - NHÂN VẬT TIÊU BIỂU
   ============================================================ */

INSERT INTO "NHAN_VAT_TIEU_BIEU"
(
    "MaNhanVat",
    "MaThanhVien",
    "DanhHieu",
    "TieuSuChiTiet",
    "CongLaoDongHo",
    "CongHienXaHoi",
    "TaiLieuThamKhao"
)
VALUES
(
    '98000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000001',
    'Nhân vật tiêu biểu',
    'Thông tin tiểu sử nhân vật.',
    'Có đóng góp cho dòng họ.',
    'Có đóng góp cho xã hội.',
    'Tài liệu FamilyConnect'
);

SELECT
    tv."HoVaTen",
    nv."DanhHieu",
    nv."CongLaoDongHo"
FROM "NHAN_VAT_TIEU_BIEU" nv
JOIN "THANH_VIEN" tv
    ON nv."MaThanhVien" = tv."MaThanhVien";


/* ============================================================
   TEST 34 - TÌM KIẾM THÀNH VIÊN
   ============================================================ */

SELECT *
FROM "THANH_VIEN"
WHERE LOWER("HoVaTen")
LIKE LOWER('%Trương%');


/* ============================================================
   TEST 35 - TÌM KIẾM THEO THẾ HỆ
   ============================================================ */

SELECT
    "HoVaTen",
    "TheHe",
    "TinhTrang"
FROM "THANH_VIEN"
WHERE "TheHe" = 2;


/* ============================================================
   TEST 36 - UPDATE THÀNH VIÊN
   ============================================================ */

UPDATE "THANH_VIEN"
SET "DiaChiHienTai" = 'Thành phố Hồ Chí Minh'
WHERE "MaThanhVien"
    = '60000000-0000-0000-0000-000000000003';

SELECT
    "HoVaTen",
    "DiaChiHienTai"
FROM "THANH_VIEN"
WHERE "MaThanhVien"
    = '60000000-0000-0000-0000-000000000003';


/* ============================================================
   TEST 37 - UNIQUE EMAIL
   KẾT QUẢ MONG ĐỢI: PASS nếu PostgreSQL CHẶN
   ============================================================ */

DO $$
BEGIN

    BEGIN

        INSERT INTO "NGUOI_DUNG"
        (
            "MaNguoiDung",
            "Email",
            "SoDienThoai",
            "MatKhauHash",
            "TrangThai",
            "NgayTao"
        )
        VALUES
        (
            gen_random_uuid(),
            'nhut@familyconnect.vn',
            '0999999999',
            'test',
            'ACTIVE',
            CURRENT_TIMESTAMP
        );

        RAISE NOTICE 'FAIL TEST 37: Email trùng vẫn được thêm';

    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'PASS TEST 37: UNIQUE Email hoạt động';
    END;

END $$;


/* ============================================================
   TEST 38 - FOREIGN KEY MaChiToc
   KẾT QUẢ MONG ĐỢI: PostgreSQL CHẶN
   ============================================================ */

DO $$
BEGIN

    BEGIN

        INSERT INTO "THANH_VIEN"
        (
            "MaThanhVien",
            "MaChiToc",
            "HoVaTen",
            "GioiTinh",
            "TheHe",
            "TinhTrang"
        )
        VALUES
        (
            gen_random_uuid(),
            'ffffffff-ffff-ffff-ffff-ffffffffffff',
            'TEST FOREIGN KEY',
            'Nam',
            99,
            'Còn sống'
        );

        RAISE NOTICE 'FAIL TEST 38: FK MaChiToc không hoạt động';

    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'PASS TEST 38: FK MaChiToc hoạt động';
    END;

END $$;


/* ============================================================
   TEST 39 - FOREIGN KEY CHA
   ============================================================ */

DO $$
BEGIN

    BEGIN

        UPDATE "THANH_VIEN"
        SET "MaCha" =
            'ffffffff-ffff-ffff-ffff-ffffffffffff'
        WHERE "MaThanhVien" =
            '60000000-0000-0000-0000-000000000003';

        RAISE NOTICE 'FAIL TEST 39: FK MaCha không hoạt động';

    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'PASS TEST 39: FK MaCha hoạt động';
    END;

END $$;


/* ============================================================
   TEST 40 - UNIQUE MaNguoiDung TRONG THANH_VIEN
   Một tài khoản chỉ liên kết tối đa một hồ sơ
   ============================================================ */

DO $$
BEGIN

    BEGIN

        INSERT INTO "THANH_VIEN"
        (
            "MaThanhVien",
            "MaChiToc",
            "MaNguoiDung",
            "HoVaTen",
            "GioiTinh",
            "TheHe",
            "TinhTrang"
        )
        VALUES
        (
            gen_random_uuid(),
            '50000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000001',
            'Hồ sơ trùng',
            'Nam',
            2,
            'Còn sống'
        );

        RAISE NOTICE 'FAIL TEST 40: 1 tài khoản có nhiều hồ sơ';

    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'PASS TEST 40: Quan hệ tài khoản-hồ sơ 1:1';
    END;

END $$;


/* ============================================================
   TEST 41 - HỒ SƠ NGHỀ NGHIỆP 1:1
   ============================================================ */

DO $$
BEGIN

    BEGIN

        INSERT INTO "HO_SO_NGHE_NGHIEP"
        (
            "MaHoSo",
            "MaThanhVien",
            "NgheNghiep"
        )
        VALUES
        (
            gen_random_uuid(),
            '60000000-0000-0000-0000-000000000003',
            'TEST DUPLICATE'
        );

        RAISE NOTICE 'FAIL TEST 41: Thành viên có >1 hồ sơ nghề nghiệp';

    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'PASS TEST 41: Quan hệ hồ sơ nghề nghiệp 1:1';
    END;

END $$;


/* ============================================================
   TEST 42 - NHÂN VẬT TIÊU BIỂU 1:1
   ============================================================ */

DO $$
BEGIN

    BEGIN

        INSERT INTO "NHAN_VAT_TIEU_BIEU"
        (
            "MaNhanVat",
            "MaThanhVien",
            "DanhHieu",
            "TieuSuChiTiet"
        )
        VALUES
        (
            gen_random_uuid(),
            '60000000-0000-0000-0000-000000000001',
            'TEST',
            'TEST'
        );

        RAISE NOTICE 'FAIL TEST 42: UNIQUE nhân vật không hoạt động';

    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'PASS TEST 42: Nhân vật tiêu biểu 1:1';
    END;

END $$;


/* ============================================================
   TEST 43 - NOT NULL
   ============================================================ */

DO $$
BEGIN

    BEGIN

        INSERT INTO "DONG_HO"
        (
            "MaDongHo",
            "TenDongHo",
            "QueQuan"
        )
        VALUES
        (
            gen_random_uuid(),
            NULL,
            'Việt Nam'
        );

        RAISE NOTICE 'FAIL TEST 43: NOT NULL không hoạt động';

    EXCEPTION
        WHEN not_null_violation THEN
            RAISE NOTICE 'PASS TEST 43: NOT NULL hoạt động';
    END;

END $$;


/* ============================================================
   TEST 44 - PRIMARY KEY
   ============================================================ */

DO $$
BEGIN

    BEGIN

        INSERT INTO "DONG_HO"
        (
            "MaDongHo",
            "TenDongHo",
            "QueQuan"
        )
        VALUES
        (
            '40000000-0000-0000-0000-000000000001',
            'TEST DUPLICATE PK',
            'Việt Nam'
        );

        RAISE NOTICE 'FAIL TEST 44: PK không hoạt động';

    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'PASS TEST 44: PRIMARY KEY hoạt động';
    END;

END $$;


/* ============================================================
   TEST 45 - THỐNG KÊ THÀNH VIÊN THEO CHI TỘC
   ============================================================ */

SELECT
    dh."TenDongHo",
    ct."TenChiToc",
    COUNT(tv."MaThanhVien") AS "SoThanhVien"
FROM "DONG_HO" dh
JOIN "CHI_TOC" ct
    ON dh."MaDongHo" = ct."MaDongHo"
LEFT JOIN "THANH_VIEN" tv
    ON ct."MaChiToc" = tv."MaChiToc"
GROUP BY
    dh."TenDongHo",
    ct."TenChiToc";


/* ============================================================
   TEST 46 - THỐNG KÊ THEO GIỚI TÍNH
   ============================================================ */

SELECT
    "GioiTinh",
    COUNT(*) AS "SoLuong"
FROM "THANH_VIEN"
GROUP BY "GioiTinh";


/* ============================================================
   TEST 47 - THỐNG KÊ THEO THẾ HỆ
   ============================================================ */

SELECT
    "TheHe",
    COUNT(*) AS "SoThanhVien"
FROM "THANH_VIEN"
GROUP BY "TheHe"
ORDER BY "TheHe";


/* ============================================================
   TEST 48 - TỔNG HỢP THÔNG TIN THÀNH VIÊN
   ============================================================ */

SELECT
    tv."HoVaTen",
    tv."GioiTinh",
    tv."NgaySinhDuongLich",
    tv."TheHe",

    cha."HoVaTen" AS "Cha",
    me."HoVaTen" AS "Mẹ",

    ct."TenChiToc",
    dh."TenDongHo",

    hs."NgheNghiep",
    hs."ChuyenNganh"

FROM "THANH_VIEN" tv

LEFT JOIN "THANH_VIEN" cha
    ON tv."MaCha" = cha."MaThanhVien"

LEFT JOIN "THANH_VIEN" me
    ON tv."MaMe" = me."MaThanhVien"

JOIN "CHI_TOC" ct
    ON tv."MaChiToc" = ct."MaChiToc"

JOIN "DONG_HO" dh
    ON ct."MaDongHo" = dh."MaDongHo"

LEFT JOIN "HO_SO_NGHE_NGHIEP" hs
    ON tv."MaThanhVien" = hs."MaThanhVien"

ORDER BY
    tv."TheHe",
    tv."HoVaTen";


/* ============================================================
   TEST 49 - ĐẾM DỮ LIỆU TẤT CẢ BẢNG CHÍNH
   ============================================================ */

SELECT 'NGUOI_DUNG' AS "Bang", COUNT(*) AS "SoDong"
FROM "NGUOI_DUNG"

UNION ALL
SELECT 'VAI_TRO', COUNT(*) FROM "VAI_TRO"

UNION ALL
SELECT 'QUYEN', COUNT(*) FROM "QUYEN"

UNION ALL
SELECT 'DONG_HO', COUNT(*) FROM "DONG_HO"

UNION ALL
SELECT 'CHI_TOC', COUNT(*) FROM "CHI_TOC"

UNION ALL
SELECT 'THANH_VIEN', COUNT(*) FROM "THANH_VIEN"

UNION ALL
SELECT 'HO_SO_NGHE_NGHIEP', COUNT(*) FROM "HO_SO_NGHE_NGHIEP"

UNION ALL
SELECT 'QUAN_HE_HON_NHAN', COUNT(*) FROM "QUAN_HE_HON_NHAN"

UNION ALL
SELECT 'BAI_VIET', COUNT(*) FROM "BAI_VIET"

UNION ALL
SELECT 'BINH_LUAN', COUNT(*) FROM "BINH_LUAN"

UNION ALL
SELECT 'TUONG_TAC', COUNT(*) FROM "TUONG_TAC"

UNION ALL
SELECT 'ALBUM_ANH', COUNT(*) FROM "ALBUM_ANH"

UNION ALL
SELECT 'SU_KIEN', COUNT(*) FROM "SU_KIEN"

UNION ALL
SELECT 'DANG_KY_SU_KIEN', COUNT(*) FROM "DANG_KY_SU_KIEN"

UNION ALL
SELECT 'THONG_BAO', COUNT(*) FROM "THONG_BAO"

UNION ALL
SELECT 'DI_SAN_LICH_SU', COUNT(*) FROM "DI_SAN_LICH_SU"

UNION ALL
SELECT 'NHAN_VAT_TIEU_BIEU', COUNT(*) FROM "NHAN_VAT_TIEU_BIEU";


/* ============================================================
   TEST 50 - KIỂM TRA FOREIGN KEY ĐANG CÓ
   ============================================================ */

SELECT
    tc.table_name AS "Bang",
    kcu.column_name AS "CotFK",
    ccu.table_name AS "BangThamChieu",
    ccu.column_name AS "CotThamChieu"

FROM information_schema.table_constraints tc

JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.constraint_schema = kcu.constraint_schema

JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.constraint_schema = tc.constraint_schema

WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'public'

ORDER BY tc.table_name;


/* ============================================================
   TEST 51 - KIỂM TRA PRIMARY KEY
   ============================================================ */

SELECT
    tc.table_name,
    kcu.column_name

FROM information_schema.table_constraints tc

JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name

WHERE tc.constraint_type = 'PRIMARY KEY'
AND tc.table_schema = 'public'

ORDER BY tc.table_name;


/* ============================================================
   TEST 52 - KIỂM TRA UNIQUE
   ============================================================ */

SELECT
    tc.table_name,
    tc.constraint_name,
    kcu.column_name

FROM information_schema.table_constraints tc

JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name

WHERE tc.constraint_type = 'UNIQUE'
AND tc.table_schema = 'public'

ORDER BY tc.table_name;


/* ============================================================
   TEST 53 - KIỂM TRA INDEX
   ============================================================ */

SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;


/* ============================================================
   TEST 54 - KIỂM TRA VIEW
   ============================================================ */

SELECT
    table_name AS "View"
FROM information_schema.views
WHERE table_schema = 'public';


/* ============================================================
   TEST 55 - KIỂM TRA TRIGGER
   ============================================================ */

SELECT
    event_object_table AS "Bang",
    trigger_name AS "Trigger",
    event_manipulation AS "SuKien"
FROM information_schema.triggers
WHERE trigger_schema = 'public';


/* ============================================================
   TEST 56 - KIỂM TRA FUNCTION
   ============================================================ */

SELECT
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_name;


/* ============================================================
   TEST 57 - KIỂM TRA TOÀN BỘ TABLE
   ============================================================ */

SELECT
    COUNT(*) AS "TongSoBang"
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE';


/* ============================================================
   TEST 58 - DELETE TEST
   Tạo dữ liệu tạm -> xóa -> kiểm tra
   ============================================================ */

INSERT INTO "QUYEN"
(
    "MaQuyen",
    "TenQuyen",
    "NhomChucNang"
)
VALUES
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'test.delete',
    'TEST'
);

DELETE FROM "QUYEN"
WHERE "MaQuyen"
    = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

SELECT *
FROM "QUYEN"
WHERE "MaQuyen"
    = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';


/* ============================================================
   HOÀN TẤT
   ============================================================ */

SELECT
    'FULL TEST FAMILYCONNECT COMPLETED'
    AS "KET_QUA";