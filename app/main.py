import fastapi

from fastapi import FastAPI, Response


app = FastAPI()


@app.get("/")
async def root(response: Response):
    response.headers["X-Content-Type-Options"] = "nosniff"
    return {"message": "Hello World"}
