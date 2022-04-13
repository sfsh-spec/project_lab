#ifndef JOS_KERN_MONITOR_H
#define JOS_KERN_MONITOR_H
#ifndef JOS_KERNEL
# error "This is a JOS kernel header; user programs should not #include it"
#endif

struct Trapframe;

// Activate the kernel monitor,
// optionally providing a trap frame indicating the current state
// (NULL if none).
void monitor(struct Trapframe *tf);

// Functions implementing monitor commands.
int mon_help(int argc, char **argv, struct Trapframe *tf);
int mon_kerninfo(int argc, char **argv, struct Trapframe *tf);
int mon_backtrace(int argc, char **argv, struct Trapframe *tf);

int v_cmd_exc(int argc, char **argv, struct Trapframe *tf);
int string2value(char* str);

//my debug commands
int show_mappings(u32 va_begin, u32 va_end);
int change_permission(u32 va, u32 aut);
int virtual_memeory_dump(u32 addr, u32 len);
int physical_memory_dump(u32 paddr, u32 len);
int test_cmd(int a, int b);
int get_page_free_list();
#endif	// !JOS_KERN_MONITOR_H
