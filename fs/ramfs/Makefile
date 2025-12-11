#
# Makefile for the linux ramfs routines.
#
ccflags-y += -O3

obj-y += ramfs.o

file-mmu-y := file-nommu.o
file-mmu-$(CONFIG_MMU) := file-mmu.o
ramfs-objs += inode.o $(file-mmu-y)
