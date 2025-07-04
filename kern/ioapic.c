#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/string.h>
#include <kern/cpu.h>
#include <inc/x86.h>

#define RSDP_SEARCH_START 0x000E0000
#define RSDP_SEARCH_END   0x00100000

#define IOAPIC_BASE 0xFEC00000 
#define IOREGSEL(ioapic_maddr) (*(volatile uint32_t *)(ioapic_maddr + 0x00))
#define IOWIN(ioapic_maddr)    (*(volatile uint32_t *)(ioapic_maddr + 0x10))

#define IOAPIC_RED_TBL_BASE 0x10  // Redirection entries 从 0x10 开始
#define REDTBL_LOW(i)  (IOAPIC_RED_TBL_BASE + (i) * 2)
#define REDTBL_HIGH(i) (IOAPIC_RED_TBL_BASE + (i) * 2 + 1)



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

void ioapic_write(u32 maddr, uint8_t reg, uint32_t val) {
    IOREGSEL(maddr) = reg;
    IOWIN(maddr) = val;
}


volatile u32 ioapic_addr;
const u32 ioapic_base = IOAPIC_BASE;

void irq_redirect_ioapic(u32 cpu_id, u32 irq_num, u32 vector)
{
    if (ioapic_addr == 0)
    {
        cprintf("ioapic_addr not init!!!\n");
        return;
    }

    ioapic_write(ioapic_addr, REDTBL_HIGH(irq_num), cpu_id << 24);     // CPU 0
    ioapic_write(ioapic_addr, REDTBL_LOW(irq_num), vector);         // 向量号 0x21
}

int ioapic_init()
{
    u32 version = ioapic_read(ioapic_addr, 0x01);
    int max_redir = ((version >> 16) & 0xff) + 1;
    cprintf("max redir cnt %d\n", max_redir);

    // 设置 IRQ1 -> vector 0x21，route to CPU 0
    // ioapic_write(ioapic_addr, REDTBL_HIGH(1), 0 << 24);     // CPU 0
    // ioapic_write(ioapic_addr, REDTBL_LOW(1), 0x21);         // 向量号 0x21
    irq_redirect_ioapic(0, IRQ_TIMER, IRQ_TIMER + IRQ_OFFSET);
    irq_redirect_ioapic(0, IRQ_KBD, IRQ_KBD + IRQ_OFFSET);
    irq_redirect_ioapic(0, IRQ_SERIAL, IRQ_SERIAL + IRQ_OFFSET);
    irq_redirect_ioapic(0, IRQ_NVME, IRQ_NVME);

    // 屏蔽 8259 所有 IRQ
    outb(0x21, 0xFF);  // 主 PIC
    outb(0xA1, 0xFF);  // 从 PIC

    return 0;
}