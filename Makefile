export PATH := $(PATH):$(PWD)/bin


indexes:
	$(MAKE) -C db indexes

databases:
	$(MAKE) -C db databases


all: indexes

