#!/usr/bin/env python3
import os
import sys
import zipfile
import hashlib
import base64
import subprocess
import tempfile
import shutil

def sha256_b64(data: bytes) -> str:
    return base64.b64encode(hashlib.sha256(data).digest()).decode('ascii')

def main():
    base_apk = '/app/applet/islami-lite.apk'
    out_apk = '/app/applet/islami.apk'
    icon_path = '/app/applet/assets/images/1.png'
    dist_dir = '/app/applet/dist'

    if not os.path.exists(base_apk):
        print(f"Error: Base APK {base_apk} not found", file=sys.stderr)
        sys.exit(1)

    workdir = tempfile.mkdtemp()
    try:
        # 1. Read existing non-asset binaries from base APK
        entries = {}
        with zipfile.ZipFile(base_apk, 'r') as z:
            for name in z.namelist():
                if name.startswith('META-INF/'):
                    continue
                entries[name] = z.read(name)

        # 2. Update icon with 1.png
        if os.path.exists(icon_path):
            with open(icon_path, 'rb') as f:
                icon_bytes = f.read()
            entries['res/drawable/icon.png'] = icon_bytes
            entries['assets/assets/images/1.png'] = icon_bytes
            print("✓ Updated icon to 1.png")

        # 3. Update splash with 2.png
        splash_path = '/app/applet/assets/images/2.png'
        if os.path.exists(splash_path):
            with open(splash_path, 'rb') as f:
                splash_bytes = f.read()
            entries['assets/assets/images/2.png'] = splash_bytes
            print("✓ Included 2.png splash screen asset")

        # 4. Remove old dist assets and add newly compiled dist assets
        entries = {k: v for k, v in entries.items() if not k.startswith('assets/dist/')}
        for root, _, files in os.walk(dist_dir):
            for file in files:
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, dist_dir)
                archive_name = 'assets/dist/' + rel_path.replace('\\', '/')
                with open(full_path, 'rb') as f:
                    entries[archive_name] = f.read()

        # Also ensure assets/assets/images/ has all files offline
        quran_dir = '/app/applet/assets/images/quran'
        for file in os.listdir(quran_dir):
            if file.endswith('.png'):
                full_path = os.path.join(quran_dir, file)
                archive_name = 'assets/assets/images/quran/' + file
                with open(full_path, 'rb') as f:
                    entries[archive_name] = f.read()

        print(f"✓ Embedded all Quran images & newly built dist assets ({len(entries)} total files)")

        # 5. Generate MANIFEST.MF
        manifest_lines = [
            "Manifest-Version: 1.0",
            "Created-By: 1.0 (Android)",
            ""
        ]
        manifest_sections = {}
        sorted_names = sorted(entries.keys())
        for name in sorted_names:
            digest = sha256_b64(entries[name])
            section = f"Name: {name}\r\nSHA-256-Digest: {digest}\r\n\r\n"
            manifest_sections[name] = section
            manifest_lines.append(f"Name: {name}")
            manifest_lines.append(f"SHA-256-Digest: {digest}")
            manifest_lines.append("")

        manifest_content = "\r\n".join(manifest_lines) + "\r\n"
        manifest_bytes = manifest_content.encode('utf-8')
        entries['META-INF/MANIFEST.MF'] = manifest_bytes

        # 6. Generate ISLAMI.SF
        sf_lines = [
            "Signature-Version: 1.0",
            "Created-By: 1.0 (Android)",
            f"SHA-256-Digest-Manifest: {sha256_b64(manifest_bytes)}",
            ""
        ]
        for name in sorted_names:
            section_bytes = manifest_sections[name].encode('utf-8')
            sf_lines.append(f"Name: {name}")
            sf_lines.append(f"SHA-256-Digest: {sha256_b64(section_bytes)}")
            sf_lines.append("")

        sf_content = "\r\n".join(sf_lines) + "\r\n"
        sf_bytes = sf_content.encode('utf-8')
        entries['META-INF/ISLAMI.SF'] = sf_bytes

        # 7. Generate RSA signature with OpenSSL
        cert_path = os.path.join(workdir, 'cert.pem')
        key_path = os.path.join(workdir, 'key.pem')
        sf_path = os.path.join(workdir, 'ISLAMI.SF')
        rsa_path = os.path.join(workdir, 'ISLAMI.RSA')

        with open(sf_path, 'wb') as f:
            f.write(sf_bytes)

        gen_cert_cmd = [
            'openssl', 'req', '-newkey', 'rsa:2048', '-nodes',
            '-keyout', key_path, '-x509', '-days', '3650',
            '-out', cert_path, '-subj', '/CN=Islami/O=App/C=EG'
        ]
        subprocess.check_call(gen_cert_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        sign_cmd = [
            'openssl', 'smime', '-sign', '-in', sf_path,
            '-out', rsa_path, '-outform', 'DER', '-binary',
            '-nodetach', '-signer', cert_path, '-inkey', key_path
        ]
        subprocess.check_call(sign_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        with open(rsa_path, 'rb') as f:
            entries['META-INF/ISLAMI.RSA'] = f.read()

        # 8. Write final signed APK
        tmp_out = os.path.join(workdir, 'final.apk')
        with zipfile.ZipFile(tmp_out, 'w', compression=zipfile.ZIP_DEFLATED) as zout:
            # Android requires uncompressed resources.arsc and classes.dex
            for name in sorted(entries.keys()):
                data = entries[name]
                if name.endswith('.arsc') or name.endswith('.dex'):
                    zout.writestr(name, data, compress_type=zipfile.ZIP_STORED)
                else:
                    zout.writestr(name, data, compress_type=zipfile.ZIP_DEFLATED)

        # Copy to output destinations
        shutil.copyfile(tmp_out, out_apk)
        shutil.copyfile(tmp_out, '/app/applet/public/islami.apk')
        shutil.copyfile(tmp_out, '/app/applet/islami-lite.apk')
        shutil.copyfile(tmp_out, '/app/applet/public/islami-lite.apk')

        size_kb = os.path.getsize(out_apk) / 1024
        print(f"✓ Successfully built and signed fresh APK: {out_apk} ({size_kb:.1f} KB)")

    finally:
        shutil.rmtree(workdir, ignore_errors=True)

if __name__ == '__main__':
    main()
