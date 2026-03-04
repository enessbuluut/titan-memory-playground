SHELL := bash

.PHONY: setup build run sbom secret-scan clean

setup:
	./scripts/setup.sh

build:
	@mkdir -p artifacts
	@command -v gcc >/dev/null 2>&1 || (echo "gcc yok. Önce 'make setup' çalıştır." && exit 1)
	@if ls lab/c/*.c >/dev/null 2>&1; then \
		echo "[build] C labs dosyaları derleniyor"; \
		gcc -Wall -Wextra -O0 -g lab/c/*.c -o artifacts/c_lab; \
		echo "Kuruldu: artifacts/c_lab"; \
	else \
		echo "c_lab içerisinde herhangi bir C dosyası bulunamadı."; \
	fi
run: build
	@if [ -f artifacts/c_lab ]; then \
		./artifacts/c_lab; \
	else \
		echo "Henüz hiçbir şey çalıştırılmadı"; \
	fi

sbom:
	@mkdir -p artifacts
	@command -v syft >/dev/null 2>&1 || (echo "syft yok(şimdilik normal). CI içinde kuracağız" && exit 1)
	syft . -o json >artifacts/sbom.json
	@echo "SBOM -> artifacts/sbom.json"

secret-scan:
	@command -v gitleaks >/dev/null 2>&1 || (echo "gitleaks yok(şimdilik normal). CI içinde kuracağız" && exit 1)
	gitleaks detect --source . -v
clean:
	@mkdir -p artifacts
	rm -rf artifacts/*
	touch artifacts/.gitkeep