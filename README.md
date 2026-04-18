# Hướng dẫn triển khai SearxNG với API Key Authentication

## 📋 Tổng quan

Hệ thống SearxNG được bảo mật bằng:
- ✅ Nginx reverse proxy với xác thực API key
- ✅ Rate limiting để chống abuse
- ✅ Chỉ cho phép truy cập qua API key hợp lệ
- ✅ Health check endpoint công khai

## 🔑 API Key

**API Key chính:** `sk-searxng-4f0158d9fc0a9750d55e338fef1092f0`

Sử dụng API key này trong header `X-API-Key` khi gọi API.

## 🚀 Triển khai

### Bước 1: Backup cấu hình cũ (nếu có)
```bash
# Backup docker-compose cũ
cp docker-compose.yml docker-compose.yml.backup

# Stop services cũ
docker compose down
```

### Bước 2: Sử dụng cấu hình mới
```bash
# Copy file docker-compose mới
cp docker-compose-secured.yml docker-compose.yml

# Khởi động services
docker compose up -d
```

### Bước 3: Kiểm tra services
```bash
# Xem logs
docker compose logs -f

# Kiểm tra containers đang chạy
docker compose ps
```

### Bước 4: Test API
```bash
# Chạy script test
chmod +x test_searxng_api.sh
./test_searxng_api.sh
```

## 📡 Cách sử dụng API

### Với curl:
```bash
curl -H "X-API-Key: sk-searxng-4f0158d9fc0a9750d55e338fef1092f0" \
  "http://localhost:8088/search?q=orange+pi&format=json"
```

### Với Python:
```python
import requests

headers = {
    'X-API-Key': 'sk-searxng-4f0158d9fc0a9750d55e338fef1092f0'
}

response = requests.get(
    'http://localhost:8088/search',
    params={'q': 'orange pi', 'format': 'json'},
    headers=headers
)

print(response.json())
```

### Với nanobot web_search:
Cần cấu hình nanobot để thêm header X-API-Key khi gọi SearxNG.

## 🔒 Bảo mật

### Thay đổi API Key:
1. Tạo API key mới:
   ```bash
   openssl rand -hex 32
   ```

2. Cập nhật trong file `nginx.conf`:
   - Tìm dòng: `if ($http_x_api_key = "sk-searxng-...")`
   - Thay thế bằng key mới

3. Cập nhật file `.env.searxng`

4. Restart services:
   ```bash
   docker compose restart nginx
   ```

### Thêm nhiều API keys:
Trong file `nginx.conf`, thêm nhiều điều kiện:
```nginx
if ($http_x_api_key = "sk-searxng-key1") {
    set $api_key_valid 1;
}
if ($http_x_api_key = "sk-searxng-key2") {
    set $api_key_valid 1;
}
```

### Whitelist IP nội bộ:
Nếu muốn cho phép một số IP không cần API key, thêm vào `nginx.conf`:
```nginx
# Cho phép IP nội bộ
geo $internal_ip {
    default 0;
    127.0.0.1 1;
    192.168.0.0/16 1;
    10.0.0.0/8 1;
}

location / {
    set $api_key_valid $internal_ip;
    
    if ($http_x_api_key = "sk-searxng-...") {
        set $api_key_valid 1;
    }
    
    if ($api_key_valid = 0) {
        return 401;
    }
    # ... rest of config
}
```

## 📊 Monitoring

### Xem logs:
```bash
# Logs của tất cả services
docker compose logs -f

# Chỉ logs của nginx
docker compose logs -f nginx

# Chỉ logs của searxng core
docker compose logs -f core
```

### Health check:
```bash
curl http://localhost:8088/healthz
```

## 🔧 Troubleshooting

### Lỗi 401 Unauthorized:
- Kiểm tra API key có đúng không
- Kiểm tra header `X-API-Key` có được gửi không
- Xem logs nginx: `docker compose logs nginx`

### Lỗi 502 Bad Gateway:
- Kiểm tra searxng-core có chạy không: `docker compose ps`
- Xem logs: `docker compose logs core`

### Rate limit:
- Mặc định: 10 requests/second, burst 20
- Điều chỉnh trong `nginx.conf`: `limit_req_zone`

## 📝 Cấu trúc files

```
.
├── docker-compose.yml          # Docker compose với nginx proxy
├── nginx.conf                  # Nginx config với API key auth
├── .env.searxng               # API keys và secrets
├── config/
│   ├── settings.yml           # SearxNG settings
│   └── limiter.toml           # Rate limiting config
├── data/                      # SearxNG cache
├── valkey-data/              # Redis data
└── test_searxng_api.sh       # Script test API
```

## 🎯 Next Steps

1. Thay đổi API key mặc định
2. Cấu hình domain/SSL nếu expose ra internet
3. Backup file `.env.searxng` an toàn
4. Cập nhật nanobot để sử dụng API key mới