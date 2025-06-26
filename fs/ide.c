/*
 * Minimal PIO-based (non-interrupt-driven) IDE driver code.
 * For information about what all this IDE/ATA magic means,
 * see the materials available on the class references page.
 */

#include "fs.h"
#include <inc/x86.h>

extern struct Super *super;		// superblock
extern uint32_t *bitmap;		// bitmap blocks mapped in memory
#define IDE_BSY		0x80
#define IDE_DRDY	0x40
#define IDE_DF		0x20
#define IDE_ERR		0x01

static int diskno = 1;

#define PCI_CONFIG_ADDRESS 0xCF8
#define PCI_CONFIG_DATA    0xCFC
uint32_t pci_config_read32(uint8_t bus, uint8_t device, uint8_t function, uint8_t offset)
{
    uint32_t address = 
        (1U << 31) | 
        ((uint32_t)bus << 16) |
        ((uint32_t)device << 11) |
        ((uint32_t)function << 8) |
        (offset & 0xFC);

    outl(PCI_CONFIG_ADDRESS, address);
    return inl(PCI_CONFIG_DATA);
}

void pci_scan()
{
    cprintf("start pci scan\n");
    for (int bus = 0; bus < 256; bus++) {
        for (int dev = 0; dev < 32; dev++) {
            for (int func = 0; func < 8; func++) {
                uint32_t vendor_device = pci_config_read32(bus, dev, func, 0x00);
                uint16_t vendor = vendor_device & 0xFFFF;
                if (vendor == 0xFFFF) continue; // no device

                uint32_t classcode = pci_config_read32(bus, dev, func, 0x08);
                uint8_t class_id = (classcode >> 24) & 0xFF;
                uint8_t subclass  = (classcode >> 16) & 0xFF;
                uint8_t prog_if   = (classcode >> 8)  & 0xFF;

                // 检查是否是 NVMe 控制器
                if (class_id == 0x01 && subclass == 0x08 && prog_if == 0x02) {
                    cprintf("Found NVMe device at %02x:%02x.%x\n", bus, dev, func);

                    // 读取 BAR0
                    uint32_t bar0 = pci_config_read32(bus, dev, func, 0x10);
                    uint32_t mmio_base = bar0 & ~0xF;  // 清除低位 flag 位
                    cprintf("NVMe MMIO base: 0x%x\n", mmio_base);

                    // 保存到全局变量或调用初始化
                    // nvme_init(mmio_base);
                }
            }
        }
    }

}
static int
ide_wait_ready(bool check_error)
{
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
}

bool
ide_probe_disk1(void)
{
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
	return (x < 1000);
}

void
ide_set_disk(int d)
{
	if (d != 0 && d != 1)
		panic("bad disk number");
	diskno = d;
}


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
	int r;

	assert(nsecs <= 256);

	ide_wait_ready(0);

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
}

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
	int r;

	assert(nsecs <= 256);

	ide_wait_ready(0);

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
}
