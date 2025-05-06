import uuid, subprocess, base64, os
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
app.add_middleware(
  CORSMiddleware,
  allow_origins=["*"],               
  allow_methods=["POST", "GET"],
  allow_headers=["*"],
)

@app.post("/api/upload")
async def upload(file: UploadFile = File(...)):
    in_path = f"/tmp/{uuid.uuid4().hex}_{file.filename}"
    out_path = f"/tmp/{uuid.uuid4().hex}_out_{file.filename}"
    content = await file.read()
    with open(in_path, "wb") as f:
        f.write(content)

    cmd = ["./detect.sh", in_path, out_path]
    proc = subprocess.run(cmd, cwd="/opt/darknet", capture_output=True)
    if proc.returncode != 0:
        return JSONResponse({"error": proc.stderr.decode()}, status_code=500)

    with open(out_path, "rb") as f:
        img_data = f.read()
    data_uri = "data:image/png;base64," + base64.b64encode(img_data).decode()

    os.remove(in_path)
    os.remove(out_path)

    return {"image_data": data_uri}
