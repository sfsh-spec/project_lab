#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/string.h>

#define RSDP_SEARCH_START 0x000E0000
#define RSDP_SEARCH_END   0x00100000

#define IOAPIC_BASE 0xFEC00000 
#define IOREGSEL(ioapic_addr) (*(volatile uint32_t *)(ioapic_addr + 0x00))
#define IOWIN(ioapic_addr)    (*(volatile uint32_t *)(ioapic_addr + 0x10))

// 计算 length 字节的校验和
uint8_t acpi_checksum(uint8_t *ptr, size_t length) {
    uint8_t sum = 0;
    for (size_t i = 0; i < length; i++) {
        sum += ptr[i];
    }
    return sum;
}

bool is_valid_rsdp(uint8_t *ptr) {
    // 签名检查
    if (memcmp(ptr, "RSD PTR ", 8) != 0) {
        return false;
    }

    // ACPI 1.0 checksum
    if (acpi_checksum(ptr, 20) != 0) {
        return false;
    }

    // 如果是 ACPI 2.0+
    uint8_t revision = ptr[15];
    if (revision >= 2) {
        uint32_t len = *(uint32_t*)(ptr + 20); // length 字段偏移 = 20
        if (len < 36) return false;
        if (acpi_checksum(ptr, len) != 0) {
            return false;
        }
    }

    return true;
}

typedef struct rsdp1 {
    char     signature[8];     // "RSD PTR "
    uint8_t  checksum;
    char     oem_id[6];
    uint8_t  revision;         // 0 表示 ACPI 1.0
    uint32_t rsdt_address;     // ✅ 这里是 RSDT 的物理地址
} rsdp1_t;

void scan_rsdp()
{
    rsdp1_t *p = NULL;
    for (uintptr_t addr = RSDP_SEARCH_START; addr < RSDP_SEARCH_END; addr += 16)
    {
        if (is_valid_rsdp((uint8_t*)addr))
        {
            // found it!
            cprintf("found!! addr 0x%x\n", addr);
            p = (rsdp1_t*)addr;
            break;
        }
    }
    uint32_t rsdt_addr = *(uint32_t *)(p + 16);
    cprintf("ver %d rsdt addr 0x%x\n", p->revision, rsdt_addr);

}


uint32_t ioapic_read(u32 base, uint8_t reg)
{
    IOREGSEL(base) = reg;
    return IOWIN(base);
}

u32 ioapic_addr;
const u32 ioapic_base = IOAPIC_BASE;