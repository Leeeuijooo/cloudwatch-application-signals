# CloudWatch Application Signals Test Application

Simple Application for cloudwatch-application-signals (Otel Auto instrumentation)

간단한 Python FastAPI 백엔드와 프론트엔드를 포함한 테스트 애플리케이션입니다.

## 구성 요소

- **Backend**: FastAPI (Python) - 포트 8000
- **Frontend**: 정적 HTML/JavaScript - 포트 3000  
- **Database**: MySQL Docker 컨테이너 - 포트 3306

## 설치 및 실행

### 1. 가상환경 생성 및 활성화

```bash
# 가상환경 생성
python3 -m venv venv

# 가상환경 활성화 (macOS/Linux)
source venv/bin/activate

# 가상환경 활성화 (Windows)
# venv\Scripts\activate
```

### 2. 의존성 설치

```bash
pip install -r requirements.txt
```

### 3. MySQL 데이터베이스 시작

```bash
docker-compose up -d mysql
```

### 4. 백엔드 API 서버 시작

```bash
python main.py
```

API는 http://localhost:8000 에서 실행됩니다.

### 5. 프론트엔드 서버 시작

새 터미널에서:
```bash
python frontend_server.py
```

프론트엔드는 http://localhost:3000 에서 실행됩니다.

## API 엔드포인트

- `GET /` - API 상태 확인
- `GET /health` - 헬스 체크
- `POST /users` - 사용자 생성
- `GET /users` - 사용자 목록 조회
- `GET /users/{user_id}` - 특정 사용자 조회
- `DELETE /users/{user_id}` - 사용자 삭제

## 테스트

1. http://localhost:3000 에서 프론트엔드 접속
2. 사용자 추가/삭제 테스트
3. API 직접 테스트: http://localhost:8000/docs

## 데이터베이스 연결 확인

```bash
docker exec -it app_signals_mysql mysql -u testuser -p testdb
# 패스워드: testpass
```
