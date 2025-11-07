# AWS Application Signals 설정 가이드

AWS Application Signals를 사용하여 Python FastAPI 애플리케이션을 모니터링하는 방법입니다.

## 사전 요구사항

### IAM 역할 설정
EC2 인스턴스에 다음 권한이 포함된 IAM 역할을 연결해야 합니다:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords"
            ],
            "Resource": "*"
        }
    ]
}
```

## 자동 설정 (권장)

### 1. Application Signals 설정 스크립트 실행

각 EC2 인스턴스에서 다음을 실행:

```bash
# 스크립트 다운로드
curl -o setup-app-signals.sh https://raw.githubusercontent.com/Leeeuijooo/cloudwatch-application-signals/main/deploy/setup-application-signals.sh
chmod +x setup-app-signals.sh

# 실행 (인터랙티브 메뉴)
./setup-app-signals.sh
```

### 2. Backend EC2에서 Application Signals 시작

```bash
# OTEL이 포함된 서비스 시작
sudo systemctl start fastapi-otel.service
sudo systemctl status fastapi-otel.service

# 로그 확인
sudo journalctl -u fastapi-otel.service -f
```

## 수동 설정

### Backend EC2 설정

1. **CloudWatch Agent 설치**
   ```bash
   cd /tmp
   wget https://amazoncloudwatch-agent.s3.amazonaws.com/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
   sudo rpm -U ./amazon-cloudwatch-agent.rpm
   ```

2. **AWS OTEL Distro 설치**
   ```bash
   cd /opt/app
   source venv/bin/activate
   pip install aws-opentelemetry-distro
   ```

3. **환경 변수 설정**
   ```bash
   # OTEL 환경 변수 로드
   source deploy/backend/otel-env.sh
   
   # 수동 시작
   opentelemetry-instrument python main.py
   ```

### Frontend/Database EC2 설정

Frontend와 Database EC2에서는 CloudWatch Agent만 설치하면 됩니다:

```bash
# CloudWatch Agent만 설치
./setup-app-signals.sh
# 옵션 4 선택
```

## 설정 확인

### 1. CloudWatch Agent 상태
```bash
sudo systemctl status amazon-cloudwatch-agent
```

### 2. Application Signals 데이터 전송 확인
```bash
# Backend에서 API 호출 테스트
curl http://localhost:8000/
curl http://localhost:8000/users
```

### 3. AWS Console에서 확인
- CloudWatch > Application Signals
- X-Ray > Traces
- CloudWatch > Metrics

## 환경 변수 커스터마이징

### Service Name 변경
`deploy/backend/otel-env.sh` 파일에서:
```bash
export SERVICE_NAME="your-service-name"
export DEPLOYMENT_ENVIRONMENT="production"  # 또는 staging, dev
export LOG_GROUP_NAME="/aws/ec2/your-service"
```

### 고급 설정
`deploy/backend/fastapi-otel.service` 파일에서 systemd 환경 변수 수정

## 트러블슈팅

### 1. OTEL 데이터가 전송되지 않는 경우
```bash
# CloudWatch Agent 로그 확인
sudo tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log

# Application 로그 확인
sudo journalctl -u fastapi-otel.service -f
```

### 2. 권한 오류
- EC2 IAM 역할에 CloudWatch/X-Ray 권한 확인
- CloudWatch Agent가 올바르게 실행되는지 확인

### 3. 포트 충돌
- 포트 2000 (X-Ray), 4315/4316 (OTLP)이 사용 가능한지 확인

## Application Signals에서 확인할 수 있는 정보

1. **서비스 맵**: 마이크로서비스 간 관계
2. **지연 시간**: API 응답 시간
3. **오류율**: HTTP 오류 응답
4. **처리량**: 초당 요청 수
5. **데이터베이스 쿼리**: SQL 쿼리 성능
6. **트레이스**: 개별 요청 추적

## 로그 상관관계 (선택사항)

로그와 트레이스를 연결하려면 애플리케이션 로깅 설정을 추가로 구성해야 합니다:

```python
# main.py에 추가
import logging
from opentelemetry.instrumentation.logging import LoggingInstrumentor

LoggingInstrumentor().instrument(set_logging_format=True)

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
```