IMAGES_FOLDER ?= $(INPUT_FOLDER)/images
INPUT_FOLDER ?= $(shell pwd)
OUTPUT_FOLDER ?= $(shell pwd)/dist

intro:
	@pandoc introduction/nix-intro.md \
	--from markdown+tex_math_single_backslash \
	--to revealjs \
	--output nix-intro.html \
	--template template/index.html \
	-V revealjs-url=template \
	-V theme=white \
	-V progress=true \
	-V slideNumber=true \
	-V history=true \
	--standalone --slide-level 2
