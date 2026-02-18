.PHONY: help install uninstall backup compress clean

SCRIPTS_DIR := scripts

help:
	@echo ""
	@echo "  Lean Windows 11 Office VM"
	@echo ""
	@echo "  make install            Download image and set up GNOME Boxes"
	@echo "  make uninstall          Remove VM, GNOME Boxes and all configs"
	@echo "  make uninstall IMAGE=1  Also delete the qcow2 image"
	@echo "  make backup             Backup current image"
	@echo "  make compress           Recompress image (reclaim space after updates)"
	@echo "  make clean              Remove backups and temp files"
	@echo ""

install:
	@bash $(SCRIPTS_DIR)/install.sh

uninstall:
	@bash $(SCRIPTS_DIR)/uninstall.sh "$(IMAGE)"

backup:
	@bash $(SCRIPTS_DIR)/backup.sh

compress:
	@bash $(SCRIPTS_DIR)/compress.sh

clean:
	@bash $(SCRIPTS_DIR)/clean.sh