.PHONY: help install backup compress clean

SCRIPTS_DIR := scripts

help:
	@echo ""
	@echo "  Lean Windows 11 Office VM"
	@echo ""
	@echo "  make install    Download image and set up GNOME Boxes"
	@echo "  make backup     Backup current image"
	@echo "  make compress   Recompress image (reclaim space after updates/cleanup)"
	@echo "  make clean      Remove backups and temp files"
	@echo ""

install:
	@bash $(SCRIPTS_DIR)/install.sh

backup:
	@bash $(SCRIPTS_DIR)/backup.sh

compress:
	@bash $(SCRIPTS_DIR)/compress.sh

clean:
	@bash $(SCRIPTS_DIR)/clean.sh