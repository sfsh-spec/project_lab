#include <inc/x86.h>
#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/string.h>
#include <kern/nvme.h>
#include <kern/pmap.h>

extern physaddr_t lapicaddr;        // Initialized in mpconfig.c

volatile u32 nvme_vaddr;
volatile u32 nvme_msix_entry_vbase;
u32 nvme_asq_paddr = 0;
u32 nvme_acq_paddr = 0;

int nvme_msix_entry_init(u32 vbase, u32 mask)
{
    msix_entry_t *p = (msix_entry_t*)vbase;
    if (!mask)
    {
        p->vector_ctrl = mask;
        return 0;
    }
    cprintf("lapicaddr 0x%x\n", lapicaddr);
    p->msg_addr_low = lapicaddr;
    p->msg_addr_high = 0;
    p->msg_data = 0x40;
    p->vector_ctrl = mask;
    return 0;
}

int nvme_write_admin_cmd(u32 asq_paddr, struct nvme_admin_command *cmd)
{
    u32 asq_vaddr = asq_paddr + KERNBASE;
    memcpy((void*)asq_vaddr, cmd, sizeof(struct nvme_admin_command));
    asm volatile("mfence" ::: "memory");
    u32 tail = 1;
    *(volatile u32*)(nvme_vaddr + 0x1000) = 1;
    cprintf("write cmd done\n");
    return 0;
}

u32 nvme_test(u32 asq_paddr, u32 acq_paddr)
{
    u32 pbuffer = page2pa(page_alloc(ALLOC_ZERO));
    struct nvme_admin_command cmd = {0};
    cmd.opc = 0x06;         // Identify
    cmd.cid = 0x1234;       // 随便一个唯一 ID
    cmd.nsid = 0;           // 控制器级别
    cmd.prp1 = pbuffer; // 指向一个 4096B 物理 buffer
    cmd.cns  = 1;           // Identify Controller

    nvme_write_admin_cmd(asq_paddr, &cmd);
    return pbuffer;
}

int nvme_init()
{
    nvme_msix_entry_init(nvme_msix_entry_vbase, 1);

    u32 cap = nvme_read(REG_CAP);
    cprintf("cap 0 0x%x\n", cap);
    cap = nvme_read(REG_CAP+4);
    cprintf("cap 1 0x%x\n", cap);

    u32 ver = nvme_read(REG_VS);
    cprintf("ver %x\n", ver);

    nvme_write(REG_CC, 0);
    u32 val;
    u32 timeout = 0;
    while ((nvme_read(REG_CSTS) & 1) != 0)
    {
        timeout++;
        if (timeout > 10000000)
        {
            cprintf("nvme init time out\n");
            return -1;
        }
    }

    struct PageInfo *p = NULL;
    p = page_alloc(ALLOC_ZERO);

    if (p != NULL)
    {
        p->pp_ref++;
        nvme_asq_paddr = (u32)page2pa(p);
        cprintf("asq addr 0x%x\n", nvme_asq_paddr);
    }
    else
    {
        panic("alloc nvme asq fail\n");
    }

    p = page_alloc(ALLOC_ZERO);
    if (p != NULL)
    {
        p->pp_ref++;
        nvme_acq_paddr = (u32)page2pa(p);
        cprintf("acq addr 0x%x\n", nvme_acq_paddr);
    }
    else
    {
        panic("alloc nvme acq fail\n");
    }

    u32 q_depth = 16;
    nvme_write(REG_AQA, (q_depth - 1) | ((q_depth -1) << 16));

    nvme_write(REG_ASQ, nvme_asq_paddr);
    nvme_write(REG_ACQ, nvme_acq_paddr);
    q_depth = nvme_read(REG_AQA);
    cprintf("aqa 0x%x\n", q_depth);

    u32 cc = 0;
    cc |= (6 << 16); // IOSQES: 64 bytes
    cc |= (4 << 20); // IOCQES: 16 bytes
    cc |= 1;         // EN
    cprintf("cc 0x%x\n", cc);
    nvme_write(REG_CC, cc);

    timeout = 0;
    u32 test_val = 0xff;
    while ((test_val = nvme_read(REG_CSTS) & 1) != 1)
    {
        timeout++;
        if (timeout > 100000000)
        {
            cprintf("nvme start time out\n");
            return -1;
        }
    }

    nvme_msix_entry_init(nvme_msix_entry_vbase, 0);
    cprintf("nvme init done\n");
    u32 eflag = read_eflags();
    eflag |= FL_IF;
    write_eflags(eflag);
    u32 pbuf = nvme_test(nvme_asq_paddr, 0);
    u8 *kbuf = (u8*)(pbuf + KERNBASE);
    // while (timeout < 1000000000)
    // {
    //     timeout++;
    // }

    u32 nvme_acq_vaddr = nvme_acq_paddr + KERNBASE;
    while (1)
    {
        volatile nvme_cpl_t *cpl = (volatile nvme_cpl_t*)nvme_acq_vaddr;
        if ((cpl->status & 0x1) == 1)
        {
            cprintf("timeout cnt %d\n", timeout);
            {
                cprintf("%s\n", kbuf);
            }
            *(volatile u32*)(nvme_vaddr + 0x1000 + 4) = 1;
            break;
        }
        timeout++;
        if (timeout > 10000000)
        {
            cprintf("nvme get cqe time out\n");
            return -1;
        }
    }
    val = *(volatile u32*)nvme_acq_vaddr;
    return 0;
}

u32 nvme_read(u32 offset)
{
    return NVME_REG_READ(nvme_vaddr, offset);
}

void nvme_write(u32 offset, u32 val)
{
    NVME_REG_WRITE(nvme_vaddr, offset, val);
}