#ifndef NVME_H_
#define NVME_H_

#define REG_CAP         (0x00)
#define REG_VS          (0x08)
#define REG_CC          (0x14)
#define REG_CSTS        (0x1c)
#define REG_AQA         (0x24)
#define REG_ASQ         (0x28)
#define REG_ACQ         (0x30)

#define NVME_REG_READ(base, offset) (*(volatile uint32_t *)((base) + (offset)))
#define NVME_REG_WRITE(base, offset, val) (*(volatile uint32_t *)((base) + (offset)) = val)

typedef struct msix_entry {
    uint32_t msg_addr_low;   // [0x00] 中断消息地址低32位
    uint32_t msg_addr_high;  // [0x04] 中断消息地址高32位
    uint32_t msg_data;       // [0x08] 中断消息数据（发送给LAPIC的向量号等）
    uint32_t vector_ctrl;    // [0x0C] 控制字段，bit0为Mask
} msix_entry_t;

struct nvme_admin_command {
    uint8_t  opc;        // 0x06 for Identify
    uint8_t  fuse;
    uint16_t cid;        // Command ID
    uint32_t nsid;       // Namespace ID = 0
    uint64_t rsvd2;
    uint64_t mptr;
    uint64_t prp1;       // PRP pointer to DMA buffer
    uint64_t prp2;
    uint32_t cns;        // [10:00] CNS = 1 for controller
    uint32_t rsvd[5];
};

typedef struct {
    uint32_t    result;       // DW0: command-specific result (e.g., Identify data offset)
    uint32_t    reserved;     // DW1: usually reserved
    uint16_t    sq_head;      // DW2: SQ Head Pointer
    uint16_t    sq_id;        // DW2: SQ Identifier
    uint16_t    cid;          // DW3: Command Identifier (to match with submission)
    uint16_t    status;       // DW3: Status Field (includes phase tag)
} __attribute__((packed)) nvme_cpl_t;

int nvme_init();
u32 nvme_read(u32 offset);
void nvme_write(u32 offset, u32 val);


#endif