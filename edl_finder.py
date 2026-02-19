#!/usr/bin/env python3
import asyncio
import aiohttp
import re
import os

OTA_COMMON = "/storage/emulated/0/Download/DownloadeR/ota_common.txt"
OUTPUT_FILE = "/storage/emulated/0/Download/DownloadeR/Edl_Link.txt"

CONCURRENT = 40
TIMEOUT = aiohttp.ClientTimeout(total=10)

# ---------- LOAD ota_common.txt ----------
def load_common():
    if not os.path.exists(OTA_COMMON):
        print(f"❌ {OTA_COMMON} not found. Run OTA FindeR first.")
        return None

    data = {}
    with open(OTA_COMMON, "r") as f:
        for line in f:
            if "=" in line:
                k, v = line.strip().split("=", 1)
                data[k] = v.strip().strip('"')
    return data

data = load_common()
if not data:
    exit(1)

MODEL = data["MODEL"]
REGION = data["REGION"]
VERSION_NAME = data["VERSION_NAME"]
OTA = data["OTA"]

# ---------- REGION → BUCKET & SERVER ----------
if REGION in ("EU", "EUEX", "EEA", "TR"):
    BUCKET = "GDPR"
    SERVER = "rms01.realme.net"
elif REGION in ("CN", "CH"):
    BUCKET = "domestic"
    SERVER = "rms11.realme.net"
else:
    BUCKET = "export"
    SERVER = "rms01.realme.net"

# ---------- VERSION CLEAN ----------
VERSION_CLEAN = re.sub(r"^RMX\d+_", "", VERSION_NAME)
VERSION_CLEAN = VERSION_CLEAN.replace("(", "").replace(")", "")

# ---------- DATE ----------
DATE = OTA.split("_")[-1]

BASE_URL = f"https://{SERVER}/sw/{MODEL}{BUCKET}_11_{VERSION_CLEAN}_{DATE}"

# ---------- HEADER ----------
print (f"╔═════════════════════════════════════════╗")
print (f"╠══════   ===== EDL FindeR =====   ═══════╣")
print (f"╠═════════════════════════════════════════╣")
print (f"║ NAME        ║ DATA                      ║")
print (f"╠═════════════════════════════════════════╣")
print (f"║             ║                           ║")
print (f"║ Model:      ║ {MODEL}")
print (f"║ Region:     ║ {REGION}")
print (f"║ Bucket:     ║ {BUCKET}")
print (f"║ Server:     ║ {SERVER}")
print (f"║ VersionName:║ {VERSION_NAME}")
print (f"║ Date:       ║ {DATE}")
print (f"║             ║                           ║")
print ("╚═════════════════════════════════════════╝")
print("\n🔗 Base URL:")
print(BASE_URL)
print(f" ")
input("\n▶ Start EDL search? [ENTER]")
print(f" ")
print("\n🔍 Searching for EDL package, please wait...\n")

# ---------- ASYNC CHECK ----------
sem = asyncio.Semaphore(CONCURRENT)
found_event = asyncio.Event()  # Signál pre prvý nájdený odkaz

async def check(session, num):
    url = f"{BASE_URL}{num:04d}.zip"
    async with sem:
        try:
            async with session.head(url) as r:
                if r.status == 200 and not found_event.is_set():
                    print(f"✅ EDL package found:\n🔗 {url}")
                    with open(OUTPUT_FILE, "w") as f:
                        f.write(url + "\n")
                    found_event.set()  # stop ostatné úlohy
        except:
            pass

async def main():
    async with aiohttp.ClientSession(timeout=TIMEOUT) as session:
        tasks = [asyncio.create_task(check(session, i)) for i in range(10000)]
        for coro in asyncio.as_completed(tasks):
            await coro
            if found_event.is_set():
                # cancel remaining tasks
                for t in tasks:
                    if not t.done():
                        t.cancel()
                break

asyncio.run(main())

# ---------- FINISH ----------
if not os.path.exists(OUTPUT_FILE):
    print(f" ")
    print("❎ EDL package not found or not available")
else:
    print(f" ")
    print("\n✅ EDL search finished")
    print(f"📄 Result saved to {OUTPUT_FILE}")
    print(f" ")

# čakáme na stlačenie Enter pred návratom do menu
input("\nPress ENTER to return to menu...")