import os
import uuid

import boto3
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

TABLE_NAME = os.getenv("TODOS_TABLE", "cloudagentra-demo-todos")
AWS_REGION = os.getenv("AWS_REGION", "ap-south-1")

ddb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = ddb.Table(TABLE_NAME)


class Todo(BaseModel):
    text: str


@app.get("/health")
def health():
    return {"ok": True}


@app.get("/todos")
def list_todos():
    return table.scan().get("Items", [])


@app.post("/todos")
def create_todo(t: Todo):
    item = {"id": str(uuid.uuid4()), "text": t.text}
    table.put_item(Item=item)
    return item


@app.delete("/todos/{todo_id}")
def delete_todo(todo_id: str):
    table.delete_item(Key={"id": todo_id})
    return {"ok": True}
