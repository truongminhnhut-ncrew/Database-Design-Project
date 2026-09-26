# FamilyConnect Database --- Hướng dẫn chạy PostgreSQL bằng Docker

Tài liệu hướng dẫn tạo PostgreSQL bằng Docker, kết nối CSDL và import
`ERD.sql`.

## 1. Yêu cầu

-   Docker Desktop
-   File `ERD.sql` của dự án
-   Tùy chọn: pgAdmin 4

Kiểm tra Docker:

``` bash
docker --version
docker ps
```

## 2. Tạo PostgreSQL container

### Windows PowerShell

``` powershell
docker run -d --name postgres_container `
  -e POSTGRES_USER=admin `
  -e POSTGRES_PASSWORD=admin123 `
  -e POSTGRES_DB=mydatabase `
  -p 5432:5432 `
  -v pgdata:/var/lib/postgresql/data `
  postgres:latest
```

### CMD / Git Bash / Linux / macOS

``` bash
docker run -d --name postgres_container \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin123 \
  -e POSTGRES_DB=mydatabase \
  -p 5432:5432 \
  -v pgdata:/var/lib/postgresql/data \
  postgres:latest
```

Thông tin kết nối:

  Thuộc tính   Giá trị
  ------------ ----------------------
  Container    `postgres_container`
  Host         `localhost`
  Port         `5432`
  Database     `mydatabase`
  Username     `admin`
  Password     `admin123`

> Thông tin trên chỉ phù hợp môi trường local/học tập. Không dùng mật
> khẩu mẫu khi triển khai production.

## 3. Kiểm tra container

``` bash
docker ps
docker ps -a
```

Nếu container đang dừng:

``` bash
docker start postgres_container
```

Xem log:

``` bash
docker logs postgres_container
```

Theo dõi log:

``` bash
docker logs -f postgres_container
```

Kiểm tra PostgreSQL sẵn sàng:

``` bash
docker exec postgres_container pg_isready -U admin -d mydatabase
```

Kết quả mong đợi:

``` text
accepting connections
```

## 4. Vào CSDL PostgreSQL

``` bash
docker exec -it postgres_container psql -U admin -d mydatabase
```

Nếu thành công:

``` text
mydatabase=#
```

Các lệnh hữu ích:

``` sql
SELECT version();
```

``` text
\l
\dt
\d "NGUOI_DUNG"
\q
```

## 5. Import `ERD.sql`

Đứng tại thư mục chứa `ERD.sql`.

Copy vào container:

``` bash
docker cp ERD.sql postgres_container:/ERD.sql
```

Import:

``` bash
docker exec -it postgres_container psql -U admin -d mydatabase -f /ERD.sql
```

Kiểm tra:

``` bash
docker exec -it postgres_container psql -U admin -d mydatabase
```

Sau đó:

``` text
\dt
```

Hoặc:

``` sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
```

## 6. Import trực tiếp không cần `docker cp`

### PowerShell

``` powershell
Get-Content .\ERD.sql | docker exec -i postgres_container psql -U admin -d mydatabase
```

### CMD

``` cmd
type ERD.sql | docker exec -i postgres_container psql -U admin -d mydatabase
```

### Git Bash / Linux / macOS

``` bash
docker exec -i postgres_container psql -U admin -d mydatabase < ERD.sql
```

## 7. Kết nối bằng pgAdmin

Tạo server:

``` text
Name: FamilyConnect
Host: localhost
Port: 5432
Maintenance database: mydatabase
Username: admin
Password: admin123
```

Sau đó:

``` text
Servers
└── FamilyConnect
    └── Databases
        └── mydatabase
            └── Schemas
                └── public
                    └── Tables
```

## 8. Chạy bằng Docker Compose

Tạo `docker-compose.yml`:

``` yaml
services:
  postgres:
    image: postgres:latest
    container_name: postgres_container
    restart: unless-stopped
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin123
      POSTGRES_DB: mydatabase
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

Khởi động:

``` bash
docker compose up -d
```

Kiểm tra:

``` bash
docker compose ps
```

Dừng:

``` bash
docker compose stop
```

Khởi động lại:

``` bash
docker compose start
```

Xóa container/network nhưng giữ volume:

``` bash
docker compose down
```

Xóa cả volume và dữ liệu:

``` bash
docker compose down -v
```

> Cảnh báo: `docker compose down -v` xóa dữ liệu PostgreSQL trong
> volume.

## 9. Tự động import `ERD.sql`

Cấu trúc:

``` text
Database-Design-Project/
├── docker-compose.yml
├── ERD.sql
└── README.md
```

`docker-compose.yml`:

``` yaml
services:
  postgres:
    image: postgres:latest
    container_name: postgres_container
    restart: unless-stopped
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin123
      POSTGRES_DB: mydatabase
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./ERD.sql:/docker-entrypoint-initdb.d/01-erd.sql:ro

volumes:
  pgdata:
```

Chạy:

``` bash
docker compose up -d
```

`/docker-entrypoint-initdb.d/` chỉ được thực thi khi PostgreSQL khởi tạo
data directory mới.

Muốn tạo lại CSDL từ đầu:

``` bash
docker compose down -v
docker compose up -d
```

> Cảnh báo: thao tác trên xóa database hiện tại.

## 10. Lệnh Docker thường dùng

``` bash
docker ps
docker ps -a
docker logs postgres_container
docker restart postgres_container
docker stop postgres_container
docker start postgres_container
docker exec -it postgres_container bash
docker exec -it postgres_container psql -U admin -d mydatabase
docker volume ls
```

Xóa container:

``` bash
docker rm -f postgres_container
```

## 11. Lỗi thường gặp

### `empty compose file`

``` bash
docker compose config
```

Đảm bảo file tên `docker-compose.yml` hoặc `compose.yaml` và terminal
đang ở đúng thư mục.

### Port 5432 đã được sử dụng

``` bash
docker ps
```

Đổi port:

``` yaml
ports:
  - "5433:5432"
```

Sau đó kết nối pgAdmin bằng port `5433`.

### Container name đã tồn tại

``` bash
docker ps -a
docker rm -f postgres_container
```

Sau đó tạo lại.

### Docker Engine chưa chạy

Mở Docker Desktop, chờ Engine chạy rồi kiểm tra:

``` bash
docker info
```

## 12. Quy trình nhanh cho thành viên nhóm

Clone:

``` bash
git clone https://github.com/truongminhnhut-ncrew/Database-Design-Project.git
cd Database-Design-Project
```

Chạy database:

``` bash
docker compose up -d
```

Kiểm tra:

``` bash
docker compose ps
```

Vào PostgreSQL:

``` bash
docker exec -it postgres_container psql -U admin -d mydatabase
```

Kiểm tra bảng:

``` text
\dt
```

Thoát:

``` text
\q
```

Nếu `ERD.sql` đã được mount vào `/docker-entrypoint-initdb.d/`, lần chạy
đầu chỉ cần:

``` bash
docker compose up -d
```

PostgreSQL sẽ tạo database và import schema tự động.
