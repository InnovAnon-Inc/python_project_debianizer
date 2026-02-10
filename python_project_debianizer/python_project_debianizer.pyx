# python_project_debianizer
# handles -march= / -mtune= architecture-specific distribution

import os
import subprocess
from pathlib import Path
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Chimera Debianizer Service")

class DebianizeRequest(BaseModel):
    path: str  # The absolute path inside the container to debianize

def run_command(cmd, cwd=None):
    print(f"🏃 Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if result.returncode != 0:
        return False, result.stderr
    return True, result.stdout

@app.post("/debianize")
@app.post("/debianize/")
async def debianize(request: DebianizeRequest):
    target_path = Path(request.path)

    if not target_path.exists() or not target_path.is_dir():
        raise HTTPException(status_code=404, detail=f"Path {request.path} not found or is not a directory")

    project_name = target_path.name.replace("_", "-")

    # 1. Boilerplate Generation
    (target_path / "debian/source").mkdir(parents=True, exist_ok=True)

    # Rules/Changelog logic... (using the functions we already wrote)
    # Ensure they write to target_path / "debian/..."

    # 2. Execution
    # -S = Source only, -d = skip build-dep check (important for slim containers)
    success, output = run_command(["dpkg-buildpackage", "-S", "-d", "-us", "-uc"], cwd=str(target_path))

    if not success:
        raise HTTPException(status_code=500, detail=f"Debianization failed: {output}")

    return {
        "status": "success",
        "project": project_name,
        "artifacts_location": str(target_path.parent)
    }

@app.get("/health")
async def health():
    return {"status": "online", "service": "python_project_debianizer"}
