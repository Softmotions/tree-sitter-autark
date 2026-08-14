TREE_SITTER ?= tree-sitter

.PHONY: generate test build wasm highlight clean

generate:
	$(TREE_SITTER) generate

test: generate
	$(TREE_SITTER) test

build: generate
	$(TREE_SITTER) build

wasm:
	$(TREE_SITTER) generate --abi 15
	$(TREE_SITTER) build --wasm

highlight: generate
	$(TREE_SITTER) highlight examples/Autark

clean:
	rm -rf build *.wasm

.PHONY: test-vim
test-vim:
	vim -Nu NONE -n -es -S test/vim-smoke.vim
