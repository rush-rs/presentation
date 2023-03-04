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

init: fetch_deps.sh
	sh fetch_deps.sh
	mkdir -p ./deps/paper/deps
	cp -fr ./deps/rush ./deps/paper/deps/rush
	cargo install --git https://github.com/rush-rs/lirstings --force

listings/generated:
	cd deps/paper && make listings/generated && cd ..

clean:
	eztex c
	rm -f lirstings.cache.json
