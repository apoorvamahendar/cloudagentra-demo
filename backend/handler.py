"""Cloud Agentra demo — Lambda backend for a todo app.

One Lambda, invoked via a Function URL. Routes four actions by HTTP method
and path: GET /todos, POST /todos, DELETE /todos/{id}, GET /health.
Uses DynamoDB for storage; the table name comes from the TODOS_TABLE
environment variable.
"""
import json
import os
import uuid

import boto3

TABLE_NAME = os.environ.get("TODOS_TABLE", "cloudagentra-demo-todos")
ddb = boto3.resource("dynamodb")
table = ddb.Table(TABLE_NAME)

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,POST,DELETE,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Content-Type": "application/json",
}


def _ok(body, status=200):
    return {"statusCode": status, "headers": CORS_HEADERS, "body": json.dumps(body)}


def handler(event, context):
    method = (event.get("requestContext", {}).get("http", {}).get("method") or "GET").upper()
    path = event.get("rawPath") or "/"

    if method == "OPTIONS":
        return _ok({})

    if path == "/health":
        return _ok({"ok": True})

    if path == "/todos" and method == "GET":
        items = table.scan().get("Items", [])
        return _ok(items)

    if path == "/todos" and method == "POST":
        body = json.loads(event.get("body") or "{}")
        text = (body.get("text") or "").strip()
        if not text:
            return _ok({"error": "text required"}, status=400)
        item = {"id": str(uuid.uuid4()), "text": text}
        table.put_item(Item=item)
        return _ok(item, status=201)

    if path.startswith("/todos/") and method == "DELETE":
        todo_id = path.rsplit("/", 1)[-1]
        table.delete_item(Key={"id": todo_id})
        return _ok({"ok": True})

    return _ok({"error": "not found", "path": path, "method": method}, status=404)
