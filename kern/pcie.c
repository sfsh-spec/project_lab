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

uint16_t pci_config_read16(uint8_t bus, uint8_t device, uint8_t function, uint8_t offset)
{
    uint32_t address = 
        (1U << 31) | 
        ((uint32_t)bus << 16) |
        ((uint32_t)device << 11) |
        ((uint32_t)function << 8) |
        (offset & 0xFC);

    outl(PCI_CONFIG_ADDRESS, address);
    u32 data = inl(PCI_CONFIG_DATA);
    u8 shift = (offset & 2) * 8;
    return (data >> shift) & 0xffff;
}

void pci_config_write16(uint8_t bus, uint8_t device, uint8_t function,
                        uint8_t offset, uint16_t value) {
    // 构建地址：bit 0~1 固定为 00，offset 必须是字对齐
    uint32_t address = (1U << 31)               // Enable bit
                     | ((uint32_t)bus << 16)
                     | ((uint32_t)device << 11)
                     | ((uint32_t)function << 8)
                     | (offset & 0xFC);         // 对齐到 32 位

    // 写入地址
    outl(PCI_CONFIG_ADDRESS, address);

    // 写入数据端口（+2 代表写入16位的高地址部分）
    outw(PCI_CONFIG_DATA + (offset & 2), value);
}

u32 nvme_dev_scan(u32 *mmio_base, u32 *msix_entry_base)
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
                    *mmio_base = bar0 & ~0xF;  // 清除低位 flag 位
                    cprintf("NVMe MMIO base: 0x%x\n", *mmio_base);
                    // for (int i = 0; i < 0x100; i+=2)
                    // {
                    //     u32 msix_info = pci_config_read16(bus, dev, func, 0x34+i);
                    //     cprintf("offset 0x%x msix_info: 0x%x\n", i+0x34, msix_info);
                    // }

                    u32 cap_offset = 0x40;
                    uint16_t msg_ctl = pci_config_read16(bus, dev, func, cap_offset + 0x2);
                    msg_ctl |= (1 << 15);
                    msg_ctl &= ~(1 << 14);
                    pci_config_write16(bus, dev, func, 0x42, msg_ctl);
                    u32 table = pci_config_read32(bus, dev, func, cap_offset + 0x4);
                    u32 table_size = (msg_ctl & 0x7ff) + 1;
                    u32 table_bir  = table & 0x7;
                    u32 table_offset = table & ~0x7;
                    cprintf("size 0x%x, bir 0x%x, offset 0x%x\n", table_size, table_bir, table_offset);
                    *msix_entry_base = (bar0 & ~0xf) + table_offset;

                    return 0;
                }
            }
        }
    }

    return 0;
}
