# Cloud Agentra Demo — Todo App

Simple full-stack todo app for demonstrating a GitHub → AWS deployment via Cloud Agentra.

## Structure
- `frontend/` — React (deploys as static files to S3 + CloudFront)
- `backend/` — FastAPI with 3 endpoints (deploys as a container to ECS Fargate)
- Uses DynamoDB for persistence

## Local run (optional)

### Backend
```
cd backend
pip install -r requirements.txt
export TODOS_TABLE=my-local-todos   # or use dynamodb-local
uvicorn main:app --reload
```

### Frontend
```
cd frontend
npm install
REACT_APP_API_URL=http://localhost:8000 npm start
```

## Deploy via Cloud Agentra

1. Connect this repo under Settings → Version control
2. Open a chat and send:

   > Deploy this todo app to AWS ap-south-1. Backend: ECS Fargate behind an ALB, container built from `/backend/Dockerfile`, pushed to ECR. Frontend: static build from `/frontend` served from S3 + CloudFront. Storage: DynamoDB table `cloudagentra-demo-todos` with partition key `id` (string). Wire the frontend's `REACT_APP_API_URL` build-arg to the ALB DNS.

3. Review plan → Approve → Watch apply
4. To demo rollback: `destroy this stack` or `remove the ECS service`
