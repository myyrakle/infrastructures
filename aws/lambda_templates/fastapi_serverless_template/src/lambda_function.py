from fastapi import FastAPI
from mangum import Mangum

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/health")
async def health_check():
    return {"message": "OK"}

lambda_handler = Mangum(app, lifespan="off")
