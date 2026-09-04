.PHONY: test install uninstall

test:
	python3 -m unittest discover -s tests -p "test_*.py" -v

install:
	./install.sh

uninstall:
	./uninstall.sh
