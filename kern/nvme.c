#include <inc/types.h>

#define NVME_REG_READ(base, offset) (*(volatile uint32_t *)(base + offset))

volatile u32 nvme_addr;

int nvme_init()
{
    return 0;
}

u32 nvme_read(u32 offset)
{
    return NVME_REG_READ(nvme_addr, offset);
}