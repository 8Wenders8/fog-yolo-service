import uuid, subprocess, base64, os
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.staticfiles import StaticFiles

app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/", response_class=HTMLResponse)
async def index():
    with open("static/index.html", "r") as f:
        return f.read()

@app.post("/upload")
async def upload(file: UploadFile = File(...)):
    in_path = f"/tmp/{uuid.uuid4().hex}_{file.filename}"
    out_path = f"/tmp/{uuid.uuid4().hex}_out_{file.filename}"
    content = await file.read()
    with open(in_path, "wb") as f:
        f.write(content)

    cmd = ["./detect.sh", "detect", "cfg/yolov3.cfg", "yolov3.weights",
           "-ext_output", in_path, out_path]
    proc = subprocess.run(cmd, cwd="/opt/darknet", capture_output=True)
    if proc.returncode != 0:
        return JSONResponse({"error": proc.stderr.decode()}, status_code=500)

    with open(out_path, "rb") as f:
        img_data = f.read()
    data_uri = "data:image/png;base64," + base64.b64encode(img_data).decode()

    os.remove(in_path)
    os.remove(out_path)

    return {"image_data": data_uri}
