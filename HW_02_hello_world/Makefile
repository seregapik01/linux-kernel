# Makefile for the demo kernel module (my_module.c)
PWD := $(shell pwd)
KERNEL_DIR ?= /lib/modules/$(shell uname -r)/build

DRV_NAME := my_module
obj-m := $(DRV_NAME).o

.PHONY: all build format check run remove install uninstall clean

all: build

build:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules

format:
	clang-format -i my_module.c

check:
	bash check.sh

run:
	sudo insmod $(PWD)/$(DRV_NAME).ko

remove:
	sudo rmmod $(DRV_NAME)

install:
	sudo cp $(DRV_NAME).ko /lib/modules/$(shell uname -r)/
	sudo cp $(DRV_NAME).conf /etc/modprobe.d/
	sudo /sbin/depmod -a
	sudo /sbin/modprobe $(DRV_NAME)

uninstall:
	sudo /sbin/modprobe -r $(DRV_NAME)
	sudo rm -f /lib/modules/$(shell uname -r)/$(DRV_NAME).ko
	sudo rm -f /etc/modprobe.d/$(DRV_NAME).conf
	sudo /sbin/depmod -a

clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean
