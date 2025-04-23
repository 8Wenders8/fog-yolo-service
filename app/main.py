from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "FastAPI over QUIC is running!"}


@app.get("/ping")
async def ping():
    return JSONResponse({"pong": True})


@app.post("/detect")
async def detect(file: UploadFile = File(...)):
    contents = await file.read()
    # Here you would forward to YOLO
    return JSONResponse(content={"message": f"Received {len(contents)} bytes"})

