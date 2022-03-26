
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 18 00       	mov    $0x181000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 c0 11 f0       	mov    $0xf011c000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 45 01 00 00       	call   f0100191 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 1c 08 08 00    	add    $0x8081c,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 40 38 18 f0    	mov    $0xf0183840,%eax
f0100058:	c7 c2 00 29 18 f0    	mov    $0xf0182900,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 ac 52 00 00       	call   f0105315 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 79 05 00 00       	call   f01005e7 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 f8 4e f8 ff    	lea    -0x7b108(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 96 42 00 00       	call   f0104318 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 c7 1a 00 00       	call   f0101b4e <mem_init>
	// cprintf("why is make warning\n");
	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 36 3a 00 00       	call   f0103ac2 <env_init>
	cprintf("env init done\n");
f010008c:	8d 83 13 4f f8 ff    	lea    -0x7b0ed(%ebx),%eax
f0100092:	89 04 24             	mov    %eax,(%esp)
f0100095:	e8 7e 42 00 00       	call   f0104318 <cprintf>
	trap_init();
f010009a:	e8 2c 43 00 00       	call   f01043cb <trap_init>
	cprintf("trap init done\n");
f010009f:	8d 83 22 4f f8 ff    	lea    -0x7b0de(%ebx),%eax
f01000a5:	89 04 24             	mov    %eax,(%esp)
f01000a8:	e8 6b 42 00 00       	call   f0104318 <cprintf>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f01000ad:	83 c4 08             	add    $0x8,%esp
f01000b0:	6a 00                	push   $0x0
f01000b2:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f01000b8:	e8 ab 3c 00 00       	call   f0103d68 <env_create>
#endif // TEST*

	cprintf("env run \n");
f01000bd:	8d 83 32 4f f8 ff    	lea    -0x7b0ce(%ebx),%eax
f01000c3:	89 04 24             	mov    %eax,(%esp)
f01000c6:	e8 4d 42 00 00       	call   f0104318 <cprintf>
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000cb:	83 c4 04             	add    $0x4,%esp
f01000ce:	c7 c0 88 2b 18 f0    	mov    $0xf0182b88,%eax
f01000d4:	ff 30                	push   (%eax)
f01000d6:	e8 37 41 00 00       	call   f0104212 <env_run>

f01000db <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000db:	55                   	push   %ebp
f01000dc:	89 e5                	mov    %esp,%ebp
f01000de:	56                   	push   %esi
f01000df:	53                   	push   %ebx
f01000e0:	e8 ac 00 00 00       	call   f0100191 <__x86.get_pc_thunk.bx>
f01000e5:	81 c3 83 07 08 00    	add    $0x80783,%ebx
	va_list ap;

	if (panicstr)
f01000eb:	83 bb 98 20 00 00 00 	cmpl   $0x0,0x2098(%ebx)
f01000f2:	74 0f                	je     f0100103 <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000f4:	83 ec 0c             	sub    $0xc,%esp
f01000f7:	6a 00                	push   $0x0
f01000f9:	e8 68 0e 00 00       	call   f0100f66 <monitor>
f01000fe:	83 c4 10             	add    $0x10,%esp
f0100101:	eb f1                	jmp    f01000f4 <_panic+0x19>
	panicstr = fmt;
f0100103:	8b 45 10             	mov    0x10(%ebp),%eax
f0100106:	89 83 98 20 00 00    	mov    %eax,0x2098(%ebx)
	asm volatile("cli; cld");
f010010c:	fa                   	cli    
f010010d:	fc                   	cld    
	va_start(ap, fmt);
f010010e:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100111:	83 ec 04             	sub    $0x4,%esp
f0100114:	ff 75 0c             	push   0xc(%ebp)
f0100117:	ff 75 08             	push   0x8(%ebp)
f010011a:	8d 83 3c 4f f8 ff    	lea    -0x7b0c4(%ebx),%eax
f0100120:	50                   	push   %eax
f0100121:	e8 f2 41 00 00       	call   f0104318 <cprintf>
	vcprintf(fmt, ap);
f0100126:	83 c4 08             	add    $0x8,%esp
f0100129:	56                   	push   %esi
f010012a:	ff 75 10             	push   0x10(%ebp)
f010012d:	e8 af 41 00 00       	call   f01042e1 <vcprintf>
	cprintf("\n");
f0100132:	8d 83 3a 4f f8 ff    	lea    -0x7b0c6(%ebx),%eax
f0100138:	89 04 24             	mov    %eax,(%esp)
f010013b:	e8 d8 41 00 00       	call   f0104318 <cprintf>
f0100140:	83 c4 10             	add    $0x10,%esp
f0100143:	eb af                	jmp    f01000f4 <_panic+0x19>

f0100145 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100145:	55                   	push   %ebp
f0100146:	89 e5                	mov    %esp,%ebp
f0100148:	56                   	push   %esi
f0100149:	53                   	push   %ebx
f010014a:	e8 42 00 00 00       	call   f0100191 <__x86.get_pc_thunk.bx>
f010014f:	81 c3 19 07 08 00    	add    $0x80719,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100155:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100158:	83 ec 04             	sub    $0x4,%esp
f010015b:	ff 75 0c             	push   0xc(%ebp)
f010015e:	ff 75 08             	push   0x8(%ebp)
f0100161:	8d 83 54 4f f8 ff    	lea    -0x7b0ac(%ebx),%eax
f0100167:	50                   	push   %eax
f0100168:	e8 ab 41 00 00       	call   f0104318 <cprintf>
	vcprintf(fmt, ap);
f010016d:	83 c4 08             	add    $0x8,%esp
f0100170:	56                   	push   %esi
f0100171:	ff 75 10             	push   0x10(%ebp)
f0100174:	e8 68 41 00 00       	call   f01042e1 <vcprintf>
	cprintf("\n");
f0100179:	8d 83 3a 4f f8 ff    	lea    -0x7b0c6(%ebx),%eax
f010017f:	89 04 24             	mov    %eax,(%esp)
f0100182:	e8 91 41 00 00       	call   f0104318 <cprintf>
	va_end(ap);
}
f0100187:	83 c4 10             	add    $0x10,%esp
f010018a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010018d:	5b                   	pop    %ebx
f010018e:	5e                   	pop    %esi
f010018f:	5d                   	pop    %ebp
f0100190:	c3                   	ret    

f0100191 <__x86.get_pc_thunk.bx>:
f0100191:	8b 1c 24             	mov    (%esp),%ebx
f0100194:	c3                   	ret    

f0100195 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100195:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010019a:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010019b:	a8 01                	test   $0x1,%al
f010019d:	74 0a                	je     f01001a9 <serial_proc_data+0x14>
f010019f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001a4:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001a5:	0f b6 c0             	movzbl %al,%eax
f01001a8:	c3                   	ret    
		return -1;
f01001a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001ae:	c3                   	ret    

f01001af <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001af:	55                   	push   %ebp
f01001b0:	89 e5                	mov    %esp,%ebp
f01001b2:	57                   	push   %edi
f01001b3:	56                   	push   %esi
f01001b4:	53                   	push   %ebx
f01001b5:	83 ec 1c             	sub    $0x1c,%esp
f01001b8:	e8 6a 05 00 00       	call   f0100727 <__x86.get_pc_thunk.si>
f01001bd:	81 c6 ab 06 08 00    	add    $0x806ab,%esi
f01001c3:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001c5:	8d 1d d8 20 00 00    	lea    0x20d8,%ebx
f01001cb:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001d1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001d4:	eb 25                	jmp    f01001fb <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f01001d6:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f01001dd:	8d 51 01             	lea    0x1(%ecx),%edx
f01001e0:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01001e3:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001e6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01001ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01001f1:	0f 44 d0             	cmove  %eax,%edx
f01001f4:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f01001fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01001fe:	ff d0                	call   *%eax
f0100200:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100203:	74 06                	je     f010020b <cons_intr+0x5c>
		if (c == 0)
f0100205:	85 c0                	test   %eax,%eax
f0100207:	75 cd                	jne    f01001d6 <cons_intr+0x27>
f0100209:	eb f0                	jmp    f01001fb <cons_intr+0x4c>
	}
}
f010020b:	83 c4 1c             	add    $0x1c,%esp
f010020e:	5b                   	pop    %ebx
f010020f:	5e                   	pop    %esi
f0100210:	5f                   	pop    %edi
f0100211:	5d                   	pop    %ebp
f0100212:	c3                   	ret    

f0100213 <kbd_proc_data>:
{
f0100213:	55                   	push   %ebp
f0100214:	89 e5                	mov    %esp,%ebp
f0100216:	56                   	push   %esi
f0100217:	53                   	push   %ebx
f0100218:	e8 74 ff ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f010021d:	81 c3 4b 06 08 00    	add    $0x8064b,%ebx
f0100223:	ba 64 00 00 00       	mov    $0x64,%edx
f0100228:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100229:	a8 01                	test   $0x1,%al
f010022b:	0f 84 f7 00 00 00    	je     f0100328 <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f0100231:	a8 20                	test   $0x20,%al
f0100233:	0f 85 f6 00 00 00    	jne    f010032f <kbd_proc_data+0x11c>
f0100239:	ba 60 00 00 00       	mov    $0x60,%edx
f010023e:	ec                   	in     (%dx),%al
f010023f:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100241:	3c e0                	cmp    $0xe0,%al
f0100243:	74 64                	je     f01002a9 <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f0100245:	84 c0                	test   %al,%al
f0100247:	78 75                	js     f01002be <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f0100249:	8b 8b b8 20 00 00    	mov    0x20b8(%ebx),%ecx
f010024f:	f6 c1 40             	test   $0x40,%cl
f0100252:	74 0e                	je     f0100262 <kbd_proc_data+0x4f>
		data |= 0x80;
f0100254:	83 c8 80             	or     $0xffffff80,%eax
f0100257:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100259:	83 e1 bf             	and    $0xffffffbf,%ecx
f010025c:	89 8b b8 20 00 00    	mov    %ecx,0x20b8(%ebx)
	shift |= shiftcode[data];
f0100262:	0f b6 d2             	movzbl %dl,%edx
f0100265:	0f b6 84 13 98 50 f8 	movzbl -0x7af68(%ebx,%edx,1),%eax
f010026c:	ff 
f010026d:	0b 83 b8 20 00 00    	or     0x20b8(%ebx),%eax
	shift ^= togglecode[data];
f0100273:	0f b6 8c 13 98 4f f8 	movzbl -0x7b068(%ebx,%edx,1),%ecx
f010027a:	ff 
f010027b:	31 c8                	xor    %ecx,%eax
f010027d:	89 83 b8 20 00 00    	mov    %eax,0x20b8(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100283:	89 c1                	mov    %eax,%ecx
f0100285:	83 e1 03             	and    $0x3,%ecx
f0100288:	8b 8c 8b b8 17 00 00 	mov    0x17b8(%ebx,%ecx,4),%ecx
f010028f:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100293:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f0100296:	a8 08                	test   $0x8,%al
f0100298:	74 61                	je     f01002fb <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f010029a:	89 f2                	mov    %esi,%edx
f010029c:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f010029f:	83 f9 19             	cmp    $0x19,%ecx
f01002a2:	77 4b                	ja     f01002ef <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f01002a4:	83 ee 20             	sub    $0x20,%esi
f01002a7:	eb 0c                	jmp    f01002b5 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002a9:	83 8b b8 20 00 00 40 	orl    $0x40,0x20b8(%ebx)
		return 0;
f01002b0:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002b5:	89 f0                	mov    %esi,%eax
f01002b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002ba:	5b                   	pop    %ebx
f01002bb:	5e                   	pop    %esi
f01002bc:	5d                   	pop    %ebp
f01002bd:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002be:	8b 8b b8 20 00 00    	mov    0x20b8(%ebx),%ecx
f01002c4:	83 e0 7f             	and    $0x7f,%eax
f01002c7:	f6 c1 40             	test   $0x40,%cl
f01002ca:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002cd:	0f b6 d2             	movzbl %dl,%edx
f01002d0:	0f b6 84 13 98 50 f8 	movzbl -0x7af68(%ebx,%edx,1),%eax
f01002d7:	ff 
f01002d8:	83 c8 40             	or     $0x40,%eax
f01002db:	0f b6 c0             	movzbl %al,%eax
f01002de:	f7 d0                	not    %eax
f01002e0:	21 c8                	and    %ecx,%eax
f01002e2:	89 83 b8 20 00 00    	mov    %eax,0x20b8(%ebx)
		return 0;
f01002e8:	be 00 00 00 00       	mov    $0x0,%esi
f01002ed:	eb c6                	jmp    f01002b5 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f01002ef:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002f2:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002f5:	83 fa 1a             	cmp    $0x1a,%edx
f01002f8:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002fb:	f7 d0                	not    %eax
f01002fd:	a8 06                	test   $0x6,%al
f01002ff:	75 b4                	jne    f01002b5 <kbd_proc_data+0xa2>
f0100301:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100307:	75 ac                	jne    f01002b5 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f0100309:	83 ec 0c             	sub    $0xc,%esp
f010030c:	8d 83 6e 4f f8 ff    	lea    -0x7b092(%ebx),%eax
f0100312:	50                   	push   %eax
f0100313:	e8 00 40 00 00       	call   f0104318 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100318:	b8 03 00 00 00       	mov    $0x3,%eax
f010031d:	ba 92 00 00 00       	mov    $0x92,%edx
f0100322:	ee                   	out    %al,(%dx)
}
f0100323:	83 c4 10             	add    $0x10,%esp
f0100326:	eb 8d                	jmp    f01002b5 <kbd_proc_data+0xa2>
		return -1;
f0100328:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010032d:	eb 86                	jmp    f01002b5 <kbd_proc_data+0xa2>
		return -1;
f010032f:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100334:	e9 7c ff ff ff       	jmp    f01002b5 <kbd_proc_data+0xa2>

f0100339 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100339:	55                   	push   %ebp
f010033a:	89 e5                	mov    %esp,%ebp
f010033c:	57                   	push   %edi
f010033d:	56                   	push   %esi
f010033e:	53                   	push   %ebx
f010033f:	83 ec 1c             	sub    $0x1c,%esp
f0100342:	e8 4a fe ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0100347:	81 c3 21 05 08 00    	add    $0x80521,%ebx
f010034d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100350:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100355:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010035a:	b9 84 00 00 00       	mov    $0x84,%ecx
f010035f:	89 fa                	mov    %edi,%edx
f0100361:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100362:	a8 20                	test   $0x20,%al
f0100364:	75 13                	jne    f0100379 <cons_putc+0x40>
f0100366:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010036c:	7f 0b                	jg     f0100379 <cons_putc+0x40>
f010036e:	89 ca                	mov    %ecx,%edx
f0100370:	ec                   	in     (%dx),%al
f0100371:	ec                   	in     (%dx),%al
f0100372:	ec                   	in     (%dx),%al
f0100373:	ec                   	in     (%dx),%al
	     i++)
f0100374:	83 c6 01             	add    $0x1,%esi
f0100377:	eb e6                	jmp    f010035f <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f0100379:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f010037d:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100380:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100385:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100386:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010038b:	bf 79 03 00 00       	mov    $0x379,%edi
f0100390:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100395:	89 fa                	mov    %edi,%edx
f0100397:	ec                   	in     (%dx),%al
f0100398:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010039e:	7f 0f                	jg     f01003af <cons_putc+0x76>
f01003a0:	84 c0                	test   %al,%al
f01003a2:	78 0b                	js     f01003af <cons_putc+0x76>
f01003a4:	89 ca                	mov    %ecx,%edx
f01003a6:	ec                   	in     (%dx),%al
f01003a7:	ec                   	in     (%dx),%al
f01003a8:	ec                   	in     (%dx),%al
f01003a9:	ec                   	in     (%dx),%al
f01003aa:	83 c6 01             	add    $0x1,%esi
f01003ad:	eb e6                	jmp    f0100395 <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003af:	ba 78 03 00 00       	mov    $0x378,%edx
f01003b4:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003b8:	ee                   	out    %al,(%dx)
f01003b9:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003be:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003c3:	ee                   	out    %al,(%dx)
f01003c4:	b8 08 00 00 00       	mov    $0x8,%eax
f01003c9:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003cd:	89 f8                	mov    %edi,%eax
f01003cf:	80 cc 07             	or     $0x7,%ah
f01003d2:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003d8:	0f 45 c7             	cmovne %edi,%eax
f01003db:	89 c7                	mov    %eax,%edi
f01003dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003e0:	0f b6 c0             	movzbl %al,%eax
f01003e3:	89 f9                	mov    %edi,%ecx
f01003e5:	80 f9 0a             	cmp    $0xa,%cl
f01003e8:	0f 84 e4 00 00 00    	je     f01004d2 <cons_putc+0x199>
f01003ee:	83 f8 0a             	cmp    $0xa,%eax
f01003f1:	7f 46                	jg     f0100439 <cons_putc+0x100>
f01003f3:	83 f8 08             	cmp    $0x8,%eax
f01003f6:	0f 84 a8 00 00 00    	je     f01004a4 <cons_putc+0x16b>
f01003fc:	83 f8 09             	cmp    $0x9,%eax
f01003ff:	0f 85 da 00 00 00    	jne    f01004df <cons_putc+0x1a6>
		cons_putc(' ');
f0100405:	b8 20 00 00 00       	mov    $0x20,%eax
f010040a:	e8 2a ff ff ff       	call   f0100339 <cons_putc>
		cons_putc(' ');
f010040f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100414:	e8 20 ff ff ff       	call   f0100339 <cons_putc>
		cons_putc(' ');
f0100419:	b8 20 00 00 00       	mov    $0x20,%eax
f010041e:	e8 16 ff ff ff       	call   f0100339 <cons_putc>
		cons_putc(' ');
f0100423:	b8 20 00 00 00       	mov    $0x20,%eax
f0100428:	e8 0c ff ff ff       	call   f0100339 <cons_putc>
		cons_putc(' ');
f010042d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100432:	e8 02 ff ff ff       	call   f0100339 <cons_putc>
		break;
f0100437:	eb 26                	jmp    f010045f <cons_putc+0x126>
	switch (c & 0xff) {
f0100439:	83 f8 0d             	cmp    $0xd,%eax
f010043c:	0f 85 9d 00 00 00    	jne    f01004df <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100442:	0f b7 83 e0 22 00 00 	movzwl 0x22e0(%ebx),%eax
f0100449:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010044f:	c1 e8 16             	shr    $0x16,%eax
f0100452:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100455:	c1 e0 04             	shl    $0x4,%eax
f0100458:	66 89 83 e0 22 00 00 	mov    %ax,0x22e0(%ebx)
	if (crt_pos >= CRT_SIZE) {
f010045f:	66 81 bb e0 22 00 00 	cmpw   $0x7cf,0x22e0(%ebx)
f0100466:	cf 07 
f0100468:	0f 87 98 00 00 00    	ja     f0100506 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f010046e:	8b 8b e8 22 00 00    	mov    0x22e8(%ebx),%ecx
f0100474:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100479:	89 ca                	mov    %ecx,%edx
f010047b:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010047c:	0f b7 9b e0 22 00 00 	movzwl 0x22e0(%ebx),%ebx
f0100483:	8d 71 01             	lea    0x1(%ecx),%esi
f0100486:	89 d8                	mov    %ebx,%eax
f0100488:	66 c1 e8 08          	shr    $0x8,%ax
f010048c:	89 f2                	mov    %esi,%edx
f010048e:	ee                   	out    %al,(%dx)
f010048f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100494:	89 ca                	mov    %ecx,%edx
f0100496:	ee                   	out    %al,(%dx)
f0100497:	89 d8                	mov    %ebx,%eax
f0100499:	89 f2                	mov    %esi,%edx
f010049b:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010049c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010049f:	5b                   	pop    %ebx
f01004a0:	5e                   	pop    %esi
f01004a1:	5f                   	pop    %edi
f01004a2:	5d                   	pop    %ebp
f01004a3:	c3                   	ret    
		if (crt_pos > 0) {
f01004a4:	0f b7 83 e0 22 00 00 	movzwl 0x22e0(%ebx),%eax
f01004ab:	66 85 c0             	test   %ax,%ax
f01004ae:	74 be                	je     f010046e <cons_putc+0x135>
			crt_pos--;
f01004b0:	83 e8 01             	sub    $0x1,%eax
f01004b3:	66 89 83 e0 22 00 00 	mov    %ax,0x22e0(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004ba:	0f b7 c0             	movzwl %ax,%eax
f01004bd:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004c1:	b2 00                	mov    $0x0,%dl
f01004c3:	83 ca 20             	or     $0x20,%edx
f01004c6:	8b 8b e4 22 00 00    	mov    0x22e4(%ebx),%ecx
f01004cc:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004d0:	eb 8d                	jmp    f010045f <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004d2:	66 83 83 e0 22 00 00 	addw   $0x50,0x22e0(%ebx)
f01004d9:	50 
f01004da:	e9 63 ff ff ff       	jmp    f0100442 <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004df:	0f b7 83 e0 22 00 00 	movzwl 0x22e0(%ebx),%eax
f01004e6:	8d 50 01             	lea    0x1(%eax),%edx
f01004e9:	66 89 93 e0 22 00 00 	mov    %dx,0x22e0(%ebx)
f01004f0:	0f b7 c0             	movzwl %ax,%eax
f01004f3:	8b 93 e4 22 00 00    	mov    0x22e4(%ebx),%edx
f01004f9:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004fd:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100501:	e9 59 ff ff ff       	jmp    f010045f <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100506:	8b 83 e4 22 00 00    	mov    0x22e4(%ebx),%eax
f010050c:	83 ec 04             	sub    $0x4,%esp
f010050f:	68 00 0f 00 00       	push   $0xf00
f0100514:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010051a:	52                   	push   %edx
f010051b:	50                   	push   %eax
f010051c:	e8 3a 4e 00 00       	call   f010535b <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100521:	8b 93 e4 22 00 00    	mov    0x22e4(%ebx),%edx
f0100527:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010052d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100533:	83 c4 10             	add    $0x10,%esp
f0100536:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010053b:	83 c0 02             	add    $0x2,%eax
f010053e:	39 d0                	cmp    %edx,%eax
f0100540:	75 f4                	jne    f0100536 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100542:	66 83 ab e0 22 00 00 	subw   $0x50,0x22e0(%ebx)
f0100549:	50 
f010054a:	e9 1f ff ff ff       	jmp    f010046e <cons_putc+0x135>

f010054f <serial_intr>:
{
f010054f:	e8 cf 01 00 00       	call   f0100723 <__x86.get_pc_thunk.ax>
f0100554:	05 14 03 08 00       	add    $0x80314,%eax
	if (serial_exists)
f0100559:	80 b8 ec 22 00 00 00 	cmpb   $0x0,0x22ec(%eax)
f0100560:	75 01                	jne    f0100563 <serial_intr+0x14>
f0100562:	c3                   	ret    
{
f0100563:	55                   	push   %ebp
f0100564:	89 e5                	mov    %esp,%ebp
f0100566:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100569:	8d 80 2d f9 f7 ff    	lea    -0x806d3(%eax),%eax
f010056f:	e8 3b fc ff ff       	call   f01001af <cons_intr>
}
f0100574:	c9                   	leave  
f0100575:	c3                   	ret    

f0100576 <kbd_intr>:
{
f0100576:	55                   	push   %ebp
f0100577:	89 e5                	mov    %esp,%ebp
f0100579:	83 ec 08             	sub    $0x8,%esp
f010057c:	e8 a2 01 00 00       	call   f0100723 <__x86.get_pc_thunk.ax>
f0100581:	05 e7 02 08 00       	add    $0x802e7,%eax
	cons_intr(kbd_proc_data);
f0100586:	8d 80 ab f9 f7 ff    	lea    -0x80655(%eax),%eax
f010058c:	e8 1e fc ff ff       	call   f01001af <cons_intr>
}
f0100591:	c9                   	leave  
f0100592:	c3                   	ret    

f0100593 <cons_getc>:
{
f0100593:	55                   	push   %ebp
f0100594:	89 e5                	mov    %esp,%ebp
f0100596:	53                   	push   %ebx
f0100597:	83 ec 04             	sub    $0x4,%esp
f010059a:	e8 f2 fb ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f010059f:	81 c3 c9 02 08 00    	add    $0x802c9,%ebx
	serial_intr();
f01005a5:	e8 a5 ff ff ff       	call   f010054f <serial_intr>
	kbd_intr();
f01005aa:	e8 c7 ff ff ff       	call   f0100576 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005af:	8b 83 d8 22 00 00    	mov    0x22d8(%ebx),%eax
	return 0;
f01005b5:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005ba:	3b 83 dc 22 00 00    	cmp    0x22dc(%ebx),%eax
f01005c0:	74 1e                	je     f01005e0 <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f01005c2:	8d 48 01             	lea    0x1(%eax),%ecx
f01005c5:	0f b6 94 03 d8 20 00 	movzbl 0x20d8(%ebx,%eax,1),%edx
f01005cc:	00 
			cons.rpos = 0;
f01005cd:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01005d7:	0f 45 c1             	cmovne %ecx,%eax
f01005da:	89 83 d8 22 00 00    	mov    %eax,0x22d8(%ebx)
}
f01005e0:	89 d0                	mov    %edx,%eax
f01005e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01005e5:	c9                   	leave  
f01005e6:	c3                   	ret    

f01005e7 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005e7:	55                   	push   %ebp
f01005e8:	89 e5                	mov    %esp,%ebp
f01005ea:	57                   	push   %edi
f01005eb:	56                   	push   %esi
f01005ec:	53                   	push   %ebx
f01005ed:	83 ec 1c             	sub    $0x1c,%esp
f01005f0:	e8 9c fb ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01005f5:	81 c3 73 02 08 00    	add    $0x80273,%ebx
	was = *cp;
f01005fb:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100602:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100609:	5a a5 
	if (*cp != 0xA55A) {
f010060b:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100612:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100617:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f010061c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100620:	0f 84 ac 00 00 00    	je     f01006d2 <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f0100626:	89 8b e8 22 00 00    	mov    %ecx,0x22e8(%ebx)
f010062c:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100631:	89 ca                	mov    %ecx,%edx
f0100633:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100634:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100637:	89 f2                	mov    %esi,%edx
f0100639:	ec                   	in     (%dx),%al
f010063a:	0f b6 c0             	movzbl %al,%eax
f010063d:	c1 e0 08             	shl    $0x8,%eax
f0100640:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100643:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100648:	89 ca                	mov    %ecx,%edx
f010064a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010064b:	89 f2                	mov    %esi,%edx
f010064d:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010064e:	89 bb e4 22 00 00    	mov    %edi,0x22e4(%ebx)
	pos |= inb(addr_6845 + 1);
f0100654:	0f b6 c0             	movzbl %al,%eax
f0100657:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f010065a:	66 89 83 e0 22 00 00 	mov    %ax,0x22e0(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100661:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100666:	89 c8                	mov    %ecx,%eax
f0100668:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010066d:	ee                   	out    %al,(%dx)
f010066e:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100673:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100678:	89 fa                	mov    %edi,%edx
f010067a:	ee                   	out    %al,(%dx)
f010067b:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100680:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100685:	ee                   	out    %al,(%dx)
f0100686:	be f9 03 00 00       	mov    $0x3f9,%esi
f010068b:	89 c8                	mov    %ecx,%eax
f010068d:	89 f2                	mov    %esi,%edx
f010068f:	ee                   	out    %al,(%dx)
f0100690:	b8 03 00 00 00       	mov    $0x3,%eax
f0100695:	89 fa                	mov    %edi,%edx
f0100697:	ee                   	out    %al,(%dx)
f0100698:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010069d:	89 c8                	mov    %ecx,%eax
f010069f:	ee                   	out    %al,(%dx)
f01006a0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006a5:	89 f2                	mov    %esi,%edx
f01006a7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006ad:	ec                   	in     (%dx),%al
f01006ae:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006b0:	3c ff                	cmp    $0xff,%al
f01006b2:	0f 95 83 ec 22 00 00 	setne  0x22ec(%ebx)
f01006b9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006be:	ec                   	in     (%dx),%al
f01006bf:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006c4:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006c5:	80 f9 ff             	cmp    $0xff,%cl
f01006c8:	74 1e                	je     f01006e8 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006cd:	5b                   	pop    %ebx
f01006ce:	5e                   	pop    %esi
f01006cf:	5f                   	pop    %edi
f01006d0:	5d                   	pop    %ebp
f01006d1:	c3                   	ret    
		*cp = was;
f01006d2:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f01006d9:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006de:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f01006e3:	e9 3e ff ff ff       	jmp    f0100626 <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f01006e8:	83 ec 0c             	sub    $0xc,%esp
f01006eb:	8d 83 7a 4f f8 ff    	lea    -0x7b086(%ebx),%eax
f01006f1:	50                   	push   %eax
f01006f2:	e8 21 3c 00 00       	call   f0104318 <cprintf>
f01006f7:	83 c4 10             	add    $0x10,%esp
}
f01006fa:	eb ce                	jmp    f01006ca <cons_init+0xe3>

f01006fc <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006fc:	55                   	push   %ebp
f01006fd:	89 e5                	mov    %esp,%ebp
f01006ff:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100702:	8b 45 08             	mov    0x8(%ebp),%eax
f0100705:	e8 2f fc ff ff       	call   f0100339 <cons_putc>
}
f010070a:	c9                   	leave  
f010070b:	c3                   	ret    

f010070c <getchar>:

int
getchar(void)
{
f010070c:	55                   	push   %ebp
f010070d:	89 e5                	mov    %esp,%ebp
f010070f:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100712:	e8 7c fe ff ff       	call   f0100593 <cons_getc>
f0100717:	85 c0                	test   %eax,%eax
f0100719:	74 f7                	je     f0100712 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010071b:	c9                   	leave  
f010071c:	c3                   	ret    

f010071d <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f010071d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100722:	c3                   	ret    

f0100723 <__x86.get_pc_thunk.ax>:
f0100723:	8b 04 24             	mov    (%esp),%eax
f0100726:	c3                   	ret    

f0100727 <__x86.get_pc_thunk.si>:
f0100727:	8b 34 24             	mov    (%esp),%esi
f010072a:	c3                   	ret    

f010072b <mon_help>:
struct Eipdebuginfo eipinfo;
/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010072b:	55                   	push   %ebp
f010072c:	89 e5                	mov    %esp,%ebp
f010072e:	56                   	push   %esi
f010072f:	53                   	push   %ebx
f0100730:	e8 5c fa ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0100735:	81 c3 33 01 08 00    	add    $0x80133,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010073b:	83 ec 04             	sub    $0x4,%esp
f010073e:	8d 83 98 51 f8 ff    	lea    -0x7ae68(%ebx),%eax
f0100744:	50                   	push   %eax
f0100745:	8d 83 b6 51 f8 ff    	lea    -0x7ae4a(%ebx),%eax
f010074b:	50                   	push   %eax
f010074c:	8d b3 bb 51 f8 ff    	lea    -0x7ae45(%ebx),%esi
f0100752:	56                   	push   %esi
f0100753:	e8 c0 3b 00 00       	call   f0104318 <cprintf>
f0100758:	83 c4 0c             	add    $0xc,%esp
f010075b:	8d 83 84 53 f8 ff    	lea    -0x7ac7c(%ebx),%eax
f0100761:	50                   	push   %eax
f0100762:	8d 83 c4 51 f8 ff    	lea    -0x7ae3c(%ebx),%eax
f0100768:	50                   	push   %eax
f0100769:	56                   	push   %esi
f010076a:	e8 a9 3b 00 00       	call   f0104318 <cprintf>
f010076f:	83 c4 0c             	add    $0xc,%esp
f0100772:	8d 83 ac 53 f8 ff    	lea    -0x7ac54(%ebx),%eax
f0100778:	50                   	push   %eax
f0100779:	8d 83 cd 51 f8 ff    	lea    -0x7ae33(%ebx),%eax
f010077f:	50                   	push   %eax
f0100780:	56                   	push   %esi
f0100781:	e8 92 3b 00 00       	call   f0104318 <cprintf>
f0100786:	83 c4 0c             	add    $0xc,%esp
f0100789:	8d 83 d7 51 f8 ff    	lea    -0x7ae29(%ebx),%eax
f010078f:	50                   	push   %eax
f0100790:	8d 83 98 65 f8 ff    	lea    -0x79a68(%ebx),%eax
f0100796:	50                   	push   %eax
f0100797:	56                   	push   %esi
f0100798:	e8 7b 3b 00 00       	call   f0104318 <cprintf>
	return 0;
}
f010079d:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007a5:	5b                   	pop    %ebx
f01007a6:	5e                   	pop    %esi
f01007a7:	5d                   	pop    %ebp
f01007a8:	c3                   	ret    

f01007a9 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007a9:	55                   	push   %ebp
f01007aa:	89 e5                	mov    %esp,%ebp
f01007ac:	57                   	push   %edi
f01007ad:	56                   	push   %esi
f01007ae:	53                   	push   %ebx
f01007af:	83 ec 18             	sub    $0x18,%esp
f01007b2:	e8 da f9 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01007b7:	81 c3 b1 00 08 00    	add    $0x800b1,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007bd:	8d 83 dc 51 f8 ff    	lea    -0x7ae24(%ebx),%eax
f01007c3:	50                   	push   %eax
f01007c4:	e8 4f 3b 00 00       	call   f0104318 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007c9:	83 c4 08             	add    $0x8,%esp
f01007cc:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f01007d2:	8d 83 d0 53 f8 ff    	lea    -0x7ac30(%ebx),%eax
f01007d8:	50                   	push   %eax
f01007d9:	e8 3a 3b 00 00       	call   f0104318 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007e7:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007ed:	50                   	push   %eax
f01007ee:	57                   	push   %edi
f01007ef:	8d 83 f8 53 f8 ff    	lea    -0x7ac08(%ebx),%eax
f01007f5:	50                   	push   %eax
f01007f6:	e8 1d 3b 00 00       	call   f0104318 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007fb:	83 c4 0c             	add    $0xc,%esp
f01007fe:	c7 c0 41 57 10 f0    	mov    $0xf0105741,%eax
f0100804:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010080a:	52                   	push   %edx
f010080b:	50                   	push   %eax
f010080c:	8d 83 1c 54 f8 ff    	lea    -0x7abe4(%ebx),%eax
f0100812:	50                   	push   %eax
f0100813:	e8 00 3b 00 00       	call   f0104318 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100818:	83 c4 0c             	add    $0xc,%esp
f010081b:	c7 c0 00 29 18 f0    	mov    $0xf0182900,%eax
f0100821:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100827:	52                   	push   %edx
f0100828:	50                   	push   %eax
f0100829:	8d 83 40 54 f8 ff    	lea    -0x7abc0(%ebx),%eax
f010082f:	50                   	push   %eax
f0100830:	e8 e3 3a 00 00       	call   f0104318 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100835:	83 c4 0c             	add    $0xc,%esp
f0100838:	c7 c6 40 38 18 f0    	mov    $0xf0183840,%esi
f010083e:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100844:	50                   	push   %eax
f0100845:	56                   	push   %esi
f0100846:	8d 83 64 54 f8 ff    	lea    -0x7ab9c(%ebx),%eax
f010084c:	50                   	push   %eax
f010084d:	e8 c6 3a 00 00       	call   f0104318 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100852:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100855:	29 fe                	sub    %edi,%esi
f0100857:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085d:	c1 fe 0a             	sar    $0xa,%esi
f0100860:	56                   	push   %esi
f0100861:	8d 83 88 54 f8 ff    	lea    -0x7ab78(%ebx),%eax
f0100867:	50                   	push   %eax
f0100868:	e8 ab 3a 00 00       	call   f0104318 <cprintf>
	return 0;
}
f010086d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100872:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100875:	5b                   	pop    %ebx
f0100876:	5e                   	pop    %esi
f0100877:	5f                   	pop    %edi
f0100878:	5d                   	pop    %ebp
f0100879:	c3                   	ret    

f010087a <test_cmd>:


/*******************My Debug Command********************/

int test_cmd(int a, int b)
{
f010087a:	55                   	push   %ebp
f010087b:	89 e5                	mov    %esp,%ebp
f010087d:	53                   	push   %ebx
f010087e:	83 ec 0c             	sub    $0xc,%esp
f0100881:	e8 0b f9 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0100886:	81 c3 e2 ff 07 00    	add    $0x7ffe2,%ebx
	cprintf("a+b=%d\n", a+b);
f010088c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010088f:	03 45 08             	add    0x8(%ebp),%eax
f0100892:	50                   	push   %eax
f0100893:	8d 83 f5 51 f8 ff    	lea    -0x7ae0b(%ebx),%eax
f0100899:	50                   	push   %eax
f010089a:	e8 79 3a 00 00       	call   f0104318 <cprintf>
	return 0;
}
f010089f:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01008a7:	c9                   	leave  
f01008a8:	c3                   	ret    

f01008a9 <mon_backtrace>:
{
f01008a9:	55                   	push   %ebp
f01008aa:	89 e5                	mov    %esp,%ebp
f01008ac:	57                   	push   %edi
f01008ad:	56                   	push   %esi
f01008ae:	53                   	push   %ebx
f01008af:	83 ec 28             	sub    $0x28,%esp
f01008b2:	e8 da f8 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01008b7:	81 c3 b1 ff 07 00    	add    $0x7ffb1,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008bd:	89 e8                	mov    %ebp,%eax
	int *ebp_ptr = (int*)ebp_val;
f01008bf:	89 c7                	mov    %eax,%edi
	cprintf("Stack backtrace:\n");
f01008c1:	8d 83 fd 51 f8 ff    	lea    -0x7ae03(%ebx),%eax
f01008c7:	50                   	push   %eax
f01008c8:	e8 4b 3a 00 00       	call   f0104318 <cprintf>
f01008cd:	83 c4 10             	add    $0x10,%esp
		debuginfo_eip(eip_val, &eipinfo);
f01008d0:	8d 83 f0 22 00 00    	lea    0x22f0(%ebx),%eax
f01008d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		cprintf("ebp %08x eip %08x  ", ebp_val, eip_val);
f01008d9:	8d 83 0f 52 f8 ff    	lea    -0x7adf1(%ebx),%eax
f01008df:	89 45 dc             	mov    %eax,-0x24(%ebp)
		ebp_val = *ebp_ptr;
f01008e2:	8b 37                	mov    (%edi),%esi
		eip_val = *(ebp_ptr+1);
f01008e4:	8b 47 04             	mov    0x4(%edi),%eax
		debuginfo_eip(eip_val, &eipinfo);
f01008e7:	83 ec 08             	sub    $0x8,%esp
f01008ea:	ff 75 e0             	push   -0x20(%ebp)
f01008ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01008f0:	50                   	push   %eax
f01008f1:	e8 c6 3f 00 00       	call   f01048bc <debuginfo_eip>
		cprintf("ebp %08x eip %08x  ", ebp_val, eip_val);
f01008f6:	83 c4 0c             	add    $0xc,%esp
f01008f9:	ff 75 e4             	push   -0x1c(%ebp)
f01008fc:	56                   	push   %esi
f01008fd:	ff 75 dc             	push   -0x24(%ebp)
f0100900:	e8 13 3a 00 00       	call   f0104318 <cprintf>
		cprintf("args %08x", *(ebp_ptr+2));
f0100905:	83 c4 08             	add    $0x8,%esp
f0100908:	ff 77 08             	push   0x8(%edi)
f010090b:	8d 83 23 52 f8 ff    	lea    -0x7addd(%ebx),%eax
f0100911:	50                   	push   %eax
f0100912:	e8 01 3a 00 00       	call   f0104318 <cprintf>
		cprintf(" %08x", *(ebp_ptr+3));
f0100917:	83 c4 08             	add    $0x8,%esp
f010091a:	ff 77 0c             	push   0xc(%edi)
f010091d:	8d b3 27 52 f8 ff    	lea    -0x7add9(%ebx),%esi
f0100923:	56                   	push   %esi
f0100924:	e8 ef 39 00 00       	call   f0104318 <cprintf>
		cprintf(" %08x", *(ebp_ptr+4));
f0100929:	83 c4 08             	add    $0x8,%esp
f010092c:	ff 77 10             	push   0x10(%edi)
f010092f:	56                   	push   %esi
f0100930:	e8 e3 39 00 00       	call   f0104318 <cprintf>
		cprintf(" %08x", *(ebp_ptr+5));
f0100935:	83 c4 08             	add    $0x8,%esp
f0100938:	ff 77 14             	push   0x14(%edi)
f010093b:	56                   	push   %esi
f010093c:	e8 d7 39 00 00       	call   f0104318 <cprintf>
		cprintf(" %08x\n", *(ebp_ptr+6));
f0100941:	83 c4 08             	add    $0x8,%esp
f0100944:	ff 77 18             	push   0x18(%edi)
f0100947:	8d 83 cf 63 f8 ff    	lea    -0x79c31(%ebx),%eax
f010094d:	50                   	push   %eax
f010094e:	e8 c5 39 00 00       	call   f0104318 <cprintf>
		cprintf("%s:%d: ", eipinfo.eip_file, eipinfo.eip_line);
f0100953:	83 c4 0c             	add    $0xc,%esp
f0100956:	ff b3 f4 22 00 00    	push   0x22f4(%ebx)
f010095c:	ff b3 f0 22 00 00    	push   0x22f0(%ebx)
f0100962:	8d 83 4c 4f f8 ff    	lea    -0x7b0b4(%ebx),%eax
f0100968:	50                   	push   %eax
f0100969:	e8 aa 39 00 00       	call   f0104318 <cprintf>
		cprintf("%.*s", eipinfo.eip_fn_namelen, eipinfo.eip_fn_name);
f010096e:	83 c4 0c             	add    $0xc,%esp
f0100971:	ff b3 f8 22 00 00    	push   0x22f8(%ebx)
f0100977:	ff b3 fc 22 00 00    	push   0x22fc(%ebx)
f010097d:	8d 83 2d 52 f8 ff    	lea    -0x7add3(%ebx),%eax
f0100983:	50                   	push   %eax
f0100984:	e8 8f 39 00 00       	call   f0104318 <cprintf>
		cprintf("+%d\n",-eipinfo.eip_fn_addr + eip_val);
f0100989:	83 c4 08             	add    $0x8,%esp
f010098c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010098f:	2b 83 00 23 00 00    	sub    0x2300(%ebx),%eax
f0100995:	50                   	push   %eax
f0100996:	8d 83 32 52 f8 ff    	lea    -0x7adce(%ebx),%eax
f010099c:	50                   	push   %eax
f010099d:	e8 76 39 00 00       	call   f0104318 <cprintf>
		ebp_ptr = (int*)(*ebp_ptr);
f01009a2:	8b 3f                	mov    (%edi),%edi
	}while(ebp_ptr != NULL);
f01009a4:	83 c4 10             	add    $0x10,%esp
f01009a7:	85 ff                	test   %edi,%edi
f01009a9:	0f 85 33 ff ff ff    	jne    f01008e2 <mon_backtrace+0x39>
}
f01009af:	b8 00 00 00 00       	mov    $0x0,%eax
f01009b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009b7:	5b                   	pop    %ebx
f01009b8:	5e                   	pop    %esi
f01009b9:	5f                   	pop    %edi
f01009ba:	5d                   	pop    %ebp
f01009bb:	c3                   	ret    

f01009bc <show_mappings>:


int show_mappings(u32 va_begin, u32 va_end)
{
f01009bc:	55                   	push   %ebp
f01009bd:	89 e5                	mov    %esp,%ebp
f01009bf:	57                   	push   %edi
f01009c0:	56                   	push   %esi
f01009c1:	53                   	push   %ebx
f01009c2:	83 ec 28             	sub    $0x28,%esp
f01009c5:	e8 c7 f7 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01009ca:	81 c3 9e fe 07 00    	add    $0x7fe9e,%ebx
f01009d0:	8b 7d 08             	mov    0x8(%ebp),%edi
	//u32 *vaddr = (u32 *)va_begin;
	cprintf("vaddr       paddr       [AVA][//][D][A][//][U][W][P]\n");
f01009d3:	8d 83 b4 54 f8 ff    	lea    -0x7ab4c(%ebx),%eax
f01009d9:	50                   	push   %eax
f01009da:	e8 39 39 00 00       	call   f0104318 <cprintf>
	for (u32 vaddr = va_begin; vaddr <= va_end; vaddr = vaddr + PGSIZE)
f01009df:	83 c4 10             	add    $0x10,%esp
	{
		pte_t *t_entry = pgdir_walk(kern_pgdir, (u32 *)vaddr, false);
f01009e2:	c7 c0 74 2b 18 f0    	mov    $0xf0182b74,%eax
f01009e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			{
				cprintf("0x%x  none pte\n", vaddr);
			}
		}
		else
			cprintf("0x%x  none pde\n", vaddr);
f01009eb:	8d 83 56 52 f8 ff    	lea    -0x7adaa(%ebx),%eax
f01009f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (u32 vaddr = va_begin; vaddr <= va_end; vaddr = vaddr + PGSIZE)
f01009f4:	eb 19                	jmp    f0100a0f <show_mappings+0x53>
				cprintf("0x%x  none pte\n", vaddr);
f01009f6:	83 ec 08             	sub    $0x8,%esp
f01009f9:	57                   	push   %edi
f01009fa:	8d 83 46 52 f8 ff    	lea    -0x7adba(%ebx),%eax
f0100a00:	50                   	push   %eax
f0100a01:	e8 12 39 00 00       	call   f0104318 <cprintf>
f0100a06:	83 c4 10             	add    $0x10,%esp
	for (u32 vaddr = va_begin; vaddr <= va_end; vaddr = vaddr + PGSIZE)
f0100a09:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0100a0f:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100a12:	0f 87 cc 00 00 00    	ja     f0100ae4 <show_mappings+0x128>
		pte_t *t_entry = pgdir_walk(kern_pgdir, (u32 *)vaddr, false);
f0100a18:	83 ec 04             	sub    $0x4,%esp
f0100a1b:	6a 00                	push   $0x0
f0100a1d:	57                   	push   %edi
f0100a1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a21:	ff 30                	push   (%eax)
f0100a23:	e8 2d 0d 00 00       	call   f0101755 <pgdir_walk>
		if (t_entry)
f0100a28:	83 c4 10             	add    $0x10,%esp
f0100a2b:	85 c0                	test   %eax,%eax
f0100a2d:	0f 84 9d 00 00 00    	je     f0100ad0 <show_mappings+0x114>
			u32 val = *t_entry;
f0100a33:	8b 30                	mov    (%eax),%esi
			if (*t_entry & PTE_P)
f0100a35:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0100a3b:	74 b9                	je     f01009f6 <show_mappings+0x3a>
				cprintf("0x%08x  0x%08x", vaddr, val & 0xfffff000);
f0100a3d:	83 ec 04             	sub    $0x4,%esp
f0100a40:	89 f0                	mov    %esi,%eax
f0100a42:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a47:	50                   	push   %eax
f0100a48:	57                   	push   %edi
f0100a49:	8d 83 37 52 f8 ff    	lea    -0x7adc9(%ebx),%eax
f0100a4f:	50                   	push   %eax
f0100a50:	e8 c3 38 00 00       	call   f0104318 <cprintf>
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
				BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
f0100a5c:	89 f0                	mov    %esi,%eax
f0100a5e:	d1 e8                	shr    %eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a60:	83 e0 01             	and    $0x1,%eax
f0100a63:	50                   	push   %eax
				BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
f0100a64:	89 f0                	mov    %esi,%eax
f0100a66:	c1 e8 02             	shr    $0x2,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a69:	83 e0 01             	and    $0x1,%eax
f0100a6c:	50                   	push   %eax
				BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
f0100a6d:	89 f0                	mov    %esi,%eax
f0100a6f:	c1 e8 03             	shr    $0x3,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a72:	83 e0 01             	and    $0x1,%eax
f0100a75:	50                   	push   %eax
				BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100a76:	89 f0                	mov    %esi,%eax
f0100a78:	c1 e8 04             	shr    $0x4,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a7b:	83 e0 01             	and    $0x1,%eax
f0100a7e:	50                   	push   %eax
				BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100a7f:	89 f0                	mov    %esi,%eax
f0100a81:	c1 e8 05             	shr    $0x5,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a84:	83 e0 01             	and    $0x1,%eax
f0100a87:	50                   	push   %eax
				BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100a88:	89 f0                	mov    %esi,%eax
f0100a8a:	c1 e8 06             	shr    $0x6,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a8d:	83 e0 01             	and    $0x1,%eax
f0100a90:	50                   	push   %eax
				BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100a91:	89 f0                	mov    %esi,%eax
f0100a93:	c1 e8 07             	shr    $0x7,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a96:	83 e0 01             	and    $0x1,%eax
f0100a99:	50                   	push   %eax
				BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100a9a:	89 f0                	mov    %esi,%eax
f0100a9c:	c1 e8 08             	shr    $0x8,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a9f:	83 e0 01             	and    $0x1,%eax
f0100aa2:	50                   	push   %eax
				BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100aa3:	89 f0                	mov    %esi,%eax
f0100aa5:	c1 e8 09             	shr    $0x9,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100aa8:	83 e0 01             	and    $0x1,%eax
f0100aab:	50                   	push   %eax
				BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100aac:	89 f0                	mov    %esi,%eax
f0100aae:	c1 e8 0a             	shr    $0xa,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100ab1:	83 e0 01             	and    $0x1,%eax
f0100ab4:	50                   	push   %eax
				BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100ab5:	c1 ee 0b             	shr    $0xb,%esi
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100ab8:	83 e6 01             	and    $0x1,%esi
f0100abb:	56                   	push   %esi
f0100abc:	8d 83 ec 54 f8 ff    	lea    -0x7ab14(%ebx),%eax
f0100ac2:	50                   	push   %eax
f0100ac3:	e8 50 38 00 00       	call   f0104318 <cprintf>
f0100ac8:	83 c4 40             	add    $0x40,%esp
f0100acb:	e9 39 ff ff ff       	jmp    f0100a09 <show_mappings+0x4d>
			cprintf("0x%x  none pde\n", vaddr);
f0100ad0:	83 ec 08             	sub    $0x8,%esp
f0100ad3:	57                   	push   %edi
f0100ad4:	ff 75 e0             	push   -0x20(%ebp)
f0100ad7:	e8 3c 38 00 00       	call   f0104318 <cprintf>
f0100adc:	83 c4 10             	add    $0x10,%esp
f0100adf:	e9 25 ff ff ff       	jmp    f0100a09 <show_mappings+0x4d>
	}
	return 0;
}
f0100ae4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aec:	5b                   	pop    %ebx
f0100aed:	5e                   	pop    %esi
f0100aee:	5f                   	pop    %edi
f0100aef:	5d                   	pop    %ebp
f0100af0:	c3                   	ret    

f0100af1 <change_permission>:

int change_permission(u32 va, u32 aut)
{
f0100af1:	55                   	push   %ebp
f0100af2:	89 e5                	mov    %esp,%ebp
f0100af4:	57                   	push   %edi
f0100af5:	56                   	push   %esi
f0100af6:	53                   	push   %ebx
f0100af7:	83 ec 28             	sub    $0x28,%esp
f0100afa:	e8 92 f6 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0100aff:	81 c3 69 fd 07 00    	add    $0x7fd69,%ebx
	va = va & 0xfffff000;
f0100b05:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100b08:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	cprintf("before change\n");
f0100b0e:	8d 83 66 52 f8 ff    	lea    -0x7ad9a(%ebx),%eax
f0100b14:	50                   	push   %eax
f0100b15:	e8 fe 37 00 00       	call   f0104318 <cprintf>
	show_mappings(va, va);
f0100b1a:	83 c4 08             	add    $0x8,%esp
f0100b1d:	57                   	push   %edi
f0100b1e:	57                   	push   %edi
f0100b1f:	e8 98 fe ff ff       	call   f01009bc <show_mappings>

	pte_t *t_entry = pgdir_walk(kern_pgdir, (u32 *)va, false);
f0100b24:	83 c4 0c             	add    $0xc,%esp
f0100b27:	6a 00                	push   $0x0
f0100b29:	57                   	push   %edi
f0100b2a:	c7 c0 74 2b 18 f0    	mov    $0xf0182b74,%eax
f0100b30:	ff 30                	push   (%eax)
f0100b32:	e8 1e 0c 00 00       	call   f0101755 <pgdir_walk>
	if (t_entry)
f0100b37:	83 c4 10             	add    $0x10,%esp
f0100b3a:	85 c0                	test   %eax,%eax
f0100b3c:	0f 84 e3 00 00 00    	je     f0100c25 <change_permission+0x134>
f0100b42:	89 c6                	mov    %eax,%esi
	{
		if (*t_entry & PTE_P)
f0100b44:	f6 00 01             	testb  $0x1,(%eax)
f0100b47:	0f 84 c3 00 00 00    	je     f0100c10 <change_permission+0x11f>
		{
			cprintf("after change\n");
f0100b4d:	83 ec 0c             	sub    $0xc,%esp
f0100b50:	8d 83 75 52 f8 ff    	lea    -0x7ad8b(%ebx),%eax
f0100b56:	50                   	push   %eax
f0100b57:	e8 bc 37 00 00       	call   f0104318 <cprintf>
			int temp = (aut << 1) & 0x6;
			*t_entry = (*t_entry & ~0x6) | temp;
f0100b5c:	89 f2                	mov    %esi,%edx
f0100b5e:	8b 06                	mov    (%esi),%eax
f0100b60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100b63:	89 c6                	mov    %eax,%esi
f0100b65:	83 e6 f9             	and    $0xfffffff9,%esi
			int temp = (aut << 1) & 0x6;
f0100b68:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b6b:	01 c0                	add    %eax,%eax
f0100b6d:	83 e0 06             	and    $0x6,%eax
			*t_entry = (*t_entry & ~0x6) | temp;
f0100b70:	09 c6                	or     %eax,%esi
f0100b72:	89 32                	mov    %esi,(%edx)
			u32 val = *t_entry;
			cprintf("0x%08x  0x%08x", va, val & 0xfffff000);
f0100b74:	83 c4 0c             	add    $0xc,%esp
f0100b77:	89 f0                	mov    %esi,%eax
f0100b79:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b7e:	50                   	push   %eax
f0100b7f:	57                   	push   %edi
f0100b80:	8d 83 37 52 f8 ff    	lea    -0x7adc9(%ebx),%eax
f0100b86:	50                   	push   %eax
f0100b87:	e8 8c 37 00 00       	call   f0104318 <cprintf>
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100b8c:	89 f0                	mov    %esi,%eax
f0100b8e:	83 e0 01             	and    $0x1,%eax
f0100b91:	89 04 24             	mov    %eax,(%esp)
			BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
			BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
			BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
f0100b94:	89 f0                	mov    %esi,%eax
f0100b96:	d1 e8                	shr    %eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100b98:	83 e0 01             	and    $0x1,%eax
f0100b9b:	50                   	push   %eax
			BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
f0100b9c:	89 f0                	mov    %esi,%eax
f0100b9e:	c1 e8 02             	shr    $0x2,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100ba1:	83 e0 01             	and    $0x1,%eax
f0100ba4:	50                   	push   %eax
			BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
f0100ba5:	89 f0                	mov    %esi,%eax
f0100ba7:	c1 e8 03             	shr    $0x3,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100baa:	83 e0 01             	and    $0x1,%eax
f0100bad:	50                   	push   %eax
			BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100bae:	89 f0                	mov    %esi,%eax
f0100bb0:	c1 e8 04             	shr    $0x4,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bb3:	83 e0 01             	and    $0x1,%eax
f0100bb6:	50                   	push   %eax
			BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100bb7:	89 f0                	mov    %esi,%eax
f0100bb9:	c1 e8 05             	shr    $0x5,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bbc:	83 e0 01             	and    $0x1,%eax
f0100bbf:	50                   	push   %eax
			BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100bc0:	89 f0                	mov    %esi,%eax
f0100bc2:	c1 e8 06             	shr    $0x6,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bc5:	83 e0 01             	and    $0x1,%eax
f0100bc8:	50                   	push   %eax
			BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100bc9:	89 f0                	mov    %esi,%eax
f0100bcb:	c1 e8 07             	shr    $0x7,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bce:	83 e0 01             	and    $0x1,%eax
f0100bd1:	50                   	push   %eax
			BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100bd2:	89 f0                	mov    %esi,%eax
f0100bd4:	c1 e8 08             	shr    $0x8,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bd7:	83 e0 01             	and    $0x1,%eax
f0100bda:	50                   	push   %eax
			BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100bdb:	89 f0                	mov    %esi,%eax
f0100bdd:	c1 e8 09             	shr    $0x9,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100be0:	83 e0 01             	and    $0x1,%eax
f0100be3:	50                   	push   %eax
			BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100be4:	89 f0                	mov    %esi,%eax
f0100be6:	c1 e8 0a             	shr    $0xa,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100be9:	83 e0 01             	and    $0x1,%eax
f0100bec:	50                   	push   %eax
			BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100bed:	c1 ee 0b             	shr    $0xb,%esi
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bf0:	83 e6 01             	and    $0x1,%esi
f0100bf3:	56                   	push   %esi
f0100bf4:	8d 83 ec 54 f8 ff    	lea    -0x7ab14(%ebx),%eax
f0100bfa:	50                   	push   %eax
f0100bfb:	e8 18 37 00 00       	call   f0104318 <cprintf>
f0100c00:	83 c4 40             	add    $0x40,%esp
	else
	{
		cprintf("0x%x  none pde\n", va);
	}
	return 0;
}
f0100c03:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c0b:	5b                   	pop    %ebx
f0100c0c:	5e                   	pop    %esi
f0100c0d:	5f                   	pop    %edi
f0100c0e:	5d                   	pop    %ebp
f0100c0f:	c3                   	ret    
			cprintf("0x%x  none pte\n", va);
f0100c10:	83 ec 08             	sub    $0x8,%esp
f0100c13:	57                   	push   %edi
f0100c14:	8d 83 46 52 f8 ff    	lea    -0x7adba(%ebx),%eax
f0100c1a:	50                   	push   %eax
f0100c1b:	e8 f8 36 00 00       	call   f0104318 <cprintf>
f0100c20:	83 c4 10             	add    $0x10,%esp
f0100c23:	eb de                	jmp    f0100c03 <change_permission+0x112>
		cprintf("0x%x  none pde\n", va);
f0100c25:	83 ec 08             	sub    $0x8,%esp
f0100c28:	57                   	push   %edi
f0100c29:	8d 83 56 52 f8 ff    	lea    -0x7adaa(%ebx),%eax
f0100c2f:	50                   	push   %eax
f0100c30:	e8 e3 36 00 00       	call   f0104318 <cprintf>
f0100c35:	83 c4 10             	add    $0x10,%esp
f0100c38:	eb c9                	jmp    f0100c03 <change_permission+0x112>

f0100c3a <virtual_memeory_dump>:

int virtual_memeory_dump(u32 addr, u32 len)
{
f0100c3a:	55                   	push   %ebp
f0100c3b:	89 e5                	mov    %esp,%ebp
f0100c3d:	57                   	push   %edi
f0100c3e:	56                   	push   %esi
f0100c3f:	53                   	push   %ebx
f0100c40:	83 ec 1c             	sub    $0x1c,%esp
f0100c43:	e8 49 f5 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0100c48:	81 c3 20 fc 07 00    	add    $0x7fc20,%ebx
	int pg_cnt; 
	int t_start = ROUNDDOWN(addr, PGSIZE);
	int t_end = ROUNDUP(addr+len, PGSIZE);
f0100c4e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0100c54:	8d 84 08 ff 0f 00 00 	lea    0xfff(%eax,%ecx,1),%eax
f0100c5b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	int t_start = ROUNDDOWN(addr, PGSIZE);
f0100c60:	8b 55 08             	mov    0x8(%ebp),%edx
f0100c63:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	pg_cnt = (t_end - t_start) / PGSIZE;
f0100c69:	29 d0                	sub    %edx,%eax
f0100c6b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100c71:	0f 48 c2             	cmovs  %edx,%eax
f0100c74:	c1 f8 0c             	sar    $0xc,%eax
f0100c77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (int i = 0; i < pg_cnt; i++)
f0100c7a:	8b 75 08             	mov    0x8(%ebp),%esi
f0100c7d:	bf 00 00 00 00       	mov    $0x0,%edi
	{
		pte_t *entry = pgdir_walk(kern_pgdir, (char*)(addr + PGSIZE * i), false);
f0100c82:	c7 c0 74 2b 18 f0    	mov    $0xf0182b74,%eax
f0100c88:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (int i = 0; i < pg_cnt; i++)
f0100c8b:	eb 22                	jmp    f0100caf <virtual_memeory_dump+0x75>
		if (!entry)
		{
			cprintf("page table for vitual address 0x%x does not exist!\n", addr + PGSIZE * i);
f0100c8d:	83 ec 08             	sub    $0x8,%esp
f0100c90:	56                   	push   %esi
f0100c91:	8d 83 18 55 f8 ff    	lea    -0x7aae8(%ebx),%eax
f0100c97:	50                   	push   %eax
f0100c98:	e8 7b 36 00 00       	call   f0104318 <cprintf>
			return -1;
f0100c9d:	83 c4 10             	add    $0x10,%esp
f0100ca0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ca5:	e9 de 00 00 00       	jmp    f0100d88 <virtual_memeory_dump+0x14e>
	for (int i = 0; i < pg_cnt; i++)
f0100caa:	83 c7 01             	add    $0x1,%edi
f0100cad:	89 d6                	mov    %edx,%esi
f0100caf:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0100cb2:	7d 3f                	jge    f0100cf3 <virtual_memeory_dump+0xb9>
		pte_t *entry = pgdir_walk(kern_pgdir, (char*)(addr + PGSIZE * i), false);
f0100cb4:	83 ec 04             	sub    $0x4,%esp
f0100cb7:	6a 00                	push   $0x0
f0100cb9:	56                   	push   %esi
f0100cba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cbd:	ff 30                	push   (%eax)
f0100cbf:	e8 91 0a 00 00       	call   f0101755 <pgdir_walk>
		if (!entry)
f0100cc4:	83 c4 10             	add    $0x10,%esp
f0100cc7:	85 c0                	test   %eax,%eax
f0100cc9:	74 c2                	je     f0100c8d <virtual_memeory_dump+0x53>
		}
		else
		{
			if ((*entry & PTE_P) == 0)
f0100ccb:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0100cd1:	f6 00 01             	testb  $0x1,(%eax)
f0100cd4:	75 d4                	jne    f0100caa <virtual_memeory_dump+0x70>
			{
				cprintf("physical map page for vitual address 0x%x does not exist!\n", addr + PGSIZE * i);
f0100cd6:	83 ec 08             	sub    $0x8,%esp
f0100cd9:	56                   	push   %esi
f0100cda:	8d 83 4c 55 f8 ff    	lea    -0x7aab4(%ebx),%eax
f0100ce0:	50                   	push   %eax
f0100ce1:	e8 32 36 00 00       	call   f0104318 <cprintf>
				return -1;
f0100ce6:	83 c4 10             	add    $0x10,%esp
f0100ce9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cee:	e9 95 00 00 00       	jmp    f0100d88 <virtual_memeory_dump+0x14e>
			}
		}
	}
	u32 *ptr = (u32 *)addr;
	// cprintf("0x%08x:  ", addr);
	for (int i = 0; i< ROUNDUP(len, sizeof(u32))/sizeof(u32); i++)
f0100cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100cf6:	83 c0 03             	add    $0x3,%eax
f0100cf9:	c1 e8 02             	shr    $0x2,%eax
f0100cfc:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100cff:	be 00 00 00 00       	mov    $0x0,%esi
	{
		if (i % 4 == 0)
		{
				cprintf("0x%08x:  ", addr + i * sizeof(u32));
f0100d04:	8d 83 83 52 f8 ff    	lea    -0x7ad7d(%ebx),%eax
f0100d0a:	89 45 d8             	mov    %eax,-0x28(%ebp)
		}
		cprintf("0x%08x  ", *(ptr+i));
f0100d0d:	8d 83 8d 52 f8 ff    	lea    -0x7ad73(%ebx),%eax
f0100d13:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100d16:	8b 7d 08             	mov    0x8(%ebp),%edi
	for (int i = 0; i< ROUNDUP(len, sizeof(u32))/sizeof(u32); i++)
f0100d19:	eb 17                	jmp    f0100d32 <virtual_memeory_dump+0xf8>
				cprintf("0x%08x:  ", addr + i * sizeof(u32));
f0100d1b:	83 ec 08             	sub    $0x8,%esp
f0100d1e:	57                   	push   %edi
f0100d1f:	ff 75 d8             	push   -0x28(%ebp)
f0100d22:	e8 f1 35 00 00       	call   f0104318 <cprintf>
f0100d27:	83 c4 10             	add    $0x10,%esp
f0100d2a:	eb 13                	jmp    f0100d3f <virtual_memeory_dump+0x105>
f0100d2c:	83 c7 04             	add    $0x4,%edi
	for (int i = 0; i < pg_cnt; i++)
f0100d2f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
	for (int i = 0; i< ROUNDUP(len, sizeof(u32))/sizeof(u32); i++)
f0100d32:	3b 75 e0             	cmp    -0x20(%ebp),%esi
f0100d35:	74 3a                	je     f0100d71 <virtual_memeory_dump+0x137>
		if (i % 4 == 0)
f0100d37:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0100d3d:	74 dc                	je     f0100d1b <virtual_memeory_dump+0xe1>
		cprintf("0x%08x  ", *(ptr+i));
f0100d3f:	83 ec 08             	sub    $0x8,%esp
f0100d42:	ff 37                	push   (%edi)
f0100d44:	ff 75 dc             	push   -0x24(%ebp)
f0100d47:	e8 cc 35 00 00       	call   f0104318 <cprintf>
		if ((i+1) % 4 == 0 && i != 0)
f0100d4c:	8d 46 01             	lea    0x1(%esi),%eax
f0100d4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d52:	83 c4 10             	add    $0x10,%esp
f0100d55:	a8 03                	test   $0x3,%al
f0100d57:	75 d3                	jne    f0100d2c <virtual_memeory_dump+0xf2>
f0100d59:	85 f6                	test   %esi,%esi
f0100d5b:	74 cf                	je     f0100d2c <virtual_memeory_dump+0xf2>
			cprintf("\n");
f0100d5d:	83 ec 0c             	sub    $0xc,%esp
f0100d60:	8d 83 3a 4f f8 ff    	lea    -0x7b0c6(%ebx),%eax
f0100d66:	50                   	push   %eax
f0100d67:	e8 ac 35 00 00       	call   f0104318 <cprintf>
f0100d6c:	83 c4 10             	add    $0x10,%esp
f0100d6f:	eb bb                	jmp    f0100d2c <virtual_memeory_dump+0xf2>
	}
	cprintf("\n");
f0100d71:	83 ec 0c             	sub    $0xc,%esp
f0100d74:	8d 83 3a 4f f8 ff    	lea    -0x7b0c6(%ebx),%eax
f0100d7a:	50                   	push   %eax
f0100d7b:	e8 98 35 00 00       	call   f0104318 <cprintf>
	return 0;
f0100d80:	83 c4 10             	add    $0x10,%esp
f0100d83:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d88:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d8b:	5b                   	pop    %ebx
f0100d8c:	5e                   	pop    %esi
f0100d8d:	5f                   	pop    %edi
f0100d8e:	5d                   	pop    %ebp
f0100d8f:	c3                   	ret    

f0100d90 <physical_memory_dump>:

int physical_memory_dump(u32 paddr, u32 len)
{
f0100d90:	55                   	push   %ebp
f0100d91:	89 e5                	mov    %esp,%ebp
f0100d93:	83 ec 10             	sub    $0x10,%esp
	u32 vaddr = paddr + KERNBASE;
	int ret = virtual_memeory_dump(vaddr, len);
f0100d96:	ff 75 0c             	push   0xc(%ebp)
	u32 vaddr = paddr + KERNBASE;
f0100d99:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d9c:	2d 00 00 00 10       	sub    $0x10000000,%eax
	int ret = virtual_memeory_dump(vaddr, len);
f0100da1:	50                   	push   %eax
f0100da2:	e8 93 fe ff ff       	call   f0100c3a <virtual_memeory_dump>
	return ret;
}
f0100da7:	c9                   	leave  
f0100da8:	c3                   	ret    

f0100da9 <in_page_dump>:


int in_page_dump(u32 addr, u32 len)
{
	return 0;
}
f0100da9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dae:	c3                   	ret    

f0100daf <string2value>:

	return 0;	
}

int string2value(char* str)
{
f0100daf:	55                   	push   %ebp
f0100db0:	89 e5                	mov    %esp,%ebp
f0100db2:	53                   	push   %ebx
f0100db3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100db6:	ba 00 00 00 00       	mov    $0x0,%edx
	char *p = str;
	int hex = 0;
	int temp_val = 0;
	int sum = 0;
	if (*p == '0')
f0100dbb:	80 39 30             	cmpb   $0x30,(%ecx)
f0100dbe:	74 1d                	je     f0100ddd <string2value+0x2e>
			p++;
		}
	}
	else
	{
		while(*p)
f0100dc0:	0f b6 01             	movzbl (%ecx),%eax
f0100dc3:	84 c0                	test   %al,%al
f0100dc5:	74 68                	je     f0100e2f <string2value+0x80>
		{
			//cprintf("ptr %d\n", *p);
			temp_val = *p - '0';
f0100dc7:	0f be c0             	movsbl %al,%eax
f0100dca:	83 e8 30             	sub    $0x30,%eax
			//cprintf("temp %d\n", temp_val);
			if (temp_val >= 0 && temp_val <= 9)
f0100dcd:	83 f8 09             	cmp    $0x9,%eax
f0100dd0:	77 58                	ja     f0100e2a <string2value+0x7b>
				sum = sum * 10 + temp_val;
f0100dd2:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0100dd5:	8d 14 50             	lea    (%eax,%edx,2),%edx
			else
				return -1;
			p++;
f0100dd8:	83 c1 01             	add    $0x1,%ecx
f0100ddb:	eb e3                	jmp    f0100dc0 <string2value+0x11>
		if (*(p+1) == 0)
f0100ddd:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0100de1:	84 c0                	test   %al,%al
f0100de3:	74 4a                	je     f0100e2f <string2value+0x80>
		else if (*(p+1) == 'x')
f0100de5:	3c 78                	cmp    $0x78,%al
f0100de7:	75 33                	jne    f0100e1c <string2value+0x6d>
		p += 2;
f0100de9:	83 c1 02             	add    $0x2,%ecx
f0100dec:	eb 15                	jmp    f0100e03 <string2value+0x54>
			else if (temp_val >= 49 && temp_val <= 54)
f0100dee:	0f be c0             	movsbl %al,%eax
f0100df1:	83 e8 61             	sub    $0x61,%eax
f0100df4:	83 f8 05             	cmp    $0x5,%eax
f0100df7:	77 2a                	ja     f0100e23 <string2value+0x74>
				sum = sum * 16 + temp_val - 39;
f0100df9:	c1 e2 04             	shl    $0x4,%edx
f0100dfc:	8d 54 13 d9          	lea    -0x27(%ebx,%edx,1),%edx
			p++;
f0100e00:	83 c1 01             	add    $0x1,%ecx
		while(*p)
f0100e03:	0f b6 01             	movzbl (%ecx),%eax
f0100e06:	84 c0                	test   %al,%al
f0100e08:	74 25                	je     f0100e2f <string2value+0x80>
			temp_val = *p - '0';
f0100e0a:	0f be d8             	movsbl %al,%ebx
f0100e0d:	83 eb 30             	sub    $0x30,%ebx
			if (temp_val >= 0 && temp_val<= 9)
f0100e10:	83 fb 09             	cmp    $0x9,%ebx
f0100e13:	77 d9                	ja     f0100dee <string2value+0x3f>
				sum = sum * 16 + temp_val;
f0100e15:	c1 e2 04             	shl    $0x4,%edx
f0100e18:	01 da                	add    %ebx,%edx
f0100e1a:	eb e4                	jmp    f0100e00 <string2value+0x51>
			return -1;
f0100e1c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100e21:	eb 0c                	jmp    f0100e2f <string2value+0x80>
				return -1;
f0100e23:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100e28:	eb 05                	jmp    f0100e2f <string2value+0x80>
				return -1;
f0100e2a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
		}
	} 
	return sum;
}
f0100e2f:	89 d0                	mov    %edx,%eax
f0100e31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e34:	c9                   	leave  
f0100e35:	c3                   	ret    

f0100e36 <v_cmd_exc>:
{
f0100e36:	55                   	push   %ebp
f0100e37:	89 e5                	mov    %esp,%ebp
f0100e39:	57                   	push   %edi
f0100e3a:	56                   	push   %esi
f0100e3b:	53                   	push   %ebx
f0100e3c:	83 ec 4c             	sub    $0x4c,%esp
f0100e3f:	e8 4d f3 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0100e44:	81 c3 24 fa 07 00    	add    $0x7fa24,%ebx
	int para[10] = {0};
f0100e4a:	8d 7d c0             	lea    -0x40(%ebp),%edi
f0100e4d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0100e52:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e57:	f3 ab                	rep stos %eax,%es:(%edi)
	if (argc < 2)
f0100e59:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100e5d:	7e 5a                	jle    f0100eb9 <v_cmd_exc+0x83>
	char *subfunc = argv[1];
f0100e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e62:	8b 40 04             	mov    0x4(%eax),%eax
f0100e65:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f0100e68:	8d bb d8 17 00 00    	lea    0x17d8(%ebx),%edi
	for (int i = 0; i < vcmd_num; i++)
f0100e6e:	be 00 00 00 00       	mov    $0x0,%esi
		if (!strcmp(subfunc, vcmd_group[i].name))
f0100e73:	83 ec 08             	sub    $0x8,%esp
f0100e76:	ff 37                	push   (%edi)
f0100e78:	ff 75 b4             	push   -0x4c(%ebp)
f0100e7b:	e8 f6 43 00 00       	call   f0105276 <strcmp>
f0100e80:	83 c4 10             	add    $0x10,%esp
f0100e83:	85 c0                	test   %eax,%eax
f0100e85:	74 4d                	je     f0100ed4 <v_cmd_exc+0x9e>
	for (int i = 0; i < vcmd_num; i++)
f0100e87:	83 c6 01             	add    $0x1,%esi
f0100e8a:	83 c7 10             	add    $0x10,%edi
f0100e8d:	81 fe 80 00 00 00    	cmp    $0x80,%esi
f0100e93:	75 de                	jne    f0100e73 <v_cmd_exc+0x3d>
	cprintf("command not found!\n");
f0100e95:	83 ec 0c             	sub    $0xc,%esp
f0100e98:	8d 83 c7 52 f8 ff    	lea    -0x7ad39(%ebx),%eax
f0100e9e:	50                   	push   %eax
f0100e9f:	e8 74 34 00 00       	call   f0104318 <cprintf>
	return 0;	
f0100ea4:	83 c4 10             	add    $0x10,%esp
f0100ea7:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
}
f0100eae:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100eb4:	5b                   	pop    %ebx
f0100eb5:	5e                   	pop    %esi
f0100eb6:	5f                   	pop    %edi
f0100eb7:	5d                   	pop    %ebp
f0100eb8:	c3                   	ret    
		cprintf("sub command name expected\n");
f0100eb9:	83 ec 0c             	sub    $0xc,%esp
f0100ebc:	8d 83 96 52 f8 ff    	lea    -0x7ad6a(%ebx),%eax
f0100ec2:	50                   	push   %eax
f0100ec3:	e8 50 34 00 00       	call   f0104318 <cprintf>
		return -1;
f0100ec8:	83 c4 10             	add    $0x10,%esp
f0100ecb:	c7 45 b4 ff ff ff ff 	movl   $0xffffffff,-0x4c(%ebp)
f0100ed2:	eb da                	jmp    f0100eae <v_cmd_exc+0x78>
			if (argc-2 != vcmd_group[i].para_cnt)
f0100ed4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f0100ed7:	89 f0                	mov    %esi,%eax
f0100ed9:	c1 e0 04             	shl    $0x4,%eax
f0100edc:	8b 84 03 e4 17 00 00 	mov    0x17e4(%ebx,%eax,1),%eax
f0100ee3:	8b 55 08             	mov    0x8(%ebp),%edx
f0100ee6:	83 ea 02             	sub    $0x2,%edx
f0100ee9:	39 c2                	cmp    %eax,%edx
f0100eeb:	75 27                	jne    f0100f14 <v_cmd_exc+0xde>
				for (int i = 2; i< argc; i++)
f0100eed:	bf 02 00 00 00       	mov    $0x2,%edi
f0100ef2:	89 75 b0             	mov    %esi,-0x50(%ebp)
f0100ef5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100ef8:	3b 7d 08             	cmp    0x8(%ebp),%edi
f0100efb:	74 36                	je     f0100f33 <v_cmd_exc+0xfd>
					para[i-1] = string2value(argv[i]);
f0100efd:	83 ec 0c             	sub    $0xc,%esp
f0100f00:	ff 34 be             	push   (%esi,%edi,4)
f0100f03:	e8 a7 fe ff ff       	call   f0100daf <string2value>
f0100f08:	83 c4 10             	add    $0x10,%esp
f0100f0b:	89 44 bd bc          	mov    %eax,-0x44(%ebp,%edi,4)
				for (int i = 2; i< argc; i++)
f0100f0f:	83 c7 01             	add    $0x1,%edi
f0100f12:	eb e4                	jmp    f0100ef8 <v_cmd_exc+0xc2>
				cprintf("expect %d parameters\n", vcmd_group[i].para_cnt);
f0100f14:	83 ec 08             	sub    $0x8,%esp
f0100f17:	50                   	push   %eax
f0100f18:	8d 83 b1 52 f8 ff    	lea    -0x7ad4f(%ebx),%eax
f0100f1e:	50                   	push   %eax
f0100f1f:	e8 f4 33 00 00       	call   f0104318 <cprintf>
				return -1;
f0100f24:	83 c4 10             	add    $0x10,%esp
f0100f27:	c7 45 b4 ff ff ff ff 	movl   $0xffffffff,-0x4c(%ebp)
f0100f2e:	e9 7b ff ff ff       	jmp    f0100eae <v_cmd_exc+0x78>
				func(para[1], para[2], para[3], para[4], para[5],
f0100f33:	8b 75 b0             	mov    -0x50(%ebp),%esi
f0100f36:	83 ec 0c             	sub    $0xc,%esp
				func9 func = (func9)vcmd_group[i].func;
f0100f39:	c1 e6 04             	shl    $0x4,%esi
				func(para[1], para[2], para[3], para[4], para[5],
f0100f3c:	ff 75 e4             	push   -0x1c(%ebp)
f0100f3f:	ff 75 e0             	push   -0x20(%ebp)
f0100f42:	ff 75 dc             	push   -0x24(%ebp)
f0100f45:	ff 75 d8             	push   -0x28(%ebp)
f0100f48:	ff 75 d4             	push   -0x2c(%ebp)
f0100f4b:	ff 75 d0             	push   -0x30(%ebp)
f0100f4e:	ff 75 cc             	push   -0x34(%ebp)
f0100f51:	ff 75 c8             	push   -0x38(%ebp)
f0100f54:	ff 75 c4             	push   -0x3c(%ebp)
f0100f57:	ff 94 33 e0 17 00 00 	call   *0x17e0(%ebx,%esi,1)
				return 0;
f0100f5e:	83 c4 30             	add    $0x30,%esp
f0100f61:	e9 48 ff ff ff       	jmp    f0100eae <v_cmd_exc+0x78>

f0100f66 <monitor>:
void
monitor(struct Trapframe *tf)
{
f0100f66:	55                   	push   %ebp
f0100f67:	89 e5                	mov    %esp,%ebp
f0100f69:	57                   	push   %edi
f0100f6a:	56                   	push   %esi
f0100f6b:	53                   	push   %ebx
f0100f6c:	83 ec 78             	sub    $0x78,%esp
f0100f6f:	e8 1d f2 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0100f74:	81 c3 f4 f8 07 00    	add    $0x7f8f4,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100f7a:	8d 83 88 55 f8 ff    	lea    -0x7aa78(%ebx),%eax
f0100f80:	50                   	push   %eax
f0100f81:	e8 92 33 00 00       	call   f0104318 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100f86:	8d 83 ac 55 f8 ff    	lea    -0x7aa54(%ebx),%eax
f0100f8c:	89 04 24             	mov    %eax,(%esp)
f0100f8f:	e8 84 33 00 00       	call   f0104318 <cprintf>
	char str[] = "0xabcd";
f0100f94:	c7 45 e1 30 78 61 62 	movl   $0x62617830,-0x1f(%ebp)
f0100f9b:	66 c7 45 e5 63 64    	movw   $0x6463,-0x1b(%ebp)
f0100fa1:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	int a = string2value(str);
f0100fa5:	8d 45 e1             	lea    -0x1f(%ebp),%eax
f0100fa8:	89 04 24             	mov    %eax,(%esp)
f0100fab:	e8 ff fd ff ff       	call   f0100daf <string2value>
f0100fb0:	83 c4 0c             	add    $0xc,%esp
	cprintf("test: %d %x\n", a, a);
f0100fb3:	50                   	push   %eax
f0100fb4:	50                   	push   %eax
f0100fb5:	8d 83 db 52 f8 ff    	lea    -0x7ad25(%ebx),%eax
f0100fbb:	50                   	push   %eax
f0100fbc:	e8 57 33 00 00       	call   f0104318 <cprintf>
f0100fc1:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100fc4:	8d bb ec 52 f8 ff    	lea    -0x7ad14(%ebx),%edi
f0100fca:	eb 4a                	jmp    f0101016 <monitor+0xb0>
f0100fcc:	83 ec 08             	sub    $0x8,%esp
f0100fcf:	0f be c0             	movsbl %al,%eax
f0100fd2:	50                   	push   %eax
f0100fd3:	57                   	push   %edi
f0100fd4:	e8 fd 42 00 00       	call   f01052d6 <strchr>
f0100fd9:	83 c4 10             	add    $0x10,%esp
f0100fdc:	85 c0                	test   %eax,%eax
f0100fde:	74 08                	je     f0100fe8 <monitor+0x82>
			*buf++ = 0;
f0100fe0:	c6 06 00             	movb   $0x0,(%esi)
f0100fe3:	8d 76 01             	lea    0x1(%esi),%esi
f0100fe6:	eb 76                	jmp    f010105e <monitor+0xf8>
		if (*buf == 0)
f0100fe8:	80 3e 00             	cmpb   $0x0,(%esi)
f0100feb:	74 7c                	je     f0101069 <monitor+0x103>
		if (argc == MAXARGS-1) {
f0100fed:	83 7d 94 0f          	cmpl   $0xf,-0x6c(%ebp)
f0100ff1:	74 0f                	je     f0101002 <monitor+0x9c>
		argv[argc++] = buf;
f0100ff3:	8b 45 94             	mov    -0x6c(%ebp),%eax
f0100ff6:	8d 48 01             	lea    0x1(%eax),%ecx
f0100ff9:	89 4d 94             	mov    %ecx,-0x6c(%ebp)
f0100ffc:	89 74 85 a0          	mov    %esi,-0x60(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0101000:	eb 41                	jmp    f0101043 <monitor+0xdd>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0101002:	83 ec 08             	sub    $0x8,%esp
f0101005:	6a 10                	push   $0x10
f0101007:	8d 83 f1 52 f8 ff    	lea    -0x7ad0f(%ebx),%eax
f010100d:	50                   	push   %eax
f010100e:	e8 05 33 00 00       	call   f0104318 <cprintf>
			return 0;
f0101013:	83 c4 10             	add    $0x10,%esp

	while (1)
	{
		buf = readline("K> ");
f0101016:	8d 83 e8 52 f8 ff    	lea    -0x7ad18(%ebx),%eax
f010101c:	89 c6                	mov    %eax,%esi
f010101e:	83 ec 0c             	sub    $0xc,%esp
f0101021:	56                   	push   %esi
f0101022:	e8 5e 40 00 00       	call   f0105085 <readline>
		if (buf != NULL)
f0101027:	83 c4 10             	add    $0x10,%esp
f010102a:	85 c0                	test   %eax,%eax
f010102c:	74 f0                	je     f010101e <monitor+0xb8>
	argv[argc] = 0;
f010102e:	89 c6                	mov    %eax,%esi
f0101030:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
	argc = 0;
f0101037:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
f010103e:	eb 1e                	jmp    f010105e <monitor+0xf8>
			buf++;
f0101040:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0101043:	0f b6 06             	movzbl (%esi),%eax
f0101046:	84 c0                	test   %al,%al
f0101048:	74 14                	je     f010105e <monitor+0xf8>
f010104a:	83 ec 08             	sub    $0x8,%esp
f010104d:	0f be c0             	movsbl %al,%eax
f0101050:	50                   	push   %eax
f0101051:	57                   	push   %edi
f0101052:	e8 7f 42 00 00       	call   f01052d6 <strchr>
f0101057:	83 c4 10             	add    $0x10,%esp
f010105a:	85 c0                	test   %eax,%eax
f010105c:	74 e2                	je     f0101040 <monitor+0xda>
		while (*buf && strchr(WHITESPACE, *buf))
f010105e:	0f b6 06             	movzbl (%esi),%eax
f0101061:	84 c0                	test   %al,%al
f0101063:	0f 85 63 ff ff ff    	jne    f0100fcc <monitor+0x66>
	argv[argc] = 0;
f0101069:	8b 45 94             	mov    -0x6c(%ebp),%eax
f010106c:	c7 44 85 a0 00 00 00 	movl   $0x0,-0x60(%ebp,%eax,4)
f0101073:	00 
	if (argc == 0)
f0101074:	85 c0                	test   %eax,%eax
f0101076:	74 9e                	je     f0101016 <monitor+0xb0>
f0101078:	8d b3 d8 1f 00 00    	lea    0x1fd8(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010107e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101083:	89 7d 90             	mov    %edi,-0x70(%ebp)
f0101086:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0101088:	83 ec 08             	sub    $0x8,%esp
f010108b:	ff 36                	push   (%esi)
f010108d:	ff 75 a0             	push   -0x60(%ebp)
f0101090:	e8 e1 41 00 00       	call   f0105276 <strcmp>
f0101095:	83 c4 10             	add    $0x10,%esp
f0101098:	85 c0                	test   %eax,%eax
f010109a:	74 28                	je     f01010c4 <monitor+0x15e>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010109c:	83 c7 01             	add    $0x1,%edi
f010109f:	83 c6 0c             	add    $0xc,%esi
f01010a2:	83 ff 04             	cmp    $0x4,%edi
f01010a5:	75 e1                	jne    f0101088 <monitor+0x122>
	cprintf("Unknown command '%s'\n", argv[0]);
f01010a7:	8b 7d 90             	mov    -0x70(%ebp),%edi
f01010aa:	83 ec 08             	sub    $0x8,%esp
f01010ad:	ff 75 a0             	push   -0x60(%ebp)
f01010b0:	8d 83 0e 53 f8 ff    	lea    -0x7acf2(%ebx),%eax
f01010b6:	50                   	push   %eax
f01010b7:	e8 5c 32 00 00       	call   f0104318 <cprintf>
	return 0;
f01010bc:	83 c4 10             	add    $0x10,%esp
f01010bf:	e9 52 ff ff ff       	jmp    f0101016 <monitor+0xb0>
			return commands[i].func(argc, argv, tf);
f01010c4:	89 f8                	mov    %edi,%eax
f01010c6:	8b 7d 90             	mov    -0x70(%ebp),%edi
f01010c9:	83 ec 04             	sub    $0x4,%esp
f01010cc:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01010cf:	ff 75 08             	push   0x8(%ebp)
f01010d2:	8d 55 a0             	lea    -0x60(%ebp),%edx
f01010d5:	52                   	push   %edx
f01010d6:	ff 75 94             	push   -0x6c(%ebp)
f01010d9:	ff 94 83 e0 1f 00 00 	call   *0x1fe0(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f01010e0:	83 c4 10             	add    $0x10,%esp
f01010e3:	85 c0                	test   %eax,%eax
f01010e5:	0f 89 2b ff ff ff    	jns    f0101016 <monitor+0xb0>
				break;
	}
}
f01010eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010ee:	5b                   	pop    %ebx
f01010ef:	5e                   	pop    %esi
f01010f0:	5f                   	pop    %edi
f01010f1:	5d                   	pop    %ebp
f01010f2:	c3                   	ret    

f01010f3 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01010f3:	55                   	push   %ebp
f01010f4:	89 e5                	mov    %esp,%ebp
f01010f6:	56                   	push   %esi
f01010f7:	53                   	push   %ebx
f01010f8:	e8 94 f0 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01010fd:	81 c3 6b f7 07 00    	add    $0x7f76b,%ebx
f0101103:	89 c6                	mov    %eax,%esi
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0101105:	83 bb 14 23 00 00 00 	cmpl   $0x0,0x2314(%ebx)
f010110c:	74 21                	je     f010112f <boot_alloc+0x3c>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f010110e:	8b 83 14 23 00 00    	mov    0x2314(%ebx),%eax
	// cprintf("next free origin: 0x%x\n", nextfree);
	nextfree = nextfree + ROUNDUP(n,PGSIZE);
f0101114:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f010111a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0101120:	01 c6                	add    %eax,%esi
f0101122:	89 b3 14 23 00 00    	mov    %esi,0x2314(%ebx)
	// cprintf("next free after: 0x%x\n", nextfree);
	return result;
}
f0101128:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010112b:	5b                   	pop    %ebx
f010112c:	5e                   	pop    %esi
f010112d:	5d                   	pop    %ebp
f010112e:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010112f:	c7 c2 40 38 18 f0    	mov    $0xf0183840,%edx
f0101135:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax
f010113b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101140:	89 83 14 23 00 00    	mov    %eax,0x2314(%ebx)
		cprintf("###end 0x%x\n", (u32)end);
f0101146:	83 ec 08             	sub    $0x8,%esp
f0101149:	52                   	push   %edx
f010114a:	8d 83 d1 55 f8 ff    	lea    -0x7aa2f(%ebx),%eax
f0101150:	50                   	push   %eax
f0101151:	e8 c2 31 00 00       	call   f0104318 <cprintf>
		cprintf("###first free 0x%x\n", (u32)nextfree);
f0101156:	83 c4 08             	add    $0x8,%esp
f0101159:	ff b3 14 23 00 00    	push   0x2314(%ebx)
f010115f:	8d 83 de 55 f8 ff    	lea    -0x7aa22(%ebx),%eax
f0101165:	50                   	push   %eax
f0101166:	e8 ad 31 00 00       	call   f0104318 <cprintf>
f010116b:	83 c4 10             	add    $0x10,%esp
f010116e:	eb 9e                	jmp    f010110e <boot_alloc+0x1b>

f0101170 <nvram_read>:
{
f0101170:	55                   	push   %ebp
f0101171:	89 e5                	mov    %esp,%ebp
f0101173:	57                   	push   %edi
f0101174:	56                   	push   %esi
f0101175:	53                   	push   %ebx
f0101176:	83 ec 18             	sub    $0x18,%esp
f0101179:	e8 13 f0 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f010117e:	81 c3 ea f6 07 00    	add    $0x7f6ea,%ebx
f0101184:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101186:	50                   	push   %eax
f0101187:	e8 05 31 00 00       	call   f0104291 <mc146818_read>
f010118c:	89 c7                	mov    %eax,%edi
f010118e:	83 c6 01             	add    $0x1,%esi
f0101191:	89 34 24             	mov    %esi,(%esp)
f0101194:	e8 f8 30 00 00       	call   f0104291 <mc146818_read>
f0101199:	c1 e0 08             	shl    $0x8,%eax
f010119c:	09 f8                	or     %edi,%eax
}
f010119e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011a1:	5b                   	pop    %ebx
f01011a2:	5e                   	pop    %esi
f01011a3:	5f                   	pop    %edi
f01011a4:	5d                   	pop    %ebp
f01011a5:	c3                   	ret    

f01011a6 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01011a6:	55                   	push   %ebp
f01011a7:	89 e5                	mov    %esp,%ebp
f01011a9:	53                   	push   %ebx
f01011aa:	83 ec 04             	sub    $0x4,%esp
f01011ad:	e8 44 28 00 00       	call   f01039f6 <__x86.get_pc_thunk.cx>
f01011b2:	81 c1 b6 f6 07 00    	add    $0x7f6b6,%ecx
f01011b8:	89 c3                	mov    %eax,%ebx
f01011ba:	89 d0                	mov    %edx,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01011bc:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f01011bf:	8b 14 93             	mov    (%ebx,%edx,4),%edx
f01011c2:	f6 c2 01             	test   $0x1,%dl
f01011c5:	74 54                	je     f010121b <check_va2pa+0x75>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01011c7:	89 d3                	mov    %edx,%ebx
f01011c9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011cf:	c1 ea 0c             	shr    $0xc,%edx
f01011d2:	3b 91 10 23 00 00    	cmp    0x2310(%ecx),%edx
f01011d8:	73 26                	jae    f0101200 <check_va2pa+0x5a>
	if (!(p[PTX(va)] & PTE_P))
f01011da:	c1 e8 0c             	shr    $0xc,%eax
f01011dd:	25 ff 03 00 00       	and    $0x3ff,%eax
f01011e2:	8b 94 83 00 00 00 f0 	mov    -0x10000000(%ebx,%eax,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01011e9:	89 d0                	mov    %edx,%eax
f01011eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011f0:	f6 c2 01             	test   $0x1,%dl
f01011f3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01011f8:	0f 44 c2             	cmove  %edx,%eax
}
f01011fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011fe:	c9                   	leave  
f01011ff:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101200:	53                   	push   %ebx
f0101201:	8d 81 a0 59 f8 ff    	lea    -0x7a660(%ecx),%eax
f0101207:	50                   	push   %eax
f0101208:	68 57 03 00 00       	push   $0x357
f010120d:	8d 81 f2 55 f8 ff    	lea    -0x7aa0e(%ecx),%eax
f0101213:	50                   	push   %eax
f0101214:	89 cb                	mov    %ecx,%ebx
f0101216:	e8 c0 ee ff ff       	call   f01000db <_panic>
		return ~0;
f010121b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101220:	eb d9                	jmp    f01011fb <check_va2pa+0x55>

f0101222 <check_page_free_list>:
{
f0101222:	55                   	push   %ebp
f0101223:	89 e5                	mov    %esp,%ebp
f0101225:	57                   	push   %edi
f0101226:	56                   	push   %esi
f0101227:	53                   	push   %ebx
f0101228:	83 ec 2c             	sub    $0x2c,%esp
f010122b:	e8 61 ef ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0101230:	81 c3 38 f6 07 00    	add    $0x7f638,%ebx
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101236:	84 c0                	test   %al,%al
f0101238:	0f 85 db 02 00 00    	jne    f0101519 <check_page_free_list+0x2f7>
	if (!page_free_list)
f010123e:	83 bb 18 23 00 00 00 	cmpl   $0x0,0x2318(%ebx)
f0101245:	74 0a                	je     f0101251 <check_page_free_list+0x2f>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101247:	bf 00 04 00 00       	mov    $0x400,%edi
f010124c:	e9 4a 03 00 00       	jmp    f010159b <check_page_free_list+0x379>
		panic("'page_free_list' is a null pointer!");
f0101251:	83 ec 04             	sub    $0x4,%esp
f0101254:	8d 83 c4 59 f8 ff    	lea    -0x7a63c(%ebx),%eax
f010125a:	50                   	push   %eax
f010125b:	68 8e 02 00 00       	push   $0x28e
f0101260:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101266:	50                   	push   %eax
f0101267:	e8 6f ee ff ff       	call   f01000db <_panic>
f010126c:	50                   	push   %eax
f010126d:	8d 83 a0 59 f8 ff    	lea    -0x7a660(%ebx),%eax
f0101273:	50                   	push   %eax
f0101274:	6a 5c                	push   $0x5c
f0101276:	8d 83 35 56 f8 ff    	lea    -0x7a9cb(%ebx),%eax
f010127c:	50                   	push   %eax
f010127d:	e8 59 ee ff ff       	call   f01000db <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101282:	8b 36                	mov    (%esi),%esi
f0101284:	85 f6                	test   %esi,%esi
f0101286:	74 41                	je     f01012c9 <check_page_free_list+0xa7>
void boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101288:	89 f0                	mov    %esi,%eax
f010128a:	2b 83 08 23 00 00    	sub    0x2308(%ebx),%eax
f0101290:	c1 f8 03             	sar    $0x3,%eax
f0101293:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101296:	89 c2                	mov    %eax,%edx
f0101298:	c1 ea 16             	shr    $0x16,%edx
f010129b:	39 fa                	cmp    %edi,%edx
f010129d:	73 e3                	jae    f0101282 <check_page_free_list+0x60>
	if (PGNUM(pa) >= npages)
f010129f:	89 c2                	mov    %eax,%edx
f01012a1:	c1 ea 0c             	shr    $0xc,%edx
f01012a4:	3b 93 10 23 00 00    	cmp    0x2310(%ebx),%edx
f01012aa:	73 c0                	jae    f010126c <check_page_free_list+0x4a>
			memset(page2kva(pp), 0x97, 128);
f01012ac:	83 ec 04             	sub    $0x4,%esp
f01012af:	68 80 00 00 00       	push   $0x80
f01012b4:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01012b9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012be:	50                   	push   %eax
f01012bf:	e8 51 40 00 00       	call   f0105315 <memset>
f01012c4:	83 c4 10             	add    $0x10,%esp
f01012c7:	eb b9                	jmp    f0101282 <check_page_free_list+0x60>
	cprintf("pfl 0x%x\n", (int)(page_free_list));
f01012c9:	83 ec 08             	sub    $0x8,%esp
f01012cc:	ff b3 18 23 00 00    	push   0x2318(%ebx)
f01012d2:	8d 83 43 56 f8 ff    	lea    -0x7a9bd(%ebx),%eax
f01012d8:	50                   	push   %eax
f01012d9:	e8 3a 30 00 00       	call   f0104318 <cprintf>
	cprintf("pfl_next 0x%x\n", (int)(page_free_list->pp_link));
f01012de:	83 c4 08             	add    $0x8,%esp
f01012e1:	8b 83 18 23 00 00    	mov    0x2318(%ebx),%eax
f01012e7:	ff 30                	push   (%eax)
f01012e9:	8d 83 4d 56 f8 ff    	lea    -0x7a9b3(%ebx),%eax
f01012ef:	50                   	push   %eax
f01012f0:	e8 23 30 00 00       	call   f0104318 <cprintf>
	first_free_page = (char *) boot_alloc(0);
f01012f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01012fa:	e8 f4 fd ff ff       	call   f01010f3 <boot_alloc>
f01012ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101302:	8b 93 18 23 00 00    	mov    0x2318(%ebx),%edx
		assert(pp >= pages);
f0101308:	8b 8b 08 23 00 00    	mov    0x2308(%ebx),%ecx
		assert(pp < pages + npages);
f010130e:	8b 83 10 23 00 00    	mov    0x2310(%ebx),%eax
f0101314:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101317:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010131a:	83 c4 10             	add    $0x10,%esp
	int nfree_basemem = 0, nfree_extmem = 0;
f010131d:	bf 00 00 00 00       	mov    $0x0,%edi
f0101322:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0101329:	89 7d d0             	mov    %edi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010132c:	e9 f3 00 00 00       	jmp    f0101424 <check_page_free_list+0x202>
		assert(pp >= pages);
f0101331:	8d 83 5c 56 f8 ff    	lea    -0x7a9a4(%ebx),%eax
f0101337:	50                   	push   %eax
f0101338:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010133e:	50                   	push   %eax
f010133f:	68 ad 02 00 00       	push   $0x2ad
f0101344:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010134a:	50                   	push   %eax
f010134b:	e8 8b ed ff ff       	call   f01000db <_panic>
		assert(pp < pages + npages);
f0101350:	8d 83 7d 56 f8 ff    	lea    -0x7a983(%ebx),%eax
f0101356:	50                   	push   %eax
f0101357:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010135d:	50                   	push   %eax
f010135e:	68 ae 02 00 00       	push   $0x2ae
f0101363:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101369:	50                   	push   %eax
f010136a:	e8 6c ed ff ff       	call   f01000db <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010136f:	8d 83 e8 59 f8 ff    	lea    -0x7a618(%ebx),%eax
f0101375:	50                   	push   %eax
f0101376:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010137c:	50                   	push   %eax
f010137d:	68 af 02 00 00       	push   $0x2af
f0101382:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101388:	50                   	push   %eax
f0101389:	e8 4d ed ff ff       	call   f01000db <_panic>
		assert(page2pa(pp) != 0);
f010138e:	8d 83 91 56 f8 ff    	lea    -0x7a96f(%ebx),%eax
f0101394:	50                   	push   %eax
f0101395:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010139b:	50                   	push   %eax
f010139c:	68 b2 02 00 00       	push   $0x2b2
f01013a1:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01013a7:	50                   	push   %eax
f01013a8:	e8 2e ed ff ff       	call   f01000db <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01013ad:	8d 83 a2 56 f8 ff    	lea    -0x7a95e(%ebx),%eax
f01013b3:	50                   	push   %eax
f01013b4:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01013ba:	50                   	push   %eax
f01013bb:	68 b3 02 00 00       	push   $0x2b3
f01013c0:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01013c6:	50                   	push   %eax
f01013c7:	e8 0f ed ff ff       	call   f01000db <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01013cc:	8d 83 1c 5a f8 ff    	lea    -0x7a5e4(%ebx),%eax
f01013d2:	50                   	push   %eax
f01013d3:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01013d9:	50                   	push   %eax
f01013da:	68 b4 02 00 00       	push   $0x2b4
f01013df:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01013e5:	50                   	push   %eax
f01013e6:	e8 f0 ec ff ff       	call   f01000db <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f01013eb:	8d 83 bb 56 f8 ff    	lea    -0x7a945(%ebx),%eax
f01013f1:	50                   	push   %eax
f01013f2:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01013f8:	50                   	push   %eax
f01013f9:	68 b5 02 00 00       	push   $0x2b5
f01013fe:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101404:	50                   	push   %eax
f0101405:	e8 d1 ec ff ff       	call   f01000db <_panic>
	if (PGNUM(pa) >= npages)
f010140a:	89 c7                	mov    %eax,%edi
f010140c:	c1 ef 0c             	shr    $0xc,%edi
f010140f:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101412:	76 6e                	jbe    f0101482 <check_page_free_list+0x260>
	return (void *)(pa + KERNBASE);
f0101414:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101419:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f010141c:	77 7a                	ja     f0101498 <check_page_free_list+0x276>
			++nfree_extmem;
f010141e:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101422:	8b 12                	mov    (%edx),%edx
f0101424:	85 d2                	test   %edx,%edx
f0101426:	0f 84 8b 00 00 00    	je     f01014b7 <check_page_free_list+0x295>
		assert(pp >= pages);
f010142c:	39 d1                	cmp    %edx,%ecx
f010142e:	0f 87 fd fe ff ff    	ja     f0101331 <check_page_free_list+0x10f>
		assert(pp < pages + npages);
f0101434:	39 d6                	cmp    %edx,%esi
f0101436:	0f 86 14 ff ff ff    	jbe    f0101350 <check_page_free_list+0x12e>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010143c:	89 d0                	mov    %edx,%eax
f010143e:	29 c8                	sub    %ecx,%eax
f0101440:	a8 07                	test   $0x7,%al
f0101442:	0f 85 27 ff ff ff    	jne    f010136f <check_page_free_list+0x14d>
	return (pp - pages) << PGSHIFT;
f0101448:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f010144b:	c1 e0 0c             	shl    $0xc,%eax
f010144e:	0f 84 3a ff ff ff    	je     f010138e <check_page_free_list+0x16c>
		assert(page2pa(pp) != IOPHYSMEM);
f0101454:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101459:	0f 84 4e ff ff ff    	je     f01013ad <check_page_free_list+0x18b>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010145f:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101464:	0f 84 62 ff ff ff    	je     f01013cc <check_page_free_list+0x1aa>
		assert(page2pa(pp) != EXTPHYSMEM);
f010146a:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010146f:	0f 84 76 ff ff ff    	je     f01013eb <check_page_free_list+0x1c9>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101475:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010147a:	77 8e                	ja     f010140a <check_page_free_list+0x1e8>
			++nfree_basemem;
f010147c:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
f0101480:	eb a0                	jmp    f0101422 <check_page_free_list+0x200>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101482:	50                   	push   %eax
f0101483:	8d 83 a0 59 f8 ff    	lea    -0x7a660(%ebx),%eax
f0101489:	50                   	push   %eax
f010148a:	6a 5c                	push   $0x5c
f010148c:	8d 83 35 56 f8 ff    	lea    -0x7a9cb(%ebx),%eax
f0101492:	50                   	push   %eax
f0101493:	e8 43 ec ff ff       	call   f01000db <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101498:	8d 83 40 5a f8 ff    	lea    -0x7a5c0(%ebx),%eax
f010149e:	50                   	push   %eax
f010149f:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01014a5:	50                   	push   %eax
f01014a6:	68 b6 02 00 00       	push   $0x2b6
f01014ab:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01014b1:	50                   	push   %eax
f01014b2:	e8 24 ec ff ff       	call   f01000db <_panic>
	assert(nfree_basemem > 0);
f01014b7:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01014ba:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01014be:	7e 1b                	jle    f01014db <check_page_free_list+0x2b9>
	assert(nfree_extmem > 0);
f01014c0:	85 ff                	test   %edi,%edi
f01014c2:	7e 36                	jle    f01014fa <check_page_free_list+0x2d8>
	cprintf("check_page_free_list() succeeded!\n");
f01014c4:	83 ec 0c             	sub    $0xc,%esp
f01014c7:	8d 83 88 5a f8 ff    	lea    -0x7a578(%ebx),%eax
f01014cd:	50                   	push   %eax
f01014ce:	e8 45 2e 00 00       	call   f0104318 <cprintf>
}
f01014d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014d6:	5b                   	pop    %ebx
f01014d7:	5e                   	pop    %esi
f01014d8:	5f                   	pop    %edi
f01014d9:	5d                   	pop    %ebp
f01014da:	c3                   	ret    
	assert(nfree_basemem > 0);
f01014db:	8d 83 d5 56 f8 ff    	lea    -0x7a92b(%ebx),%eax
f01014e1:	50                   	push   %eax
f01014e2:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01014e8:	50                   	push   %eax
f01014e9:	68 be 02 00 00       	push   $0x2be
f01014ee:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01014f4:	50                   	push   %eax
f01014f5:	e8 e1 eb ff ff       	call   f01000db <_panic>
	assert(nfree_extmem > 0);
f01014fa:	8d 83 e7 56 f8 ff    	lea    -0x7a919(%ebx),%eax
f0101500:	50                   	push   %eax
f0101501:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0101507:	50                   	push   %eax
f0101508:	68 bf 02 00 00       	push   $0x2bf
f010150d:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101513:	50                   	push   %eax
f0101514:	e8 c2 eb ff ff       	call   f01000db <_panic>
	if (!page_free_list)
f0101519:	8b 83 18 23 00 00    	mov    0x2318(%ebx),%eax
f010151f:	85 c0                	test   %eax,%eax
f0101521:	0f 84 2a fd ff ff    	je     f0101251 <check_page_free_list+0x2f>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101527:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010152a:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010152d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101530:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101533:	89 c2                	mov    %eax,%edx
f0101535:	2b 93 08 23 00 00    	sub    0x2308(%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010153b:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0101541:	0f 95 c2             	setne  %dl
f0101544:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101547:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f010154b:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f010154d:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101551:	8b 00                	mov    (%eax),%eax
f0101553:	85 c0                	test   %eax,%eax
f0101555:	75 dc                	jne    f0101533 <check_page_free_list+0x311>
		*tp[1] = 0;
f0101557:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010155a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101560:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101563:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101566:	89 02                	mov    %eax,(%edx)
		page_free_list = pp1;
f0101568:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010156b:	89 b3 18 23 00 00    	mov    %esi,0x2318(%ebx)
		cprintf("pp1: 0x%x pp2: 0x%x\n", (int)pp1, (int)pp2);
f0101571:	83 ec 04             	sub    $0x4,%esp
f0101574:	50                   	push   %eax
f0101575:	56                   	push   %esi
f0101576:	8d 83 fe 55 f8 ff    	lea    -0x7aa02(%ebx),%eax
f010157c:	50                   	push   %eax
f010157d:	e8 96 2d 00 00       	call   f0104318 <cprintf>
		cprintf("pp1 next 0x%x\n", (int)(pp1->pp_link));
f0101582:	83 c4 08             	add    $0x8,%esp
f0101585:	ff 36                	push   (%esi)
f0101587:	8d 83 13 56 f8 ff    	lea    -0x7a9ed(%ebx),%eax
f010158d:	50                   	push   %eax
f010158e:	e8 85 2d 00 00       	call   f0104318 <cprintf>
f0101593:	83 c4 10             	add    $0x10,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101596:	bf 01 00 00 00       	mov    $0x1,%edi
	cprintf("low memory finish\n");
f010159b:	83 ec 0c             	sub    $0xc,%esp
f010159e:	8d 83 22 56 f8 ff    	lea    -0x7a9de(%ebx),%eax
f01015a4:	50                   	push   %eax
f01015a5:	e8 6e 2d 00 00       	call   f0104318 <cprintf>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015aa:	8b b3 18 23 00 00    	mov    0x2318(%ebx),%esi
f01015b0:	83 c4 10             	add    $0x10,%esp
f01015b3:	e9 cc fc ff ff       	jmp    f0101284 <check_page_free_list+0x62>

f01015b8 <page_init>:
{
f01015b8:	55                   	push   %ebp
f01015b9:	89 e5                	mov    %esp,%ebp
f01015bb:	57                   	push   %edi
f01015bc:	56                   	push   %esi
f01015bd:	53                   	push   %ebx
f01015be:	e8 2f 24 00 00       	call   f01039f2 <__x86.get_pc_thunk.dx>
f01015c3:	81 c2 a5 f2 07 00    	add    $0x7f2a5,%edx
f01015c9:	8b b2 18 23 00 00    	mov    0x2318(%edx),%esi
	for (i = 0; i < npages; i++) {
f01015cf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01015d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01015d9:	bf 01 00 00 00       	mov    $0x1,%edi
f01015de:	eb 24                	jmp    f0101604 <page_init+0x4c>
f01015e0:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
		pages[i].pp_ref = 0;
f01015e7:	89 cb                	mov    %ecx,%ebx
f01015e9:	03 9a 08 23 00 00    	add    0x2308(%edx),%ebx
f01015ef:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		pages[i].pp_link = page_free_list;
f01015f5:	89 33                	mov    %esi,(%ebx)
		page_free_list = &pages[i];
f01015f7:	89 ce                	mov    %ecx,%esi
f01015f9:	03 b2 08 23 00 00    	add    0x2308(%edx),%esi
	for (i = 0; i < npages; i++) {
f01015ff:	83 c0 01             	add    $0x1,%eax
f0101602:	89 f9                	mov    %edi,%ecx
f0101604:	39 82 10 23 00 00    	cmp    %eax,0x2310(%edx)
f010160a:	77 d4                	ja     f01015e0 <page_init+0x28>
f010160c:	84 c9                	test   %cl,%cl
f010160e:	74 06                	je     f0101616 <page_init+0x5e>
f0101610:	89 b2 18 23 00 00    	mov    %esi,0x2318(%edx)
	pages[1].pp_link = NULL;
f0101616:	8b 82 08 23 00 00    	mov    0x2308(%edx),%eax
f010161c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	unsigned int k_use_end = PDX(kern_pgdir) + PAGE_START + PAGES_SIZE + ENVS_SIZE;
f0101623:	8b 92 0c 23 00 00    	mov    0x230c(%edx),%edx
f0101629:	c1 ea 16             	shr    $0x16,%edx
	pages[k_use_end].pp_link = &pages[0x9f];  //io hole and kernel use
f010162c:	8d 88 f8 04 00 00    	lea    0x4f8(%eax),%ecx
f0101632:	89 8c d0 10 02 00 00 	mov    %ecx,0x210(%eax,%edx,8)
}
f0101639:	5b                   	pop    %ebx
f010163a:	5e                   	pop    %esi
f010163b:	5f                   	pop    %edi
f010163c:	5d                   	pop    %ebp
f010163d:	c3                   	ret    

f010163e <page_alloc>:
{
f010163e:	55                   	push   %ebp
f010163f:	89 e5                	mov    %esp,%ebp
f0101641:	56                   	push   %esi
f0101642:	53                   	push   %ebx
f0101643:	e8 49 eb ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0101648:	81 c3 20 f2 07 00    	add    $0x7f220,%ebx
	if (page_free_list == NULL)
f010164e:	8b b3 18 23 00 00    	mov    0x2318(%ebx),%esi
f0101654:	85 f6                	test   %esi,%esi
f0101656:	74 23                	je     f010167b <page_alloc+0x3d>
	page_free_list = page_free_list->pp_link;
f0101658:	8b 06                	mov    (%esi),%eax
f010165a:	89 83 18 23 00 00    	mov    %eax,0x2318(%ebx)
	alloc_page->pp_ref = 0;
f0101660:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
	alloc_page->pp_link = NULL;
f0101666:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (alloc_flags & ALLOC_ZERO)
f010166c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101670:	75 1d                	jne    f010168f <page_alloc+0x51>
}
f0101672:	89 f0                	mov    %esi,%eax
f0101674:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101677:	5b                   	pop    %ebx
f0101678:	5e                   	pop    %esi
f0101679:	5d                   	pop    %ebp
f010167a:	c3                   	ret    
		cprintf("none free page\n");	
f010167b:	83 ec 0c             	sub    $0xc,%esp
f010167e:	8d 83 f8 56 f8 ff    	lea    -0x7a908(%ebx),%eax
f0101684:	50                   	push   %eax
f0101685:	e8 8e 2c 00 00       	call   f0104318 <cprintf>
		return NULL;
f010168a:	83 c4 10             	add    $0x10,%esp
f010168d:	eb e3                	jmp    f0101672 <page_alloc+0x34>
f010168f:	89 f0                	mov    %esi,%eax
f0101691:	2b 83 08 23 00 00    	sub    0x2308(%ebx),%eax
f0101697:	c1 f8 03             	sar    $0x3,%eax
f010169a:	89 c2                	mov    %eax,%edx
f010169c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010169f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01016a4:	3b 83 10 23 00 00    	cmp    0x2310(%ebx),%eax
f01016aa:	73 1b                	jae    f01016c7 <page_alloc+0x89>
		memset(page2kva(alloc_page), '\0', PGSIZE);
f01016ac:	83 ec 04             	sub    $0x4,%esp
f01016af:	68 00 10 00 00       	push   $0x1000
f01016b4:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01016b6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01016bc:	52                   	push   %edx
f01016bd:	e8 53 3c 00 00       	call   f0105315 <memset>
f01016c2:	83 c4 10             	add    $0x10,%esp
f01016c5:	eb ab                	jmp    f0101672 <page_alloc+0x34>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016c7:	52                   	push   %edx
f01016c8:	8d 83 a0 59 f8 ff    	lea    -0x7a660(%ebx),%eax
f01016ce:	50                   	push   %eax
f01016cf:	6a 5c                	push   $0x5c
f01016d1:	8d 83 35 56 f8 ff    	lea    -0x7a9cb(%ebx),%eax
f01016d7:	50                   	push   %eax
f01016d8:	e8 fe e9 ff ff       	call   f01000db <_panic>

f01016dd <page_free>:
{
f01016dd:	55                   	push   %ebp
f01016de:	89 e5                	mov    %esp,%ebp
f01016e0:	53                   	push   %ebx
f01016e1:	83 ec 04             	sub    $0x4,%esp
f01016e4:	e8 a8 ea ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01016e9:	81 c3 7f f1 07 00    	add    $0x7f17f,%ebx
f01016ef:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL)
f01016f2:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01016f7:	75 18                	jne    f0101711 <page_free+0x34>
f01016f9:	83 38 00             	cmpl   $0x0,(%eax)
f01016fc:	75 13                	jne    f0101711 <page_free+0x34>
	pp->pp_link = page_free_list;
f01016fe:	8b 8b 18 23 00 00    	mov    0x2318(%ebx),%ecx
f0101704:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp; 
f0101706:	89 83 18 23 00 00    	mov    %eax,0x2318(%ebx)
}
f010170c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010170f:	c9                   	leave  
f0101710:	c3                   	ret    
			panic("nonzero pp_ref or illegal pp_link");
f0101711:	83 ec 04             	sub    $0x4,%esp
f0101714:	8d 83 ac 5a f8 ff    	lea    -0x7a554(%ebx),%eax
f010171a:	50                   	push   %eax
f010171b:	68 5c 01 00 00       	push   $0x15c
f0101720:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101726:	50                   	push   %eax
f0101727:	e8 af e9 ff ff       	call   f01000db <_panic>

f010172c <page_decref>:
{
f010172c:	55                   	push   %ebp
f010172d:	89 e5                	mov    %esp,%ebp
f010172f:	83 ec 08             	sub    $0x8,%esp
f0101732:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101735:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101739:	83 e8 01             	sub    $0x1,%eax
f010173c:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101740:	66 85 c0             	test   %ax,%ax
f0101743:	74 02                	je     f0101747 <page_decref+0x1b>
}
f0101745:	c9                   	leave  
f0101746:	c3                   	ret    
		page_free(pp);
f0101747:	83 ec 0c             	sub    $0xc,%esp
f010174a:	52                   	push   %edx
f010174b:	e8 8d ff ff ff       	call   f01016dd <page_free>
f0101750:	83 c4 10             	add    $0x10,%esp
}
f0101753:	eb f0                	jmp    f0101745 <page_decref+0x19>

f0101755 <pgdir_walk>:
{
f0101755:	55                   	push   %ebp
f0101756:	89 e5                	mov    %esp,%ebp
f0101758:	57                   	push   %edi
f0101759:	56                   	push   %esi
f010175a:	53                   	push   %ebx
f010175b:	83 ec 0c             	sub    $0xc,%esp
f010175e:	e8 97 22 00 00       	call   f01039fa <__x86.get_pc_thunk.di>
f0101763:	81 c7 05 f1 07 00    	add    $0x7f105,%edi
	pde_t pd_entry = pgdir[PDX(va)];
f0101769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010176c:	c1 eb 16             	shr    $0x16,%ebx
f010176f:	c1 e3 02             	shl    $0x2,%ebx
f0101772:	03 5d 08             	add    0x8(%ebp),%ebx
f0101775:	8b 03                	mov    (%ebx),%eax
	if ((pd_entry & PTE_P) == 0)
f0101777:	a8 01                	test   $0x1,%al
f0101779:	0f 85 aa 00 00 00    	jne    f0101829 <pgdir_walk+0xd4>
		if (create == false)
f010177f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101783:	0f 84 e2 00 00 00    	je     f010186b <pgdir_walk+0x116>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);
f0101789:	83 ec 0c             	sub    $0xc,%esp
f010178c:	6a 01                	push   $0x1
f010178e:	e8 ab fe ff ff       	call   f010163e <page_alloc>
f0101793:	89 c6                	mov    %eax,%esi
			if (pg)
f0101795:	83 c4 10             	add    $0x10,%esp
f0101798:	85 c0                	test   %eax,%eax
f010179a:	74 6a                	je     f0101806 <pgdir_walk+0xb1>
				pg->pp_ref++;
f010179c:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01017a1:	2b 87 08 23 00 00    	sub    0x2308(%edi),%eax
f01017a7:	c1 f8 03             	sar    $0x3,%eax
f01017aa:	c1 e0 0c             	shl    $0xc,%eax
				pgdir[PDX(va)] = page2pa(pg)|PTE_P;
f01017ad:	83 c8 01             	or     $0x1,%eax
f01017b0:	89 03                	mov    %eax,(%ebx)
				cprintf("alloc pg tab entry: 0x%x\n", page2pa(pg)|PTE_P);
f01017b2:	83 ec 08             	sub    $0x8,%esp
f01017b5:	89 f0                	mov    %esi,%eax
f01017b7:	2b 87 08 23 00 00    	sub    0x2308(%edi),%eax
f01017bd:	c1 f8 03             	sar    $0x3,%eax
f01017c0:	c1 e0 0c             	shl    $0xc,%eax
f01017c3:	83 c8 01             	or     $0x1,%eax
f01017c6:	50                   	push   %eax
f01017c7:	8d 87 08 57 f8 ff    	lea    -0x7a8f8(%edi),%eax
f01017cd:	50                   	push   %eax
f01017ce:	89 fb                	mov    %edi,%ebx
f01017d0:	e8 43 2b 00 00       	call   f0104318 <cprintf>
f01017d5:	2b b7 08 23 00 00    	sub    0x2308(%edi),%esi
f01017db:	c1 fe 03             	sar    $0x3,%esi
f01017de:	89 f2                	mov    %esi,%edx
f01017e0:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01017e3:	81 e6 ff ff 0f 00    	and    $0xfffff,%esi
f01017e9:	83 c4 10             	add    $0x10,%esp
f01017ec:	3b b7 10 23 00 00    	cmp    0x2310(%edi),%esi
f01017f2:	73 1c                	jae    f0101810 <pgdir_walk+0xbb>
				return  (pte_t*)(KADDR(page2pa(pg))) + PTX(va);
f01017f4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01017f7:	c1 e8 0a             	shr    $0xa,%eax
f01017fa:	25 fc 0f 00 00       	and    $0xffc,%eax
f01017ff:	8d b4 02 00 00 00 f0 	lea    -0x10000000(%edx,%eax,1),%esi
}
f0101806:	89 f0                	mov    %esi,%eax
f0101808:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010180b:	5b                   	pop    %ebx
f010180c:	5e                   	pop    %esi
f010180d:	5f                   	pop    %edi
f010180e:	5d                   	pop    %ebp
f010180f:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101810:	52                   	push   %edx
f0101811:	8d 87 a0 59 f8 ff    	lea    -0x7a660(%edi),%eax
f0101817:	50                   	push   %eax
f0101818:	68 98 01 00 00       	push   $0x198
f010181d:	8d 87 f2 55 f8 ff    	lea    -0x7aa0e(%edi),%eax
f0101823:	50                   	push   %eax
f0101824:	e8 b2 e8 ff ff       	call   f01000db <_panic>
		uintptr_t *pt_addr = (uintptr_t*)(KADDR(PTE_ADDR(pd_entry)));
f0101829:	89 c2                	mov    %eax,%edx
f010182b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101831:	c1 e8 0c             	shr    $0xc,%eax
f0101834:	3b 87 10 23 00 00    	cmp    0x2310(%edi),%eax
f010183a:	73 14                	jae    f0101850 <pgdir_walk+0xfb>
		return pt_addr+PTX(va);
f010183c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010183f:	c1 e8 0a             	shr    $0xa,%eax
f0101842:	25 fc 0f 00 00       	and    $0xffc,%eax
f0101847:	8d b4 02 00 00 00 f0 	lea    -0x10000000(%edx,%eax,1),%esi
f010184e:	eb b6                	jmp    f0101806 <pgdir_walk+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101850:	52                   	push   %edx
f0101851:	8d 87 a0 59 f8 ff    	lea    -0x7a660(%edi),%eax
f0101857:	50                   	push   %eax
f0101858:	68 a2 01 00 00       	push   $0x1a2
f010185d:	8d 87 f2 55 f8 ff    	lea    -0x7aa0e(%edi),%eax
f0101863:	50                   	push   %eax
f0101864:	89 fb                	mov    %edi,%ebx
f0101866:	e8 70 e8 ff ff       	call   f01000db <_panic>
			return NULL;
f010186b:	be 00 00 00 00       	mov    $0x0,%esi
f0101870:	eb 94                	jmp    f0101806 <pgdir_walk+0xb1>

f0101872 <boot_map_region>:
{
f0101872:	55                   	push   %ebp
f0101873:	89 e5                	mov    %esp,%ebp
f0101875:	57                   	push   %edi
f0101876:	56                   	push   %esi
f0101877:	53                   	push   %ebx
f0101878:	83 ec 1c             	sub    $0x1c,%esp
f010187b:	e8 11 e9 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0101880:	81 c3 e8 ef 07 00    	add    $0x7efe8,%ebx
f0101886:	8b 75 10             	mov    0x10(%ebp),%esi
	cprintf("b map  va:0x%x pa: 0x%x size: 0x%x\n", va, pa, size);
f0101889:	56                   	push   %esi
f010188a:	ff 75 14             	push   0x14(%ebp)
f010188d:	ff 75 0c             	push   0xc(%ebp)
f0101890:	8d 83 d0 5a f8 ff    	lea    -0x7a530(%ebx),%eax
f0101896:	50                   	push   %eax
f0101897:	e8 7c 2a 00 00       	call   f0104318 <cprintf>
	for (int i = 0; i<size/PGSIZE; i++)
f010189c:	c1 ee 0c             	shr    $0xc,%esi
f010189f:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01018a2:	83 c4 10             	add    $0x10,%esp
f01018a5:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01018a8:	be 00 00 00 00       	mov    $0x0,%esi
	int j = 0;
f01018ad:	ba 00 00 00 00       	mov    $0x0,%edx
	pte_t *pt_entry  = NULL;
f01018b2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			cprintf("pde pos 0x%x\n", PDX(va+PGSIZE*i));
f01018b9:	8d 83 22 57 f8 ff    	lea    -0x7a8de(%ebx),%eax
f01018bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
		*(pt_entry+j) = (pa+i*PGSIZE) | perm | PTE_P;
f01018c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01018c5:	29 f8                	sub    %edi,%eax
f01018c7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (int i = 0; i<size/PGSIZE; i++)
f01018ca:	eb 1d                	jmp    f01018e9 <boot_map_region+0x77>
		*(pt_entry+j) = (pa+i*PGSIZE) | perm | PTE_P;
f01018cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01018cf:	01 f8                	add    %edi,%eax
f01018d1:	0b 45 18             	or     0x18(%ebp),%eax
f01018d4:	83 c8 01             	or     $0x1,%eax
f01018d7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01018da:	89 04 91             	mov    %eax,(%ecx,%edx,4)
		j++;
f01018dd:	83 c2 01             	add    $0x1,%edx
	for (int i = 0; i<size/PGSIZE; i++)
f01018e0:	83 c6 01             	add    $0x1,%esi
f01018e3:	81 c7 00 10 00 00    	add    $0x1000,%edi
f01018e9:	3b 75 e0             	cmp    -0x20(%ebp),%esi
f01018ec:	74 3d                	je     f010192b <boot_map_region+0xb9>
		if (i % 1024 == 0)
f01018ee:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f01018f4:	75 d6                	jne    f01018cc <boot_map_region+0x5a>
			pt_entry = pgdir_walk(pgdir, (uintptr_t*)va+PGSIZE*i/4, 1);
f01018f6:	83 ec 04             	sub    $0x4,%esp
f01018f9:	6a 01                	push   $0x1
f01018fb:	57                   	push   %edi
f01018fc:	ff 75 08             	push   0x8(%ebp)
f01018ff:	e8 51 fe ff ff       	call   f0101755 <pgdir_walk>
f0101904:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			pgdir[PDX(va+PGSIZE*i)] |= perm;
f0101907:	89 f8                	mov    %edi,%eax
f0101909:	c1 e8 16             	shr    $0x16,%eax
f010190c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010190f:	8b 55 18             	mov    0x18(%ebp),%edx
f0101912:	09 14 81             	or     %edx,(%ecx,%eax,4)
			cprintf("pde pos 0x%x\n", PDX(va+PGSIZE*i));
f0101915:	83 c4 08             	add    $0x8,%esp
f0101918:	50                   	push   %eax
f0101919:	ff 75 d8             	push   -0x28(%ebp)
f010191c:	e8 f7 29 00 00       	call   f0104318 <cprintf>
f0101921:	83 c4 10             	add    $0x10,%esp
			j = 0;
f0101924:	ba 00 00 00 00       	mov    $0x0,%edx
f0101929:	eb a1                	jmp    f01018cc <boot_map_region+0x5a>
}
f010192b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010192e:	5b                   	pop    %ebx
f010192f:	5e                   	pop    %esi
f0101930:	5f                   	pop    %edi
f0101931:	5d                   	pop    %ebp
f0101932:	c3                   	ret    

f0101933 <page_lookup>:
{
f0101933:	55                   	push   %ebp
f0101934:	89 e5                	mov    %esp,%ebp
f0101936:	56                   	push   %esi
f0101937:	53                   	push   %ebx
f0101938:	e8 ea ed ff ff       	call   f0100727 <__x86.get_pc_thunk.si>
f010193d:	81 c6 2b ef 07 00    	add    $0x7ef2b,%esi
f0101943:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *ptr = pgdir_walk(pgdir, va, 0);
f0101946:	83 ec 04             	sub    $0x4,%esp
f0101949:	6a 00                	push   $0x0
f010194b:	ff 75 0c             	push   0xc(%ebp)
f010194e:	ff 75 08             	push   0x8(%ebp)
f0101951:	e8 ff fd ff ff       	call   f0101755 <pgdir_walk>
	if (pte_store)
f0101956:	83 c4 10             	add    $0x10,%esp
f0101959:	85 db                	test   %ebx,%ebx
f010195b:	74 02                	je     f010195f <page_lookup+0x2c>
		*pte_store = ptr;
f010195d:	89 03                	mov    %eax,(%ebx)
	if (ptr && (*ptr & PTE_P))
f010195f:	85 c0                	test   %eax,%eax
f0101961:	74 0c                	je     f010196f <page_lookup+0x3c>
f0101963:	8b 10                	mov    (%eax),%edx
	return NULL;
f0101965:	b8 00 00 00 00       	mov    $0x0,%eax
	if (ptr && (*ptr & PTE_P))
f010196a:	f6 c2 01             	test   $0x1,%dl
f010196d:	75 07                	jne    f0101976 <page_lookup+0x43>
}
f010196f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101972:	5b                   	pop    %ebx
f0101973:	5e                   	pop    %esi
f0101974:	5d                   	pop    %ebp
f0101975:	c3                   	ret    
f0101976:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101979:	39 96 10 23 00 00    	cmp    %edx,0x2310(%esi)
f010197f:	76 0b                	jbe    f010198c <page_lookup+0x59>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101981:	8b 86 08 23 00 00    	mov    0x2308(%esi),%eax
f0101987:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return pa2page(PTE_ADDR(*ptr));
f010198a:	eb e3                	jmp    f010196f <page_lookup+0x3c>
		panic("pa2page called with invalid pa");
f010198c:	83 ec 04             	sub    $0x4,%esp
f010198f:	8d 86 f4 5a f8 ff    	lea    -0x7a50c(%esi),%eax
f0101995:	50                   	push   %eax
f0101996:	6a 55                	push   $0x55
f0101998:	8d 86 35 56 f8 ff    	lea    -0x7a9cb(%esi),%eax
f010199e:	50                   	push   %eax
f010199f:	89 f3                	mov    %esi,%ebx
f01019a1:	e8 35 e7 ff ff       	call   f01000db <_panic>

f01019a6 <page_remove>:
{
f01019a6:	55                   	push   %ebp
f01019a7:	89 e5                	mov    %esp,%ebp
f01019a9:	56                   	push   %esi
f01019aa:	53                   	push   %ebx
f01019ab:	8b 75 08             	mov    0x8(%ebp),%esi
f01019ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pgptr = page_lookup(pgdir, va, NULL);
f01019b1:	83 ec 04             	sub    $0x4,%esp
f01019b4:	6a 00                	push   $0x0
f01019b6:	53                   	push   %ebx
f01019b7:	56                   	push   %esi
f01019b8:	e8 76 ff ff ff       	call   f0101933 <page_lookup>
	if (!pgptr)
f01019bd:	83 c4 10             	add    $0x10,%esp
f01019c0:	85 c0                	test   %eax,%eax
f01019c2:	74 21                	je     f01019e5 <page_remove+0x3f>
	page_decref(pgptr);
f01019c4:	83 ec 0c             	sub    $0xc,%esp
f01019c7:	50                   	push   %eax
f01019c8:	e8 5f fd ff ff       	call   f010172c <page_decref>
	pte_t *pteptr = pgdir_walk(pgdir, va, 0);
f01019cd:	83 c4 0c             	add    $0xc,%esp
f01019d0:	6a 00                	push   $0x0
f01019d2:	53                   	push   %ebx
f01019d3:	56                   	push   %esi
f01019d4:	e8 7c fd ff ff       	call   f0101755 <pgdir_walk>
	*pteptr = 0;
f01019d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01019df:	0f 01 3b             	invlpg (%ebx)
}
f01019e2:	83 c4 10             	add    $0x10,%esp
}
f01019e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01019e8:	5b                   	pop    %ebx
f01019e9:	5e                   	pop    %esi
f01019ea:	5d                   	pop    %ebp
f01019eb:	c3                   	ret    

f01019ec <page_insert>:
{
f01019ec:	55                   	push   %ebp
f01019ed:	89 e5                	mov    %esp,%ebp
f01019ef:	57                   	push   %edi
f01019f0:	56                   	push   %esi
f01019f1:	53                   	push   %ebx
f01019f2:	83 ec 20             	sub    $0x20,%esp
f01019f5:	e8 00 20 00 00       	call   f01039fa <__x86.get_pc_thunk.di>
f01019fa:	81 c7 6e ee 07 00    	add    $0x7ee6e,%edi
f0101a00:	8b 75 08             	mov    0x8(%ebp),%esi
	pte_t *pte_ptr = pgdir_walk(pgdir, va, 0);
f0101a03:	6a 00                	push   $0x0
f0101a05:	ff 75 10             	push   0x10(%ebp)
f0101a08:	56                   	push   %esi
f0101a09:	e8 47 fd ff ff       	call   f0101755 <pgdir_walk>
	if (!pte_ptr)
f0101a0e:	83 c4 10             	add    $0x10,%esp
f0101a11:	85 c0                	test   %eax,%eax
f0101a13:	74 43                	je     f0101a58 <page_insert+0x6c>
f0101a15:	89 c3                	mov    %eax,%ebx
		pp->pp_ref++;
f0101a17:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a1a:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		if (*pte_ptr & PTE_P)
f0101a1f:	f6 03 01             	testb  $0x1,(%ebx)
f0101a22:	0f 85 0c 01 00 00    	jne    f0101b34 <page_insert+0x148>
	return (pp - pages) << PGSHIFT;
f0101a28:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a2b:	2b 87 08 23 00 00    	sub    0x2308(%edi),%eax
f0101a31:	c1 f8 03             	sar    $0x3,%eax
f0101a34:	c1 e0 0c             	shl    $0xc,%eax
		*pte_ptr = page2pa(pp) | perm | PTE_P;
f0101a37:	0b 45 14             	or     0x14(%ebp),%eax
f0101a3a:	83 c8 01             	or     $0x1,%eax
f0101a3d:	89 03                	mov    %eax,(%ebx)
		pgdir[PDX(va)] = pgdir[PDX(va)] | perm;
f0101a3f:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a42:	c1 e8 16             	shr    $0x16,%eax
f0101a45:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101a48:	09 0c 86             	or     %ecx,(%esi,%eax,4)
	return 0;
f0101a4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a50:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101a53:	5b                   	pop    %ebx
f0101a54:	5e                   	pop    %esi
f0101a55:	5f                   	pop    %edi
f0101a56:	5d                   	pop    %ebp
f0101a57:	c3                   	ret    
		struct PageInfo * pg_ptr = page_alloc(ALLOC_ZERO);
f0101a58:	83 ec 0c             	sub    $0xc,%esp
f0101a5b:	6a 01                	push   $0x1
f0101a5d:	e8 dc fb ff ff       	call   f010163e <page_alloc>
f0101a62:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if (!pg_ptr)
f0101a65:	83 c4 10             	add    $0x10,%esp
f0101a68:	85 c0                	test   %eax,%eax
f0101a6a:	0f 84 8d 00 00 00    	je     f0101afd <page_insert+0x111>
f0101a70:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101a73:	2b 87 08 23 00 00    	sub    0x2308(%edi),%eax
f0101a79:	c1 f8 03             	sar    $0x3,%eax
f0101a7c:	c1 e0 0c             	shl    $0xc,%eax
		cprintf("alloc page table p addr: 0x%x\n", padd);
f0101a7f:	83 ec 08             	sub    $0x8,%esp
f0101a82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101a85:	50                   	push   %eax
f0101a86:	8d 87 14 5b f8 ff    	lea    -0x7a4ec(%edi),%eax
f0101a8c:	50                   	push   %eax
f0101a8d:	89 fb                	mov    %edi,%ebx
f0101a8f:	e8 84 28 00 00       	call   f0104318 <cprintf>
		pgdir[PDX(va)] = padd | PTE_P | perm;
f0101a94:	8b 55 10             	mov    0x10(%ebp),%edx
f0101a97:	c1 ea 16             	shr    $0x16,%edx
f0101a9a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a9d:	89 c8                	mov    %ecx,%eax
f0101a9f:	0b 45 14             	or     0x14(%ebp),%eax
f0101aa2:	83 c8 01             	or     $0x1,%eax
f0101aa5:	89 04 96             	mov    %eax,(%esi,%edx,4)
		pg_ptr->pp_ref++;
f0101aa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101aab:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	if (PGNUM(pa) >= npages)
f0101ab0:	89 c8                	mov    %ecx,%eax
f0101ab2:	c1 e8 0c             	shr    $0xc,%eax
f0101ab5:	83 c4 10             	add    $0x10,%esp
f0101ab8:	3b 87 10 23 00 00    	cmp    0x2310(%edi),%eax
f0101abe:	73 5b                	jae    f0101b1b <page_insert+0x12f>
		kadd[PTX(va)] = page2pa(pp)|perm|PTE_P;
f0101ac0:	8b 55 10             	mov    0x10(%ebp),%edx
f0101ac3:	c1 ea 0c             	shr    $0xc,%edx
f0101ac6:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
	return (pp - pages) << PGSHIFT;
f0101acc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101acf:	2b 87 08 23 00 00    	sub    0x2308(%edi),%eax
f0101ad5:	c1 f8 03             	sar    $0x3,%eax
f0101ad8:	c1 e0 0c             	shl    $0xc,%eax
f0101adb:	0b 45 14             	or     0x14(%ebp),%eax
f0101ade:	83 c8 01             	or     $0x1,%eax
f0101ae1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101ae4:	89 84 91 00 00 00 f0 	mov    %eax,-0x10000000(%ecx,%edx,4)
		pp->pp_ref++;
f0101aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101aee:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return 0;
f0101af3:	b8 00 00 00 00       	mov    $0x0,%eax
f0101af8:	e9 53 ff ff ff       	jmp    f0101a50 <page_insert+0x64>
			cprintf("alloc fail\n");
f0101afd:	83 ec 0c             	sub    $0xc,%esp
f0101b00:	8d 87 30 57 f8 ff    	lea    -0x7a8d0(%edi),%eax
f0101b06:	50                   	push   %eax
f0101b07:	89 fb                	mov    %edi,%ebx
f0101b09:	e8 0a 28 00 00       	call   f0104318 <cprintf>
			return E_NO_MEM;
f0101b0e:	83 c4 10             	add    $0x10,%esp
f0101b11:	b8 04 00 00 00       	mov    $0x4,%eax
f0101b16:	e9 35 ff ff ff       	jmp    f0101a50 <page_insert+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b1b:	51                   	push   %ecx
f0101b1c:	8d 87 a0 59 f8 ff    	lea    -0x7a660(%edi),%eax
f0101b22:	50                   	push   %eax
f0101b23:	68 fa 01 00 00       	push   $0x1fa
f0101b28:	8d 87 f2 55 f8 ff    	lea    -0x7aa0e(%edi),%eax
f0101b2e:	50                   	push   %eax
f0101b2f:	e8 a7 e5 ff ff       	call   f01000db <_panic>
			page_remove(pgdir, va);
f0101b34:	83 ec 08             	sub    $0x8,%esp
f0101b37:	ff 75 10             	push   0x10(%ebp)
f0101b3a:	56                   	push   %esi
f0101b3b:	e8 66 fe ff ff       	call   f01019a6 <page_remove>
f0101b40:	8b 45 10             	mov    0x10(%ebp),%eax
f0101b43:	0f 01 38             	invlpg (%eax)
}
f0101b46:	83 c4 10             	add    $0x10,%esp
f0101b49:	e9 da fe ff ff       	jmp    f0101a28 <page_insert+0x3c>

f0101b4e <mem_init>:
{
f0101b4e:	55                   	push   %ebp
f0101b4f:	89 e5                	mov    %esp,%ebp
f0101b51:	57                   	push   %edi
f0101b52:	56                   	push   %esi
f0101b53:	53                   	push   %ebx
f0101b54:	83 ec 3c             	sub    $0x3c,%esp
f0101b57:	e8 c7 eb ff ff       	call   f0100723 <__x86.get_pc_thunk.ax>
f0101b5c:	05 0c ed 07 00       	add    $0x7ed0c,%eax
f0101b61:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f0101b64:	b8 15 00 00 00       	mov    $0x15,%eax
f0101b69:	e8 02 f6 ff ff       	call   f0101170 <nvram_read>
f0101b6e:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101b70:	b8 17 00 00 00       	mov    $0x17,%eax
f0101b75:	e8 f6 f5 ff ff       	call   f0101170 <nvram_read>
f0101b7a:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101b7c:	b8 34 00 00 00       	mov    $0x34,%eax
f0101b81:	e8 ea f5 ff ff       	call   f0101170 <nvram_read>
	if (ext16mem)
f0101b86:	c1 e0 06             	shl    $0x6,%eax
f0101b89:	0f 84 02 01 00 00    	je     f0101c91 <mem_init+0x143>
		totalmem = 16 * 1024 + ext16mem;
f0101b8f:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101b94:	89 c2                	mov    %eax,%edx
f0101b96:	c1 ea 02             	shr    $0x2,%edx
f0101b99:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b9c:	89 91 10 23 00 00    	mov    %edx,0x2310(%ecx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101ba2:	89 c2                	mov    %eax,%edx
f0101ba4:	29 da                	sub    %ebx,%edx
f0101ba6:	52                   	push   %edx
f0101ba7:	53                   	push   %ebx
f0101ba8:	50                   	push   %eax
f0101ba9:	8d 81 34 5b f8 ff    	lea    -0x7a4cc(%ecx),%eax
f0101baf:	50                   	push   %eax
f0101bb0:	89 cb                	mov    %ecx,%ebx
f0101bb2:	e8 61 27 00 00       	call   f0104318 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101bb7:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101bbc:	e8 32 f5 ff ff       	call   f01010f3 <boot_alloc>
f0101bc1:	89 83 0c 23 00 00    	mov    %eax,0x230c(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f0101bc7:	83 c4 0c             	add    $0xc,%esp
f0101bca:	68 00 10 00 00       	push   $0x1000
f0101bcf:	6a 00                	push   $0x0
f0101bd1:	50                   	push   %eax
f0101bd2:	e8 3e 37 00 00       	call   f0105315 <memset>
	cprintf("bootstack_addr: 0x%x\n", (int)bootstack);
f0101bd7:	83 c4 08             	add    $0x8,%esp
f0101bda:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f0101be0:	8d 83 3c 57 f8 ff    	lea    -0x7a8c4(%ebx),%eax
f0101be6:	50                   	push   %eax
f0101be7:	e8 2c 27 00 00       	call   f0104318 <cprintf>
	cprintf("kern_pgdir addr: 0x%x\n", (u32)kern_pgdir);
f0101bec:	83 c4 08             	add    $0x8,%esp
f0101bef:	ff b3 0c 23 00 00    	push   0x230c(%ebx)
f0101bf5:	8d 83 52 57 f8 ff    	lea    -0x7a8ae(%ebx),%eax
f0101bfb:	50                   	push   %eax
f0101bfc:	e8 17 27 00 00       	call   f0104318 <cprintf>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101c01:	8b 83 0c 23 00 00    	mov    0x230c(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0101c07:	83 c4 10             	add    $0x10,%esp
f0101c0a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101c0f:	0f 86 8c 00 00 00    	jbe    f0101ca1 <mem_init+0x153>
	return (physaddr_t)kva - KERNBASE;
f0101c15:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101c1b:	83 ca 05             	or     $0x5,%edx
f0101c1e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(npages*8);
f0101c24:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101c27:	8b 87 10 23 00 00    	mov    0x2310(%edi),%eax
f0101c2d:	c1 e0 03             	shl    $0x3,%eax
f0101c30:	e8 be f4 ff ff       	call   f01010f3 <boot_alloc>
f0101c35:	89 87 08 23 00 00    	mov    %eax,0x2308(%edi)
	memset(pages, 0, npages * 8);
f0101c3b:	83 ec 04             	sub    $0x4,%esp
f0101c3e:	8b 97 10 23 00 00    	mov    0x2310(%edi),%edx
f0101c44:	c1 e2 03             	shl    $0x3,%edx
f0101c47:	52                   	push   %edx
f0101c48:	6a 00                	push   $0x0
f0101c4a:	50                   	push   %eax
f0101c4b:	89 fb                	mov    %edi,%ebx
f0101c4d:	e8 c3 36 00 00       	call   f0105315 <memset>
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f0101c52:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101c57:	e8 97 f4 ff ff       	call   f01010f3 <boot_alloc>
f0101c5c:	89 c2                	mov    %eax,%edx
f0101c5e:	c7 c0 88 2b 18 f0    	mov    $0xf0182b88,%eax
f0101c64:	89 10                	mov    %edx,(%eax)
	page_init();
f0101c66:	e8 4d f9 ff ff       	call   f01015b8 <page_init>
	check_page_free_list(1);
f0101c6b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101c70:	e8 ad f5 ff ff       	call   f0101222 <check_page_free_list>
	if (!pages)
f0101c75:	83 c4 10             	add    $0x10,%esp
f0101c78:	83 bf 08 23 00 00 00 	cmpl   $0x0,0x2308(%edi)
f0101c7f:	74 3c                	je     f0101cbd <mem_init+0x16f>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101c81:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c84:	8b 80 18 23 00 00    	mov    0x2318(%eax),%eax
f0101c8a:	be 00 00 00 00       	mov    $0x0,%esi
f0101c8f:	eb 4f                	jmp    f0101ce0 <mem_init+0x192>
		totalmem = 1 * 1024 + extmem;
f0101c91:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101c97:	85 f6                	test   %esi,%esi
f0101c99:	0f 44 c3             	cmove  %ebx,%eax
f0101c9c:	e9 f3 fe ff ff       	jmp    f0101b94 <mem_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101ca1:	50                   	push   %eax
f0101ca2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ca5:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f0101cab:	50                   	push   %eax
f0101cac:	68 96 00 00 00       	push   $0x96
f0101cb1:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101cb7:	50                   	push   %eax
f0101cb8:	e8 1e e4 ff ff       	call   f01000db <_panic>
		panic("'pages' is a null pointer!");
f0101cbd:	83 ec 04             	sub    $0x4,%esp
f0101cc0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101cc3:	8d 83 69 57 f8 ff    	lea    -0x7a897(%ebx),%eax
f0101cc9:	50                   	push   %eax
f0101cca:	68 d2 02 00 00       	push   $0x2d2
f0101ccf:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101cd5:	50                   	push   %eax
f0101cd6:	e8 00 e4 ff ff       	call   f01000db <_panic>
		++nfree;
f0101cdb:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101cde:	8b 00                	mov    (%eax),%eax
f0101ce0:	85 c0                	test   %eax,%eax
f0101ce2:	75 f7                	jne    f0101cdb <mem_init+0x18d>
	assert((pp0 = page_alloc(0)));
f0101ce4:	83 ec 0c             	sub    $0xc,%esp
f0101ce7:	6a 00                	push   $0x0
f0101ce9:	e8 50 f9 ff ff       	call   f010163e <page_alloc>
f0101cee:	89 c3                	mov    %eax,%ebx
f0101cf0:	83 c4 10             	add    $0x10,%esp
f0101cf3:	85 c0                	test   %eax,%eax
f0101cf5:	0f 84 3a 02 00 00    	je     f0101f35 <mem_init+0x3e7>
	assert((pp1 = page_alloc(0)));
f0101cfb:	83 ec 0c             	sub    $0xc,%esp
f0101cfe:	6a 00                	push   $0x0
f0101d00:	e8 39 f9 ff ff       	call   f010163e <page_alloc>
f0101d05:	89 c7                	mov    %eax,%edi
f0101d07:	83 c4 10             	add    $0x10,%esp
f0101d0a:	85 c0                	test   %eax,%eax
f0101d0c:	0f 84 45 02 00 00    	je     f0101f57 <mem_init+0x409>
	assert((pp2 = page_alloc(0)));
f0101d12:	83 ec 0c             	sub    $0xc,%esp
f0101d15:	6a 00                	push   $0x0
f0101d17:	e8 22 f9 ff ff       	call   f010163e <page_alloc>
f0101d1c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101d1f:	83 c4 10             	add    $0x10,%esp
f0101d22:	85 c0                	test   %eax,%eax
f0101d24:	0f 84 4f 02 00 00    	je     f0101f79 <mem_init+0x42b>
	assert(pp1 && pp1 != pp0);
f0101d2a:	39 fb                	cmp    %edi,%ebx
f0101d2c:	0f 84 69 02 00 00    	je     f0101f9b <mem_init+0x44d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d32:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d35:	39 c3                	cmp    %eax,%ebx
f0101d37:	0f 84 80 02 00 00    	je     f0101fbd <mem_init+0x46f>
f0101d3d:	39 c7                	cmp    %eax,%edi
f0101d3f:	0f 84 78 02 00 00    	je     f0101fbd <mem_init+0x46f>
	return (pp - pages) << PGSHIFT;
f0101d45:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d48:	8b 88 08 23 00 00    	mov    0x2308(%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101d4e:	8b 90 10 23 00 00    	mov    0x2310(%eax),%edx
f0101d54:	c1 e2 0c             	shl    $0xc,%edx
f0101d57:	89 d8                	mov    %ebx,%eax
f0101d59:	29 c8                	sub    %ecx,%eax
f0101d5b:	c1 f8 03             	sar    $0x3,%eax
f0101d5e:	c1 e0 0c             	shl    $0xc,%eax
f0101d61:	39 d0                	cmp    %edx,%eax
f0101d63:	0f 83 76 02 00 00    	jae    f0101fdf <mem_init+0x491>
f0101d69:	89 f8                	mov    %edi,%eax
f0101d6b:	29 c8                	sub    %ecx,%eax
f0101d6d:	c1 f8 03             	sar    $0x3,%eax
f0101d70:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101d73:	39 c2                	cmp    %eax,%edx
f0101d75:	0f 86 86 02 00 00    	jbe    f0102001 <mem_init+0x4b3>
f0101d7b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d7e:	29 c8                	sub    %ecx,%eax
f0101d80:	c1 f8 03             	sar    $0x3,%eax
f0101d83:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101d86:	39 c2                	cmp    %eax,%edx
f0101d88:	0f 86 95 02 00 00    	jbe    f0102023 <mem_init+0x4d5>
	fl = page_free_list;
f0101d8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d91:	8b 88 18 23 00 00    	mov    0x2318(%eax),%ecx
f0101d97:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101d9a:	c7 80 18 23 00 00 00 	movl   $0x0,0x2318(%eax)
f0101da1:	00 00 00 
	assert(!page_alloc(0));
f0101da4:	83 ec 0c             	sub    $0xc,%esp
f0101da7:	6a 00                	push   $0x0
f0101da9:	e8 90 f8 ff ff       	call   f010163e <page_alloc>
f0101dae:	83 c4 10             	add    $0x10,%esp
f0101db1:	85 c0                	test   %eax,%eax
f0101db3:	0f 85 8c 02 00 00    	jne    f0102045 <mem_init+0x4f7>
	page_free(pp0);
f0101db9:	83 ec 0c             	sub    $0xc,%esp
f0101dbc:	53                   	push   %ebx
f0101dbd:	e8 1b f9 ff ff       	call   f01016dd <page_free>
	page_free(pp1);
f0101dc2:	89 3c 24             	mov    %edi,(%esp)
f0101dc5:	e8 13 f9 ff ff       	call   f01016dd <page_free>
	page_free(pp2);
f0101dca:	83 c4 04             	add    $0x4,%esp
f0101dcd:	ff 75 d0             	push   -0x30(%ebp)
f0101dd0:	e8 08 f9 ff ff       	call   f01016dd <page_free>
	assert((pp0 = page_alloc(0)));
f0101dd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ddc:	e8 5d f8 ff ff       	call   f010163e <page_alloc>
f0101de1:	89 c7                	mov    %eax,%edi
f0101de3:	83 c4 10             	add    $0x10,%esp
f0101de6:	85 c0                	test   %eax,%eax
f0101de8:	0f 84 79 02 00 00    	je     f0102067 <mem_init+0x519>
	assert((pp1 = page_alloc(0)));
f0101dee:	83 ec 0c             	sub    $0xc,%esp
f0101df1:	6a 00                	push   $0x0
f0101df3:	e8 46 f8 ff ff       	call   f010163e <page_alloc>
f0101df8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101dfb:	83 c4 10             	add    $0x10,%esp
f0101dfe:	85 c0                	test   %eax,%eax
f0101e00:	0f 84 83 02 00 00    	je     f0102089 <mem_init+0x53b>
	assert((pp2 = page_alloc(0)));
f0101e06:	83 ec 0c             	sub    $0xc,%esp
f0101e09:	6a 00                	push   $0x0
f0101e0b:	e8 2e f8 ff ff       	call   f010163e <page_alloc>
f0101e10:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e13:	83 c4 10             	add    $0x10,%esp
f0101e16:	85 c0                	test   %eax,%eax
f0101e18:	0f 84 8d 02 00 00    	je     f01020ab <mem_init+0x55d>
	assert(pp1 && pp1 != pp0);
f0101e1e:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0101e21:	0f 84 a6 02 00 00    	je     f01020cd <mem_init+0x57f>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101e27:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101e2a:	39 c7                	cmp    %eax,%edi
f0101e2c:	0f 84 bd 02 00 00    	je     f01020ef <mem_init+0x5a1>
f0101e32:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101e35:	0f 84 b4 02 00 00    	je     f01020ef <mem_init+0x5a1>
	assert(!page_alloc(0));
f0101e3b:	83 ec 0c             	sub    $0xc,%esp
f0101e3e:	6a 00                	push   $0x0
f0101e40:	e8 f9 f7 ff ff       	call   f010163e <page_alloc>
f0101e45:	83 c4 10             	add    $0x10,%esp
f0101e48:	85 c0                	test   %eax,%eax
f0101e4a:	0f 85 c1 02 00 00    	jne    f0102111 <mem_init+0x5c3>
f0101e50:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e53:	89 f8                	mov    %edi,%eax
f0101e55:	2b 81 08 23 00 00    	sub    0x2308(%ecx),%eax
f0101e5b:	c1 f8 03             	sar    $0x3,%eax
f0101e5e:	89 c2                	mov    %eax,%edx
f0101e60:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e63:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e68:	3b 81 10 23 00 00    	cmp    0x2310(%ecx),%eax
f0101e6e:	0f 83 bf 02 00 00    	jae    f0102133 <mem_init+0x5e5>
	memset(page2kva(pp0), 1, PGSIZE);
f0101e74:	83 ec 04             	sub    $0x4,%esp
f0101e77:	68 00 10 00 00       	push   $0x1000
f0101e7c:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101e7e:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101e84:	52                   	push   %edx
f0101e85:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e88:	e8 88 34 00 00       	call   f0105315 <memset>
	page_free(pp0);
f0101e8d:	89 3c 24             	mov    %edi,(%esp)
f0101e90:	e8 48 f8 ff ff       	call   f01016dd <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101e95:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101e9c:	e8 9d f7 ff ff       	call   f010163e <page_alloc>
f0101ea1:	83 c4 10             	add    $0x10,%esp
f0101ea4:	85 c0                	test   %eax,%eax
f0101ea6:	0f 84 9f 02 00 00    	je     f010214b <mem_init+0x5fd>
	assert(pp && pp0 == pp);
f0101eac:	39 c7                	cmp    %eax,%edi
f0101eae:	0f 85 b9 02 00 00    	jne    f010216d <mem_init+0x61f>
	return (pp - pages) << PGSHIFT;
f0101eb4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101eb7:	2b 81 08 23 00 00    	sub    0x2308(%ecx),%eax
f0101ebd:	c1 f8 03             	sar    $0x3,%eax
f0101ec0:	89 c2                	mov    %eax,%edx
f0101ec2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101ec5:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101eca:	3b 81 10 23 00 00    	cmp    0x2310(%ecx),%eax
f0101ed0:	0f 83 b9 02 00 00    	jae    f010218f <mem_init+0x641>
	return (void *)(pa + KERNBASE);
f0101ed6:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101edc:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101ee2:	80 38 00             	cmpb   $0x0,(%eax)
f0101ee5:	0f 85 bc 02 00 00    	jne    f01021a7 <mem_init+0x659>
	for (i = 0; i < PGSIZE; i++)
f0101eeb:	83 c0 01             	add    $0x1,%eax
f0101eee:	39 d0                	cmp    %edx,%eax
f0101ef0:	75 f0                	jne    f0101ee2 <mem_init+0x394>
	page_free_list = fl;
f0101ef2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ef5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101ef8:	89 8b 18 23 00 00    	mov    %ecx,0x2318(%ebx)
	page_free(pp0);
f0101efe:	83 ec 0c             	sub    $0xc,%esp
f0101f01:	57                   	push   %edi
f0101f02:	e8 d6 f7 ff ff       	call   f01016dd <page_free>
	page_free(pp1);
f0101f07:	83 c4 04             	add    $0x4,%esp
f0101f0a:	ff 75 d0             	push   -0x30(%ebp)
f0101f0d:	e8 cb f7 ff ff       	call   f01016dd <page_free>
	page_free(pp2);
f0101f12:	83 c4 04             	add    $0x4,%esp
f0101f15:	ff 75 cc             	push   -0x34(%ebp)
f0101f18:	e8 c0 f7 ff ff       	call   f01016dd <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f1d:	8b 83 18 23 00 00    	mov    0x2318(%ebx),%eax
f0101f23:	83 c4 10             	add    $0x10,%esp
f0101f26:	85 c0                	test   %eax,%eax
f0101f28:	0f 84 9b 02 00 00    	je     f01021c9 <mem_init+0x67b>
		--nfree;
f0101f2e:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f31:	8b 00                	mov    (%eax),%eax
f0101f33:	eb f1                	jmp    f0101f26 <mem_init+0x3d8>
	assert((pp0 = page_alloc(0)));
f0101f35:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f38:	8d 83 84 57 f8 ff    	lea    -0x7a87c(%ebx),%eax
f0101f3e:	50                   	push   %eax
f0101f3f:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0101f45:	50                   	push   %eax
f0101f46:	68 da 02 00 00       	push   $0x2da
f0101f4b:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101f51:	50                   	push   %eax
f0101f52:	e8 84 e1 ff ff       	call   f01000db <_panic>
	assert((pp1 = page_alloc(0)));
f0101f57:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f5a:	8d 83 9a 57 f8 ff    	lea    -0x7a866(%ebx),%eax
f0101f60:	50                   	push   %eax
f0101f61:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0101f67:	50                   	push   %eax
f0101f68:	68 db 02 00 00       	push   $0x2db
f0101f6d:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101f73:	50                   	push   %eax
f0101f74:	e8 62 e1 ff ff       	call   f01000db <_panic>
	assert((pp2 = page_alloc(0)));
f0101f79:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f7c:	8d 83 b0 57 f8 ff    	lea    -0x7a850(%ebx),%eax
f0101f82:	50                   	push   %eax
f0101f83:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0101f89:	50                   	push   %eax
f0101f8a:	68 dc 02 00 00       	push   $0x2dc
f0101f8f:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101f95:	50                   	push   %eax
f0101f96:	e8 40 e1 ff ff       	call   f01000db <_panic>
	assert(pp1 && pp1 != pp0);
f0101f9b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f9e:	8d 83 c6 57 f8 ff    	lea    -0x7a83a(%ebx),%eax
f0101fa4:	50                   	push   %eax
f0101fa5:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0101fab:	50                   	push   %eax
f0101fac:	68 df 02 00 00       	push   $0x2df
f0101fb1:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101fb7:	50                   	push   %eax
f0101fb8:	e8 1e e1 ff ff       	call   f01000db <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101fbd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fc0:	8d 83 94 5b f8 ff    	lea    -0x7a46c(%ebx),%eax
f0101fc6:	50                   	push   %eax
f0101fc7:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0101fcd:	50                   	push   %eax
f0101fce:	68 e0 02 00 00       	push   $0x2e0
f0101fd3:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101fd9:	50                   	push   %eax
f0101fda:	e8 fc e0 ff ff       	call   f01000db <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101fdf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fe2:	8d 83 d8 57 f8 ff    	lea    -0x7a828(%ebx),%eax
f0101fe8:	50                   	push   %eax
f0101fe9:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0101fef:	50                   	push   %eax
f0101ff0:	68 e1 02 00 00       	push   $0x2e1
f0101ff5:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0101ffb:	50                   	push   %eax
f0101ffc:	e8 da e0 ff ff       	call   f01000db <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0102001:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102004:	8d 83 f5 57 f8 ff    	lea    -0x7a80b(%ebx),%eax
f010200a:	50                   	push   %eax
f010200b:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102011:	50                   	push   %eax
f0102012:	68 e2 02 00 00       	push   $0x2e2
f0102017:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010201d:	50                   	push   %eax
f010201e:	e8 b8 e0 ff ff       	call   f01000db <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0102023:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102026:	8d 83 12 58 f8 ff    	lea    -0x7a7ee(%ebx),%eax
f010202c:	50                   	push   %eax
f010202d:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102033:	50                   	push   %eax
f0102034:	68 e3 02 00 00       	push   $0x2e3
f0102039:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010203f:	50                   	push   %eax
f0102040:	e8 96 e0 ff ff       	call   f01000db <_panic>
	assert(!page_alloc(0));
f0102045:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102048:	8d 83 2f 58 f8 ff    	lea    -0x7a7d1(%ebx),%eax
f010204e:	50                   	push   %eax
f010204f:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102055:	50                   	push   %eax
f0102056:	68 ea 02 00 00       	push   $0x2ea
f010205b:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102061:	50                   	push   %eax
f0102062:	e8 74 e0 ff ff       	call   f01000db <_panic>
	assert((pp0 = page_alloc(0)));
f0102067:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010206a:	8d 83 84 57 f8 ff    	lea    -0x7a87c(%ebx),%eax
f0102070:	50                   	push   %eax
f0102071:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102077:	50                   	push   %eax
f0102078:	68 f1 02 00 00       	push   $0x2f1
f010207d:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102083:	50                   	push   %eax
f0102084:	e8 52 e0 ff ff       	call   f01000db <_panic>
	assert((pp1 = page_alloc(0)));
f0102089:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010208c:	8d 83 9a 57 f8 ff    	lea    -0x7a866(%ebx),%eax
f0102092:	50                   	push   %eax
f0102093:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102099:	50                   	push   %eax
f010209a:	68 f2 02 00 00       	push   $0x2f2
f010209f:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01020a5:	50                   	push   %eax
f01020a6:	e8 30 e0 ff ff       	call   f01000db <_panic>
	assert((pp2 = page_alloc(0)));
f01020ab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020ae:	8d 83 b0 57 f8 ff    	lea    -0x7a850(%ebx),%eax
f01020b4:	50                   	push   %eax
f01020b5:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01020bb:	50                   	push   %eax
f01020bc:	68 f3 02 00 00       	push   $0x2f3
f01020c1:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01020c7:	50                   	push   %eax
f01020c8:	e8 0e e0 ff ff       	call   f01000db <_panic>
	assert(pp1 && pp1 != pp0);
f01020cd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020d0:	8d 83 c6 57 f8 ff    	lea    -0x7a83a(%ebx),%eax
f01020d6:	50                   	push   %eax
f01020d7:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01020dd:	50                   	push   %eax
f01020de:	68 f5 02 00 00       	push   $0x2f5
f01020e3:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01020e9:	50                   	push   %eax
f01020ea:	e8 ec df ff ff       	call   f01000db <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01020ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020f2:	8d 83 94 5b f8 ff    	lea    -0x7a46c(%ebx),%eax
f01020f8:	50                   	push   %eax
f01020f9:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01020ff:	50                   	push   %eax
f0102100:	68 f6 02 00 00       	push   $0x2f6
f0102105:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010210b:	50                   	push   %eax
f010210c:	e8 ca df ff ff       	call   f01000db <_panic>
	assert(!page_alloc(0));
f0102111:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102114:	8d 83 2f 58 f8 ff    	lea    -0x7a7d1(%ebx),%eax
f010211a:	50                   	push   %eax
f010211b:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102121:	50                   	push   %eax
f0102122:	68 f7 02 00 00       	push   $0x2f7
f0102127:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010212d:	50                   	push   %eax
f010212e:	e8 a8 df ff ff       	call   f01000db <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102133:	52                   	push   %edx
f0102134:	89 cb                	mov    %ecx,%ebx
f0102136:	8d 81 a0 59 f8 ff    	lea    -0x7a660(%ecx),%eax
f010213c:	50                   	push   %eax
f010213d:	6a 5c                	push   $0x5c
f010213f:	8d 81 35 56 f8 ff    	lea    -0x7a9cb(%ecx),%eax
f0102145:	50                   	push   %eax
f0102146:	e8 90 df ff ff       	call   f01000db <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010214b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010214e:	8d 83 3e 58 f8 ff    	lea    -0x7a7c2(%ebx),%eax
f0102154:	50                   	push   %eax
f0102155:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010215b:	50                   	push   %eax
f010215c:	68 fc 02 00 00       	push   $0x2fc
f0102161:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102167:	50                   	push   %eax
f0102168:	e8 6e df ff ff       	call   f01000db <_panic>
	assert(pp && pp0 == pp);
f010216d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102170:	8d 83 5c 58 f8 ff    	lea    -0x7a7a4(%ebx),%eax
f0102176:	50                   	push   %eax
f0102177:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010217d:	50                   	push   %eax
f010217e:	68 fd 02 00 00       	push   $0x2fd
f0102183:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102189:	50                   	push   %eax
f010218a:	e8 4c df ff ff       	call   f01000db <_panic>
f010218f:	52                   	push   %edx
f0102190:	89 cb                	mov    %ecx,%ebx
f0102192:	8d 81 a0 59 f8 ff    	lea    -0x7a660(%ecx),%eax
f0102198:	50                   	push   %eax
f0102199:	6a 5c                	push   $0x5c
f010219b:	8d 81 35 56 f8 ff    	lea    -0x7a9cb(%ecx),%eax
f01021a1:	50                   	push   %eax
f01021a2:	e8 34 df ff ff       	call   f01000db <_panic>
		assert(c[i] == 0);
f01021a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021aa:	8d 83 6c 58 f8 ff    	lea    -0x7a794(%ebx),%eax
f01021b0:	50                   	push   %eax
f01021b1:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01021b7:	50                   	push   %eax
f01021b8:	68 00 03 00 00       	push   $0x300
f01021bd:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01021c3:	50                   	push   %eax
f01021c4:	e8 12 df ff ff       	call   f01000db <_panic>
	assert(nfree == 0);
f01021c9:	85 f6                	test   %esi,%esi
f01021cb:	0f 85 e6 08 00 00    	jne    f0102ab7 <mem_init+0xf69>
	cprintf("check_page_alloc() succeeded!\n");
f01021d1:	83 ec 0c             	sub    $0xc,%esp
f01021d4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021d7:	8d 83 b4 5b f8 ff    	lea    -0x7a44c(%ebx),%eax
f01021dd:	50                   	push   %eax
f01021de:	e8 35 21 00 00       	call   f0104318 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01021e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021ea:	e8 4f f4 ff ff       	call   f010163e <page_alloc>
f01021ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021f2:	83 c4 10             	add    $0x10,%esp
f01021f5:	85 c0                	test   %eax,%eax
f01021f7:	0f 84 dc 08 00 00    	je     f0102ad9 <mem_init+0xf8b>
	assert((pp1 = page_alloc(0)));
f01021fd:	83 ec 0c             	sub    $0xc,%esp
f0102200:	6a 00                	push   $0x0
f0102202:	e8 37 f4 ff ff       	call   f010163e <page_alloc>
f0102207:	89 c7                	mov    %eax,%edi
f0102209:	83 c4 10             	add    $0x10,%esp
f010220c:	85 c0                	test   %eax,%eax
f010220e:	0f 84 e7 08 00 00    	je     f0102afb <mem_init+0xfad>
	assert((pp2 = page_alloc(0)));
f0102214:	83 ec 0c             	sub    $0xc,%esp
f0102217:	6a 00                	push   $0x0
f0102219:	e8 20 f4 ff ff       	call   f010163e <page_alloc>
f010221e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102221:	83 c4 10             	add    $0x10,%esp
f0102224:	85 c0                	test   %eax,%eax
f0102226:	0f 84 f1 08 00 00    	je     f0102b1d <mem_init+0xfcf>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010222c:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f010222f:	0f 84 0a 09 00 00    	je     f0102b3f <mem_init+0xff1>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102235:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102238:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010223b:	0f 84 20 09 00 00    	je     f0102b61 <mem_init+0x1013>
f0102241:	39 c7                	cmp    %eax,%edi
f0102243:	0f 84 18 09 00 00    	je     f0102b61 <mem_init+0x1013>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102249:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010224c:	8b 88 18 23 00 00    	mov    0x2318(%eax),%ecx
f0102252:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0102255:	c7 80 18 23 00 00 00 	movl   $0x0,0x2318(%eax)
f010225c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010225f:	83 ec 0c             	sub    $0xc,%esp
f0102262:	6a 00                	push   $0x0
f0102264:	e8 d5 f3 ff ff       	call   f010163e <page_alloc>
f0102269:	83 c4 10             	add    $0x10,%esp
f010226c:	85 c0                	test   %eax,%eax
f010226e:	0f 85 0f 09 00 00    	jne    f0102b83 <mem_init+0x1035>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102274:	83 ec 04             	sub    $0x4,%esp
f0102277:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010227a:	50                   	push   %eax
f010227b:	6a 00                	push   $0x0
f010227d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102280:	ff b0 0c 23 00 00    	push   0x230c(%eax)
f0102286:	e8 a8 f6 ff ff       	call   f0101933 <page_lookup>
f010228b:	83 c4 10             	add    $0x10,%esp
f010228e:	85 c0                	test   %eax,%eax
f0102290:	0f 85 0f 09 00 00    	jne    f0102ba5 <mem_init+0x1057>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) != 0);
f0102296:	6a 02                	push   $0x2
f0102298:	6a 00                	push   $0x0
f010229a:	57                   	push   %edi
f010229b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010229e:	ff b0 0c 23 00 00    	push   0x230c(%eax)
f01022a4:	e8 43 f7 ff ff       	call   f01019ec <page_insert>
f01022a9:	83 c4 10             	add    $0x10,%esp
f01022ac:	85 c0                	test   %eax,%eax
f01022ae:	0f 84 13 09 00 00    	je     f0102bc7 <mem_init+0x1079>
	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01022b4:	83 ec 0c             	sub    $0xc,%esp
f01022b7:	ff 75 cc             	push   -0x34(%ebp)
f01022ba:	e8 1e f4 ff ff       	call   f01016dd <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022bf:	6a 02                	push   $0x2
f01022c1:	6a 00                	push   $0x0
f01022c3:	57                   	push   %edi
f01022c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022c7:	ff b0 0c 23 00 00    	push   0x230c(%eax)
f01022cd:	e8 1a f7 ff ff       	call   f01019ec <page_insert>
f01022d2:	83 c4 20             	add    $0x20,%esp
f01022d5:	85 c0                	test   %eax,%eax
f01022d7:	0f 85 0c 09 00 00    	jne    f0102be9 <mem_init+0x109b>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022e0:	8b 98 0c 23 00 00    	mov    0x230c(%eax),%ebx
	return (pp - pages) << PGSHIFT;
f01022e6:	8b b0 08 23 00 00    	mov    0x2308(%eax),%esi
f01022ec:	8b 13                	mov    (%ebx),%edx
f01022ee:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01022f4:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01022f7:	29 f0                	sub    %esi,%eax
f01022f9:	c1 f8 03             	sar    $0x3,%eax
f01022fc:	c1 e0 0c             	shl    $0xc,%eax
f01022ff:	39 c2                	cmp    %eax,%edx
f0102301:	0f 85 04 09 00 00    	jne    f0102c0b <mem_init+0x10bd>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102307:	ba 00 00 00 00       	mov    $0x0,%edx
f010230c:	89 d8                	mov    %ebx,%eax
f010230e:	e8 93 ee ff ff       	call   f01011a6 <check_va2pa>
f0102313:	89 c2                	mov    %eax,%edx
f0102315:	89 f8                	mov    %edi,%eax
f0102317:	29 f0                	sub    %esi,%eax
f0102319:	c1 f8 03             	sar    $0x3,%eax
f010231c:	c1 e0 0c             	shl    $0xc,%eax
f010231f:	39 c2                	cmp    %eax,%edx
f0102321:	0f 85 06 09 00 00    	jne    f0102c2d <mem_init+0x10df>
	assert(pp1->pp_ref == 1);
f0102327:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010232c:	0f 85 1d 09 00 00    	jne    f0102c4f <mem_init+0x1101>
	assert(pp0->pp_ref == 1);
f0102332:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102335:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010233a:	0f 85 31 09 00 00    	jne    f0102c71 <mem_init+0x1123>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102340:	6a 02                	push   $0x2
f0102342:	68 00 10 00 00       	push   $0x1000
f0102347:	ff 75 d0             	push   -0x30(%ebp)
f010234a:	53                   	push   %ebx
f010234b:	e8 9c f6 ff ff       	call   f01019ec <page_insert>
f0102350:	83 c4 10             	add    $0x10,%esp
f0102353:	85 c0                	test   %eax,%eax
f0102355:	0f 85 38 09 00 00    	jne    f0102c93 <mem_init+0x1145>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010235b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102360:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102363:	8b 83 0c 23 00 00    	mov    0x230c(%ebx),%eax
f0102369:	e8 38 ee ff ff       	call   f01011a6 <check_va2pa>
f010236e:	89 c2                	mov    %eax,%edx
f0102370:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102373:	2b 83 08 23 00 00    	sub    0x2308(%ebx),%eax
f0102379:	c1 f8 03             	sar    $0x3,%eax
f010237c:	c1 e0 0c             	shl    $0xc,%eax
f010237f:	39 c2                	cmp    %eax,%edx
f0102381:	0f 85 2e 09 00 00    	jne    f0102cb5 <mem_init+0x1167>
	assert(pp2->pp_ref == 1);
f0102387:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010238a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010238f:	0f 85 42 09 00 00    	jne    f0102cd7 <mem_init+0x1189>

	// should be no free memory
	assert(!page_alloc(0));
f0102395:	83 ec 0c             	sub    $0xc,%esp
f0102398:	6a 00                	push   $0x0
f010239a:	e8 9f f2 ff ff       	call   f010163e <page_alloc>
f010239f:	83 c4 10             	add    $0x10,%esp
f01023a2:	85 c0                	test   %eax,%eax
f01023a4:	0f 85 4f 09 00 00    	jne    f0102cf9 <mem_init+0x11ab>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023aa:	6a 02                	push   $0x2
f01023ac:	68 00 10 00 00       	push   $0x1000
f01023b1:	ff 75 d0             	push   -0x30(%ebp)
f01023b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023b7:	ff b0 0c 23 00 00    	push   0x230c(%eax)
f01023bd:	e8 2a f6 ff ff       	call   f01019ec <page_insert>
f01023c2:	83 c4 10             	add    $0x10,%esp
f01023c5:	85 c0                	test   %eax,%eax
f01023c7:	0f 85 4e 09 00 00    	jne    f0102d1b <mem_init+0x11cd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023cd:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023d2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023d5:	8b 83 0c 23 00 00    	mov    0x230c(%ebx),%eax
f01023db:	e8 c6 ed ff ff       	call   f01011a6 <check_va2pa>
f01023e0:	89 c2                	mov    %eax,%edx
f01023e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01023e5:	2b 83 08 23 00 00    	sub    0x2308(%ebx),%eax
f01023eb:	c1 f8 03             	sar    $0x3,%eax
f01023ee:	c1 e0 0c             	shl    $0xc,%eax
f01023f1:	39 c2                	cmp    %eax,%edx
f01023f3:	0f 85 44 09 00 00    	jne    f0102d3d <mem_init+0x11ef>
	assert(pp2->pp_ref == 1);
f01023f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01023fc:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102401:	0f 85 58 09 00 00    	jne    f0102d5f <mem_init+0x1211>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102407:	83 ec 0c             	sub    $0xc,%esp
f010240a:	6a 00                	push   $0x0
f010240c:	e8 2d f2 ff ff       	call   f010163e <page_alloc>
f0102411:	83 c4 10             	add    $0x10,%esp
f0102414:	85 c0                	test   %eax,%eax
f0102416:	0f 85 65 09 00 00    	jne    f0102d81 <mem_init+0x1233>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010241c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010241f:	8b 91 0c 23 00 00    	mov    0x230c(%ecx),%edx
f0102425:	8b 02                	mov    (%edx),%eax
f0102427:	89 c3                	mov    %eax,%ebx
f0102429:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f010242f:	c1 e8 0c             	shr    $0xc,%eax
f0102432:	3b 81 10 23 00 00    	cmp    0x2310(%ecx),%eax
f0102438:	0f 83 65 09 00 00    	jae    f0102da3 <mem_init+0x1255>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010243e:	83 ec 04             	sub    $0x4,%esp
f0102441:	6a 00                	push   $0x0
f0102443:	68 00 10 00 00       	push   $0x1000
f0102448:	52                   	push   %edx
f0102449:	e8 07 f3 ff ff       	call   f0101755 <pgdir_walk>
f010244e:	81 eb fc ff ff 0f    	sub    $0xffffffc,%ebx
f0102454:	83 c4 10             	add    $0x10,%esp
f0102457:	39 d8                	cmp    %ebx,%eax
f0102459:	0f 85 5f 09 00 00    	jne    f0102dbe <mem_init+0x1270>

	// should be able to change permissions too.
	//cprintf("mark0#####\n");
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010245f:	6a 06                	push   $0x6
f0102461:	68 00 10 00 00       	push   $0x1000
f0102466:	ff 75 d0             	push   -0x30(%ebp)
f0102469:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010246c:	ff b0 0c 23 00 00    	push   0x230c(%eax)
f0102472:	e8 75 f5 ff ff       	call   f01019ec <page_insert>
f0102477:	83 c4 10             	add    $0x10,%esp
f010247a:	85 c0                	test   %eax,%eax
f010247c:	0f 85 5e 09 00 00    	jne    f0102de0 <mem_init+0x1292>
	//cprintf("kern_pgdir[0]: 0x%x\n", kern_pgdir[0]);
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102482:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102485:	8b 9e 0c 23 00 00    	mov    0x230c(%esi),%ebx
f010248b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102490:	89 d8                	mov    %ebx,%eax
f0102492:	e8 0f ed ff ff       	call   f01011a6 <check_va2pa>
f0102497:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0102499:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010249c:	2b 86 08 23 00 00    	sub    0x2308(%esi),%eax
f01024a2:	c1 f8 03             	sar    $0x3,%eax
f01024a5:	c1 e0 0c             	shl    $0xc,%eax
f01024a8:	39 c2                	cmp    %eax,%edx
f01024aa:	0f 85 52 09 00 00    	jne    f0102e02 <mem_init+0x12b4>
	assert(pp2->pp_ref == 1);
f01024b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01024b3:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01024b8:	0f 85 66 09 00 00    	jne    f0102e24 <mem_init+0x12d6>
	//cprintf("mark1#####\n");
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024be:	83 ec 04             	sub    $0x4,%esp
f01024c1:	6a 00                	push   $0x0
f01024c3:	68 00 10 00 00       	push   $0x1000
f01024c8:	53                   	push   %ebx
f01024c9:	e8 87 f2 ff ff       	call   f0101755 <pgdir_walk>
f01024ce:	83 c4 10             	add    $0x10,%esp
f01024d1:	f6 00 04             	testb  $0x4,(%eax)
f01024d4:	0f 84 6c 09 00 00    	je     f0102e46 <mem_init+0x12f8>
	assert(kern_pgdir[0] & PTE_U);
f01024da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024dd:	8b 80 0c 23 00 00    	mov    0x230c(%eax),%eax
f01024e3:	f6 00 04             	testb  $0x4,(%eax)
f01024e6:	0f 84 7c 09 00 00    	je     f0102e68 <mem_init+0x131a>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024ec:	6a 02                	push   $0x2
f01024ee:	68 00 10 00 00       	push   $0x1000
f01024f3:	ff 75 d0             	push   -0x30(%ebp)
f01024f6:	50                   	push   %eax
f01024f7:	e8 f0 f4 ff ff       	call   f01019ec <page_insert>
f01024fc:	83 c4 10             	add    $0x10,%esp
f01024ff:	85 c0                	test   %eax,%eax
f0102501:	0f 85 83 09 00 00    	jne    f0102e8a <mem_init+0x133c>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102507:	83 ec 04             	sub    $0x4,%esp
f010250a:	6a 00                	push   $0x0
f010250c:	68 00 10 00 00       	push   $0x1000
f0102511:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102514:	ff b0 0c 23 00 00    	push   0x230c(%eax)
f010251a:	e8 36 f2 ff ff       	call   f0101755 <pgdir_walk>
f010251f:	83 c4 10             	add    $0x10,%esp
f0102522:	f6 00 02             	testb  $0x2,(%eax)
f0102525:	0f 84 81 09 00 00    	je     f0102eac <mem_init+0x135e>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010252b:	83 ec 04             	sub    $0x4,%esp
f010252e:	6a 00                	push   $0x0
f0102530:	68 00 10 00 00       	push   $0x1000
f0102535:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102538:	ff b0 0c 23 00 00    	push   0x230c(%eax)
f010253e:	e8 12 f2 ff ff       	call   f0101755 <pgdir_walk>
f0102543:	83 c4 10             	add    $0x10,%esp
f0102546:	f6 00 04             	testb  $0x4,(%eax)
f0102549:	0f 85 7f 09 00 00    	jne    f0102ece <mem_init+0x1380>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) != 0);
f010254f:	6a 02                	push   $0x2
f0102551:	68 00 00 40 00       	push   $0x400000
f0102556:	ff 75 cc             	push   -0x34(%ebp)
f0102559:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010255c:	ff b0 0c 23 00 00    	push   0x230c(%eax)
f0102562:	e8 85 f4 ff ff       	call   f01019ec <page_insert>
f0102567:	83 c4 10             	add    $0x10,%esp
f010256a:	85 c0                	test   %eax,%eax
f010256c:	0f 84 7e 09 00 00    	je     f0102ef0 <mem_init+0x13a2>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102572:	6a 02                	push   $0x2
f0102574:	68 00 10 00 00       	push   $0x1000
f0102579:	57                   	push   %edi
f010257a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010257d:	ff b0 0c 23 00 00    	push   0x230c(%eax)
f0102583:	e8 64 f4 ff ff       	call   f01019ec <page_insert>
f0102588:	83 c4 10             	add    $0x10,%esp
f010258b:	85 c0                	test   %eax,%eax
f010258d:	0f 85 7f 09 00 00    	jne    f0102f12 <mem_init+0x13c4>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102593:	83 ec 04             	sub    $0x4,%esp
f0102596:	6a 00                	push   $0x0
f0102598:	68 00 10 00 00       	push   $0x1000
f010259d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025a0:	ff b0 0c 23 00 00    	push   0x230c(%eax)
f01025a6:	e8 aa f1 ff ff       	call   f0101755 <pgdir_walk>
f01025ab:	83 c4 10             	add    $0x10,%esp
f01025ae:	f6 00 04             	testb  $0x4,(%eax)
f01025b1:	0f 85 7d 09 00 00    	jne    f0102f34 <mem_init+0x13e6>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01025b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025ba:	8b b3 0c 23 00 00    	mov    0x230c(%ebx),%esi
f01025c0:	ba 00 00 00 00       	mov    $0x0,%edx
f01025c5:	89 f0                	mov    %esi,%eax
f01025c7:	e8 da eb ff ff       	call   f01011a6 <check_va2pa>
f01025cc:	89 d9                	mov    %ebx,%ecx
f01025ce:	89 fb                	mov    %edi,%ebx
f01025d0:	2b 99 08 23 00 00    	sub    0x2308(%ecx),%ebx
f01025d6:	c1 fb 03             	sar    $0x3,%ebx
f01025d9:	c1 e3 0c             	shl    $0xc,%ebx
f01025dc:	39 d8                	cmp    %ebx,%eax
f01025de:	0f 85 72 09 00 00    	jne    f0102f56 <mem_init+0x1408>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025e4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025e9:	89 f0                	mov    %esi,%eax
f01025eb:	e8 b6 eb ff ff       	call   f01011a6 <check_va2pa>
f01025f0:	39 c3                	cmp    %eax,%ebx
f01025f2:	0f 85 80 09 00 00    	jne    f0102f78 <mem_init+0x142a>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01025f8:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f01025fd:	0f 85 97 09 00 00    	jne    f0102f9a <mem_init+0x144c>
	assert(pp2->pp_ref == 0);
f0102603:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102606:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010260b:	0f 85 ab 09 00 00    	jne    f0102fbc <mem_init+0x146e>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102611:	83 ec 0c             	sub    $0xc,%esp
f0102614:	6a 00                	push   $0x0
f0102616:	e8 23 f0 ff ff       	call   f010163e <page_alloc>
f010261b:	83 c4 10             	add    $0x10,%esp
f010261e:	85 c0                	test   %eax,%eax
f0102620:	0f 84 b8 09 00 00    	je     f0102fde <mem_init+0x1490>
f0102626:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102629:	0f 85 af 09 00 00    	jne    f0102fde <mem_init+0x1490>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010262f:	83 ec 08             	sub    $0x8,%esp
f0102632:	6a 00                	push   $0x0
f0102634:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102637:	ff b3 0c 23 00 00    	push   0x230c(%ebx)
f010263d:	e8 64 f3 ff ff       	call   f01019a6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102642:	8b 9b 0c 23 00 00    	mov    0x230c(%ebx),%ebx
f0102648:	ba 00 00 00 00       	mov    $0x0,%edx
f010264d:	89 d8                	mov    %ebx,%eax
f010264f:	e8 52 eb ff ff       	call   f01011a6 <check_va2pa>
f0102654:	83 c4 10             	add    $0x10,%esp
f0102657:	83 f8 ff             	cmp    $0xffffffff,%eax
f010265a:	0f 85 a0 09 00 00    	jne    f0103000 <mem_init+0x14b2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102660:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102665:	89 d8                	mov    %ebx,%eax
f0102667:	e8 3a eb ff ff       	call   f01011a6 <check_va2pa>
f010266c:	89 c2                	mov    %eax,%edx
f010266e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102671:	89 f8                	mov    %edi,%eax
f0102673:	2b 81 08 23 00 00    	sub    0x2308(%ecx),%eax
f0102679:	c1 f8 03             	sar    $0x3,%eax
f010267c:	c1 e0 0c             	shl    $0xc,%eax
f010267f:	39 c2                	cmp    %eax,%edx
f0102681:	0f 85 9b 09 00 00    	jne    f0103022 <mem_init+0x14d4>
	assert(pp1->pp_ref == 1);
f0102687:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010268c:	0f 85 b1 09 00 00    	jne    f0103043 <mem_init+0x14f5>
	assert(pp2->pp_ref == 0);
f0102692:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102695:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010269a:	0f 85 c5 09 00 00    	jne    f0103065 <mem_init+0x1517>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01026a0:	6a 00                	push   $0x0
f01026a2:	68 00 10 00 00       	push   $0x1000
f01026a7:	57                   	push   %edi
f01026a8:	53                   	push   %ebx
f01026a9:	e8 3e f3 ff ff       	call   f01019ec <page_insert>
f01026ae:	83 c4 10             	add    $0x10,%esp
f01026b1:	85 c0                	test   %eax,%eax
f01026b3:	0f 85 ce 09 00 00    	jne    f0103087 <mem_init+0x1539>
	assert(pp1->pp_ref);
f01026b9:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01026be:	0f 84 e5 09 00 00    	je     f01030a9 <mem_init+0x155b>
	assert(pp1->pp_link == NULL);
f01026c4:	83 3f 00             	cmpl   $0x0,(%edi)
f01026c7:	0f 85 fe 09 00 00    	jne    f01030cb <mem_init+0x157d>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01026cd:	83 ec 08             	sub    $0x8,%esp
f01026d0:	68 00 10 00 00       	push   $0x1000
f01026d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026d8:	ff b3 0c 23 00 00    	push   0x230c(%ebx)
f01026de:	e8 c3 f2 ff ff       	call   f01019a6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026e3:	8b 9b 0c 23 00 00    	mov    0x230c(%ebx),%ebx
f01026e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01026ee:	89 d8                	mov    %ebx,%eax
f01026f0:	e8 b1 ea ff ff       	call   f01011a6 <check_va2pa>
f01026f5:	83 c4 10             	add    $0x10,%esp
f01026f8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026fb:	0f 85 ec 09 00 00    	jne    f01030ed <mem_init+0x159f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102701:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102706:	89 d8                	mov    %ebx,%eax
f0102708:	e8 99 ea ff ff       	call   f01011a6 <check_va2pa>
f010270d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102710:	0f 85 f9 09 00 00    	jne    f010310f <mem_init+0x15c1>
	assert(pp1->pp_ref == 0);
f0102716:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010271b:	0f 85 10 0a 00 00    	jne    f0103131 <mem_init+0x15e3>
	assert(pp2->pp_ref == 0);
f0102721:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102724:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102729:	0f 85 24 0a 00 00    	jne    f0103153 <mem_init+0x1605>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010272f:	83 ec 0c             	sub    $0xc,%esp
f0102732:	6a 00                	push   $0x0
f0102734:	e8 05 ef ff ff       	call   f010163e <page_alloc>
f0102739:	83 c4 10             	add    $0x10,%esp
f010273c:	39 c7                	cmp    %eax,%edi
f010273e:	0f 85 31 0a 00 00    	jne    f0103175 <mem_init+0x1627>
f0102744:	85 c0                	test   %eax,%eax
f0102746:	0f 84 29 0a 00 00    	je     f0103175 <mem_init+0x1627>

	// should be no free memory
	assert(!page_alloc(0));
f010274c:	83 ec 0c             	sub    $0xc,%esp
f010274f:	6a 00                	push   $0x0
f0102751:	e8 e8 ee ff ff       	call   f010163e <page_alloc>
f0102756:	83 c4 10             	add    $0x10,%esp
f0102759:	85 c0                	test   %eax,%eax
f010275b:	0f 85 36 0a 00 00    	jne    f0103197 <mem_init+0x1649>

	// forcibly take pp0 back
	
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102761:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102764:	8b 88 0c 23 00 00    	mov    0x230c(%eax),%ecx
f010276a:	8b 11                	mov    (%ecx),%edx
f010276c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102772:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0102775:	2b 98 08 23 00 00    	sub    0x2308(%eax),%ebx
f010277b:	89 d8                	mov    %ebx,%eax
f010277d:	c1 f8 03             	sar    $0x3,%eax
f0102780:	c1 e0 0c             	shl    $0xc,%eax
f0102783:	39 c2                	cmp    %eax,%edx
f0102785:	0f 85 2e 0a 00 00    	jne    f01031b9 <mem_init+0x166b>
	kern_pgdir[0] = 0;
f010278b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102791:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102794:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102799:	0f 85 3c 0a 00 00    	jne    f01031db <mem_init+0x168d>
	pp0->pp_ref = 0;
f010279f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01027a2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01027a8:	83 ec 0c             	sub    $0xc,%esp
f01027ab:	50                   	push   %eax
f01027ac:	e8 2c ef ff ff       	call   f01016dd <page_free>
	//cprintf("mark2#####\n");
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01027b1:	83 c4 0c             	add    $0xc,%esp
f01027b4:	6a 01                	push   $0x1
f01027b6:	68 00 10 40 00       	push   $0x401000
f01027bb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027be:	ff b3 0c 23 00 00    	push   0x230c(%ebx)
f01027c4:	e8 8c ef ff ff       	call   f0101755 <pgdir_walk>
f01027c9:	89 c6                	mov    %eax,%esi
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01027cb:	89 d9                	mov    %ebx,%ecx
f01027cd:	8b 9b 0c 23 00 00    	mov    0x230c(%ebx),%ebx
f01027d3:	8b 43 04             	mov    0x4(%ebx),%eax
f01027d6:	89 c2                	mov    %eax,%edx
f01027d8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01027de:	8b 89 10 23 00 00    	mov    0x2310(%ecx),%ecx
f01027e4:	c1 e8 0c             	shr    $0xc,%eax
f01027e7:	83 c4 10             	add    $0x10,%esp
f01027ea:	39 c8                	cmp    %ecx,%eax
f01027ec:	0f 83 0b 0a 00 00    	jae    f01031fd <mem_init+0x16af>
	assert(ptep == ptep1 + PTX(va));
f01027f2:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01027f8:	39 d6                	cmp    %edx,%esi
f01027fa:	0f 85 19 0a 00 00    	jne    f0103219 <mem_init+0x16cb>
	kern_pgdir[PDX(va)] = 0;
f0102800:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0102807:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010280a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0102810:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102813:	2b 83 08 23 00 00    	sub    0x2308(%ebx),%eax
f0102819:	c1 f8 03             	sar    $0x3,%eax
f010281c:	89 c2                	mov    %eax,%edx
f010281e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102821:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102826:	39 c1                	cmp    %eax,%ecx
f0102828:	0f 86 0d 0a 00 00    	jbe    f010323b <mem_init+0x16ed>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010282e:	83 ec 04             	sub    $0x4,%esp
f0102831:	68 00 10 00 00       	push   $0x1000
f0102836:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f010283b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102841:	52                   	push   %edx
f0102842:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102845:	e8 cb 2a 00 00       	call   f0105315 <memset>
	page_free(pp0);
f010284a:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010284d:	89 34 24             	mov    %esi,(%esp)
f0102850:	e8 88 ee ff ff       	call   f01016dd <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102855:	83 c4 0c             	add    $0xc,%esp
f0102858:	6a 01                	push   $0x1
f010285a:	6a 00                	push   $0x0
f010285c:	ff b3 0c 23 00 00    	push   0x230c(%ebx)
f0102862:	e8 ee ee ff ff       	call   f0101755 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102867:	89 f0                	mov    %esi,%eax
f0102869:	2b 83 08 23 00 00    	sub    0x2308(%ebx),%eax
f010286f:	c1 f8 03             	sar    $0x3,%eax
f0102872:	89 c2                	mov    %eax,%edx
f0102874:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102877:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010287c:	83 c4 10             	add    $0x10,%esp
f010287f:	3b 83 10 23 00 00    	cmp    0x2310(%ebx),%eax
f0102885:	0f 83 c6 09 00 00    	jae    f0103251 <mem_init+0x1703>
	return (void *)(pa + KERNBASE);
f010288b:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102891:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102897:	8b 30                	mov    (%eax),%esi
f0102899:	83 e6 01             	and    $0x1,%esi
f010289c:	0f 85 c8 09 00 00    	jne    f010326a <mem_init+0x171c>
	for(i=0; i<NPTENTRIES; i++)
f01028a2:	83 c0 04             	add    $0x4,%eax
f01028a5:	39 c2                	cmp    %eax,%edx
f01028a7:	75 ee                	jne    f0102897 <mem_init+0xd49>
	kern_pgdir[0] = 0;
f01028a9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028ac:	8b 83 0c 23 00 00    	mov    0x230c(%ebx),%eax
f01028b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01028b8:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028bb:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01028c1:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01028c4:	89 93 18 23 00 00    	mov    %edx,0x2318(%ebx)

	// free the pages we took
	page_free(pp0);
f01028ca:	83 ec 0c             	sub    $0xc,%esp
f01028cd:	50                   	push   %eax
f01028ce:	e8 0a ee ff ff       	call   f01016dd <page_free>
	page_free(pp1);
f01028d3:	89 3c 24             	mov    %edi,(%esp)
f01028d6:	e8 02 ee ff ff       	call   f01016dd <page_free>
	page_free(pp2);
f01028db:	83 c4 04             	add    $0x4,%esp
f01028de:	ff 75 d0             	push   -0x30(%ebp)
f01028e1:	e8 f7 ed ff ff       	call   f01016dd <page_free>

	cprintf("check_page() succeeded!\n");
f01028e6:	8d 83 4d 59 f8 ff    	lea    -0x7a6b3(%ebx),%eax
f01028ec:	89 04 24             	mov    %eax,(%esp)
f01028ef:	e8 24 1a 00 00       	call   f0104318 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, 64*PGSIZE, PADDR(pages), PTE_P|PTE_W);
f01028f4:	8b 83 08 23 00 00    	mov    0x2308(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01028fa:	83 c4 10             	add    $0x10,%esp
f01028fd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102902:	0f 86 84 09 00 00    	jbe    f010328c <mem_init+0x173e>
f0102908:	83 ec 0c             	sub    $0xc,%esp
f010290b:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f010290d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102912:	50                   	push   %eax
f0102913:	68 00 00 04 00       	push   $0x40000
f0102918:	68 00 00 00 ef       	push   $0xef000000
f010291d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102920:	ff b7 0c 23 00 00    	push   0x230c(%edi)
f0102926:	e8 47 ef ff ff       	call   f0101872 <boot_map_region>
			PADDR(pages+64*PGSIZE/sizeof(struct PageInfo)),PTE_U|PTE_P);
f010292b:	8b 87 08 23 00 00    	mov    0x2308(%edi),%eax
f0102931:	05 00 00 04 00       	add    $0x40000,%eax
	if ((uint32_t)kva < KERNBASE)
f0102936:	83 c4 20             	add    $0x20,%esp
f0102939:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010293e:	0f 86 64 09 00 00    	jbe    f01032a8 <mem_init+0x175a>
	boot_map_region(kern_pgdir, UPAGES+64*PGSIZE, PTSIZE-64*PGSIZE,
f0102944:	83 ec 0c             	sub    $0xc,%esp
f0102947:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102949:	05 00 00 00 10       	add    $0x10000000,%eax
f010294e:	50                   	push   %eax
f010294f:	68 00 00 3c 00       	push   $0x3c0000
f0102954:	68 00 00 04 ef       	push   $0xef040000
f0102959:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010295c:	ff b7 0c 23 00 00    	push   0x230c(%edi)
f0102962:	e8 0b ef ff ff       	call   f0101872 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, 1*PGSIZE, PADDR(envs), PTE_P|PTE_W);
f0102967:	c7 c0 88 2b 18 f0    	mov    $0xf0182b88,%eax
f010296d:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010296f:	83 c4 20             	add    $0x20,%esp
f0102972:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102977:	0f 86 47 09 00 00    	jbe    f01032c4 <mem_init+0x1776>
f010297d:	83 ec 0c             	sub    $0xc,%esp
f0102980:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f0102982:	05 00 00 00 10       	add    $0x10000000,%eax
f0102987:	50                   	push   %eax
f0102988:	68 00 10 00 00       	push   $0x1000
f010298d:	68 00 00 c0 ee       	push   $0xeec00000
f0102992:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102995:	ff b7 0c 23 00 00    	push   0x230c(%edi)
f010299b:	e8 d2 ee ff ff       	call   f0101872 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS+1*PGSIZE, PTSIZE-1*PGSIZE, PADDR(envs)+PGSIZE, PTE_P);
f01029a0:	c7 c0 88 2b 18 f0    	mov    $0xf0182b88,%eax
f01029a6:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01029a8:	83 c4 20             	add    $0x20,%esp
f01029ab:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029b0:	0f 86 2a 09 00 00    	jbe    f01032e0 <mem_init+0x1792>
f01029b6:	83 ec 0c             	sub    $0xc,%esp
f01029b9:	6a 01                	push   $0x1
f01029bb:	05 00 10 00 10       	add    $0x10001000,%eax
f01029c0:	50                   	push   %eax
f01029c1:	68 00 f0 3f 00       	push   $0x3ff000
f01029c6:	68 00 10 c0 ee       	push   $0xeec01000
f01029cb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01029ce:	ff b7 0c 23 00 00    	push   0x230c(%edi)
f01029d4:	e8 99 ee ff ff       	call   f0101872 <boot_map_region>
f01029d9:	c7 c0 00 40 11 f0    	mov    $0xf0114000,%eax
f01029df:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01029e2:	83 c4 20             	add    $0x20,%esp
f01029e5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029ea:	0f 86 0c 09 00 00    	jbe    f01032fc <mem_init+0x17ae>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, 
f01029f0:	83 ec 0c             	sub    $0xc,%esp
f01029f3:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f01029f5:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01029f8:	05 00 00 00 10       	add    $0x10000000,%eax
f01029fd:	50                   	push   %eax
f01029fe:	68 00 80 00 00       	push   $0x8000
f0102a03:	68 00 80 ff ef       	push   $0xefff8000
f0102a08:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a0b:	ff b3 0c 23 00 00    	push   0x230c(%ebx)
f0102a11:	e8 5c ee ff ff       	call   f0101872 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE+1, 0, PTE_W|PTE_P);
f0102a16:	83 c4 14             	add    $0x14,%esp
f0102a19:	6a 03                	push   $0x3
f0102a1b:	6a 00                	push   $0x0
f0102a1d:	68 00 00 00 10       	push   $0x10000000
f0102a22:	68 00 00 00 f0       	push   $0xf0000000
f0102a27:	ff b3 0c 23 00 00    	push   0x230c(%ebx)
f0102a2d:	e8 40 ee ff ff       	call   f0101872 <boot_map_region>
	cprintf("gogogo\n");
f0102a32:	83 c4 14             	add    $0x14,%esp
f0102a35:	8d 83 66 59 f8 ff    	lea    -0x7a69a(%ebx),%eax
f0102a3b:	50                   	push   %eax
f0102a3c:	e8 d7 18 00 00       	call   f0104318 <cprintf>
	pgdir = kern_pgdir;
f0102a41:	8b bb 0c 23 00 00    	mov    0x230c(%ebx),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102a47:	8b 83 10 23 00 00    	mov    0x2310(%ebx),%eax
f0102a4d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102a50:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102a57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102a5c:	89 c2                	mov    %eax,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102a5e:	8b 83 08 23 00 00    	mov    0x2308(%ebx),%eax
f0102a64:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0102a67:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0102a6d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102a70:	83 c4 10             	add    $0x10,%esp
f0102a73:	89 f3                	mov    %esi,%ebx
f0102a75:	89 75 c0             	mov    %esi,-0x40(%ebp)
f0102a78:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102a7b:	89 d6                	mov    %edx,%esi
f0102a7d:	89 c7                	mov    %eax,%edi
f0102a7f:	39 de                	cmp    %ebx,%esi
f0102a81:	0f 86 d6 08 00 00    	jbe    f010335d <mem_init+0x180f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102a87:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102a8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102a90:	e8 11 e7 ff ff       	call   f01011a6 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102a95:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102a9b:	0f 86 7c 08 00 00    	jbe    f010331d <mem_init+0x17cf>
f0102aa1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102aa4:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102aa7:	39 c2                	cmp    %eax,%edx
f0102aa9:	0f 85 8c 08 00 00    	jne    f010333b <mem_init+0x17ed>
	for (i = 0; i < n; i += PGSIZE)
f0102aaf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ab5:	eb c8                	jmp    f0102a7f <mem_init+0xf31>
	assert(nfree == 0);
f0102ab7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102aba:	8d 83 76 58 f8 ff    	lea    -0x7a78a(%ebx),%eax
f0102ac0:	50                   	push   %eax
f0102ac1:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102ac7:	50                   	push   %eax
f0102ac8:	68 0d 03 00 00       	push   $0x30d
f0102acd:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102ad3:	50                   	push   %eax
f0102ad4:	e8 02 d6 ff ff       	call   f01000db <_panic>
	assert((pp0 = page_alloc(0)));
f0102ad9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102adc:	8d 83 84 57 f8 ff    	lea    -0x7a87c(%ebx),%eax
f0102ae2:	50                   	push   %eax
f0102ae3:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102ae9:	50                   	push   %eax
f0102aea:	68 6b 03 00 00       	push   $0x36b
f0102aef:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102af5:	50                   	push   %eax
f0102af6:	e8 e0 d5 ff ff       	call   f01000db <_panic>
	assert((pp1 = page_alloc(0)));
f0102afb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102afe:	8d 83 9a 57 f8 ff    	lea    -0x7a866(%ebx),%eax
f0102b04:	50                   	push   %eax
f0102b05:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102b0b:	50                   	push   %eax
f0102b0c:	68 6c 03 00 00       	push   $0x36c
f0102b11:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102b17:	50                   	push   %eax
f0102b18:	e8 be d5 ff ff       	call   f01000db <_panic>
	assert((pp2 = page_alloc(0)));
f0102b1d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b20:	8d 83 b0 57 f8 ff    	lea    -0x7a850(%ebx),%eax
f0102b26:	50                   	push   %eax
f0102b27:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102b2d:	50                   	push   %eax
f0102b2e:	68 6d 03 00 00       	push   $0x36d
f0102b33:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102b39:	50                   	push   %eax
f0102b3a:	e8 9c d5 ff ff       	call   f01000db <_panic>
	assert(pp1 && pp1 != pp0);
f0102b3f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b42:	8d 83 c6 57 f8 ff    	lea    -0x7a83a(%ebx),%eax
f0102b48:	50                   	push   %eax
f0102b49:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102b4f:	50                   	push   %eax
f0102b50:	68 70 03 00 00       	push   $0x370
f0102b55:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102b5b:	50                   	push   %eax
f0102b5c:	e8 7a d5 ff ff       	call   f01000db <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102b61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b64:	8d 83 94 5b f8 ff    	lea    -0x7a46c(%ebx),%eax
f0102b6a:	50                   	push   %eax
f0102b6b:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102b71:	50                   	push   %eax
f0102b72:	68 71 03 00 00       	push   $0x371
f0102b77:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102b7d:	50                   	push   %eax
f0102b7e:	e8 58 d5 ff ff       	call   f01000db <_panic>
	assert(!page_alloc(0));
f0102b83:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b86:	8d 83 2f 58 f8 ff    	lea    -0x7a7d1(%ebx),%eax
f0102b8c:	50                   	push   %eax
f0102b8d:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102b93:	50                   	push   %eax
f0102b94:	68 78 03 00 00       	push   $0x378
f0102b99:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102b9f:	50                   	push   %eax
f0102ba0:	e8 36 d5 ff ff       	call   f01000db <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102ba5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ba8:	8d 83 d4 5b f8 ff    	lea    -0x7a42c(%ebx),%eax
f0102bae:	50                   	push   %eax
f0102baf:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102bb5:	50                   	push   %eax
f0102bb6:	68 7b 03 00 00       	push   $0x37b
f0102bbb:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102bc1:	50                   	push   %eax
f0102bc2:	e8 14 d5 ff ff       	call   f01000db <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) != 0);
f0102bc7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bca:	8d 83 0c 5c f8 ff    	lea    -0x7a3f4(%ebx),%eax
f0102bd0:	50                   	push   %eax
f0102bd1:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102bd7:	50                   	push   %eax
f0102bd8:	68 7e 03 00 00       	push   $0x37e
f0102bdd:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102be3:	50                   	push   %eax
f0102be4:	e8 f2 d4 ff ff       	call   f01000db <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102be9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bec:	8d 83 3c 5c f8 ff    	lea    -0x7a3c4(%ebx),%eax
f0102bf2:	50                   	push   %eax
f0102bf3:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102bf9:	50                   	push   %eax
f0102bfa:	68 81 03 00 00       	push   $0x381
f0102bff:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102c05:	50                   	push   %eax
f0102c06:	e8 d0 d4 ff ff       	call   f01000db <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c0b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c0e:	8d 83 6c 5c f8 ff    	lea    -0x7a394(%ebx),%eax
f0102c14:	50                   	push   %eax
f0102c15:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102c1b:	50                   	push   %eax
f0102c1c:	68 82 03 00 00       	push   $0x382
f0102c21:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102c27:	50                   	push   %eax
f0102c28:	e8 ae d4 ff ff       	call   f01000db <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102c2d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c30:	8d 83 94 5c f8 ff    	lea    -0x7a36c(%ebx),%eax
f0102c36:	50                   	push   %eax
f0102c37:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102c3d:	50                   	push   %eax
f0102c3e:	68 83 03 00 00       	push   $0x383
f0102c43:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102c49:	50                   	push   %eax
f0102c4a:	e8 8c d4 ff ff       	call   f01000db <_panic>
	assert(pp1->pp_ref == 1);
f0102c4f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c52:	8d 83 81 58 f8 ff    	lea    -0x7a77f(%ebx),%eax
f0102c58:	50                   	push   %eax
f0102c59:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102c5f:	50                   	push   %eax
f0102c60:	68 84 03 00 00       	push   $0x384
f0102c65:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102c6b:	50                   	push   %eax
f0102c6c:	e8 6a d4 ff ff       	call   f01000db <_panic>
	assert(pp0->pp_ref == 1);
f0102c71:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c74:	8d 83 92 58 f8 ff    	lea    -0x7a76e(%ebx),%eax
f0102c7a:	50                   	push   %eax
f0102c7b:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102c81:	50                   	push   %eax
f0102c82:	68 85 03 00 00       	push   $0x385
f0102c87:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102c8d:	50                   	push   %eax
f0102c8e:	e8 48 d4 ff ff       	call   f01000db <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102c93:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c96:	8d 83 c4 5c f8 ff    	lea    -0x7a33c(%ebx),%eax
f0102c9c:	50                   	push   %eax
f0102c9d:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102ca3:	50                   	push   %eax
f0102ca4:	68 88 03 00 00       	push   $0x388
f0102ca9:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102caf:	50                   	push   %eax
f0102cb0:	e8 26 d4 ff ff       	call   f01000db <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102cb5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cb8:	8d 83 00 5d f8 ff    	lea    -0x7a300(%ebx),%eax
f0102cbe:	50                   	push   %eax
f0102cbf:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102cc5:	50                   	push   %eax
f0102cc6:	68 89 03 00 00       	push   $0x389
f0102ccb:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102cd1:	50                   	push   %eax
f0102cd2:	e8 04 d4 ff ff       	call   f01000db <_panic>
	assert(pp2->pp_ref == 1);
f0102cd7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cda:	8d 83 a3 58 f8 ff    	lea    -0x7a75d(%ebx),%eax
f0102ce0:	50                   	push   %eax
f0102ce1:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102ce7:	50                   	push   %eax
f0102ce8:	68 8a 03 00 00       	push   $0x38a
f0102ced:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102cf3:	50                   	push   %eax
f0102cf4:	e8 e2 d3 ff ff       	call   f01000db <_panic>
	assert(!page_alloc(0));
f0102cf9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cfc:	8d 83 2f 58 f8 ff    	lea    -0x7a7d1(%ebx),%eax
f0102d02:	50                   	push   %eax
f0102d03:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102d09:	50                   	push   %eax
f0102d0a:	68 8d 03 00 00       	push   $0x38d
f0102d0f:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102d15:	50                   	push   %eax
f0102d16:	e8 c0 d3 ff ff       	call   f01000db <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102d1b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d1e:	8d 83 c4 5c f8 ff    	lea    -0x7a33c(%ebx),%eax
f0102d24:	50                   	push   %eax
f0102d25:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102d2b:	50                   	push   %eax
f0102d2c:	68 90 03 00 00       	push   $0x390
f0102d31:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102d37:	50                   	push   %eax
f0102d38:	e8 9e d3 ff ff       	call   f01000db <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102d3d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d40:	8d 83 00 5d f8 ff    	lea    -0x7a300(%ebx),%eax
f0102d46:	50                   	push   %eax
f0102d47:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102d4d:	50                   	push   %eax
f0102d4e:	68 91 03 00 00       	push   $0x391
f0102d53:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102d59:	50                   	push   %eax
f0102d5a:	e8 7c d3 ff ff       	call   f01000db <_panic>
	assert(pp2->pp_ref == 1);
f0102d5f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d62:	8d 83 a3 58 f8 ff    	lea    -0x7a75d(%ebx),%eax
f0102d68:	50                   	push   %eax
f0102d69:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102d6f:	50                   	push   %eax
f0102d70:	68 92 03 00 00       	push   $0x392
f0102d75:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102d7b:	50                   	push   %eax
f0102d7c:	e8 5a d3 ff ff       	call   f01000db <_panic>
	assert(!page_alloc(0));
f0102d81:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d84:	8d 83 2f 58 f8 ff    	lea    -0x7a7d1(%ebx),%eax
f0102d8a:	50                   	push   %eax
f0102d8b:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102d91:	50                   	push   %eax
f0102d92:	68 96 03 00 00       	push   $0x396
f0102d97:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102d9d:	50                   	push   %eax
f0102d9e:	e8 38 d3 ff ff       	call   f01000db <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102da3:	53                   	push   %ebx
f0102da4:	89 cb                	mov    %ecx,%ebx
f0102da6:	8d 81 a0 59 f8 ff    	lea    -0x7a660(%ecx),%eax
f0102dac:	50                   	push   %eax
f0102dad:	68 99 03 00 00       	push   $0x399
f0102db2:	8d 81 f2 55 f8 ff    	lea    -0x7aa0e(%ecx),%eax
f0102db8:	50                   	push   %eax
f0102db9:	e8 1d d3 ff ff       	call   f01000db <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102dbe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dc1:	8d 83 30 5d f8 ff    	lea    -0x7a2d0(%ebx),%eax
f0102dc7:	50                   	push   %eax
f0102dc8:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102dce:	50                   	push   %eax
f0102dcf:	68 9a 03 00 00       	push   $0x39a
f0102dd4:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102dda:	50                   	push   %eax
f0102ddb:	e8 fb d2 ff ff       	call   f01000db <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102de0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102de3:	8d 83 70 5d f8 ff    	lea    -0x7a290(%ebx),%eax
f0102de9:	50                   	push   %eax
f0102dea:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102df0:	50                   	push   %eax
f0102df1:	68 9e 03 00 00       	push   $0x39e
f0102df6:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102dfc:	50                   	push   %eax
f0102dfd:	e8 d9 d2 ff ff       	call   f01000db <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102e02:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e05:	8d 83 00 5d f8 ff    	lea    -0x7a300(%ebx),%eax
f0102e0b:	50                   	push   %eax
f0102e0c:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102e12:	50                   	push   %eax
f0102e13:	68 a0 03 00 00       	push   $0x3a0
f0102e18:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102e1e:	50                   	push   %eax
f0102e1f:	e8 b7 d2 ff ff       	call   f01000db <_panic>
	assert(pp2->pp_ref == 1);
f0102e24:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e27:	8d 83 a3 58 f8 ff    	lea    -0x7a75d(%ebx),%eax
f0102e2d:	50                   	push   %eax
f0102e2e:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102e34:	50                   	push   %eax
f0102e35:	68 a1 03 00 00       	push   $0x3a1
f0102e3a:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102e40:	50                   	push   %eax
f0102e41:	e8 95 d2 ff ff       	call   f01000db <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102e46:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e49:	8d 83 b0 5d f8 ff    	lea    -0x7a250(%ebx),%eax
f0102e4f:	50                   	push   %eax
f0102e50:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102e56:	50                   	push   %eax
f0102e57:	68 a3 03 00 00       	push   $0x3a3
f0102e5c:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102e62:	50                   	push   %eax
f0102e63:	e8 73 d2 ff ff       	call   f01000db <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102e68:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e6b:	8d 83 b4 58 f8 ff    	lea    -0x7a74c(%ebx),%eax
f0102e71:	50                   	push   %eax
f0102e72:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102e78:	50                   	push   %eax
f0102e79:	68 a4 03 00 00       	push   $0x3a4
f0102e7e:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102e84:	50                   	push   %eax
f0102e85:	e8 51 d2 ff ff       	call   f01000db <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102e8a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e8d:	8d 83 c4 5c f8 ff    	lea    -0x7a33c(%ebx),%eax
f0102e93:	50                   	push   %eax
f0102e94:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102e9a:	50                   	push   %eax
f0102e9b:	68 a7 03 00 00       	push   $0x3a7
f0102ea0:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102ea6:	50                   	push   %eax
f0102ea7:	e8 2f d2 ff ff       	call   f01000db <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102eac:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eaf:	8d 83 e4 5d f8 ff    	lea    -0x7a21c(%ebx),%eax
f0102eb5:	50                   	push   %eax
f0102eb6:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102ebc:	50                   	push   %eax
f0102ebd:	68 a8 03 00 00       	push   $0x3a8
f0102ec2:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102ec8:	50                   	push   %eax
f0102ec9:	e8 0d d2 ff ff       	call   f01000db <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102ece:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ed1:	8d 83 18 5e f8 ff    	lea    -0x7a1e8(%ebx),%eax
f0102ed7:	50                   	push   %eax
f0102ed8:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102ede:	50                   	push   %eax
f0102edf:	68 a9 03 00 00       	push   $0x3a9
f0102ee4:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102eea:	50                   	push   %eax
f0102eeb:	e8 eb d1 ff ff       	call   f01000db <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) != 0);
f0102ef0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ef3:	8d 83 50 5e f8 ff    	lea    -0x7a1b0(%ebx),%eax
f0102ef9:	50                   	push   %eax
f0102efa:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102f00:	50                   	push   %eax
f0102f01:	68 ac 03 00 00       	push   $0x3ac
f0102f06:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102f0c:	50                   	push   %eax
f0102f0d:	e8 c9 d1 ff ff       	call   f01000db <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102f12:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f15:	8d 83 8c 5e f8 ff    	lea    -0x7a174(%ebx),%eax
f0102f1b:	50                   	push   %eax
f0102f1c:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102f22:	50                   	push   %eax
f0102f23:	68 af 03 00 00       	push   $0x3af
f0102f28:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102f2e:	50                   	push   %eax
f0102f2f:	e8 a7 d1 ff ff       	call   f01000db <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102f34:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f37:	8d 83 18 5e f8 ff    	lea    -0x7a1e8(%ebx),%eax
f0102f3d:	50                   	push   %eax
f0102f3e:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102f44:	50                   	push   %eax
f0102f45:	68 b0 03 00 00       	push   $0x3b0
f0102f4a:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102f50:	50                   	push   %eax
f0102f51:	e8 85 d1 ff ff       	call   f01000db <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102f56:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f59:	8d 83 c8 5e f8 ff    	lea    -0x7a138(%ebx),%eax
f0102f5f:	50                   	push   %eax
f0102f60:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102f66:	50                   	push   %eax
f0102f67:	68 b3 03 00 00       	push   $0x3b3
f0102f6c:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102f72:	50                   	push   %eax
f0102f73:	e8 63 d1 ff ff       	call   f01000db <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102f78:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f7b:	8d 83 f4 5e f8 ff    	lea    -0x7a10c(%ebx),%eax
f0102f81:	50                   	push   %eax
f0102f82:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102f88:	50                   	push   %eax
f0102f89:	68 b4 03 00 00       	push   $0x3b4
f0102f8e:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102f94:	50                   	push   %eax
f0102f95:	e8 41 d1 ff ff       	call   f01000db <_panic>
	assert(pp1->pp_ref == 2);
f0102f9a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f9d:	8d 83 ca 58 f8 ff    	lea    -0x7a736(%ebx),%eax
f0102fa3:	50                   	push   %eax
f0102fa4:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102faa:	50                   	push   %eax
f0102fab:	68 b6 03 00 00       	push   $0x3b6
f0102fb0:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102fb6:	50                   	push   %eax
f0102fb7:	e8 1f d1 ff ff       	call   f01000db <_panic>
	assert(pp2->pp_ref == 0);
f0102fbc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fbf:	8d 83 db 58 f8 ff    	lea    -0x7a725(%ebx),%eax
f0102fc5:	50                   	push   %eax
f0102fc6:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102fcc:	50                   	push   %eax
f0102fcd:	68 b7 03 00 00       	push   $0x3b7
f0102fd2:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102fd8:	50                   	push   %eax
f0102fd9:	e8 fd d0 ff ff       	call   f01000db <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102fde:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fe1:	8d 83 24 5f f8 ff    	lea    -0x7a0dc(%ebx),%eax
f0102fe7:	50                   	push   %eax
f0102fe8:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0102fee:	50                   	push   %eax
f0102fef:	68 ba 03 00 00       	push   $0x3ba
f0102ff4:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0102ffa:	50                   	push   %eax
f0102ffb:	e8 db d0 ff ff       	call   f01000db <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0103000:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103003:	8d 83 48 5f f8 ff    	lea    -0x7a0b8(%ebx),%eax
f0103009:	50                   	push   %eax
f010300a:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103010:	50                   	push   %eax
f0103011:	68 be 03 00 00       	push   $0x3be
f0103016:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010301c:	50                   	push   %eax
f010301d:	e8 b9 d0 ff ff       	call   f01000db <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103022:	89 cb                	mov    %ecx,%ebx
f0103024:	8d 81 f4 5e f8 ff    	lea    -0x7a10c(%ecx),%eax
f010302a:	50                   	push   %eax
f010302b:	8d 81 68 56 f8 ff    	lea    -0x7a998(%ecx),%eax
f0103031:	50                   	push   %eax
f0103032:	68 bf 03 00 00       	push   $0x3bf
f0103037:	8d 81 f2 55 f8 ff    	lea    -0x7aa0e(%ecx),%eax
f010303d:	50                   	push   %eax
f010303e:	e8 98 d0 ff ff       	call   f01000db <_panic>
	assert(pp1->pp_ref == 1);
f0103043:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103046:	8d 83 81 58 f8 ff    	lea    -0x7a77f(%ebx),%eax
f010304c:	50                   	push   %eax
f010304d:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103053:	50                   	push   %eax
f0103054:	68 c0 03 00 00       	push   $0x3c0
f0103059:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010305f:	50                   	push   %eax
f0103060:	e8 76 d0 ff ff       	call   f01000db <_panic>
	assert(pp2->pp_ref == 0);
f0103065:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103068:	8d 83 db 58 f8 ff    	lea    -0x7a725(%ebx),%eax
f010306e:	50                   	push   %eax
f010306f:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103075:	50                   	push   %eax
f0103076:	68 c1 03 00 00       	push   $0x3c1
f010307b:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103081:	50                   	push   %eax
f0103082:	e8 54 d0 ff ff       	call   f01000db <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0103087:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010308a:	8d 83 6c 5f f8 ff    	lea    -0x7a094(%ebx),%eax
f0103090:	50                   	push   %eax
f0103091:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103097:	50                   	push   %eax
f0103098:	68 c4 03 00 00       	push   $0x3c4
f010309d:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01030a3:	50                   	push   %eax
f01030a4:	e8 32 d0 ff ff       	call   f01000db <_panic>
	assert(pp1->pp_ref);
f01030a9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030ac:	8d 83 ec 58 f8 ff    	lea    -0x7a714(%ebx),%eax
f01030b2:	50                   	push   %eax
f01030b3:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01030b9:	50                   	push   %eax
f01030ba:	68 c5 03 00 00       	push   $0x3c5
f01030bf:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01030c5:	50                   	push   %eax
f01030c6:	e8 10 d0 ff ff       	call   f01000db <_panic>
	assert(pp1->pp_link == NULL);
f01030cb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030ce:	8d 83 f8 58 f8 ff    	lea    -0x7a708(%ebx),%eax
f01030d4:	50                   	push   %eax
f01030d5:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01030db:	50                   	push   %eax
f01030dc:	68 c6 03 00 00       	push   $0x3c6
f01030e1:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01030e7:	50                   	push   %eax
f01030e8:	e8 ee cf ff ff       	call   f01000db <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01030ed:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030f0:	8d 83 48 5f f8 ff    	lea    -0x7a0b8(%ebx),%eax
f01030f6:	50                   	push   %eax
f01030f7:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01030fd:	50                   	push   %eax
f01030fe:	68 ca 03 00 00       	push   $0x3ca
f0103103:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103109:	50                   	push   %eax
f010310a:	e8 cc cf ff ff       	call   f01000db <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010310f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103112:	8d 83 a4 5f f8 ff    	lea    -0x7a05c(%ebx),%eax
f0103118:	50                   	push   %eax
f0103119:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010311f:	50                   	push   %eax
f0103120:	68 cb 03 00 00       	push   $0x3cb
f0103125:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010312b:	50                   	push   %eax
f010312c:	e8 aa cf ff ff       	call   f01000db <_panic>
	assert(pp1->pp_ref == 0);
f0103131:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103134:	8d 83 0d 59 f8 ff    	lea    -0x7a6f3(%ebx),%eax
f010313a:	50                   	push   %eax
f010313b:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103141:	50                   	push   %eax
f0103142:	68 cc 03 00 00       	push   $0x3cc
f0103147:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010314d:	50                   	push   %eax
f010314e:	e8 88 cf ff ff       	call   f01000db <_panic>
	assert(pp2->pp_ref == 0);
f0103153:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103156:	8d 83 db 58 f8 ff    	lea    -0x7a725(%ebx),%eax
f010315c:	50                   	push   %eax
f010315d:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103163:	50                   	push   %eax
f0103164:	68 cd 03 00 00       	push   $0x3cd
f0103169:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010316f:	50                   	push   %eax
f0103170:	e8 66 cf ff ff       	call   f01000db <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0103175:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103178:	8d 83 cc 5f f8 ff    	lea    -0x7a034(%ebx),%eax
f010317e:	50                   	push   %eax
f010317f:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103185:	50                   	push   %eax
f0103186:	68 d0 03 00 00       	push   $0x3d0
f010318b:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103191:	50                   	push   %eax
f0103192:	e8 44 cf ff ff       	call   f01000db <_panic>
	assert(!page_alloc(0));
f0103197:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010319a:	8d 83 2f 58 f8 ff    	lea    -0x7a7d1(%ebx),%eax
f01031a0:	50                   	push   %eax
f01031a1:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01031a7:	50                   	push   %eax
f01031a8:	68 d3 03 00 00       	push   $0x3d3
f01031ad:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01031b3:	50                   	push   %eax
f01031b4:	e8 22 cf ff ff       	call   f01000db <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01031b9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031bc:	8d 83 6c 5c f8 ff    	lea    -0x7a394(%ebx),%eax
f01031c2:	50                   	push   %eax
f01031c3:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01031c9:	50                   	push   %eax
f01031ca:	68 d7 03 00 00       	push   $0x3d7
f01031cf:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01031d5:	50                   	push   %eax
f01031d6:	e8 00 cf ff ff       	call   f01000db <_panic>
	assert(pp0->pp_ref == 1);
f01031db:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031de:	8d 83 92 58 f8 ff    	lea    -0x7a76e(%ebx),%eax
f01031e4:	50                   	push   %eax
f01031e5:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01031eb:	50                   	push   %eax
f01031ec:	68 d9 03 00 00       	push   $0x3d9
f01031f1:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01031f7:	50                   	push   %eax
f01031f8:	e8 de ce ff ff       	call   f01000db <_panic>
f01031fd:	52                   	push   %edx
f01031fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103201:	8d 83 a0 59 f8 ff    	lea    -0x7a660(%ebx),%eax
f0103207:	50                   	push   %eax
f0103208:	68 e1 03 00 00       	push   $0x3e1
f010320d:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103213:	50                   	push   %eax
f0103214:	e8 c2 ce ff ff       	call   f01000db <_panic>
	assert(ptep == ptep1 + PTX(va));
f0103219:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010321c:	8d 83 1e 59 f8 ff    	lea    -0x7a6e2(%ebx),%eax
f0103222:	50                   	push   %eax
f0103223:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103229:	50                   	push   %eax
f010322a:	68 e2 03 00 00       	push   $0x3e2
f010322f:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103235:	50                   	push   %eax
f0103236:	e8 a0 ce ff ff       	call   f01000db <_panic>
f010323b:	52                   	push   %edx
f010323c:	8d 83 a0 59 f8 ff    	lea    -0x7a660(%ebx),%eax
f0103242:	50                   	push   %eax
f0103243:	6a 5c                	push   $0x5c
f0103245:	8d 83 35 56 f8 ff    	lea    -0x7a9cb(%ebx),%eax
f010324b:	50                   	push   %eax
f010324c:	e8 8a ce ff ff       	call   f01000db <_panic>
f0103251:	52                   	push   %edx
f0103252:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103255:	8d 83 a0 59 f8 ff    	lea    -0x7a660(%ebx),%eax
f010325b:	50                   	push   %eax
f010325c:	6a 5c                	push   $0x5c
f010325e:	8d 83 35 56 f8 ff    	lea    -0x7a9cb(%ebx),%eax
f0103264:	50                   	push   %eax
f0103265:	e8 71 ce ff ff       	call   f01000db <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010326a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010326d:	8d 83 36 59 f8 ff    	lea    -0x7a6ca(%ebx),%eax
f0103273:	50                   	push   %eax
f0103274:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010327a:	50                   	push   %eax
f010327b:	68 ec 03 00 00       	push   $0x3ec
f0103280:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103286:	50                   	push   %eax
f0103287:	e8 4f ce ff ff       	call   f01000db <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010328c:	50                   	push   %eax
f010328d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103290:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f0103296:	50                   	push   %eax
f0103297:	68 bd 00 00 00       	push   $0xbd
f010329c:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01032a2:	50                   	push   %eax
f01032a3:	e8 33 ce ff ff       	call   f01000db <_panic>
f01032a8:	50                   	push   %eax
f01032a9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032ac:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f01032b2:	50                   	push   %eax
f01032b3:	68 bf 00 00 00       	push   $0xbf
f01032b8:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01032be:	50                   	push   %eax
f01032bf:	e8 17 ce ff ff       	call   f01000db <_panic>
f01032c4:	50                   	push   %eax
f01032c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032c8:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f01032ce:	50                   	push   %eax
f01032cf:	68 c9 00 00 00       	push   $0xc9
f01032d4:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01032da:	50                   	push   %eax
f01032db:	e8 fb cd ff ff       	call   f01000db <_panic>
f01032e0:	50                   	push   %eax
f01032e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032e4:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f01032ea:	50                   	push   %eax
f01032eb:	68 ca 00 00 00       	push   $0xca
f01032f0:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01032f6:	50                   	push   %eax
f01032f7:	e8 df cd ff ff       	call   f01000db <_panic>
f01032fc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032ff:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f0103305:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f010330b:	50                   	push   %eax
f010330c:	68 dc 00 00 00       	push   $0xdc
f0103311:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103317:	50                   	push   %eax
f0103318:	e8 be cd ff ff       	call   f01000db <_panic>
f010331d:	ff 75 bc             	push   -0x44(%ebp)
f0103320:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103323:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f0103329:	50                   	push   %eax
f010332a:	68 24 03 00 00       	push   $0x324
f010332f:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103335:	50                   	push   %eax
f0103336:	e8 a0 cd ff ff       	call   f01000db <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010333b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010333e:	8d 83 f0 5f f8 ff    	lea    -0x7a010(%ebx),%eax
f0103344:	50                   	push   %eax
f0103345:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010334b:	50                   	push   %eax
f010334c:	68 24 03 00 00       	push   $0x324
f0103351:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103357:	50                   	push   %eax
f0103358:	e8 7e cd ff ff       	call   f01000db <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010335d:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0103360:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0103363:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103366:	c7 c0 88 2b 18 f0    	mov    $0xf0182b88,%eax
f010336c:	8b 00                	mov    (%eax),%eax
f010336e:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0103371:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0103376:	8d 88 00 00 40 21    	lea    0x21400000(%eax),%ecx
f010337c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010337f:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0103382:	89 c6                	mov    %eax,%esi
f0103384:	89 da                	mov    %ebx,%edx
f0103386:	89 f8                	mov    %edi,%eax
f0103388:	e8 19 de ff ff       	call   f01011a6 <check_va2pa>
f010338d:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0103393:	76 45                	jbe    f01033da <mem_init+0x188c>
f0103395:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103398:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f010339b:	39 c2                	cmp    %eax,%edx
f010339d:	75 59                	jne    f01033f8 <mem_init+0x18aa>
	for (i = 0; i < n; i += PGSIZE)
f010339f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01033a5:	81 fb 00 80 c1 ee    	cmp    $0xeec18000,%ebx
f01033ab:	75 d7                	jne    f0103384 <mem_init+0x1836>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01033ad:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01033b0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01033b3:	c1 e0 0c             	shl    $0xc,%eax
f01033b6:	89 f3                	mov    %esi,%ebx
f01033b8:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01033bb:	89 c6                	mov    %eax,%esi
f01033bd:	39 f3                	cmp    %esi,%ebx
f01033bf:	73 7b                	jae    f010343c <mem_init+0x18ee>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01033c1:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01033c7:	89 f8                	mov    %edi,%eax
f01033c9:	e8 d8 dd ff ff       	call   f01011a6 <check_va2pa>
f01033ce:	39 c3                	cmp    %eax,%ebx
f01033d0:	75 48                	jne    f010341a <mem_init+0x18cc>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01033d2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01033d8:	eb e3                	jmp    f01033bd <mem_init+0x186f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033da:	ff 75 c0             	push   -0x40(%ebp)
f01033dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01033e0:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f01033e6:	50                   	push   %eax
f01033e7:	68 29 03 00 00       	push   $0x329
f01033ec:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01033f2:	50                   	push   %eax
f01033f3:	e8 e3 cc ff ff       	call   f01000db <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01033f8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01033fb:	8d 83 24 60 f8 ff    	lea    -0x79fdc(%ebx),%eax
f0103401:	50                   	push   %eax
f0103402:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103408:	50                   	push   %eax
f0103409:	68 29 03 00 00       	push   $0x329
f010340e:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103414:	50                   	push   %eax
f0103415:	e8 c1 cc ff ff       	call   f01000db <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010341a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010341d:	8d 83 58 60 f8 ff    	lea    -0x79fa8(%ebx),%eax
f0103423:	50                   	push   %eax
f0103424:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010342a:	50                   	push   %eax
f010342b:	68 2d 03 00 00       	push   $0x32d
f0103430:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103436:	50                   	push   %eax
f0103437:	e8 9f cc ff ff       	call   f01000db <_panic>
f010343c:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103441:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103444:	05 00 80 00 20       	add    $0x20008000,%eax
f0103449:	89 c6                	mov    %eax,%esi
f010344b:	89 da                	mov    %ebx,%edx
f010344d:	89 f8                	mov    %edi,%eax
f010344f:	e8 52 dd ff ff       	call   f01011a6 <check_va2pa>
f0103454:	89 c2                	mov    %eax,%edx
f0103456:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0103459:	39 c2                	cmp    %eax,%edx
f010345b:	75 44                	jne    f01034a1 <mem_init+0x1953>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010345d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103463:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0103469:	75 e0                	jne    f010344b <mem_init+0x18fd>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010346b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010346e:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0103473:	89 f8                	mov    %edi,%eax
f0103475:	e8 2c dd ff ff       	call   f01011a6 <check_va2pa>
f010347a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010347d:	74 71                	je     f01034f0 <mem_init+0x19a2>
f010347f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103482:	8d 83 c8 60 f8 ff    	lea    -0x79f38(%ebx),%eax
f0103488:	50                   	push   %eax
f0103489:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010348f:	50                   	push   %eax
f0103490:	68 32 03 00 00       	push   $0x332
f0103495:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010349b:	50                   	push   %eax
f010349c:	e8 3a cc ff ff       	call   f01000db <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01034a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01034a4:	8d 83 80 60 f8 ff    	lea    -0x79f80(%ebx),%eax
f01034aa:	50                   	push   %eax
f01034ab:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01034b1:	50                   	push   %eax
f01034b2:	68 31 03 00 00       	push   $0x331
f01034b7:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01034bd:	50                   	push   %eax
f01034be:	e8 18 cc ff ff       	call   f01000db <_panic>
		switch (i) {
f01034c3:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f01034c9:	75 25                	jne    f01034f0 <mem_init+0x19a2>
			assert(pgdir[i] & PTE_P);
f01034cb:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f01034cf:	74 4f                	je     f0103520 <mem_init+0x19d2>
	for (i = 0; i < NPDENTRIES; i++) {
f01034d1:	83 c6 01             	add    $0x1,%esi
f01034d4:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f01034da:	0f 87 b1 00 00 00    	ja     f0103591 <mem_init+0x1a43>
		switch (i) {
f01034e0:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f01034e6:	77 db                	ja     f01034c3 <mem_init+0x1975>
f01034e8:	81 fe ba 03 00 00    	cmp    $0x3ba,%esi
f01034ee:	77 db                	ja     f01034cb <mem_init+0x197d>
			if (i >= PDX(KERNBASE)) {
f01034f0:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f01034f6:	77 4a                	ja     f0103542 <mem_init+0x19f4>
				assert(pgdir[i] == 0);
f01034f8:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f01034fc:	74 d3                	je     f01034d1 <mem_init+0x1983>
f01034fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103501:	8d 83 90 59 f8 ff    	lea    -0x7a670(%ebx),%eax
f0103507:	50                   	push   %eax
f0103508:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010350e:	50                   	push   %eax
f010350f:	68 42 03 00 00       	push   $0x342
f0103514:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010351a:	50                   	push   %eax
f010351b:	e8 bb cb ff ff       	call   f01000db <_panic>
			assert(pgdir[i] & PTE_P);
f0103520:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103523:	8d 83 6e 59 f8 ff    	lea    -0x7a692(%ebx),%eax
f0103529:	50                   	push   %eax
f010352a:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103530:	50                   	push   %eax
f0103531:	68 3b 03 00 00       	push   $0x33b
f0103536:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010353c:	50                   	push   %eax
f010353d:	e8 99 cb ff ff       	call   f01000db <_panic>
				assert(pgdir[i] & PTE_P);
f0103542:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f0103545:	a8 01                	test   $0x1,%al
f0103547:	74 26                	je     f010356f <mem_init+0x1a21>
				assert(pgdir[i] & PTE_W);
f0103549:	a8 02                	test   $0x2,%al
f010354b:	75 84                	jne    f01034d1 <mem_init+0x1983>
f010354d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103550:	8d 83 7f 59 f8 ff    	lea    -0x7a681(%ebx),%eax
f0103556:	50                   	push   %eax
f0103557:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010355d:	50                   	push   %eax
f010355e:	68 40 03 00 00       	push   $0x340
f0103563:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103569:	50                   	push   %eax
f010356a:	e8 6c cb ff ff       	call   f01000db <_panic>
				assert(pgdir[i] & PTE_P);
f010356f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103572:	8d 83 6e 59 f8 ff    	lea    -0x7a692(%ebx),%eax
f0103578:	50                   	push   %eax
f0103579:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010357f:	50                   	push   %eax
f0103580:	68 3f 03 00 00       	push   $0x33f
f0103585:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010358b:	50                   	push   %eax
f010358c:	e8 4a cb ff ff       	call   f01000db <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0103591:	83 ec 0c             	sub    $0xc,%esp
f0103594:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103597:	8d 83 f8 60 f8 ff    	lea    -0x79f08(%ebx),%eax
f010359d:	50                   	push   %eax
f010359e:	e8 75 0d 00 00       	call   f0104318 <cprintf>
	lcr3(PADDR(kern_pgdir));
f01035a3:	8b 83 0c 23 00 00    	mov    0x230c(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01035a9:	83 c4 10             	add    $0x10,%esp
f01035ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035b1:	0f 86 2c 02 00 00    	jbe    f01037e3 <mem_init+0x1c95>
	return (physaddr_t)kva - KERNBASE;
f01035b7:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01035bc:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01035bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01035c4:	e8 59 dc ff ff       	call   f0101222 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01035c9:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01035cc:	83 e0 f3             	and    $0xfffffff3,%eax
f01035cf:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01035d4:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01035d7:	83 ec 0c             	sub    $0xc,%esp
f01035da:	6a 00                	push   $0x0
f01035dc:	e8 5d e0 ff ff       	call   f010163e <page_alloc>
f01035e1:	89 c6                	mov    %eax,%esi
f01035e3:	83 c4 10             	add    $0x10,%esp
f01035e6:	85 c0                	test   %eax,%eax
f01035e8:	0f 84 11 02 00 00    	je     f01037ff <mem_init+0x1cb1>
	assert((pp1 = page_alloc(0)));
f01035ee:	83 ec 0c             	sub    $0xc,%esp
f01035f1:	6a 00                	push   $0x0
f01035f3:	e8 46 e0 ff ff       	call   f010163e <page_alloc>
f01035f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01035fb:	83 c4 10             	add    $0x10,%esp
f01035fe:	85 c0                	test   %eax,%eax
f0103600:	0f 84 1b 02 00 00    	je     f0103821 <mem_init+0x1cd3>
	assert((pp2 = page_alloc(0)));
f0103606:	83 ec 0c             	sub    $0xc,%esp
f0103609:	6a 00                	push   $0x0
f010360b:	e8 2e e0 ff ff       	call   f010163e <page_alloc>
f0103610:	89 c7                	mov    %eax,%edi
f0103612:	83 c4 10             	add    $0x10,%esp
f0103615:	85 c0                	test   %eax,%eax
f0103617:	0f 84 26 02 00 00    	je     f0103843 <mem_init+0x1cf5>
	page_free(pp0);
f010361d:	83 ec 0c             	sub    $0xc,%esp
f0103620:	56                   	push   %esi
f0103621:	e8 b7 e0 ff ff       	call   f01016dd <page_free>
	return (pp - pages) << PGSHIFT;
f0103626:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103629:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010362c:	2b 81 08 23 00 00    	sub    0x2308(%ecx),%eax
f0103632:	c1 f8 03             	sar    $0x3,%eax
f0103635:	89 c2                	mov    %eax,%edx
f0103637:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010363a:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010363f:	83 c4 10             	add    $0x10,%esp
f0103642:	3b 81 10 23 00 00    	cmp    0x2310(%ecx),%eax
f0103648:	0f 83 17 02 00 00    	jae    f0103865 <mem_init+0x1d17>
	memset(page2kva(pp1), 1, PGSIZE);
f010364e:	83 ec 04             	sub    $0x4,%esp
f0103651:	68 00 10 00 00       	push   $0x1000
f0103656:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103658:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010365e:	52                   	push   %edx
f010365f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103662:	e8 ae 1c 00 00       	call   f0105315 <memset>
	return (pp - pages) << PGSHIFT;
f0103667:	89 f8                	mov    %edi,%eax
f0103669:	2b 83 08 23 00 00    	sub    0x2308(%ebx),%eax
f010366f:	c1 f8 03             	sar    $0x3,%eax
f0103672:	89 c2                	mov    %eax,%edx
f0103674:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103677:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010367c:	83 c4 10             	add    $0x10,%esp
f010367f:	3b 83 10 23 00 00    	cmp    0x2310(%ebx),%eax
f0103685:	0f 83 f2 01 00 00    	jae    f010387d <mem_init+0x1d2f>
	memset(page2kva(pp2), 2, PGSIZE);
f010368b:	83 ec 04             	sub    $0x4,%esp
f010368e:	68 00 10 00 00       	push   $0x1000
f0103693:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0103695:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010369b:	52                   	push   %edx
f010369c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010369f:	e8 71 1c 00 00       	call   f0105315 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01036a4:	6a 02                	push   $0x2
f01036a6:	68 00 10 00 00       	push   $0x1000
f01036ab:	ff 75 d0             	push   -0x30(%ebp)
f01036ae:	ff b3 0c 23 00 00    	push   0x230c(%ebx)
f01036b4:	e8 33 e3 ff ff       	call   f01019ec <page_insert>
	assert(pp1->pp_ref == 1);
f01036b9:	83 c4 20             	add    $0x20,%esp
f01036bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01036bf:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01036c4:	0f 85 cc 01 00 00    	jne    f0103896 <mem_init+0x1d48>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01036ca:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01036d1:	01 01 01 
f01036d4:	0f 85 de 01 00 00    	jne    f01038b8 <mem_init+0x1d6a>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01036da:	6a 02                	push   $0x2
f01036dc:	68 00 10 00 00       	push   $0x1000
f01036e1:	57                   	push   %edi
f01036e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01036e5:	ff b0 0c 23 00 00    	push   0x230c(%eax)
f01036eb:	e8 fc e2 ff ff       	call   f01019ec <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01036f0:	83 c4 10             	add    $0x10,%esp
f01036f3:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01036fa:	02 02 02 
f01036fd:	0f 85 d7 01 00 00    	jne    f01038da <mem_init+0x1d8c>
	assert(pp2->pp_ref == 1);
f0103703:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103708:	0f 85 ee 01 00 00    	jne    f01038fc <mem_init+0x1dae>
	assert(pp1->pp_ref == 0);
f010370e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103711:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0103716:	0f 85 02 02 00 00    	jne    f010391e <mem_init+0x1dd0>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010371c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103723:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0103726:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103729:	89 f8                	mov    %edi,%eax
f010372b:	2b 81 08 23 00 00    	sub    0x2308(%ecx),%eax
f0103731:	c1 f8 03             	sar    $0x3,%eax
f0103734:	89 c2                	mov    %eax,%edx
f0103736:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103739:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010373e:	3b 81 10 23 00 00    	cmp    0x2310(%ecx),%eax
f0103744:	0f 83 f6 01 00 00    	jae    f0103940 <mem_init+0x1df2>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010374a:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0103751:	03 03 03 
f0103754:	0f 85 fe 01 00 00    	jne    f0103958 <mem_init+0x1e0a>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010375a:	83 ec 08             	sub    $0x8,%esp
f010375d:	68 00 10 00 00       	push   $0x1000
f0103762:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103765:	ff b0 0c 23 00 00    	push   0x230c(%eax)
f010376b:	e8 36 e2 ff ff       	call   f01019a6 <page_remove>
	assert(pp2->pp_ref == 0);
f0103770:	83 c4 10             	add    $0x10,%esp
f0103773:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103778:	0f 85 fc 01 00 00    	jne    f010397a <mem_init+0x1e2c>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010377e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103781:	8b 88 0c 23 00 00    	mov    0x230c(%eax),%ecx
f0103787:	8b 11                	mov    (%ecx),%edx
f0103789:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f010378f:	89 f7                	mov    %esi,%edi
f0103791:	2b b8 08 23 00 00    	sub    0x2308(%eax),%edi
f0103797:	89 f8                	mov    %edi,%eax
f0103799:	c1 f8 03             	sar    $0x3,%eax
f010379c:	c1 e0 0c             	shl    $0xc,%eax
f010379f:	39 c2                	cmp    %eax,%edx
f01037a1:	0f 85 f5 01 00 00    	jne    f010399c <mem_init+0x1e4e>
	kern_pgdir[0] = 0;
f01037a7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01037ad:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01037b2:	0f 85 06 02 00 00    	jne    f01039be <mem_init+0x1e70>
	pp0->pp_ref = 0;
f01037b8:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01037be:	83 ec 0c             	sub    $0xc,%esp
f01037c1:	56                   	push   %esi
f01037c2:	e8 16 df ff ff       	call   f01016dd <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01037c7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01037ca:	8d 83 8c 61 f8 ff    	lea    -0x79e74(%ebx),%eax
f01037d0:	89 04 24             	mov    %eax,(%esp)
f01037d3:	e8 40 0b 00 00       	call   f0104318 <cprintf>
}
f01037d8:	83 c4 10             	add    $0x10,%esp
f01037db:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037de:	5b                   	pop    %ebx
f01037df:	5e                   	pop    %esi
f01037e0:	5f                   	pop    %edi
f01037e1:	5d                   	pop    %ebp
f01037e2:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037e3:	50                   	push   %eax
f01037e4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01037e7:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f01037ed:	50                   	push   %eax
f01037ee:	68 f3 00 00 00       	push   $0xf3
f01037f3:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01037f9:	50                   	push   %eax
f01037fa:	e8 dc c8 ff ff       	call   f01000db <_panic>
	assert((pp0 = page_alloc(0)));
f01037ff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103802:	8d 83 84 57 f8 ff    	lea    -0x7a87c(%ebx),%eax
f0103808:	50                   	push   %eax
f0103809:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010380f:	50                   	push   %eax
f0103810:	68 07 04 00 00       	push   $0x407
f0103815:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010381b:	50                   	push   %eax
f010381c:	e8 ba c8 ff ff       	call   f01000db <_panic>
	assert((pp1 = page_alloc(0)));
f0103821:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103824:	8d 83 9a 57 f8 ff    	lea    -0x7a866(%ebx),%eax
f010382a:	50                   	push   %eax
f010382b:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103831:	50                   	push   %eax
f0103832:	68 08 04 00 00       	push   $0x408
f0103837:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010383d:	50                   	push   %eax
f010383e:	e8 98 c8 ff ff       	call   f01000db <_panic>
	assert((pp2 = page_alloc(0)));
f0103843:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103846:	8d 83 b0 57 f8 ff    	lea    -0x7a850(%ebx),%eax
f010384c:	50                   	push   %eax
f010384d:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103853:	50                   	push   %eax
f0103854:	68 09 04 00 00       	push   $0x409
f0103859:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010385f:	50                   	push   %eax
f0103860:	e8 76 c8 ff ff       	call   f01000db <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103865:	52                   	push   %edx
f0103866:	89 cb                	mov    %ecx,%ebx
f0103868:	8d 81 a0 59 f8 ff    	lea    -0x7a660(%ecx),%eax
f010386e:	50                   	push   %eax
f010386f:	6a 5c                	push   $0x5c
f0103871:	8d 81 35 56 f8 ff    	lea    -0x7a9cb(%ecx),%eax
f0103877:	50                   	push   %eax
f0103878:	e8 5e c8 ff ff       	call   f01000db <_panic>
f010387d:	52                   	push   %edx
f010387e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103881:	8d 83 a0 59 f8 ff    	lea    -0x7a660(%ebx),%eax
f0103887:	50                   	push   %eax
f0103888:	6a 5c                	push   $0x5c
f010388a:	8d 83 35 56 f8 ff    	lea    -0x7a9cb(%ebx),%eax
f0103890:	50                   	push   %eax
f0103891:	e8 45 c8 ff ff       	call   f01000db <_panic>
	assert(pp1->pp_ref == 1);
f0103896:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103899:	8d 83 81 58 f8 ff    	lea    -0x7a77f(%ebx),%eax
f010389f:	50                   	push   %eax
f01038a0:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01038a6:	50                   	push   %eax
f01038a7:	68 0e 04 00 00       	push   $0x40e
f01038ac:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01038b2:	50                   	push   %eax
f01038b3:	e8 23 c8 ff ff       	call   f01000db <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01038b8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01038bb:	8d 83 18 61 f8 ff    	lea    -0x79ee8(%ebx),%eax
f01038c1:	50                   	push   %eax
f01038c2:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01038c8:	50                   	push   %eax
f01038c9:	68 0f 04 00 00       	push   $0x40f
f01038ce:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01038d4:	50                   	push   %eax
f01038d5:	e8 01 c8 ff ff       	call   f01000db <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01038da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01038dd:	8d 83 3c 61 f8 ff    	lea    -0x79ec4(%ebx),%eax
f01038e3:	50                   	push   %eax
f01038e4:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01038ea:	50                   	push   %eax
f01038eb:	68 11 04 00 00       	push   $0x411
f01038f0:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01038f6:	50                   	push   %eax
f01038f7:	e8 df c7 ff ff       	call   f01000db <_panic>
	assert(pp2->pp_ref == 1);
f01038fc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01038ff:	8d 83 a3 58 f8 ff    	lea    -0x7a75d(%ebx),%eax
f0103905:	50                   	push   %eax
f0103906:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010390c:	50                   	push   %eax
f010390d:	68 12 04 00 00       	push   $0x412
f0103912:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103918:	50                   	push   %eax
f0103919:	e8 bd c7 ff ff       	call   f01000db <_panic>
	assert(pp1->pp_ref == 0);
f010391e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103921:	8d 83 0d 59 f8 ff    	lea    -0x7a6f3(%ebx),%eax
f0103927:	50                   	push   %eax
f0103928:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010392e:	50                   	push   %eax
f010392f:	68 13 04 00 00       	push   $0x413
f0103934:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f010393a:	50                   	push   %eax
f010393b:	e8 9b c7 ff ff       	call   f01000db <_panic>
f0103940:	52                   	push   %edx
f0103941:	89 cb                	mov    %ecx,%ebx
f0103943:	8d 81 a0 59 f8 ff    	lea    -0x7a660(%ecx),%eax
f0103949:	50                   	push   %eax
f010394a:	6a 5c                	push   $0x5c
f010394c:	8d 81 35 56 f8 ff    	lea    -0x7a9cb(%ecx),%eax
f0103952:	50                   	push   %eax
f0103953:	e8 83 c7 ff ff       	call   f01000db <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103958:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010395b:	8d 83 60 61 f8 ff    	lea    -0x79ea0(%ebx),%eax
f0103961:	50                   	push   %eax
f0103962:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0103968:	50                   	push   %eax
f0103969:	68 15 04 00 00       	push   $0x415
f010396e:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103974:	50                   	push   %eax
f0103975:	e8 61 c7 ff ff       	call   f01000db <_panic>
	assert(pp2->pp_ref == 0);
f010397a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010397d:	8d 83 db 58 f8 ff    	lea    -0x7a725(%ebx),%eax
f0103983:	50                   	push   %eax
f0103984:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f010398a:	50                   	push   %eax
f010398b:	68 17 04 00 00       	push   $0x417
f0103990:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f0103996:	50                   	push   %eax
f0103997:	e8 3f c7 ff ff       	call   f01000db <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010399c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010399f:	8d 83 6c 5c f8 ff    	lea    -0x7a394(%ebx),%eax
f01039a5:	50                   	push   %eax
f01039a6:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01039ac:	50                   	push   %eax
f01039ad:	68 1a 04 00 00       	push   $0x41a
f01039b2:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01039b8:	50                   	push   %eax
f01039b9:	e8 1d c7 ff ff       	call   f01000db <_panic>
	assert(pp0->pp_ref == 1);
f01039be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01039c1:	8d 83 92 58 f8 ff    	lea    -0x7a76e(%ebx),%eax
f01039c7:	50                   	push   %eax
f01039c8:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01039ce:	50                   	push   %eax
f01039cf:	68 1c 04 00 00       	push   $0x41c
f01039d4:	8d 83 f2 55 f8 ff    	lea    -0x7aa0e(%ebx),%eax
f01039da:	50                   	push   %eax
f01039db:	e8 fb c6 ff ff       	call   f01000db <_panic>

f01039e0 <tlb_invalidate>:
{
f01039e0:	55                   	push   %ebp
f01039e1:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01039e3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039e6:	0f 01 38             	invlpg (%eax)
}
f01039e9:	5d                   	pop    %ebp
f01039ea:	c3                   	ret    

f01039eb <user_mem_check>:
}
f01039eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01039f0:	c3                   	ret    

f01039f1 <user_mem_assert>:
}
f01039f1:	c3                   	ret    

f01039f2 <__x86.get_pc_thunk.dx>:
f01039f2:	8b 14 24             	mov    (%esp),%edx
f01039f5:	c3                   	ret    

f01039f6 <__x86.get_pc_thunk.cx>:
f01039f6:	8b 0c 24             	mov    (%esp),%ecx
f01039f9:	c3                   	ret    

f01039fa <__x86.get_pc_thunk.di>:
f01039fa:	8b 3c 24             	mov    (%esp),%edi
f01039fd:	c3                   	ret    

f01039fe <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01039fe:	55                   	push   %ebp
f01039ff:	89 e5                	mov    %esp,%ebp
f0103a01:	53                   	push   %ebx
f0103a02:	e8 ef ff ff ff       	call   f01039f6 <__x86.get_pc_thunk.cx>
f0103a07:	81 c1 61 ce 07 00    	add    $0x7ce61,%ecx
f0103a0d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103a13:	85 c0                	test   %eax,%eax
f0103a15:	74 4c                	je     f0103a63 <envid2env+0x65>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103a17:	89 c2                	mov    %eax,%edx
f0103a19:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103a1f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103a22:	c1 e2 05             	shl    $0x5,%edx
f0103a25:	03 91 20 23 00 00    	add    0x2320(%ecx),%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103a2b:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103a2f:	74 42                	je     f0103a73 <envid2env+0x75>
f0103a31:	39 42 48             	cmp    %eax,0x48(%edx)
f0103a34:	75 49                	jne    f0103a7f <envid2env+0x81>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
	return 0;
f0103a36:	b8 00 00 00 00       	mov    $0x0,%eax
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103a3b:	84 db                	test   %bl,%bl
f0103a3d:	74 2a                	je     f0103a69 <envid2env+0x6b>
f0103a3f:	8b 89 1c 23 00 00    	mov    0x231c(%ecx),%ecx
f0103a45:	39 d1                	cmp    %edx,%ecx
f0103a47:	74 20                	je     f0103a69 <envid2env+0x6b>
f0103a49:	8b 42 4c             	mov    0x4c(%edx),%eax
f0103a4c:	3b 41 48             	cmp    0x48(%ecx),%eax
f0103a4f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103a54:	0f 45 d3             	cmovne %ebx,%edx
f0103a57:	0f 94 c0             	sete   %al
f0103a5a:	0f b6 c0             	movzbl %al,%eax
f0103a5d:	8d 44 00 fe          	lea    -0x2(%eax,%eax,1),%eax
f0103a61:	eb 06                	jmp    f0103a69 <envid2env+0x6b>
		*env_store = curenv;
f0103a63:	8b 91 1c 23 00 00    	mov    0x231c(%ecx),%edx
f0103a69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103a6c:	89 11                	mov    %edx,(%ecx)
}
f0103a6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a71:	c9                   	leave  
f0103a72:	c3                   	ret    
f0103a73:	ba 00 00 00 00       	mov    $0x0,%edx
		return -E_BAD_ENV;
f0103a78:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a7d:	eb ea                	jmp    f0103a69 <envid2env+0x6b>
f0103a7f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a84:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a89:	eb de                	jmp    f0103a69 <envid2env+0x6b>

f0103a8b <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103a8b:	e8 93 cc ff ff       	call   f0100723 <__x86.get_pc_thunk.ax>
f0103a90:	05 d8 cd 07 00       	add    $0x7cdd8,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f0103a95:	8d 80 98 17 00 00    	lea    0x1798(%eax),%eax
f0103a9b:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103a9e:	b8 23 00 00 00       	mov    $0x23,%eax
f0103aa3:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103aa5:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103aa7:	b8 10 00 00 00       	mov    $0x10,%eax
f0103aac:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103aae:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103ab0:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103ab2:	ea b9 3a 10 f0 08 00 	ljmp   $0x8,$0xf0103ab9
	asm volatile("lldt %0" : : "r" (sel));
f0103ab9:	b8 00 00 00 00       	mov    $0x0,%eax
f0103abe:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103ac1:	c3                   	ret    

f0103ac2 <env_init>:
{
f0103ac2:	55                   	push   %ebp
f0103ac3:	89 e5                	mov    %esp,%ebp
f0103ac5:	83 ec 08             	sub    $0x8,%esp
f0103ac8:	e8 29 ff ff ff       	call   f01039f6 <__x86.get_pc_thunk.cx>
f0103acd:	81 c1 9b cd 07 00    	add    $0x7cd9b,%ecx
		envs[i].env_id = 0;
f0103ad3:	8b 91 20 23 00 00    	mov    0x2320(%ecx),%edx
f0103ad9:	8d 42 48             	lea    0x48(%edx),%eax
f0103adc:	81 c2 48 80 01 00    	add    $0x18048,%edx
f0103ae2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		envs[i].env_status = ENV_FREE;
f0103ae8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	for (int i = 0; i < NENV; i++)
f0103aef:	83 c0 60             	add    $0x60,%eax
f0103af2:	39 d0                	cmp    %edx,%eax
f0103af4:	75 ec                	jne    f0103ae2 <env_init+0x20>
	env_free_list = &envs[0];
f0103af6:	8b 91 20 23 00 00    	mov    0x2320(%ecx),%edx
f0103afc:	89 91 24 23 00 00    	mov    %edx,0x2324(%ecx)
f0103b02:	b8 ff 03 00 00       	mov    $0x3ff,%eax
	for (int i = 1; i < NENV; i++)
f0103b07:	83 e8 01             	sub    $0x1,%eax
f0103b0a:	75 fb                	jne    f0103b07 <env_init+0x45>
		temp_ptr->env_link = &envs[i];
f0103b0c:	8d 82 a0 7f 01 00    	lea    0x17fa0(%edx),%eax
f0103b12:	89 42 44             	mov    %eax,0x44(%edx)
	env_init_percpu();
f0103b15:	e8 71 ff ff ff       	call   f0103a8b <env_init_percpu>
}
f0103b1a:	c9                   	leave  
f0103b1b:	c3                   	ret    

f0103b1c <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103b1c:	55                   	push   %ebp
f0103b1d:	89 e5                	mov    %esp,%ebp
f0103b1f:	57                   	push   %edi
f0103b20:	56                   	push   %esi
f0103b21:	53                   	push   %ebx
f0103b22:	83 ec 1c             	sub    $0x1c,%esp
f0103b25:	e8 67 c6 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0103b2a:	81 c3 3e cd 07 00    	add    $0x7cd3e,%ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103b30:	8b b3 24 23 00 00    	mov    0x2324(%ebx),%esi
f0103b36:	85 f6                	test   %esi,%esi
f0103b38:	0f 84 1c 02 00 00    	je     f0103d5a <env_alloc+0x23e>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103b3e:	83 ec 0c             	sub    $0xc,%esp
f0103b41:	6a 01                	push   $0x1
f0103b43:	e8 f6 da ff ff       	call   f010163e <page_alloc>
f0103b48:	89 c1                	mov    %eax,%ecx
f0103b4a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103b4d:	83 c4 10             	add    $0x10,%esp
f0103b50:	85 c0                	test   %eax,%eax
f0103b52:	0f 84 09 02 00 00    	je     f0103d61 <env_alloc+0x245>
	return (pp - pages) << PGSHIFT;
f0103b58:	c7 c0 70 2b 18 f0    	mov    $0xf0182b70,%eax
f0103b5e:	2b 08                	sub    (%eax),%ecx
f0103b60:	89 c8                	mov    %ecx,%eax
f0103b62:	c1 f8 03             	sar    $0x3,%eax
f0103b65:	89 c7                	mov    %eax,%edi
f0103b67:	c1 e7 0c             	shl    $0xc,%edi
	if (PGNUM(pa) >= npages)
f0103b6a:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0103b6f:	c7 c2 78 2b 18 f0    	mov    $0xf0182b78,%edx
f0103b75:	3b 02                	cmp    (%edx),%eax
f0103b77:	0f 83 ae 01 00 00    	jae    f0103d2b <env_alloc+0x20f>
	return (void *)(pa + KERNBASE);
f0103b7d:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	cprintf("user pgdir: 0x%x\n",(u32)dir);
f0103b83:	83 ec 08             	sub    $0x8,%esp
f0103b86:	57                   	push   %edi
f0103b87:	8d 83 92 62 f8 ff    	lea    -0x79d6e(%ebx),%eax
f0103b8d:	50                   	push   %eax
f0103b8e:	e8 85 07 00 00       	call   f0104318 <cprintf>
	p->pp_ref++;
f0103b93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b96:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	e->env_pgdir = dir;
f0103b9b:	89 7e 5c             	mov    %edi,0x5c(%esi)
	e->env_pgdir[PDX(UENVS)] = kern_pgdir[PDX(UENVS)] | PTE_U;
f0103b9e:	c7 c0 74 2b 18 f0    	mov    $0xf0182b74,%eax
f0103ba4:	8b 08                	mov    (%eax),%ecx
f0103ba6:	8b 81 ec 0e 00 00    	mov    0xeec(%ecx),%eax
f0103bac:	83 c8 04             	or     $0x4,%eax
f0103baf:	89 87 ec 0e 00 00    	mov    %eax,0xeec(%edi)
	e->env_pgdir[PDX(UPAGES)] = kern_pgdir[PDX(UPAGES)] | PTE_U;
f0103bb5:	8b 56 5c             	mov    0x5c(%esi),%edx
f0103bb8:	8b 81 f0 0e 00 00    	mov    0xef0(%ecx),%eax
f0103bbe:	83 c8 04             	or     $0x4,%eax
f0103bc1:	89 82 f0 0e 00 00    	mov    %eax,0xef0(%edx)
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103bc7:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103bca:	83 c4 10             	add    $0x10,%esp
f0103bcd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bd2:	0f 86 69 01 00 00    	jbe    f0103d41 <env_alloc+0x225>
	return (physaddr_t)kva - KERNBASE;
f0103bd8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103bde:	83 ca 05             	or     $0x5,%edx
f0103be1:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	boot_map_region(dir, 0xf0000000, 0x400000, 0x0, PTE_P | PTE_W);
f0103be7:	83 ec 0c             	sub    $0xc,%esp
f0103bea:	6a 03                	push   $0x3
f0103bec:	6a 00                	push   $0x0
f0103bee:	68 00 00 40 00       	push   $0x400000
f0103bf3:	68 00 00 00 f0       	push   $0xf0000000
f0103bf8:	57                   	push   %edi
f0103bf9:	e8 74 dc ff ff       	call   f0101872 <boot_map_region>
	cprintf("env setup vm done\n");
f0103bfe:	83 c4 14             	add    $0x14,%esp
f0103c01:	8d 83 af 62 f8 ff    	lea    -0x79d51(%ebx),%eax
f0103c07:	50                   	push   %eax
f0103c08:	e8 0b 07 00 00       	call   f0104318 <cprintf>
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103c0d:	8b 46 48             	mov    0x48(%esi),%eax
f0103c10:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
		generation = 1 << ENVGENSHIFT;
f0103c15:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103c1a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103c1f:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103c22:	89 f2                	mov    %esi,%edx
f0103c24:	2b 93 20 23 00 00    	sub    0x2320(%ebx),%edx
f0103c2a:	c1 fa 05             	sar    $0x5,%edx
f0103c2d:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103c33:	09 d0                	or     %edx,%eax
f0103c35:	89 46 48             	mov    %eax,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103c38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c3b:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0103c3e:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103c45:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0103c4c:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	cprintf("####memset\n");
f0103c53:	8d 83 c2 62 f8 ff    	lea    -0x79d3e(%ebx),%eax
f0103c59:	89 04 24             	mov    %eax,(%esp)
f0103c5c:	e8 b7 06 00 00       	call   f0104318 <cprintf>
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103c61:	83 c4 0c             	add    $0xc,%esp
f0103c64:	6a 44                	push   $0x44
f0103c66:	6a 00                	push   $0x0
f0103c68:	56                   	push   %esi
f0103c69:	e8 a7 16 00 00       	call   f0105315 <memset>
	cprintf("####memset done\n");
f0103c6e:	8d 83 ce 62 f8 ff    	lea    -0x79d32(%ebx),%eax
f0103c74:	89 04 24             	mov    %eax,(%esp)
f0103c77:	e8 9c 06 00 00       	call   f0104318 <cprintf>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103c7c:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f0103c82:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f0103c88:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0103c8e:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0103c95:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	cprintf("####1\n");
f0103c9b:	8d 83 df 62 f8 ff    	lea    -0x79d21(%ebx),%eax
f0103ca1:	89 04 24             	mov    %eax,(%esp)
f0103ca4:	e8 6f 06 00 00       	call   f0104318 <cprintf>
	env_free_list = e->env_link;
f0103ca9:	8b 46 44             	mov    0x44(%esi),%eax
f0103cac:	89 83 24 23 00 00    	mov    %eax,0x2324(%ebx)
	cprintf("e_addr 0x%x, env free 0x%x\n", (u32)e, (u32)env_free_list);
f0103cb2:	83 c4 0c             	add    $0xc,%esp
f0103cb5:	50                   	push   %eax
f0103cb6:	56                   	push   %esi
f0103cb7:	8d 83 e6 62 f8 ff    	lea    -0x79d1a(%ebx),%eax
f0103cbd:	50                   	push   %eax
f0103cbe:	e8 55 06 00 00       	call   f0104318 <cprintf>
	cprintf("####2\n");
f0103cc3:	8d 83 02 63 f8 ff    	lea    -0x79cfe(%ebx),%eax
f0103cc9:	89 04 24             	mov    %eax,(%esp)
f0103ccc:	e8 47 06 00 00       	call   f0104318 <cprintf>

	*newenv_store = e;
f0103cd1:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cd4:	89 30                	mov    %esi,(%eax)
	cprintf("####3\n");
f0103cd6:	8d 83 09 63 f8 ff    	lea    -0x79cf7(%ebx),%eax
f0103cdc:	89 04 24             	mov    %eax,(%esp)
f0103cdf:	e8 34 06 00 00       	call   f0104318 <cprintf>

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103ce4:	8b 4e 48             	mov    0x48(%esi),%ecx
f0103ce7:	8b 83 1c 23 00 00    	mov    0x231c(%ebx),%eax
f0103ced:	83 c4 10             	add    $0x10,%esp
f0103cf0:	ba 00 00 00 00       	mov    $0x0,%edx
f0103cf5:	85 c0                	test   %eax,%eax
f0103cf7:	74 03                	je     f0103cfc <env_alloc+0x1e0>
f0103cf9:	8b 50 48             	mov    0x48(%eax),%edx
f0103cfc:	83 ec 04             	sub    $0x4,%esp
f0103cff:	51                   	push   %ecx
f0103d00:	52                   	push   %edx
f0103d01:	8d 83 10 63 f8 ff    	lea    -0x79cf0(%ebx),%eax
f0103d07:	50                   	push   %eax
f0103d08:	e8 0b 06 00 00       	call   f0104318 <cprintf>
	cprintf("####4\n");
f0103d0d:	8d 83 25 63 f8 ff    	lea    -0x79cdb(%ebx),%eax
f0103d13:	89 04 24             	mov    %eax,(%esp)
f0103d16:	e8 fd 05 00 00       	call   f0104318 <cprintf>
	
	return 0;
f0103d1b:	83 c4 10             	add    $0x10,%esp
f0103d1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d23:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d26:	5b                   	pop    %ebx
f0103d27:	5e                   	pop    %esi
f0103d28:	5f                   	pop    %edi
f0103d29:	5d                   	pop    %ebp
f0103d2a:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103d2b:	57                   	push   %edi
f0103d2c:	8d 83 a0 59 f8 ff    	lea    -0x7a660(%ebx),%eax
f0103d32:	50                   	push   %eax
f0103d33:	6a 5c                	push   $0x5c
f0103d35:	8d 83 35 56 f8 ff    	lea    -0x7a9cb(%ebx),%eax
f0103d3b:	50                   	push   %eax
f0103d3c:	e8 9a c3 ff ff       	call   f01000db <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d41:	50                   	push   %eax
f0103d42:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f0103d48:	50                   	push   %eax
f0103d49:	68 ca 00 00 00       	push   $0xca
f0103d4e:	8d 83 a4 62 f8 ff    	lea    -0x79d5c(%ebx),%eax
f0103d54:	50                   	push   %eax
f0103d55:	e8 81 c3 ff ff       	call   f01000db <_panic>
		return -E_NO_FREE_ENV;
f0103d5a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103d5f:	eb c2                	jmp    f0103d23 <env_alloc+0x207>
		return -E_NO_MEM;
f0103d61:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103d66:	eb bb                	jmp    f0103d23 <env_alloc+0x207>

f0103d68 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103d68:	55                   	push   %ebp
f0103d69:	89 e5                	mov    %esp,%ebp
f0103d6b:	57                   	push   %edi
f0103d6c:	56                   	push   %esi
f0103d6d:	53                   	push   %ebx
f0103d6e:	83 ec 44             	sub    $0x44,%esp
f0103d71:	e8 1b c4 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0103d76:	81 c3 f2 ca 07 00    	add    $0x7caf2,%ebx
	// LAB 3: Your code here.
	struct Env *new = NULL;
f0103d7c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int ret = env_alloc(&new, 0);
f0103d83:	6a 00                	push   $0x0
f0103d85:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103d88:	50                   	push   %eax
f0103d89:	e8 8e fd ff ff       	call   f0103b1c <env_alloc>
	cprintf("env alloc done. new_env: 0x%x\n", (u32)new);
f0103d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d91:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103d94:	83 c4 08             	add    $0x8,%esp
f0103d97:	50                   	push   %eax
f0103d98:	8d 83 b8 61 f8 ff    	lea    -0x79e48(%ebx),%eax
f0103d9e:	50                   	push   %eax
f0103d9f:	e8 74 05 00 00       	call   f0104318 <cprintf>
	cprintf("entry 0x%x, phoff 0x%x, phnum 0x%x\n", 
f0103da4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103da7:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0103dab:	50                   	push   %eax
f0103dac:	8b 45 08             	mov    0x8(%ebp),%eax
f0103daf:	ff 70 1c             	push   0x1c(%eax)
f0103db2:	ff 70 18             	push   0x18(%eax)
f0103db5:	8d 83 d8 61 f8 ff    	lea    -0x79e28(%ebx),%eax
f0103dbb:	50                   	push   %eax
f0103dbc:	e8 57 05 00 00       	call   f0104318 <cprintf>
	temp = (struct Proghdr *)((uint8_t*)elf_ptr + elf_ptr->e_phoff);
f0103dc1:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dc4:	89 c6                	mov    %eax,%esi
f0103dc6:	03 70 1c             	add    0x1c(%eax),%esi
	end = temp+elf_ptr->e_phnum;
f0103dc9:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0103dcd:	c1 e0 05             	shl    $0x5,%eax
f0103dd0:	01 f0                	add    %esi,%eax
f0103dd2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (;temp<end;temp++)
f0103dd5:	83 c4 20             	add    $0x20,%esp
			page_insert(kern_pgdir, p, (u32*)(temp->p_va + PGSIZE*i), PTE_W);
f0103dd8:	c7 c0 74 2b 18 f0    	mov    $0xf0182b74,%eax
f0103dde:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (;temp<end;temp++)
f0103de1:	eb 15                	jmp    f0103df8 <env_create+0x90>
			cprintf("non load segment\n");
f0103de3:	83 ec 0c             	sub    $0xc,%esp
f0103de6:	8d 83 2c 63 f8 ff    	lea    -0x79cd4(%ebx),%eax
f0103dec:	50                   	push   %eax
f0103ded:	e8 26 05 00 00       	call   f0104318 <cprintf>
			continue;
f0103df2:	83 c4 10             	add    $0x10,%esp
	for (;temp<end;temp++)
f0103df5:	83 c6 20             	add    $0x20,%esi
f0103df8:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0103dfb:	0f 86 02 01 00 00    	jbe    f0103f03 <env_create+0x19b>
		cprintf("p_type 0x%x, p_offset 0x%x, p_va 0x%x, p_filesz 0x%x\np_memsz 0x%x, p_flags 0x%x, p_align 0x%x\n",
f0103e01:	ff 76 1c             	push   0x1c(%esi)
f0103e04:	ff 76 18             	push   0x18(%esi)
f0103e07:	ff 76 14             	push   0x14(%esi)
f0103e0a:	ff 76 10             	push   0x10(%esi)
f0103e0d:	ff 76 08             	push   0x8(%esi)
f0103e10:	ff 76 04             	push   0x4(%esi)
f0103e13:	ff 36                	push   (%esi)
f0103e15:	8d 83 fc 61 f8 ff    	lea    -0x79e04(%ebx),%eax
f0103e1b:	50                   	push   %eax
f0103e1c:	e8 f7 04 00 00       	call   f0104318 <cprintf>
		if (temp->p_type != ELF_PROG_LOAD)
f0103e21:	83 c4 20             	add    $0x20,%esp
f0103e24:	83 3e 01             	cmpl   $0x1,(%esi)
f0103e27:	75 ba                	jne    f0103de3 <env_create+0x7b>
		cprintf("p_va 0x%x\n", temp->p_va);
f0103e29:	83 ec 08             	sub    $0x8,%esp
f0103e2c:	ff 76 08             	push   0x8(%esi)
f0103e2f:	8d 83 3e 63 f8 ff    	lea    -0x79cc2(%ebx),%eax
f0103e35:	50                   	push   %eax
f0103e36:	e8 dd 04 00 00       	call   f0104318 <cprintf>
		u32 pg_num = ROUNDUP(temp->p_memsz, PGSIZE)/PGSIZE;
f0103e3b:	8b 46 14             	mov    0x14(%esi),%eax
f0103e3e:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103e43:	c1 e8 0c             	shr    $0xc,%eax
f0103e46:	89 c7                	mov    %eax,%edi
		cprintf("needed page number 0x%x\n", pg_num);
f0103e48:	83 c4 08             	add    $0x8,%esp
f0103e4b:	50                   	push   %eax
f0103e4c:	8d 83 49 63 f8 ff    	lea    -0x79cb7(%ebx),%eax
f0103e52:	50                   	push   %eax
f0103e53:	e8 c0 04 00 00       	call   f0104318 <cprintf>
f0103e58:	c1 e7 0c             	shl    $0xc,%edi
f0103e5b:	89 7d d0             	mov    %edi,-0x30(%ebp)
		for (u32 i = 0; i<pg_num;i++)
f0103e5e:	83 c4 10             	add    $0x10,%esp
f0103e61:	bf 00 00 00 00       	mov    $0x0,%edi
f0103e66:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0103e69:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0103e6c:	74 66                	je     f0103ed4 <env_create+0x16c>
			struct PageInfo *p = page_alloc(ALLOC_ZERO);
f0103e6e:	83 ec 0c             	sub    $0xc,%esp
f0103e71:	6a 01                	push   $0x1
f0103e73:	e8 c6 d7 ff ff       	call   f010163e <page_alloc>
f0103e78:	89 c6                	mov    %eax,%esi
			if (!p)
f0103e7a:	83 c4 10             	add    $0x10,%esp
f0103e7d:	85 c0                	test   %eax,%eax
f0103e7f:	74 38                	je     f0103eb9 <env_create+0x151>
			page_insert(kern_pgdir, p, (u32*)(temp->p_va + PGSIZE*i), PTE_W);
f0103e81:	6a 02                	push   $0x2
f0103e83:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103e86:	89 f8                	mov    %edi,%eax
f0103e88:	03 42 08             	add    0x8(%edx),%eax
f0103e8b:	50                   	push   %eax
f0103e8c:	56                   	push   %esi
f0103e8d:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103e90:	ff 30                	push   (%eax)
f0103e92:	e8 55 db ff ff       	call   f01019ec <page_insert>
			page_insert(e->env_pgdir, p, (u32*)(temp->p_va + PGSIZE*i), PTE_W | PTE_U);
f0103e97:	6a 06                	push   $0x6
f0103e99:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103e9c:	89 f8                	mov    %edi,%eax
f0103e9e:	03 42 08             	add    0x8(%edx),%eax
f0103ea1:	50                   	push   %eax
f0103ea2:	56                   	push   %esi
f0103ea3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103ea6:	ff 70 5c             	push   0x5c(%eax)
f0103ea9:	e8 3e db ff ff       	call   f01019ec <page_insert>
f0103eae:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0103eb4:	83 c4 20             	add    $0x20,%esp
f0103eb7:	eb b0                	jmp    f0103e69 <env_create+0x101>
				panic("program page alloc fail");
f0103eb9:	83 ec 04             	sub    $0x4,%esp
f0103ebc:	8d 83 62 63 f8 ff    	lea    -0x79c9e(%ebx),%eax
f0103ec2:	50                   	push   %eax
f0103ec3:	68 8d 01 00 00       	push   $0x18d
f0103ec8:	8d 83 a4 62 f8 ff    	lea    -0x79d5c(%ebx),%eax
f0103ece:	50                   	push   %eax
f0103ecf:	e8 07 c2 ff ff       	call   f01000db <_panic>
		cprintf("finish\n");
f0103ed4:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103ed7:	83 ec 0c             	sub    $0xc,%esp
f0103eda:	8d 83 2d 56 f8 ff    	lea    -0x7a9d3(%ebx),%eax
f0103ee0:	50                   	push   %eax
f0103ee1:	e8 32 04 00 00       	call   f0104318 <cprintf>
		memcpy((uint8_t*)temp->p_va, (uint8_t*)elf_ptr + temp->p_offset, temp->p_memsz);
f0103ee6:	83 c4 0c             	add    $0xc,%esp
f0103ee9:	ff 76 14             	push   0x14(%esi)
f0103eec:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eef:	03 46 04             	add    0x4(%esi),%eax
f0103ef2:	50                   	push   %eax
f0103ef3:	ff 76 08             	push   0x8(%esi)
f0103ef6:	e8 c2 14 00 00       	call   f01053bd <memcpy>
f0103efb:	83 c4 10             	add    $0x10,%esp
f0103efe:	e9 f2 fe ff ff       	jmp    f0103df5 <env_create+0x8d>
	cprintf("alloc stack\n");
f0103f03:	83 ec 0c             	sub    $0xc,%esp
f0103f06:	8d 83 7a 63 f8 ff    	lea    -0x79c86(%ebx),%eax
f0103f0c:	50                   	push   %eax
f0103f0d:	e8 06 04 00 00       	call   f0104318 <cprintf>
	struct PageInfo *p_stk = page_alloc(ALLOC_ZERO);
f0103f12:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103f19:	e8 20 d7 ff ff       	call   f010163e <page_alloc>
	if (!p_stk)
f0103f1e:	83 c4 10             	add    $0x10,%esp
f0103f21:	85 c0                	test   %eax,%eax
f0103f23:	74 50                	je     f0103f75 <env_create+0x20d>
	page_insert(e->env_pgdir, p_stk, (u32*)(USTACKTOP-PGSIZE), PTE_W | PTE_U);
f0103f25:	6a 06                	push   $0x6
f0103f27:	68 00 d0 bf ee       	push   $0xeebfd000
f0103f2c:	50                   	push   %eax
f0103f2d:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103f30:	ff 77 5c             	push   0x5c(%edi)
f0103f33:	e8 b4 da ff ff       	call   f01019ec <page_insert>
	e->env_tf.tf_esp = USTACKTOP-16;
f0103f38:	c7 47 3c f0 df bf ee 	movl   $0xeebfdff0,0x3c(%edi)
	cprintf("alloc stack done\n");
f0103f3f:	8d 83 9d 63 f8 ff    	lea    -0x79c63(%ebx),%eax
f0103f45:	89 04 24             	mov    %eax,(%esp)
f0103f48:	e8 cb 03 00 00       	call   f0104318 <cprintf>
	e->env_tf.tf_eip = elf_ptr->e_entry; 
f0103f4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f50:	8b 40 18             	mov    0x18(%eax),%eax
f0103f53:	89 47 30             	mov    %eax,0x30(%edi)
	load_icode(new, binary);
	cprintf("load icode done\n");
f0103f56:	8d 83 af 63 f8 ff    	lea    -0x79c51(%ebx),%eax
f0103f5c:	89 04 24             	mov    %eax,(%esp)
f0103f5f:	e8 b4 03 00 00       	call   f0104318 <cprintf>

	(new)->env_type = type;
f0103f64:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f67:	89 47 50             	mov    %eax,0x50(%edi)
}
f0103f6a:	83 c4 10             	add    $0x10,%esp
f0103f6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f70:	5b                   	pop    %ebx
f0103f71:	5e                   	pop    %esi
f0103f72:	5f                   	pop    %edi
f0103f73:	5d                   	pop    %ebp
f0103f74:	c3                   	ret    
		panic("stack page alloc fail");
f0103f75:	83 ec 04             	sub    $0x4,%esp
f0103f78:	8d 83 87 63 f8 ff    	lea    -0x79c79(%ebx),%eax
f0103f7e:	50                   	push   %eax
f0103f7f:	68 9c 01 00 00       	push   $0x19c
f0103f84:	8d 83 a4 62 f8 ff    	lea    -0x79d5c(%ebx),%eax
f0103f8a:	50                   	push   %eax
f0103f8b:	e8 4b c1 ff ff       	call   f01000db <_panic>

f0103f90 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103f90:	55                   	push   %ebp
f0103f91:	89 e5                	mov    %esp,%ebp
f0103f93:	57                   	push   %edi
f0103f94:	56                   	push   %esi
f0103f95:	53                   	push   %ebx
f0103f96:	83 ec 2c             	sub    $0x2c,%esp
f0103f99:	e8 f3 c1 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0103f9e:	81 c3 ca c8 07 00    	add    $0x7c8ca,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103fa4:	8b 93 1c 23 00 00    	mov    0x231c(%ebx),%edx
f0103faa:	3b 55 08             	cmp    0x8(%ebp),%edx
f0103fad:	74 47                	je     f0103ff6 <env_free+0x66>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103faf:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fb2:	8b 48 48             	mov    0x48(%eax),%ecx
f0103fb5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fba:	85 d2                	test   %edx,%edx
f0103fbc:	74 03                	je     f0103fc1 <env_free+0x31>
f0103fbe:	8b 42 48             	mov    0x48(%edx),%eax
f0103fc1:	83 ec 04             	sub    $0x4,%esp
f0103fc4:	51                   	push   %ecx
f0103fc5:	50                   	push   %eax
f0103fc6:	8d 83 c0 63 f8 ff    	lea    -0x79c40(%ebx),%eax
f0103fcc:	50                   	push   %eax
f0103fcd:	e8 46 03 00 00       	call   f0104318 <cprintf>
f0103fd2:	83 c4 10             	add    $0x10,%esp
f0103fd5:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	if (PGNUM(pa) >= npages)
f0103fdc:	c7 c0 78 2b 18 f0    	mov    $0xf0182b78,%eax
f0103fe2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if (PGNUM(pa) >= npages)
f0103fe5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return &pages[PGNUM(pa)];
f0103fe8:	c7 c0 70 2b 18 f0    	mov    $0xf0182b70,%eax
f0103fee:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103ff1:	e9 bf 00 00 00       	jmp    f01040b5 <env_free+0x125>
		lcr3(PADDR(kern_pgdir));
f0103ff6:	c7 c0 74 2b 18 f0    	mov    $0xf0182b74,%eax
f0103ffc:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103ffe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104003:	76 10                	jbe    f0104015 <env_free+0x85>
	return (physaddr_t)kva - KERNBASE;
f0104005:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010400a:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010400d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104010:	8b 48 48             	mov    0x48(%eax),%ecx
f0104013:	eb a9                	jmp    f0103fbe <env_free+0x2e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104015:	50                   	push   %eax
f0104016:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f010401c:	50                   	push   %eax
f010401d:	68 c5 01 00 00       	push   $0x1c5
f0104022:	8d 83 a4 62 f8 ff    	lea    -0x79d5c(%ebx),%eax
f0104028:	50                   	push   %eax
f0104029:	e8 ad c0 ff ff       	call   f01000db <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010402e:	57                   	push   %edi
f010402f:	8d 83 a0 59 f8 ff    	lea    -0x7a660(%ebx),%eax
f0104035:	50                   	push   %eax
f0104036:	68 d4 01 00 00       	push   $0x1d4
f010403b:	8d 83 a4 62 f8 ff    	lea    -0x79d5c(%ebx),%eax
f0104041:	50                   	push   %eax
f0104042:	e8 94 c0 ff ff       	call   f01000db <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0104047:	83 c7 04             	add    $0x4,%edi
f010404a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0104050:	81 fe 00 00 40 00    	cmp    $0x400000,%esi
f0104056:	74 1e                	je     f0104076 <env_free+0xe6>
			if (pt[pteno] & PTE_P)
f0104058:	f6 07 01             	testb  $0x1,(%edi)
f010405b:	74 ea                	je     f0104047 <env_free+0xb7>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010405d:	83 ec 08             	sub    $0x8,%esp
f0104060:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104063:	09 f0                	or     %esi,%eax
f0104065:	50                   	push   %eax
f0104066:	8b 45 08             	mov    0x8(%ebp),%eax
f0104069:	ff 70 5c             	push   0x5c(%eax)
f010406c:	e8 35 d9 ff ff       	call   f01019a6 <page_remove>
f0104071:	83 c4 10             	add    $0x10,%esp
f0104074:	eb d1                	jmp    f0104047 <env_free+0xb7>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0104076:	8b 45 08             	mov    0x8(%ebp),%eax
f0104079:	8b 40 5c             	mov    0x5c(%eax),%eax
f010407c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010407f:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0104086:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104089:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010408c:	3b 10                	cmp    (%eax),%edx
f010408e:	73 67                	jae    f01040f7 <env_free+0x167>
		page_decref(pa2page(pa));
f0104090:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0104093:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104096:	8b 00                	mov    (%eax),%eax
f0104098:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010409b:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010409e:	50                   	push   %eax
f010409f:	e8 88 d6 ff ff       	call   f010172c <page_decref>
f01040a4:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01040a7:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01040ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01040ae:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01040b3:	74 5a                	je     f010410f <env_free+0x17f>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01040b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01040b8:	8b 40 5c             	mov    0x5c(%eax),%eax
f01040bb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01040be:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f01040c1:	a8 01                	test   $0x1,%al
f01040c3:	74 e2                	je     f01040a7 <env_free+0x117>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01040c5:	89 c7                	mov    %eax,%edi
f01040c7:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f01040cd:	c1 e8 0c             	shr    $0xc,%eax
f01040d0:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01040d3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01040d6:	3b 02                	cmp    (%edx),%eax
f01040d8:	0f 83 50 ff ff ff    	jae    f010402e <env_free+0x9e>
	return (void *)(pa + KERNBASE);
f01040de:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f01040e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01040e7:	c1 e0 14             	shl    $0x14,%eax
f01040ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01040ed:	be 00 00 00 00       	mov    $0x0,%esi
f01040f2:	e9 61 ff ff ff       	jmp    f0104058 <env_free+0xc8>
		panic("pa2page called with invalid pa");
f01040f7:	83 ec 04             	sub    $0x4,%esp
f01040fa:	8d 83 f4 5a f8 ff    	lea    -0x7a50c(%ebx),%eax
f0104100:	50                   	push   %eax
f0104101:	6a 55                	push   $0x55
f0104103:	8d 83 35 56 f8 ff    	lea    -0x7a9cb(%ebx),%eax
f0104109:	50                   	push   %eax
f010410a:	e8 cc bf ff ff       	call   f01000db <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010410f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104112:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0104115:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010411a:	76 57                	jbe    f0104173 <env_free+0x1e3>
	e->env_pgdir = 0;
f010411c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010411f:	c7 41 5c 00 00 00 00 	movl   $0x0,0x5c(%ecx)
	return (physaddr_t)kva - KERNBASE;
f0104126:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f010412b:	c1 e8 0c             	shr    $0xc,%eax
f010412e:	c7 c2 78 2b 18 f0    	mov    $0xf0182b78,%edx
f0104134:	3b 02                	cmp    (%edx),%eax
f0104136:	73 54                	jae    f010418c <env_free+0x1fc>
	page_decref(pa2page(pa));
f0104138:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010413b:	c7 c2 70 2b 18 f0    	mov    $0xf0182b70,%edx
f0104141:	8b 12                	mov    (%edx),%edx
f0104143:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0104146:	50                   	push   %eax
f0104147:	e8 e0 d5 ff ff       	call   f010172c <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010414c:	8b 45 08             	mov    0x8(%ebp),%eax
f010414f:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0104156:	8b 83 24 23 00 00    	mov    0x2324(%ebx),%eax
f010415c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010415f:	89 41 44             	mov    %eax,0x44(%ecx)
	env_free_list = e;
f0104162:	89 8b 24 23 00 00    	mov    %ecx,0x2324(%ebx)
}
f0104168:	83 c4 10             	add    $0x10,%esp
f010416b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010416e:	5b                   	pop    %ebx
f010416f:	5e                   	pop    %esi
f0104170:	5f                   	pop    %edi
f0104171:	5d                   	pop    %ebp
f0104172:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104173:	50                   	push   %eax
f0104174:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f010417a:	50                   	push   %eax
f010417b:	68 e2 01 00 00       	push   $0x1e2
f0104180:	8d 83 a4 62 f8 ff    	lea    -0x79d5c(%ebx),%eax
f0104186:	50                   	push   %eax
f0104187:	e8 4f bf ff ff       	call   f01000db <_panic>
		panic("pa2page called with invalid pa");
f010418c:	83 ec 04             	sub    $0x4,%esp
f010418f:	8d 83 f4 5a f8 ff    	lea    -0x7a50c(%ebx),%eax
f0104195:	50                   	push   %eax
f0104196:	6a 55                	push   $0x55
f0104198:	8d 83 35 56 f8 ff    	lea    -0x7a9cb(%ebx),%eax
f010419e:	50                   	push   %eax
f010419f:	e8 37 bf ff ff       	call   f01000db <_panic>

f01041a4 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01041a4:	55                   	push   %ebp
f01041a5:	89 e5                	mov    %esp,%ebp
f01041a7:	53                   	push   %ebx
f01041a8:	83 ec 10             	sub    $0x10,%esp
f01041ab:	e8 e1 bf ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01041b0:	81 c3 b8 c6 07 00    	add    $0x7c6b8,%ebx
	env_free(e);
f01041b6:	ff 75 08             	push   0x8(%ebp)
f01041b9:	e8 d2 fd ff ff       	call   f0103f90 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01041be:	8d 83 5c 62 f8 ff    	lea    -0x79da4(%ebx),%eax
f01041c4:	89 04 24             	mov    %eax,(%esp)
f01041c7:	e8 4c 01 00 00       	call   f0104318 <cprintf>
f01041cc:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01041cf:	83 ec 0c             	sub    $0xc,%esp
f01041d2:	6a 00                	push   $0x0
f01041d4:	e8 8d cd ff ff       	call   f0100f66 <monitor>
f01041d9:	83 c4 10             	add    $0x10,%esp
f01041dc:	eb f1                	jmp    f01041cf <env_destroy+0x2b>

f01041de <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01041de:	55                   	push   %ebp
f01041df:	89 e5                	mov    %esp,%ebp
f01041e1:	53                   	push   %ebx
f01041e2:	83 ec 08             	sub    $0x8,%esp
f01041e5:	e8 a7 bf ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01041ea:	81 c3 7e c6 07 00    	add    $0x7c67e,%ebx
	asm volatile(
f01041f0:	8b 65 08             	mov    0x8(%ebp),%esp
f01041f3:	61                   	popa   
f01041f4:	07                   	pop    %es
f01041f5:	1f                   	pop    %ds
f01041f6:	83 c4 08             	add    $0x8,%esp
f01041f9:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01041fa:	8d 83 d6 63 f8 ff    	lea    -0x79c2a(%ebx),%eax
f0104200:	50                   	push   %eax
f0104201:	68 0b 02 00 00       	push   $0x20b
f0104206:	8d 83 a4 62 f8 ff    	lea    -0x79d5c(%ebx),%eax
f010420c:	50                   	push   %eax
f010420d:	e8 c9 be ff ff       	call   f01000db <_panic>

f0104212 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104212:	55                   	push   %ebp
f0104213:	89 e5                	mov    %esp,%ebp
f0104215:	56                   	push   %esi
f0104216:	53                   	push   %ebx
f0104217:	e8 75 bf ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f010421c:	81 c3 4c c6 07 00    	add    $0x7c64c,%ebx
f0104222:	8b 75 08             	mov    0x8(%ebp),%esi
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv)
f0104225:	8b 83 1c 23 00 00    	mov    0x231c(%ebx),%eax
f010422b:	85 c0                	test   %eax,%eax
f010422d:	74 06                	je     f0104235 <env_run+0x23>
	{
		if (curenv->env_status == ENV_RUNNING)
f010422f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104233:	74 3a                	je     f010426f <env_run+0x5d>
			curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
f0104235:	89 b3 1c 23 00 00    	mov    %esi,0x231c(%ebx)
	e->env_status = ENV_RUNNING;	
f010423b:	c7 46 54 03 00 00 00 	movl   $0x3,0x54(%esi)
	e->env_runs++;
f0104242:	83 46 58 01          	addl   $0x1,0x58(%esi)
	lcr3(PADDR(e->env_pgdir));
f0104246:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0104249:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010424e:	76 28                	jbe    f0104278 <env_run+0x66>
	return (physaddr_t)kva - KERNBASE;
f0104250:	05 00 00 00 10       	add    $0x10000000,%eax
f0104255:	0f 22 d8             	mov    %eax,%cr3
	cprintf("gogogo\n");
f0104258:	83 ec 0c             	sub    $0xc,%esp
f010425b:	8d 83 66 59 f8 ff    	lea    -0x7a69a(%ebx),%eax
f0104261:	50                   	push   %eax
f0104262:	e8 b1 00 00 00       	call   f0104318 <cprintf>
	env_pop_tf(&e->env_tf);
f0104267:	89 34 24             	mov    %esi,(%esp)
f010426a:	e8 6f ff ff ff       	call   f01041de <env_pop_tf>
			curenv->env_status = ENV_RUNNABLE;
f010426f:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0104276:	eb bd                	jmp    f0104235 <env_run+0x23>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104278:	50                   	push   %eax
f0104279:	8d 83 70 5b f8 ff    	lea    -0x7a490(%ebx),%eax
f010427f:	50                   	push   %eax
f0104280:	68 31 02 00 00       	push   $0x231
f0104285:	8d 83 a4 62 f8 ff    	lea    -0x79d5c(%ebx),%eax
f010428b:	50                   	push   %eax
f010428c:	e8 4a be ff ff       	call   f01000db <_panic>

f0104291 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0104291:	55                   	push   %ebp
f0104292:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0104294:	8b 45 08             	mov    0x8(%ebp),%eax
f0104297:	ba 70 00 00 00       	mov    $0x70,%edx
f010429c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010429d:	ba 71 00 00 00       	mov    $0x71,%edx
f01042a2:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01042a3:	0f b6 c0             	movzbl %al,%eax
}
f01042a6:	5d                   	pop    %ebp
f01042a7:	c3                   	ret    

f01042a8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01042a8:	55                   	push   %ebp
f01042a9:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01042ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01042ae:	ba 70 00 00 00       	mov    $0x70,%edx
f01042b3:	ee                   	out    %al,(%dx)
f01042b4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042b7:	ba 71 00 00 00       	mov    $0x71,%edx
f01042bc:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01042bd:	5d                   	pop    %ebp
f01042be:	c3                   	ret    

f01042bf <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01042bf:	55                   	push   %ebp
f01042c0:	89 e5                	mov    %esp,%ebp
f01042c2:	53                   	push   %ebx
f01042c3:	83 ec 10             	sub    $0x10,%esp
f01042c6:	e8 c6 be ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01042cb:	81 c3 9d c5 07 00    	add    $0x7c59d,%ebx
	cputchar(ch);
f01042d1:	ff 75 08             	push   0x8(%ebp)
f01042d4:	e8 23 c4 ff ff       	call   f01006fc <cputchar>
	*cnt++;
}
f01042d9:	83 c4 10             	add    $0x10,%esp
f01042dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01042df:	c9                   	leave  
f01042e0:	c3                   	ret    

f01042e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01042e1:	55                   	push   %ebp
f01042e2:	89 e5                	mov    %esp,%ebp
f01042e4:	53                   	push   %ebx
f01042e5:	83 ec 14             	sub    $0x14,%esp
f01042e8:	e8 a4 be ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01042ed:	81 c3 7b c5 07 00    	add    $0x7c57b,%ebx
	int cnt = 0;
f01042f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01042fa:	ff 75 0c             	push   0xc(%ebp)
f01042fd:	ff 75 08             	push   0x8(%ebp)
f0104300:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104303:	50                   	push   %eax
f0104304:	8d 83 57 3a f8 ff    	lea    -0x7c5a9(%ebx),%eax
f010430a:	50                   	push   %eax
f010430b:	e8 90 08 00 00       	call   f0104ba0 <vprintfmt>
	return cnt;
}
f0104310:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104313:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104316:	c9                   	leave  
f0104317:	c3                   	ret    

f0104318 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0104318:	55                   	push   %ebp
f0104319:	89 e5                	mov    %esp,%ebp
f010431b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010431e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0104321:	50                   	push   %eax
f0104322:	ff 75 08             	push   0x8(%ebp)
f0104325:	e8 b7 ff ff ff       	call   f01042e1 <vcprintf>
	va_end(ap);

	return cnt;
}
f010432a:	c9                   	leave  
f010432b:	c3                   	ret    

f010432c <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010432c:	55                   	push   %ebp
f010432d:	89 e5                	mov    %esp,%ebp
f010432f:	57                   	push   %edi
f0104330:	56                   	push   %esi
f0104331:	53                   	push   %ebx
f0104332:	83 ec 04             	sub    $0x4,%esp
f0104335:	e8 57 be ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f010433a:	81 c3 2e c5 07 00    	add    $0x7c52e,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0104340:	c7 83 5c 2b 00 00 00 	movl   $0xf0000000,0x2b5c(%ebx)
f0104347:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010434a:	66 c7 83 60 2b 00 00 	movw   $0x10,0x2b60(%ebx)
f0104351:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0104353:	66 c7 83 be 2b 00 00 	movw   $0x68,0x2bbe(%ebx)
f010435a:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010435c:	c7 c0 00 d3 11 f0    	mov    $0xf011d300,%eax
f0104362:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f0104368:	8d b3 58 2b 00 00    	lea    0x2b58(%ebx),%esi
f010436e:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0104372:	89 f2                	mov    %esi,%edx
f0104374:	c1 ea 10             	shr    $0x10,%edx
f0104377:	88 50 2c             	mov    %dl,0x2c(%eax)
f010437a:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f010437e:	83 e2 f0             	and    $0xfffffff0,%edx
f0104381:	83 ca 09             	or     $0x9,%edx
f0104384:	83 e2 9f             	and    $0xffffff9f,%edx
f0104387:	83 ca 80             	or     $0xffffff80,%edx
f010438a:	88 55 f3             	mov    %dl,-0xd(%ebp)
f010438d:	88 50 2d             	mov    %dl,0x2d(%eax)
f0104390:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f0104394:	83 e1 c0             	and    $0xffffffc0,%ecx
f0104397:	83 c9 40             	or     $0x40,%ecx
f010439a:	83 e1 7f             	and    $0x7f,%ecx
f010439d:	88 48 2e             	mov    %cl,0x2e(%eax)
f01043a0:	c1 ee 18             	shr    $0x18,%esi
f01043a3:	89 f1                	mov    %esi,%ecx
f01043a5:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01043a8:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f01043ac:	83 e2 ef             	and    $0xffffffef,%edx
f01043af:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f01043b2:	b8 28 00 00 00       	mov    $0x28,%eax
f01043b7:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01043ba:	8d 83 a0 17 00 00    	lea    0x17a0(%ebx),%eax
f01043c0:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01043c3:	83 c4 04             	add    $0x4,%esp
f01043c6:	5b                   	pop    %ebx
f01043c7:	5e                   	pop    %esi
f01043c8:	5f                   	pop    %edi
f01043c9:	5d                   	pop    %ebp
f01043ca:	c3                   	ret    

f01043cb <trap_init>:
{
f01043cb:	55                   	push   %ebp
f01043cc:	89 e5                	mov    %esp,%ebp
	trap_init_percpu();
f01043ce:	e8 59 ff ff ff       	call   f010432c <trap_init_percpu>
}
f01043d3:	5d                   	pop    %ebp
f01043d4:	c3                   	ret    

f01043d5 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01043d5:	55                   	push   %ebp
f01043d6:	89 e5                	mov    %esp,%ebp
f01043d8:	56                   	push   %esi
f01043d9:	53                   	push   %ebx
f01043da:	e8 b2 bd ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01043df:	81 c3 89 c4 07 00    	add    $0x7c489,%ebx
f01043e5:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01043e8:	83 ec 08             	sub    $0x8,%esp
f01043eb:	ff 36                	push   (%esi)
f01043ed:	8d 83 e2 63 f8 ff    	lea    -0x79c1e(%ebx),%eax
f01043f3:	50                   	push   %eax
f01043f4:	e8 1f ff ff ff       	call   f0104318 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01043f9:	83 c4 08             	add    $0x8,%esp
f01043fc:	ff 76 04             	push   0x4(%esi)
f01043ff:	8d 83 f1 63 f8 ff    	lea    -0x79c0f(%ebx),%eax
f0104405:	50                   	push   %eax
f0104406:	e8 0d ff ff ff       	call   f0104318 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010440b:	83 c4 08             	add    $0x8,%esp
f010440e:	ff 76 08             	push   0x8(%esi)
f0104411:	8d 83 00 64 f8 ff    	lea    -0x79c00(%ebx),%eax
f0104417:	50                   	push   %eax
f0104418:	e8 fb fe ff ff       	call   f0104318 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010441d:	83 c4 08             	add    $0x8,%esp
f0104420:	ff 76 0c             	push   0xc(%esi)
f0104423:	8d 83 0f 64 f8 ff    	lea    -0x79bf1(%ebx),%eax
f0104429:	50                   	push   %eax
f010442a:	e8 e9 fe ff ff       	call   f0104318 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010442f:	83 c4 08             	add    $0x8,%esp
f0104432:	ff 76 10             	push   0x10(%esi)
f0104435:	8d 83 1e 64 f8 ff    	lea    -0x79be2(%ebx),%eax
f010443b:	50                   	push   %eax
f010443c:	e8 d7 fe ff ff       	call   f0104318 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104441:	83 c4 08             	add    $0x8,%esp
f0104444:	ff 76 14             	push   0x14(%esi)
f0104447:	8d 83 2d 64 f8 ff    	lea    -0x79bd3(%ebx),%eax
f010444d:	50                   	push   %eax
f010444e:	e8 c5 fe ff ff       	call   f0104318 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104453:	83 c4 08             	add    $0x8,%esp
f0104456:	ff 76 18             	push   0x18(%esi)
f0104459:	8d 83 3c 64 f8 ff    	lea    -0x79bc4(%ebx),%eax
f010445f:	50                   	push   %eax
f0104460:	e8 b3 fe ff ff       	call   f0104318 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104465:	83 c4 08             	add    $0x8,%esp
f0104468:	ff 76 1c             	push   0x1c(%esi)
f010446b:	8d 83 4b 64 f8 ff    	lea    -0x79bb5(%ebx),%eax
f0104471:	50                   	push   %eax
f0104472:	e8 a1 fe ff ff       	call   f0104318 <cprintf>
}
f0104477:	83 c4 10             	add    $0x10,%esp
f010447a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010447d:	5b                   	pop    %ebx
f010447e:	5e                   	pop    %esi
f010447f:	5d                   	pop    %ebp
f0104480:	c3                   	ret    

f0104481 <print_trapframe>:
{
f0104481:	55                   	push   %ebp
f0104482:	89 e5                	mov    %esp,%ebp
f0104484:	57                   	push   %edi
f0104485:	56                   	push   %esi
f0104486:	53                   	push   %ebx
f0104487:	83 ec 14             	sub    $0x14,%esp
f010448a:	e8 02 bd ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f010448f:	81 c3 d9 c3 07 00    	add    $0x7c3d9,%ebx
f0104495:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0104498:	56                   	push   %esi
f0104499:	8d 83 81 65 f8 ff    	lea    -0x79a7f(%ebx),%eax
f010449f:	50                   	push   %eax
f01044a0:	e8 73 fe ff ff       	call   f0104318 <cprintf>
	print_regs(&tf->tf_regs);
f01044a5:	89 34 24             	mov    %esi,(%esp)
f01044a8:	e8 28 ff ff ff       	call   f01043d5 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01044ad:	83 c4 08             	add    $0x8,%esp
f01044b0:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f01044b4:	50                   	push   %eax
f01044b5:	8d 83 9c 64 f8 ff    	lea    -0x79b64(%ebx),%eax
f01044bb:	50                   	push   %eax
f01044bc:	e8 57 fe ff ff       	call   f0104318 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01044c1:	83 c4 08             	add    $0x8,%esp
f01044c4:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f01044c8:	50                   	push   %eax
f01044c9:	8d 83 af 64 f8 ff    	lea    -0x79b51(%ebx),%eax
f01044cf:	50                   	push   %eax
f01044d0:	e8 43 fe ff ff       	call   f0104318 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044d5:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f01044d8:	83 c4 10             	add    $0x10,%esp
f01044db:	83 fa 13             	cmp    $0x13,%edx
f01044de:	0f 86 e2 00 00 00    	jbe    f01045c6 <print_trapframe+0x145>
		return "System call";
f01044e4:	83 fa 30             	cmp    $0x30,%edx
f01044e7:	8d 83 5a 64 f8 ff    	lea    -0x79ba6(%ebx),%eax
f01044ed:	8d 8b 69 64 f8 ff    	lea    -0x79b97(%ebx),%ecx
f01044f3:	0f 44 c1             	cmove  %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044f6:	83 ec 04             	sub    $0x4,%esp
f01044f9:	50                   	push   %eax
f01044fa:	52                   	push   %edx
f01044fb:	8d 83 c2 64 f8 ff    	lea    -0x79b3e(%ebx),%eax
f0104501:	50                   	push   %eax
f0104502:	e8 11 fe ff ff       	call   f0104318 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104507:	83 c4 10             	add    $0x10,%esp
f010450a:	39 b3 38 2b 00 00    	cmp    %esi,0x2b38(%ebx)
f0104510:	0f 84 bc 00 00 00    	je     f01045d2 <print_trapframe+0x151>
	cprintf("  err  0x%08x", tf->tf_err);
f0104516:	83 ec 08             	sub    $0x8,%esp
f0104519:	ff 76 2c             	push   0x2c(%esi)
f010451c:	8d 83 e3 64 f8 ff    	lea    -0x79b1d(%ebx),%eax
f0104522:	50                   	push   %eax
f0104523:	e8 f0 fd ff ff       	call   f0104318 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104528:	83 c4 10             	add    $0x10,%esp
f010452b:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f010452f:	0f 85 c2 00 00 00    	jne    f01045f7 <print_trapframe+0x176>
			tf->tf_err & 1 ? "protection" : "not-present");
f0104535:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f0104538:	a8 01                	test   $0x1,%al
f010453a:	8d 8b 75 64 f8 ff    	lea    -0x79b8b(%ebx),%ecx
f0104540:	8d 93 80 64 f8 ff    	lea    -0x79b80(%ebx),%edx
f0104546:	0f 44 ca             	cmove  %edx,%ecx
f0104549:	a8 02                	test   $0x2,%al
f010454b:	8d 93 8c 64 f8 ff    	lea    -0x79b74(%ebx),%edx
f0104551:	8d bb 92 64 f8 ff    	lea    -0x79b6e(%ebx),%edi
f0104557:	0f 44 d7             	cmove  %edi,%edx
f010455a:	a8 04                	test   $0x4,%al
f010455c:	8d 83 97 64 f8 ff    	lea    -0x79b69(%ebx),%eax
f0104562:	8d bb ac 65 f8 ff    	lea    -0x79a54(%ebx),%edi
f0104568:	0f 44 c7             	cmove  %edi,%eax
f010456b:	51                   	push   %ecx
f010456c:	52                   	push   %edx
f010456d:	50                   	push   %eax
f010456e:	8d 83 f1 64 f8 ff    	lea    -0x79b0f(%ebx),%eax
f0104574:	50                   	push   %eax
f0104575:	e8 9e fd ff ff       	call   f0104318 <cprintf>
f010457a:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010457d:	83 ec 08             	sub    $0x8,%esp
f0104580:	ff 76 30             	push   0x30(%esi)
f0104583:	8d 83 00 65 f8 ff    	lea    -0x79b00(%ebx),%eax
f0104589:	50                   	push   %eax
f010458a:	e8 89 fd ff ff       	call   f0104318 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010458f:	83 c4 08             	add    $0x8,%esp
f0104592:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104596:	50                   	push   %eax
f0104597:	8d 83 0f 65 f8 ff    	lea    -0x79af1(%ebx),%eax
f010459d:	50                   	push   %eax
f010459e:	e8 75 fd ff ff       	call   f0104318 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01045a3:	83 c4 08             	add    $0x8,%esp
f01045a6:	ff 76 38             	push   0x38(%esi)
f01045a9:	8d 83 22 65 f8 ff    	lea    -0x79ade(%ebx),%eax
f01045af:	50                   	push   %eax
f01045b0:	e8 63 fd ff ff       	call   f0104318 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01045b5:	83 c4 10             	add    $0x10,%esp
f01045b8:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f01045bc:	75 50                	jne    f010460e <print_trapframe+0x18d>
}
f01045be:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01045c1:	5b                   	pop    %ebx
f01045c2:	5e                   	pop    %esi
f01045c3:	5f                   	pop    %edi
f01045c4:	5d                   	pop    %ebp
f01045c5:	c3                   	ret    
		return excnames[trapno];
f01045c6:	8b 84 93 18 20 00 00 	mov    0x2018(%ebx,%edx,4),%eax
f01045cd:	e9 24 ff ff ff       	jmp    f01044f6 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01045d2:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01045d6:	0f 85 3a ff ff ff    	jne    f0104516 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01045dc:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01045df:	83 ec 08             	sub    $0x8,%esp
f01045e2:	50                   	push   %eax
f01045e3:	8d 83 d4 64 f8 ff    	lea    -0x79b2c(%ebx),%eax
f01045e9:	50                   	push   %eax
f01045ea:	e8 29 fd ff ff       	call   f0104318 <cprintf>
f01045ef:	83 c4 10             	add    $0x10,%esp
f01045f2:	e9 1f ff ff ff       	jmp    f0104516 <print_trapframe+0x95>
		cprintf("\n");
f01045f7:	83 ec 0c             	sub    $0xc,%esp
f01045fa:	8d 83 3a 4f f8 ff    	lea    -0x7b0c6(%ebx),%eax
f0104600:	50                   	push   %eax
f0104601:	e8 12 fd ff ff       	call   f0104318 <cprintf>
f0104606:	83 c4 10             	add    $0x10,%esp
f0104609:	e9 6f ff ff ff       	jmp    f010457d <print_trapframe+0xfc>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010460e:	83 ec 08             	sub    $0x8,%esp
f0104611:	ff 76 3c             	push   0x3c(%esi)
f0104614:	8d 83 31 65 f8 ff    	lea    -0x79acf(%ebx),%eax
f010461a:	50                   	push   %eax
f010461b:	e8 f8 fc ff ff       	call   f0104318 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104620:	83 c4 08             	add    $0x8,%esp
f0104623:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0104627:	50                   	push   %eax
f0104628:	8d 83 40 65 f8 ff    	lea    -0x79ac0(%ebx),%eax
f010462e:	50                   	push   %eax
f010462f:	e8 e4 fc ff ff       	call   f0104318 <cprintf>
f0104634:	83 c4 10             	add    $0x10,%esp
}
f0104637:	eb 85                	jmp    f01045be <print_trapframe+0x13d>

f0104639 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104639:	55                   	push   %ebp
f010463a:	89 e5                	mov    %esp,%ebp
f010463c:	57                   	push   %edi
f010463d:	56                   	push   %esi
f010463e:	53                   	push   %ebx
f010463f:	83 ec 0c             	sub    $0xc,%esp
f0104642:	e8 4a bb ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0104647:	81 c3 21 c2 07 00    	add    $0x7c221,%ebx
f010464d:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104650:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104651:	9c                   	pushf  
f0104652:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104653:	f6 c4 02             	test   $0x2,%ah
f0104656:	74 1f                	je     f0104677 <trap+0x3e>
f0104658:	8d 83 53 65 f8 ff    	lea    -0x79aad(%ebx),%eax
f010465e:	50                   	push   %eax
f010465f:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0104665:	50                   	push   %eax
f0104666:	68 a8 00 00 00       	push   $0xa8
f010466b:	8d 83 6c 65 f8 ff    	lea    -0x79a94(%ebx),%eax
f0104671:	50                   	push   %eax
f0104672:	e8 64 ba ff ff       	call   f01000db <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0104677:	83 ec 08             	sub    $0x8,%esp
f010467a:	56                   	push   %esi
f010467b:	8d 83 78 65 f8 ff    	lea    -0x79a88(%ebx),%eax
f0104681:	50                   	push   %eax
f0104682:	e8 91 fc ff ff       	call   f0104318 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0104687:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010468b:	83 e0 03             	and    $0x3,%eax
f010468e:	83 c4 10             	add    $0x10,%esp
f0104691:	66 83 f8 03          	cmp    $0x3,%ax
f0104695:	75 1d                	jne    f01046b4 <trap+0x7b>
		// Trapped from user mode.
		assert(curenv);
f0104697:	c7 c0 84 2b 18 f0    	mov    $0xf0182b84,%eax
f010469d:	8b 00                	mov    (%eax),%eax
f010469f:	85 c0                	test   %eax,%eax
f01046a1:	74 68                	je     f010470b <trap+0xd2>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01046a3:	b9 11 00 00 00       	mov    $0x11,%ecx
f01046a8:	89 c7                	mov    %eax,%edi
f01046aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01046ac:	c7 c0 84 2b 18 f0    	mov    $0xf0182b84,%eax
f01046b2:	8b 30                	mov    (%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01046b4:	89 b3 38 2b 00 00    	mov    %esi,0x2b38(%ebx)
	print_trapframe(tf);
f01046ba:	83 ec 0c             	sub    $0xc,%esp
f01046bd:	56                   	push   %esi
f01046be:	e8 be fd ff ff       	call   f0104481 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01046c3:	83 c4 10             	add    $0x10,%esp
f01046c6:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01046cb:	74 5d                	je     f010472a <trap+0xf1>
		env_destroy(curenv);
f01046cd:	83 ec 0c             	sub    $0xc,%esp
f01046d0:	c7 c6 84 2b 18 f0    	mov    $0xf0182b84,%esi
f01046d6:	ff 36                	push   (%esi)
f01046d8:	e8 c7 fa ff ff       	call   f01041a4 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f01046dd:	8b 06                	mov    (%esi),%eax
f01046df:	83 c4 10             	add    $0x10,%esp
f01046e2:	85 c0                	test   %eax,%eax
f01046e4:	74 06                	je     f01046ec <trap+0xb3>
f01046e6:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01046ea:	74 59                	je     f0104745 <trap+0x10c>
f01046ec:	8d 83 f8 66 f8 ff    	lea    -0x79908(%ebx),%eax
f01046f2:	50                   	push   %eax
f01046f3:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f01046f9:	50                   	push   %eax
f01046fa:	68 c0 00 00 00       	push   $0xc0
f01046ff:	8d 83 6c 65 f8 ff    	lea    -0x79a94(%ebx),%eax
f0104705:	50                   	push   %eax
f0104706:	e8 d0 b9 ff ff       	call   f01000db <_panic>
		assert(curenv);
f010470b:	8d 83 93 65 f8 ff    	lea    -0x79a6d(%ebx),%eax
f0104711:	50                   	push   %eax
f0104712:	8d 83 68 56 f8 ff    	lea    -0x7a998(%ebx),%eax
f0104718:	50                   	push   %eax
f0104719:	68 ae 00 00 00       	push   $0xae
f010471e:	8d 83 6c 65 f8 ff    	lea    -0x79a94(%ebx),%eax
f0104724:	50                   	push   %eax
f0104725:	e8 b1 b9 ff ff       	call   f01000db <_panic>
		panic("unhandled trap in kernel");
f010472a:	83 ec 04             	sub    $0x4,%esp
f010472d:	8d 83 9a 65 f8 ff    	lea    -0x79a66(%ebx),%eax
f0104733:	50                   	push   %eax
f0104734:	68 97 00 00 00       	push   $0x97
f0104739:	8d 83 6c 65 f8 ff    	lea    -0x79a94(%ebx),%eax
f010473f:	50                   	push   %eax
f0104740:	e8 96 b9 ff ff       	call   f01000db <_panic>
	env_run(curenv);
f0104745:	83 ec 0c             	sub    $0xc,%esp
f0104748:	50                   	push   %eax
f0104749:	e8 c4 fa ff ff       	call   f0104212 <env_run>

f010474e <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010474e:	55                   	push   %ebp
f010474f:	89 e5                	mov    %esp,%ebp
f0104751:	57                   	push   %edi
f0104752:	56                   	push   %esi
f0104753:	53                   	push   %ebx
f0104754:	83 ec 0c             	sub    $0xc,%esp
f0104757:	e8 35 ba ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f010475c:	81 c3 0c c1 07 00    	add    $0x7c10c,%ebx
f0104762:	8b 7d 08             	mov    0x8(%ebp),%edi
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104765:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104768:	ff 77 30             	push   0x30(%edi)
f010476b:	50                   	push   %eax
f010476c:	c7 c6 84 2b 18 f0    	mov    $0xf0182b84,%esi
f0104772:	8b 06                	mov    (%esi),%eax
f0104774:	ff 70 48             	push   0x48(%eax)
f0104777:	8d 83 24 67 f8 ff    	lea    -0x798dc(%ebx),%eax
f010477d:	50                   	push   %eax
f010477e:	e8 95 fb ff ff       	call   f0104318 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104783:	89 3c 24             	mov    %edi,(%esp)
f0104786:	e8 f6 fc ff ff       	call   f0104481 <print_trapframe>
	env_destroy(curenv);
f010478b:	83 c4 04             	add    $0x4,%esp
f010478e:	ff 36                	push   (%esi)
f0104790:	e8 0f fa ff ff       	call   f01041a4 <env_destroy>
}
f0104795:	83 c4 10             	add    $0x10,%esp
f0104798:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010479b:	5b                   	pop    %ebx
f010479c:	5e                   	pop    %esi
f010479d:	5f                   	pop    %edi
f010479e:	5d                   	pop    %ebp
f010479f:	c3                   	ret    

f01047a0 <syscall>:
f01047a0:	55                   	push   %ebp
f01047a1:	89 e5                	mov    %esp,%ebp
f01047a3:	53                   	push   %ebx
f01047a4:	83 ec 08             	sub    $0x8,%esp
f01047a7:	e8 e5 b9 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01047ac:	81 c3 bc c0 07 00    	add    $0x7c0bc,%ebx
f01047b2:	8d 83 47 67 f8 ff    	lea    -0x798b9(%ebx),%eax
f01047b8:	50                   	push   %eax
f01047b9:	6a 49                	push   $0x49
f01047bb:	8d 83 5f 67 f8 ff    	lea    -0x798a1(%ebx),%eax
f01047c1:	50                   	push   %eax
f01047c2:	e8 14 b9 ff ff       	call   f01000db <_panic>

f01047c7 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01047c7:	55                   	push   %ebp
f01047c8:	89 e5                	mov    %esp,%ebp
f01047ca:	57                   	push   %edi
f01047cb:	56                   	push   %esi
f01047cc:	53                   	push   %ebx
f01047cd:	83 ec 14             	sub    $0x14,%esp
f01047d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01047d3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01047d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01047d9:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01047dc:	8b 1a                	mov    (%edx),%ebx
f01047de:	8b 01                	mov    (%ecx),%eax
f01047e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01047e3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01047ea:	eb 2f                	jmp    f010481b <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01047ec:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01047ef:	39 c3                	cmp    %eax,%ebx
f01047f1:	7f 4e                	jg     f0104841 <stab_binsearch+0x7a>
f01047f3:	0f b6 0a             	movzbl (%edx),%ecx
f01047f6:	83 ea 0c             	sub    $0xc,%edx
f01047f9:	39 f1                	cmp    %esi,%ecx
f01047fb:	75 ef                	jne    f01047ec <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01047fd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104800:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104803:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104807:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010480a:	73 3a                	jae    f0104846 <stab_binsearch+0x7f>
			*region_left = m;
f010480c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010480f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104811:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104814:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f010481b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010481e:	7f 53                	jg     f0104873 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104820:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104823:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104826:	89 d0                	mov    %edx,%eax
f0104828:	c1 e8 1f             	shr    $0x1f,%eax
f010482b:	01 d0                	add    %edx,%eax
f010482d:	89 c7                	mov    %eax,%edi
f010482f:	d1 ff                	sar    %edi
f0104831:	83 e0 fe             	and    $0xfffffffe,%eax
f0104834:	01 f8                	add    %edi,%eax
f0104836:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104839:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f010483d:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f010483f:	eb ae                	jmp    f01047ef <stab_binsearch+0x28>
			l = true_m + 1;
f0104841:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104844:	eb d5                	jmp    f010481b <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104846:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104849:	76 14                	jbe    f010485f <stab_binsearch+0x98>
			*region_right = m - 1;
f010484b:	83 e8 01             	sub    $0x1,%eax
f010484e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104851:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104854:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104856:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010485d:	eb bc                	jmp    f010481b <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010485f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104862:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104864:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104868:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010486a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104871:	eb a8                	jmp    f010481b <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104873:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104877:	75 15                	jne    f010488e <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104879:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010487c:	8b 00                	mov    (%eax),%eax
f010487e:	83 e8 01             	sub    $0x1,%eax
f0104881:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104884:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104886:	83 c4 14             	add    $0x14,%esp
f0104889:	5b                   	pop    %ebx
f010488a:	5e                   	pop    %esi
f010488b:	5f                   	pop    %edi
f010488c:	5d                   	pop    %ebp
f010488d:	c3                   	ret    
		for (l = *region_right;
f010488e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104891:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104893:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104896:	8b 0f                	mov    (%edi),%ecx
f0104898:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010489b:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010489e:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01048a2:	39 c1                	cmp    %eax,%ecx
f01048a4:	7d 0f                	jge    f01048b5 <stab_binsearch+0xee>
f01048a6:	0f b6 1a             	movzbl (%edx),%ebx
f01048a9:	83 ea 0c             	sub    $0xc,%edx
f01048ac:	39 f3                	cmp    %esi,%ebx
f01048ae:	74 05                	je     f01048b5 <stab_binsearch+0xee>
		     l--)
f01048b0:	83 e8 01             	sub    $0x1,%eax
f01048b3:	eb ed                	jmp    f01048a2 <stab_binsearch+0xdb>
		*region_left = l;
f01048b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01048b8:	89 07                	mov    %eax,(%edi)
}
f01048ba:	eb ca                	jmp    f0104886 <stab_binsearch+0xbf>

f01048bc <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01048bc:	55                   	push   %ebp
f01048bd:	89 e5                	mov    %esp,%ebp
f01048bf:	57                   	push   %edi
f01048c0:	56                   	push   %esi
f01048c1:	53                   	push   %ebx
f01048c2:	83 ec 3c             	sub    $0x3c,%esp
f01048c5:	e8 c7 b8 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f01048ca:	81 c3 9e bf 07 00    	add    $0x7bf9e,%ebx
f01048d0:	8b 75 08             	mov    0x8(%ebp),%esi
f01048d3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01048d6:	8d 83 6e 67 f8 ff    	lea    -0x79892(%ebx),%eax
f01048dc:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f01048de:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f01048e5:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f01048e8:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f01048ef:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f01048f2:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01048f9:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01048ff:	0f 87 ea 00 00 00    	ja     f01049ef <debuginfo_eip+0x133>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104905:	a1 00 00 20 00       	mov    0x200000,%eax
f010490a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f010490d:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104912:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104918:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f010491b:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104921:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104924:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104927:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f010492a:	0f 83 56 01 00 00    	jae    f0104a86 <debuginfo_eip+0x1ca>
f0104930:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104934:	0f 85 53 01 00 00    	jne    f0104a8d <debuginfo_eip+0x1d1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010493a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104941:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0104944:	c1 f8 02             	sar    $0x2,%eax
f0104947:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010494d:	83 e8 01             	sub    $0x1,%eax
f0104950:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104953:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104956:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104959:	56                   	push   %esi
f010495a:	6a 64                	push   $0x64
f010495c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010495f:	e8 63 fe ff ff       	call   f01047c7 <stab_binsearch>
	if (lfile == 0)
f0104964:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104967:	83 c4 08             	add    $0x8,%esp
f010496a:	85 c9                	test   %ecx,%ecx
f010496c:	0f 84 22 01 00 00    	je     f0104a94 <debuginfo_eip+0x1d8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104972:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0104975:	89 4d dc             	mov    %ecx,-0x24(%ebp)
	rfun = rfile;
f0104978:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010497b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010497e:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104981:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104984:	56                   	push   %esi
f0104985:	6a 24                	push   $0x24
f0104987:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010498a:	e8 38 fe ff ff       	call   f01047c7 <stab_binsearch>

	if (lfun <= rfun) {
f010498f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104992:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104995:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104998:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010499b:	83 c4 08             	add    $0x8,%esp
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
		lline = lfile;
f010499e:	8b 75 c8             	mov    -0x38(%ebp),%esi
	if (lfun <= rfun) {
f01049a1:	39 c2                	cmp    %eax,%edx
f01049a3:	7f 25                	jg     f01049ca <debuginfo_eip+0x10e>
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01049a5:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01049a8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01049ab:	8d 14 86             	lea    (%esi,%eax,4),%edx
f01049ae:	8b 02                	mov    (%edx),%eax
f01049b0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01049b3:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01049b6:	29 f1                	sub    %esi,%ecx
f01049b8:	39 c8                	cmp    %ecx,%eax
f01049ba:	73 05                	jae    f01049c1 <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01049bc:	01 f0                	add    %esi,%eax
f01049be:	89 47 08             	mov    %eax,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01049c1:	8b 42 08             	mov    0x8(%edx),%eax
f01049c4:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfun;
f01049c7:	8b 75 c4             	mov    -0x3c(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01049ca:	83 ec 08             	sub    $0x8,%esp
f01049cd:	6a 3a                	push   $0x3a
f01049cf:	ff 77 08             	push   0x8(%edi)
f01049d2:	e8 22 09 00 00       	call   f01052f9 <strfind>
f01049d7:	2b 47 08             	sub    0x8(%edi),%eax
f01049da:	89 47 0c             	mov    %eax,0xc(%edi)
f01049dd:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01049e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01049e3:	8d 44 83 04          	lea    0x4(%ebx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01049e7:	83 c4 10             	add    $0x10,%esp
f01049ea:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f01049ed:	eb 2c                	jmp    f0104a1b <debuginfo_eip+0x15f>
		stabstr_end = __STABSTR_END__;
f01049ef:	c7 c0 33 3d 11 f0    	mov    $0xf0113d33,%eax
f01049f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01049f8:	c7 c0 a9 00 11 f0    	mov    $0xf01100a9,%eax
f01049fe:	89 45 cc             	mov    %eax,-0x34(%ebp)
		stab_end = __STAB_END__;
f0104a01:	c7 c0 a8 00 11 f0    	mov    $0xf01100a8,%eax
		stabs = __STAB_BEGIN__;
f0104a07:	c7 c1 d4 71 10 f0    	mov    $0xf01071d4,%ecx
f0104a0d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104a10:	e9 0f ff ff ff       	jmp    f0104924 <debuginfo_eip+0x68>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104a15:	83 ee 01             	sub    $0x1,%esi
f0104a18:	83 e8 0c             	sub    $0xc,%eax
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104a1b:	39 f3                	cmp    %esi,%ebx
f0104a1d:	7f 2e                	jg     f0104a4d <debuginfo_eip+0x191>
	       && stabs[lline].n_type != N_SOL
f0104a1f:	0f b6 10             	movzbl (%eax),%edx
f0104a22:	80 fa 84             	cmp    $0x84,%dl
f0104a25:	74 0b                	je     f0104a32 <debuginfo_eip+0x176>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104a27:	80 fa 64             	cmp    $0x64,%dl
f0104a2a:	75 e9                	jne    f0104a15 <debuginfo_eip+0x159>
f0104a2c:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104a30:	74 e3                	je     f0104a15 <debuginfo_eip+0x159>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104a32:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104a35:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104a38:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0104a3b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104a3e:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104a41:	29 d8                	sub    %ebx,%eax
f0104a43:	39 c2                	cmp    %eax,%edx
f0104a45:	73 06                	jae    f0104a4d <debuginfo_eip+0x191>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104a47:	89 d8                	mov    %ebx,%eax
f0104a49:	01 d0                	add    %edx,%eax
f0104a4b:	89 07                	mov    %eax,(%edi)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104a4d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104a52:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0104a55:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104a58:	39 cb                	cmp    %ecx,%ebx
f0104a5a:	7d 44                	jge    f0104aa0 <debuginfo_eip+0x1e4>
		for (lline = lfun + 1;
f0104a5c:	8d 53 01             	lea    0x1(%ebx),%edx
f0104a5f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104a62:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104a65:	8d 44 83 10          	lea    0x10(%ebx,%eax,4),%eax
f0104a69:	eb 07                	jmp    f0104a72 <debuginfo_eip+0x1b6>
			info->eip_fn_narg++;
f0104a6b:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0104a6f:	83 c2 01             	add    $0x1,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104a72:	39 d1                	cmp    %edx,%ecx
f0104a74:	74 25                	je     f0104a9b <debuginfo_eip+0x1df>
f0104a76:	83 c0 0c             	add    $0xc,%eax
f0104a79:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0104a7d:	74 ec                	je     f0104a6b <debuginfo_eip+0x1af>
	return 0;
f0104a7f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a84:	eb 1a                	jmp    f0104aa0 <debuginfo_eip+0x1e4>
		return -1;
f0104a86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a8b:	eb 13                	jmp    f0104aa0 <debuginfo_eip+0x1e4>
f0104a8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a92:	eb 0c                	jmp    f0104aa0 <debuginfo_eip+0x1e4>
		return -1;
f0104a94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a99:	eb 05                	jmp    f0104aa0 <debuginfo_eip+0x1e4>
	return 0;
f0104a9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104aa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104aa3:	5b                   	pop    %ebx
f0104aa4:	5e                   	pop    %esi
f0104aa5:	5f                   	pop    %edi
f0104aa6:	5d                   	pop    %ebp
f0104aa7:	c3                   	ret    

f0104aa8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104aa8:	55                   	push   %ebp
f0104aa9:	89 e5                	mov    %esp,%ebp
f0104aab:	57                   	push   %edi
f0104aac:	56                   	push   %esi
f0104aad:	53                   	push   %ebx
f0104aae:	83 ec 2c             	sub    $0x2c,%esp
f0104ab1:	e8 40 ef ff ff       	call   f01039f6 <__x86.get_pc_thunk.cx>
f0104ab6:	81 c1 b2 bd 07 00    	add    $0x7bdb2,%ecx
f0104abc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104abf:	89 c7                	mov    %eax,%edi
f0104ac1:	89 d6                	mov    %edx,%esi
f0104ac3:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ac9:	89 d1                	mov    %edx,%ecx
f0104acb:	89 c2                	mov    %eax,%edx
f0104acd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104ad0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104ad3:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ad6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104ad9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104adc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104ae3:	39 c2                	cmp    %eax,%edx
f0104ae5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0104ae8:	72 41                	jb     f0104b2b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104aea:	83 ec 0c             	sub    $0xc,%esp
f0104aed:	ff 75 18             	push   0x18(%ebp)
f0104af0:	83 eb 01             	sub    $0x1,%ebx
f0104af3:	53                   	push   %ebx
f0104af4:	50                   	push   %eax
f0104af5:	83 ec 08             	sub    $0x8,%esp
f0104af8:	ff 75 e4             	push   -0x1c(%ebp)
f0104afb:	ff 75 e0             	push   -0x20(%ebp)
f0104afe:	ff 75 d4             	push   -0x2c(%ebp)
f0104b01:	ff 75 d0             	push   -0x30(%ebp)
f0104b04:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104b07:	e8 04 0a 00 00       	call   f0105510 <__udivdi3>
f0104b0c:	83 c4 18             	add    $0x18,%esp
f0104b0f:	52                   	push   %edx
f0104b10:	50                   	push   %eax
f0104b11:	89 f2                	mov    %esi,%edx
f0104b13:	89 f8                	mov    %edi,%eax
f0104b15:	e8 8e ff ff ff       	call   f0104aa8 <printnum>
f0104b1a:	83 c4 20             	add    $0x20,%esp
f0104b1d:	eb 13                	jmp    f0104b32 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104b1f:	83 ec 08             	sub    $0x8,%esp
f0104b22:	56                   	push   %esi
f0104b23:	ff 75 18             	push   0x18(%ebp)
f0104b26:	ff d7                	call   *%edi
f0104b28:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0104b2b:	83 eb 01             	sub    $0x1,%ebx
f0104b2e:	85 db                	test   %ebx,%ebx
f0104b30:	7f ed                	jg     f0104b1f <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104b32:	83 ec 08             	sub    $0x8,%esp
f0104b35:	56                   	push   %esi
f0104b36:	83 ec 04             	sub    $0x4,%esp
f0104b39:	ff 75 e4             	push   -0x1c(%ebp)
f0104b3c:	ff 75 e0             	push   -0x20(%ebp)
f0104b3f:	ff 75 d4             	push   -0x2c(%ebp)
f0104b42:	ff 75 d0             	push   -0x30(%ebp)
f0104b45:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104b48:	e8 e3 0a 00 00       	call   f0105630 <__umoddi3>
f0104b4d:	83 c4 14             	add    $0x14,%esp
f0104b50:	0f be 84 03 78 67 f8 	movsbl -0x79888(%ebx,%eax,1),%eax
f0104b57:	ff 
f0104b58:	50                   	push   %eax
f0104b59:	ff d7                	call   *%edi
}
f0104b5b:	83 c4 10             	add    $0x10,%esp
f0104b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b61:	5b                   	pop    %ebx
f0104b62:	5e                   	pop    %esi
f0104b63:	5f                   	pop    %edi
f0104b64:	5d                   	pop    %ebp
f0104b65:	c3                   	ret    

f0104b66 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104b66:	55                   	push   %ebp
f0104b67:	89 e5                	mov    %esp,%ebp
f0104b69:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104b6c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104b70:	8b 10                	mov    (%eax),%edx
f0104b72:	3b 50 04             	cmp    0x4(%eax),%edx
f0104b75:	73 0a                	jae    f0104b81 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104b77:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104b7a:	89 08                	mov    %ecx,(%eax)
f0104b7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b7f:	88 02                	mov    %al,(%edx)
}
f0104b81:	5d                   	pop    %ebp
f0104b82:	c3                   	ret    

f0104b83 <printfmt>:
{
f0104b83:	55                   	push   %ebp
f0104b84:	89 e5                	mov    %esp,%ebp
f0104b86:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104b89:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104b8c:	50                   	push   %eax
f0104b8d:	ff 75 10             	push   0x10(%ebp)
f0104b90:	ff 75 0c             	push   0xc(%ebp)
f0104b93:	ff 75 08             	push   0x8(%ebp)
f0104b96:	e8 05 00 00 00       	call   f0104ba0 <vprintfmt>
}
f0104b9b:	83 c4 10             	add    $0x10,%esp
f0104b9e:	c9                   	leave  
f0104b9f:	c3                   	ret    

f0104ba0 <vprintfmt>:
{
f0104ba0:	55                   	push   %ebp
f0104ba1:	89 e5                	mov    %esp,%ebp
f0104ba3:	57                   	push   %edi
f0104ba4:	56                   	push   %esi
f0104ba5:	53                   	push   %ebx
f0104ba6:	83 ec 3c             	sub    $0x3c,%esp
f0104ba9:	e8 75 bb ff ff       	call   f0100723 <__x86.get_pc_thunk.ax>
f0104bae:	05 ba bc 07 00       	add    $0x7bcba,%eax
f0104bb3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104bb6:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bb9:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104bbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104bbf:	8d 80 68 20 00 00    	lea    0x2068(%eax),%eax
f0104bc5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0104bc8:	eb 0a                	jmp    f0104bd4 <vprintfmt+0x34>
			putch(ch, putdat);
f0104bca:	83 ec 08             	sub    $0x8,%esp
f0104bcd:	57                   	push   %edi
f0104bce:	50                   	push   %eax
f0104bcf:	ff d6                	call   *%esi
f0104bd1:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104bd4:	83 c3 01             	add    $0x1,%ebx
f0104bd7:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0104bdb:	83 f8 25             	cmp    $0x25,%eax
f0104bde:	74 0c                	je     f0104bec <vprintfmt+0x4c>
			if (ch == '\0')
f0104be0:	85 c0                	test   %eax,%eax
f0104be2:	75 e6                	jne    f0104bca <vprintfmt+0x2a>
}
f0104be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104be7:	5b                   	pop    %ebx
f0104be8:	5e                   	pop    %esi
f0104be9:	5f                   	pop    %edi
f0104bea:	5d                   	pop    %ebp
f0104beb:	c3                   	ret    
		padc = ' ';
f0104bec:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0104bf0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0104bf7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0104bfe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f0104c05:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104c0a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0104c0d:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104c10:	8d 43 01             	lea    0x1(%ebx),%eax
f0104c13:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104c16:	0f b6 13             	movzbl (%ebx),%edx
f0104c19:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104c1c:	3c 55                	cmp    $0x55,%al
f0104c1e:	0f 87 c5 03 00 00    	ja     f0104fe9 <.L20>
f0104c24:	0f b6 c0             	movzbl %al,%eax
f0104c27:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104c2a:	89 ce                	mov    %ecx,%esi
f0104c2c:	03 b4 81 04 68 f8 ff 	add    -0x797fc(%ecx,%eax,4),%esi
f0104c33:	ff e6                	jmp    *%esi

f0104c35 <.L66>:
f0104c35:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0104c38:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0104c3c:	eb d2                	jmp    f0104c10 <vprintfmt+0x70>

f0104c3e <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0104c3e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c41:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0104c45:	eb c9                	jmp    f0104c10 <vprintfmt+0x70>

f0104c47 <.L31>:
f0104c47:	0f b6 d2             	movzbl %dl,%edx
f0104c4a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0104c4d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c52:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0104c55:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104c58:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104c5c:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0104c5f:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104c62:	83 f9 09             	cmp    $0x9,%ecx
f0104c65:	77 58                	ja     f0104cbf <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0104c67:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0104c6a:	eb e9                	jmp    f0104c55 <.L31+0xe>

f0104c6c <.L34>:
			precision = va_arg(ap, int);
f0104c6c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c6f:	8b 00                	mov    (%eax),%eax
f0104c71:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104c74:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c77:	8d 40 04             	lea    0x4(%eax),%eax
f0104c7a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104c7d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0104c80:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0104c84:	79 8a                	jns    f0104c10 <vprintfmt+0x70>
				width = precision, precision = -1;
f0104c86:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104c89:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104c8c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0104c93:	e9 78 ff ff ff       	jmp    f0104c10 <vprintfmt+0x70>

f0104c98 <.L33>:
f0104c98:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104c9b:	85 d2                	test   %edx,%edx
f0104c9d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ca2:	0f 49 c2             	cmovns %edx,%eax
f0104ca5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104ca8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0104cab:	e9 60 ff ff ff       	jmp    f0104c10 <vprintfmt+0x70>

f0104cb0 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0104cb0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0104cb3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0104cba:	e9 51 ff ff ff       	jmp    f0104c10 <vprintfmt+0x70>
f0104cbf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104cc2:	89 75 08             	mov    %esi,0x8(%ebp)
f0104cc5:	eb b9                	jmp    f0104c80 <.L34+0x14>

f0104cc7 <.L27>:
			lflag++;
f0104cc7:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104ccb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0104cce:	e9 3d ff ff ff       	jmp    f0104c10 <vprintfmt+0x70>

f0104cd3 <.L30>:
			putch(va_arg(ap, int), putdat);
f0104cd3:	8b 75 08             	mov    0x8(%ebp),%esi
f0104cd6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cd9:	8d 58 04             	lea    0x4(%eax),%ebx
f0104cdc:	83 ec 08             	sub    $0x8,%esp
f0104cdf:	57                   	push   %edi
f0104ce0:	ff 30                	push   (%eax)
f0104ce2:	ff d6                	call   *%esi
			break;
f0104ce4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104ce7:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0104cea:	e9 90 02 00 00       	jmp    f0104f7f <.L25+0x45>

f0104cef <.L28>:
			err = va_arg(ap, int);
f0104cef:	8b 75 08             	mov    0x8(%ebp),%esi
f0104cf2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cf5:	8d 58 04             	lea    0x4(%eax),%ebx
f0104cf8:	8b 10                	mov    (%eax),%edx
f0104cfa:	89 d0                	mov    %edx,%eax
f0104cfc:	f7 d8                	neg    %eax
f0104cfe:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104d01:	83 f8 06             	cmp    $0x6,%eax
f0104d04:	7f 27                	jg     f0104d2d <.L28+0x3e>
f0104d06:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0104d09:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0104d0c:	85 d2                	test   %edx,%edx
f0104d0e:	74 1d                	je     f0104d2d <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f0104d10:	52                   	push   %edx
f0104d11:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d14:	8d 80 7a 56 f8 ff    	lea    -0x7a986(%eax),%eax
f0104d1a:	50                   	push   %eax
f0104d1b:	57                   	push   %edi
f0104d1c:	56                   	push   %esi
f0104d1d:	e8 61 fe ff ff       	call   f0104b83 <printfmt>
f0104d22:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104d25:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0104d28:	e9 52 02 00 00       	jmp    f0104f7f <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0104d2d:	50                   	push   %eax
f0104d2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d31:	8d 80 90 67 f8 ff    	lea    -0x79870(%eax),%eax
f0104d37:	50                   	push   %eax
f0104d38:	57                   	push   %edi
f0104d39:	56                   	push   %esi
f0104d3a:	e8 44 fe ff ff       	call   f0104b83 <printfmt>
f0104d3f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104d42:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104d45:	e9 35 02 00 00       	jmp    f0104f7f <.L25+0x45>

f0104d4a <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f0104d4a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d4d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d50:	83 c0 04             	add    $0x4,%eax
f0104d53:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0104d56:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d59:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0104d5b:	85 d2                	test   %edx,%edx
f0104d5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d60:	8d 80 89 67 f8 ff    	lea    -0x79877(%eax),%eax
f0104d66:	0f 45 c2             	cmovne %edx,%eax
f0104d69:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0104d6c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0104d70:	7e 06                	jle    f0104d78 <.L24+0x2e>
f0104d72:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0104d76:	75 0d                	jne    f0104d85 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104d78:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104d7b:	89 c3                	mov    %eax,%ebx
f0104d7d:	03 45 d0             	add    -0x30(%ebp),%eax
f0104d80:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104d83:	eb 58                	jmp    f0104ddd <.L24+0x93>
f0104d85:	83 ec 08             	sub    $0x8,%esp
f0104d88:	ff 75 d8             	push   -0x28(%ebp)
f0104d8b:	ff 75 c8             	push   -0x38(%ebp)
f0104d8e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104d91:	e8 0c 04 00 00       	call   f01051a2 <strnlen>
f0104d96:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104d99:	29 c2                	sub    %eax,%edx
f0104d9b:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0104d9e:	83 c4 10             	add    $0x10,%esp
f0104da1:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0104da3:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0104da7:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104daa:	eb 0f                	jmp    f0104dbb <.L24+0x71>
					putch(padc, putdat);
f0104dac:	83 ec 08             	sub    $0x8,%esp
f0104daf:	57                   	push   %edi
f0104db0:	ff 75 d0             	push   -0x30(%ebp)
f0104db3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104db5:	83 eb 01             	sub    $0x1,%ebx
f0104db8:	83 c4 10             	add    $0x10,%esp
f0104dbb:	85 db                	test   %ebx,%ebx
f0104dbd:	7f ed                	jg     f0104dac <.L24+0x62>
f0104dbf:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104dc2:	85 d2                	test   %edx,%edx
f0104dc4:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dc9:	0f 49 c2             	cmovns %edx,%eax
f0104dcc:	29 c2                	sub    %eax,%edx
f0104dce:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104dd1:	eb a5                	jmp    f0104d78 <.L24+0x2e>
					putch(ch, putdat);
f0104dd3:	83 ec 08             	sub    $0x8,%esp
f0104dd6:	57                   	push   %edi
f0104dd7:	52                   	push   %edx
f0104dd8:	ff d6                	call   *%esi
f0104dda:	83 c4 10             	add    $0x10,%esp
f0104ddd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104de0:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104de2:	83 c3 01             	add    $0x1,%ebx
f0104de5:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0104de9:	0f be d0             	movsbl %al,%edx
f0104dec:	85 d2                	test   %edx,%edx
f0104dee:	74 4b                	je     f0104e3b <.L24+0xf1>
f0104df0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104df4:	78 06                	js     f0104dfc <.L24+0xb2>
f0104df6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0104dfa:	78 1e                	js     f0104e1a <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0104dfc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104e00:	74 d1                	je     f0104dd3 <.L24+0x89>
f0104e02:	0f be c0             	movsbl %al,%eax
f0104e05:	83 e8 20             	sub    $0x20,%eax
f0104e08:	83 f8 5e             	cmp    $0x5e,%eax
f0104e0b:	76 c6                	jbe    f0104dd3 <.L24+0x89>
					putch('?', putdat);
f0104e0d:	83 ec 08             	sub    $0x8,%esp
f0104e10:	57                   	push   %edi
f0104e11:	6a 3f                	push   $0x3f
f0104e13:	ff d6                	call   *%esi
f0104e15:	83 c4 10             	add    $0x10,%esp
f0104e18:	eb c3                	jmp    f0104ddd <.L24+0x93>
f0104e1a:	89 cb                	mov    %ecx,%ebx
f0104e1c:	eb 0e                	jmp    f0104e2c <.L24+0xe2>
				putch(' ', putdat);
f0104e1e:	83 ec 08             	sub    $0x8,%esp
f0104e21:	57                   	push   %edi
f0104e22:	6a 20                	push   $0x20
f0104e24:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0104e26:	83 eb 01             	sub    $0x1,%ebx
f0104e29:	83 c4 10             	add    $0x10,%esp
f0104e2c:	85 db                	test   %ebx,%ebx
f0104e2e:	7f ee                	jg     f0104e1e <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f0104e30:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0104e33:	89 45 14             	mov    %eax,0x14(%ebp)
f0104e36:	e9 44 01 00 00       	jmp    f0104f7f <.L25+0x45>
f0104e3b:	89 cb                	mov    %ecx,%ebx
f0104e3d:	eb ed                	jmp    f0104e2c <.L24+0xe2>

f0104e3f <.L29>:
	if (lflag >= 2)
f0104e3f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104e42:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e45:	83 f9 01             	cmp    $0x1,%ecx
f0104e48:	7f 1b                	jg     f0104e65 <.L29+0x26>
	else if (lflag)
f0104e4a:	85 c9                	test   %ecx,%ecx
f0104e4c:	74 63                	je     f0104eb1 <.L29+0x72>
		return va_arg(*ap, long);
f0104e4e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e51:	8b 00                	mov    (%eax),%eax
f0104e53:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e56:	99                   	cltd   
f0104e57:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104e5a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e5d:	8d 40 04             	lea    0x4(%eax),%eax
f0104e60:	89 45 14             	mov    %eax,0x14(%ebp)
f0104e63:	eb 17                	jmp    f0104e7c <.L29+0x3d>
		return va_arg(*ap, long long);
f0104e65:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e68:	8b 50 04             	mov    0x4(%eax),%edx
f0104e6b:	8b 00                	mov    (%eax),%eax
f0104e6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e70:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104e73:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e76:	8d 40 08             	lea    0x8(%eax),%eax
f0104e79:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104e7c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104e7f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f0104e82:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f0104e87:	85 db                	test   %ebx,%ebx
f0104e89:	0f 89 d6 00 00 00    	jns    f0104f65 <.L25+0x2b>
				putch('-', putdat);
f0104e8f:	83 ec 08             	sub    $0x8,%esp
f0104e92:	57                   	push   %edi
f0104e93:	6a 2d                	push   $0x2d
f0104e95:	ff d6                	call   *%esi
				num = -(long long) num;
f0104e97:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104e9a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104e9d:	f7 d9                	neg    %ecx
f0104e9f:	83 d3 00             	adc    $0x0,%ebx
f0104ea2:	f7 db                	neg    %ebx
f0104ea4:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104ea7:	ba 0a 00 00 00       	mov    $0xa,%edx
f0104eac:	e9 b4 00 00 00       	jmp    f0104f65 <.L25+0x2b>
		return va_arg(*ap, int);
f0104eb1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104eb4:	8b 00                	mov    (%eax),%eax
f0104eb6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104eb9:	99                   	cltd   
f0104eba:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104ebd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ec0:	8d 40 04             	lea    0x4(%eax),%eax
f0104ec3:	89 45 14             	mov    %eax,0x14(%ebp)
f0104ec6:	eb b4                	jmp    f0104e7c <.L29+0x3d>

f0104ec8 <.L23>:
	if (lflag >= 2)
f0104ec8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104ecb:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ece:	83 f9 01             	cmp    $0x1,%ecx
f0104ed1:	7f 1b                	jg     f0104eee <.L23+0x26>
	else if (lflag)
f0104ed3:	85 c9                	test   %ecx,%ecx
f0104ed5:	74 2c                	je     f0104f03 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f0104ed7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104eda:	8b 08                	mov    (%eax),%ecx
f0104edc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ee1:	8d 40 04             	lea    0x4(%eax),%eax
f0104ee4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104ee7:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f0104eec:	eb 77                	jmp    f0104f65 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104eee:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ef1:	8b 08                	mov    (%eax),%ecx
f0104ef3:	8b 58 04             	mov    0x4(%eax),%ebx
f0104ef6:	8d 40 08             	lea    0x8(%eax),%eax
f0104ef9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104efc:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f0104f01:	eb 62                	jmp    f0104f65 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104f03:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f06:	8b 08                	mov    (%eax),%ecx
f0104f08:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f0d:	8d 40 04             	lea    0x4(%eax),%eax
f0104f10:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104f13:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f0104f18:	eb 4b                	jmp    f0104f65 <.L25+0x2b>

f0104f1a <.L26>:
			putch('X', putdat);
f0104f1a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f1d:	83 ec 08             	sub    $0x8,%esp
f0104f20:	57                   	push   %edi
f0104f21:	6a 58                	push   $0x58
f0104f23:	ff d6                	call   *%esi
			putch('X', putdat);
f0104f25:	83 c4 08             	add    $0x8,%esp
f0104f28:	57                   	push   %edi
f0104f29:	6a 58                	push   $0x58
f0104f2b:	ff d6                	call   *%esi
			putch('X', putdat);
f0104f2d:	83 c4 08             	add    $0x8,%esp
f0104f30:	57                   	push   %edi
f0104f31:	6a 58                	push   $0x58
f0104f33:	ff d6                	call   *%esi
			break;
f0104f35:	83 c4 10             	add    $0x10,%esp
f0104f38:	eb 45                	jmp    f0104f7f <.L25+0x45>

f0104f3a <.L25>:
			putch('0', putdat);
f0104f3a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f3d:	83 ec 08             	sub    $0x8,%esp
f0104f40:	57                   	push   %edi
f0104f41:	6a 30                	push   $0x30
f0104f43:	ff d6                	call   *%esi
			putch('x', putdat);
f0104f45:	83 c4 08             	add    $0x8,%esp
f0104f48:	57                   	push   %edi
f0104f49:	6a 78                	push   $0x78
f0104f4b:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104f4d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f50:	8b 08                	mov    (%eax),%ecx
f0104f52:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0104f57:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104f5a:	8d 40 04             	lea    0x4(%eax),%eax
f0104f5d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104f60:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0104f65:	83 ec 0c             	sub    $0xc,%esp
f0104f68:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0104f6c:	50                   	push   %eax
f0104f6d:	ff 75 d0             	push   -0x30(%ebp)
f0104f70:	52                   	push   %edx
f0104f71:	53                   	push   %ebx
f0104f72:	51                   	push   %ecx
f0104f73:	89 fa                	mov    %edi,%edx
f0104f75:	89 f0                	mov    %esi,%eax
f0104f77:	e8 2c fb ff ff       	call   f0104aa8 <printnum>
			break;
f0104f7c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104f7f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104f82:	e9 4d fc ff ff       	jmp    f0104bd4 <vprintfmt+0x34>

f0104f87 <.L21>:
	if (lflag >= 2)
f0104f87:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104f8a:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f8d:	83 f9 01             	cmp    $0x1,%ecx
f0104f90:	7f 1b                	jg     f0104fad <.L21+0x26>
	else if (lflag)
f0104f92:	85 c9                	test   %ecx,%ecx
f0104f94:	74 2c                	je     f0104fc2 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0104f96:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f99:	8b 08                	mov    (%eax),%ecx
f0104f9b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104fa0:	8d 40 04             	lea    0x4(%eax),%eax
f0104fa3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104fa6:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f0104fab:	eb b8                	jmp    f0104f65 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0104fad:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fb0:	8b 08                	mov    (%eax),%ecx
f0104fb2:	8b 58 04             	mov    0x4(%eax),%ebx
f0104fb5:	8d 40 08             	lea    0x8(%eax),%eax
f0104fb8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104fbb:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0104fc0:	eb a3                	jmp    f0104f65 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0104fc2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fc5:	8b 08                	mov    (%eax),%ecx
f0104fc7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104fcc:	8d 40 04             	lea    0x4(%eax),%eax
f0104fcf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104fd2:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0104fd7:	eb 8c                	jmp    f0104f65 <.L25+0x2b>

f0104fd9 <.L35>:
			putch(ch, putdat);
f0104fd9:	8b 75 08             	mov    0x8(%ebp),%esi
f0104fdc:	83 ec 08             	sub    $0x8,%esp
f0104fdf:	57                   	push   %edi
f0104fe0:	6a 25                	push   $0x25
f0104fe2:	ff d6                	call   *%esi
			break;
f0104fe4:	83 c4 10             	add    $0x10,%esp
f0104fe7:	eb 96                	jmp    f0104f7f <.L25+0x45>

f0104fe9 <.L20>:
			putch('%', putdat);
f0104fe9:	8b 75 08             	mov    0x8(%ebp),%esi
f0104fec:	83 ec 08             	sub    $0x8,%esp
f0104fef:	57                   	push   %edi
f0104ff0:	6a 25                	push   $0x25
f0104ff2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104ff4:	83 c4 10             	add    $0x10,%esp
f0104ff7:	89 d8                	mov    %ebx,%eax
f0104ff9:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104ffd:	74 05                	je     f0105004 <.L20+0x1b>
f0104fff:	83 e8 01             	sub    $0x1,%eax
f0105002:	eb f5                	jmp    f0104ff9 <.L20+0x10>
f0105004:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105007:	e9 73 ff ff ff       	jmp    f0104f7f <.L25+0x45>

f010500c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010500c:	55                   	push   %ebp
f010500d:	89 e5                	mov    %esp,%ebp
f010500f:	53                   	push   %ebx
f0105010:	83 ec 14             	sub    $0x14,%esp
f0105013:	e8 79 b1 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0105018:	81 c3 50 b8 07 00    	add    $0x7b850,%ebx
f010501e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105021:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105024:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105027:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010502b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010502e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105035:	85 c0                	test   %eax,%eax
f0105037:	74 2b                	je     f0105064 <vsnprintf+0x58>
f0105039:	85 d2                	test   %edx,%edx
f010503b:	7e 27                	jle    f0105064 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010503d:	ff 75 14             	push   0x14(%ebp)
f0105040:	ff 75 10             	push   0x10(%ebp)
f0105043:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105046:	50                   	push   %eax
f0105047:	8d 83 fe 42 f8 ff    	lea    -0x7bd02(%ebx),%eax
f010504d:	50                   	push   %eax
f010504e:	e8 4d fb ff ff       	call   f0104ba0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105053:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105056:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105059:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010505c:	83 c4 10             	add    $0x10,%esp
}
f010505f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105062:	c9                   	leave  
f0105063:	c3                   	ret    
		return -E_INVAL;
f0105064:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105069:	eb f4                	jmp    f010505f <vsnprintf+0x53>

f010506b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010506b:	55                   	push   %ebp
f010506c:	89 e5                	mov    %esp,%ebp
f010506e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105071:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105074:	50                   	push   %eax
f0105075:	ff 75 10             	push   0x10(%ebp)
f0105078:	ff 75 0c             	push   0xc(%ebp)
f010507b:	ff 75 08             	push   0x8(%ebp)
f010507e:	e8 89 ff ff ff       	call   f010500c <vsnprintf>
	va_end(ap);

	return rc;
}
f0105083:	c9                   	leave  
f0105084:	c3                   	ret    

f0105085 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105085:	55                   	push   %ebp
f0105086:	89 e5                	mov    %esp,%ebp
f0105088:	57                   	push   %edi
f0105089:	56                   	push   %esi
f010508a:	53                   	push   %ebx
f010508b:	83 ec 1c             	sub    $0x1c,%esp
f010508e:	e8 fe b0 ff ff       	call   f0100191 <__x86.get_pc_thunk.bx>
f0105093:	81 c3 d5 b7 07 00    	add    $0x7b7d5,%ebx
f0105099:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010509c:	85 c0                	test   %eax,%eax
f010509e:	74 13                	je     f01050b3 <readline+0x2e>
		cprintf("%s", prompt);
f01050a0:	83 ec 08             	sub    $0x8,%esp
f01050a3:	50                   	push   %eax
f01050a4:	8d 83 7a 56 f8 ff    	lea    -0x7a986(%ebx),%eax
f01050aa:	50                   	push   %eax
f01050ab:	e8 68 f2 ff ff       	call   f0104318 <cprintf>
f01050b0:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01050b3:	83 ec 0c             	sub    $0xc,%esp
f01050b6:	6a 00                	push   $0x0
f01050b8:	e8 60 b6 ff ff       	call   f010071d <iscons>
f01050bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01050c0:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01050c3:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f01050c8:	8d 83 d8 2b 00 00    	lea    0x2bd8(%ebx),%eax
f01050ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01050d1:	eb 45                	jmp    f0105118 <readline+0x93>
			cprintf("read error: %e\n", c);
f01050d3:	83 ec 08             	sub    $0x8,%esp
f01050d6:	50                   	push   %eax
f01050d7:	8d 83 5c 69 f8 ff    	lea    -0x796a4(%ebx),%eax
f01050dd:	50                   	push   %eax
f01050de:	e8 35 f2 ff ff       	call   f0104318 <cprintf>
			return NULL;
f01050e3:	83 c4 10             	add    $0x10,%esp
f01050e6:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01050eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050ee:	5b                   	pop    %ebx
f01050ef:	5e                   	pop    %esi
f01050f0:	5f                   	pop    %edi
f01050f1:	5d                   	pop    %ebp
f01050f2:	c3                   	ret    
			if (echoing)
f01050f3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01050f7:	75 05                	jne    f01050fe <readline+0x79>
			i--;
f01050f9:	83 ef 01             	sub    $0x1,%edi
f01050fc:	eb 1a                	jmp    f0105118 <readline+0x93>
				cputchar('\b');
f01050fe:	83 ec 0c             	sub    $0xc,%esp
f0105101:	6a 08                	push   $0x8
f0105103:	e8 f4 b5 ff ff       	call   f01006fc <cputchar>
f0105108:	83 c4 10             	add    $0x10,%esp
f010510b:	eb ec                	jmp    f01050f9 <readline+0x74>
			buf[i++] = c;
f010510d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105110:	89 f0                	mov    %esi,%eax
f0105112:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0105115:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0105118:	e8 ef b5 ff ff       	call   f010070c <getchar>
f010511d:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f010511f:	85 c0                	test   %eax,%eax
f0105121:	78 b0                	js     f01050d3 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105123:	83 f8 08             	cmp    $0x8,%eax
f0105126:	0f 94 c0             	sete   %al
f0105129:	83 fe 7f             	cmp    $0x7f,%esi
f010512c:	0f 94 c2             	sete   %dl
f010512f:	08 d0                	or     %dl,%al
f0105131:	74 04                	je     f0105137 <readline+0xb2>
f0105133:	85 ff                	test   %edi,%edi
f0105135:	7f bc                	jg     f01050f3 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105137:	83 fe 1f             	cmp    $0x1f,%esi
f010513a:	7e 1c                	jle    f0105158 <readline+0xd3>
f010513c:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0105142:	7f 14                	jg     f0105158 <readline+0xd3>
			if (echoing)
f0105144:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105148:	74 c3                	je     f010510d <readline+0x88>
				cputchar(c);
f010514a:	83 ec 0c             	sub    $0xc,%esp
f010514d:	56                   	push   %esi
f010514e:	e8 a9 b5 ff ff       	call   f01006fc <cputchar>
f0105153:	83 c4 10             	add    $0x10,%esp
f0105156:	eb b5                	jmp    f010510d <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f0105158:	83 fe 0a             	cmp    $0xa,%esi
f010515b:	74 05                	je     f0105162 <readline+0xdd>
f010515d:	83 fe 0d             	cmp    $0xd,%esi
f0105160:	75 b6                	jne    f0105118 <readline+0x93>
			if (echoing)
f0105162:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105166:	75 13                	jne    f010517b <readline+0xf6>
			buf[i] = 0;
f0105168:	c6 84 3b d8 2b 00 00 	movb   $0x0,0x2bd8(%ebx,%edi,1)
f010516f:	00 
			return buf;
f0105170:	8d 83 d8 2b 00 00    	lea    0x2bd8(%ebx),%eax
f0105176:	e9 70 ff ff ff       	jmp    f01050eb <readline+0x66>
				cputchar('\n');
f010517b:	83 ec 0c             	sub    $0xc,%esp
f010517e:	6a 0a                	push   $0xa
f0105180:	e8 77 b5 ff ff       	call   f01006fc <cputchar>
f0105185:	83 c4 10             	add    $0x10,%esp
f0105188:	eb de                	jmp    f0105168 <readline+0xe3>

f010518a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010518a:	55                   	push   %ebp
f010518b:	89 e5                	mov    %esp,%ebp
f010518d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105190:	b8 00 00 00 00       	mov    $0x0,%eax
f0105195:	eb 03                	jmp    f010519a <strlen+0x10>
		n++;
f0105197:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010519a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010519e:	75 f7                	jne    f0105197 <strlen+0xd>
	return n;
}
f01051a0:	5d                   	pop    %ebp
f01051a1:	c3                   	ret    

f01051a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01051a2:	55                   	push   %ebp
f01051a3:	89 e5                	mov    %esp,%ebp
f01051a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01051a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01051ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01051b0:	eb 03                	jmp    f01051b5 <strnlen+0x13>
		n++;
f01051b2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01051b5:	39 d0                	cmp    %edx,%eax
f01051b7:	74 08                	je     f01051c1 <strnlen+0x1f>
f01051b9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01051bd:	75 f3                	jne    f01051b2 <strnlen+0x10>
f01051bf:	89 c2                	mov    %eax,%edx
	return n;
}
f01051c1:	89 d0                	mov    %edx,%eax
f01051c3:	5d                   	pop    %ebp
f01051c4:	c3                   	ret    

f01051c5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01051c5:	55                   	push   %ebp
f01051c6:	89 e5                	mov    %esp,%ebp
f01051c8:	53                   	push   %ebx
f01051c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01051cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01051cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01051d4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01051d8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01051db:	83 c0 01             	add    $0x1,%eax
f01051de:	84 d2                	test   %dl,%dl
f01051e0:	75 f2                	jne    f01051d4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01051e2:	89 c8                	mov    %ecx,%eax
f01051e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01051e7:	c9                   	leave  
f01051e8:	c3                   	ret    

f01051e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01051e9:	55                   	push   %ebp
f01051ea:	89 e5                	mov    %esp,%ebp
f01051ec:	53                   	push   %ebx
f01051ed:	83 ec 10             	sub    $0x10,%esp
f01051f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01051f3:	53                   	push   %ebx
f01051f4:	e8 91 ff ff ff       	call   f010518a <strlen>
f01051f9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01051fc:	ff 75 0c             	push   0xc(%ebp)
f01051ff:	01 d8                	add    %ebx,%eax
f0105201:	50                   	push   %eax
f0105202:	e8 be ff ff ff       	call   f01051c5 <strcpy>
	return dst;
}
f0105207:	89 d8                	mov    %ebx,%eax
f0105209:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010520c:	c9                   	leave  
f010520d:	c3                   	ret    

f010520e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010520e:	55                   	push   %ebp
f010520f:	89 e5                	mov    %esp,%ebp
f0105211:	56                   	push   %esi
f0105212:	53                   	push   %ebx
f0105213:	8b 75 08             	mov    0x8(%ebp),%esi
f0105216:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105219:	89 f3                	mov    %esi,%ebx
f010521b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010521e:	89 f0                	mov    %esi,%eax
f0105220:	eb 0f                	jmp    f0105231 <strncpy+0x23>
		*dst++ = *src;
f0105222:	83 c0 01             	add    $0x1,%eax
f0105225:	0f b6 0a             	movzbl (%edx),%ecx
f0105228:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010522b:	80 f9 01             	cmp    $0x1,%cl
f010522e:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0105231:	39 d8                	cmp    %ebx,%eax
f0105233:	75 ed                	jne    f0105222 <strncpy+0x14>
	}
	return ret;
}
f0105235:	89 f0                	mov    %esi,%eax
f0105237:	5b                   	pop    %ebx
f0105238:	5e                   	pop    %esi
f0105239:	5d                   	pop    %ebp
f010523a:	c3                   	ret    

f010523b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010523b:	55                   	push   %ebp
f010523c:	89 e5                	mov    %esp,%ebp
f010523e:	56                   	push   %esi
f010523f:	53                   	push   %ebx
f0105240:	8b 75 08             	mov    0x8(%ebp),%esi
f0105243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105246:	8b 55 10             	mov    0x10(%ebp),%edx
f0105249:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010524b:	85 d2                	test   %edx,%edx
f010524d:	74 21                	je     f0105270 <strlcpy+0x35>
f010524f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105253:	89 f2                	mov    %esi,%edx
f0105255:	eb 09                	jmp    f0105260 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105257:	83 c1 01             	add    $0x1,%ecx
f010525a:	83 c2 01             	add    $0x1,%edx
f010525d:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0105260:	39 c2                	cmp    %eax,%edx
f0105262:	74 09                	je     f010526d <strlcpy+0x32>
f0105264:	0f b6 19             	movzbl (%ecx),%ebx
f0105267:	84 db                	test   %bl,%bl
f0105269:	75 ec                	jne    f0105257 <strlcpy+0x1c>
f010526b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f010526d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105270:	29 f0                	sub    %esi,%eax
}
f0105272:	5b                   	pop    %ebx
f0105273:	5e                   	pop    %esi
f0105274:	5d                   	pop    %ebp
f0105275:	c3                   	ret    

f0105276 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105276:	55                   	push   %ebp
f0105277:	89 e5                	mov    %esp,%ebp
f0105279:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010527c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010527f:	eb 06                	jmp    f0105287 <strcmp+0x11>
		p++, q++;
f0105281:	83 c1 01             	add    $0x1,%ecx
f0105284:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105287:	0f b6 01             	movzbl (%ecx),%eax
f010528a:	84 c0                	test   %al,%al
f010528c:	74 04                	je     f0105292 <strcmp+0x1c>
f010528e:	3a 02                	cmp    (%edx),%al
f0105290:	74 ef                	je     f0105281 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105292:	0f b6 c0             	movzbl %al,%eax
f0105295:	0f b6 12             	movzbl (%edx),%edx
f0105298:	29 d0                	sub    %edx,%eax
}
f010529a:	5d                   	pop    %ebp
f010529b:	c3                   	ret    

f010529c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010529c:	55                   	push   %ebp
f010529d:	89 e5                	mov    %esp,%ebp
f010529f:	53                   	push   %ebx
f01052a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01052a3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052a6:	89 c3                	mov    %eax,%ebx
f01052a8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01052ab:	eb 06                	jmp    f01052b3 <strncmp+0x17>
		n--, p++, q++;
f01052ad:	83 c0 01             	add    $0x1,%eax
f01052b0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01052b3:	39 d8                	cmp    %ebx,%eax
f01052b5:	74 18                	je     f01052cf <strncmp+0x33>
f01052b7:	0f b6 08             	movzbl (%eax),%ecx
f01052ba:	84 c9                	test   %cl,%cl
f01052bc:	74 04                	je     f01052c2 <strncmp+0x26>
f01052be:	3a 0a                	cmp    (%edx),%cl
f01052c0:	74 eb                	je     f01052ad <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01052c2:	0f b6 00             	movzbl (%eax),%eax
f01052c5:	0f b6 12             	movzbl (%edx),%edx
f01052c8:	29 d0                	sub    %edx,%eax
}
f01052ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01052cd:	c9                   	leave  
f01052ce:	c3                   	ret    
		return 0;
f01052cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01052d4:	eb f4                	jmp    f01052ca <strncmp+0x2e>

f01052d6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01052d6:	55                   	push   %ebp
f01052d7:	89 e5                	mov    %esp,%ebp
f01052d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01052dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01052e0:	eb 03                	jmp    f01052e5 <strchr+0xf>
f01052e2:	83 c0 01             	add    $0x1,%eax
f01052e5:	0f b6 10             	movzbl (%eax),%edx
f01052e8:	84 d2                	test   %dl,%dl
f01052ea:	74 06                	je     f01052f2 <strchr+0x1c>
		if (*s == c)
f01052ec:	38 ca                	cmp    %cl,%dl
f01052ee:	75 f2                	jne    f01052e2 <strchr+0xc>
f01052f0:	eb 05                	jmp    f01052f7 <strchr+0x21>
			return (char *) s;
	return 0;
f01052f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01052f7:	5d                   	pop    %ebp
f01052f8:	c3                   	ret    

f01052f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01052f9:	55                   	push   %ebp
f01052fa:	89 e5                	mov    %esp,%ebp
f01052fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01052ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105303:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105306:	38 ca                	cmp    %cl,%dl
f0105308:	74 09                	je     f0105313 <strfind+0x1a>
f010530a:	84 d2                	test   %dl,%dl
f010530c:	74 05                	je     f0105313 <strfind+0x1a>
	for (; *s; s++)
f010530e:	83 c0 01             	add    $0x1,%eax
f0105311:	eb f0                	jmp    f0105303 <strfind+0xa>
			break;
	return (char *) s;
}
f0105313:	5d                   	pop    %ebp
f0105314:	c3                   	ret    

f0105315 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105315:	55                   	push   %ebp
f0105316:	89 e5                	mov    %esp,%ebp
f0105318:	57                   	push   %edi
f0105319:	56                   	push   %esi
f010531a:	53                   	push   %ebx
f010531b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010531e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105321:	85 c9                	test   %ecx,%ecx
f0105323:	74 2f                	je     f0105354 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105325:	89 f8                	mov    %edi,%eax
f0105327:	09 c8                	or     %ecx,%eax
f0105329:	a8 03                	test   $0x3,%al
f010532b:	75 21                	jne    f010534e <memset+0x39>
		c &= 0xFF;
f010532d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105331:	89 d0                	mov    %edx,%eax
f0105333:	c1 e0 08             	shl    $0x8,%eax
f0105336:	89 d3                	mov    %edx,%ebx
f0105338:	c1 e3 18             	shl    $0x18,%ebx
f010533b:	89 d6                	mov    %edx,%esi
f010533d:	c1 e6 10             	shl    $0x10,%esi
f0105340:	09 f3                	or     %esi,%ebx
f0105342:	09 da                	or     %ebx,%edx
f0105344:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105346:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105349:	fc                   	cld    
f010534a:	f3 ab                	rep stos %eax,%es:(%edi)
f010534c:	eb 06                	jmp    f0105354 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010534e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105351:	fc                   	cld    
f0105352:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105354:	89 f8                	mov    %edi,%eax
f0105356:	5b                   	pop    %ebx
f0105357:	5e                   	pop    %esi
f0105358:	5f                   	pop    %edi
f0105359:	5d                   	pop    %ebp
f010535a:	c3                   	ret    

f010535b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010535b:	55                   	push   %ebp
f010535c:	89 e5                	mov    %esp,%ebp
f010535e:	57                   	push   %edi
f010535f:	56                   	push   %esi
f0105360:	8b 45 08             	mov    0x8(%ebp),%eax
f0105363:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105366:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105369:	39 c6                	cmp    %eax,%esi
f010536b:	73 32                	jae    f010539f <memmove+0x44>
f010536d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105370:	39 c2                	cmp    %eax,%edx
f0105372:	76 2b                	jbe    f010539f <memmove+0x44>
		s += n;
		d += n;
f0105374:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105377:	89 d6                	mov    %edx,%esi
f0105379:	09 fe                	or     %edi,%esi
f010537b:	09 ce                	or     %ecx,%esi
f010537d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105383:	75 0e                	jne    f0105393 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105385:	83 ef 04             	sub    $0x4,%edi
f0105388:	8d 72 fc             	lea    -0x4(%edx),%esi
f010538b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010538e:	fd                   	std    
f010538f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105391:	eb 09                	jmp    f010539c <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105393:	83 ef 01             	sub    $0x1,%edi
f0105396:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105399:	fd                   	std    
f010539a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010539c:	fc                   	cld    
f010539d:	eb 1a                	jmp    f01053b9 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010539f:	89 f2                	mov    %esi,%edx
f01053a1:	09 c2                	or     %eax,%edx
f01053a3:	09 ca                	or     %ecx,%edx
f01053a5:	f6 c2 03             	test   $0x3,%dl
f01053a8:	75 0a                	jne    f01053b4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01053aa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01053ad:	89 c7                	mov    %eax,%edi
f01053af:	fc                   	cld    
f01053b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01053b2:	eb 05                	jmp    f01053b9 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f01053b4:	89 c7                	mov    %eax,%edi
f01053b6:	fc                   	cld    
f01053b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01053b9:	5e                   	pop    %esi
f01053ba:	5f                   	pop    %edi
f01053bb:	5d                   	pop    %ebp
f01053bc:	c3                   	ret    

f01053bd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01053bd:	55                   	push   %ebp
f01053be:	89 e5                	mov    %esp,%ebp
f01053c0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01053c3:	ff 75 10             	push   0x10(%ebp)
f01053c6:	ff 75 0c             	push   0xc(%ebp)
f01053c9:	ff 75 08             	push   0x8(%ebp)
f01053cc:	e8 8a ff ff ff       	call   f010535b <memmove>
}
f01053d1:	c9                   	leave  
f01053d2:	c3                   	ret    

f01053d3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01053d3:	55                   	push   %ebp
f01053d4:	89 e5                	mov    %esp,%ebp
f01053d6:	56                   	push   %esi
f01053d7:	53                   	push   %ebx
f01053d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01053db:	8b 55 0c             	mov    0xc(%ebp),%edx
f01053de:	89 c6                	mov    %eax,%esi
f01053e0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01053e3:	eb 06                	jmp    f01053eb <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01053e5:	83 c0 01             	add    $0x1,%eax
f01053e8:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f01053eb:	39 f0                	cmp    %esi,%eax
f01053ed:	74 14                	je     f0105403 <memcmp+0x30>
		if (*s1 != *s2)
f01053ef:	0f b6 08             	movzbl (%eax),%ecx
f01053f2:	0f b6 1a             	movzbl (%edx),%ebx
f01053f5:	38 d9                	cmp    %bl,%cl
f01053f7:	74 ec                	je     f01053e5 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f01053f9:	0f b6 c1             	movzbl %cl,%eax
f01053fc:	0f b6 db             	movzbl %bl,%ebx
f01053ff:	29 d8                	sub    %ebx,%eax
f0105401:	eb 05                	jmp    f0105408 <memcmp+0x35>
	}

	return 0;
f0105403:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105408:	5b                   	pop    %ebx
f0105409:	5e                   	pop    %esi
f010540a:	5d                   	pop    %ebp
f010540b:	c3                   	ret    

f010540c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010540c:	55                   	push   %ebp
f010540d:	89 e5                	mov    %esp,%ebp
f010540f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105412:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105415:	89 c2                	mov    %eax,%edx
f0105417:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010541a:	eb 03                	jmp    f010541f <memfind+0x13>
f010541c:	83 c0 01             	add    $0x1,%eax
f010541f:	39 d0                	cmp    %edx,%eax
f0105421:	73 04                	jae    f0105427 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105423:	38 08                	cmp    %cl,(%eax)
f0105425:	75 f5                	jne    f010541c <memfind+0x10>
			break;
	return (void *) s;
}
f0105427:	5d                   	pop    %ebp
f0105428:	c3                   	ret    

f0105429 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105429:	55                   	push   %ebp
f010542a:	89 e5                	mov    %esp,%ebp
f010542c:	57                   	push   %edi
f010542d:	56                   	push   %esi
f010542e:	53                   	push   %ebx
f010542f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105432:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105435:	eb 03                	jmp    f010543a <strtol+0x11>
		s++;
f0105437:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f010543a:	0f b6 02             	movzbl (%edx),%eax
f010543d:	3c 20                	cmp    $0x20,%al
f010543f:	74 f6                	je     f0105437 <strtol+0xe>
f0105441:	3c 09                	cmp    $0x9,%al
f0105443:	74 f2                	je     f0105437 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105445:	3c 2b                	cmp    $0x2b,%al
f0105447:	74 2a                	je     f0105473 <strtol+0x4a>
	int neg = 0;
f0105449:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010544e:	3c 2d                	cmp    $0x2d,%al
f0105450:	74 2b                	je     f010547d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105452:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105458:	75 0f                	jne    f0105469 <strtol+0x40>
f010545a:	80 3a 30             	cmpb   $0x30,(%edx)
f010545d:	74 28                	je     f0105487 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010545f:	85 db                	test   %ebx,%ebx
f0105461:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105466:	0f 44 d8             	cmove  %eax,%ebx
f0105469:	b9 00 00 00 00       	mov    $0x0,%ecx
f010546e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105471:	eb 46                	jmp    f01054b9 <strtol+0x90>
		s++;
f0105473:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0105476:	bf 00 00 00 00       	mov    $0x0,%edi
f010547b:	eb d5                	jmp    f0105452 <strtol+0x29>
		s++, neg = 1;
f010547d:	83 c2 01             	add    $0x1,%edx
f0105480:	bf 01 00 00 00       	mov    $0x1,%edi
f0105485:	eb cb                	jmp    f0105452 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105487:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010548b:	74 0e                	je     f010549b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f010548d:	85 db                	test   %ebx,%ebx
f010548f:	75 d8                	jne    f0105469 <strtol+0x40>
		s++, base = 8;
f0105491:	83 c2 01             	add    $0x1,%edx
f0105494:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105499:	eb ce                	jmp    f0105469 <strtol+0x40>
		s += 2, base = 16;
f010549b:	83 c2 02             	add    $0x2,%edx
f010549e:	bb 10 00 00 00       	mov    $0x10,%ebx
f01054a3:	eb c4                	jmp    f0105469 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01054a5:	0f be c0             	movsbl %al,%eax
f01054a8:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01054ab:	3b 45 10             	cmp    0x10(%ebp),%eax
f01054ae:	7d 3a                	jge    f01054ea <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01054b0:	83 c2 01             	add    $0x1,%edx
f01054b3:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f01054b7:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f01054b9:	0f b6 02             	movzbl (%edx),%eax
f01054bc:	8d 70 d0             	lea    -0x30(%eax),%esi
f01054bf:	89 f3                	mov    %esi,%ebx
f01054c1:	80 fb 09             	cmp    $0x9,%bl
f01054c4:	76 df                	jbe    f01054a5 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f01054c6:	8d 70 9f             	lea    -0x61(%eax),%esi
f01054c9:	89 f3                	mov    %esi,%ebx
f01054cb:	80 fb 19             	cmp    $0x19,%bl
f01054ce:	77 08                	ja     f01054d8 <strtol+0xaf>
			dig = *s - 'a' + 10;
f01054d0:	0f be c0             	movsbl %al,%eax
f01054d3:	83 e8 57             	sub    $0x57,%eax
f01054d6:	eb d3                	jmp    f01054ab <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f01054d8:	8d 70 bf             	lea    -0x41(%eax),%esi
f01054db:	89 f3                	mov    %esi,%ebx
f01054dd:	80 fb 19             	cmp    $0x19,%bl
f01054e0:	77 08                	ja     f01054ea <strtol+0xc1>
			dig = *s - 'A' + 10;
f01054e2:	0f be c0             	movsbl %al,%eax
f01054e5:	83 e8 37             	sub    $0x37,%eax
f01054e8:	eb c1                	jmp    f01054ab <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f01054ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01054ee:	74 05                	je     f01054f5 <strtol+0xcc>
		*endptr = (char *) s;
f01054f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054f3:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f01054f5:	89 c8                	mov    %ecx,%eax
f01054f7:	f7 d8                	neg    %eax
f01054f9:	85 ff                	test   %edi,%edi
f01054fb:	0f 45 c8             	cmovne %eax,%ecx
}
f01054fe:	89 c8                	mov    %ecx,%eax
f0105500:	5b                   	pop    %ebx
f0105501:	5e                   	pop    %esi
f0105502:	5f                   	pop    %edi
f0105503:	5d                   	pop    %ebp
f0105504:	c3                   	ret    
f0105505:	66 90                	xchg   %ax,%ax
f0105507:	66 90                	xchg   %ax,%ax
f0105509:	66 90                	xchg   %ax,%ax
f010550b:	66 90                	xchg   %ax,%ax
f010550d:	66 90                	xchg   %ax,%ax
f010550f:	90                   	nop

f0105510 <__udivdi3>:
f0105510:	f3 0f 1e fb          	endbr32 
f0105514:	55                   	push   %ebp
f0105515:	57                   	push   %edi
f0105516:	56                   	push   %esi
f0105517:	53                   	push   %ebx
f0105518:	83 ec 1c             	sub    $0x1c,%esp
f010551b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010551f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0105523:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105527:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010552b:	85 c0                	test   %eax,%eax
f010552d:	75 19                	jne    f0105548 <__udivdi3+0x38>
f010552f:	39 f3                	cmp    %esi,%ebx
f0105531:	76 4d                	jbe    f0105580 <__udivdi3+0x70>
f0105533:	31 ff                	xor    %edi,%edi
f0105535:	89 e8                	mov    %ebp,%eax
f0105537:	89 f2                	mov    %esi,%edx
f0105539:	f7 f3                	div    %ebx
f010553b:	89 fa                	mov    %edi,%edx
f010553d:	83 c4 1c             	add    $0x1c,%esp
f0105540:	5b                   	pop    %ebx
f0105541:	5e                   	pop    %esi
f0105542:	5f                   	pop    %edi
f0105543:	5d                   	pop    %ebp
f0105544:	c3                   	ret    
f0105545:	8d 76 00             	lea    0x0(%esi),%esi
f0105548:	39 f0                	cmp    %esi,%eax
f010554a:	76 14                	jbe    f0105560 <__udivdi3+0x50>
f010554c:	31 ff                	xor    %edi,%edi
f010554e:	31 c0                	xor    %eax,%eax
f0105550:	89 fa                	mov    %edi,%edx
f0105552:	83 c4 1c             	add    $0x1c,%esp
f0105555:	5b                   	pop    %ebx
f0105556:	5e                   	pop    %esi
f0105557:	5f                   	pop    %edi
f0105558:	5d                   	pop    %ebp
f0105559:	c3                   	ret    
f010555a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105560:	0f bd f8             	bsr    %eax,%edi
f0105563:	83 f7 1f             	xor    $0x1f,%edi
f0105566:	75 48                	jne    f01055b0 <__udivdi3+0xa0>
f0105568:	39 f0                	cmp    %esi,%eax
f010556a:	72 06                	jb     f0105572 <__udivdi3+0x62>
f010556c:	31 c0                	xor    %eax,%eax
f010556e:	39 eb                	cmp    %ebp,%ebx
f0105570:	77 de                	ja     f0105550 <__udivdi3+0x40>
f0105572:	b8 01 00 00 00       	mov    $0x1,%eax
f0105577:	eb d7                	jmp    f0105550 <__udivdi3+0x40>
f0105579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105580:	89 d9                	mov    %ebx,%ecx
f0105582:	85 db                	test   %ebx,%ebx
f0105584:	75 0b                	jne    f0105591 <__udivdi3+0x81>
f0105586:	b8 01 00 00 00       	mov    $0x1,%eax
f010558b:	31 d2                	xor    %edx,%edx
f010558d:	f7 f3                	div    %ebx
f010558f:	89 c1                	mov    %eax,%ecx
f0105591:	31 d2                	xor    %edx,%edx
f0105593:	89 f0                	mov    %esi,%eax
f0105595:	f7 f1                	div    %ecx
f0105597:	89 c6                	mov    %eax,%esi
f0105599:	89 e8                	mov    %ebp,%eax
f010559b:	89 f7                	mov    %esi,%edi
f010559d:	f7 f1                	div    %ecx
f010559f:	89 fa                	mov    %edi,%edx
f01055a1:	83 c4 1c             	add    $0x1c,%esp
f01055a4:	5b                   	pop    %ebx
f01055a5:	5e                   	pop    %esi
f01055a6:	5f                   	pop    %edi
f01055a7:	5d                   	pop    %ebp
f01055a8:	c3                   	ret    
f01055a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01055b0:	89 f9                	mov    %edi,%ecx
f01055b2:	ba 20 00 00 00       	mov    $0x20,%edx
f01055b7:	29 fa                	sub    %edi,%edx
f01055b9:	d3 e0                	shl    %cl,%eax
f01055bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01055bf:	89 d1                	mov    %edx,%ecx
f01055c1:	89 d8                	mov    %ebx,%eax
f01055c3:	d3 e8                	shr    %cl,%eax
f01055c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01055c9:	09 c1                	or     %eax,%ecx
f01055cb:	89 f0                	mov    %esi,%eax
f01055cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01055d1:	89 f9                	mov    %edi,%ecx
f01055d3:	d3 e3                	shl    %cl,%ebx
f01055d5:	89 d1                	mov    %edx,%ecx
f01055d7:	d3 e8                	shr    %cl,%eax
f01055d9:	89 f9                	mov    %edi,%ecx
f01055db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01055df:	89 eb                	mov    %ebp,%ebx
f01055e1:	d3 e6                	shl    %cl,%esi
f01055e3:	89 d1                	mov    %edx,%ecx
f01055e5:	d3 eb                	shr    %cl,%ebx
f01055e7:	09 f3                	or     %esi,%ebx
f01055e9:	89 c6                	mov    %eax,%esi
f01055eb:	89 f2                	mov    %esi,%edx
f01055ed:	89 d8                	mov    %ebx,%eax
f01055ef:	f7 74 24 08          	divl   0x8(%esp)
f01055f3:	89 d6                	mov    %edx,%esi
f01055f5:	89 c3                	mov    %eax,%ebx
f01055f7:	f7 64 24 0c          	mull   0xc(%esp)
f01055fb:	39 d6                	cmp    %edx,%esi
f01055fd:	72 19                	jb     f0105618 <__udivdi3+0x108>
f01055ff:	89 f9                	mov    %edi,%ecx
f0105601:	d3 e5                	shl    %cl,%ebp
f0105603:	39 c5                	cmp    %eax,%ebp
f0105605:	73 04                	jae    f010560b <__udivdi3+0xfb>
f0105607:	39 d6                	cmp    %edx,%esi
f0105609:	74 0d                	je     f0105618 <__udivdi3+0x108>
f010560b:	89 d8                	mov    %ebx,%eax
f010560d:	31 ff                	xor    %edi,%edi
f010560f:	e9 3c ff ff ff       	jmp    f0105550 <__udivdi3+0x40>
f0105614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105618:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010561b:	31 ff                	xor    %edi,%edi
f010561d:	e9 2e ff ff ff       	jmp    f0105550 <__udivdi3+0x40>
f0105622:	66 90                	xchg   %ax,%ax
f0105624:	66 90                	xchg   %ax,%ax
f0105626:	66 90                	xchg   %ax,%ax
f0105628:	66 90                	xchg   %ax,%ax
f010562a:	66 90                	xchg   %ax,%ax
f010562c:	66 90                	xchg   %ax,%ax
f010562e:	66 90                	xchg   %ax,%ax

f0105630 <__umoddi3>:
f0105630:	f3 0f 1e fb          	endbr32 
f0105634:	55                   	push   %ebp
f0105635:	57                   	push   %edi
f0105636:	56                   	push   %esi
f0105637:	53                   	push   %ebx
f0105638:	83 ec 1c             	sub    $0x1c,%esp
f010563b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010563f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105643:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0105647:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f010564b:	89 f0                	mov    %esi,%eax
f010564d:	89 da                	mov    %ebx,%edx
f010564f:	85 ff                	test   %edi,%edi
f0105651:	75 15                	jne    f0105668 <__umoddi3+0x38>
f0105653:	39 dd                	cmp    %ebx,%ebp
f0105655:	76 39                	jbe    f0105690 <__umoddi3+0x60>
f0105657:	f7 f5                	div    %ebp
f0105659:	89 d0                	mov    %edx,%eax
f010565b:	31 d2                	xor    %edx,%edx
f010565d:	83 c4 1c             	add    $0x1c,%esp
f0105660:	5b                   	pop    %ebx
f0105661:	5e                   	pop    %esi
f0105662:	5f                   	pop    %edi
f0105663:	5d                   	pop    %ebp
f0105664:	c3                   	ret    
f0105665:	8d 76 00             	lea    0x0(%esi),%esi
f0105668:	39 df                	cmp    %ebx,%edi
f010566a:	77 f1                	ja     f010565d <__umoddi3+0x2d>
f010566c:	0f bd cf             	bsr    %edi,%ecx
f010566f:	83 f1 1f             	xor    $0x1f,%ecx
f0105672:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105676:	75 40                	jne    f01056b8 <__umoddi3+0x88>
f0105678:	39 df                	cmp    %ebx,%edi
f010567a:	72 04                	jb     f0105680 <__umoddi3+0x50>
f010567c:	39 f5                	cmp    %esi,%ebp
f010567e:	77 dd                	ja     f010565d <__umoddi3+0x2d>
f0105680:	89 da                	mov    %ebx,%edx
f0105682:	89 f0                	mov    %esi,%eax
f0105684:	29 e8                	sub    %ebp,%eax
f0105686:	19 fa                	sbb    %edi,%edx
f0105688:	eb d3                	jmp    f010565d <__umoddi3+0x2d>
f010568a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105690:	89 e9                	mov    %ebp,%ecx
f0105692:	85 ed                	test   %ebp,%ebp
f0105694:	75 0b                	jne    f01056a1 <__umoddi3+0x71>
f0105696:	b8 01 00 00 00       	mov    $0x1,%eax
f010569b:	31 d2                	xor    %edx,%edx
f010569d:	f7 f5                	div    %ebp
f010569f:	89 c1                	mov    %eax,%ecx
f01056a1:	89 d8                	mov    %ebx,%eax
f01056a3:	31 d2                	xor    %edx,%edx
f01056a5:	f7 f1                	div    %ecx
f01056a7:	89 f0                	mov    %esi,%eax
f01056a9:	f7 f1                	div    %ecx
f01056ab:	89 d0                	mov    %edx,%eax
f01056ad:	31 d2                	xor    %edx,%edx
f01056af:	eb ac                	jmp    f010565d <__umoddi3+0x2d>
f01056b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01056b8:	8b 44 24 04          	mov    0x4(%esp),%eax
f01056bc:	ba 20 00 00 00       	mov    $0x20,%edx
f01056c1:	29 c2                	sub    %eax,%edx
f01056c3:	89 c1                	mov    %eax,%ecx
f01056c5:	89 e8                	mov    %ebp,%eax
f01056c7:	d3 e7                	shl    %cl,%edi
f01056c9:	89 d1                	mov    %edx,%ecx
f01056cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01056cf:	d3 e8                	shr    %cl,%eax
f01056d1:	89 c1                	mov    %eax,%ecx
f01056d3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01056d7:	09 f9                	or     %edi,%ecx
f01056d9:	89 df                	mov    %ebx,%edi
f01056db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01056df:	89 c1                	mov    %eax,%ecx
f01056e1:	d3 e5                	shl    %cl,%ebp
f01056e3:	89 d1                	mov    %edx,%ecx
f01056e5:	d3 ef                	shr    %cl,%edi
f01056e7:	89 c1                	mov    %eax,%ecx
f01056e9:	89 f0                	mov    %esi,%eax
f01056eb:	d3 e3                	shl    %cl,%ebx
f01056ed:	89 d1                	mov    %edx,%ecx
f01056ef:	89 fa                	mov    %edi,%edx
f01056f1:	d3 e8                	shr    %cl,%eax
f01056f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01056f8:	09 d8                	or     %ebx,%eax
f01056fa:	f7 74 24 08          	divl   0x8(%esp)
f01056fe:	89 d3                	mov    %edx,%ebx
f0105700:	d3 e6                	shl    %cl,%esi
f0105702:	f7 e5                	mul    %ebp
f0105704:	89 c7                	mov    %eax,%edi
f0105706:	89 d1                	mov    %edx,%ecx
f0105708:	39 d3                	cmp    %edx,%ebx
f010570a:	72 06                	jb     f0105712 <__umoddi3+0xe2>
f010570c:	75 0e                	jne    f010571c <__umoddi3+0xec>
f010570e:	39 c6                	cmp    %eax,%esi
f0105710:	73 0a                	jae    f010571c <__umoddi3+0xec>
f0105712:	29 e8                	sub    %ebp,%eax
f0105714:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0105718:	89 d1                	mov    %edx,%ecx
f010571a:	89 c7                	mov    %eax,%edi
f010571c:	89 f5                	mov    %esi,%ebp
f010571e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105722:	29 fd                	sub    %edi,%ebp
f0105724:	19 cb                	sbb    %ecx,%ebx
f0105726:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f010572b:	89 d8                	mov    %ebx,%eax
f010572d:	d3 e0                	shl    %cl,%eax
f010572f:	89 f1                	mov    %esi,%ecx
f0105731:	d3 ed                	shr    %cl,%ebp
f0105733:	d3 eb                	shr    %cl,%ebx
f0105735:	09 e8                	or     %ebp,%eax
f0105737:	89 da                	mov    %ebx,%edx
f0105739:	83 c4 1c             	add    $0x1c,%esp
f010573c:	5b                   	pop    %ebx
f010573d:	5e                   	pop    %esi
f010573e:	5f                   	pop    %edi
f010573f:	5d                   	pop    %ebp
f0105740:	c3                   	ret    
