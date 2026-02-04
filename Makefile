# Default variables
SCHEME ?= LoopJournal
CONFIGURATION ?= Release
ARCHIVE_PATH ?= build/$(SCHEME).xcarchive
DESTINATION ?= generic/platform=iOS
WORKSPACE ?=
PROJECT ?=
EXPORT_OPTIONS_PLIST ?= ExportOptions.plist
EXPORT_PATH ?= build

.PHONY: archive ipa clean

archive:
	@echo "==> Archiving $(SCHEME) ($(CONFIGURATION)) to $(ARCHIVE_PATH)"
	SCHEME="$(SCHEME)" \
	CONFIGURATION="$(CONFIGURATION)" \
	ARCHIVE_PATH="$(ARCHIVE_PATH)" \
	DESTINATION="$(DESTINATION)" \
	WORKSPACE="$(WORKSPACE)" \
	PROJECT="$(PROJECT)" \
	./scripts/archive.sh

ipa: archive
	@echo "==> Exporting IPA to $(EXPORT_PATH) using $(EXPORT_OPTIONS_PLIST)"
	SCHEME="$(SCHEME)" \
	CONFIGURATION="$(CONFIGURATION)" \
	ARCHIVE_PATH="$(ARCHIVE_PATH)" \
	DESTINATION="$(DESTINATION)" \
	WORKSPACE="$(WORKSPACE)" \
	PROJECT="$(PROJECT)" \
	EXPORT_IPA=true \
	EXPORT_OPTIONS_PLIST="$(EXPORT_OPTIONS_PLIST)" \
	EXPORT_PATH="$(EXPORT_PATH)" \
	./scripts/archive.sh

clean:
	@echo "==> Cleaning build artifacts"
	rm -rf build
