#!/usr/bin/env bash

set -euo pipefail

echo "[setup] Gerekli araçlar kontrol ediliyor"

missing=()
need(){
    local name="$1"
    local hint="$2"
    if ! command -v "$name" >/dev/null 2>&1; then
        echo "Bulunamadı: $name"
        echo " Hint:$hint"
        missing+=("$name")
    else
        echo "$name,bulundu."
    fi
}

#Daha sonrası için opsiyonel olanlar (güncellenilebilir)

optional() {
    local name="$1"
    local hint="${2:-}"
    if command -v "$name" >/dev/null 2>&1; then
        echo "(optional) $name bulundu."
    else   
        echo "(optional) $name bulunamadı."
        if  [ -n "$hint" ]; then
        echo "  İpucu: $hint"
        fi
    fi
}

# Zorunlular (Ay 1 minimum)
need gcc   "MinGW-w64 GCC kur (MSYS2 ya da MinGW-w64)."
need git   "Git for Windows kur (Git Bash zaten bununla gelir)."
if command -v python >/dev/null 2>&1; then
	echo "python,bulundu."
elif command -v python3 >/dev/null 2>&1; then
	echo "python3, bulundu."
else
	echo "Bulunamadı: python"
	echo "Hint: Python 3 kur ve 'python -- version' çalışsın."
	missing+=("python")
fi

# Opsiyoneller (sonra lazım olacaklar)
optional clang   "İleride clang ile uyarı/davranış kıyası yapacağız."
optional cargo   "Rust labları için gerekli."
optional syft    "SBOM üretmek için (CI'da kurulacak, local sonra)."
optional gitleaks "Secret scan için (CI'da kurulacak, local sonra)."
optional semgrep "Hafta 2'de SAST için."

echo

if [ "${#missing[@]}" -ne 0 ]; then
    echo "[setup] Eksikler var,: ${missing[*]}"
    echo "[setup] Bu eksikleri kurduktan sonra tekrar çalıştır."
    exit 1
else
    echo "[setup] zorunlu amaçlar tamam."
fi


