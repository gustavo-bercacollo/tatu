from fastapi import FastAPI

app = FastAPI(title="Tatu API")


@app.get("/health")
async def health():
    return {"status": "ok"}
