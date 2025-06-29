all: assemble

help:
	@echo "make assemble - assembles the resource pack"
	@echo "make clean    - removes resource pack"

SRCS = pack.mcmeta pack.png assets
OUT = oldlight.zip

clean:
	rm -f $(OUT)

assemble:
	rm -f $(OUT)
	zip -r $(OUT) $(SRCS)
