#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
	struct Env *idle;

	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	idle = thiscpu->cpu_env;
	cprintf("sched start\n");
	cprintf("CPU: %d,  idle: 0x%x\n",cpunum(), (u32)(idle));
	struct Env *temp = envs;
	if (idle == NULL)
	{
		// temp = envs;
		int i = 0;
		for (i = 0; i<NENV; i++)
		{
			// cprintf("status: 0x%x",(u32)((temp+i)->env_status));
			if ((temp+i)->env_status == ENV_RUNNABLE)
			{
				cprintf("-----env %d\n", i);
				env_run(temp+i);
				break;
			}
		}
	}
	else
	{
		for (temp = idle+1; temp < envs+NENV; temp++)
			if (temp->env_status == ENV_RUNNABLE)
			{	
				cprintf("*****selected env: 0x%x\n", (u32)temp);
				env_run(temp);
				return;
			}

		for (temp = envs; temp < idle; temp++)
			if (temp->env_status == ENV_RUNNABLE)
			{	
				cprintf("*****selected env: 0x%x\n", (u32)temp);
				env_run(temp);
				return;
			}
		
		if (temp == idle)
		{
			if (temp->env_status == ENV_RUNNING)
				env_run(temp);
		}
	}
	// sched_halt never returns
	cprintf("gogogo\n");
	sched_halt();
}

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	cprintf("iiii: %d\n", i);
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
		"movl $0, %%ebp\n"
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}

