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
parser.add_argument("--model", choices=("SessionWindow", "EndDrain", "SpscPublication", "RuntimeOwnership", "ReceiveDrain"), default="SessionWindow")
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
model_folder = {"SessionWindow": "session", "EndDrain": "stream", "SpscPublication": "concurrency", "RuntimeOwnership": "runtime", "ReceiveDrain": "runtime"}[args.model]
model = root / f"spec/{model_folder}/{args.model}.tla"
config = (root / f"spec/{model_folder}/{args.model}.cfg").read_text(encoding="utf-8")
profiles = {
    "SessionWindow": ({"none": None, "skip_auth": "AuthenticatedStreaming", "stale_epoch": "WindowBounds", "early_free": "QuiescentIdle", "replay_tick": "UniquePlayout"}, {"capacity": 2, "positions": 3, "epochs": 2}),
    "EndDrain": ({"none": None, "early_done": "Drained", "end_before_buffer": "Bounded", "post_end": "NoPostEndAdmission"}, {"capacity": 2, "positions": 3}),
    "SpscPublication": ({"none": None, "early_publish": "NoCorruption", "early_release": "NoCorruption"}, {"capacity": 2, "frames": 4}),
    "RuntimeOwnership": ({"none": None, "early_free": "LiveStorage", "stop_wait": "TEMPORAL"}, {"capacity": 2, "prefill": 2, "frames": 3, "epochs": 2, "drain_ticks": 2}),
    "ReceiveDrain": ({"none": None, "overwrite_pending": "FrameOrder", "drop_suffix": "FrameOrder", "early_ack": "AckFence", "short_stream_wait": "TEMPORAL"}, {"capacity": 2, "prefill": 2, "frames": 3, "max_block": 2}),
}
faults, bounds = profiles[args.model]
results = []
for fault, invariant in faults.items():
    with tempfile.TemporaryDirectory(prefix="lan-audio-tlc-") as scratch:
        folder = Path(scratch)
        (folder / model.name).write_bytes(model.read_bytes())
        (folder / f"{args.model}.cfg").write_text(config.replace('Fault = "none"', f'Fault = "{fault}"'), encoding="utf-8")
        command = [args.java, "-Xmx512m", "-cp", str(args.jar.resolve()), "tlc2.TLC", "-workers", "1", "-seed", "1", "-config", f"{args.model}.cfg", model.name]
        run = subprocess.run(command, cwd=folder, capture_output=True, text=True, timeout=120)
        output = run.stdout + run.stderr
        if invariant is None:
            passed = run.returncode == 0 and "Model checking completed. No error has been found." in output
        elif invariant == "TEMPORAL":
            passed = run.returncode != 0 and "Temporal properties were violated" in output
        else:
            passed = run.returncode != 0 and f"Invariant {invariant} is violated" in output
        counts = re.findall(r"([\d,]+) states generated, ([\d,]+) distinct states found", output)
        results.append({"fault": fault, "passed": passed, "returncode": run.returncode, "expected_violation": invariant, "states": counts[-1] if counts else None, "output": output})
report = {"model": args.model, "model_sha256": hashlib.sha256(model.read_bytes()).hexdigest(), "config_sha256": hashlib.sha256((root / f"spec/{model_folder}/{args.model}.cfg").read_bytes()).hexdigest(), "runner_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), "jar_sha256": hashlib.sha256(args.jar.read_bytes()).hexdigest(), "bounds": bounds, "results": results}
print(json.dumps(report, indent=2))
raise SystemExit(0 if all(item["passed"] for item in results) else 1)
