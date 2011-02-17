PACKAGE = GSM
EE_BIN = $(PACKAGE).ELF
EE_OBJS := iomanx.o filexio.o ps2fs.o fakehost.o loader.o elf.o
EE_OBJS += timer.o pad.o
EE_OBJS += engine.o  
EE_OBJS += gsm.o  
	
EE_INCS += -I$(PS2SDK)/ports/include -I$(GSKIT)/include -I$(GSKIT)/ee/dma/include -I$(GSKIT)/ee/gs/include -I$(GSKIT)/ee/toolkit/include

EE_LIBS = -L$(PS2SDK)/ports/lib -L$(GSKIT)/lib -lgskit -ldmakit -ljpeg
EE_LIBS += -lfileXio -lmc -lpad

EE_LDFLAGS = -Xlinker -Map -Xlinker 'uncompressed $(PACKAGE).map' -L$(PS2SDK)/ee/lib -Tlinkfile -nostartfiles

all: $(EE_BIN)
	 rm -f 'uncompressed $(PACKAGE).ELF'
	 mv $(PACKAGE).ELF 'uncompressed $(PACKAGE).ELF'
	 ee-strip 'uncompressed $(PACKAGE).ELF'
	 ps2-packer 'uncompressed $(PACKAGE).ELF' $(PACKAGE).ELF > /dev/null

dump:
	ee-objdump -D 'uncompressed $(PACKAGE).ELF' > $(PACKAGE).dump
	ps2client netdump

test:
	ps2client -h $(PS2_IP) reset
	ps2client -h $(PS2_IP) execee host:'uncompressed $(PACKAGE).ELF'

run:
	ps2client -h $(PS2_IP) reset
	ps2client -h $(PS2_IP) execee host:$(PACKAGE).ELF

line:
	ee-addr2line -e 'uncompressed $(PACKAGE).ELF' $(ADDR)

reset:
	ps2client -h $(PS2_IP) reset

clean:
	rm -f *.ELF *.o *.a *.s *.i
	$(MAKE) -C loader clean

rebuild: clean all

iomanx.s:
	bin2s irx/iomanX.irx iomanx.s iomanx_irx
        
filexio.s:
	bin2s irx/fileXio.irx filexio.s filexio_irx
            
ps2fs.s:
	bin2s irx/ps2fs.irx ps2fs.s ps2fs_irx

fakehost.s:
	bin2s irx/fakehost.irx fakehost.s fakehost_irx
	
loader.s:
	$(MAKE) -C loader
	bin2s loader/loader.elf loader.s loader_elf

splash.s:
	bin2s splash.jpg splash.s splash		

include $(PS2SDK)/samples/Makefile.pref
include $(PS2SDK)/samples/Makefile.eeglobal
