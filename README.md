# Cloud Agentra Demo — Todo App (serverless)

A tiny full-stack todo app for demonstrating GitHub → AWS deployment via
Cloud Agentra. No Docker, no containers, no build step — everything
deploys straight from source files.

## Structure

- `backend/handler.py` — Python Lambda, invoked via a Function URL
- `frontend/index.html` — single static HTML page with inline JS
- Storage: DynamoDB table `cloudagentra-demo-todos`

## Deploy via Cloud Agentra

1. Connect this repo under **Settings → Version control**
2. Open a chat and send:

   > Deploy this todo app to AWS ap-south-1. Backend: Python Lambda from
   > `/backend/handler.py` with a Function URL (public, no auth), runtime
   > `python3.12`, env var `TODOS_TABLE=cloudagentra-demo-todos`. Storage:
   > DynamoDB table `cloudagentra-demo-todos` with partition key `id`
   > (string), grant the Lambda read/write access. Frontend: upload
   > `/frontend/index.html` to an S3 bucket configured for static website
   > hosting (public read). Before uploading, replace the string
   > `__API_URL__` in the HTML with the Lambda Function URL.

3. Review plan → **Approve** → watch apply
4. Open the S3 website URL in the browser — add/remove todos
5. Demo rollback: `destroy this stack`
