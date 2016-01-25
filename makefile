# Linux (default)
EXE = example
CFLAGS = -std=gnu99
LDFLAGS = -lm

# Windows (cygwin)
ifeq "$(OS)" "Windows_NT"
	EXE = example.exe
	LDFLAGS = 
endif

# OS X, OSTYPE not being declared
ifndef OSTYPE
  OSTYPE = $(shell uname -s|awk '{print tolower($$0)}')
  #export OSTYPE
endif
ifeq ($(OSTYPE),darwin)
	LDFLAGS = 
endif

$(EXE): example.c
	gcc -o $@ $< $(CFLAGS) $(LDFLAGS)

run:
	./$(EXE) $(ARGS)