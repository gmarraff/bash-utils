.PHONY: help windows systemd uninstall reinstall clear-cache logs

help:
	@echo "make windows      Install as a Windows scheduled task (WSL)"
	@echo "make systemd      Install as a systemd user service"
	@echo "make uninstall    Remove both, plus the saved variables and logs"
	@echo "make reinstall    Uninstall, then install the same setup again"
	@echo "make clear-cache  Forget the cached channel names and restart the app"
	@echo "make logs         Follow the app's logs"

windows systemd uninstall reinstall clear-cache:
	./install.sh $@

logs:
	@if [ -e ~/.config/systemd/user/go-claudio-go.service ]; then \
		journalctl --user -u go-claudio-go -f; \
	else \
		tail -f ~/.local/state/go-claudio-go/app.log; \
	fi
