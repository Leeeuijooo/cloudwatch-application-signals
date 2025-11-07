# EC2 MSA 배포 가이드

3대 EC2 인스턴스에 MSA 구조로 배포하는 가이드입니다.

## 사전 준비사항

### EC2 인스턴스 구성
- **Backend EC2**: AL2023, t3.medium 이상 권장
- **Frontend EC2**: AL2023, t3.small 이상 권장  
- **Database EC2**: AL2023, t3.medium 이상 권장

### 보안 그룹 설정

#### Backend EC2 보안 그룹
- 8000 포트: Frontend EC2에서 접근 허용
- 22 포트: SSH 접근

#### Frontend EC2 보안 그룹  
- 80 포트: 0.0.0.0/0 (전체 허용)
- 22 포트: SSH 접근

#### Database EC2 보안 그룹
- 3306 포트: Backend EC2에서 접근 허용
- 22 포트: SSH 접근

## 배포 순서

### 1. Database EC2 설정

```bash
# Database EC2에 SSH 접속
ssh -i your-key.pem ec2-user@DATABASE_EC2_PUBLIC_IP

# 스크립트 다운로드 및 실행
curl -o setup.sh https://raw.githubusercontent.com/Leeeuijooo/cloudwatch-application-signals/main/deploy/database/setup.sh
chmod +x setup.sh
./setup.sh

# 재로그인 (Docker 그룹 적용)
exit
ssh -i your-key.pem ec2-user@DATABASE_EC2_PUBLIC_IP

# MySQL 서비스 확인
cd /opt/database
docker-compose ps
```

### 2. Backend EC2 설정

```bash
# Backend EC2에 SSH 접속
ssh -i your-key.pem ec2-user@BACKEND_EC2_PUBLIC_IP

# 스크립트 다운로드 및 실행
curl -o setup.sh https://raw.githubusercontent.com/Leeeuijooo/cloudwatch-application-signals/main/deploy/backend/setup.sh
chmod +x setup.sh
./setup.sh

# 환경변수 설정
cd /opt/app
cp deploy/backend/.env.example .env
nano .env
# DB_HOST를 Database EC2의 Private IP로 변경

# 서비스 재시작
sudo systemctl restart fastapi-app
sudo systemctl status fastapi-app
```

### 3. Frontend EC2 설정

```bash
# Frontend EC2에 SSH 접속
ssh -i your-key.pem ec2-user@FRONTEND_EC2_PUBLIC_IP

# 스크립트 다운로드 및 실행
curl -o setup.sh https://raw.githubusercontent.com/Leeeuijooo/cloudwatch-application-signals/main/deploy/frontend/setup.sh
chmod +x setup.sh

# nginx 설정에서 Backend IP 수정
sed -i 's/BACKEND_EC2_PRIVATE_IP/YOUR_BACKEND_PRIVATE_IP/g' setup.sh
./setup.sh

# nginx 상태 확인
sudo systemctl status nginx
```

## 배포 후 확인

1. **Frontend 접속**: http://FRONTEND_EC2_PUBLIC_IP
2. **Backend API 확인**: http://BACKEND_EC2_PUBLIC_IP:8000/docs
3. **Database 연결 테스트**: Frontend에서 사용자 추가/조회 테스트

## 트러블슈팅

### Backend 서비스 로그 확인
```bash
sudo journalctl -u fastapi-app -f
```

### Frontend nginx 로그 확인
```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Database 연결 확인
```bash
cd /opt/database
docker-compose exec mysql mysql -u testuser -ptestpass testdb
```

## 업데이트 방법

### Backend 업데이트
```bash
cd /opt/app
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart fastapi-app
```

### Frontend 업데이트
```bash
cd /opt/frontend
git pull origin main
sudo systemctl reload nginx
```