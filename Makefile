SHELL := bash
CC=gcc
CFLAGS=-Wall -Wextra -std=c11 -g -O0
ARTIFACT_DIR=artifacts
LOG_DIR=$(ARTIFACT_DIR)/logs

.PHONY: setup sbom secret-scan clean init build-memory-regions build-memory-regions-ci run-memory-regions log-memory-regions inspect-memory-regions-sections inspect-memory-regions-segments

init:
	mkdir -p $(ARTIFACT_DIR) $(LOG_DIR)
sbom:
	@mkdir -p artifacts
	@command -v syft >/dev/null 2>&1 || (echo "syft yok(şimdilik normal). CI içinde kuracağız" && exit 1)
	syft . -o json >artifacts/sbom.json
	@echo "SBOM -> artifacts/sbom.json"

secret-scan:
	@command -v gitleaks >/dev/null 2>&1 || (echo "gitleaks yok(şimdilik normal). CI içinde kuracağız" && exit 1)
	gitleaks detect --source . -v

clean:
	@mkdir -p $(ARTIFACT_DIR)
	rm -rf $(ARTIFACT_DIR)/*
	touch $(ARTIFACT_DIR)/.gitkeep

setup:
	./scripts/setup.sh

# Video-1 memory_regions.c
build-memory-regions: init
	$(CC) $(CFLAGS) -o $(ARTIFACT_DIR)/memory_regions lab/c/memory_regions.c

build-memory-regions-ci: init
	$(CC) $(CFLAGS) -DCI_MODE -o $(ARTIFACT_DIR)/memory_regions_ci lab/c/memory_regions.c

run-memory-regions: build-memory-regions
	./$(ARTIFACT_DIR)/memory-regions

log-memory-regions: build-memory-regions-ci
	./$(ARTIFACT_DIR)/memory_regions_ci > $(LOG_DIR)/memory_regions_run1.log
	./$(ARTIFACT_DIR)/memory_regions_ci > $(LOG_DIR)/memory_regions_run2.log

inspect-memory-regions-sections: build-memory-regions
	readelf -S $(ARTIFACT_DIR)/memory-regions
	nm -n $(ARTIFACT_DIR)/memory-regions
	objdump -h $(ARTIFACT_DIR)/memory-regions

inspect-memory-regions-segments: build-memory-regions
	readelf -l $(ARTIFACT_DIR)/memory-regions



