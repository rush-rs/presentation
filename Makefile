build: listings/generated
	rm -f main.pdf
	make main.pdf
	exiftool \
		-Title="Defense: The Conversion of Source Code to Machine Code" \
		-Author="Silas Groh, Mik Müller" \
		-Subject="Compiler Construction" \
		-Keywords="compiler, compiler construction, programming language" \
		-overwrite_original \
		main.pdf

main.pdf: main.tex deps preamble lirstings.json
	latexmk -lualatex -shell-escape -g main.tex

listings/generated: rush_build.py deps/rush deps/paper listings/incompatible_types.rush
	cd deps/paper && mkdir -p listings/generated && python3 rush_build.py build && cd ..
	mkdir -p ./listings/generated/
	python3 rush_build.py build

check: rush_build.py listings deps
	mkdir -p ./listings/generated/
	python3 rush_build.py check
	python3 rush_build.py used

init: fetch_deps.sh
	sh fetch_deps.sh
	mkdir -p ./deps/paper/deps
	cp -fr ./deps/rush ./deps/paper/deps/rush
	cargo install --git https://github.com/rush-rs/lirstings --force

clean:
	eztex c
	rm -f lirstings.cache.json
	rm -f tokei.cache.json
	rm -rf listings/generated
