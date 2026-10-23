.PHONY: help windows systemd uninstall reinstall clear-cache delicate ballistic logs

# No built-in rules, otherwise `make install` copies install.sh to ./install
.SUFFIXES:

help:
	@echo "make windows      Install as a Windows scheduled task (WSL)"
	@echo "make systemd      Install as a systemd user service"
	@echo "make uninstall    Remove both, plus the saved variables and logs"
	@echo "make reinstall    Uninstall, then install the same setup again"
	@echo "make clear-cache  Forget the cached channel names and restart the app"
	@echo "make delicate     React only to @Claude mentions (the default)"
	@echo "make ballistic    Also react when Claude is named in plain text"
	@echo "make logs         Follow the app's logs"

windows systemd uninstall reinstall clear-cache delicate ballistic:
	./install.sh $@

logs:
	@if [ -e ~/.config/systemd/user/go-claudio-go.service ]; then \
		journalctl --user -u go-claudio-go -f; \
	else \
		tail -f ~/.local/state/go-claudio-go/app.log; \
	fi
