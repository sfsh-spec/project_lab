// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>
#include <kern/trap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line
#define V_CMD_TOTAL   128
#define VM  1
struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "backtrace function call information", mon_backtrace},
	{ "v", "test", v_cmd_exc},
};

struct v_command {
	const char *name;
	const char *desc;
	int (*func)();
	int para_cnt;
};

static struct v_command vcmd_group[V_CMD_TOTAL] = {
	{
		"test",
		"test",
		test_cmd,
		2,
	},
	{
		"map",
		"show mappings",
		show_mappings,
		2,
	},
	{
		"chpm",
		"change permission",
		change_permission,
		2,
	},
	{
		"vmdump",
		"dump virtual memory",
		virtual_memeory_dump,
		2,
	},
	{
		"pmdump",
		"dump physical memory",
		physical_memory_dump,
		2,
	},
	{
		"pfl",
		"get page free list",
		get_page_free_list,
		0,
	}
};
static int vcmd_num = sizeof(vcmd_group) / sizeof(vcmd_group[0]);
struct Eipdebuginfo eipinfo;
/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	int ebp_val;
	int eip_val;
	ebp_val = read_ebp();
	
	int *ebp_ptr = (int*)ebp_val;
	cprintf("Stack backtrace:\n");
	do
	{
		ebp_val = *ebp_ptr;
		eip_val = *(ebp_ptr+1);
		debuginfo_eip(eip_val, &eipinfo);
		cprintf("ebp %08x eip %08x  ", ebp_val, eip_val);
		cprintf("args %08x", *(ebp_ptr+2));
		cprintf(" %08x", *(ebp_ptr+3));
		cprintf(" %08x", *(ebp_ptr+4));
		cprintf(" %08x", *(ebp_ptr+5));
		cprintf(" %08x\n", *(ebp_ptr+6));
		cprintf("%s:%d: ", eipinfo.eip_file, eipinfo.eip_line);
		cprintf("%.*s", eipinfo.eip_fn_namelen, eipinfo.eip_fn_name);
		cprintf("+%d\n",-eipinfo.eip_fn_addr + eip_val);
		ebp_ptr = (int*)(*ebp_ptr);
	}while(ebp_ptr != NULL);
	return 0;
}



/*******************My Debug Command********************/

int test_cmd(int a, int b)
{
	cprintf("a+b=%d\n", a+b);
	return 0;
}


int show_mappings(u32 va_begin, u32 va_end)
{
	//u32 *vaddr = (u32 *)va_begin;
	cprintf("vaddr       paddr       [AVA][//][D][A][//][U][W][P]\n");
	for (u32 vaddr = va_begin; vaddr <= va_end; vaddr = vaddr + PGSIZE)
	{
		pte_t *t_entry = pgdir_walk(kern_pgdir, (u32 *)vaddr, false);
		if (t_entry)
		{
			u32 val = *t_entry;
			if (*t_entry & PTE_P)
			{
				cprintf("0x%08x  0x%08x", vaddr, val & 0xfffff000);
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
				BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
				BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
				BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
			}
			else
			{
				cprintf("0x%x  none pte\n", vaddr);
			}
		}
		else
			cprintf("0x%x  none pde\n", vaddr);
	}
	return 0;
}

int change_permission(u32 va, u32 aut)
{
	va = va & 0xfffff000;
	cprintf("before change\n");
	show_mappings(va, va);

	pte_t *t_entry = pgdir_walk(kern_pgdir, (u32 *)va, false);
	if (t_entry)
	{
		if (*t_entry & PTE_P)
		{
			cprintf("after change\n");
			int temp = (aut << 1) & 0x6;
			*t_entry = (*t_entry & ~0x6) | temp;
			u32 val = *t_entry;
			cprintf("0x%08x  0x%08x", va, val & 0xfffff000);
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
			BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
			BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
			BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
		}
		else
		{
			cprintf("0x%x  none pte\n", va);
		}
	}
	else
	{
		cprintf("0x%x  none pde\n", va);
	}
	return 0;
}

int virtual_memeory_dump(u32 addr, u32 len)
{
	int pg_cnt; 
	int t_start = ROUNDDOWN(addr, PGSIZE);
	int t_end = ROUNDUP(addr+len, PGSIZE);
	pg_cnt = (t_end - t_start) / PGSIZE;
	for (int i = 0; i < pg_cnt; i++)
	{
		pte_t *entry = pgdir_walk(kern_pgdir, (char*)(addr + PGSIZE * i), false);
		if (!entry)
		{
			cprintf("page table for vitual address 0x%x does not exist!\n", addr + PGSIZE * i);
			return -1;
		}
		else
		{
			if ((*entry & PTE_P) == 0)
			{
				cprintf("physical map page for vitual address 0x%x does not exist!\n", addr + PGSIZE * i);
				return -1;
			}
		}
	}
	u32 *ptr = (u32 *)addr;
	// cprintf("0x%08x:  ", addr);
	for (int i = 0; i< ROUNDUP(len, sizeof(u32))/sizeof(u32); i++)
	{
		if (i % 4 == 0)
		{
				cprintf("0x%08x:  ", addr + i * sizeof(u32));
		}
		cprintf("0x%08x  ", *(ptr+i));
		if ((i+1) % 4 == 0 && i != 0)
			cprintf("\n");
	}
	cprintf("\n");
	return 0;
}

int physical_memory_dump(u32 paddr, u32 len)
{
	u32 vaddr = paddr + KERNBASE;
	int ret = virtual_memeory_dump(vaddr, len);
	return ret;
}


int in_page_dump(u32 addr, u32 len)
{
	return 0;
}

int get_page_free_list()
{
	cprintf("page free list: 0x%x\n", free_list_debug);
	return 0;
}

/***************************************************/
/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16



static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

int v_cmd_exc(int argc, char **argv, struct Trapframe *tf)
{
	int para[10] = {0};
	if (argc < 2)
	{
		cprintf("sub command name expected\n");
		return -1;
	}
	char *subfunc = argv[1];
	for (int i = 0; i < vcmd_num; i++)
	{
		if (!strcmp(subfunc, vcmd_group[i].name))
		{
			if (argc-2 != vcmd_group[i].para_cnt)
			{
				cprintf("expect %d parameters\n", vcmd_group[i].para_cnt);
				return -1;
			}
			else
			{
				for (int i = 2; i< argc; i++)
					para[i-1] = string2value(argv[i]);

				typedef int (*func9)(int p1, int p2, int p3, int p4, 
					int p5, int p6, int p7, int p8, int p9);
				func9 func = (func9)vcmd_group[i].func;
				func(para[1], para[2], para[3], para[4], para[5],
					para[6], para[7], para[8], para[9]);
				return 0;
			}
		}

	}
	cprintf("command not found!\n");

	return 0;	
}

int string2value(char* str)
{
	char *p = str;
	int hex = 0;
	int temp_val = 0;
	int sum = 0;
	if (*p == '0')
	{
		if (*(p+1) == 0)
			return 0;
		else if (*(p+1) == 'x')
			hex = 1;
		else
			return -1;
		p += 2;
	}
	if (hex)
	{
		while(*p)
		{
			temp_val = *p - '0';
			if (temp_val >= 0 && temp_val<= 9)
				sum = sum * 16 + temp_val;
			else if (temp_val >= 49 && temp_val <= 54)
				sum = sum * 16 + temp_val - 39;
			else 
				return -1;
			p++;
		}
	}
	else
	{
		while(*p)
		{
			//cprintf("ptr %d\n", *p);
			temp_val = *p - '0';
			//cprintf("temp %d\n", temp_val);
			if (temp_val >= 0 && temp_val <= 9)
				sum = sum * 10 + temp_val;
			else
				return -1;
			p++;
		}
	} 
	return sum;
}
void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");
	char str[] = "0xabcd";
	int a = string2value(str);
	cprintf("test: %d %x\n", a, a);

	while (1)
	{
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}

