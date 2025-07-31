# WooshCalc, a fast and lightwieght arithmetic calculator.
# Copyright (C) 2025 Wojciech Zduniak <githubinquiries.ladder140@passinbox.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

MAKEFILE_DIR = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
ORIGIN_DIR = $(PWD)
CFLAGS = nasm -g -F dwarf -f elf32
all:
	cd $(MAKEFILE_DIR)
	rm -rf bin/
	rm -rf debug/
	mkdir bin/
	mkdir bin/objects
	mkdir debug/
	cp src/input.asm debug/input.asm
	sed -i "s|PLACEHOLDER_W_FOR_MAKE|$(MAKEFILE_DIR)src/text_files/warranty.txt|g" debug/input.asm
	sed -i "s|PLACEHOLDER_C_FOR_MAKE|$(MAKEFILE_DIR)src/text_files/conditions.txt|g" debug/input.asm
	$(CFLAGS) src/main.asm -Isrc/ -o bin/objects/main.o
	$(CFLAGS) debug/input.asm -o bin/objects/input.o
	cd $(PWD)
	ld -m elf_i386 bin/objects/main.o  bin/objects/input.o -o bin/WooshCalc
.PHONY: clean
clean:
	cd $(MAKEFILE_DIR)
	rm -rf bin/
	rm -rf debug/
	cd $(PWD)
