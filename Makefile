install:
	swift package update
	swift build -c release
	install .build/release/cloakswift /usr/local/bin/cloakswift

uninstall:
	rm -f /usr/local/bin/cloakswift