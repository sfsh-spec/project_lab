#include <inc/x86.h>
#include <inc/trap.h>
#include <inc/stdio.h>
#include "pcie.h"

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

u32 pci_scan()
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
                    return mmio_base;
                    // 保存到全局变量或调用初始化
                    // nvme_init(mmio_base);
                }
            }
        }
    }

    return 0;
}