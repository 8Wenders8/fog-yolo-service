import uuid, subprocess, base64, os
import magic
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

ALLOWED_MIME_TYPES = {"image/png", "image/jpeg"}

@app.post("/api/upload")
async def upload(file: UploadFile = File(...)):
    # Load image
    in_path = f"/tmp/{uuid.uuid4().hex}_{file.filename}"
    out_path = f"/tmp/{uuid.uuid4().hex}_out_{file.filename}"
    content = await file.read()
    with open(in_path, "wb") as f:
        f.write(content)

    # Check MIME type of the file
    mime = magic.from_buffer(content, mime=True)
    if mime not in ALLOWED_MIME_TYPES:
        return JSONResponse({"error": f"Invalid file type: {mime}"}, status_code=400)

    # Run detect script
    cmd = ["./detect.sh", in_path, out_path]
    proc = subprocess.run(cmd, cwd="/opt/darknet", capture_output=True)
    if proc.returncode != 0:
        return JSONResponse({"error": proc.stderr.decode()}, status_code=500)

    # Load final image and encode it to base64
    with open(out_path, "rb") as f:
        img_data = f.read()
    data_uri = "data:image/png;base64," + base64.b64encode(img_data).decode()

    # Remove both images - clean up
    os.remove(in_path)
    os.remove(out_path)

    return {"image_data": data_uri}
