# Frontend for Cloudflare Worker CRUD App
## Setup Instructions
1.
```
git clone https://github.com/Korrawit-aoongern/frontend-cw
```

2.
```
cd frontend-cw
```

3.
```
docker build --no-cache -t frontend-cw:latest .
```

4.
```
docker run --rm -p 8080:80 -e API_BASE=https://<your-cloudflare-worker-url-api>.dev frontend-cw:latest
example: docker run --rm -p 8080:80 -e API_BASE=https://backend-cw.chontipan.workers.dev frontend-cw:latest
```

5.
```
https://localhost:8080
```

