# SearxNG + Nginx (API-key protected)

Mục tiêu: chạy SearxNG bằng Docker Compose và expose qua Nginx reverse-proxy; tất cả truy cập đều phải kèm header X-API-Key hợp lệ.

Yêu cầu
- Docker & Docker Compose (v2)
- Một API key (không commit vào repo)

File chính
- docker-compose-secured.yml — compose file để khởi động searxng + nginx + valkey
- nginx.conf — reverse-proxy, kiểm tra X-API-Key, healthcheck public
- config/settings.yml — cấu hình SearxNG
- .env.searxng.example — mẫu biến môi trường (không chứa secrets)
- test_searxng_api.sh — script test nhanh

Quick start
1. Tạo API key an toàn:
   openssl rand -hex 32

2. Tạo file secrets cục bộ (KHÔNG commit):
   cp .env.searxng.example .env.searxng
   # chỉnh .env.searxng: đặt SEARXNG_API_KEY và SEARXNG_SECRET_KEY

3. Khởi động:
   docker compose -f docker-compose-secured.yml up -d

4. Test:
   curl -H "X-API-Key: <YOUR_KEY>" "http://localhost:8088/search?q=hello&format=json"
   curl "http://localhost:8088/healthz"    # public health check

Bảo mật
- Không commit .env.searxng chứa key/secret.
- Thay API key khi nghi ngờ lộ.
- Trong production: front Nginx phải có TLS (HTTPS); luồng API key có thể validate bằng header map hoặc external auth service.
