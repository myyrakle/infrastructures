from fastapi import FastAPI, HTTPException, Depends

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Boom!!!"}
