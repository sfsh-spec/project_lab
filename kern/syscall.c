/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U|PTE_P);
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	cprintf("-----getenvid----- 0x%x\n", (u32)curenv);
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	env_destroy(e);
	return 0;
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *new;
	int ret = env_alloc(&new, curenv->env_id);
	cprintf("env alloc ret: %d\n", ret);
	if (ret < 0)
		return ret;
	new->env_status = ENV_NOT_RUNNABLE;
	new->env_tf = curenv->env_tf; //
	new->env_tf.tf_regs.reg_eax = 0; //for child, set appeared return value to 0
	cprintf("new env id: 0x%x\n", new->env_id);
	return new->env_id;

	// panic("sys_exofork not implemented");
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
	struct Env *e;
	int ret = envid2env(envid, &e, 1);
	if (ret != 0)
		return -E_BAD_ENV;
	e->env_status = status;
	return 0;
	
	// panic("sys_env_set_status not implemented");
}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *store;
	if (envid2env(envid, &store, 1) != 0)
		return -E_BAD_ENV;
	store->env_pgfault_upcall = func;
	return 0;
	// panic("sys_env_set_pgfault_upcall not implemented");
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.  See PTE_SYSCALL in inc/mmu.h.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	// cprintf("page alloc perm: 0x%x\n", perm);
	if ((u32)va >= UTOP || (u32)va % PGSIZE != 0)
		return -E_INVAL;
	if ((perm & PTE_P) == 0 || (perm & PTE_U) == 0)
		return -E_INVAL;
	if ((perm & (~PTE_SYSCALL)) != 0)
		return -E_INVAL;

	struct Env *store;
	if (envid2env(envid, &store, 1) != 0)
		return -E_BAD_ENV;
	struct PageInfo *new = page_alloc(ALLOC_ZERO);
	if (new == NULL)
		return -E_NO_MEM;
	// cprintf("sys page alloc: 0x%x\n", page2pa(new));
	int ret = page_insert(store->env_pgdir, new, va, perm);
	if (ret != 0)
	{
		page_free(new);
		return -E_NO_MEM;
	}
	return 0;
	// panic("sys_page_alloc not implemented");
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	u32 s_va = (u32)srcva;
	u32 d_va = (u32)dstva;
	if (s_va % PGSIZE != 0 || d_va % PGSIZE != 0)
		return -E_INVAL;
	if (s_va >= UTOP || d_va >= UTOP)
		return -E_INVAL;

	struct Env *s_store;
	struct Env *d_store;
	if (envid2env(srcenvid, &s_store, 1) != 0 || envid2env(dstenvid, &d_store, 1) != 0)
		return -E_BAD_ENV;

	pte_t *pte_store;
	if (page_lookup(s_store->env_pgdir, srcva, &pte_store) == NULL)
		return -E_INVAL;
	u32 write = *pte_store & PTE_W;
	if ((perm & PTE_W) && (write == 0))
		return -E_INVAL;

	if ((perm & PTE_P) == 0 ||(perm & PTE_U) == 0)
		return -E_INVAL;
	if ((perm & (~PTE_SYSCALL)) != 0)
		return -E_INVAL;
	// void *kva = (void *)*pte_store;
	// cprintf("sys page map. pte_store: 0x%x\n", (u32)pte_store);
	int ret = page_insert(d_store->env_pgdir, pa2page(*pte_store), dstva, perm);
	if (ret != 0)
		return -E_NO_MEM;
	
	return 0;
	// panic("sys_page_map not implemented");
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if ((u32)va >= UTOP || (u32)va % PGSIZE != 0)
		return -E_INVAL;
	struct Env *store;
	if (envid2env(envid, &store, 1) != 0)
		return -E_BAD_ENV;
	page_remove(store->env_pgdir, va);

	return 0;
	// panic("sys_page_unmap not implemented");
}

// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	struct Env *store;
	int res = envid2env(envid, &store, 0);
	if (res < 0)
		return -E_BAD_ENV;
	if (store->env_ipc_recving == false)
		return -E_IPC_NOT_RECV;
	// cprintf("22222222\n");
	// if (store->env_ipc_from  != 0)
	// 	return -E_IPC_NOT_RECV;
	pte_t val; 
	store->env_ipc_perm = 0;
	void *dstva = store->env_ipc_dstva;
	if ((u32)dstva < UTOP)
	{
		if ((u32)srcva < UTOP)
		{
			if ((u32)srcva % PGSIZE != 0)
				return -E_INVAL;

			pte_t *entry = pgdir_walk(curenv->env_pgdir, srcva, 0);
			if (entry == NULL)
			{
				return -E_INVAL;
			}
			else	
			{
				u32 w = perm & PTE_W;
				val = *entry;
				// cprintf("val 0x%x\n", val);
				if ((val & PTE_W) == 0 && (perm & PTE_W) != 0)
					return -E_INVAL;
				if ((val & PTE_U) == 0)	
					return -E_INVAL;
				if (((val & 0xf0f) & (~PTE_SYSCALL)) != 0)
					return -E_INVAL;
			}
			struct PageInfo *pp = pa2page(val);
			int ret = page_insert(store->env_pgdir, pp, dstva, perm);
			if (ret < 0)
				return -E_NO_MEM;
			store->env_ipc_perm = perm;
		}
	}
	store->env_ipc_value = value;
	store->env_ipc_from = curenv->env_id;
	store->env_ipc_recving = false;
	store->env_status = ENV_RUNNABLE;
	// store->env_tf.tf_regs.reg_eax = 0;
	// curenv->env_tf.tf_regs.reg_eax = 0;
	return 0;
	//panic("sys_ipc_try_send not implemented");
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	curenv->env_ipc_recving = true;
	curenv->env_ipc_dstva = dstva;
	curenv->env_status = ENV_NOT_RUNNABLE;
	if ((u32)dstva < UTOP)
	{
		if ( (u32)dstva % PGSIZE != 0)
			return -E_INVAL;
	}

	curenv->env_ipc_dstva = dstva;
	curenv->env_tf.tf_regs.reg_eax = 0;
	return 0;
	// panic("sys_ipc_recv not implemented");
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");
	// cprintf("a1: 0x%x a2:0x%x a3: 0x%x a4: 0x%x a5: 0x%x\n", a1, a2, a3, a4, a5);
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((const char*)a1, a2);
			return 0;
		
		case SYS_cgetc:
			return sys_cgetc();

		case SYS_getenvid:
			return sys_getenvid();

		case SYS_env_destroy:
			return sys_env_destroy(a1);

		case SYS_yield:
			sys_yield();
			return 0;

		case SYS_exofork:
			int ret1 = sys_exofork();
			//  cprintf("~~~~~exofork return: 0x%x\n", ret1);
			return ret1;

		case SYS_page_alloc:
			int ret2 = sys_page_alloc(a1, (void*)a2, (int)a3);
			// cprintf("~~~~~page alloc return: %d\n", ret2);
			return ret2;

		case SYS_page_map:
			int ret = sys_page_map(a1, (void*)a2, a3, (void*)a4, (int)a5);
			// cprintf("~~~~~page map return: %d\n", ret);
			return ret;

		case SYS_page_unmap:
			int ret3 = sys_page_unmap(a1, (void*)a2);
			// cprintf("~~~~~page ummap return: %d\n", ret3);
			return ret3;

		case SYS_env_set_status:
			int ret4 = sys_env_set_status(a1, (int)a2);
			// cprintf("~~~~~env set status return: %d\n", ret4);
			return ret4;
		
		case SYS_env_set_pgfault_upcall:
			int ret5 = sys_env_set_pgfault_upcall(a1, (void*)a2);
			// cprintf("~~~~~env set pgfault upcall return: %d\n", ret5);
			return ret5;

		case SYS_ipc_try_send:
			int ret6 = sys_ipc_try_send(a1, a2, (void*)a3, a4);
			cprintf("~~~~~ipc try send return: %d\n", ret6);
			return ret6;

		case SYS_ipc_recv:
			int ret7 = sys_ipc_recv((void*)a1);
			cprintf("~~~~~ipc recv return: %d\n", ret7);
			return ret7;

		default:
			return -E_INVAL;
	}
}

