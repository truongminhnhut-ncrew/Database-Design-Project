# FamilyConnect — Thiết kế Cơ sở Dữ liệu

**Nền tảng Cộng đồng Gia đình số tích hợp Trí tuệ Nhân tạo**

Đồ án học phần **Thiết kế Cơ sở Dữ liệu** tại Trường Đại học Giao thông Vận tải TP. Hồ Chí Minh (UTH), năm 2026. Đề tài xây dựng nền tảng dữ liệu phục vụ quản lý gia phả, kết nối thành viên và bảo tồn di sản gia đình.

## Mục tiêu

- Số hóa thông tin dòng họ, chi tộc và hồ sơ thành viên.
- Biểu diễn quan hệ cha–mẹ–con, hôn nhân và các thế hệ trong gia phả.
- Hỗ trợ chia sẻ bài viết, bình luận, tương tác và tổ chức sự kiện gia đình.
- Lưu trữ di sản lịch sử, tư liệu và thông tin nhân vật tiêu biểu.
- Thiết kế dữ liệu nhất quán, có phân quyền và khả năng mở rộng.

## Nội dung đồ án

| Giai đoạn | Nội dung chính |
| --- | --- |
| **Thiết kế quan niệm** | Xác định thực thể, thuộc tính, mối quan hệ, bản số và 10 quy tắc nghiệp vụ RB01–RB10. |
| **Thiết kế logic** | Chuyển mô hình ER/EER sang lược đồ quan hệ gồm 22 bảng; xác định PK/FK; phân tích phụ thuộc hàm và chuẩn hóa 1NF, 2NF, 3NF, BCNF. |
| **Thiết kế vật lý** | Xây dựng từ điển dữ liệu và DDL trên PostgreSQL; thiết kế ràng buộc, chỉ mục, phân quyền, sao lưu và kiểm thử. |

## Các phân hệ dữ liệu

| Phân hệ | Bảng chính |
| --- | --- |
| **Người dùng & bảo mật** | `NGUOI_DUNG`, `VAI_TRO`, `QUYEN`, `NGUOI_DUNG_VAI_TRO`, `VAI_TRO_QUYEN`, `NHAT_KY_HE_THONG` |
| **Gia tộc & gia phả** | `DONG_HO`, `CHI_TOC`, `THANH_VIEN`, `HO_SO_NGHE_NGHIEP`, `QUAN_HE_HON_NHAN`, `THANH_VIEN_NOI_TOC`, `THANH_VIEN_DAU_RE` |
| **Tương tác, sự kiện & truyền thông** | `BAI_VIET`, `BINH_LUAN`, `TUONG_TAC`, `ALBUM_ANH`, `SU_KIEN`, `DANG_KY_SU_KIEN`, `THONG_BAO` |
| **Di sản số** | `DI_SAN_LICH_SU`, `NHAN_VAT_TIEU_BIEU` |

Quan hệ cha–mẹ–con được biểu diễn bằng khóa ngoại tự tham chiếu `MaCha`, `MaMe` trong bảng `THANH_VIEN`. Các bảng liên kết hỗ trợ phân quyền theo vai trò (RBAC) và đăng ký tham gia sự kiện.

## Công nghệ và kỹ thuật

- **PostgreSQL:** hệ quản trị cơ sở dữ liệu quan hệ; sử dụng UUID, dữ liệu thời gian và JSONB.
- **SQL / PL/pgSQL:** tạo lược đồ, truy vấn và kiểm thử ràng buộc.
- **ER/EER & dbdiagram.io:** mô hình hóa và trực quan hóa cấu trúc dữ liệu.
- **LaTeX:** trình bày báo cáo học thuật.
- **Thiết kế tối ưu và vận hành:** B-Tree, Partial Index, GIN; sao lưu bằng `pg_dump` và định hướng phục hồi WAL/PITR.

## Kiểm thử

Báo cáo trình bày kịch bản gồm **58 trường hợp kiểm thử**, bao gồm:

- Kiểm tra cấu trúc bảng, khóa chính, khóa ngoại và chỉ mục.
- Kiểm tra tài khoản, vai trò và quyền hạn.
- Kiểm tra dữ liệu dòng họ, chi tộc, hôn nhân và quan hệ cha–mẹ–con.
- Kiểm tra bài viết, bình luận, tương tác, sự kiện, thông báo và di sản.
- Kiểm tra vi phạm ràng buộc `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `NOT NULL`.
- Kiểm tra truy vấn thống kê, báo cáo và thao tác xóa dữ liệu.

**Kết quả được ghi nhận trong báo cáo: 58/58 trường hợp đạt.** Đây là kết quả trên dữ liệu mẫu; chưa có đánh giá tải lớn hoặc truy cập đồng thời.

## Phạm vi và hướng phát triển

Đồ án tập trung vào **phân tích và thiết kế cơ sở dữ liệu**. Giao diện Web/Mobile, Backend API và pipeline AI chưa được xây dựng hoàn chỉnh.

Các hướng phát triển tiếp theo:

- Xây dựng API và ứng dụng cho người dùng.
- Tích hợp `pgvector` và RAG để tìm kiếm, hỏi đáp về tư liệu gia đình.
- Kết hợp cơ sở dữ liệu đồ thị để xử lý quan hệ họ hàng phức tạp.
- Bổ sung bảo mật cấp hàng (RLS), mã hóa dữ liệu nhạy cảm và kiểm thử hiệu năng.

## Nhóm thực hiện

**Giảng viên hướng dẫn:** ThS. Nguyễn Văn Chiến

1. Trương Minh Nhựt
2. Nguyễn Hoàng Minh Trí
3. Nguyễn Ngọc Anh Thư
4. Nguyễn Hoàng Phi
5. Nguyễn Hưng

---

*Đồ án học thuật — UTH, 2026.*
