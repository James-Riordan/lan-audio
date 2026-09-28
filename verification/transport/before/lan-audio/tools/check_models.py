"""Run bounded TLC safety/liveness checks and falsifying mutations.

Owns temporary configurations and subprocess deadlines, never project/runtime state.
Failures are data; an absent expected counterexample is a failed qualification.
Requires Python 3.10+, explicit Java and official tla2tools.jar. No network access.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument("--java", required=True)
parser.add_argument("--jar", required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
model = root / "spec/SessionWindow.tla"
config = (root / "spec/SessionWindow.cfg").read_text(encoding="utf-8")
faults = {"none": None, "skip_auth": "AuthenticatedStreaming", "stale_epoch": "WindowBounds", "early_free": "QuiescentIdle", "replay_tick": "UniquePlayout"}
results = []
for fault, invariant in faults.items():
    with tempfile.TemporaryDirectory(prefix="lan-audio-tlc-") as scratch:
        folder = Path(scratch)
        (folder / model.name).write_bytes(model.read_bytes())
        (folder / "SessionWindow.cfg").write_text(config.replace('Fault = "none"', f'Fault = "{fault}"'), encoding="utf-8")
        command = [args.java, "-Xmx512m", "-cp", str(args.jar.resolve()), "tlc2.TLC", "-workers", "1", "-seed", "1", "-config", "SessionWindow.cfg", "SessionWindow.tla"]
        run = subprocess.run(command, cwd=folder, capture_output=True, text=True, timeout=120)
        output = run.stdout + run.stderr
        passed = (run.returncode == 0 and "Model checking completed. No error has been found." in output) if invariant is None else (run.returncode != 0 and f"Invariant {invariant} is violated" in output)
        counts = re.findall(r"([\d,]+) states generated, ([\d,]+) distinct states found", output)
        results.append({"fault": fault, "passed": passed, "returncode": run.returncode, "expected_violation": invariant, "states": counts[-1] if counts else None, "output": output})
report = {"model_sha256": hashlib.sha256(model.read_bytes()).hexdigest(), "jar_sha256": hashlib.sha256(args.jar.read_bytes()).hexdigest(), "bounds": {"capacity": 2, "positions": 3, "epochs": 2}, "results": results}
print(json.dumps(report, indent=2))
raise SystemExit(0 if all(item["passed"] for item in results) else 1)
