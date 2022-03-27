
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
f0100015:	b8 00 20 18 00       	mov    $0x182000,%eax
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
f0100034:	bc 00 d0 11 f0       	mov    $0xf011d000,%esp

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
f0100047:	e8 5a 01 00 00       	call   f01001a6 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 20 18 08 00    	add    $0x81820,%ebx
	//extern char bootstacktop;
	// cprintf("######stk top 0x%x\n", bootstacktop);
	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 40 48 18 f0    	mov    $0xf0184840,%eax
f0100058:	c7 c2 00 39 18 f0    	mov    $0xf0183900,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 1c 57 00 00       	call   f0105785 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 8e 05 00 00       	call   f01005fc <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 54 43 f8 ff    	lea    -0x7bcac(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 bd 42 00 00       	call   f010433f <cprintf>

	cprintf("######stk top 0x%x\n", bootstacktop);
f0100082:	83 c4 08             	add    $0x8,%esp
f0100085:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f010008b:	8d 83 6f 43 f8 ff    	lea    -0x7bc91(%ebx),%eax
f0100091:	50                   	push   %eax
f0100092:	e8 a8 42 00 00       	call   f010433f <cprintf>
	// Lab 2 memory management initialization functions
	mem_init();
f0100097:	e8 c7 1a 00 00       	call   f0101b63 <mem_init>
	// cprintf("why is make warning\n");
	// Lab 3 user environment initialization functions
	env_init();
f010009c:	e8 36 3a 00 00       	call   f0103ad7 <env_init>
	cprintf("env init done\n");
f01000a1:	8d 83 83 43 f8 ff    	lea    -0x7bc7d(%ebx),%eax
f01000a7:	89 04 24             	mov    %eax,(%esp)
f01000aa:	e8 90 42 00 00       	call   f010433f <cprintf>
	trap_init();
f01000af:	e8 3e 43 00 00       	call   f01043f2 <trap_init>
	cprintf("trap init done\n");
f01000b4:	8d 83 92 43 f8 ff    	lea    -0x7bc6e(%ebx),%eax
f01000ba:	89 04 24             	mov    %eax,(%esp)
f01000bd:	e8 7d 42 00 00       	call   f010433f <cprintf>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_divzero, ENV_TYPE_USER);
f01000c2:	83 c4 08             	add    $0x8,%esp
f01000c5:	6a 00                	push   $0x0
f01000c7:	ff b3 f0 ff ff ff    	push   -0x10(%ebx)
f01000cd:	e8 bd 3c 00 00       	call   f0103d8f <env_create>
#endif // TEST*

	cprintf("env run \n");
f01000d2:	8d 83 a2 43 f8 ff    	lea    -0x7bc5e(%ebx),%eax
f01000d8:	89 04 24             	mov    %eax,(%esp)
f01000db:	e8 5f 42 00 00       	call   f010433f <cprintf>
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000e0:	83 c4 04             	add    $0x4,%esp
f01000e3:	c7 c0 88 3b 18 f0    	mov    $0xf0183b88,%eax
f01000e9:	ff 30                	push   (%eax)
f01000eb:	e8 49 41 00 00       	call   f0104239 <env_run>

f01000f0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f0:	55                   	push   %ebp
f01000f1:	89 e5                	mov    %esp,%ebp
f01000f3:	56                   	push   %esi
f01000f4:	53                   	push   %ebx
f01000f5:	e8 ac 00 00 00       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01000fa:	81 c3 72 17 08 00    	add    $0x81772,%ebx
	va_list ap;

	if (panicstr)
f0100100:	83 bb 94 20 00 00 00 	cmpl   $0x0,0x2094(%ebx)
f0100107:	74 0f                	je     f0100118 <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100109:	83 ec 0c             	sub    $0xc,%esp
f010010c:	6a 00                	push   $0x0
f010010e:	e8 68 0e 00 00       	call   f0100f7b <monitor>
f0100113:	83 c4 10             	add    $0x10,%esp
f0100116:	eb f1                	jmp    f0100109 <_panic+0x19>
	panicstr = fmt;
f0100118:	8b 45 10             	mov    0x10(%ebp),%eax
f010011b:	89 83 94 20 00 00    	mov    %eax,0x2094(%ebx)
	asm volatile("cli; cld");
f0100121:	fa                   	cli    
f0100122:	fc                   	cld    
	va_start(ap, fmt);
f0100123:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100126:	83 ec 04             	sub    $0x4,%esp
f0100129:	ff 75 0c             	push   0xc(%ebp)
f010012c:	ff 75 08             	push   0x8(%ebp)
f010012f:	8d 83 ac 43 f8 ff    	lea    -0x7bc54(%ebx),%eax
f0100135:	50                   	push   %eax
f0100136:	e8 04 42 00 00       	call   f010433f <cprintf>
	vcprintf(fmt, ap);
f010013b:	83 c4 08             	add    $0x8,%esp
f010013e:	56                   	push   %esi
f010013f:	ff 75 10             	push   0x10(%ebp)
f0100142:	e8 c1 41 00 00       	call   f0104308 <vcprintf>
	cprintf("\n");
f0100147:	8d 83 aa 43 f8 ff    	lea    -0x7bc56(%ebx),%eax
f010014d:	89 04 24             	mov    %eax,(%esp)
f0100150:	e8 ea 41 00 00       	call   f010433f <cprintf>
f0100155:	83 c4 10             	add    $0x10,%esp
f0100158:	eb af                	jmp    f0100109 <_panic+0x19>

f010015a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010015a:	55                   	push   %ebp
f010015b:	89 e5                	mov    %esp,%ebp
f010015d:	56                   	push   %esi
f010015e:	53                   	push   %ebx
f010015f:	e8 42 00 00 00       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100164:	81 c3 08 17 08 00    	add    $0x81708,%ebx
	va_list ap;

	va_start(ap, fmt);
f010016a:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010016d:	83 ec 04             	sub    $0x4,%esp
f0100170:	ff 75 0c             	push   0xc(%ebp)
f0100173:	ff 75 08             	push   0x8(%ebp)
f0100176:	8d 83 c4 43 f8 ff    	lea    -0x7bc3c(%ebx),%eax
f010017c:	50                   	push   %eax
f010017d:	e8 bd 41 00 00       	call   f010433f <cprintf>
	vcprintf(fmt, ap);
f0100182:	83 c4 08             	add    $0x8,%esp
f0100185:	56                   	push   %esi
f0100186:	ff 75 10             	push   0x10(%ebp)
f0100189:	e8 7a 41 00 00       	call   f0104308 <vcprintf>
	cprintf("\n");
f010018e:	8d 83 aa 43 f8 ff    	lea    -0x7bc56(%ebx),%eax
f0100194:	89 04 24             	mov    %eax,(%esp)
f0100197:	e8 a3 41 00 00       	call   f010433f <cprintf>
	va_end(ap);
}
f010019c:	83 c4 10             	add    $0x10,%esp
f010019f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001a2:	5b                   	pop    %ebx
f01001a3:	5e                   	pop    %esi
f01001a4:	5d                   	pop    %ebp
f01001a5:	c3                   	ret    

f01001a6 <__x86.get_pc_thunk.bx>:
f01001a6:	8b 1c 24             	mov    (%esp),%ebx
f01001a9:	c3                   	ret    

f01001aa <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001aa:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001af:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001b0:	a8 01                	test   $0x1,%al
f01001b2:	74 0a                	je     f01001be <serial_proc_data+0x14>
f01001b4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001b9:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001ba:	0f b6 c0             	movzbl %al,%eax
f01001bd:	c3                   	ret    
		return -1;
f01001be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001c3:	c3                   	ret    

f01001c4 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001c4:	55                   	push   %ebp
f01001c5:	89 e5                	mov    %esp,%ebp
f01001c7:	57                   	push   %edi
f01001c8:	56                   	push   %esi
f01001c9:	53                   	push   %ebx
f01001ca:	83 ec 1c             	sub    $0x1c,%esp
f01001cd:	e8 6a 05 00 00       	call   f010073c <__x86.get_pc_thunk.si>
f01001d2:	81 c6 9a 16 08 00    	add    $0x8169a,%esi
f01001d8:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001da:	8d 1d d4 20 00 00    	lea    0x20d4,%ebx
f01001e0:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001e6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001e9:	eb 25                	jmp    f0100210 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f01001eb:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f01001f2:	8d 51 01             	lea    0x1(%ecx),%edx
f01001f5:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01001f8:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001fb:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100201:	b8 00 00 00 00       	mov    $0x0,%eax
f0100206:	0f 44 d0             	cmove  %eax,%edx
f0100209:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f0100210:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100213:	ff d0                	call   *%eax
f0100215:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100218:	74 06                	je     f0100220 <cons_intr+0x5c>
		if (c == 0)
f010021a:	85 c0                	test   %eax,%eax
f010021c:	75 cd                	jne    f01001eb <cons_intr+0x27>
f010021e:	eb f0                	jmp    f0100210 <cons_intr+0x4c>
	}
}
f0100220:	83 c4 1c             	add    $0x1c,%esp
f0100223:	5b                   	pop    %ebx
f0100224:	5e                   	pop    %esi
f0100225:	5f                   	pop    %edi
f0100226:	5d                   	pop    %ebp
f0100227:	c3                   	ret    

f0100228 <kbd_proc_data>:
{
f0100228:	55                   	push   %ebp
f0100229:	89 e5                	mov    %esp,%ebp
f010022b:	56                   	push   %esi
f010022c:	53                   	push   %ebx
f010022d:	e8 74 ff ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100232:	81 c3 3a 16 08 00    	add    $0x8163a,%ebx
f0100238:	ba 64 00 00 00       	mov    $0x64,%edx
f010023d:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010023e:	a8 01                	test   $0x1,%al
f0100240:	0f 84 f7 00 00 00    	je     f010033d <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f0100246:	a8 20                	test   $0x20,%al
f0100248:	0f 85 f6 00 00 00    	jne    f0100344 <kbd_proc_data+0x11c>
f010024e:	ba 60 00 00 00       	mov    $0x60,%edx
f0100253:	ec                   	in     (%dx),%al
f0100254:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100256:	3c e0                	cmp    $0xe0,%al
f0100258:	74 64                	je     f01002be <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f010025a:	84 c0                	test   %al,%al
f010025c:	78 75                	js     f01002d3 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f010025e:	8b 8b b4 20 00 00    	mov    0x20b4(%ebx),%ecx
f0100264:	f6 c1 40             	test   $0x40,%cl
f0100267:	74 0e                	je     f0100277 <kbd_proc_data+0x4f>
		data |= 0x80;
f0100269:	83 c8 80             	or     $0xffffff80,%eax
f010026c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010026e:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100271:	89 8b b4 20 00 00    	mov    %ecx,0x20b4(%ebx)
	shift |= shiftcode[data];
f0100277:	0f b6 d2             	movzbl %dl,%edx
f010027a:	0f b6 84 13 14 45 f8 	movzbl -0x7baec(%ebx,%edx,1),%eax
f0100281:	ff 
f0100282:	0b 83 b4 20 00 00    	or     0x20b4(%ebx),%eax
	shift ^= togglecode[data];
f0100288:	0f b6 8c 13 14 44 f8 	movzbl -0x7bbec(%ebx,%edx,1),%ecx
f010028f:	ff 
f0100290:	31 c8                	xor    %ecx,%eax
f0100292:	89 83 b4 20 00 00    	mov    %eax,0x20b4(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100298:	89 c1                	mov    %eax,%ecx
f010029a:	83 e1 03             	and    $0x3,%ecx
f010029d:	8b 8c 8b b4 17 00 00 	mov    0x17b4(%ebx,%ecx,4),%ecx
f01002a4:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002a8:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002ab:	a8 08                	test   $0x8,%al
f01002ad:	74 61                	je     f0100310 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f01002af:	89 f2                	mov    %esi,%edx
f01002b1:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002b4:	83 f9 19             	cmp    $0x19,%ecx
f01002b7:	77 4b                	ja     f0100304 <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f01002b9:	83 ee 20             	sub    $0x20,%esi
f01002bc:	eb 0c                	jmp    f01002ca <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002be:	83 8b b4 20 00 00 40 	orl    $0x40,0x20b4(%ebx)
		return 0;
f01002c5:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002ca:	89 f0                	mov    %esi,%eax
f01002cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002cf:	5b                   	pop    %ebx
f01002d0:	5e                   	pop    %esi
f01002d1:	5d                   	pop    %ebp
f01002d2:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002d3:	8b 8b b4 20 00 00    	mov    0x20b4(%ebx),%ecx
f01002d9:	83 e0 7f             	and    $0x7f,%eax
f01002dc:	f6 c1 40             	test   $0x40,%cl
f01002df:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002e2:	0f b6 d2             	movzbl %dl,%edx
f01002e5:	0f b6 84 13 14 45 f8 	movzbl -0x7baec(%ebx,%edx,1),%eax
f01002ec:	ff 
f01002ed:	83 c8 40             	or     $0x40,%eax
f01002f0:	0f b6 c0             	movzbl %al,%eax
f01002f3:	f7 d0                	not    %eax
f01002f5:	21 c8                	and    %ecx,%eax
f01002f7:	89 83 b4 20 00 00    	mov    %eax,0x20b4(%ebx)
		return 0;
f01002fd:	be 00 00 00 00       	mov    $0x0,%esi
f0100302:	eb c6                	jmp    f01002ca <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f0100304:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100307:	8d 4e 20             	lea    0x20(%esi),%ecx
f010030a:	83 fa 1a             	cmp    $0x1a,%edx
f010030d:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100310:	f7 d0                	not    %eax
f0100312:	a8 06                	test   $0x6,%al
f0100314:	75 b4                	jne    f01002ca <kbd_proc_data+0xa2>
f0100316:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010031c:	75 ac                	jne    f01002ca <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f010031e:	83 ec 0c             	sub    $0xc,%esp
f0100321:	8d 83 de 43 f8 ff    	lea    -0x7bc22(%ebx),%eax
f0100327:	50                   	push   %eax
f0100328:	e8 12 40 00 00       	call   f010433f <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100332:	ba 92 00 00 00       	mov    $0x92,%edx
f0100337:	ee                   	out    %al,(%dx)
}
f0100338:	83 c4 10             	add    $0x10,%esp
f010033b:	eb 8d                	jmp    f01002ca <kbd_proc_data+0xa2>
		return -1;
f010033d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100342:	eb 86                	jmp    f01002ca <kbd_proc_data+0xa2>
		return -1;
f0100344:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100349:	e9 7c ff ff ff       	jmp    f01002ca <kbd_proc_data+0xa2>

f010034e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010034e:	55                   	push   %ebp
f010034f:	89 e5                	mov    %esp,%ebp
f0100351:	57                   	push   %edi
f0100352:	56                   	push   %esi
f0100353:	53                   	push   %ebx
f0100354:	83 ec 1c             	sub    $0x1c,%esp
f0100357:	e8 4a fe ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f010035c:	81 c3 10 15 08 00    	add    $0x81510,%ebx
f0100362:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100365:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010036a:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010036f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100374:	89 fa                	mov    %edi,%edx
f0100376:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100377:	a8 20                	test   $0x20,%al
f0100379:	75 13                	jne    f010038e <cons_putc+0x40>
f010037b:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100381:	7f 0b                	jg     f010038e <cons_putc+0x40>
f0100383:	89 ca                	mov    %ecx,%edx
f0100385:	ec                   	in     (%dx),%al
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
	     i++)
f0100389:	83 c6 01             	add    $0x1,%esi
f010038c:	eb e6                	jmp    f0100374 <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f010038e:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100392:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100395:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010039a:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010039b:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a0:	bf 79 03 00 00       	mov    $0x379,%edi
f01003a5:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003aa:	89 fa                	mov    %edi,%edx
f01003ac:	ec                   	in     (%dx),%al
f01003ad:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003b3:	7f 0f                	jg     f01003c4 <cons_putc+0x76>
f01003b5:	84 c0                	test   %al,%al
f01003b7:	78 0b                	js     f01003c4 <cons_putc+0x76>
f01003b9:	89 ca                	mov    %ecx,%edx
f01003bb:	ec                   	in     (%dx),%al
f01003bc:	ec                   	in     (%dx),%al
f01003bd:	ec                   	in     (%dx),%al
f01003be:	ec                   	in     (%dx),%al
f01003bf:	83 c6 01             	add    $0x1,%esi
f01003c2:	eb e6                	jmp    f01003aa <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c4:	ba 78 03 00 00       	mov    $0x378,%edx
f01003c9:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003cd:	ee                   	out    %al,(%dx)
f01003ce:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003d3:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003d8:	ee                   	out    %al,(%dx)
f01003d9:	b8 08 00 00 00       	mov    $0x8,%eax
f01003de:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003e2:	89 f8                	mov    %edi,%eax
f01003e4:	80 cc 07             	or     $0x7,%ah
f01003e7:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003ed:	0f 45 c7             	cmovne %edi,%eax
f01003f0:	89 c7                	mov    %eax,%edi
f01003f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003f5:	0f b6 c0             	movzbl %al,%eax
f01003f8:	89 f9                	mov    %edi,%ecx
f01003fa:	80 f9 0a             	cmp    $0xa,%cl
f01003fd:	0f 84 e4 00 00 00    	je     f01004e7 <cons_putc+0x199>
f0100403:	83 f8 0a             	cmp    $0xa,%eax
f0100406:	7f 46                	jg     f010044e <cons_putc+0x100>
f0100408:	83 f8 08             	cmp    $0x8,%eax
f010040b:	0f 84 a8 00 00 00    	je     f01004b9 <cons_putc+0x16b>
f0100411:	83 f8 09             	cmp    $0x9,%eax
f0100414:	0f 85 da 00 00 00    	jne    f01004f4 <cons_putc+0x1a6>
		cons_putc(' ');
f010041a:	b8 20 00 00 00       	mov    $0x20,%eax
f010041f:	e8 2a ff ff ff       	call   f010034e <cons_putc>
		cons_putc(' ');
f0100424:	b8 20 00 00 00       	mov    $0x20,%eax
f0100429:	e8 20 ff ff ff       	call   f010034e <cons_putc>
		cons_putc(' ');
f010042e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100433:	e8 16 ff ff ff       	call   f010034e <cons_putc>
		cons_putc(' ');
f0100438:	b8 20 00 00 00       	mov    $0x20,%eax
f010043d:	e8 0c ff ff ff       	call   f010034e <cons_putc>
		cons_putc(' ');
f0100442:	b8 20 00 00 00       	mov    $0x20,%eax
f0100447:	e8 02 ff ff ff       	call   f010034e <cons_putc>
		break;
f010044c:	eb 26                	jmp    f0100474 <cons_putc+0x126>
	switch (c & 0xff) {
f010044e:	83 f8 0d             	cmp    $0xd,%eax
f0100451:	0f 85 9d 00 00 00    	jne    f01004f4 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100457:	0f b7 83 dc 22 00 00 	movzwl 0x22dc(%ebx),%eax
f010045e:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100464:	c1 e8 16             	shr    $0x16,%eax
f0100467:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010046a:	c1 e0 04             	shl    $0x4,%eax
f010046d:	66 89 83 dc 22 00 00 	mov    %ax,0x22dc(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100474:	66 81 bb dc 22 00 00 	cmpw   $0x7cf,0x22dc(%ebx)
f010047b:	cf 07 
f010047d:	0f 87 98 00 00 00    	ja     f010051b <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100483:	8b 8b e4 22 00 00    	mov    0x22e4(%ebx),%ecx
f0100489:	b8 0e 00 00 00       	mov    $0xe,%eax
f010048e:	89 ca                	mov    %ecx,%edx
f0100490:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100491:	0f b7 9b dc 22 00 00 	movzwl 0x22dc(%ebx),%ebx
f0100498:	8d 71 01             	lea    0x1(%ecx),%esi
f010049b:	89 d8                	mov    %ebx,%eax
f010049d:	66 c1 e8 08          	shr    $0x8,%ax
f01004a1:	89 f2                	mov    %esi,%edx
f01004a3:	ee                   	out    %al,(%dx)
f01004a4:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004a9:	89 ca                	mov    %ecx,%edx
f01004ab:	ee                   	out    %al,(%dx)
f01004ac:	89 d8                	mov    %ebx,%eax
f01004ae:	89 f2                	mov    %esi,%edx
f01004b0:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004b4:	5b                   	pop    %ebx
f01004b5:	5e                   	pop    %esi
f01004b6:	5f                   	pop    %edi
f01004b7:	5d                   	pop    %ebp
f01004b8:	c3                   	ret    
		if (crt_pos > 0) {
f01004b9:	0f b7 83 dc 22 00 00 	movzwl 0x22dc(%ebx),%eax
f01004c0:	66 85 c0             	test   %ax,%ax
f01004c3:	74 be                	je     f0100483 <cons_putc+0x135>
			crt_pos--;
f01004c5:	83 e8 01             	sub    $0x1,%eax
f01004c8:	66 89 83 dc 22 00 00 	mov    %ax,0x22dc(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004cf:	0f b7 c0             	movzwl %ax,%eax
f01004d2:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004d6:	b2 00                	mov    $0x0,%dl
f01004d8:	83 ca 20             	or     $0x20,%edx
f01004db:	8b 8b e0 22 00 00    	mov    0x22e0(%ebx),%ecx
f01004e1:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004e5:	eb 8d                	jmp    f0100474 <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004e7:	66 83 83 dc 22 00 00 	addw   $0x50,0x22dc(%ebx)
f01004ee:	50 
f01004ef:	e9 63 ff ff ff       	jmp    f0100457 <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004f4:	0f b7 83 dc 22 00 00 	movzwl 0x22dc(%ebx),%eax
f01004fb:	8d 50 01             	lea    0x1(%eax),%edx
f01004fe:	66 89 93 dc 22 00 00 	mov    %dx,0x22dc(%ebx)
f0100505:	0f b7 c0             	movzwl %ax,%eax
f0100508:	8b 93 e0 22 00 00    	mov    0x22e0(%ebx),%edx
f010050e:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100512:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100516:	e9 59 ff ff ff       	jmp    f0100474 <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010051b:	8b 83 e0 22 00 00    	mov    0x22e0(%ebx),%eax
f0100521:	83 ec 04             	sub    $0x4,%esp
f0100524:	68 00 0f 00 00       	push   $0xf00
f0100529:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010052f:	52                   	push   %edx
f0100530:	50                   	push   %eax
f0100531:	e8 95 52 00 00       	call   f01057cb <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100536:	8b 93 e0 22 00 00    	mov    0x22e0(%ebx),%edx
f010053c:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100542:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100548:	83 c4 10             	add    $0x10,%esp
f010054b:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100550:	83 c0 02             	add    $0x2,%eax
f0100553:	39 d0                	cmp    %edx,%eax
f0100555:	75 f4                	jne    f010054b <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100557:	66 83 ab dc 22 00 00 	subw   $0x50,0x22dc(%ebx)
f010055e:	50 
f010055f:	e9 1f ff ff ff       	jmp    f0100483 <cons_putc+0x135>

f0100564 <serial_intr>:
{
f0100564:	e8 cf 01 00 00       	call   f0100738 <__x86.get_pc_thunk.ax>
f0100569:	05 03 13 08 00       	add    $0x81303,%eax
	if (serial_exists)
f010056e:	80 b8 e8 22 00 00 00 	cmpb   $0x0,0x22e8(%eax)
f0100575:	75 01                	jne    f0100578 <serial_intr+0x14>
f0100577:	c3                   	ret    
{
f0100578:	55                   	push   %ebp
f0100579:	89 e5                	mov    %esp,%ebp
f010057b:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010057e:	8d 80 3e e9 f7 ff    	lea    -0x816c2(%eax),%eax
f0100584:	e8 3b fc ff ff       	call   f01001c4 <cons_intr>
}
f0100589:	c9                   	leave  
f010058a:	c3                   	ret    

f010058b <kbd_intr>:
{
f010058b:	55                   	push   %ebp
f010058c:	89 e5                	mov    %esp,%ebp
f010058e:	83 ec 08             	sub    $0x8,%esp
f0100591:	e8 a2 01 00 00       	call   f0100738 <__x86.get_pc_thunk.ax>
f0100596:	05 d6 12 08 00       	add    $0x812d6,%eax
	cons_intr(kbd_proc_data);
f010059b:	8d 80 bc e9 f7 ff    	lea    -0x81644(%eax),%eax
f01005a1:	e8 1e fc ff ff       	call   f01001c4 <cons_intr>
}
f01005a6:	c9                   	leave  
f01005a7:	c3                   	ret    

f01005a8 <cons_getc>:
{
f01005a8:	55                   	push   %ebp
f01005a9:	89 e5                	mov    %esp,%ebp
f01005ab:	53                   	push   %ebx
f01005ac:	83 ec 04             	sub    $0x4,%esp
f01005af:	e8 f2 fb ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01005b4:	81 c3 b8 12 08 00    	add    $0x812b8,%ebx
	serial_intr();
f01005ba:	e8 a5 ff ff ff       	call   f0100564 <serial_intr>
	kbd_intr();
f01005bf:	e8 c7 ff ff ff       	call   f010058b <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005c4:	8b 83 d4 22 00 00    	mov    0x22d4(%ebx),%eax
	return 0;
f01005ca:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005cf:	3b 83 d8 22 00 00    	cmp    0x22d8(%ebx),%eax
f01005d5:	74 1e                	je     f01005f5 <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f01005d7:	8d 48 01             	lea    0x1(%eax),%ecx
f01005da:	0f b6 94 03 d4 20 00 	movzbl 0x20d4(%ebx,%eax,1),%edx
f01005e1:	00 
			cons.rpos = 0;
f01005e2:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ec:	0f 45 c1             	cmovne %ecx,%eax
f01005ef:	89 83 d4 22 00 00    	mov    %eax,0x22d4(%ebx)
}
f01005f5:	89 d0                	mov    %edx,%eax
f01005f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01005fa:	c9                   	leave  
f01005fb:	c3                   	ret    

f01005fc <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005fc:	55                   	push   %ebp
f01005fd:	89 e5                	mov    %esp,%ebp
f01005ff:	57                   	push   %edi
f0100600:	56                   	push   %esi
f0100601:	53                   	push   %ebx
f0100602:	83 ec 1c             	sub    $0x1c,%esp
f0100605:	e8 9c fb ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f010060a:	81 c3 62 12 08 00    	add    $0x81262,%ebx
	was = *cp;
f0100610:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100617:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010061e:	5a a5 
	if (*cp != 0xA55A) {
f0100620:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100627:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010062c:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f0100631:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100635:	0f 84 ac 00 00 00    	je     f01006e7 <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f010063b:	89 8b e4 22 00 00    	mov    %ecx,0x22e4(%ebx)
f0100641:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100646:	89 ca                	mov    %ecx,%edx
f0100648:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100649:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010064c:	89 f2                	mov    %esi,%edx
f010064e:	ec                   	in     (%dx),%al
f010064f:	0f b6 c0             	movzbl %al,%eax
f0100652:	c1 e0 08             	shl    $0x8,%eax
f0100655:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100658:	b8 0f 00 00 00       	mov    $0xf,%eax
f010065d:	89 ca                	mov    %ecx,%edx
f010065f:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100660:	89 f2                	mov    %esi,%edx
f0100662:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100663:	89 bb e0 22 00 00    	mov    %edi,0x22e0(%ebx)
	pos |= inb(addr_6845 + 1);
f0100669:	0f b6 c0             	movzbl %al,%eax
f010066c:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f010066f:	66 89 83 dc 22 00 00 	mov    %ax,0x22dc(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100676:	b9 00 00 00 00       	mov    $0x0,%ecx
f010067b:	89 c8                	mov    %ecx,%eax
f010067d:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100682:	ee                   	out    %al,(%dx)
f0100683:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100688:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010068d:	89 fa                	mov    %edi,%edx
f010068f:	ee                   	out    %al,(%dx)
f0100690:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100695:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010069a:	ee                   	out    %al,(%dx)
f010069b:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006a0:	89 c8                	mov    %ecx,%eax
f01006a2:	89 f2                	mov    %esi,%edx
f01006a4:	ee                   	out    %al,(%dx)
f01006a5:	b8 03 00 00 00       	mov    $0x3,%eax
f01006aa:	89 fa                	mov    %edi,%edx
f01006ac:	ee                   	out    %al,(%dx)
f01006ad:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006b2:	89 c8                	mov    %ecx,%eax
f01006b4:	ee                   	out    %al,(%dx)
f01006b5:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ba:	89 f2                	mov    %esi,%edx
f01006bc:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006bd:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006c2:	ec                   	in     (%dx),%al
f01006c3:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006c5:	3c ff                	cmp    $0xff,%al
f01006c7:	0f 95 83 e8 22 00 00 	setne  0x22e8(%ebx)
f01006ce:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006d3:	ec                   	in     (%dx),%al
f01006d4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006d9:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006da:	80 f9 ff             	cmp    $0xff,%cl
f01006dd:	74 1e                	je     f01006fd <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006df:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006e2:	5b                   	pop    %ebx
f01006e3:	5e                   	pop    %esi
f01006e4:	5f                   	pop    %edi
f01006e5:	5d                   	pop    %ebp
f01006e6:	c3                   	ret    
		*cp = was;
f01006e7:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f01006ee:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006f3:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f01006f8:	e9 3e ff ff ff       	jmp    f010063b <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f01006fd:	83 ec 0c             	sub    $0xc,%esp
f0100700:	8d 83 ea 43 f8 ff    	lea    -0x7bc16(%ebx),%eax
f0100706:	50                   	push   %eax
f0100707:	e8 33 3c 00 00       	call   f010433f <cprintf>
f010070c:	83 c4 10             	add    $0x10,%esp
}
f010070f:	eb ce                	jmp    f01006df <cons_init+0xe3>

f0100711 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100711:	55                   	push   %ebp
f0100712:	89 e5                	mov    %esp,%ebp
f0100714:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100717:	8b 45 08             	mov    0x8(%ebp),%eax
f010071a:	e8 2f fc ff ff       	call   f010034e <cons_putc>
}
f010071f:	c9                   	leave  
f0100720:	c3                   	ret    

f0100721 <getchar>:

int
getchar(void)
{
f0100721:	55                   	push   %ebp
f0100722:	89 e5                	mov    %esp,%ebp
f0100724:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100727:	e8 7c fe ff ff       	call   f01005a8 <cons_getc>
f010072c:	85 c0                	test   %eax,%eax
f010072e:	74 f7                	je     f0100727 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100730:	c9                   	leave  
f0100731:	c3                   	ret    

f0100732 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100732:	b8 01 00 00 00       	mov    $0x1,%eax
f0100737:	c3                   	ret    

f0100738 <__x86.get_pc_thunk.ax>:
f0100738:	8b 04 24             	mov    (%esp),%eax
f010073b:	c3                   	ret    

f010073c <__x86.get_pc_thunk.si>:
f010073c:	8b 34 24             	mov    (%esp),%esi
f010073f:	c3                   	ret    

f0100740 <mon_help>:
struct Eipdebuginfo eipinfo;
/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100740:	55                   	push   %ebp
f0100741:	89 e5                	mov    %esp,%ebp
f0100743:	56                   	push   %esi
f0100744:	53                   	push   %ebx
f0100745:	e8 5c fa ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f010074a:	81 c3 22 11 08 00    	add    $0x81122,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100750:	83 ec 04             	sub    $0x4,%esp
f0100753:	8d 83 14 46 f8 ff    	lea    -0x7b9ec(%ebx),%eax
f0100759:	50                   	push   %eax
f010075a:	8d 83 32 46 f8 ff    	lea    -0x7b9ce(%ebx),%eax
f0100760:	50                   	push   %eax
f0100761:	8d b3 37 46 f8 ff    	lea    -0x7b9c9(%ebx),%esi
f0100767:	56                   	push   %esi
f0100768:	e8 d2 3b 00 00       	call   f010433f <cprintf>
f010076d:	83 c4 0c             	add    $0xc,%esp
f0100770:	8d 83 00 48 f8 ff    	lea    -0x7b800(%ebx),%eax
f0100776:	50                   	push   %eax
f0100777:	8d 83 40 46 f8 ff    	lea    -0x7b9c0(%ebx),%eax
f010077d:	50                   	push   %eax
f010077e:	56                   	push   %esi
f010077f:	e8 bb 3b 00 00       	call   f010433f <cprintf>
f0100784:	83 c4 0c             	add    $0xc,%esp
f0100787:	8d 83 28 48 f8 ff    	lea    -0x7b7d8(%ebx),%eax
f010078d:	50                   	push   %eax
f010078e:	8d 83 49 46 f8 ff    	lea    -0x7b9b7(%ebx),%eax
f0100794:	50                   	push   %eax
f0100795:	56                   	push   %esi
f0100796:	e8 a4 3b 00 00       	call   f010433f <cprintf>
f010079b:	83 c4 0c             	add    $0xc,%esp
f010079e:	8d 83 53 46 f8 ff    	lea    -0x7b9ad(%ebx),%eax
f01007a4:	50                   	push   %eax
f01007a5:	8d 83 38 5a f8 ff    	lea    -0x7a5c8(%ebx),%eax
f01007ab:	50                   	push   %eax
f01007ac:	56                   	push   %esi
f01007ad:	e8 8d 3b 00 00       	call   f010433f <cprintf>
	return 0;
}
f01007b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007ba:	5b                   	pop    %ebx
f01007bb:	5e                   	pop    %esi
f01007bc:	5d                   	pop    %ebp
f01007bd:	c3                   	ret    

f01007be <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007be:	55                   	push   %ebp
f01007bf:	89 e5                	mov    %esp,%ebp
f01007c1:	57                   	push   %edi
f01007c2:	56                   	push   %esi
f01007c3:	53                   	push   %ebx
f01007c4:	83 ec 18             	sub    $0x18,%esp
f01007c7:	e8 da f9 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01007cc:	81 c3 a0 10 08 00    	add    $0x810a0,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d2:	8d 83 58 46 f8 ff    	lea    -0x7b9a8(%ebx),%eax
f01007d8:	50                   	push   %eax
f01007d9:	e8 61 3b 00 00       	call   f010433f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007de:	83 c4 08             	add    $0x8,%esp
f01007e1:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f01007e7:	8d 83 4c 48 f8 ff    	lea    -0x7b7b4(%ebx),%eax
f01007ed:	50                   	push   %eax
f01007ee:	e8 4c 3b 00 00       	call   f010433f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f3:	83 c4 0c             	add    $0xc,%esp
f01007f6:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007fc:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100802:	50                   	push   %eax
f0100803:	57                   	push   %edi
f0100804:	8d 83 74 48 f8 ff    	lea    -0x7b78c(%ebx),%eax
f010080a:	50                   	push   %eax
f010080b:	e8 2f 3b 00 00       	call   f010433f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100810:	83 c4 0c             	add    $0xc,%esp
f0100813:	c7 c0 b1 5b 10 f0    	mov    $0xf0105bb1,%eax
f0100819:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010081f:	52                   	push   %edx
f0100820:	50                   	push   %eax
f0100821:	8d 83 98 48 f8 ff    	lea    -0x7b768(%ebx),%eax
f0100827:	50                   	push   %eax
f0100828:	e8 12 3b 00 00       	call   f010433f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082d:	83 c4 0c             	add    $0xc,%esp
f0100830:	c7 c0 00 39 18 f0    	mov    $0xf0183900,%eax
f0100836:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010083c:	52                   	push   %edx
f010083d:	50                   	push   %eax
f010083e:	8d 83 bc 48 f8 ff    	lea    -0x7b744(%ebx),%eax
f0100844:	50                   	push   %eax
f0100845:	e8 f5 3a 00 00       	call   f010433f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010084a:	83 c4 0c             	add    $0xc,%esp
f010084d:	c7 c6 40 48 18 f0    	mov    $0xf0184840,%esi
f0100853:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100859:	50                   	push   %eax
f010085a:	56                   	push   %esi
f010085b:	8d 83 e0 48 f8 ff    	lea    -0x7b720(%ebx),%eax
f0100861:	50                   	push   %eax
f0100862:	e8 d8 3a 00 00       	call   f010433f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100867:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010086a:	29 fe                	sub    %edi,%esi
f010086c:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100872:	c1 fe 0a             	sar    $0xa,%esi
f0100875:	56                   	push   %esi
f0100876:	8d 83 04 49 f8 ff    	lea    -0x7b6fc(%ebx),%eax
f010087c:	50                   	push   %eax
f010087d:	e8 bd 3a 00 00       	call   f010433f <cprintf>
	return 0;
}
f0100882:	b8 00 00 00 00       	mov    $0x0,%eax
f0100887:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010088a:	5b                   	pop    %ebx
f010088b:	5e                   	pop    %esi
f010088c:	5f                   	pop    %edi
f010088d:	5d                   	pop    %ebp
f010088e:	c3                   	ret    

f010088f <test_cmd>:


/*******************My Debug Command********************/

int test_cmd(int a, int b)
{
f010088f:	55                   	push   %ebp
f0100890:	89 e5                	mov    %esp,%ebp
f0100892:	53                   	push   %ebx
f0100893:	83 ec 0c             	sub    $0xc,%esp
f0100896:	e8 0b f9 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f010089b:	81 c3 d1 0f 08 00    	add    $0x80fd1,%ebx
	cprintf("a+b=%d\n", a+b);
f01008a1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01008a4:	03 45 08             	add    0x8(%ebp),%eax
f01008a7:	50                   	push   %eax
f01008a8:	8d 83 71 46 f8 ff    	lea    -0x7b98f(%ebx),%eax
f01008ae:	50                   	push   %eax
f01008af:	e8 8b 3a 00 00       	call   f010433f <cprintf>
	return 0;
}
f01008b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01008bc:	c9                   	leave  
f01008bd:	c3                   	ret    

f01008be <mon_backtrace>:
{
f01008be:	55                   	push   %ebp
f01008bf:	89 e5                	mov    %esp,%ebp
f01008c1:	57                   	push   %edi
f01008c2:	56                   	push   %esi
f01008c3:	53                   	push   %ebx
f01008c4:	83 ec 28             	sub    $0x28,%esp
f01008c7:	e8 da f8 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01008cc:	81 c3 a0 0f 08 00    	add    $0x80fa0,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008d2:	89 e8                	mov    %ebp,%eax
	int *ebp_ptr = (int*)ebp_val;
f01008d4:	89 c7                	mov    %eax,%edi
	cprintf("Stack backtrace:\n");
f01008d6:	8d 83 79 46 f8 ff    	lea    -0x7b987(%ebx),%eax
f01008dc:	50                   	push   %eax
f01008dd:	e8 5d 3a 00 00       	call   f010433f <cprintf>
f01008e2:	83 c4 10             	add    $0x10,%esp
		debuginfo_eip(eip_val, &eipinfo);
f01008e5:	8d 83 ec 22 00 00    	lea    0x22ec(%ebx),%eax
f01008eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		cprintf("ebp %08x eip %08x  ", ebp_val, eip_val);
f01008ee:	8d 83 8b 46 f8 ff    	lea    -0x7b975(%ebx),%eax
f01008f4:	89 45 dc             	mov    %eax,-0x24(%ebp)
		ebp_val = *ebp_ptr;
f01008f7:	8b 37                	mov    (%edi),%esi
		eip_val = *(ebp_ptr+1);
f01008f9:	8b 47 04             	mov    0x4(%edi),%eax
		debuginfo_eip(eip_val, &eipinfo);
f01008fc:	83 ec 08             	sub    $0x8,%esp
f01008ff:	ff 75 e0             	push   -0x20(%ebp)
f0100902:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100905:	50                   	push   %eax
f0100906:	e8 21 44 00 00       	call   f0104d2c <debuginfo_eip>
		cprintf("ebp %08x eip %08x  ", ebp_val, eip_val);
f010090b:	83 c4 0c             	add    $0xc,%esp
f010090e:	ff 75 e4             	push   -0x1c(%ebp)
f0100911:	56                   	push   %esi
f0100912:	ff 75 dc             	push   -0x24(%ebp)
f0100915:	e8 25 3a 00 00       	call   f010433f <cprintf>
		cprintf("args %08x", *(ebp_ptr+2));
f010091a:	83 c4 08             	add    $0x8,%esp
f010091d:	ff 77 08             	push   0x8(%edi)
f0100920:	8d 83 9f 46 f8 ff    	lea    -0x7b961(%ebx),%eax
f0100926:	50                   	push   %eax
f0100927:	e8 13 3a 00 00       	call   f010433f <cprintf>
		cprintf(" %08x", *(ebp_ptr+3));
f010092c:	83 c4 08             	add    $0x8,%esp
f010092f:	ff 77 0c             	push   0xc(%edi)
f0100932:	8d b3 a3 46 f8 ff    	lea    -0x7b95d(%ebx),%esi
f0100938:	56                   	push   %esi
f0100939:	e8 01 3a 00 00       	call   f010433f <cprintf>
		cprintf(" %08x", *(ebp_ptr+4));
f010093e:	83 c4 08             	add    $0x8,%esp
f0100941:	ff 77 10             	push   0x10(%edi)
f0100944:	56                   	push   %esi
f0100945:	e8 f5 39 00 00       	call   f010433f <cprintf>
		cprintf(" %08x", *(ebp_ptr+5));
f010094a:	83 c4 08             	add    $0x8,%esp
f010094d:	ff 77 14             	push   0x14(%edi)
f0100950:	56                   	push   %esi
f0100951:	e8 e9 39 00 00       	call   f010433f <cprintf>
		cprintf(" %08x\n", *(ebp_ptr+6));
f0100956:	83 c4 08             	add    $0x8,%esp
f0100959:	ff 77 18             	push   0x18(%edi)
f010095c:	8d 83 4b 58 f8 ff    	lea    -0x7a7b5(%ebx),%eax
f0100962:	50                   	push   %eax
f0100963:	e8 d7 39 00 00       	call   f010433f <cprintf>
		cprintf("%s:%d: ", eipinfo.eip_file, eipinfo.eip_line);
f0100968:	83 c4 0c             	add    $0xc,%esp
f010096b:	ff b3 f0 22 00 00    	push   0x22f0(%ebx)
f0100971:	ff b3 ec 22 00 00    	push   0x22ec(%ebx)
f0100977:	8d 83 bc 43 f8 ff    	lea    -0x7bc44(%ebx),%eax
f010097d:	50                   	push   %eax
f010097e:	e8 bc 39 00 00       	call   f010433f <cprintf>
		cprintf("%.*s", eipinfo.eip_fn_namelen, eipinfo.eip_fn_name);
f0100983:	83 c4 0c             	add    $0xc,%esp
f0100986:	ff b3 f4 22 00 00    	push   0x22f4(%ebx)
f010098c:	ff b3 f8 22 00 00    	push   0x22f8(%ebx)
f0100992:	8d 83 a9 46 f8 ff    	lea    -0x7b957(%ebx),%eax
f0100998:	50                   	push   %eax
f0100999:	e8 a1 39 00 00       	call   f010433f <cprintf>
		cprintf("+%d\n",-eipinfo.eip_fn_addr + eip_val);
f010099e:	83 c4 08             	add    $0x8,%esp
f01009a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009a4:	2b 83 fc 22 00 00    	sub    0x22fc(%ebx),%eax
f01009aa:	50                   	push   %eax
f01009ab:	8d 83 ae 46 f8 ff    	lea    -0x7b952(%ebx),%eax
f01009b1:	50                   	push   %eax
f01009b2:	e8 88 39 00 00       	call   f010433f <cprintf>
		ebp_ptr = (int*)(*ebp_ptr);
f01009b7:	8b 3f                	mov    (%edi),%edi
	}while(ebp_ptr != NULL);
f01009b9:	83 c4 10             	add    $0x10,%esp
f01009bc:	85 ff                	test   %edi,%edi
f01009be:	0f 85 33 ff ff ff    	jne    f01008f7 <mon_backtrace+0x39>
}
f01009c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01009c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009cc:	5b                   	pop    %ebx
f01009cd:	5e                   	pop    %esi
f01009ce:	5f                   	pop    %edi
f01009cf:	5d                   	pop    %ebp
f01009d0:	c3                   	ret    

f01009d1 <show_mappings>:


int show_mappings(u32 va_begin, u32 va_end)
{
f01009d1:	55                   	push   %ebp
f01009d2:	89 e5                	mov    %esp,%ebp
f01009d4:	57                   	push   %edi
f01009d5:	56                   	push   %esi
f01009d6:	53                   	push   %ebx
f01009d7:	83 ec 28             	sub    $0x28,%esp
f01009da:	e8 c7 f7 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01009df:	81 c3 8d 0e 08 00    	add    $0x80e8d,%ebx
f01009e5:	8b 7d 08             	mov    0x8(%ebp),%edi
	//u32 *vaddr = (u32 *)va_begin;
	cprintf("vaddr       paddr       [AVA][//][D][A][//][U][W][P]\n");
f01009e8:	8d 83 30 49 f8 ff    	lea    -0x7b6d0(%ebx),%eax
f01009ee:	50                   	push   %eax
f01009ef:	e8 4b 39 00 00       	call   f010433f <cprintf>
	for (u32 vaddr = va_begin; vaddr <= va_end; vaddr = vaddr + PGSIZE)
f01009f4:	83 c4 10             	add    $0x10,%esp
	{
		pte_t *t_entry = pgdir_walk(kern_pgdir, (u32 *)vaddr, false);
f01009f7:	c7 c0 74 3b 18 f0    	mov    $0xf0183b74,%eax
f01009fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			{
				cprintf("0x%x  none pte\n", vaddr);
			}
		}
		else
			cprintf("0x%x  none pde\n", vaddr);
f0100a00:	8d 83 d2 46 f8 ff    	lea    -0x7b92e(%ebx),%eax
f0100a06:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (u32 vaddr = va_begin; vaddr <= va_end; vaddr = vaddr + PGSIZE)
f0100a09:	eb 19                	jmp    f0100a24 <show_mappings+0x53>
				cprintf("0x%x  none pte\n", vaddr);
f0100a0b:	83 ec 08             	sub    $0x8,%esp
f0100a0e:	57                   	push   %edi
f0100a0f:	8d 83 c2 46 f8 ff    	lea    -0x7b93e(%ebx),%eax
f0100a15:	50                   	push   %eax
f0100a16:	e8 24 39 00 00       	call   f010433f <cprintf>
f0100a1b:	83 c4 10             	add    $0x10,%esp
	for (u32 vaddr = va_begin; vaddr <= va_end; vaddr = vaddr + PGSIZE)
f0100a1e:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0100a24:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100a27:	0f 87 cc 00 00 00    	ja     f0100af9 <show_mappings+0x128>
		pte_t *t_entry = pgdir_walk(kern_pgdir, (u32 *)vaddr, false);
f0100a2d:	83 ec 04             	sub    $0x4,%esp
f0100a30:	6a 00                	push   $0x0
f0100a32:	57                   	push   %edi
f0100a33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a36:	ff 30                	push   (%eax)
f0100a38:	e8 2d 0d 00 00       	call   f010176a <pgdir_walk>
		if (t_entry)
f0100a3d:	83 c4 10             	add    $0x10,%esp
f0100a40:	85 c0                	test   %eax,%eax
f0100a42:	0f 84 9d 00 00 00    	je     f0100ae5 <show_mappings+0x114>
			u32 val = *t_entry;
f0100a48:	8b 30                	mov    (%eax),%esi
			if (*t_entry & PTE_P)
f0100a4a:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0100a50:	74 b9                	je     f0100a0b <show_mappings+0x3a>
				cprintf("0x%08x  0x%08x", vaddr, val & 0xfffff000);
f0100a52:	83 ec 04             	sub    $0x4,%esp
f0100a55:	89 f0                	mov    %esi,%eax
f0100a57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a5c:	50                   	push   %eax
f0100a5d:	57                   	push   %edi
f0100a5e:	8d 83 b3 46 f8 ff    	lea    -0x7b94d(%ebx),%eax
f0100a64:	50                   	push   %eax
f0100a65:	e8 d5 38 00 00       	call   f010433f <cprintf>
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
				BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
f0100a71:	89 f0                	mov    %esi,%eax
f0100a73:	d1 e8                	shr    %eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a75:	83 e0 01             	and    $0x1,%eax
f0100a78:	50                   	push   %eax
				BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
f0100a79:	89 f0                	mov    %esi,%eax
f0100a7b:	c1 e8 02             	shr    $0x2,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a7e:	83 e0 01             	and    $0x1,%eax
f0100a81:	50                   	push   %eax
				BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
f0100a82:	89 f0                	mov    %esi,%eax
f0100a84:	c1 e8 03             	shr    $0x3,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a87:	83 e0 01             	and    $0x1,%eax
f0100a8a:	50                   	push   %eax
				BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100a8b:	89 f0                	mov    %esi,%eax
f0100a8d:	c1 e8 04             	shr    $0x4,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a90:	83 e0 01             	and    $0x1,%eax
f0100a93:	50                   	push   %eax
				BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100a94:	89 f0                	mov    %esi,%eax
f0100a96:	c1 e8 05             	shr    $0x5,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100a99:	83 e0 01             	and    $0x1,%eax
f0100a9c:	50                   	push   %eax
				BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100a9d:	89 f0                	mov    %esi,%eax
f0100a9f:	c1 e8 06             	shr    $0x6,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100aa2:	83 e0 01             	and    $0x1,%eax
f0100aa5:	50                   	push   %eax
				BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100aa6:	89 f0                	mov    %esi,%eax
f0100aa8:	c1 e8 07             	shr    $0x7,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100aab:	83 e0 01             	and    $0x1,%eax
f0100aae:	50                   	push   %eax
				BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100aaf:	89 f0                	mov    %esi,%eax
f0100ab1:	c1 e8 08             	shr    $0x8,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100ab4:	83 e0 01             	and    $0x1,%eax
f0100ab7:	50                   	push   %eax
				BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100ab8:	89 f0                	mov    %esi,%eax
f0100aba:	c1 e8 09             	shr    $0x9,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100abd:	83 e0 01             	and    $0x1,%eax
f0100ac0:	50                   	push   %eax
				BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100ac1:	89 f0                	mov    %esi,%eax
f0100ac3:	c1 e8 0a             	shr    $0xa,%eax
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100ac6:	83 e0 01             	and    $0x1,%eax
f0100ac9:	50                   	push   %eax
				BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100aca:	c1 ee 0b             	shr    $0xb,%esi
				cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100acd:	83 e6 01             	and    $0x1,%esi
f0100ad0:	56                   	push   %esi
f0100ad1:	8d 83 68 49 f8 ff    	lea    -0x7b698(%ebx),%eax
f0100ad7:	50                   	push   %eax
f0100ad8:	e8 62 38 00 00       	call   f010433f <cprintf>
f0100add:	83 c4 40             	add    $0x40,%esp
f0100ae0:	e9 39 ff ff ff       	jmp    f0100a1e <show_mappings+0x4d>
			cprintf("0x%x  none pde\n", vaddr);
f0100ae5:	83 ec 08             	sub    $0x8,%esp
f0100ae8:	57                   	push   %edi
f0100ae9:	ff 75 e0             	push   -0x20(%ebp)
f0100aec:	e8 4e 38 00 00       	call   f010433f <cprintf>
f0100af1:	83 c4 10             	add    $0x10,%esp
f0100af4:	e9 25 ff ff ff       	jmp    f0100a1e <show_mappings+0x4d>
	}
	return 0;
}
f0100af9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100afe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b01:	5b                   	pop    %ebx
f0100b02:	5e                   	pop    %esi
f0100b03:	5f                   	pop    %edi
f0100b04:	5d                   	pop    %ebp
f0100b05:	c3                   	ret    

f0100b06 <change_permission>:

int change_permission(u32 va, u32 aut)
{
f0100b06:	55                   	push   %ebp
f0100b07:	89 e5                	mov    %esp,%ebp
f0100b09:	57                   	push   %edi
f0100b0a:	56                   	push   %esi
f0100b0b:	53                   	push   %ebx
f0100b0c:	83 ec 28             	sub    $0x28,%esp
f0100b0f:	e8 92 f6 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100b14:	81 c3 58 0d 08 00    	add    $0x80d58,%ebx
	va = va & 0xfffff000;
f0100b1a:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100b1d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	cprintf("before change\n");
f0100b23:	8d 83 e2 46 f8 ff    	lea    -0x7b91e(%ebx),%eax
f0100b29:	50                   	push   %eax
f0100b2a:	e8 10 38 00 00       	call   f010433f <cprintf>
	show_mappings(va, va);
f0100b2f:	83 c4 08             	add    $0x8,%esp
f0100b32:	57                   	push   %edi
f0100b33:	57                   	push   %edi
f0100b34:	e8 98 fe ff ff       	call   f01009d1 <show_mappings>

	pte_t *t_entry = pgdir_walk(kern_pgdir, (u32 *)va, false);
f0100b39:	83 c4 0c             	add    $0xc,%esp
f0100b3c:	6a 00                	push   $0x0
f0100b3e:	57                   	push   %edi
f0100b3f:	c7 c0 74 3b 18 f0    	mov    $0xf0183b74,%eax
f0100b45:	ff 30                	push   (%eax)
f0100b47:	e8 1e 0c 00 00       	call   f010176a <pgdir_walk>
	if (t_entry)
f0100b4c:	83 c4 10             	add    $0x10,%esp
f0100b4f:	85 c0                	test   %eax,%eax
f0100b51:	0f 84 e3 00 00 00    	je     f0100c3a <change_permission+0x134>
f0100b57:	89 c6                	mov    %eax,%esi
	{
		if (*t_entry & PTE_P)
f0100b59:	f6 00 01             	testb  $0x1,(%eax)
f0100b5c:	0f 84 c3 00 00 00    	je     f0100c25 <change_permission+0x11f>
		{
			cprintf("after change\n");
f0100b62:	83 ec 0c             	sub    $0xc,%esp
f0100b65:	8d 83 f1 46 f8 ff    	lea    -0x7b90f(%ebx),%eax
f0100b6b:	50                   	push   %eax
f0100b6c:	e8 ce 37 00 00       	call   f010433f <cprintf>
			int temp = (aut << 1) & 0x6;
			*t_entry = (*t_entry & ~0x6) | temp;
f0100b71:	89 f2                	mov    %esi,%edx
f0100b73:	8b 06                	mov    (%esi),%eax
f0100b75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100b78:	89 c6                	mov    %eax,%esi
f0100b7a:	83 e6 f9             	and    $0xfffffff9,%esi
			int temp = (aut << 1) & 0x6;
f0100b7d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b80:	01 c0                	add    %eax,%eax
f0100b82:	83 e0 06             	and    $0x6,%eax
			*t_entry = (*t_entry & ~0x6) | temp;
f0100b85:	09 c6                	or     %eax,%esi
f0100b87:	89 32                	mov    %esi,(%edx)
			u32 val = *t_entry;
			cprintf("0x%08x  0x%08x", va, val & 0xfffff000);
f0100b89:	83 c4 0c             	add    $0xc,%esp
f0100b8c:	89 f0                	mov    %esi,%eax
f0100b8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b93:	50                   	push   %eax
f0100b94:	57                   	push   %edi
f0100b95:	8d 83 b3 46 f8 ff    	lea    -0x7b94d(%ebx),%eax
f0100b9b:	50                   	push   %eax
f0100b9c:	e8 9e 37 00 00       	call   f010433f <cprintf>
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100ba1:	89 f0                	mov    %esi,%eax
f0100ba3:	83 e0 01             	and    $0x1,%eax
f0100ba6:	89 04 24             	mov    %eax,(%esp)
			BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
			BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
			BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
f0100ba9:	89 f0                	mov    %esi,%eax
f0100bab:	d1 e8                	shr    %eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bad:	83 e0 01             	and    $0x1,%eax
f0100bb0:	50                   	push   %eax
			BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
f0100bb1:	89 f0                	mov    %esi,%eax
f0100bb3:	c1 e8 02             	shr    $0x2,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bb6:	83 e0 01             	and    $0x1,%eax
f0100bb9:	50                   	push   %eax
			BIT(val, 3), BIT(val, 2), BIT(val, 1), BIT(val, 0));
f0100bba:	89 f0                	mov    %esi,%eax
f0100bbc:	c1 e8 03             	shr    $0x3,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bbf:	83 e0 01             	and    $0x1,%eax
f0100bc2:	50                   	push   %eax
			BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100bc3:	89 f0                	mov    %esi,%eax
f0100bc5:	c1 e8 04             	shr    $0x4,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bc8:	83 e0 01             	and    $0x1,%eax
f0100bcb:	50                   	push   %eax
			BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100bcc:	89 f0                	mov    %esi,%eax
f0100bce:	c1 e8 05             	shr    $0x5,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bd1:	83 e0 01             	and    $0x1,%eax
f0100bd4:	50                   	push   %eax
			BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100bd5:	89 f0                	mov    %esi,%eax
f0100bd7:	c1 e8 06             	shr    $0x6,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bda:	83 e0 01             	and    $0x1,%eax
f0100bdd:	50                   	push   %eax
			BIT(val, 7), BIT(val, 6), BIT(val, 5), BIT(val, 4),
f0100bde:	89 f0                	mov    %esi,%eax
f0100be0:	c1 e8 07             	shr    $0x7,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100be3:	83 e0 01             	and    $0x1,%eax
f0100be6:	50                   	push   %eax
			BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100be7:	89 f0                	mov    %esi,%eax
f0100be9:	c1 e8 08             	shr    $0x8,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bec:	83 e0 01             	and    $0x1,%eax
f0100bef:	50                   	push   %eax
			BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100bf0:	89 f0                	mov    %esi,%eax
f0100bf2:	c1 e8 09             	shr    $0x9,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bf5:	83 e0 01             	and    $0x1,%eax
f0100bf8:	50                   	push   %eax
			BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100bf9:	89 f0                	mov    %esi,%eax
f0100bfb:	c1 e8 0a             	shr    $0xa,%eax
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100bfe:	83 e0 01             	and    $0x1,%eax
f0100c01:	50                   	push   %eax
			BIT(val, 11), BIT(val, 10), BIT(val, 9), BIT(val, 8),
f0100c02:	c1 ee 0b             	shr    $0xb,%esi
			cprintf("   %x%x%x  %x%x  %x  %x  %x%x  %x  %x  %x\n",
f0100c05:	83 e6 01             	and    $0x1,%esi
f0100c08:	56                   	push   %esi
f0100c09:	8d 83 68 49 f8 ff    	lea    -0x7b698(%ebx),%eax
f0100c0f:	50                   	push   %eax
f0100c10:	e8 2a 37 00 00       	call   f010433f <cprintf>
f0100c15:	83 c4 40             	add    $0x40,%esp
	else
	{
		cprintf("0x%x  none pde\n", va);
	}
	return 0;
}
f0100c18:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c20:	5b                   	pop    %ebx
f0100c21:	5e                   	pop    %esi
f0100c22:	5f                   	pop    %edi
f0100c23:	5d                   	pop    %ebp
f0100c24:	c3                   	ret    
			cprintf("0x%x  none pte\n", va);
f0100c25:	83 ec 08             	sub    $0x8,%esp
f0100c28:	57                   	push   %edi
f0100c29:	8d 83 c2 46 f8 ff    	lea    -0x7b93e(%ebx),%eax
f0100c2f:	50                   	push   %eax
f0100c30:	e8 0a 37 00 00       	call   f010433f <cprintf>
f0100c35:	83 c4 10             	add    $0x10,%esp
f0100c38:	eb de                	jmp    f0100c18 <change_permission+0x112>
		cprintf("0x%x  none pde\n", va);
f0100c3a:	83 ec 08             	sub    $0x8,%esp
f0100c3d:	57                   	push   %edi
f0100c3e:	8d 83 d2 46 f8 ff    	lea    -0x7b92e(%ebx),%eax
f0100c44:	50                   	push   %eax
f0100c45:	e8 f5 36 00 00       	call   f010433f <cprintf>
f0100c4a:	83 c4 10             	add    $0x10,%esp
f0100c4d:	eb c9                	jmp    f0100c18 <change_permission+0x112>

f0100c4f <virtual_memeory_dump>:

int virtual_memeory_dump(u32 addr, u32 len)
{
f0100c4f:	55                   	push   %ebp
f0100c50:	89 e5                	mov    %esp,%ebp
f0100c52:	57                   	push   %edi
f0100c53:	56                   	push   %esi
f0100c54:	53                   	push   %ebx
f0100c55:	83 ec 1c             	sub    $0x1c,%esp
f0100c58:	e8 49 f5 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100c5d:	81 c3 0f 0c 08 00    	add    $0x80c0f,%ebx
	int pg_cnt; 
	int t_start = ROUNDDOWN(addr, PGSIZE);
	int t_end = ROUNDUP(addr+len, PGSIZE);
f0100c63:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0100c69:	8d 84 08 ff 0f 00 00 	lea    0xfff(%eax,%ecx,1),%eax
f0100c70:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	int t_start = ROUNDDOWN(addr, PGSIZE);
f0100c75:	8b 55 08             	mov    0x8(%ebp),%edx
f0100c78:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	pg_cnt = (t_end - t_start) / PGSIZE;
f0100c7e:	29 d0                	sub    %edx,%eax
f0100c80:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100c86:	0f 48 c2             	cmovs  %edx,%eax
f0100c89:	c1 f8 0c             	sar    $0xc,%eax
f0100c8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (int i = 0; i < pg_cnt; i++)
f0100c8f:	8b 75 08             	mov    0x8(%ebp),%esi
f0100c92:	bf 00 00 00 00       	mov    $0x0,%edi
	{
		pte_t *entry = pgdir_walk(kern_pgdir, (char*)(addr + PGSIZE * i), false);
f0100c97:	c7 c0 74 3b 18 f0    	mov    $0xf0183b74,%eax
f0100c9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (int i = 0; i < pg_cnt; i++)
f0100ca0:	eb 22                	jmp    f0100cc4 <virtual_memeory_dump+0x75>
		if (!entry)
		{
			cprintf("page table for vitual address 0x%x does not exist!\n", addr + PGSIZE * i);
f0100ca2:	83 ec 08             	sub    $0x8,%esp
f0100ca5:	56                   	push   %esi
f0100ca6:	8d 83 94 49 f8 ff    	lea    -0x7b66c(%ebx),%eax
f0100cac:	50                   	push   %eax
f0100cad:	e8 8d 36 00 00       	call   f010433f <cprintf>
			return -1;
f0100cb2:	83 c4 10             	add    $0x10,%esp
f0100cb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cba:	e9 de 00 00 00       	jmp    f0100d9d <virtual_memeory_dump+0x14e>
	for (int i = 0; i < pg_cnt; i++)
f0100cbf:	83 c7 01             	add    $0x1,%edi
f0100cc2:	89 d6                	mov    %edx,%esi
f0100cc4:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0100cc7:	7d 3f                	jge    f0100d08 <virtual_memeory_dump+0xb9>
		pte_t *entry = pgdir_walk(kern_pgdir, (char*)(addr + PGSIZE * i), false);
f0100cc9:	83 ec 04             	sub    $0x4,%esp
f0100ccc:	6a 00                	push   $0x0
f0100cce:	56                   	push   %esi
f0100ccf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cd2:	ff 30                	push   (%eax)
f0100cd4:	e8 91 0a 00 00       	call   f010176a <pgdir_walk>
		if (!entry)
f0100cd9:	83 c4 10             	add    $0x10,%esp
f0100cdc:	85 c0                	test   %eax,%eax
f0100cde:	74 c2                	je     f0100ca2 <virtual_memeory_dump+0x53>
		}
		else
		{
			if ((*entry & PTE_P) == 0)
f0100ce0:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0100ce6:	f6 00 01             	testb  $0x1,(%eax)
f0100ce9:	75 d4                	jne    f0100cbf <virtual_memeory_dump+0x70>
			{
				cprintf("physical map page for vitual address 0x%x does not exist!\n", addr + PGSIZE * i);
f0100ceb:	83 ec 08             	sub    $0x8,%esp
f0100cee:	56                   	push   %esi
f0100cef:	8d 83 c8 49 f8 ff    	lea    -0x7b638(%ebx),%eax
f0100cf5:	50                   	push   %eax
f0100cf6:	e8 44 36 00 00       	call   f010433f <cprintf>
				return -1;
f0100cfb:	83 c4 10             	add    $0x10,%esp
f0100cfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d03:	e9 95 00 00 00       	jmp    f0100d9d <virtual_memeory_dump+0x14e>
			}
		}
	}
	u32 *ptr = (u32 *)addr;
	// cprintf("0x%08x:  ", addr);
	for (int i = 0; i< ROUNDUP(len, sizeof(u32))/sizeof(u32); i++)
f0100d08:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d0b:	83 c0 03             	add    $0x3,%eax
f0100d0e:	c1 e8 02             	shr    $0x2,%eax
f0100d11:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d14:	be 00 00 00 00       	mov    $0x0,%esi
	{
		if (i % 4 == 0)
		{
				cprintf("0x%08x:  ", addr + i * sizeof(u32));
f0100d19:	8d 83 ff 46 f8 ff    	lea    -0x7b901(%ebx),%eax
f0100d1f:	89 45 d8             	mov    %eax,-0x28(%ebp)
		}
		cprintf("0x%08x  ", *(ptr+i));
f0100d22:	8d 83 09 47 f8 ff    	lea    -0x7b8f7(%ebx),%eax
f0100d28:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100d2b:	8b 7d 08             	mov    0x8(%ebp),%edi
	for (int i = 0; i< ROUNDUP(len, sizeof(u32))/sizeof(u32); i++)
f0100d2e:	eb 17                	jmp    f0100d47 <virtual_memeory_dump+0xf8>
				cprintf("0x%08x:  ", addr + i * sizeof(u32));
f0100d30:	83 ec 08             	sub    $0x8,%esp
f0100d33:	57                   	push   %edi
f0100d34:	ff 75 d8             	push   -0x28(%ebp)
f0100d37:	e8 03 36 00 00       	call   f010433f <cprintf>
f0100d3c:	83 c4 10             	add    $0x10,%esp
f0100d3f:	eb 13                	jmp    f0100d54 <virtual_memeory_dump+0x105>
f0100d41:	83 c7 04             	add    $0x4,%edi
	for (int i = 0; i < pg_cnt; i++)
f0100d44:	8b 75 e4             	mov    -0x1c(%ebp),%esi
	for (int i = 0; i< ROUNDUP(len, sizeof(u32))/sizeof(u32); i++)
f0100d47:	3b 75 e0             	cmp    -0x20(%ebp),%esi
f0100d4a:	74 3a                	je     f0100d86 <virtual_memeory_dump+0x137>
		if (i % 4 == 0)
f0100d4c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0100d52:	74 dc                	je     f0100d30 <virtual_memeory_dump+0xe1>
		cprintf("0x%08x  ", *(ptr+i));
f0100d54:	83 ec 08             	sub    $0x8,%esp
f0100d57:	ff 37                	push   (%edi)
f0100d59:	ff 75 dc             	push   -0x24(%ebp)
f0100d5c:	e8 de 35 00 00       	call   f010433f <cprintf>
		if ((i+1) % 4 == 0 && i != 0)
f0100d61:	8d 46 01             	lea    0x1(%esi),%eax
f0100d64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d67:	83 c4 10             	add    $0x10,%esp
f0100d6a:	a8 03                	test   $0x3,%al
f0100d6c:	75 d3                	jne    f0100d41 <virtual_memeory_dump+0xf2>
f0100d6e:	85 f6                	test   %esi,%esi
f0100d70:	74 cf                	je     f0100d41 <virtual_memeory_dump+0xf2>
			cprintf("\n");
f0100d72:	83 ec 0c             	sub    $0xc,%esp
f0100d75:	8d 83 aa 43 f8 ff    	lea    -0x7bc56(%ebx),%eax
f0100d7b:	50                   	push   %eax
f0100d7c:	e8 be 35 00 00       	call   f010433f <cprintf>
f0100d81:	83 c4 10             	add    $0x10,%esp
f0100d84:	eb bb                	jmp    f0100d41 <virtual_memeory_dump+0xf2>
	}
	cprintf("\n");
f0100d86:	83 ec 0c             	sub    $0xc,%esp
f0100d89:	8d 83 aa 43 f8 ff    	lea    -0x7bc56(%ebx),%eax
f0100d8f:	50                   	push   %eax
f0100d90:	e8 aa 35 00 00       	call   f010433f <cprintf>
	return 0;
f0100d95:	83 c4 10             	add    $0x10,%esp
f0100d98:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100da0:	5b                   	pop    %ebx
f0100da1:	5e                   	pop    %esi
f0100da2:	5f                   	pop    %edi
f0100da3:	5d                   	pop    %ebp
f0100da4:	c3                   	ret    

f0100da5 <physical_memory_dump>:

int physical_memory_dump(u32 paddr, u32 len)
{
f0100da5:	55                   	push   %ebp
f0100da6:	89 e5                	mov    %esp,%ebp
f0100da8:	83 ec 10             	sub    $0x10,%esp
	u32 vaddr = paddr + KERNBASE;
	int ret = virtual_memeory_dump(vaddr, len);
f0100dab:	ff 75 0c             	push   0xc(%ebp)
	u32 vaddr = paddr + KERNBASE;
f0100dae:	8b 45 08             	mov    0x8(%ebp),%eax
f0100db1:	2d 00 00 00 10       	sub    $0x10000000,%eax
	int ret = virtual_memeory_dump(vaddr, len);
f0100db6:	50                   	push   %eax
f0100db7:	e8 93 fe ff ff       	call   f0100c4f <virtual_memeory_dump>
	return ret;
}
f0100dbc:	c9                   	leave  
f0100dbd:	c3                   	ret    

f0100dbe <in_page_dump>:


int in_page_dump(u32 addr, u32 len)
{
	return 0;
}
f0100dbe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dc3:	c3                   	ret    

f0100dc4 <string2value>:

	return 0;	
}

int string2value(char* str)
{
f0100dc4:	55                   	push   %ebp
f0100dc5:	89 e5                	mov    %esp,%ebp
f0100dc7:	53                   	push   %ebx
f0100dc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100dcb:	ba 00 00 00 00       	mov    $0x0,%edx
	char *p = str;
	int hex = 0;
	int temp_val = 0;
	int sum = 0;
	if (*p == '0')
f0100dd0:	80 39 30             	cmpb   $0x30,(%ecx)
f0100dd3:	74 1d                	je     f0100df2 <string2value+0x2e>
			p++;
		}
	}
	else
	{
		while(*p)
f0100dd5:	0f b6 01             	movzbl (%ecx),%eax
f0100dd8:	84 c0                	test   %al,%al
f0100dda:	74 68                	je     f0100e44 <string2value+0x80>
		{
			//cprintf("ptr %d\n", *p);
			temp_val = *p - '0';
f0100ddc:	0f be c0             	movsbl %al,%eax
f0100ddf:	83 e8 30             	sub    $0x30,%eax
			//cprintf("temp %d\n", temp_val);
			if (temp_val >= 0 && temp_val <= 9)
f0100de2:	83 f8 09             	cmp    $0x9,%eax
f0100de5:	77 58                	ja     f0100e3f <string2value+0x7b>
				sum = sum * 10 + temp_val;
f0100de7:	8d 14 92             	lea    (%edx,%edx,4),%edx
f0100dea:	8d 14 50             	lea    (%eax,%edx,2),%edx
			else
				return -1;
			p++;
f0100ded:	83 c1 01             	add    $0x1,%ecx
f0100df0:	eb e3                	jmp    f0100dd5 <string2value+0x11>
		if (*(p+1) == 0)
f0100df2:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
f0100df6:	84 c0                	test   %al,%al
f0100df8:	74 4a                	je     f0100e44 <string2value+0x80>
		else if (*(p+1) == 'x')
f0100dfa:	3c 78                	cmp    $0x78,%al
f0100dfc:	75 33                	jne    f0100e31 <string2value+0x6d>
		p += 2;
f0100dfe:	83 c1 02             	add    $0x2,%ecx
f0100e01:	eb 15                	jmp    f0100e18 <string2value+0x54>
			else if (temp_val >= 49 && temp_val <= 54)
f0100e03:	0f be c0             	movsbl %al,%eax
f0100e06:	83 e8 61             	sub    $0x61,%eax
f0100e09:	83 f8 05             	cmp    $0x5,%eax
f0100e0c:	77 2a                	ja     f0100e38 <string2value+0x74>
				sum = sum * 16 + temp_val - 39;
f0100e0e:	c1 e2 04             	shl    $0x4,%edx
f0100e11:	8d 54 13 d9          	lea    -0x27(%ebx,%edx,1),%edx
			p++;
f0100e15:	83 c1 01             	add    $0x1,%ecx
		while(*p)
f0100e18:	0f b6 01             	movzbl (%ecx),%eax
f0100e1b:	84 c0                	test   %al,%al
f0100e1d:	74 25                	je     f0100e44 <string2value+0x80>
			temp_val = *p - '0';
f0100e1f:	0f be d8             	movsbl %al,%ebx
f0100e22:	83 eb 30             	sub    $0x30,%ebx
			if (temp_val >= 0 && temp_val<= 9)
f0100e25:	83 fb 09             	cmp    $0x9,%ebx
f0100e28:	77 d9                	ja     f0100e03 <string2value+0x3f>
				sum = sum * 16 + temp_val;
f0100e2a:	c1 e2 04             	shl    $0x4,%edx
f0100e2d:	01 da                	add    %ebx,%edx
f0100e2f:	eb e4                	jmp    f0100e15 <string2value+0x51>
			return -1;
f0100e31:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100e36:	eb 0c                	jmp    f0100e44 <string2value+0x80>
				return -1;
f0100e38:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100e3d:	eb 05                	jmp    f0100e44 <string2value+0x80>
				return -1;
f0100e3f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
		}
	} 
	return sum;
}
f0100e44:	89 d0                	mov    %edx,%eax
f0100e46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e49:	c9                   	leave  
f0100e4a:	c3                   	ret    

f0100e4b <v_cmd_exc>:
{
f0100e4b:	55                   	push   %ebp
f0100e4c:	89 e5                	mov    %esp,%ebp
f0100e4e:	57                   	push   %edi
f0100e4f:	56                   	push   %esi
f0100e50:	53                   	push   %ebx
f0100e51:	83 ec 4c             	sub    $0x4c,%esp
f0100e54:	e8 4d f3 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100e59:	81 c3 13 0a 08 00    	add    $0x80a13,%ebx
	int para[10] = {0};
f0100e5f:	8d 7d c0             	lea    -0x40(%ebp),%edi
f0100e62:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0100e67:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e6c:	f3 ab                	rep stos %eax,%es:(%edi)
	if (argc < 2)
f0100e6e:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100e72:	7e 5a                	jle    f0100ece <v_cmd_exc+0x83>
	char *subfunc = argv[1];
f0100e74:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e77:	8b 40 04             	mov    0x4(%eax),%eax
f0100e7a:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f0100e7d:	8d bb d4 17 00 00    	lea    0x17d4(%ebx),%edi
	for (int i = 0; i < vcmd_num; i++)
f0100e83:	be 00 00 00 00       	mov    $0x0,%esi
		if (!strcmp(subfunc, vcmd_group[i].name))
f0100e88:	83 ec 08             	sub    $0x8,%esp
f0100e8b:	ff 37                	push   (%edi)
f0100e8d:	ff 75 b4             	push   -0x4c(%ebp)
f0100e90:	e8 51 48 00 00       	call   f01056e6 <strcmp>
f0100e95:	83 c4 10             	add    $0x10,%esp
f0100e98:	85 c0                	test   %eax,%eax
f0100e9a:	74 4d                	je     f0100ee9 <v_cmd_exc+0x9e>
	for (int i = 0; i < vcmd_num; i++)
f0100e9c:	83 c6 01             	add    $0x1,%esi
f0100e9f:	83 c7 10             	add    $0x10,%edi
f0100ea2:	81 fe 80 00 00 00    	cmp    $0x80,%esi
f0100ea8:	75 de                	jne    f0100e88 <v_cmd_exc+0x3d>
	cprintf("command not found!\n");
f0100eaa:	83 ec 0c             	sub    $0xc,%esp
f0100ead:	8d 83 43 47 f8 ff    	lea    -0x7b8bd(%ebx),%eax
f0100eb3:	50                   	push   %eax
f0100eb4:	e8 86 34 00 00       	call   f010433f <cprintf>
	return 0;	
f0100eb9:	83 c4 10             	add    $0x10,%esp
f0100ebc:	c7 45 b4 00 00 00 00 	movl   $0x0,-0x4c(%ebp)
}
f0100ec3:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100ec6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ec9:	5b                   	pop    %ebx
f0100eca:	5e                   	pop    %esi
f0100ecb:	5f                   	pop    %edi
f0100ecc:	5d                   	pop    %ebp
f0100ecd:	c3                   	ret    
		cprintf("sub command name expected\n");
f0100ece:	83 ec 0c             	sub    $0xc,%esp
f0100ed1:	8d 83 12 47 f8 ff    	lea    -0x7b8ee(%ebx),%eax
f0100ed7:	50                   	push   %eax
f0100ed8:	e8 62 34 00 00       	call   f010433f <cprintf>
		return -1;
f0100edd:	83 c4 10             	add    $0x10,%esp
f0100ee0:	c7 45 b4 ff ff ff ff 	movl   $0xffffffff,-0x4c(%ebp)
f0100ee7:	eb da                	jmp    f0100ec3 <v_cmd_exc+0x78>
			if (argc-2 != vcmd_group[i].para_cnt)
f0100ee9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f0100eec:	89 f0                	mov    %esi,%eax
f0100eee:	c1 e0 04             	shl    $0x4,%eax
f0100ef1:	8b 84 03 e0 17 00 00 	mov    0x17e0(%ebx,%eax,1),%eax
f0100ef8:	8b 55 08             	mov    0x8(%ebp),%edx
f0100efb:	83 ea 02             	sub    $0x2,%edx
f0100efe:	39 c2                	cmp    %eax,%edx
f0100f00:	75 27                	jne    f0100f29 <v_cmd_exc+0xde>
				for (int i = 2; i< argc; i++)
f0100f02:	bf 02 00 00 00       	mov    $0x2,%edi
f0100f07:	89 75 b0             	mov    %esi,-0x50(%ebp)
f0100f0a:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100f0d:	3b 7d 08             	cmp    0x8(%ebp),%edi
f0100f10:	74 36                	je     f0100f48 <v_cmd_exc+0xfd>
					para[i-1] = string2value(argv[i]);
f0100f12:	83 ec 0c             	sub    $0xc,%esp
f0100f15:	ff 34 be             	push   (%esi,%edi,4)
f0100f18:	e8 a7 fe ff ff       	call   f0100dc4 <string2value>
f0100f1d:	83 c4 10             	add    $0x10,%esp
f0100f20:	89 44 bd bc          	mov    %eax,-0x44(%ebp,%edi,4)
				for (int i = 2; i< argc; i++)
f0100f24:	83 c7 01             	add    $0x1,%edi
f0100f27:	eb e4                	jmp    f0100f0d <v_cmd_exc+0xc2>
				cprintf("expect %d parameters\n", vcmd_group[i].para_cnt);
f0100f29:	83 ec 08             	sub    $0x8,%esp
f0100f2c:	50                   	push   %eax
f0100f2d:	8d 83 2d 47 f8 ff    	lea    -0x7b8d3(%ebx),%eax
f0100f33:	50                   	push   %eax
f0100f34:	e8 06 34 00 00       	call   f010433f <cprintf>
				return -1;
f0100f39:	83 c4 10             	add    $0x10,%esp
f0100f3c:	c7 45 b4 ff ff ff ff 	movl   $0xffffffff,-0x4c(%ebp)
f0100f43:	e9 7b ff ff ff       	jmp    f0100ec3 <v_cmd_exc+0x78>
				func(para[1], para[2], para[3], para[4], para[5],
f0100f48:	8b 75 b0             	mov    -0x50(%ebp),%esi
f0100f4b:	83 ec 0c             	sub    $0xc,%esp
				func9 func = (func9)vcmd_group[i].func;
f0100f4e:	c1 e6 04             	shl    $0x4,%esi
				func(para[1], para[2], para[3], para[4], para[5],
f0100f51:	ff 75 e4             	push   -0x1c(%ebp)
f0100f54:	ff 75 e0             	push   -0x20(%ebp)
f0100f57:	ff 75 dc             	push   -0x24(%ebp)
f0100f5a:	ff 75 d8             	push   -0x28(%ebp)
f0100f5d:	ff 75 d4             	push   -0x2c(%ebp)
f0100f60:	ff 75 d0             	push   -0x30(%ebp)
f0100f63:	ff 75 cc             	push   -0x34(%ebp)
f0100f66:	ff 75 c8             	push   -0x38(%ebp)
f0100f69:	ff 75 c4             	push   -0x3c(%ebp)
f0100f6c:	ff 94 33 dc 17 00 00 	call   *0x17dc(%ebx,%esi,1)
				return 0;
f0100f73:	83 c4 30             	add    $0x30,%esp
f0100f76:	e9 48 ff ff ff       	jmp    f0100ec3 <v_cmd_exc+0x78>

f0100f7b <monitor>:
void
monitor(struct Trapframe *tf)
{
f0100f7b:	55                   	push   %ebp
f0100f7c:	89 e5                	mov    %esp,%ebp
f0100f7e:	57                   	push   %edi
f0100f7f:	56                   	push   %esi
f0100f80:	53                   	push   %ebx
f0100f81:	83 ec 78             	sub    $0x78,%esp
f0100f84:	e8 1d f2 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0100f89:	81 c3 e3 08 08 00    	add    $0x808e3,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100f8f:	8d 83 04 4a f8 ff    	lea    -0x7b5fc(%ebx),%eax
f0100f95:	50                   	push   %eax
f0100f96:	e8 a4 33 00 00       	call   f010433f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100f9b:	8d 83 28 4a f8 ff    	lea    -0x7b5d8(%ebx),%eax
f0100fa1:	89 04 24             	mov    %eax,(%esp)
f0100fa4:	e8 96 33 00 00       	call   f010433f <cprintf>
	char str[] = "0xabcd";
f0100fa9:	c7 45 e1 30 78 61 62 	movl   $0x62617830,-0x1f(%ebp)
f0100fb0:	66 c7 45 e5 63 64    	movw   $0x6463,-0x1b(%ebp)
f0100fb6:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
	int a = string2value(str);
f0100fba:	8d 45 e1             	lea    -0x1f(%ebp),%eax
f0100fbd:	89 04 24             	mov    %eax,(%esp)
f0100fc0:	e8 ff fd ff ff       	call   f0100dc4 <string2value>
f0100fc5:	83 c4 0c             	add    $0xc,%esp
	cprintf("test: %d %x\n", a, a);
f0100fc8:	50                   	push   %eax
f0100fc9:	50                   	push   %eax
f0100fca:	8d 83 57 47 f8 ff    	lea    -0x7b8a9(%ebx),%eax
f0100fd0:	50                   	push   %eax
f0100fd1:	e8 69 33 00 00       	call   f010433f <cprintf>
f0100fd6:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100fd9:	8d bb 68 47 f8 ff    	lea    -0x7b898(%ebx),%edi
f0100fdf:	eb 4a                	jmp    f010102b <monitor+0xb0>
f0100fe1:	83 ec 08             	sub    $0x8,%esp
f0100fe4:	0f be c0             	movsbl %al,%eax
f0100fe7:	50                   	push   %eax
f0100fe8:	57                   	push   %edi
f0100fe9:	e8 58 47 00 00       	call   f0105746 <strchr>
f0100fee:	83 c4 10             	add    $0x10,%esp
f0100ff1:	85 c0                	test   %eax,%eax
f0100ff3:	74 08                	je     f0100ffd <monitor+0x82>
			*buf++ = 0;
f0100ff5:	c6 06 00             	movb   $0x0,(%esi)
f0100ff8:	8d 76 01             	lea    0x1(%esi),%esi
f0100ffb:	eb 76                	jmp    f0101073 <monitor+0xf8>
		if (*buf == 0)
f0100ffd:	80 3e 00             	cmpb   $0x0,(%esi)
f0101000:	74 7c                	je     f010107e <monitor+0x103>
		if (argc == MAXARGS-1) {
f0101002:	83 7d 94 0f          	cmpl   $0xf,-0x6c(%ebp)
f0101006:	74 0f                	je     f0101017 <monitor+0x9c>
		argv[argc++] = buf;
f0101008:	8b 45 94             	mov    -0x6c(%ebp),%eax
f010100b:	8d 48 01             	lea    0x1(%eax),%ecx
f010100e:	89 4d 94             	mov    %ecx,-0x6c(%ebp)
f0101011:	89 74 85 a0          	mov    %esi,-0x60(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0101015:	eb 41                	jmp    f0101058 <monitor+0xdd>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0101017:	83 ec 08             	sub    $0x8,%esp
f010101a:	6a 10                	push   $0x10
f010101c:	8d 83 6d 47 f8 ff    	lea    -0x7b893(%ebx),%eax
f0101022:	50                   	push   %eax
f0101023:	e8 17 33 00 00       	call   f010433f <cprintf>
			return 0;
f0101028:	83 c4 10             	add    $0x10,%esp

	while (1)
	{
		buf = readline("K> ");
f010102b:	8d 83 64 47 f8 ff    	lea    -0x7b89c(%ebx),%eax
f0101031:	89 c6                	mov    %eax,%esi
f0101033:	83 ec 0c             	sub    $0xc,%esp
f0101036:	56                   	push   %esi
f0101037:	e8 b9 44 00 00       	call   f01054f5 <readline>
		if (buf != NULL)
f010103c:	83 c4 10             	add    $0x10,%esp
f010103f:	85 c0                	test   %eax,%eax
f0101041:	74 f0                	je     f0101033 <monitor+0xb8>
	argv[argc] = 0;
f0101043:	89 c6                	mov    %eax,%esi
f0101045:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
	argc = 0;
f010104c:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
f0101053:	eb 1e                	jmp    f0101073 <monitor+0xf8>
			buf++;
f0101055:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0101058:	0f b6 06             	movzbl (%esi),%eax
f010105b:	84 c0                	test   %al,%al
f010105d:	74 14                	je     f0101073 <monitor+0xf8>
f010105f:	83 ec 08             	sub    $0x8,%esp
f0101062:	0f be c0             	movsbl %al,%eax
f0101065:	50                   	push   %eax
f0101066:	57                   	push   %edi
f0101067:	e8 da 46 00 00       	call   f0105746 <strchr>
f010106c:	83 c4 10             	add    $0x10,%esp
f010106f:	85 c0                	test   %eax,%eax
f0101071:	74 e2                	je     f0101055 <monitor+0xda>
		while (*buf && strchr(WHITESPACE, *buf))
f0101073:	0f b6 06             	movzbl (%esi),%eax
f0101076:	84 c0                	test   %al,%al
f0101078:	0f 85 63 ff ff ff    	jne    f0100fe1 <monitor+0x66>
	argv[argc] = 0;
f010107e:	8b 45 94             	mov    -0x6c(%ebp),%eax
f0101081:	c7 44 85 a0 00 00 00 	movl   $0x0,-0x60(%ebp,%eax,4)
f0101088:	00 
	if (argc == 0)
f0101089:	85 c0                	test   %eax,%eax
f010108b:	74 9e                	je     f010102b <monitor+0xb0>
f010108d:	8d b3 d4 1f 00 00    	lea    0x1fd4(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0101093:	b8 00 00 00 00       	mov    $0x0,%eax
f0101098:	89 7d 90             	mov    %edi,-0x70(%ebp)
f010109b:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f010109d:	83 ec 08             	sub    $0x8,%esp
f01010a0:	ff 36                	push   (%esi)
f01010a2:	ff 75 a0             	push   -0x60(%ebp)
f01010a5:	e8 3c 46 00 00       	call   f01056e6 <strcmp>
f01010aa:	83 c4 10             	add    $0x10,%esp
f01010ad:	85 c0                	test   %eax,%eax
f01010af:	74 28                	je     f01010d9 <monitor+0x15e>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01010b1:	83 c7 01             	add    $0x1,%edi
f01010b4:	83 c6 0c             	add    $0xc,%esi
f01010b7:	83 ff 04             	cmp    $0x4,%edi
f01010ba:	75 e1                	jne    f010109d <monitor+0x122>
	cprintf("Unknown command '%s'\n", argv[0]);
f01010bc:	8b 7d 90             	mov    -0x70(%ebp),%edi
f01010bf:	83 ec 08             	sub    $0x8,%esp
f01010c2:	ff 75 a0             	push   -0x60(%ebp)
f01010c5:	8d 83 8a 47 f8 ff    	lea    -0x7b876(%ebx),%eax
f01010cb:	50                   	push   %eax
f01010cc:	e8 6e 32 00 00       	call   f010433f <cprintf>
	return 0;
f01010d1:	83 c4 10             	add    $0x10,%esp
f01010d4:	e9 52 ff ff ff       	jmp    f010102b <monitor+0xb0>
			return commands[i].func(argc, argv, tf);
f01010d9:	89 f8                	mov    %edi,%eax
f01010db:	8b 7d 90             	mov    -0x70(%ebp),%edi
f01010de:	83 ec 04             	sub    $0x4,%esp
f01010e1:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01010e4:	ff 75 08             	push   0x8(%ebp)
f01010e7:	8d 55 a0             	lea    -0x60(%ebp),%edx
f01010ea:	52                   	push   %edx
f01010eb:	ff 75 94             	push   -0x6c(%ebp)
f01010ee:	ff 94 83 dc 1f 00 00 	call   *0x1fdc(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f01010f5:	83 c4 10             	add    $0x10,%esp
f01010f8:	85 c0                	test   %eax,%eax
f01010fa:	0f 89 2b ff ff ff    	jns    f010102b <monitor+0xb0>
				break;
	}
}
f0101100:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101103:	5b                   	pop    %ebx
f0101104:	5e                   	pop    %esi
f0101105:	5f                   	pop    %edi
f0101106:	5d                   	pop    %ebp
f0101107:	c3                   	ret    

f0101108 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0101108:	55                   	push   %ebp
f0101109:	89 e5                	mov    %esp,%ebp
f010110b:	56                   	push   %esi
f010110c:	53                   	push   %ebx
f010110d:	e8 94 f0 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0101112:	81 c3 5a 07 08 00    	add    $0x8075a,%ebx
f0101118:	89 c6                	mov    %eax,%esi
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010111a:	83 bb 10 23 00 00 00 	cmpl   $0x0,0x2310(%ebx)
f0101121:	74 21                	je     f0101144 <boot_alloc+0x3c>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0101123:	8b 83 10 23 00 00    	mov    0x2310(%ebx),%eax
	// cprintf("next free origin: 0x%x\n", nextfree);
	nextfree = nextfree + ROUNDUP(n,PGSIZE);
f0101129:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f010112f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0101135:	01 c6                	add    %eax,%esi
f0101137:	89 b3 10 23 00 00    	mov    %esi,0x2310(%ebx)
	// cprintf("next free after: 0x%x\n", nextfree);
	return result;
}
f010113d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101140:	5b                   	pop    %ebx
f0101141:	5e                   	pop    %esi
f0101142:	5d                   	pop    %ebp
f0101143:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0101144:	c7 c2 40 48 18 f0    	mov    $0xf0184840,%edx
f010114a:	8d 82 ff 0f 00 00    	lea    0xfff(%edx),%eax
f0101150:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101155:	89 83 10 23 00 00    	mov    %eax,0x2310(%ebx)
		cprintf("###end 0x%x\n", (u32)end);
f010115b:	83 ec 08             	sub    $0x8,%esp
f010115e:	52                   	push   %edx
f010115f:	8d 83 4d 4a f8 ff    	lea    -0x7b5b3(%ebx),%eax
f0101165:	50                   	push   %eax
f0101166:	e8 d4 31 00 00       	call   f010433f <cprintf>
		cprintf("###first free 0x%x\n", (u32)nextfree);
f010116b:	83 c4 08             	add    $0x8,%esp
f010116e:	ff b3 10 23 00 00    	push   0x2310(%ebx)
f0101174:	8d 83 5a 4a f8 ff    	lea    -0x7b5a6(%ebx),%eax
f010117a:	50                   	push   %eax
f010117b:	e8 bf 31 00 00       	call   f010433f <cprintf>
f0101180:	83 c4 10             	add    $0x10,%esp
f0101183:	eb 9e                	jmp    f0101123 <boot_alloc+0x1b>

f0101185 <nvram_read>:
{
f0101185:	55                   	push   %ebp
f0101186:	89 e5                	mov    %esp,%ebp
f0101188:	57                   	push   %edi
f0101189:	56                   	push   %esi
f010118a:	53                   	push   %ebx
f010118b:	83 ec 18             	sub    $0x18,%esp
f010118e:	e8 13 f0 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0101193:	81 c3 d9 06 08 00    	add    $0x806d9,%ebx
f0101199:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010119b:	50                   	push   %eax
f010119c:	e8 17 31 00 00       	call   f01042b8 <mc146818_read>
f01011a1:	89 c7                	mov    %eax,%edi
f01011a3:	83 c6 01             	add    $0x1,%esi
f01011a6:	89 34 24             	mov    %esi,(%esp)
f01011a9:	e8 0a 31 00 00       	call   f01042b8 <mc146818_read>
f01011ae:	c1 e0 08             	shl    $0x8,%eax
f01011b1:	09 f8                	or     %edi,%eax
}
f01011b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011b6:	5b                   	pop    %ebx
f01011b7:	5e                   	pop    %esi
f01011b8:	5f                   	pop    %edi
f01011b9:	5d                   	pop    %ebp
f01011ba:	c3                   	ret    

f01011bb <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01011bb:	55                   	push   %ebp
f01011bc:	89 e5                	mov    %esp,%ebp
f01011be:	53                   	push   %ebx
f01011bf:	83 ec 04             	sub    $0x4,%esp
f01011c2:	e8 44 28 00 00       	call   f0103a0b <__x86.get_pc_thunk.cx>
f01011c7:	81 c1 a5 06 08 00    	add    $0x806a5,%ecx
f01011cd:	89 c3                	mov    %eax,%ebx
f01011cf:	89 d0                	mov    %edx,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01011d1:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f01011d4:	8b 14 93             	mov    (%ebx,%edx,4),%edx
f01011d7:	f6 c2 01             	test   $0x1,%dl
f01011da:	74 54                	je     f0101230 <check_va2pa+0x75>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01011dc:	89 d3                	mov    %edx,%ebx
f01011de:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011e4:	c1 ea 0c             	shr    $0xc,%edx
f01011e7:	3b 91 0c 23 00 00    	cmp    0x230c(%ecx),%edx
f01011ed:	73 26                	jae    f0101215 <check_va2pa+0x5a>
	if (!(p[PTX(va)] & PTE_P))
f01011ef:	c1 e8 0c             	shr    $0xc,%eax
f01011f2:	25 ff 03 00 00       	and    $0x3ff,%eax
f01011f7:	8b 94 83 00 00 00 f0 	mov    -0x10000000(%ebx,%eax,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01011fe:	89 d0                	mov    %edx,%eax
f0101200:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101205:	f6 c2 01             	test   $0x1,%dl
f0101208:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010120d:	0f 44 c2             	cmove  %edx,%eax
}
f0101210:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101213:	c9                   	leave  
f0101214:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101215:	53                   	push   %ebx
f0101216:	8d 81 1c 4e f8 ff    	lea    -0x7b1e4(%ecx),%eax
f010121c:	50                   	push   %eax
f010121d:	68 57 03 00 00       	push   $0x357
f0101222:	8d 81 6e 4a f8 ff    	lea    -0x7b592(%ecx),%eax
f0101228:	50                   	push   %eax
f0101229:	89 cb                	mov    %ecx,%ebx
f010122b:	e8 c0 ee ff ff       	call   f01000f0 <_panic>
		return ~0;
f0101230:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101235:	eb d9                	jmp    f0101210 <check_va2pa+0x55>

f0101237 <check_page_free_list>:
{
f0101237:	55                   	push   %ebp
f0101238:	89 e5                	mov    %esp,%ebp
f010123a:	57                   	push   %edi
f010123b:	56                   	push   %esi
f010123c:	53                   	push   %ebx
f010123d:	83 ec 2c             	sub    $0x2c,%esp
f0101240:	e8 61 ef ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0101245:	81 c3 27 06 08 00    	add    $0x80627,%ebx
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010124b:	84 c0                	test   %al,%al
f010124d:	0f 85 db 02 00 00    	jne    f010152e <check_page_free_list+0x2f7>
	if (!page_free_list)
f0101253:	83 bb 14 23 00 00 00 	cmpl   $0x0,0x2314(%ebx)
f010125a:	74 0a                	je     f0101266 <check_page_free_list+0x2f>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010125c:	bf 00 04 00 00       	mov    $0x400,%edi
f0101261:	e9 4a 03 00 00       	jmp    f01015b0 <check_page_free_list+0x379>
		panic("'page_free_list' is a null pointer!");
f0101266:	83 ec 04             	sub    $0x4,%esp
f0101269:	8d 83 40 4e f8 ff    	lea    -0x7b1c0(%ebx),%eax
f010126f:	50                   	push   %eax
f0101270:	68 8e 02 00 00       	push   $0x28e
f0101275:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010127b:	50                   	push   %eax
f010127c:	e8 6f ee ff ff       	call   f01000f0 <_panic>
f0101281:	50                   	push   %eax
f0101282:	8d 83 1c 4e f8 ff    	lea    -0x7b1e4(%ebx),%eax
f0101288:	50                   	push   %eax
f0101289:	6a 5c                	push   $0x5c
f010128b:	8d 83 b1 4a f8 ff    	lea    -0x7b54f(%ebx),%eax
f0101291:	50                   	push   %eax
f0101292:	e8 59 ee ff ff       	call   f01000f0 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101297:	8b 36                	mov    (%esi),%esi
f0101299:	85 f6                	test   %esi,%esi
f010129b:	74 41                	je     f01012de <check_page_free_list+0xa7>
void boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010129d:	89 f0                	mov    %esi,%eax
f010129f:	2b 83 04 23 00 00    	sub    0x2304(%ebx),%eax
f01012a5:	c1 f8 03             	sar    $0x3,%eax
f01012a8:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01012ab:	89 c2                	mov    %eax,%edx
f01012ad:	c1 ea 16             	shr    $0x16,%edx
f01012b0:	39 fa                	cmp    %edi,%edx
f01012b2:	73 e3                	jae    f0101297 <check_page_free_list+0x60>
	if (PGNUM(pa) >= npages)
f01012b4:	89 c2                	mov    %eax,%edx
f01012b6:	c1 ea 0c             	shr    $0xc,%edx
f01012b9:	3b 93 0c 23 00 00    	cmp    0x230c(%ebx),%edx
f01012bf:	73 c0                	jae    f0101281 <check_page_free_list+0x4a>
			memset(page2kva(pp), 0x97, 128);
f01012c1:	83 ec 04             	sub    $0x4,%esp
f01012c4:	68 80 00 00 00       	push   $0x80
f01012c9:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f01012ce:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012d3:	50                   	push   %eax
f01012d4:	e8 ac 44 00 00       	call   f0105785 <memset>
f01012d9:	83 c4 10             	add    $0x10,%esp
f01012dc:	eb b9                	jmp    f0101297 <check_page_free_list+0x60>
	cprintf("pfl 0x%x\n", (int)(page_free_list));
f01012de:	83 ec 08             	sub    $0x8,%esp
f01012e1:	ff b3 14 23 00 00    	push   0x2314(%ebx)
f01012e7:	8d 83 bf 4a f8 ff    	lea    -0x7b541(%ebx),%eax
f01012ed:	50                   	push   %eax
f01012ee:	e8 4c 30 00 00       	call   f010433f <cprintf>
	cprintf("pfl_next 0x%x\n", (int)(page_free_list->pp_link));
f01012f3:	83 c4 08             	add    $0x8,%esp
f01012f6:	8b 83 14 23 00 00    	mov    0x2314(%ebx),%eax
f01012fc:	ff 30                	push   (%eax)
f01012fe:	8d 83 c9 4a f8 ff    	lea    -0x7b537(%ebx),%eax
f0101304:	50                   	push   %eax
f0101305:	e8 35 30 00 00       	call   f010433f <cprintf>
	first_free_page = (char *) boot_alloc(0);
f010130a:	b8 00 00 00 00       	mov    $0x0,%eax
f010130f:	e8 f4 fd ff ff       	call   f0101108 <boot_alloc>
f0101314:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101317:	8b 93 14 23 00 00    	mov    0x2314(%ebx),%edx
		assert(pp >= pages);
f010131d:	8b 8b 04 23 00 00    	mov    0x2304(%ebx),%ecx
		assert(pp < pages + npages);
f0101323:	8b 83 0c 23 00 00    	mov    0x230c(%ebx),%eax
f0101329:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010132c:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010132f:	83 c4 10             	add    $0x10,%esp
	int nfree_basemem = 0, nfree_extmem = 0;
f0101332:	bf 00 00 00 00       	mov    $0x0,%edi
f0101337:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f010133e:	89 7d d0             	mov    %edi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101341:	e9 f3 00 00 00       	jmp    f0101439 <check_page_free_list+0x202>
		assert(pp >= pages);
f0101346:	8d 83 d8 4a f8 ff    	lea    -0x7b528(%ebx),%eax
f010134c:	50                   	push   %eax
f010134d:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0101353:	50                   	push   %eax
f0101354:	68 ad 02 00 00       	push   $0x2ad
f0101359:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010135f:	50                   	push   %eax
f0101360:	e8 8b ed ff ff       	call   f01000f0 <_panic>
		assert(pp < pages + npages);
f0101365:	8d 83 f9 4a f8 ff    	lea    -0x7b507(%ebx),%eax
f010136b:	50                   	push   %eax
f010136c:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0101372:	50                   	push   %eax
f0101373:	68 ae 02 00 00       	push   $0x2ae
f0101378:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010137e:	50                   	push   %eax
f010137f:	e8 6c ed ff ff       	call   f01000f0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101384:	8d 83 64 4e f8 ff    	lea    -0x7b19c(%ebx),%eax
f010138a:	50                   	push   %eax
f010138b:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0101391:	50                   	push   %eax
f0101392:	68 af 02 00 00       	push   $0x2af
f0101397:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010139d:	50                   	push   %eax
f010139e:	e8 4d ed ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) != 0);
f01013a3:	8d 83 0d 4b f8 ff    	lea    -0x7b4f3(%ebx),%eax
f01013a9:	50                   	push   %eax
f01013aa:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01013b0:	50                   	push   %eax
f01013b1:	68 b2 02 00 00       	push   $0x2b2
f01013b6:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01013bc:	50                   	push   %eax
f01013bd:	e8 2e ed ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01013c2:	8d 83 1e 4b f8 ff    	lea    -0x7b4e2(%ebx),%eax
f01013c8:	50                   	push   %eax
f01013c9:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01013cf:	50                   	push   %eax
f01013d0:	68 b3 02 00 00       	push   $0x2b3
f01013d5:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01013db:	50                   	push   %eax
f01013dc:	e8 0f ed ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01013e1:	8d 83 98 4e f8 ff    	lea    -0x7b168(%ebx),%eax
f01013e7:	50                   	push   %eax
f01013e8:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01013ee:	50                   	push   %eax
f01013ef:	68 b4 02 00 00       	push   $0x2b4
f01013f4:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01013fa:	50                   	push   %eax
f01013fb:	e8 f0 ec ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101400:	8d 83 37 4b f8 ff    	lea    -0x7b4c9(%ebx),%eax
f0101406:	50                   	push   %eax
f0101407:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f010140d:	50                   	push   %eax
f010140e:	68 b5 02 00 00       	push   $0x2b5
f0101413:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0101419:	50                   	push   %eax
f010141a:	e8 d1 ec ff ff       	call   f01000f0 <_panic>
	if (PGNUM(pa) >= npages)
f010141f:	89 c7                	mov    %eax,%edi
f0101421:	c1 ef 0c             	shr    $0xc,%edi
f0101424:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0101427:	76 6e                	jbe    f0101497 <check_page_free_list+0x260>
	return (void *)(pa + KERNBASE);
f0101429:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010142e:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0101431:	77 7a                	ja     f01014ad <check_page_free_list+0x276>
			++nfree_extmem;
f0101433:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101437:	8b 12                	mov    (%edx),%edx
f0101439:	85 d2                	test   %edx,%edx
f010143b:	0f 84 8b 00 00 00    	je     f01014cc <check_page_free_list+0x295>
		assert(pp >= pages);
f0101441:	39 d1                	cmp    %edx,%ecx
f0101443:	0f 87 fd fe ff ff    	ja     f0101346 <check_page_free_list+0x10f>
		assert(pp < pages + npages);
f0101449:	39 d6                	cmp    %edx,%esi
f010144b:	0f 86 14 ff ff ff    	jbe    f0101365 <check_page_free_list+0x12e>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101451:	89 d0                	mov    %edx,%eax
f0101453:	29 c8                	sub    %ecx,%eax
f0101455:	a8 07                	test   $0x7,%al
f0101457:	0f 85 27 ff ff ff    	jne    f0101384 <check_page_free_list+0x14d>
	return (pp - pages) << PGSHIFT;
f010145d:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0101460:	c1 e0 0c             	shl    $0xc,%eax
f0101463:	0f 84 3a ff ff ff    	je     f01013a3 <check_page_free_list+0x16c>
		assert(page2pa(pp) != IOPHYSMEM);
f0101469:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010146e:	0f 84 4e ff ff ff    	je     f01013c2 <check_page_free_list+0x18b>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101474:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101479:	0f 84 62 ff ff ff    	je     f01013e1 <check_page_free_list+0x1aa>
		assert(page2pa(pp) != EXTPHYSMEM);
f010147f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101484:	0f 84 76 ff ff ff    	je     f0101400 <check_page_free_list+0x1c9>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010148a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010148f:	77 8e                	ja     f010141f <check_page_free_list+0x1e8>
			++nfree_basemem;
f0101491:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
f0101495:	eb a0                	jmp    f0101437 <check_page_free_list+0x200>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101497:	50                   	push   %eax
f0101498:	8d 83 1c 4e f8 ff    	lea    -0x7b1e4(%ebx),%eax
f010149e:	50                   	push   %eax
f010149f:	6a 5c                	push   $0x5c
f01014a1:	8d 83 b1 4a f8 ff    	lea    -0x7b54f(%ebx),%eax
f01014a7:	50                   	push   %eax
f01014a8:	e8 43 ec ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01014ad:	8d 83 bc 4e f8 ff    	lea    -0x7b144(%ebx),%eax
f01014b3:	50                   	push   %eax
f01014b4:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01014ba:	50                   	push   %eax
f01014bb:	68 b6 02 00 00       	push   $0x2b6
f01014c0:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01014c6:	50                   	push   %eax
f01014c7:	e8 24 ec ff ff       	call   f01000f0 <_panic>
	assert(nfree_basemem > 0);
f01014cc:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01014cf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01014d3:	7e 1b                	jle    f01014f0 <check_page_free_list+0x2b9>
	assert(nfree_extmem > 0);
f01014d5:	85 ff                	test   %edi,%edi
f01014d7:	7e 36                	jle    f010150f <check_page_free_list+0x2d8>
	cprintf("check_page_free_list() succeeded!\n");
f01014d9:	83 ec 0c             	sub    $0xc,%esp
f01014dc:	8d 83 04 4f f8 ff    	lea    -0x7b0fc(%ebx),%eax
f01014e2:	50                   	push   %eax
f01014e3:	e8 57 2e 00 00       	call   f010433f <cprintf>
}
f01014e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014eb:	5b                   	pop    %ebx
f01014ec:	5e                   	pop    %esi
f01014ed:	5f                   	pop    %edi
f01014ee:	5d                   	pop    %ebp
f01014ef:	c3                   	ret    
	assert(nfree_basemem > 0);
f01014f0:	8d 83 51 4b f8 ff    	lea    -0x7b4af(%ebx),%eax
f01014f6:	50                   	push   %eax
f01014f7:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01014fd:	50                   	push   %eax
f01014fe:	68 be 02 00 00       	push   $0x2be
f0101503:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0101509:	50                   	push   %eax
f010150a:	e8 e1 eb ff ff       	call   f01000f0 <_panic>
	assert(nfree_extmem > 0);
f010150f:	8d 83 63 4b f8 ff    	lea    -0x7b49d(%ebx),%eax
f0101515:	50                   	push   %eax
f0101516:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f010151c:	50                   	push   %eax
f010151d:	68 bf 02 00 00       	push   $0x2bf
f0101522:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0101528:	50                   	push   %eax
f0101529:	e8 c2 eb ff ff       	call   f01000f0 <_panic>
	if (!page_free_list)
f010152e:	8b 83 14 23 00 00    	mov    0x2314(%ebx),%eax
f0101534:	85 c0                	test   %eax,%eax
f0101536:	0f 84 2a fd ff ff    	je     f0101266 <check_page_free_list+0x2f>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010153c:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010153f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101542:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101545:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101548:	89 c2                	mov    %eax,%edx
f010154a:	2b 93 04 23 00 00    	sub    0x2304(%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101550:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0101556:	0f 95 c2             	setne  %dl
f0101559:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f010155c:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101560:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101562:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101566:	8b 00                	mov    (%eax),%eax
f0101568:	85 c0                	test   %eax,%eax
f010156a:	75 dc                	jne    f0101548 <check_page_free_list+0x311>
		*tp[1] = 0;
f010156c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010156f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101575:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101578:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010157b:	89 02                	mov    %eax,(%edx)
		page_free_list = pp1;
f010157d:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101580:	89 b3 14 23 00 00    	mov    %esi,0x2314(%ebx)
		cprintf("pp1: 0x%x pp2: 0x%x\n", (int)pp1, (int)pp2);
f0101586:	83 ec 04             	sub    $0x4,%esp
f0101589:	50                   	push   %eax
f010158a:	56                   	push   %esi
f010158b:	8d 83 7a 4a f8 ff    	lea    -0x7b586(%ebx),%eax
f0101591:	50                   	push   %eax
f0101592:	e8 a8 2d 00 00       	call   f010433f <cprintf>
		cprintf("pp1 next 0x%x\n", (int)(pp1->pp_link));
f0101597:	83 c4 08             	add    $0x8,%esp
f010159a:	ff 36                	push   (%esi)
f010159c:	8d 83 8f 4a f8 ff    	lea    -0x7b571(%ebx),%eax
f01015a2:	50                   	push   %eax
f01015a3:	e8 97 2d 00 00       	call   f010433f <cprintf>
f01015a8:	83 c4 10             	add    $0x10,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01015ab:	bf 01 00 00 00       	mov    $0x1,%edi
	cprintf("low memory finish\n");
f01015b0:	83 ec 0c             	sub    $0xc,%esp
f01015b3:	8d 83 9e 4a f8 ff    	lea    -0x7b562(%ebx),%eax
f01015b9:	50                   	push   %eax
f01015ba:	e8 80 2d 00 00       	call   f010433f <cprintf>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015bf:	8b b3 14 23 00 00    	mov    0x2314(%ebx),%esi
f01015c5:	83 c4 10             	add    $0x10,%esp
f01015c8:	e9 cc fc ff ff       	jmp    f0101299 <check_page_free_list+0x62>

f01015cd <page_init>:
{
f01015cd:	55                   	push   %ebp
f01015ce:	89 e5                	mov    %esp,%ebp
f01015d0:	57                   	push   %edi
f01015d1:	56                   	push   %esi
f01015d2:	53                   	push   %ebx
f01015d3:	e8 2f 24 00 00       	call   f0103a07 <__x86.get_pc_thunk.dx>
f01015d8:	81 c2 94 02 08 00    	add    $0x80294,%edx
f01015de:	8b b2 14 23 00 00    	mov    0x2314(%edx),%esi
	for (i = 0; i < npages; i++) {
f01015e4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01015e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01015ee:	bf 01 00 00 00       	mov    $0x1,%edi
f01015f3:	eb 24                	jmp    f0101619 <page_init+0x4c>
f01015f5:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
		pages[i].pp_ref = 0;
f01015fc:	89 cb                	mov    %ecx,%ebx
f01015fe:	03 9a 04 23 00 00    	add    0x2304(%edx),%ebx
f0101604:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		pages[i].pp_link = page_free_list;
f010160a:	89 33                	mov    %esi,(%ebx)
		page_free_list = &pages[i];
f010160c:	89 ce                	mov    %ecx,%esi
f010160e:	03 b2 04 23 00 00    	add    0x2304(%edx),%esi
	for (i = 0; i < npages; i++) {
f0101614:	83 c0 01             	add    $0x1,%eax
f0101617:	89 f9                	mov    %edi,%ecx
f0101619:	39 82 0c 23 00 00    	cmp    %eax,0x230c(%edx)
f010161f:	77 d4                	ja     f01015f5 <page_init+0x28>
f0101621:	84 c9                	test   %cl,%cl
f0101623:	74 06                	je     f010162b <page_init+0x5e>
f0101625:	89 b2 14 23 00 00    	mov    %esi,0x2314(%edx)
	pages[1].pp_link = NULL;
f010162b:	8b 82 04 23 00 00    	mov    0x2304(%edx),%eax
f0101631:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	unsigned int k_use_end = PDX(kern_pgdir) + PAGE_START + PAGES_SIZE + ENVS_SIZE;
f0101638:	8b 92 08 23 00 00    	mov    0x2308(%edx),%edx
f010163e:	c1 ea 16             	shr    $0x16,%edx
	pages[k_use_end].pp_link = &pages[0x9f];  //io hole and kernel use
f0101641:	8d 88 f8 04 00 00    	lea    0x4f8(%eax),%ecx
f0101647:	89 8c d0 10 02 00 00 	mov    %ecx,0x210(%eax,%edx,8)
}
f010164e:	5b                   	pop    %ebx
f010164f:	5e                   	pop    %esi
f0101650:	5f                   	pop    %edi
f0101651:	5d                   	pop    %ebp
f0101652:	c3                   	ret    

f0101653 <page_alloc>:
{
f0101653:	55                   	push   %ebp
f0101654:	89 e5                	mov    %esp,%ebp
f0101656:	56                   	push   %esi
f0101657:	53                   	push   %ebx
f0101658:	e8 49 eb ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f010165d:	81 c3 0f 02 08 00    	add    $0x8020f,%ebx
	if (page_free_list == NULL)
f0101663:	8b b3 14 23 00 00    	mov    0x2314(%ebx),%esi
f0101669:	85 f6                	test   %esi,%esi
f010166b:	74 23                	je     f0101690 <page_alloc+0x3d>
	page_free_list = page_free_list->pp_link;
f010166d:	8b 06                	mov    (%esi),%eax
f010166f:	89 83 14 23 00 00    	mov    %eax,0x2314(%ebx)
	alloc_page->pp_ref = 0;
f0101675:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
	alloc_page->pp_link = NULL;
f010167b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (alloc_flags & ALLOC_ZERO)
f0101681:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101685:	75 1d                	jne    f01016a4 <page_alloc+0x51>
}
f0101687:	89 f0                	mov    %esi,%eax
f0101689:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010168c:	5b                   	pop    %ebx
f010168d:	5e                   	pop    %esi
f010168e:	5d                   	pop    %ebp
f010168f:	c3                   	ret    
		cprintf("none free page\n");	
f0101690:	83 ec 0c             	sub    $0xc,%esp
f0101693:	8d 83 74 4b f8 ff    	lea    -0x7b48c(%ebx),%eax
f0101699:	50                   	push   %eax
f010169a:	e8 a0 2c 00 00       	call   f010433f <cprintf>
		return NULL;
f010169f:	83 c4 10             	add    $0x10,%esp
f01016a2:	eb e3                	jmp    f0101687 <page_alloc+0x34>
f01016a4:	89 f0                	mov    %esi,%eax
f01016a6:	2b 83 04 23 00 00    	sub    0x2304(%ebx),%eax
f01016ac:	c1 f8 03             	sar    $0x3,%eax
f01016af:	89 c2                	mov    %eax,%edx
f01016b1:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01016b4:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01016b9:	3b 83 0c 23 00 00    	cmp    0x230c(%ebx),%eax
f01016bf:	73 1b                	jae    f01016dc <page_alloc+0x89>
		memset(page2kva(alloc_page), '\0', PGSIZE);
f01016c1:	83 ec 04             	sub    $0x4,%esp
f01016c4:	68 00 10 00 00       	push   $0x1000
f01016c9:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01016cb:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01016d1:	52                   	push   %edx
f01016d2:	e8 ae 40 00 00       	call   f0105785 <memset>
f01016d7:	83 c4 10             	add    $0x10,%esp
f01016da:	eb ab                	jmp    f0101687 <page_alloc+0x34>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016dc:	52                   	push   %edx
f01016dd:	8d 83 1c 4e f8 ff    	lea    -0x7b1e4(%ebx),%eax
f01016e3:	50                   	push   %eax
f01016e4:	6a 5c                	push   $0x5c
f01016e6:	8d 83 b1 4a f8 ff    	lea    -0x7b54f(%ebx),%eax
f01016ec:	50                   	push   %eax
f01016ed:	e8 fe e9 ff ff       	call   f01000f0 <_panic>

f01016f2 <page_free>:
{
f01016f2:	55                   	push   %ebp
f01016f3:	89 e5                	mov    %esp,%ebp
f01016f5:	53                   	push   %ebx
f01016f6:	83 ec 04             	sub    $0x4,%esp
f01016f9:	e8 a8 ea ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01016fe:	81 c3 6e 01 08 00    	add    $0x8016e,%ebx
f0101704:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL)
f0101707:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010170c:	75 18                	jne    f0101726 <page_free+0x34>
f010170e:	83 38 00             	cmpl   $0x0,(%eax)
f0101711:	75 13                	jne    f0101726 <page_free+0x34>
	pp->pp_link = page_free_list;
f0101713:	8b 8b 14 23 00 00    	mov    0x2314(%ebx),%ecx
f0101719:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp; 
f010171b:	89 83 14 23 00 00    	mov    %eax,0x2314(%ebx)
}
f0101721:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101724:	c9                   	leave  
f0101725:	c3                   	ret    
			panic("nonzero pp_ref or illegal pp_link");
f0101726:	83 ec 04             	sub    $0x4,%esp
f0101729:	8d 83 28 4f f8 ff    	lea    -0x7b0d8(%ebx),%eax
f010172f:	50                   	push   %eax
f0101730:	68 5c 01 00 00       	push   $0x15c
f0101735:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010173b:	50                   	push   %eax
f010173c:	e8 af e9 ff ff       	call   f01000f0 <_panic>

f0101741 <page_decref>:
{
f0101741:	55                   	push   %ebp
f0101742:	89 e5                	mov    %esp,%ebp
f0101744:	83 ec 08             	sub    $0x8,%esp
f0101747:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010174a:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010174e:	83 e8 01             	sub    $0x1,%eax
f0101751:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101755:	66 85 c0             	test   %ax,%ax
f0101758:	74 02                	je     f010175c <page_decref+0x1b>
}
f010175a:	c9                   	leave  
f010175b:	c3                   	ret    
		page_free(pp);
f010175c:	83 ec 0c             	sub    $0xc,%esp
f010175f:	52                   	push   %edx
f0101760:	e8 8d ff ff ff       	call   f01016f2 <page_free>
f0101765:	83 c4 10             	add    $0x10,%esp
}
f0101768:	eb f0                	jmp    f010175a <page_decref+0x19>

f010176a <pgdir_walk>:
{
f010176a:	55                   	push   %ebp
f010176b:	89 e5                	mov    %esp,%ebp
f010176d:	57                   	push   %edi
f010176e:	56                   	push   %esi
f010176f:	53                   	push   %ebx
f0101770:	83 ec 0c             	sub    $0xc,%esp
f0101773:	e8 97 22 00 00       	call   f0103a0f <__x86.get_pc_thunk.di>
f0101778:	81 c7 f4 00 08 00    	add    $0x800f4,%edi
	pde_t pd_entry = pgdir[PDX(va)];
f010177e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101781:	c1 eb 16             	shr    $0x16,%ebx
f0101784:	c1 e3 02             	shl    $0x2,%ebx
f0101787:	03 5d 08             	add    0x8(%ebp),%ebx
f010178a:	8b 03                	mov    (%ebx),%eax
	if ((pd_entry & PTE_P) == 0)
f010178c:	a8 01                	test   $0x1,%al
f010178e:	0f 85 aa 00 00 00    	jne    f010183e <pgdir_walk+0xd4>
		if (create == false)
f0101794:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101798:	0f 84 e2 00 00 00    	je     f0101880 <pgdir_walk+0x116>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);
f010179e:	83 ec 0c             	sub    $0xc,%esp
f01017a1:	6a 01                	push   $0x1
f01017a3:	e8 ab fe ff ff       	call   f0101653 <page_alloc>
f01017a8:	89 c6                	mov    %eax,%esi
			if (pg)
f01017aa:	83 c4 10             	add    $0x10,%esp
f01017ad:	85 c0                	test   %eax,%eax
f01017af:	74 6a                	je     f010181b <pgdir_walk+0xb1>
				pg->pp_ref++;
f01017b1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01017b6:	2b 87 04 23 00 00    	sub    0x2304(%edi),%eax
f01017bc:	c1 f8 03             	sar    $0x3,%eax
f01017bf:	c1 e0 0c             	shl    $0xc,%eax
				pgdir[PDX(va)] = page2pa(pg)|PTE_P;
f01017c2:	83 c8 01             	or     $0x1,%eax
f01017c5:	89 03                	mov    %eax,(%ebx)
				cprintf("alloc pg tab entry: 0x%x\n", page2pa(pg)|PTE_P);
f01017c7:	83 ec 08             	sub    $0x8,%esp
f01017ca:	89 f0                	mov    %esi,%eax
f01017cc:	2b 87 04 23 00 00    	sub    0x2304(%edi),%eax
f01017d2:	c1 f8 03             	sar    $0x3,%eax
f01017d5:	c1 e0 0c             	shl    $0xc,%eax
f01017d8:	83 c8 01             	or     $0x1,%eax
f01017db:	50                   	push   %eax
f01017dc:	8d 87 84 4b f8 ff    	lea    -0x7b47c(%edi),%eax
f01017e2:	50                   	push   %eax
f01017e3:	89 fb                	mov    %edi,%ebx
f01017e5:	e8 55 2b 00 00       	call   f010433f <cprintf>
f01017ea:	2b b7 04 23 00 00    	sub    0x2304(%edi),%esi
f01017f0:	c1 fe 03             	sar    $0x3,%esi
f01017f3:	89 f2                	mov    %esi,%edx
f01017f5:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01017f8:	81 e6 ff ff 0f 00    	and    $0xfffff,%esi
f01017fe:	83 c4 10             	add    $0x10,%esp
f0101801:	3b b7 0c 23 00 00    	cmp    0x230c(%edi),%esi
f0101807:	73 1c                	jae    f0101825 <pgdir_walk+0xbb>
				return  (pte_t*)(KADDR(page2pa(pg))) + PTX(va);
f0101809:	8b 45 0c             	mov    0xc(%ebp),%eax
f010180c:	c1 e8 0a             	shr    $0xa,%eax
f010180f:	25 fc 0f 00 00       	and    $0xffc,%eax
f0101814:	8d b4 02 00 00 00 f0 	lea    -0x10000000(%edx,%eax,1),%esi
}
f010181b:	89 f0                	mov    %esi,%eax
f010181d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101820:	5b                   	pop    %ebx
f0101821:	5e                   	pop    %esi
f0101822:	5f                   	pop    %edi
f0101823:	5d                   	pop    %ebp
f0101824:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101825:	52                   	push   %edx
f0101826:	8d 87 1c 4e f8 ff    	lea    -0x7b1e4(%edi),%eax
f010182c:	50                   	push   %eax
f010182d:	68 98 01 00 00       	push   $0x198
f0101832:	8d 87 6e 4a f8 ff    	lea    -0x7b592(%edi),%eax
f0101838:	50                   	push   %eax
f0101839:	e8 b2 e8 ff ff       	call   f01000f0 <_panic>
		uintptr_t *pt_addr = (uintptr_t*)(KADDR(PTE_ADDR(pd_entry)));
f010183e:	89 c2                	mov    %eax,%edx
f0101840:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101846:	c1 e8 0c             	shr    $0xc,%eax
f0101849:	3b 87 0c 23 00 00    	cmp    0x230c(%edi),%eax
f010184f:	73 14                	jae    f0101865 <pgdir_walk+0xfb>
		return pt_addr+PTX(va);
f0101851:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101854:	c1 e8 0a             	shr    $0xa,%eax
f0101857:	25 fc 0f 00 00       	and    $0xffc,%eax
f010185c:	8d b4 02 00 00 00 f0 	lea    -0x10000000(%edx,%eax,1),%esi
f0101863:	eb b6                	jmp    f010181b <pgdir_walk+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101865:	52                   	push   %edx
f0101866:	8d 87 1c 4e f8 ff    	lea    -0x7b1e4(%edi),%eax
f010186c:	50                   	push   %eax
f010186d:	68 a2 01 00 00       	push   $0x1a2
f0101872:	8d 87 6e 4a f8 ff    	lea    -0x7b592(%edi),%eax
f0101878:	50                   	push   %eax
f0101879:	89 fb                	mov    %edi,%ebx
f010187b:	e8 70 e8 ff ff       	call   f01000f0 <_panic>
			return NULL;
f0101880:	be 00 00 00 00       	mov    $0x0,%esi
f0101885:	eb 94                	jmp    f010181b <pgdir_walk+0xb1>

f0101887 <boot_map_region>:
{
f0101887:	55                   	push   %ebp
f0101888:	89 e5                	mov    %esp,%ebp
f010188a:	57                   	push   %edi
f010188b:	56                   	push   %esi
f010188c:	53                   	push   %ebx
f010188d:	83 ec 1c             	sub    $0x1c,%esp
f0101890:	e8 11 e9 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0101895:	81 c3 d7 ff 07 00    	add    $0x7ffd7,%ebx
f010189b:	8b 75 10             	mov    0x10(%ebp),%esi
	cprintf("b map  va:0x%x pa: 0x%x size: 0x%x\n", va, pa, size);
f010189e:	56                   	push   %esi
f010189f:	ff 75 14             	push   0x14(%ebp)
f01018a2:	ff 75 0c             	push   0xc(%ebp)
f01018a5:	8d 83 4c 4f f8 ff    	lea    -0x7b0b4(%ebx),%eax
f01018ab:	50                   	push   %eax
f01018ac:	e8 8e 2a 00 00       	call   f010433f <cprintf>
	for (int i = 0; i<size/PGSIZE; i++)
f01018b1:	c1 ee 0c             	shr    $0xc,%esi
f01018b4:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01018b7:	83 c4 10             	add    $0x10,%esp
f01018ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01018bd:	be 00 00 00 00       	mov    $0x0,%esi
	int j = 0;
f01018c2:	ba 00 00 00 00       	mov    $0x0,%edx
	pte_t *pt_entry  = NULL;
f01018c7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			cprintf("pde pos 0x%x\n", PDX(va+PGSIZE*i));
f01018ce:	8d 83 9e 4b f8 ff    	lea    -0x7b462(%ebx),%eax
f01018d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
		*(pt_entry+j) = (pa+i*PGSIZE) | perm | PTE_P;
f01018d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01018da:	29 f8                	sub    %edi,%eax
f01018dc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (int i = 0; i<size/PGSIZE; i++)
f01018df:	eb 1d                	jmp    f01018fe <boot_map_region+0x77>
		*(pt_entry+j) = (pa+i*PGSIZE) | perm | PTE_P;
f01018e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01018e4:	01 f8                	add    %edi,%eax
f01018e6:	0b 45 18             	or     0x18(%ebp),%eax
f01018e9:	83 c8 01             	or     $0x1,%eax
f01018ec:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01018ef:	89 04 91             	mov    %eax,(%ecx,%edx,4)
		j++;
f01018f2:	83 c2 01             	add    $0x1,%edx
	for (int i = 0; i<size/PGSIZE; i++)
f01018f5:	83 c6 01             	add    $0x1,%esi
f01018f8:	81 c7 00 10 00 00    	add    $0x1000,%edi
f01018fe:	3b 75 e0             	cmp    -0x20(%ebp),%esi
f0101901:	74 3d                	je     f0101940 <boot_map_region+0xb9>
		if (i % 1024 == 0)
f0101903:	f7 c6 ff 03 00 00    	test   $0x3ff,%esi
f0101909:	75 d6                	jne    f01018e1 <boot_map_region+0x5a>
			pt_entry = pgdir_walk(pgdir, (uintptr_t*)va+PGSIZE*i/4, 1);
f010190b:	83 ec 04             	sub    $0x4,%esp
f010190e:	6a 01                	push   $0x1
f0101910:	57                   	push   %edi
f0101911:	ff 75 08             	push   0x8(%ebp)
f0101914:	e8 51 fe ff ff       	call   f010176a <pgdir_walk>
f0101919:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			pgdir[PDX(va+PGSIZE*i)] |= perm;
f010191c:	89 f8                	mov    %edi,%eax
f010191e:	c1 e8 16             	shr    $0x16,%eax
f0101921:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101924:	8b 55 18             	mov    0x18(%ebp),%edx
f0101927:	09 14 81             	or     %edx,(%ecx,%eax,4)
			cprintf("pde pos 0x%x\n", PDX(va+PGSIZE*i));
f010192a:	83 c4 08             	add    $0x8,%esp
f010192d:	50                   	push   %eax
f010192e:	ff 75 d8             	push   -0x28(%ebp)
f0101931:	e8 09 2a 00 00       	call   f010433f <cprintf>
f0101936:	83 c4 10             	add    $0x10,%esp
			j = 0;
f0101939:	ba 00 00 00 00       	mov    $0x0,%edx
f010193e:	eb a1                	jmp    f01018e1 <boot_map_region+0x5a>
}
f0101940:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101943:	5b                   	pop    %ebx
f0101944:	5e                   	pop    %esi
f0101945:	5f                   	pop    %edi
f0101946:	5d                   	pop    %ebp
f0101947:	c3                   	ret    

f0101948 <page_lookup>:
{
f0101948:	55                   	push   %ebp
f0101949:	89 e5                	mov    %esp,%ebp
f010194b:	56                   	push   %esi
f010194c:	53                   	push   %ebx
f010194d:	e8 ea ed ff ff       	call   f010073c <__x86.get_pc_thunk.si>
f0101952:	81 c6 1a ff 07 00    	add    $0x7ff1a,%esi
f0101958:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *ptr = pgdir_walk(pgdir, va, 0);
f010195b:	83 ec 04             	sub    $0x4,%esp
f010195e:	6a 00                	push   $0x0
f0101960:	ff 75 0c             	push   0xc(%ebp)
f0101963:	ff 75 08             	push   0x8(%ebp)
f0101966:	e8 ff fd ff ff       	call   f010176a <pgdir_walk>
	if (pte_store)
f010196b:	83 c4 10             	add    $0x10,%esp
f010196e:	85 db                	test   %ebx,%ebx
f0101970:	74 02                	je     f0101974 <page_lookup+0x2c>
		*pte_store = ptr;
f0101972:	89 03                	mov    %eax,(%ebx)
	if (ptr && (*ptr & PTE_P))
f0101974:	85 c0                	test   %eax,%eax
f0101976:	74 0c                	je     f0101984 <page_lookup+0x3c>
f0101978:	8b 10                	mov    (%eax),%edx
	return NULL;
f010197a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (ptr && (*ptr & PTE_P))
f010197f:	f6 c2 01             	test   $0x1,%dl
f0101982:	75 07                	jne    f010198b <page_lookup+0x43>
}
f0101984:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101987:	5b                   	pop    %ebx
f0101988:	5e                   	pop    %esi
f0101989:	5d                   	pop    %ebp
f010198a:	c3                   	ret    
f010198b:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010198e:	39 96 0c 23 00 00    	cmp    %edx,0x230c(%esi)
f0101994:	76 0b                	jbe    f01019a1 <page_lookup+0x59>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101996:	8b 86 04 23 00 00    	mov    0x2304(%esi),%eax
f010199c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		return pa2page(PTE_ADDR(*ptr));
f010199f:	eb e3                	jmp    f0101984 <page_lookup+0x3c>
		panic("pa2page called with invalid pa");
f01019a1:	83 ec 04             	sub    $0x4,%esp
f01019a4:	8d 86 70 4f f8 ff    	lea    -0x7b090(%esi),%eax
f01019aa:	50                   	push   %eax
f01019ab:	6a 55                	push   $0x55
f01019ad:	8d 86 b1 4a f8 ff    	lea    -0x7b54f(%esi),%eax
f01019b3:	50                   	push   %eax
f01019b4:	89 f3                	mov    %esi,%ebx
f01019b6:	e8 35 e7 ff ff       	call   f01000f0 <_panic>

f01019bb <page_remove>:
{
f01019bb:	55                   	push   %ebp
f01019bc:	89 e5                	mov    %esp,%ebp
f01019be:	56                   	push   %esi
f01019bf:	53                   	push   %ebx
f01019c0:	8b 75 08             	mov    0x8(%ebp),%esi
f01019c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pgptr = page_lookup(pgdir, va, NULL);
f01019c6:	83 ec 04             	sub    $0x4,%esp
f01019c9:	6a 00                	push   $0x0
f01019cb:	53                   	push   %ebx
f01019cc:	56                   	push   %esi
f01019cd:	e8 76 ff ff ff       	call   f0101948 <page_lookup>
	if (!pgptr)
f01019d2:	83 c4 10             	add    $0x10,%esp
f01019d5:	85 c0                	test   %eax,%eax
f01019d7:	74 21                	je     f01019fa <page_remove+0x3f>
	page_decref(pgptr);
f01019d9:	83 ec 0c             	sub    $0xc,%esp
f01019dc:	50                   	push   %eax
f01019dd:	e8 5f fd ff ff       	call   f0101741 <page_decref>
	pte_t *pteptr = pgdir_walk(pgdir, va, 0);
f01019e2:	83 c4 0c             	add    $0xc,%esp
f01019e5:	6a 00                	push   $0x0
f01019e7:	53                   	push   %ebx
f01019e8:	56                   	push   %esi
f01019e9:	e8 7c fd ff ff       	call   f010176a <pgdir_walk>
	*pteptr = 0;
f01019ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01019f4:	0f 01 3b             	invlpg (%ebx)
}
f01019f7:	83 c4 10             	add    $0x10,%esp
}
f01019fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01019fd:	5b                   	pop    %ebx
f01019fe:	5e                   	pop    %esi
f01019ff:	5d                   	pop    %ebp
f0101a00:	c3                   	ret    

f0101a01 <page_insert>:
{
f0101a01:	55                   	push   %ebp
f0101a02:	89 e5                	mov    %esp,%ebp
f0101a04:	57                   	push   %edi
f0101a05:	56                   	push   %esi
f0101a06:	53                   	push   %ebx
f0101a07:	83 ec 20             	sub    $0x20,%esp
f0101a0a:	e8 00 20 00 00       	call   f0103a0f <__x86.get_pc_thunk.di>
f0101a0f:	81 c7 5d fe 07 00    	add    $0x7fe5d,%edi
f0101a15:	8b 75 08             	mov    0x8(%ebp),%esi
	pte_t *pte_ptr = pgdir_walk(pgdir, va, 0);
f0101a18:	6a 00                	push   $0x0
f0101a1a:	ff 75 10             	push   0x10(%ebp)
f0101a1d:	56                   	push   %esi
f0101a1e:	e8 47 fd ff ff       	call   f010176a <pgdir_walk>
	if (!pte_ptr)
f0101a23:	83 c4 10             	add    $0x10,%esp
f0101a26:	85 c0                	test   %eax,%eax
f0101a28:	74 43                	je     f0101a6d <page_insert+0x6c>
f0101a2a:	89 c3                	mov    %eax,%ebx
		pp->pp_ref++;
f0101a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a2f:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		if (*pte_ptr & PTE_P)
f0101a34:	f6 03 01             	testb  $0x1,(%ebx)
f0101a37:	0f 85 0c 01 00 00    	jne    f0101b49 <page_insert+0x148>
	return (pp - pages) << PGSHIFT;
f0101a3d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a40:	2b 87 04 23 00 00    	sub    0x2304(%edi),%eax
f0101a46:	c1 f8 03             	sar    $0x3,%eax
f0101a49:	c1 e0 0c             	shl    $0xc,%eax
		*pte_ptr = page2pa(pp) | perm | PTE_P;
f0101a4c:	0b 45 14             	or     0x14(%ebp),%eax
f0101a4f:	83 c8 01             	or     $0x1,%eax
f0101a52:	89 03                	mov    %eax,(%ebx)
		pgdir[PDX(va)] = pgdir[PDX(va)] | perm;
f0101a54:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a57:	c1 e8 16             	shr    $0x16,%eax
f0101a5a:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0101a5d:	09 0c 86             	or     %ecx,(%esi,%eax,4)
	return 0;
f0101a60:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a65:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101a68:	5b                   	pop    %ebx
f0101a69:	5e                   	pop    %esi
f0101a6a:	5f                   	pop    %edi
f0101a6b:	5d                   	pop    %ebp
f0101a6c:	c3                   	ret    
		struct PageInfo * pg_ptr = page_alloc(ALLOC_ZERO);
f0101a6d:	83 ec 0c             	sub    $0xc,%esp
f0101a70:	6a 01                	push   $0x1
f0101a72:	e8 dc fb ff ff       	call   f0101653 <page_alloc>
f0101a77:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if (!pg_ptr)
f0101a7a:	83 c4 10             	add    $0x10,%esp
f0101a7d:	85 c0                	test   %eax,%eax
f0101a7f:	0f 84 8d 00 00 00    	je     f0101b12 <page_insert+0x111>
f0101a85:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101a88:	2b 87 04 23 00 00    	sub    0x2304(%edi),%eax
f0101a8e:	c1 f8 03             	sar    $0x3,%eax
f0101a91:	c1 e0 0c             	shl    $0xc,%eax
		cprintf("alloc page table p addr: 0x%x\n", padd);
f0101a94:	83 ec 08             	sub    $0x8,%esp
f0101a97:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101a9a:	50                   	push   %eax
f0101a9b:	8d 87 90 4f f8 ff    	lea    -0x7b070(%edi),%eax
f0101aa1:	50                   	push   %eax
f0101aa2:	89 fb                	mov    %edi,%ebx
f0101aa4:	e8 96 28 00 00       	call   f010433f <cprintf>
		pgdir[PDX(va)] = padd | PTE_P | perm;
f0101aa9:	8b 55 10             	mov    0x10(%ebp),%edx
f0101aac:	c1 ea 16             	shr    $0x16,%edx
f0101aaf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101ab2:	89 c8                	mov    %ecx,%eax
f0101ab4:	0b 45 14             	or     0x14(%ebp),%eax
f0101ab7:	83 c8 01             	or     $0x1,%eax
f0101aba:	89 04 96             	mov    %eax,(%esi,%edx,4)
		pg_ptr->pp_ref++;
f0101abd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101ac0:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	if (PGNUM(pa) >= npages)
f0101ac5:	89 c8                	mov    %ecx,%eax
f0101ac7:	c1 e8 0c             	shr    $0xc,%eax
f0101aca:	83 c4 10             	add    $0x10,%esp
f0101acd:	3b 87 0c 23 00 00    	cmp    0x230c(%edi),%eax
f0101ad3:	73 5b                	jae    f0101b30 <page_insert+0x12f>
		kadd[PTX(va)] = page2pa(pp)|perm|PTE_P;
f0101ad5:	8b 55 10             	mov    0x10(%ebp),%edx
f0101ad8:	c1 ea 0c             	shr    $0xc,%edx
f0101adb:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
	return (pp - pages) << PGSHIFT;
f0101ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101ae4:	2b 87 04 23 00 00    	sub    0x2304(%edi),%eax
f0101aea:	c1 f8 03             	sar    $0x3,%eax
f0101aed:	c1 e0 0c             	shl    $0xc,%eax
f0101af0:	0b 45 14             	or     0x14(%ebp),%eax
f0101af3:	83 c8 01             	or     $0x1,%eax
f0101af6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101af9:	89 84 91 00 00 00 f0 	mov    %eax,-0x10000000(%ecx,%edx,4)
		pp->pp_ref++;
f0101b00:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b03:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return 0;
f0101b08:	b8 00 00 00 00       	mov    $0x0,%eax
f0101b0d:	e9 53 ff ff ff       	jmp    f0101a65 <page_insert+0x64>
			cprintf("alloc fail\n");
f0101b12:	83 ec 0c             	sub    $0xc,%esp
f0101b15:	8d 87 ac 4b f8 ff    	lea    -0x7b454(%edi),%eax
f0101b1b:	50                   	push   %eax
f0101b1c:	89 fb                	mov    %edi,%ebx
f0101b1e:	e8 1c 28 00 00       	call   f010433f <cprintf>
			return E_NO_MEM;
f0101b23:	83 c4 10             	add    $0x10,%esp
f0101b26:	b8 04 00 00 00       	mov    $0x4,%eax
f0101b2b:	e9 35 ff ff ff       	jmp    f0101a65 <page_insert+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b30:	51                   	push   %ecx
f0101b31:	8d 87 1c 4e f8 ff    	lea    -0x7b1e4(%edi),%eax
f0101b37:	50                   	push   %eax
f0101b38:	68 fa 01 00 00       	push   $0x1fa
f0101b3d:	8d 87 6e 4a f8 ff    	lea    -0x7b592(%edi),%eax
f0101b43:	50                   	push   %eax
f0101b44:	e8 a7 e5 ff ff       	call   f01000f0 <_panic>
			page_remove(pgdir, va);
f0101b49:	83 ec 08             	sub    $0x8,%esp
f0101b4c:	ff 75 10             	push   0x10(%ebp)
f0101b4f:	56                   	push   %esi
f0101b50:	e8 66 fe ff ff       	call   f01019bb <page_remove>
f0101b55:	8b 45 10             	mov    0x10(%ebp),%eax
f0101b58:	0f 01 38             	invlpg (%eax)
}
f0101b5b:	83 c4 10             	add    $0x10,%esp
f0101b5e:	e9 da fe ff ff       	jmp    f0101a3d <page_insert+0x3c>

f0101b63 <mem_init>:
{
f0101b63:	55                   	push   %ebp
f0101b64:	89 e5                	mov    %esp,%ebp
f0101b66:	57                   	push   %edi
f0101b67:	56                   	push   %esi
f0101b68:	53                   	push   %ebx
f0101b69:	83 ec 3c             	sub    $0x3c,%esp
f0101b6c:	e8 c7 eb ff ff       	call   f0100738 <__x86.get_pc_thunk.ax>
f0101b71:	05 fb fc 07 00       	add    $0x7fcfb,%eax
f0101b76:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f0101b79:	b8 15 00 00 00       	mov    $0x15,%eax
f0101b7e:	e8 02 f6 ff ff       	call   f0101185 <nvram_read>
f0101b83:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101b85:	b8 17 00 00 00       	mov    $0x17,%eax
f0101b8a:	e8 f6 f5 ff ff       	call   f0101185 <nvram_read>
f0101b8f:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101b91:	b8 34 00 00 00       	mov    $0x34,%eax
f0101b96:	e8 ea f5 ff ff       	call   f0101185 <nvram_read>
	if (ext16mem)
f0101b9b:	c1 e0 06             	shl    $0x6,%eax
f0101b9e:	0f 84 02 01 00 00    	je     f0101ca6 <mem_init+0x143>
		totalmem = 16 * 1024 + ext16mem;
f0101ba4:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101ba9:	89 c2                	mov    %eax,%edx
f0101bab:	c1 ea 02             	shr    $0x2,%edx
f0101bae:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101bb1:	89 91 0c 23 00 00    	mov    %edx,0x230c(%ecx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101bb7:	89 c2                	mov    %eax,%edx
f0101bb9:	29 da                	sub    %ebx,%edx
f0101bbb:	52                   	push   %edx
f0101bbc:	53                   	push   %ebx
f0101bbd:	50                   	push   %eax
f0101bbe:	8d 81 b0 4f f8 ff    	lea    -0x7b050(%ecx),%eax
f0101bc4:	50                   	push   %eax
f0101bc5:	89 cb                	mov    %ecx,%ebx
f0101bc7:	e8 73 27 00 00       	call   f010433f <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101bcc:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101bd1:	e8 32 f5 ff ff       	call   f0101108 <boot_alloc>
f0101bd6:	89 83 08 23 00 00    	mov    %eax,0x2308(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f0101bdc:	83 c4 0c             	add    $0xc,%esp
f0101bdf:	68 00 10 00 00       	push   $0x1000
f0101be4:	6a 00                	push   $0x0
f0101be6:	50                   	push   %eax
f0101be7:	e8 99 3b 00 00       	call   f0105785 <memset>
	cprintf("bootstack_addr: 0x%x\n", (int)bootstack);
f0101bec:	83 c4 08             	add    $0x8,%esp
f0101bef:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f0101bf5:	8d 83 b8 4b f8 ff    	lea    -0x7b448(%ebx),%eax
f0101bfb:	50                   	push   %eax
f0101bfc:	e8 3e 27 00 00       	call   f010433f <cprintf>
	cprintf("kern_pgdir addr: 0x%x\n", (u32)kern_pgdir);
f0101c01:	83 c4 08             	add    $0x8,%esp
f0101c04:	ff b3 08 23 00 00    	push   0x2308(%ebx)
f0101c0a:	8d 83 ce 4b f8 ff    	lea    -0x7b432(%ebx),%eax
f0101c10:	50                   	push   %eax
f0101c11:	e8 29 27 00 00       	call   f010433f <cprintf>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101c16:	8b 83 08 23 00 00    	mov    0x2308(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0101c1c:	83 c4 10             	add    $0x10,%esp
f0101c1f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101c24:	0f 86 8c 00 00 00    	jbe    f0101cb6 <mem_init+0x153>
	return (physaddr_t)kva - KERNBASE;
f0101c2a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101c30:	83 ca 05             	or     $0x5,%edx
f0101c33:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(npages*8);
f0101c39:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101c3c:	8b 87 0c 23 00 00    	mov    0x230c(%edi),%eax
f0101c42:	c1 e0 03             	shl    $0x3,%eax
f0101c45:	e8 be f4 ff ff       	call   f0101108 <boot_alloc>
f0101c4a:	89 87 04 23 00 00    	mov    %eax,0x2304(%edi)
	memset(pages, 0, npages * 8);
f0101c50:	83 ec 04             	sub    $0x4,%esp
f0101c53:	8b 97 0c 23 00 00    	mov    0x230c(%edi),%edx
f0101c59:	c1 e2 03             	shl    $0x3,%edx
f0101c5c:	52                   	push   %edx
f0101c5d:	6a 00                	push   $0x0
f0101c5f:	50                   	push   %eax
f0101c60:	89 fb                	mov    %edi,%ebx
f0101c62:	e8 1e 3b 00 00       	call   f0105785 <memset>
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f0101c67:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101c6c:	e8 97 f4 ff ff       	call   f0101108 <boot_alloc>
f0101c71:	89 c2                	mov    %eax,%edx
f0101c73:	c7 c0 88 3b 18 f0    	mov    $0xf0183b88,%eax
f0101c79:	89 10                	mov    %edx,(%eax)
	page_init();
f0101c7b:	e8 4d f9 ff ff       	call   f01015cd <page_init>
	check_page_free_list(1);
f0101c80:	b8 01 00 00 00       	mov    $0x1,%eax
f0101c85:	e8 ad f5 ff ff       	call   f0101237 <check_page_free_list>
	if (!pages)
f0101c8a:	83 c4 10             	add    $0x10,%esp
f0101c8d:	83 bf 04 23 00 00 00 	cmpl   $0x0,0x2304(%edi)
f0101c94:	74 3c                	je     f0101cd2 <mem_init+0x16f>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101c96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c99:	8b 80 14 23 00 00    	mov    0x2314(%eax),%eax
f0101c9f:	be 00 00 00 00       	mov    $0x0,%esi
f0101ca4:	eb 4f                	jmp    f0101cf5 <mem_init+0x192>
		totalmem = 1 * 1024 + extmem;
f0101ca6:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101cac:	85 f6                	test   %esi,%esi
f0101cae:	0f 44 c3             	cmove  %ebx,%eax
f0101cb1:	e9 f3 fe ff ff       	jmp    f0101ba9 <mem_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101cb6:	50                   	push   %eax
f0101cb7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101cba:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f0101cc0:	50                   	push   %eax
f0101cc1:	68 96 00 00 00       	push   $0x96
f0101cc6:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0101ccc:	50                   	push   %eax
f0101ccd:	e8 1e e4 ff ff       	call   f01000f0 <_panic>
		panic("'pages' is a null pointer!");
f0101cd2:	83 ec 04             	sub    $0x4,%esp
f0101cd5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101cd8:	8d 83 e5 4b f8 ff    	lea    -0x7b41b(%ebx),%eax
f0101cde:	50                   	push   %eax
f0101cdf:	68 d2 02 00 00       	push   $0x2d2
f0101ce4:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0101cea:	50                   	push   %eax
f0101ceb:	e8 00 e4 ff ff       	call   f01000f0 <_panic>
		++nfree;
f0101cf0:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101cf3:	8b 00                	mov    (%eax),%eax
f0101cf5:	85 c0                	test   %eax,%eax
f0101cf7:	75 f7                	jne    f0101cf0 <mem_init+0x18d>
	assert((pp0 = page_alloc(0)));
f0101cf9:	83 ec 0c             	sub    $0xc,%esp
f0101cfc:	6a 00                	push   $0x0
f0101cfe:	e8 50 f9 ff ff       	call   f0101653 <page_alloc>
f0101d03:	89 c3                	mov    %eax,%ebx
f0101d05:	83 c4 10             	add    $0x10,%esp
f0101d08:	85 c0                	test   %eax,%eax
f0101d0a:	0f 84 3a 02 00 00    	je     f0101f4a <mem_init+0x3e7>
	assert((pp1 = page_alloc(0)));
f0101d10:	83 ec 0c             	sub    $0xc,%esp
f0101d13:	6a 00                	push   $0x0
f0101d15:	e8 39 f9 ff ff       	call   f0101653 <page_alloc>
f0101d1a:	89 c7                	mov    %eax,%edi
f0101d1c:	83 c4 10             	add    $0x10,%esp
f0101d1f:	85 c0                	test   %eax,%eax
f0101d21:	0f 84 45 02 00 00    	je     f0101f6c <mem_init+0x409>
	assert((pp2 = page_alloc(0)));
f0101d27:	83 ec 0c             	sub    $0xc,%esp
f0101d2a:	6a 00                	push   $0x0
f0101d2c:	e8 22 f9 ff ff       	call   f0101653 <page_alloc>
f0101d31:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101d34:	83 c4 10             	add    $0x10,%esp
f0101d37:	85 c0                	test   %eax,%eax
f0101d39:	0f 84 4f 02 00 00    	je     f0101f8e <mem_init+0x42b>
	assert(pp1 && pp1 != pp0);
f0101d3f:	39 fb                	cmp    %edi,%ebx
f0101d41:	0f 84 69 02 00 00    	je     f0101fb0 <mem_init+0x44d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d47:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d4a:	39 c3                	cmp    %eax,%ebx
f0101d4c:	0f 84 80 02 00 00    	je     f0101fd2 <mem_init+0x46f>
f0101d52:	39 c7                	cmp    %eax,%edi
f0101d54:	0f 84 78 02 00 00    	je     f0101fd2 <mem_init+0x46f>
	return (pp - pages) << PGSHIFT;
f0101d5a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d5d:	8b 88 04 23 00 00    	mov    0x2304(%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101d63:	8b 90 0c 23 00 00    	mov    0x230c(%eax),%edx
f0101d69:	c1 e2 0c             	shl    $0xc,%edx
f0101d6c:	89 d8                	mov    %ebx,%eax
f0101d6e:	29 c8                	sub    %ecx,%eax
f0101d70:	c1 f8 03             	sar    $0x3,%eax
f0101d73:	c1 e0 0c             	shl    $0xc,%eax
f0101d76:	39 d0                	cmp    %edx,%eax
f0101d78:	0f 83 76 02 00 00    	jae    f0101ff4 <mem_init+0x491>
f0101d7e:	89 f8                	mov    %edi,%eax
f0101d80:	29 c8                	sub    %ecx,%eax
f0101d82:	c1 f8 03             	sar    $0x3,%eax
f0101d85:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101d88:	39 c2                	cmp    %eax,%edx
f0101d8a:	0f 86 86 02 00 00    	jbe    f0102016 <mem_init+0x4b3>
f0101d90:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d93:	29 c8                	sub    %ecx,%eax
f0101d95:	c1 f8 03             	sar    $0x3,%eax
f0101d98:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101d9b:	39 c2                	cmp    %eax,%edx
f0101d9d:	0f 86 95 02 00 00    	jbe    f0102038 <mem_init+0x4d5>
	fl = page_free_list;
f0101da3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101da6:	8b 88 14 23 00 00    	mov    0x2314(%eax),%ecx
f0101dac:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101daf:	c7 80 14 23 00 00 00 	movl   $0x0,0x2314(%eax)
f0101db6:	00 00 00 
	assert(!page_alloc(0));
f0101db9:	83 ec 0c             	sub    $0xc,%esp
f0101dbc:	6a 00                	push   $0x0
f0101dbe:	e8 90 f8 ff ff       	call   f0101653 <page_alloc>
f0101dc3:	83 c4 10             	add    $0x10,%esp
f0101dc6:	85 c0                	test   %eax,%eax
f0101dc8:	0f 85 8c 02 00 00    	jne    f010205a <mem_init+0x4f7>
	page_free(pp0);
f0101dce:	83 ec 0c             	sub    $0xc,%esp
f0101dd1:	53                   	push   %ebx
f0101dd2:	e8 1b f9 ff ff       	call   f01016f2 <page_free>
	page_free(pp1);
f0101dd7:	89 3c 24             	mov    %edi,(%esp)
f0101dda:	e8 13 f9 ff ff       	call   f01016f2 <page_free>
	page_free(pp2);
f0101ddf:	83 c4 04             	add    $0x4,%esp
f0101de2:	ff 75 d0             	push   -0x30(%ebp)
f0101de5:	e8 08 f9 ff ff       	call   f01016f2 <page_free>
	assert((pp0 = page_alloc(0)));
f0101dea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101df1:	e8 5d f8 ff ff       	call   f0101653 <page_alloc>
f0101df6:	89 c7                	mov    %eax,%edi
f0101df8:	83 c4 10             	add    $0x10,%esp
f0101dfb:	85 c0                	test   %eax,%eax
f0101dfd:	0f 84 79 02 00 00    	je     f010207c <mem_init+0x519>
	assert((pp1 = page_alloc(0)));
f0101e03:	83 ec 0c             	sub    $0xc,%esp
f0101e06:	6a 00                	push   $0x0
f0101e08:	e8 46 f8 ff ff       	call   f0101653 <page_alloc>
f0101e0d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101e10:	83 c4 10             	add    $0x10,%esp
f0101e13:	85 c0                	test   %eax,%eax
f0101e15:	0f 84 83 02 00 00    	je     f010209e <mem_init+0x53b>
	assert((pp2 = page_alloc(0)));
f0101e1b:	83 ec 0c             	sub    $0xc,%esp
f0101e1e:	6a 00                	push   $0x0
f0101e20:	e8 2e f8 ff ff       	call   f0101653 <page_alloc>
f0101e25:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e28:	83 c4 10             	add    $0x10,%esp
f0101e2b:	85 c0                	test   %eax,%eax
f0101e2d:	0f 84 8d 02 00 00    	je     f01020c0 <mem_init+0x55d>
	assert(pp1 && pp1 != pp0);
f0101e33:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0101e36:	0f 84 a6 02 00 00    	je     f01020e2 <mem_init+0x57f>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101e3c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101e3f:	39 c7                	cmp    %eax,%edi
f0101e41:	0f 84 bd 02 00 00    	je     f0102104 <mem_init+0x5a1>
f0101e47:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101e4a:	0f 84 b4 02 00 00    	je     f0102104 <mem_init+0x5a1>
	assert(!page_alloc(0));
f0101e50:	83 ec 0c             	sub    $0xc,%esp
f0101e53:	6a 00                	push   $0x0
f0101e55:	e8 f9 f7 ff ff       	call   f0101653 <page_alloc>
f0101e5a:	83 c4 10             	add    $0x10,%esp
f0101e5d:	85 c0                	test   %eax,%eax
f0101e5f:	0f 85 c1 02 00 00    	jne    f0102126 <mem_init+0x5c3>
f0101e65:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e68:	89 f8                	mov    %edi,%eax
f0101e6a:	2b 81 04 23 00 00    	sub    0x2304(%ecx),%eax
f0101e70:	c1 f8 03             	sar    $0x3,%eax
f0101e73:	89 c2                	mov    %eax,%edx
f0101e75:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e78:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e7d:	3b 81 0c 23 00 00    	cmp    0x230c(%ecx),%eax
f0101e83:	0f 83 bf 02 00 00    	jae    f0102148 <mem_init+0x5e5>
	memset(page2kva(pp0), 1, PGSIZE);
f0101e89:	83 ec 04             	sub    $0x4,%esp
f0101e8c:	68 00 10 00 00       	push   $0x1000
f0101e91:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101e93:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101e99:	52                   	push   %edx
f0101e9a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e9d:	e8 e3 38 00 00       	call   f0105785 <memset>
	page_free(pp0);
f0101ea2:	89 3c 24             	mov    %edi,(%esp)
f0101ea5:	e8 48 f8 ff ff       	call   f01016f2 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101eaa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101eb1:	e8 9d f7 ff ff       	call   f0101653 <page_alloc>
f0101eb6:	83 c4 10             	add    $0x10,%esp
f0101eb9:	85 c0                	test   %eax,%eax
f0101ebb:	0f 84 9f 02 00 00    	je     f0102160 <mem_init+0x5fd>
	assert(pp && pp0 == pp);
f0101ec1:	39 c7                	cmp    %eax,%edi
f0101ec3:	0f 85 b9 02 00 00    	jne    f0102182 <mem_init+0x61f>
	return (pp - pages) << PGSHIFT;
f0101ec9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101ecc:	2b 81 04 23 00 00    	sub    0x2304(%ecx),%eax
f0101ed2:	c1 f8 03             	sar    $0x3,%eax
f0101ed5:	89 c2                	mov    %eax,%edx
f0101ed7:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101eda:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101edf:	3b 81 0c 23 00 00    	cmp    0x230c(%ecx),%eax
f0101ee5:	0f 83 b9 02 00 00    	jae    f01021a4 <mem_init+0x641>
	return (void *)(pa + KERNBASE);
f0101eeb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101ef1:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101ef7:	80 38 00             	cmpb   $0x0,(%eax)
f0101efa:	0f 85 bc 02 00 00    	jne    f01021bc <mem_init+0x659>
	for (i = 0; i < PGSIZE; i++)
f0101f00:	83 c0 01             	add    $0x1,%eax
f0101f03:	39 d0                	cmp    %edx,%eax
f0101f05:	75 f0                	jne    f0101ef7 <mem_init+0x394>
	page_free_list = fl;
f0101f07:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f0a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101f0d:	89 8b 14 23 00 00    	mov    %ecx,0x2314(%ebx)
	page_free(pp0);
f0101f13:	83 ec 0c             	sub    $0xc,%esp
f0101f16:	57                   	push   %edi
f0101f17:	e8 d6 f7 ff ff       	call   f01016f2 <page_free>
	page_free(pp1);
f0101f1c:	83 c4 04             	add    $0x4,%esp
f0101f1f:	ff 75 d0             	push   -0x30(%ebp)
f0101f22:	e8 cb f7 ff ff       	call   f01016f2 <page_free>
	page_free(pp2);
f0101f27:	83 c4 04             	add    $0x4,%esp
f0101f2a:	ff 75 cc             	push   -0x34(%ebp)
f0101f2d:	e8 c0 f7 ff ff       	call   f01016f2 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f32:	8b 83 14 23 00 00    	mov    0x2314(%ebx),%eax
f0101f38:	83 c4 10             	add    $0x10,%esp
f0101f3b:	85 c0                	test   %eax,%eax
f0101f3d:	0f 84 9b 02 00 00    	je     f01021de <mem_init+0x67b>
		--nfree;
f0101f43:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f46:	8b 00                	mov    (%eax),%eax
f0101f48:	eb f1                	jmp    f0101f3b <mem_init+0x3d8>
	assert((pp0 = page_alloc(0)));
f0101f4a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f4d:	8d 83 00 4c f8 ff    	lea    -0x7b400(%ebx),%eax
f0101f53:	50                   	push   %eax
f0101f54:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0101f5a:	50                   	push   %eax
f0101f5b:	68 da 02 00 00       	push   $0x2da
f0101f60:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0101f66:	50                   	push   %eax
f0101f67:	e8 84 e1 ff ff       	call   f01000f0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f6c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f6f:	8d 83 16 4c f8 ff    	lea    -0x7b3ea(%ebx),%eax
f0101f75:	50                   	push   %eax
f0101f76:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0101f7c:	50                   	push   %eax
f0101f7d:	68 db 02 00 00       	push   $0x2db
f0101f82:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0101f88:	50                   	push   %eax
f0101f89:	e8 62 e1 ff ff       	call   f01000f0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f8e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f91:	8d 83 2c 4c f8 ff    	lea    -0x7b3d4(%ebx),%eax
f0101f97:	50                   	push   %eax
f0101f98:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0101f9e:	50                   	push   %eax
f0101f9f:	68 dc 02 00 00       	push   $0x2dc
f0101fa4:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0101faa:	50                   	push   %eax
f0101fab:	e8 40 e1 ff ff       	call   f01000f0 <_panic>
	assert(pp1 && pp1 != pp0);
f0101fb0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fb3:	8d 83 42 4c f8 ff    	lea    -0x7b3be(%ebx),%eax
f0101fb9:	50                   	push   %eax
f0101fba:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0101fc0:	50                   	push   %eax
f0101fc1:	68 df 02 00 00       	push   $0x2df
f0101fc6:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0101fcc:	50                   	push   %eax
f0101fcd:	e8 1e e1 ff ff       	call   f01000f0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101fd2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fd5:	8d 83 10 50 f8 ff    	lea    -0x7aff0(%ebx),%eax
f0101fdb:	50                   	push   %eax
f0101fdc:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0101fe2:	50                   	push   %eax
f0101fe3:	68 e0 02 00 00       	push   $0x2e0
f0101fe8:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0101fee:	50                   	push   %eax
f0101fef:	e8 fc e0 ff ff       	call   f01000f0 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101ff4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ff7:	8d 83 54 4c f8 ff    	lea    -0x7b3ac(%ebx),%eax
f0101ffd:	50                   	push   %eax
f0101ffe:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102004:	50                   	push   %eax
f0102005:	68 e1 02 00 00       	push   $0x2e1
f010200a:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102010:	50                   	push   %eax
f0102011:	e8 da e0 ff ff       	call   f01000f0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0102016:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102019:	8d 83 71 4c f8 ff    	lea    -0x7b38f(%ebx),%eax
f010201f:	50                   	push   %eax
f0102020:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102026:	50                   	push   %eax
f0102027:	68 e2 02 00 00       	push   $0x2e2
f010202c:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102032:	50                   	push   %eax
f0102033:	e8 b8 e0 ff ff       	call   f01000f0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0102038:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010203b:	8d 83 8e 4c f8 ff    	lea    -0x7b372(%ebx),%eax
f0102041:	50                   	push   %eax
f0102042:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102048:	50                   	push   %eax
f0102049:	68 e3 02 00 00       	push   $0x2e3
f010204e:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102054:	50                   	push   %eax
f0102055:	e8 96 e0 ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f010205a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010205d:	8d 83 ab 4c f8 ff    	lea    -0x7b355(%ebx),%eax
f0102063:	50                   	push   %eax
f0102064:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f010206a:	50                   	push   %eax
f010206b:	68 ea 02 00 00       	push   $0x2ea
f0102070:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102076:	50                   	push   %eax
f0102077:	e8 74 e0 ff ff       	call   f01000f0 <_panic>
	assert((pp0 = page_alloc(0)));
f010207c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010207f:	8d 83 00 4c f8 ff    	lea    -0x7b400(%ebx),%eax
f0102085:	50                   	push   %eax
f0102086:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f010208c:	50                   	push   %eax
f010208d:	68 f1 02 00 00       	push   $0x2f1
f0102092:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102098:	50                   	push   %eax
f0102099:	e8 52 e0 ff ff       	call   f01000f0 <_panic>
	assert((pp1 = page_alloc(0)));
f010209e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020a1:	8d 83 16 4c f8 ff    	lea    -0x7b3ea(%ebx),%eax
f01020a7:	50                   	push   %eax
f01020a8:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01020ae:	50                   	push   %eax
f01020af:	68 f2 02 00 00       	push   $0x2f2
f01020b4:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01020ba:	50                   	push   %eax
f01020bb:	e8 30 e0 ff ff       	call   f01000f0 <_panic>
	assert((pp2 = page_alloc(0)));
f01020c0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020c3:	8d 83 2c 4c f8 ff    	lea    -0x7b3d4(%ebx),%eax
f01020c9:	50                   	push   %eax
f01020ca:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01020d0:	50                   	push   %eax
f01020d1:	68 f3 02 00 00       	push   $0x2f3
f01020d6:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01020dc:	50                   	push   %eax
f01020dd:	e8 0e e0 ff ff       	call   f01000f0 <_panic>
	assert(pp1 && pp1 != pp0);
f01020e2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020e5:	8d 83 42 4c f8 ff    	lea    -0x7b3be(%ebx),%eax
f01020eb:	50                   	push   %eax
f01020ec:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01020f2:	50                   	push   %eax
f01020f3:	68 f5 02 00 00       	push   $0x2f5
f01020f8:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01020fe:	50                   	push   %eax
f01020ff:	e8 ec df ff ff       	call   f01000f0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102104:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102107:	8d 83 10 50 f8 ff    	lea    -0x7aff0(%ebx),%eax
f010210d:	50                   	push   %eax
f010210e:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102114:	50                   	push   %eax
f0102115:	68 f6 02 00 00       	push   $0x2f6
f010211a:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102120:	50                   	push   %eax
f0102121:	e8 ca df ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f0102126:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102129:	8d 83 ab 4c f8 ff    	lea    -0x7b355(%ebx),%eax
f010212f:	50                   	push   %eax
f0102130:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102136:	50                   	push   %eax
f0102137:	68 f7 02 00 00       	push   $0x2f7
f010213c:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102142:	50                   	push   %eax
f0102143:	e8 a8 df ff ff       	call   f01000f0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102148:	52                   	push   %edx
f0102149:	89 cb                	mov    %ecx,%ebx
f010214b:	8d 81 1c 4e f8 ff    	lea    -0x7b1e4(%ecx),%eax
f0102151:	50                   	push   %eax
f0102152:	6a 5c                	push   $0x5c
f0102154:	8d 81 b1 4a f8 ff    	lea    -0x7b54f(%ecx),%eax
f010215a:	50                   	push   %eax
f010215b:	e8 90 df ff ff       	call   f01000f0 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102160:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102163:	8d 83 ba 4c f8 ff    	lea    -0x7b346(%ebx),%eax
f0102169:	50                   	push   %eax
f010216a:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102170:	50                   	push   %eax
f0102171:	68 fc 02 00 00       	push   $0x2fc
f0102176:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010217c:	50                   	push   %eax
f010217d:	e8 6e df ff ff       	call   f01000f0 <_panic>
	assert(pp && pp0 == pp);
f0102182:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102185:	8d 83 d8 4c f8 ff    	lea    -0x7b328(%ebx),%eax
f010218b:	50                   	push   %eax
f010218c:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102192:	50                   	push   %eax
f0102193:	68 fd 02 00 00       	push   $0x2fd
f0102198:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010219e:	50                   	push   %eax
f010219f:	e8 4c df ff ff       	call   f01000f0 <_panic>
f01021a4:	52                   	push   %edx
f01021a5:	89 cb                	mov    %ecx,%ebx
f01021a7:	8d 81 1c 4e f8 ff    	lea    -0x7b1e4(%ecx),%eax
f01021ad:	50                   	push   %eax
f01021ae:	6a 5c                	push   $0x5c
f01021b0:	8d 81 b1 4a f8 ff    	lea    -0x7b54f(%ecx),%eax
f01021b6:	50                   	push   %eax
f01021b7:	e8 34 df ff ff       	call   f01000f0 <_panic>
		assert(c[i] == 0);
f01021bc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021bf:	8d 83 e8 4c f8 ff    	lea    -0x7b318(%ebx),%eax
f01021c5:	50                   	push   %eax
f01021c6:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01021cc:	50                   	push   %eax
f01021cd:	68 00 03 00 00       	push   $0x300
f01021d2:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01021d8:	50                   	push   %eax
f01021d9:	e8 12 df ff ff       	call   f01000f0 <_panic>
	assert(nfree == 0);
f01021de:	85 f6                	test   %esi,%esi
f01021e0:	0f 85 e6 08 00 00    	jne    f0102acc <mem_init+0xf69>
	cprintf("check_page_alloc() succeeded!\n");
f01021e6:	83 ec 0c             	sub    $0xc,%esp
f01021e9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021ec:	8d 83 30 50 f8 ff    	lea    -0x7afd0(%ebx),%eax
f01021f2:	50                   	push   %eax
f01021f3:	e8 47 21 00 00       	call   f010433f <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01021f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021ff:	e8 4f f4 ff ff       	call   f0101653 <page_alloc>
f0102204:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102207:	83 c4 10             	add    $0x10,%esp
f010220a:	85 c0                	test   %eax,%eax
f010220c:	0f 84 dc 08 00 00    	je     f0102aee <mem_init+0xf8b>
	assert((pp1 = page_alloc(0)));
f0102212:	83 ec 0c             	sub    $0xc,%esp
f0102215:	6a 00                	push   $0x0
f0102217:	e8 37 f4 ff ff       	call   f0101653 <page_alloc>
f010221c:	89 c7                	mov    %eax,%edi
f010221e:	83 c4 10             	add    $0x10,%esp
f0102221:	85 c0                	test   %eax,%eax
f0102223:	0f 84 e7 08 00 00    	je     f0102b10 <mem_init+0xfad>
	assert((pp2 = page_alloc(0)));
f0102229:	83 ec 0c             	sub    $0xc,%esp
f010222c:	6a 00                	push   $0x0
f010222e:	e8 20 f4 ff ff       	call   f0101653 <page_alloc>
f0102233:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102236:	83 c4 10             	add    $0x10,%esp
f0102239:	85 c0                	test   %eax,%eax
f010223b:	0f 84 f1 08 00 00    	je     f0102b32 <mem_init+0xfcf>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102241:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102244:	0f 84 0a 09 00 00    	je     f0102b54 <mem_init+0xff1>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010224a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010224d:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102250:	0f 84 20 09 00 00    	je     f0102b76 <mem_init+0x1013>
f0102256:	39 c7                	cmp    %eax,%edi
f0102258:	0f 84 18 09 00 00    	je     f0102b76 <mem_init+0x1013>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010225e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102261:	8b 88 14 23 00 00    	mov    0x2314(%eax),%ecx
f0102267:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f010226a:	c7 80 14 23 00 00 00 	movl   $0x0,0x2314(%eax)
f0102271:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102274:	83 ec 0c             	sub    $0xc,%esp
f0102277:	6a 00                	push   $0x0
f0102279:	e8 d5 f3 ff ff       	call   f0101653 <page_alloc>
f010227e:	83 c4 10             	add    $0x10,%esp
f0102281:	85 c0                	test   %eax,%eax
f0102283:	0f 85 0f 09 00 00    	jne    f0102b98 <mem_init+0x1035>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102289:	83 ec 04             	sub    $0x4,%esp
f010228c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010228f:	50                   	push   %eax
f0102290:	6a 00                	push   $0x0
f0102292:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102295:	ff b0 08 23 00 00    	push   0x2308(%eax)
f010229b:	e8 a8 f6 ff ff       	call   f0101948 <page_lookup>
f01022a0:	83 c4 10             	add    $0x10,%esp
f01022a3:	85 c0                	test   %eax,%eax
f01022a5:	0f 85 0f 09 00 00    	jne    f0102bba <mem_init+0x1057>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) != 0);
f01022ab:	6a 02                	push   $0x2
f01022ad:	6a 00                	push   $0x0
f01022af:	57                   	push   %edi
f01022b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022b3:	ff b0 08 23 00 00    	push   0x2308(%eax)
f01022b9:	e8 43 f7 ff ff       	call   f0101a01 <page_insert>
f01022be:	83 c4 10             	add    $0x10,%esp
f01022c1:	85 c0                	test   %eax,%eax
f01022c3:	0f 84 13 09 00 00    	je     f0102bdc <mem_init+0x1079>
	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01022c9:	83 ec 0c             	sub    $0xc,%esp
f01022cc:	ff 75 cc             	push   -0x34(%ebp)
f01022cf:	e8 1e f4 ff ff       	call   f01016f2 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022d4:	6a 02                	push   $0x2
f01022d6:	6a 00                	push   $0x0
f01022d8:	57                   	push   %edi
f01022d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022dc:	ff b0 08 23 00 00    	push   0x2308(%eax)
f01022e2:	e8 1a f7 ff ff       	call   f0101a01 <page_insert>
f01022e7:	83 c4 20             	add    $0x20,%esp
f01022ea:	85 c0                	test   %eax,%eax
f01022ec:	0f 85 0c 09 00 00    	jne    f0102bfe <mem_init+0x109b>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022f5:	8b 98 08 23 00 00    	mov    0x2308(%eax),%ebx
	return (pp - pages) << PGSHIFT;
f01022fb:	8b b0 04 23 00 00    	mov    0x2304(%eax),%esi
f0102301:	8b 13                	mov    (%ebx),%edx
f0102303:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102309:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010230c:	29 f0                	sub    %esi,%eax
f010230e:	c1 f8 03             	sar    $0x3,%eax
f0102311:	c1 e0 0c             	shl    $0xc,%eax
f0102314:	39 c2                	cmp    %eax,%edx
f0102316:	0f 85 04 09 00 00    	jne    f0102c20 <mem_init+0x10bd>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010231c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102321:	89 d8                	mov    %ebx,%eax
f0102323:	e8 93 ee ff ff       	call   f01011bb <check_va2pa>
f0102328:	89 c2                	mov    %eax,%edx
f010232a:	89 f8                	mov    %edi,%eax
f010232c:	29 f0                	sub    %esi,%eax
f010232e:	c1 f8 03             	sar    $0x3,%eax
f0102331:	c1 e0 0c             	shl    $0xc,%eax
f0102334:	39 c2                	cmp    %eax,%edx
f0102336:	0f 85 06 09 00 00    	jne    f0102c42 <mem_init+0x10df>
	assert(pp1->pp_ref == 1);
f010233c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102341:	0f 85 1d 09 00 00    	jne    f0102c64 <mem_init+0x1101>
	assert(pp0->pp_ref == 1);
f0102347:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010234a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010234f:	0f 85 31 09 00 00    	jne    f0102c86 <mem_init+0x1123>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102355:	6a 02                	push   $0x2
f0102357:	68 00 10 00 00       	push   $0x1000
f010235c:	ff 75 d0             	push   -0x30(%ebp)
f010235f:	53                   	push   %ebx
f0102360:	e8 9c f6 ff ff       	call   f0101a01 <page_insert>
f0102365:	83 c4 10             	add    $0x10,%esp
f0102368:	85 c0                	test   %eax,%eax
f010236a:	0f 85 38 09 00 00    	jne    f0102ca8 <mem_init+0x1145>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102370:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102375:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102378:	8b 83 08 23 00 00    	mov    0x2308(%ebx),%eax
f010237e:	e8 38 ee ff ff       	call   f01011bb <check_va2pa>
f0102383:	89 c2                	mov    %eax,%edx
f0102385:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102388:	2b 83 04 23 00 00    	sub    0x2304(%ebx),%eax
f010238e:	c1 f8 03             	sar    $0x3,%eax
f0102391:	c1 e0 0c             	shl    $0xc,%eax
f0102394:	39 c2                	cmp    %eax,%edx
f0102396:	0f 85 2e 09 00 00    	jne    f0102cca <mem_init+0x1167>
	assert(pp2->pp_ref == 1);
f010239c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010239f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01023a4:	0f 85 42 09 00 00    	jne    f0102cec <mem_init+0x1189>

	// should be no free memory
	assert(!page_alloc(0));
f01023aa:	83 ec 0c             	sub    $0xc,%esp
f01023ad:	6a 00                	push   $0x0
f01023af:	e8 9f f2 ff ff       	call   f0101653 <page_alloc>
f01023b4:	83 c4 10             	add    $0x10,%esp
f01023b7:	85 c0                	test   %eax,%eax
f01023b9:	0f 85 4f 09 00 00    	jne    f0102d0e <mem_init+0x11ab>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023bf:	6a 02                	push   $0x2
f01023c1:	68 00 10 00 00       	push   $0x1000
f01023c6:	ff 75 d0             	push   -0x30(%ebp)
f01023c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023cc:	ff b0 08 23 00 00    	push   0x2308(%eax)
f01023d2:	e8 2a f6 ff ff       	call   f0101a01 <page_insert>
f01023d7:	83 c4 10             	add    $0x10,%esp
f01023da:	85 c0                	test   %eax,%eax
f01023dc:	0f 85 4e 09 00 00    	jne    f0102d30 <mem_init+0x11cd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023e2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ea:	8b 83 08 23 00 00    	mov    0x2308(%ebx),%eax
f01023f0:	e8 c6 ed ff ff       	call   f01011bb <check_va2pa>
f01023f5:	89 c2                	mov    %eax,%edx
f01023f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01023fa:	2b 83 04 23 00 00    	sub    0x2304(%ebx),%eax
f0102400:	c1 f8 03             	sar    $0x3,%eax
f0102403:	c1 e0 0c             	shl    $0xc,%eax
f0102406:	39 c2                	cmp    %eax,%edx
f0102408:	0f 85 44 09 00 00    	jne    f0102d52 <mem_init+0x11ef>
	assert(pp2->pp_ref == 1);
f010240e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102411:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102416:	0f 85 58 09 00 00    	jne    f0102d74 <mem_init+0x1211>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010241c:	83 ec 0c             	sub    $0xc,%esp
f010241f:	6a 00                	push   $0x0
f0102421:	e8 2d f2 ff ff       	call   f0101653 <page_alloc>
f0102426:	83 c4 10             	add    $0x10,%esp
f0102429:	85 c0                	test   %eax,%eax
f010242b:	0f 85 65 09 00 00    	jne    f0102d96 <mem_init+0x1233>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102431:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102434:	8b 91 08 23 00 00    	mov    0x2308(%ecx),%edx
f010243a:	8b 02                	mov    (%edx),%eax
f010243c:	89 c3                	mov    %eax,%ebx
f010243e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f0102444:	c1 e8 0c             	shr    $0xc,%eax
f0102447:	3b 81 0c 23 00 00    	cmp    0x230c(%ecx),%eax
f010244d:	0f 83 65 09 00 00    	jae    f0102db8 <mem_init+0x1255>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102453:	83 ec 04             	sub    $0x4,%esp
f0102456:	6a 00                	push   $0x0
f0102458:	68 00 10 00 00       	push   $0x1000
f010245d:	52                   	push   %edx
f010245e:	e8 07 f3 ff ff       	call   f010176a <pgdir_walk>
f0102463:	81 eb fc ff ff 0f    	sub    $0xffffffc,%ebx
f0102469:	83 c4 10             	add    $0x10,%esp
f010246c:	39 d8                	cmp    %ebx,%eax
f010246e:	0f 85 5f 09 00 00    	jne    f0102dd3 <mem_init+0x1270>

	// should be able to change permissions too.
	//cprintf("mark0#####\n");
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102474:	6a 06                	push   $0x6
f0102476:	68 00 10 00 00       	push   $0x1000
f010247b:	ff 75 d0             	push   -0x30(%ebp)
f010247e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102481:	ff b0 08 23 00 00    	push   0x2308(%eax)
f0102487:	e8 75 f5 ff ff       	call   f0101a01 <page_insert>
f010248c:	83 c4 10             	add    $0x10,%esp
f010248f:	85 c0                	test   %eax,%eax
f0102491:	0f 85 5e 09 00 00    	jne    f0102df5 <mem_init+0x1292>
	//cprintf("kern_pgdir[0]: 0x%x\n", kern_pgdir[0]);
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102497:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010249a:	8b 9e 08 23 00 00    	mov    0x2308(%esi),%ebx
f01024a0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024a5:	89 d8                	mov    %ebx,%eax
f01024a7:	e8 0f ed ff ff       	call   f01011bb <check_va2pa>
f01024ac:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f01024ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01024b1:	2b 86 04 23 00 00    	sub    0x2304(%esi),%eax
f01024b7:	c1 f8 03             	sar    $0x3,%eax
f01024ba:	c1 e0 0c             	shl    $0xc,%eax
f01024bd:	39 c2                	cmp    %eax,%edx
f01024bf:	0f 85 52 09 00 00    	jne    f0102e17 <mem_init+0x12b4>
	assert(pp2->pp_ref == 1);
f01024c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01024c8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01024cd:	0f 85 66 09 00 00    	jne    f0102e39 <mem_init+0x12d6>
	//cprintf("mark1#####\n");
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01024d3:	83 ec 04             	sub    $0x4,%esp
f01024d6:	6a 00                	push   $0x0
f01024d8:	68 00 10 00 00       	push   $0x1000
f01024dd:	53                   	push   %ebx
f01024de:	e8 87 f2 ff ff       	call   f010176a <pgdir_walk>
f01024e3:	83 c4 10             	add    $0x10,%esp
f01024e6:	f6 00 04             	testb  $0x4,(%eax)
f01024e9:	0f 84 6c 09 00 00    	je     f0102e5b <mem_init+0x12f8>
	assert(kern_pgdir[0] & PTE_U);
f01024ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024f2:	8b 80 08 23 00 00    	mov    0x2308(%eax),%eax
f01024f8:	f6 00 04             	testb  $0x4,(%eax)
f01024fb:	0f 84 7c 09 00 00    	je     f0102e7d <mem_init+0x131a>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102501:	6a 02                	push   $0x2
f0102503:	68 00 10 00 00       	push   $0x1000
f0102508:	ff 75 d0             	push   -0x30(%ebp)
f010250b:	50                   	push   %eax
f010250c:	e8 f0 f4 ff ff       	call   f0101a01 <page_insert>
f0102511:	83 c4 10             	add    $0x10,%esp
f0102514:	85 c0                	test   %eax,%eax
f0102516:	0f 85 83 09 00 00    	jne    f0102e9f <mem_init+0x133c>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010251c:	83 ec 04             	sub    $0x4,%esp
f010251f:	6a 00                	push   $0x0
f0102521:	68 00 10 00 00       	push   $0x1000
f0102526:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102529:	ff b0 08 23 00 00    	push   0x2308(%eax)
f010252f:	e8 36 f2 ff ff       	call   f010176a <pgdir_walk>
f0102534:	83 c4 10             	add    $0x10,%esp
f0102537:	f6 00 02             	testb  $0x2,(%eax)
f010253a:	0f 84 81 09 00 00    	je     f0102ec1 <mem_init+0x135e>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102540:	83 ec 04             	sub    $0x4,%esp
f0102543:	6a 00                	push   $0x0
f0102545:	68 00 10 00 00       	push   $0x1000
f010254a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010254d:	ff b0 08 23 00 00    	push   0x2308(%eax)
f0102553:	e8 12 f2 ff ff       	call   f010176a <pgdir_walk>
f0102558:	83 c4 10             	add    $0x10,%esp
f010255b:	f6 00 04             	testb  $0x4,(%eax)
f010255e:	0f 85 7f 09 00 00    	jne    f0102ee3 <mem_init+0x1380>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) != 0);
f0102564:	6a 02                	push   $0x2
f0102566:	68 00 00 40 00       	push   $0x400000
f010256b:	ff 75 cc             	push   -0x34(%ebp)
f010256e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102571:	ff b0 08 23 00 00    	push   0x2308(%eax)
f0102577:	e8 85 f4 ff ff       	call   f0101a01 <page_insert>
f010257c:	83 c4 10             	add    $0x10,%esp
f010257f:	85 c0                	test   %eax,%eax
f0102581:	0f 84 7e 09 00 00    	je     f0102f05 <mem_init+0x13a2>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102587:	6a 02                	push   $0x2
f0102589:	68 00 10 00 00       	push   $0x1000
f010258e:	57                   	push   %edi
f010258f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102592:	ff b0 08 23 00 00    	push   0x2308(%eax)
f0102598:	e8 64 f4 ff ff       	call   f0101a01 <page_insert>
f010259d:	83 c4 10             	add    $0x10,%esp
f01025a0:	85 c0                	test   %eax,%eax
f01025a2:	0f 85 7f 09 00 00    	jne    f0102f27 <mem_init+0x13c4>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025a8:	83 ec 04             	sub    $0x4,%esp
f01025ab:	6a 00                	push   $0x0
f01025ad:	68 00 10 00 00       	push   $0x1000
f01025b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025b5:	ff b0 08 23 00 00    	push   0x2308(%eax)
f01025bb:	e8 aa f1 ff ff       	call   f010176a <pgdir_walk>
f01025c0:	83 c4 10             	add    $0x10,%esp
f01025c3:	f6 00 04             	testb  $0x4,(%eax)
f01025c6:	0f 85 7d 09 00 00    	jne    f0102f49 <mem_init+0x13e6>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01025cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025cf:	8b b3 08 23 00 00    	mov    0x2308(%ebx),%esi
f01025d5:	ba 00 00 00 00       	mov    $0x0,%edx
f01025da:	89 f0                	mov    %esi,%eax
f01025dc:	e8 da eb ff ff       	call   f01011bb <check_va2pa>
f01025e1:	89 d9                	mov    %ebx,%ecx
f01025e3:	89 fb                	mov    %edi,%ebx
f01025e5:	2b 99 04 23 00 00    	sub    0x2304(%ecx),%ebx
f01025eb:	c1 fb 03             	sar    $0x3,%ebx
f01025ee:	c1 e3 0c             	shl    $0xc,%ebx
f01025f1:	39 d8                	cmp    %ebx,%eax
f01025f3:	0f 85 72 09 00 00    	jne    f0102f6b <mem_init+0x1408>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025f9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025fe:	89 f0                	mov    %esi,%eax
f0102600:	e8 b6 eb ff ff       	call   f01011bb <check_va2pa>
f0102605:	39 c3                	cmp    %eax,%ebx
f0102607:	0f 85 80 09 00 00    	jne    f0102f8d <mem_init+0x142a>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010260d:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102612:	0f 85 97 09 00 00    	jne    f0102faf <mem_init+0x144c>
	assert(pp2->pp_ref == 0);
f0102618:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010261b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102620:	0f 85 ab 09 00 00    	jne    f0102fd1 <mem_init+0x146e>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102626:	83 ec 0c             	sub    $0xc,%esp
f0102629:	6a 00                	push   $0x0
f010262b:	e8 23 f0 ff ff       	call   f0101653 <page_alloc>
f0102630:	83 c4 10             	add    $0x10,%esp
f0102633:	85 c0                	test   %eax,%eax
f0102635:	0f 84 b8 09 00 00    	je     f0102ff3 <mem_init+0x1490>
f010263b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010263e:	0f 85 af 09 00 00    	jne    f0102ff3 <mem_init+0x1490>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102644:	83 ec 08             	sub    $0x8,%esp
f0102647:	6a 00                	push   $0x0
f0102649:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010264c:	ff b3 08 23 00 00    	push   0x2308(%ebx)
f0102652:	e8 64 f3 ff ff       	call   f01019bb <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102657:	8b 9b 08 23 00 00    	mov    0x2308(%ebx),%ebx
f010265d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102662:	89 d8                	mov    %ebx,%eax
f0102664:	e8 52 eb ff ff       	call   f01011bb <check_va2pa>
f0102669:	83 c4 10             	add    $0x10,%esp
f010266c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010266f:	0f 85 a0 09 00 00    	jne    f0103015 <mem_init+0x14b2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102675:	ba 00 10 00 00       	mov    $0x1000,%edx
f010267a:	89 d8                	mov    %ebx,%eax
f010267c:	e8 3a eb ff ff       	call   f01011bb <check_va2pa>
f0102681:	89 c2                	mov    %eax,%edx
f0102683:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102686:	89 f8                	mov    %edi,%eax
f0102688:	2b 81 04 23 00 00    	sub    0x2304(%ecx),%eax
f010268e:	c1 f8 03             	sar    $0x3,%eax
f0102691:	c1 e0 0c             	shl    $0xc,%eax
f0102694:	39 c2                	cmp    %eax,%edx
f0102696:	0f 85 9b 09 00 00    	jne    f0103037 <mem_init+0x14d4>
	assert(pp1->pp_ref == 1);
f010269c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01026a1:	0f 85 b1 09 00 00    	jne    f0103058 <mem_init+0x14f5>
	assert(pp2->pp_ref == 0);
f01026a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01026aa:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01026af:	0f 85 c5 09 00 00    	jne    f010307a <mem_init+0x1517>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01026b5:	6a 00                	push   $0x0
f01026b7:	68 00 10 00 00       	push   $0x1000
f01026bc:	57                   	push   %edi
f01026bd:	53                   	push   %ebx
f01026be:	e8 3e f3 ff ff       	call   f0101a01 <page_insert>
f01026c3:	83 c4 10             	add    $0x10,%esp
f01026c6:	85 c0                	test   %eax,%eax
f01026c8:	0f 85 ce 09 00 00    	jne    f010309c <mem_init+0x1539>
	assert(pp1->pp_ref);
f01026ce:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01026d3:	0f 84 e5 09 00 00    	je     f01030be <mem_init+0x155b>
	assert(pp1->pp_link == NULL);
f01026d9:	83 3f 00             	cmpl   $0x0,(%edi)
f01026dc:	0f 85 fe 09 00 00    	jne    f01030e0 <mem_init+0x157d>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01026e2:	83 ec 08             	sub    $0x8,%esp
f01026e5:	68 00 10 00 00       	push   $0x1000
f01026ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026ed:	ff b3 08 23 00 00    	push   0x2308(%ebx)
f01026f3:	e8 c3 f2 ff ff       	call   f01019bb <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026f8:	8b 9b 08 23 00 00    	mov    0x2308(%ebx),%ebx
f01026fe:	ba 00 00 00 00       	mov    $0x0,%edx
f0102703:	89 d8                	mov    %ebx,%eax
f0102705:	e8 b1 ea ff ff       	call   f01011bb <check_va2pa>
f010270a:	83 c4 10             	add    $0x10,%esp
f010270d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102710:	0f 85 ec 09 00 00    	jne    f0103102 <mem_init+0x159f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102716:	ba 00 10 00 00       	mov    $0x1000,%edx
f010271b:	89 d8                	mov    %ebx,%eax
f010271d:	e8 99 ea ff ff       	call   f01011bb <check_va2pa>
f0102722:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102725:	0f 85 f9 09 00 00    	jne    f0103124 <mem_init+0x15c1>
	assert(pp1->pp_ref == 0);
f010272b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102730:	0f 85 10 0a 00 00    	jne    f0103146 <mem_init+0x15e3>
	assert(pp2->pp_ref == 0);
f0102736:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102739:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010273e:	0f 85 24 0a 00 00    	jne    f0103168 <mem_init+0x1605>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102744:	83 ec 0c             	sub    $0xc,%esp
f0102747:	6a 00                	push   $0x0
f0102749:	e8 05 ef ff ff       	call   f0101653 <page_alloc>
f010274e:	83 c4 10             	add    $0x10,%esp
f0102751:	39 c7                	cmp    %eax,%edi
f0102753:	0f 85 31 0a 00 00    	jne    f010318a <mem_init+0x1627>
f0102759:	85 c0                	test   %eax,%eax
f010275b:	0f 84 29 0a 00 00    	je     f010318a <mem_init+0x1627>

	// should be no free memory
	assert(!page_alloc(0));
f0102761:	83 ec 0c             	sub    $0xc,%esp
f0102764:	6a 00                	push   $0x0
f0102766:	e8 e8 ee ff ff       	call   f0101653 <page_alloc>
f010276b:	83 c4 10             	add    $0x10,%esp
f010276e:	85 c0                	test   %eax,%eax
f0102770:	0f 85 36 0a 00 00    	jne    f01031ac <mem_init+0x1649>

	// forcibly take pp0 back
	
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102776:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102779:	8b 88 08 23 00 00    	mov    0x2308(%eax),%ecx
f010277f:	8b 11                	mov    (%ecx),%edx
f0102781:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102787:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f010278a:	2b 98 04 23 00 00    	sub    0x2304(%eax),%ebx
f0102790:	89 d8                	mov    %ebx,%eax
f0102792:	c1 f8 03             	sar    $0x3,%eax
f0102795:	c1 e0 0c             	shl    $0xc,%eax
f0102798:	39 c2                	cmp    %eax,%edx
f010279a:	0f 85 2e 0a 00 00    	jne    f01031ce <mem_init+0x166b>
	kern_pgdir[0] = 0;
f01027a0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01027a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01027a9:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01027ae:	0f 85 3c 0a 00 00    	jne    f01031f0 <mem_init+0x168d>
	pp0->pp_ref = 0;
f01027b4:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01027b7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01027bd:	83 ec 0c             	sub    $0xc,%esp
f01027c0:	50                   	push   %eax
f01027c1:	e8 2c ef ff ff       	call   f01016f2 <page_free>
	//cprintf("mark2#####\n");
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01027c6:	83 c4 0c             	add    $0xc,%esp
f01027c9:	6a 01                	push   $0x1
f01027cb:	68 00 10 40 00       	push   $0x401000
f01027d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027d3:	ff b3 08 23 00 00    	push   0x2308(%ebx)
f01027d9:	e8 8c ef ff ff       	call   f010176a <pgdir_walk>
f01027de:	89 c6                	mov    %eax,%esi
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01027e0:	89 d9                	mov    %ebx,%ecx
f01027e2:	8b 9b 08 23 00 00    	mov    0x2308(%ebx),%ebx
f01027e8:	8b 43 04             	mov    0x4(%ebx),%eax
f01027eb:	89 c2                	mov    %eax,%edx
f01027ed:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01027f3:	8b 89 0c 23 00 00    	mov    0x230c(%ecx),%ecx
f01027f9:	c1 e8 0c             	shr    $0xc,%eax
f01027fc:	83 c4 10             	add    $0x10,%esp
f01027ff:	39 c8                	cmp    %ecx,%eax
f0102801:	0f 83 0b 0a 00 00    	jae    f0103212 <mem_init+0x16af>
	assert(ptep == ptep1 + PTX(va));
f0102807:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010280d:	39 d6                	cmp    %edx,%esi
f010280f:	0f 85 19 0a 00 00    	jne    f010322e <mem_init+0x16cb>
	kern_pgdir[PDX(va)] = 0;
f0102815:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f010281c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010281f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0102825:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102828:	2b 83 04 23 00 00    	sub    0x2304(%ebx),%eax
f010282e:	c1 f8 03             	sar    $0x3,%eax
f0102831:	89 c2                	mov    %eax,%edx
f0102833:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102836:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010283b:	39 c1                	cmp    %eax,%ecx
f010283d:	0f 86 0d 0a 00 00    	jbe    f0103250 <mem_init+0x16ed>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102843:	83 ec 04             	sub    $0x4,%esp
f0102846:	68 00 10 00 00       	push   $0x1000
f010284b:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102850:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102856:	52                   	push   %edx
f0102857:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010285a:	e8 26 2f 00 00       	call   f0105785 <memset>
	page_free(pp0);
f010285f:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102862:	89 34 24             	mov    %esi,(%esp)
f0102865:	e8 88 ee ff ff       	call   f01016f2 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010286a:	83 c4 0c             	add    $0xc,%esp
f010286d:	6a 01                	push   $0x1
f010286f:	6a 00                	push   $0x0
f0102871:	ff b3 08 23 00 00    	push   0x2308(%ebx)
f0102877:	e8 ee ee ff ff       	call   f010176a <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f010287c:	89 f0                	mov    %esi,%eax
f010287e:	2b 83 04 23 00 00    	sub    0x2304(%ebx),%eax
f0102884:	c1 f8 03             	sar    $0x3,%eax
f0102887:	89 c2                	mov    %eax,%edx
f0102889:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010288c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102891:	83 c4 10             	add    $0x10,%esp
f0102894:	3b 83 0c 23 00 00    	cmp    0x230c(%ebx),%eax
f010289a:	0f 83 c6 09 00 00    	jae    f0103266 <mem_init+0x1703>
	return (void *)(pa + KERNBASE);
f01028a0:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01028a6:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01028ac:	8b 30                	mov    (%eax),%esi
f01028ae:	83 e6 01             	and    $0x1,%esi
f01028b1:	0f 85 c8 09 00 00    	jne    f010327f <mem_init+0x171c>
	for(i=0; i<NPTENTRIES; i++)
f01028b7:	83 c0 04             	add    $0x4,%eax
f01028ba:	39 c2                	cmp    %eax,%edx
f01028bc:	75 ee                	jne    f01028ac <mem_init+0xd49>
	kern_pgdir[0] = 0;
f01028be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028c1:	8b 83 08 23 00 00    	mov    0x2308(%ebx),%eax
f01028c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01028cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01028d0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01028d6:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01028d9:	89 93 14 23 00 00    	mov    %edx,0x2314(%ebx)

	// free the pages we took
	page_free(pp0);
f01028df:	83 ec 0c             	sub    $0xc,%esp
f01028e2:	50                   	push   %eax
f01028e3:	e8 0a ee ff ff       	call   f01016f2 <page_free>
	page_free(pp1);
f01028e8:	89 3c 24             	mov    %edi,(%esp)
f01028eb:	e8 02 ee ff ff       	call   f01016f2 <page_free>
	page_free(pp2);
f01028f0:	83 c4 04             	add    $0x4,%esp
f01028f3:	ff 75 d0             	push   -0x30(%ebp)
f01028f6:	e8 f7 ed ff ff       	call   f01016f2 <page_free>

	cprintf("check_page() succeeded!\n");
f01028fb:	8d 83 c9 4d f8 ff    	lea    -0x7b237(%ebx),%eax
f0102901:	89 04 24             	mov    %eax,(%esp)
f0102904:	e8 36 1a 00 00       	call   f010433f <cprintf>
	boot_map_region(kern_pgdir, UPAGES, 64*PGSIZE, PADDR(pages), PTE_P|PTE_W);
f0102909:	8b 83 04 23 00 00    	mov    0x2304(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f010290f:	83 c4 10             	add    $0x10,%esp
f0102912:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102917:	0f 86 84 09 00 00    	jbe    f01032a1 <mem_init+0x173e>
f010291d:	83 ec 0c             	sub    $0xc,%esp
f0102920:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f0102922:	05 00 00 00 10       	add    $0x10000000,%eax
f0102927:	50                   	push   %eax
f0102928:	68 00 00 04 00       	push   $0x40000
f010292d:	68 00 00 00 ef       	push   $0xef000000
f0102932:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102935:	ff b7 08 23 00 00    	push   0x2308(%edi)
f010293b:	e8 47 ef ff ff       	call   f0101887 <boot_map_region>
			PADDR(pages+64*PGSIZE/sizeof(struct PageInfo)),PTE_U|PTE_P);
f0102940:	8b 87 04 23 00 00    	mov    0x2304(%edi),%eax
f0102946:	05 00 00 04 00       	add    $0x40000,%eax
	if ((uint32_t)kva < KERNBASE)
f010294b:	83 c4 20             	add    $0x20,%esp
f010294e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102953:	0f 86 64 09 00 00    	jbe    f01032bd <mem_init+0x175a>
	boot_map_region(kern_pgdir, UPAGES+64*PGSIZE, PTSIZE-64*PGSIZE,
f0102959:	83 ec 0c             	sub    $0xc,%esp
f010295c:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010295e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102963:	50                   	push   %eax
f0102964:	68 00 00 3c 00       	push   $0x3c0000
f0102969:	68 00 00 04 ef       	push   $0xef040000
f010296e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102971:	ff b7 08 23 00 00    	push   0x2308(%edi)
f0102977:	e8 0b ef ff ff       	call   f0101887 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, 1*PGSIZE, PADDR(envs), PTE_P|PTE_W);
f010297c:	c7 c0 88 3b 18 f0    	mov    $0xf0183b88,%eax
f0102982:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102984:	83 c4 20             	add    $0x20,%esp
f0102987:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010298c:	0f 86 47 09 00 00    	jbe    f01032d9 <mem_init+0x1776>
f0102992:	83 ec 0c             	sub    $0xc,%esp
f0102995:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f0102997:	05 00 00 00 10       	add    $0x10000000,%eax
f010299c:	50                   	push   %eax
f010299d:	68 00 10 00 00       	push   $0x1000
f01029a2:	68 00 00 c0 ee       	push   $0xeec00000
f01029a7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01029aa:	ff b7 08 23 00 00    	push   0x2308(%edi)
f01029b0:	e8 d2 ee ff ff       	call   f0101887 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS+1*PGSIZE, PTSIZE-1*PGSIZE, PADDR(envs)+PGSIZE, PTE_P);
f01029b5:	c7 c0 88 3b 18 f0    	mov    $0xf0183b88,%eax
f01029bb:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01029bd:	83 c4 20             	add    $0x20,%esp
f01029c0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029c5:	0f 86 2a 09 00 00    	jbe    f01032f5 <mem_init+0x1792>
f01029cb:	83 ec 0c             	sub    $0xc,%esp
f01029ce:	6a 01                	push   $0x1
f01029d0:	05 00 10 00 10       	add    $0x10001000,%eax
f01029d5:	50                   	push   %eax
f01029d6:	68 00 f0 3f 00       	push   $0x3ff000
f01029db:	68 00 10 c0 ee       	push   $0xeec01000
f01029e0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01029e3:	ff b7 08 23 00 00    	push   0x2308(%edi)
f01029e9:	e8 99 ee ff ff       	call   f0101887 <boot_map_region>
f01029ee:	c7 c0 00 50 11 f0    	mov    $0xf0115000,%eax
f01029f4:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01029f7:	83 c4 20             	add    $0x20,%esp
f01029fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029ff:	0f 86 0c 09 00 00    	jbe    f0103311 <mem_init+0x17ae>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, 
f0102a05:	83 ec 0c             	sub    $0xc,%esp
f0102a08:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f0102a0a:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102a0d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102a12:	50                   	push   %eax
f0102a13:	68 00 80 00 00       	push   $0x8000
f0102a18:	68 00 80 ff ef       	push   $0xefff8000
f0102a1d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a20:	ff b3 08 23 00 00    	push   0x2308(%ebx)
f0102a26:	e8 5c ee ff ff       	call   f0101887 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-KERNBASE+1, 0, PTE_W|PTE_P);
f0102a2b:	83 c4 14             	add    $0x14,%esp
f0102a2e:	6a 03                	push   $0x3
f0102a30:	6a 00                	push   $0x0
f0102a32:	68 00 00 00 10       	push   $0x10000000
f0102a37:	68 00 00 00 f0       	push   $0xf0000000
f0102a3c:	ff b3 08 23 00 00    	push   0x2308(%ebx)
f0102a42:	e8 40 ee ff ff       	call   f0101887 <boot_map_region>
	cprintf("gogogo\n");
f0102a47:	83 c4 14             	add    $0x14,%esp
f0102a4a:	8d 83 e2 4d f8 ff    	lea    -0x7b21e(%ebx),%eax
f0102a50:	50                   	push   %eax
f0102a51:	e8 e9 18 00 00       	call   f010433f <cprintf>
	pgdir = kern_pgdir;
f0102a56:	8b bb 08 23 00 00    	mov    0x2308(%ebx),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102a5c:	8b 83 0c 23 00 00    	mov    0x230c(%ebx),%eax
f0102a62:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102a65:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102a6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102a71:	89 c2                	mov    %eax,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102a73:	8b 83 04 23 00 00    	mov    0x2304(%ebx),%eax
f0102a79:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0102a7c:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0102a82:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102a85:	83 c4 10             	add    $0x10,%esp
f0102a88:	89 f3                	mov    %esi,%ebx
f0102a8a:	89 75 c0             	mov    %esi,-0x40(%ebp)
f0102a8d:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102a90:	89 d6                	mov    %edx,%esi
f0102a92:	89 c7                	mov    %eax,%edi
f0102a94:	39 de                	cmp    %ebx,%esi
f0102a96:	0f 86 d6 08 00 00    	jbe    f0103372 <mem_init+0x180f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102a9c:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102aa2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102aa5:	e8 11 e7 ff ff       	call   f01011bb <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102aaa:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102ab0:	0f 86 7c 08 00 00    	jbe    f0103332 <mem_init+0x17cf>
f0102ab6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102ab9:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102abc:	39 c2                	cmp    %eax,%edx
f0102abe:	0f 85 8c 08 00 00    	jne    f0103350 <mem_init+0x17ed>
	for (i = 0; i < n; i += PGSIZE)
f0102ac4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102aca:	eb c8                	jmp    f0102a94 <mem_init+0xf31>
	assert(nfree == 0);
f0102acc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102acf:	8d 83 f2 4c f8 ff    	lea    -0x7b30e(%ebx),%eax
f0102ad5:	50                   	push   %eax
f0102ad6:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102adc:	50                   	push   %eax
f0102add:	68 0d 03 00 00       	push   $0x30d
f0102ae2:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102ae8:	50                   	push   %eax
f0102ae9:	e8 02 d6 ff ff       	call   f01000f0 <_panic>
	assert((pp0 = page_alloc(0)));
f0102aee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102af1:	8d 83 00 4c f8 ff    	lea    -0x7b400(%ebx),%eax
f0102af7:	50                   	push   %eax
f0102af8:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102afe:	50                   	push   %eax
f0102aff:	68 6b 03 00 00       	push   $0x36b
f0102b04:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102b0a:	50                   	push   %eax
f0102b0b:	e8 e0 d5 ff ff       	call   f01000f0 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b10:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b13:	8d 83 16 4c f8 ff    	lea    -0x7b3ea(%ebx),%eax
f0102b19:	50                   	push   %eax
f0102b1a:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102b20:	50                   	push   %eax
f0102b21:	68 6c 03 00 00       	push   $0x36c
f0102b26:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102b2c:	50                   	push   %eax
f0102b2d:	e8 be d5 ff ff       	call   f01000f0 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b32:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b35:	8d 83 2c 4c f8 ff    	lea    -0x7b3d4(%ebx),%eax
f0102b3b:	50                   	push   %eax
f0102b3c:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102b42:	50                   	push   %eax
f0102b43:	68 6d 03 00 00       	push   $0x36d
f0102b48:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102b4e:	50                   	push   %eax
f0102b4f:	e8 9c d5 ff ff       	call   f01000f0 <_panic>
	assert(pp1 && pp1 != pp0);
f0102b54:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b57:	8d 83 42 4c f8 ff    	lea    -0x7b3be(%ebx),%eax
f0102b5d:	50                   	push   %eax
f0102b5e:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102b64:	50                   	push   %eax
f0102b65:	68 70 03 00 00       	push   $0x370
f0102b6a:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102b70:	50                   	push   %eax
f0102b71:	e8 7a d5 ff ff       	call   f01000f0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102b76:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b79:	8d 83 10 50 f8 ff    	lea    -0x7aff0(%ebx),%eax
f0102b7f:	50                   	push   %eax
f0102b80:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102b86:	50                   	push   %eax
f0102b87:	68 71 03 00 00       	push   $0x371
f0102b8c:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102b92:	50                   	push   %eax
f0102b93:	e8 58 d5 ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f0102b98:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b9b:	8d 83 ab 4c f8 ff    	lea    -0x7b355(%ebx),%eax
f0102ba1:	50                   	push   %eax
f0102ba2:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102ba8:	50                   	push   %eax
f0102ba9:	68 78 03 00 00       	push   $0x378
f0102bae:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102bb4:	50                   	push   %eax
f0102bb5:	e8 36 d5 ff ff       	call   f01000f0 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102bba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bbd:	8d 83 50 50 f8 ff    	lea    -0x7afb0(%ebx),%eax
f0102bc3:	50                   	push   %eax
f0102bc4:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102bca:	50                   	push   %eax
f0102bcb:	68 7b 03 00 00       	push   $0x37b
f0102bd0:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102bd6:	50                   	push   %eax
f0102bd7:	e8 14 d5 ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) != 0);
f0102bdc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bdf:	8d 83 88 50 f8 ff    	lea    -0x7af78(%ebx),%eax
f0102be5:	50                   	push   %eax
f0102be6:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102bec:	50                   	push   %eax
f0102bed:	68 7e 03 00 00       	push   $0x37e
f0102bf2:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102bf8:	50                   	push   %eax
f0102bf9:	e8 f2 d4 ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102bfe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c01:	8d 83 b8 50 f8 ff    	lea    -0x7af48(%ebx),%eax
f0102c07:	50                   	push   %eax
f0102c08:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102c0e:	50                   	push   %eax
f0102c0f:	68 81 03 00 00       	push   $0x381
f0102c14:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102c1a:	50                   	push   %eax
f0102c1b:	e8 d0 d4 ff ff       	call   f01000f0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c20:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c23:	8d 83 e8 50 f8 ff    	lea    -0x7af18(%ebx),%eax
f0102c29:	50                   	push   %eax
f0102c2a:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102c30:	50                   	push   %eax
f0102c31:	68 82 03 00 00       	push   $0x382
f0102c36:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102c3c:	50                   	push   %eax
f0102c3d:	e8 ae d4 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102c42:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c45:	8d 83 10 51 f8 ff    	lea    -0x7aef0(%ebx),%eax
f0102c4b:	50                   	push   %eax
f0102c4c:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102c52:	50                   	push   %eax
f0102c53:	68 83 03 00 00       	push   $0x383
f0102c58:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102c5e:	50                   	push   %eax
f0102c5f:	e8 8c d4 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 1);
f0102c64:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c67:	8d 83 fd 4c f8 ff    	lea    -0x7b303(%ebx),%eax
f0102c6d:	50                   	push   %eax
f0102c6e:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102c74:	50                   	push   %eax
f0102c75:	68 84 03 00 00       	push   $0x384
f0102c7a:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102c80:	50                   	push   %eax
f0102c81:	e8 6a d4 ff ff       	call   f01000f0 <_panic>
	assert(pp0->pp_ref == 1);
f0102c86:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c89:	8d 83 0e 4d f8 ff    	lea    -0x7b2f2(%ebx),%eax
f0102c8f:	50                   	push   %eax
f0102c90:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102c96:	50                   	push   %eax
f0102c97:	68 85 03 00 00       	push   $0x385
f0102c9c:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102ca2:	50                   	push   %eax
f0102ca3:	e8 48 d4 ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102ca8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cab:	8d 83 40 51 f8 ff    	lea    -0x7aec0(%ebx),%eax
f0102cb1:	50                   	push   %eax
f0102cb2:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102cb8:	50                   	push   %eax
f0102cb9:	68 88 03 00 00       	push   $0x388
f0102cbe:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102cc4:	50                   	push   %eax
f0102cc5:	e8 26 d4 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102cca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ccd:	8d 83 7c 51 f8 ff    	lea    -0x7ae84(%ebx),%eax
f0102cd3:	50                   	push   %eax
f0102cd4:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102cda:	50                   	push   %eax
f0102cdb:	68 89 03 00 00       	push   $0x389
f0102ce0:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102ce6:	50                   	push   %eax
f0102ce7:	e8 04 d4 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 1);
f0102cec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cef:	8d 83 1f 4d f8 ff    	lea    -0x7b2e1(%ebx),%eax
f0102cf5:	50                   	push   %eax
f0102cf6:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102cfc:	50                   	push   %eax
f0102cfd:	68 8a 03 00 00       	push   $0x38a
f0102d02:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102d08:	50                   	push   %eax
f0102d09:	e8 e2 d3 ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f0102d0e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d11:	8d 83 ab 4c f8 ff    	lea    -0x7b355(%ebx),%eax
f0102d17:	50                   	push   %eax
f0102d18:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102d1e:	50                   	push   %eax
f0102d1f:	68 8d 03 00 00       	push   $0x38d
f0102d24:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102d2a:	50                   	push   %eax
f0102d2b:	e8 c0 d3 ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102d30:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d33:	8d 83 40 51 f8 ff    	lea    -0x7aec0(%ebx),%eax
f0102d39:	50                   	push   %eax
f0102d3a:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102d40:	50                   	push   %eax
f0102d41:	68 90 03 00 00       	push   $0x390
f0102d46:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102d4c:	50                   	push   %eax
f0102d4d:	e8 9e d3 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102d52:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d55:	8d 83 7c 51 f8 ff    	lea    -0x7ae84(%ebx),%eax
f0102d5b:	50                   	push   %eax
f0102d5c:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102d62:	50                   	push   %eax
f0102d63:	68 91 03 00 00       	push   $0x391
f0102d68:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102d6e:	50                   	push   %eax
f0102d6f:	e8 7c d3 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 1);
f0102d74:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d77:	8d 83 1f 4d f8 ff    	lea    -0x7b2e1(%ebx),%eax
f0102d7d:	50                   	push   %eax
f0102d7e:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102d84:	50                   	push   %eax
f0102d85:	68 92 03 00 00       	push   $0x392
f0102d8a:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102d90:	50                   	push   %eax
f0102d91:	e8 5a d3 ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f0102d96:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d99:	8d 83 ab 4c f8 ff    	lea    -0x7b355(%ebx),%eax
f0102d9f:	50                   	push   %eax
f0102da0:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102da6:	50                   	push   %eax
f0102da7:	68 96 03 00 00       	push   $0x396
f0102dac:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102db2:	50                   	push   %eax
f0102db3:	e8 38 d3 ff ff       	call   f01000f0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102db8:	53                   	push   %ebx
f0102db9:	89 cb                	mov    %ecx,%ebx
f0102dbb:	8d 81 1c 4e f8 ff    	lea    -0x7b1e4(%ecx),%eax
f0102dc1:	50                   	push   %eax
f0102dc2:	68 99 03 00 00       	push   $0x399
f0102dc7:	8d 81 6e 4a f8 ff    	lea    -0x7b592(%ecx),%eax
f0102dcd:	50                   	push   %eax
f0102dce:	e8 1d d3 ff ff       	call   f01000f0 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102dd3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dd6:	8d 83 ac 51 f8 ff    	lea    -0x7ae54(%ebx),%eax
f0102ddc:	50                   	push   %eax
f0102ddd:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102de3:	50                   	push   %eax
f0102de4:	68 9a 03 00 00       	push   $0x39a
f0102de9:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102def:	50                   	push   %eax
f0102df0:	e8 fb d2 ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102df5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102df8:	8d 83 ec 51 f8 ff    	lea    -0x7ae14(%ebx),%eax
f0102dfe:	50                   	push   %eax
f0102dff:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102e05:	50                   	push   %eax
f0102e06:	68 9e 03 00 00       	push   $0x39e
f0102e0b:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102e11:	50                   	push   %eax
f0102e12:	e8 d9 d2 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102e17:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e1a:	8d 83 7c 51 f8 ff    	lea    -0x7ae84(%ebx),%eax
f0102e20:	50                   	push   %eax
f0102e21:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102e27:	50                   	push   %eax
f0102e28:	68 a0 03 00 00       	push   $0x3a0
f0102e2d:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102e33:	50                   	push   %eax
f0102e34:	e8 b7 d2 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 1);
f0102e39:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e3c:	8d 83 1f 4d f8 ff    	lea    -0x7b2e1(%ebx),%eax
f0102e42:	50                   	push   %eax
f0102e43:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102e49:	50                   	push   %eax
f0102e4a:	68 a1 03 00 00       	push   $0x3a1
f0102e4f:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102e55:	50                   	push   %eax
f0102e56:	e8 95 d2 ff ff       	call   f01000f0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102e5b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e5e:	8d 83 2c 52 f8 ff    	lea    -0x7add4(%ebx),%eax
f0102e64:	50                   	push   %eax
f0102e65:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102e6b:	50                   	push   %eax
f0102e6c:	68 a3 03 00 00       	push   $0x3a3
f0102e71:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102e77:	50                   	push   %eax
f0102e78:	e8 73 d2 ff ff       	call   f01000f0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102e7d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e80:	8d 83 30 4d f8 ff    	lea    -0x7b2d0(%ebx),%eax
f0102e86:	50                   	push   %eax
f0102e87:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102e8d:	50                   	push   %eax
f0102e8e:	68 a4 03 00 00       	push   $0x3a4
f0102e93:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102e99:	50                   	push   %eax
f0102e9a:	e8 51 d2 ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102e9f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ea2:	8d 83 40 51 f8 ff    	lea    -0x7aec0(%ebx),%eax
f0102ea8:	50                   	push   %eax
f0102ea9:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102eaf:	50                   	push   %eax
f0102eb0:	68 a7 03 00 00       	push   $0x3a7
f0102eb5:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102ebb:	50                   	push   %eax
f0102ebc:	e8 2f d2 ff ff       	call   f01000f0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102ec1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ec4:	8d 83 60 52 f8 ff    	lea    -0x7ada0(%ebx),%eax
f0102eca:	50                   	push   %eax
f0102ecb:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102ed1:	50                   	push   %eax
f0102ed2:	68 a8 03 00 00       	push   $0x3a8
f0102ed7:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102edd:	50                   	push   %eax
f0102ede:	e8 0d d2 ff ff       	call   f01000f0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102ee3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ee6:	8d 83 94 52 f8 ff    	lea    -0x7ad6c(%ebx),%eax
f0102eec:	50                   	push   %eax
f0102eed:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102ef3:	50                   	push   %eax
f0102ef4:	68 a9 03 00 00       	push   $0x3a9
f0102ef9:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102eff:	50                   	push   %eax
f0102f00:	e8 eb d1 ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) != 0);
f0102f05:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f08:	8d 83 cc 52 f8 ff    	lea    -0x7ad34(%ebx),%eax
f0102f0e:	50                   	push   %eax
f0102f0f:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102f15:	50                   	push   %eax
f0102f16:	68 ac 03 00 00       	push   $0x3ac
f0102f1b:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102f21:	50                   	push   %eax
f0102f22:	e8 c9 d1 ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102f27:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f2a:	8d 83 08 53 f8 ff    	lea    -0x7acf8(%ebx),%eax
f0102f30:	50                   	push   %eax
f0102f31:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102f37:	50                   	push   %eax
f0102f38:	68 af 03 00 00       	push   $0x3af
f0102f3d:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102f43:	50                   	push   %eax
f0102f44:	e8 a7 d1 ff ff       	call   f01000f0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102f49:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f4c:	8d 83 94 52 f8 ff    	lea    -0x7ad6c(%ebx),%eax
f0102f52:	50                   	push   %eax
f0102f53:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102f59:	50                   	push   %eax
f0102f5a:	68 b0 03 00 00       	push   $0x3b0
f0102f5f:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102f65:	50                   	push   %eax
f0102f66:	e8 85 d1 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102f6b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f6e:	8d 83 44 53 f8 ff    	lea    -0x7acbc(%ebx),%eax
f0102f74:	50                   	push   %eax
f0102f75:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102f7b:	50                   	push   %eax
f0102f7c:	68 b3 03 00 00       	push   $0x3b3
f0102f81:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102f87:	50                   	push   %eax
f0102f88:	e8 63 d1 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102f8d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f90:	8d 83 70 53 f8 ff    	lea    -0x7ac90(%ebx),%eax
f0102f96:	50                   	push   %eax
f0102f97:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102f9d:	50                   	push   %eax
f0102f9e:	68 b4 03 00 00       	push   $0x3b4
f0102fa3:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102fa9:	50                   	push   %eax
f0102faa:	e8 41 d1 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 2);
f0102faf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fb2:	8d 83 46 4d f8 ff    	lea    -0x7b2ba(%ebx),%eax
f0102fb8:	50                   	push   %eax
f0102fb9:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102fbf:	50                   	push   %eax
f0102fc0:	68 b6 03 00 00       	push   $0x3b6
f0102fc5:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102fcb:	50                   	push   %eax
f0102fcc:	e8 1f d1 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 0);
f0102fd1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fd4:	8d 83 57 4d f8 ff    	lea    -0x7b2a9(%ebx),%eax
f0102fda:	50                   	push   %eax
f0102fdb:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0102fe1:	50                   	push   %eax
f0102fe2:	68 b7 03 00 00       	push   $0x3b7
f0102fe7:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0102fed:	50                   	push   %eax
f0102fee:	e8 fd d0 ff ff       	call   f01000f0 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102ff3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ff6:	8d 83 a0 53 f8 ff    	lea    -0x7ac60(%ebx),%eax
f0102ffc:	50                   	push   %eax
f0102ffd:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103003:	50                   	push   %eax
f0103004:	68 ba 03 00 00       	push   $0x3ba
f0103009:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010300f:	50                   	push   %eax
f0103010:	e8 db d0 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0103015:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103018:	8d 83 c4 53 f8 ff    	lea    -0x7ac3c(%ebx),%eax
f010301e:	50                   	push   %eax
f010301f:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103025:	50                   	push   %eax
f0103026:	68 be 03 00 00       	push   $0x3be
f010302b:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103031:	50                   	push   %eax
f0103032:	e8 b9 d0 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0103037:	89 cb                	mov    %ecx,%ebx
f0103039:	8d 81 70 53 f8 ff    	lea    -0x7ac90(%ecx),%eax
f010303f:	50                   	push   %eax
f0103040:	8d 81 e4 4a f8 ff    	lea    -0x7b51c(%ecx),%eax
f0103046:	50                   	push   %eax
f0103047:	68 bf 03 00 00       	push   $0x3bf
f010304c:	8d 81 6e 4a f8 ff    	lea    -0x7b592(%ecx),%eax
f0103052:	50                   	push   %eax
f0103053:	e8 98 d0 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 1);
f0103058:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010305b:	8d 83 fd 4c f8 ff    	lea    -0x7b303(%ebx),%eax
f0103061:	50                   	push   %eax
f0103062:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103068:	50                   	push   %eax
f0103069:	68 c0 03 00 00       	push   $0x3c0
f010306e:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103074:	50                   	push   %eax
f0103075:	e8 76 d0 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 0);
f010307a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010307d:	8d 83 57 4d f8 ff    	lea    -0x7b2a9(%ebx),%eax
f0103083:	50                   	push   %eax
f0103084:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f010308a:	50                   	push   %eax
f010308b:	68 c1 03 00 00       	push   $0x3c1
f0103090:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103096:	50                   	push   %eax
f0103097:	e8 54 d0 ff ff       	call   f01000f0 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010309c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010309f:	8d 83 e8 53 f8 ff    	lea    -0x7ac18(%ebx),%eax
f01030a5:	50                   	push   %eax
f01030a6:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01030ac:	50                   	push   %eax
f01030ad:	68 c4 03 00 00       	push   $0x3c4
f01030b2:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01030b8:	50                   	push   %eax
f01030b9:	e8 32 d0 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref);
f01030be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030c1:	8d 83 68 4d f8 ff    	lea    -0x7b298(%ebx),%eax
f01030c7:	50                   	push   %eax
f01030c8:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01030ce:	50                   	push   %eax
f01030cf:	68 c5 03 00 00       	push   $0x3c5
f01030d4:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01030da:	50                   	push   %eax
f01030db:	e8 10 d0 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_link == NULL);
f01030e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030e3:	8d 83 74 4d f8 ff    	lea    -0x7b28c(%ebx),%eax
f01030e9:	50                   	push   %eax
f01030ea:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01030f0:	50                   	push   %eax
f01030f1:	68 c6 03 00 00       	push   $0x3c6
f01030f6:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01030fc:	50                   	push   %eax
f01030fd:	e8 ee cf ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0103102:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103105:	8d 83 c4 53 f8 ff    	lea    -0x7ac3c(%ebx),%eax
f010310b:	50                   	push   %eax
f010310c:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103112:	50                   	push   %eax
f0103113:	68 ca 03 00 00       	push   $0x3ca
f0103118:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010311e:	50                   	push   %eax
f010311f:	e8 cc cf ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0103124:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103127:	8d 83 20 54 f8 ff    	lea    -0x7abe0(%ebx),%eax
f010312d:	50                   	push   %eax
f010312e:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103134:	50                   	push   %eax
f0103135:	68 cb 03 00 00       	push   $0x3cb
f010313a:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103140:	50                   	push   %eax
f0103141:	e8 aa cf ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 0);
f0103146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103149:	8d 83 89 4d f8 ff    	lea    -0x7b277(%ebx),%eax
f010314f:	50                   	push   %eax
f0103150:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103156:	50                   	push   %eax
f0103157:	68 cc 03 00 00       	push   $0x3cc
f010315c:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103162:	50                   	push   %eax
f0103163:	e8 88 cf ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 0);
f0103168:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010316b:	8d 83 57 4d f8 ff    	lea    -0x7b2a9(%ebx),%eax
f0103171:	50                   	push   %eax
f0103172:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103178:	50                   	push   %eax
f0103179:	68 cd 03 00 00       	push   $0x3cd
f010317e:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103184:	50                   	push   %eax
f0103185:	e8 66 cf ff ff       	call   f01000f0 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010318a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010318d:	8d 83 48 54 f8 ff    	lea    -0x7abb8(%ebx),%eax
f0103193:	50                   	push   %eax
f0103194:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f010319a:	50                   	push   %eax
f010319b:	68 d0 03 00 00       	push   $0x3d0
f01031a0:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01031a6:	50                   	push   %eax
f01031a7:	e8 44 cf ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f01031ac:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031af:	8d 83 ab 4c f8 ff    	lea    -0x7b355(%ebx),%eax
f01031b5:	50                   	push   %eax
f01031b6:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01031bc:	50                   	push   %eax
f01031bd:	68 d3 03 00 00       	push   $0x3d3
f01031c2:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01031c8:	50                   	push   %eax
f01031c9:	e8 22 cf ff ff       	call   f01000f0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01031ce:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031d1:	8d 83 e8 50 f8 ff    	lea    -0x7af18(%ebx),%eax
f01031d7:	50                   	push   %eax
f01031d8:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01031de:	50                   	push   %eax
f01031df:	68 d7 03 00 00       	push   $0x3d7
f01031e4:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01031ea:	50                   	push   %eax
f01031eb:	e8 00 cf ff ff       	call   f01000f0 <_panic>
	assert(pp0->pp_ref == 1);
f01031f0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031f3:	8d 83 0e 4d f8 ff    	lea    -0x7b2f2(%ebx),%eax
f01031f9:	50                   	push   %eax
f01031fa:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103200:	50                   	push   %eax
f0103201:	68 d9 03 00 00       	push   $0x3d9
f0103206:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010320c:	50                   	push   %eax
f010320d:	e8 de ce ff ff       	call   f01000f0 <_panic>
f0103212:	52                   	push   %edx
f0103213:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103216:	8d 83 1c 4e f8 ff    	lea    -0x7b1e4(%ebx),%eax
f010321c:	50                   	push   %eax
f010321d:	68 e1 03 00 00       	push   $0x3e1
f0103222:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103228:	50                   	push   %eax
f0103229:	e8 c2 ce ff ff       	call   f01000f0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010322e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103231:	8d 83 9a 4d f8 ff    	lea    -0x7b266(%ebx),%eax
f0103237:	50                   	push   %eax
f0103238:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f010323e:	50                   	push   %eax
f010323f:	68 e2 03 00 00       	push   $0x3e2
f0103244:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010324a:	50                   	push   %eax
f010324b:	e8 a0 ce ff ff       	call   f01000f0 <_panic>
f0103250:	52                   	push   %edx
f0103251:	8d 83 1c 4e f8 ff    	lea    -0x7b1e4(%ebx),%eax
f0103257:	50                   	push   %eax
f0103258:	6a 5c                	push   $0x5c
f010325a:	8d 83 b1 4a f8 ff    	lea    -0x7b54f(%ebx),%eax
f0103260:	50                   	push   %eax
f0103261:	e8 8a ce ff ff       	call   f01000f0 <_panic>
f0103266:	52                   	push   %edx
f0103267:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010326a:	8d 83 1c 4e f8 ff    	lea    -0x7b1e4(%ebx),%eax
f0103270:	50                   	push   %eax
f0103271:	6a 5c                	push   $0x5c
f0103273:	8d 83 b1 4a f8 ff    	lea    -0x7b54f(%ebx),%eax
f0103279:	50                   	push   %eax
f010327a:	e8 71 ce ff ff       	call   f01000f0 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010327f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103282:	8d 83 b2 4d f8 ff    	lea    -0x7b24e(%ebx),%eax
f0103288:	50                   	push   %eax
f0103289:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f010328f:	50                   	push   %eax
f0103290:	68 ec 03 00 00       	push   $0x3ec
f0103295:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010329b:	50                   	push   %eax
f010329c:	e8 4f ce ff ff       	call   f01000f0 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032a1:	50                   	push   %eax
f01032a2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032a5:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f01032ab:	50                   	push   %eax
f01032ac:	68 bd 00 00 00       	push   $0xbd
f01032b1:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01032b7:	50                   	push   %eax
f01032b8:	e8 33 ce ff ff       	call   f01000f0 <_panic>
f01032bd:	50                   	push   %eax
f01032be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032c1:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f01032c7:	50                   	push   %eax
f01032c8:	68 bf 00 00 00       	push   $0xbf
f01032cd:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01032d3:	50                   	push   %eax
f01032d4:	e8 17 ce ff ff       	call   f01000f0 <_panic>
f01032d9:	50                   	push   %eax
f01032da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032dd:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f01032e3:	50                   	push   %eax
f01032e4:	68 c9 00 00 00       	push   $0xc9
f01032e9:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01032ef:	50                   	push   %eax
f01032f0:	e8 fb cd ff ff       	call   f01000f0 <_panic>
f01032f5:	50                   	push   %eax
f01032f6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032f9:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f01032ff:	50                   	push   %eax
f0103300:	68 ca 00 00 00       	push   $0xca
f0103305:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010330b:	50                   	push   %eax
f010330c:	e8 df cd ff ff       	call   f01000f0 <_panic>
f0103311:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103314:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f010331a:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f0103320:	50                   	push   %eax
f0103321:	68 dc 00 00 00       	push   $0xdc
f0103326:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010332c:	50                   	push   %eax
f010332d:	e8 be cd ff ff       	call   f01000f0 <_panic>
f0103332:	ff 75 bc             	push   -0x44(%ebp)
f0103335:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103338:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f010333e:	50                   	push   %eax
f010333f:	68 24 03 00 00       	push   $0x324
f0103344:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010334a:	50                   	push   %eax
f010334b:	e8 a0 cd ff ff       	call   f01000f0 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103350:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103353:	8d 83 6c 54 f8 ff    	lea    -0x7ab94(%ebx),%eax
f0103359:	50                   	push   %eax
f010335a:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103360:	50                   	push   %eax
f0103361:	68 24 03 00 00       	push   $0x324
f0103366:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010336c:	50                   	push   %eax
f010336d:	e8 7e cd ff ff       	call   f01000f0 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103372:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0103375:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0103378:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010337b:	c7 c0 88 3b 18 f0    	mov    $0xf0183b88,%eax
f0103381:	8b 00                	mov    (%eax),%eax
f0103383:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0103386:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010338b:	8d 88 00 00 40 21    	lea    0x21400000(%eax),%ecx
f0103391:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0103394:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0103397:	89 c6                	mov    %eax,%esi
f0103399:	89 da                	mov    %ebx,%edx
f010339b:	89 f8                	mov    %edi,%eax
f010339d:	e8 19 de ff ff       	call   f01011bb <check_va2pa>
f01033a2:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01033a8:	76 45                	jbe    f01033ef <mem_init+0x188c>
f01033aa:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01033ad:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f01033b0:	39 c2                	cmp    %eax,%edx
f01033b2:	75 59                	jne    f010340d <mem_init+0x18aa>
	for (i = 0; i < n; i += PGSIZE)
f01033b4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01033ba:	81 fb 00 80 c1 ee    	cmp    $0xeec18000,%ebx
f01033c0:	75 d7                	jne    f0103399 <mem_init+0x1836>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01033c2:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01033c5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01033c8:	c1 e0 0c             	shl    $0xc,%eax
f01033cb:	89 f3                	mov    %esi,%ebx
f01033cd:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01033d0:	89 c6                	mov    %eax,%esi
f01033d2:	39 f3                	cmp    %esi,%ebx
f01033d4:	73 7b                	jae    f0103451 <mem_init+0x18ee>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01033d6:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01033dc:	89 f8                	mov    %edi,%eax
f01033de:	e8 d8 dd ff ff       	call   f01011bb <check_va2pa>
f01033e3:	39 c3                	cmp    %eax,%ebx
f01033e5:	75 48                	jne    f010342f <mem_init+0x18cc>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01033e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01033ed:	eb e3                	jmp    f01033d2 <mem_init+0x186f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033ef:	ff 75 c0             	push   -0x40(%ebp)
f01033f2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01033f5:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f01033fb:	50                   	push   %eax
f01033fc:	68 29 03 00 00       	push   $0x329
f0103401:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103407:	50                   	push   %eax
f0103408:	e8 e3 cc ff ff       	call   f01000f0 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010340d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103410:	8d 83 a0 54 f8 ff    	lea    -0x7ab60(%ebx),%eax
f0103416:	50                   	push   %eax
f0103417:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f010341d:	50                   	push   %eax
f010341e:	68 29 03 00 00       	push   $0x329
f0103423:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103429:	50                   	push   %eax
f010342a:	e8 c1 cc ff ff       	call   f01000f0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010342f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103432:	8d 83 d4 54 f8 ff    	lea    -0x7ab2c(%ebx),%eax
f0103438:	50                   	push   %eax
f0103439:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f010343f:	50                   	push   %eax
f0103440:	68 2d 03 00 00       	push   $0x32d
f0103445:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010344b:	50                   	push   %eax
f010344c:	e8 9f cc ff ff       	call   f01000f0 <_panic>
f0103451:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103456:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103459:	05 00 80 00 20       	add    $0x20008000,%eax
f010345e:	89 c6                	mov    %eax,%esi
f0103460:	89 da                	mov    %ebx,%edx
f0103462:	89 f8                	mov    %edi,%eax
f0103464:	e8 52 dd ff ff       	call   f01011bb <check_va2pa>
f0103469:	89 c2                	mov    %eax,%edx
f010346b:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010346e:	39 c2                	cmp    %eax,%edx
f0103470:	75 44                	jne    f01034b6 <mem_init+0x1953>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103472:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103478:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f010347e:	75 e0                	jne    f0103460 <mem_init+0x18fd>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0103480:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103483:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0103488:	89 f8                	mov    %edi,%eax
f010348a:	e8 2c dd ff ff       	call   f01011bb <check_va2pa>
f010348f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103492:	74 71                	je     f0103505 <mem_init+0x19a2>
f0103494:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103497:	8d 83 44 55 f8 ff    	lea    -0x7aabc(%ebx),%eax
f010349d:	50                   	push   %eax
f010349e:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01034a4:	50                   	push   %eax
f01034a5:	68 32 03 00 00       	push   $0x332
f01034aa:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01034b0:	50                   	push   %eax
f01034b1:	e8 3a cc ff ff       	call   f01000f0 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01034b6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01034b9:	8d 83 fc 54 f8 ff    	lea    -0x7ab04(%ebx),%eax
f01034bf:	50                   	push   %eax
f01034c0:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01034c6:	50                   	push   %eax
f01034c7:	68 31 03 00 00       	push   $0x331
f01034cc:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01034d2:	50                   	push   %eax
f01034d3:	e8 18 cc ff ff       	call   f01000f0 <_panic>
		switch (i) {
f01034d8:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f01034de:	75 25                	jne    f0103505 <mem_init+0x19a2>
			assert(pgdir[i] & PTE_P);
f01034e0:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f01034e4:	74 4f                	je     f0103535 <mem_init+0x19d2>
	for (i = 0; i < NPDENTRIES; i++) {
f01034e6:	83 c6 01             	add    $0x1,%esi
f01034e9:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f01034ef:	0f 87 b1 00 00 00    	ja     f01035a6 <mem_init+0x1a43>
		switch (i) {
f01034f5:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f01034fb:	77 db                	ja     f01034d8 <mem_init+0x1975>
f01034fd:	81 fe ba 03 00 00    	cmp    $0x3ba,%esi
f0103503:	77 db                	ja     f01034e0 <mem_init+0x197d>
			if (i >= PDX(KERNBASE)) {
f0103505:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f010350b:	77 4a                	ja     f0103557 <mem_init+0x19f4>
				assert(pgdir[i] == 0);
f010350d:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f0103511:	74 d3                	je     f01034e6 <mem_init+0x1983>
f0103513:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103516:	8d 83 0c 4e f8 ff    	lea    -0x7b1f4(%ebx),%eax
f010351c:	50                   	push   %eax
f010351d:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103523:	50                   	push   %eax
f0103524:	68 42 03 00 00       	push   $0x342
f0103529:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010352f:	50                   	push   %eax
f0103530:	e8 bb cb ff ff       	call   f01000f0 <_panic>
			assert(pgdir[i] & PTE_P);
f0103535:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103538:	8d 83 ea 4d f8 ff    	lea    -0x7b216(%ebx),%eax
f010353e:	50                   	push   %eax
f010353f:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103545:	50                   	push   %eax
f0103546:	68 3b 03 00 00       	push   $0x33b
f010354b:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103551:	50                   	push   %eax
f0103552:	e8 99 cb ff ff       	call   f01000f0 <_panic>
				assert(pgdir[i] & PTE_P);
f0103557:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f010355a:	a8 01                	test   $0x1,%al
f010355c:	74 26                	je     f0103584 <mem_init+0x1a21>
				assert(pgdir[i] & PTE_W);
f010355e:	a8 02                	test   $0x2,%al
f0103560:	75 84                	jne    f01034e6 <mem_init+0x1983>
f0103562:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103565:	8d 83 fb 4d f8 ff    	lea    -0x7b205(%ebx),%eax
f010356b:	50                   	push   %eax
f010356c:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103572:	50                   	push   %eax
f0103573:	68 40 03 00 00       	push   $0x340
f0103578:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010357e:	50                   	push   %eax
f010357f:	e8 6c cb ff ff       	call   f01000f0 <_panic>
				assert(pgdir[i] & PTE_P);
f0103584:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103587:	8d 83 ea 4d f8 ff    	lea    -0x7b216(%ebx),%eax
f010358d:	50                   	push   %eax
f010358e:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103594:	50                   	push   %eax
f0103595:	68 3f 03 00 00       	push   $0x33f
f010359a:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01035a0:	50                   	push   %eax
f01035a1:	e8 4a cb ff ff       	call   f01000f0 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f01035a6:	83 ec 0c             	sub    $0xc,%esp
f01035a9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01035ac:	8d 83 74 55 f8 ff    	lea    -0x7aa8c(%ebx),%eax
f01035b2:	50                   	push   %eax
f01035b3:	e8 87 0d 00 00       	call   f010433f <cprintf>
	lcr3(PADDR(kern_pgdir));
f01035b8:	8b 83 08 23 00 00    	mov    0x2308(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01035be:	83 c4 10             	add    $0x10,%esp
f01035c1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035c6:	0f 86 2c 02 00 00    	jbe    f01037f8 <mem_init+0x1c95>
	return (physaddr_t)kva - KERNBASE;
f01035cc:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01035d1:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f01035d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01035d9:	e8 59 dc ff ff       	call   f0101237 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01035de:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01035e1:	83 e0 f3             	and    $0xfffffff3,%eax
f01035e4:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01035e9:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01035ec:	83 ec 0c             	sub    $0xc,%esp
f01035ef:	6a 00                	push   $0x0
f01035f1:	e8 5d e0 ff ff       	call   f0101653 <page_alloc>
f01035f6:	89 c6                	mov    %eax,%esi
f01035f8:	83 c4 10             	add    $0x10,%esp
f01035fb:	85 c0                	test   %eax,%eax
f01035fd:	0f 84 11 02 00 00    	je     f0103814 <mem_init+0x1cb1>
	assert((pp1 = page_alloc(0)));
f0103603:	83 ec 0c             	sub    $0xc,%esp
f0103606:	6a 00                	push   $0x0
f0103608:	e8 46 e0 ff ff       	call   f0101653 <page_alloc>
f010360d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103610:	83 c4 10             	add    $0x10,%esp
f0103613:	85 c0                	test   %eax,%eax
f0103615:	0f 84 1b 02 00 00    	je     f0103836 <mem_init+0x1cd3>
	assert((pp2 = page_alloc(0)));
f010361b:	83 ec 0c             	sub    $0xc,%esp
f010361e:	6a 00                	push   $0x0
f0103620:	e8 2e e0 ff ff       	call   f0101653 <page_alloc>
f0103625:	89 c7                	mov    %eax,%edi
f0103627:	83 c4 10             	add    $0x10,%esp
f010362a:	85 c0                	test   %eax,%eax
f010362c:	0f 84 26 02 00 00    	je     f0103858 <mem_init+0x1cf5>
	page_free(pp0);
f0103632:	83 ec 0c             	sub    $0xc,%esp
f0103635:	56                   	push   %esi
f0103636:	e8 b7 e0 ff ff       	call   f01016f2 <page_free>
	return (pp - pages) << PGSHIFT;
f010363b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010363e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103641:	2b 81 04 23 00 00    	sub    0x2304(%ecx),%eax
f0103647:	c1 f8 03             	sar    $0x3,%eax
f010364a:	89 c2                	mov    %eax,%edx
f010364c:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010364f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0103654:	83 c4 10             	add    $0x10,%esp
f0103657:	3b 81 0c 23 00 00    	cmp    0x230c(%ecx),%eax
f010365d:	0f 83 17 02 00 00    	jae    f010387a <mem_init+0x1d17>
	memset(page2kva(pp1), 1, PGSIZE);
f0103663:	83 ec 04             	sub    $0x4,%esp
f0103666:	68 00 10 00 00       	push   $0x1000
f010366b:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010366d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103673:	52                   	push   %edx
f0103674:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103677:	e8 09 21 00 00       	call   f0105785 <memset>
	return (pp - pages) << PGSHIFT;
f010367c:	89 f8                	mov    %edi,%eax
f010367e:	2b 83 04 23 00 00    	sub    0x2304(%ebx),%eax
f0103684:	c1 f8 03             	sar    $0x3,%eax
f0103687:	89 c2                	mov    %eax,%edx
f0103689:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010368c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0103691:	83 c4 10             	add    $0x10,%esp
f0103694:	3b 83 0c 23 00 00    	cmp    0x230c(%ebx),%eax
f010369a:	0f 83 f2 01 00 00    	jae    f0103892 <mem_init+0x1d2f>
	memset(page2kva(pp2), 2, PGSIZE);
f01036a0:	83 ec 04             	sub    $0x4,%esp
f01036a3:	68 00 10 00 00       	push   $0x1000
f01036a8:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01036aa:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01036b0:	52                   	push   %edx
f01036b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01036b4:	e8 cc 20 00 00       	call   f0105785 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01036b9:	6a 02                	push   $0x2
f01036bb:	68 00 10 00 00       	push   $0x1000
f01036c0:	ff 75 d0             	push   -0x30(%ebp)
f01036c3:	ff b3 08 23 00 00    	push   0x2308(%ebx)
f01036c9:	e8 33 e3 ff ff       	call   f0101a01 <page_insert>
	assert(pp1->pp_ref == 1);
f01036ce:	83 c4 20             	add    $0x20,%esp
f01036d1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01036d4:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01036d9:	0f 85 cc 01 00 00    	jne    f01038ab <mem_init+0x1d48>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01036df:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01036e6:	01 01 01 
f01036e9:	0f 85 de 01 00 00    	jne    f01038cd <mem_init+0x1d6a>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01036ef:	6a 02                	push   $0x2
f01036f1:	68 00 10 00 00       	push   $0x1000
f01036f6:	57                   	push   %edi
f01036f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01036fa:	ff b0 08 23 00 00    	push   0x2308(%eax)
f0103700:	e8 fc e2 ff ff       	call   f0101a01 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103705:	83 c4 10             	add    $0x10,%esp
f0103708:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010370f:	02 02 02 
f0103712:	0f 85 d7 01 00 00    	jne    f01038ef <mem_init+0x1d8c>
	assert(pp2->pp_ref == 1);
f0103718:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010371d:	0f 85 ee 01 00 00    	jne    f0103911 <mem_init+0x1dae>
	assert(pp1->pp_ref == 0);
f0103723:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103726:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010372b:	0f 85 02 02 00 00    	jne    f0103933 <mem_init+0x1dd0>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103731:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103738:	03 03 03 
	return (pp - pages) << PGSHIFT;
f010373b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010373e:	89 f8                	mov    %edi,%eax
f0103740:	2b 81 04 23 00 00    	sub    0x2304(%ecx),%eax
f0103746:	c1 f8 03             	sar    $0x3,%eax
f0103749:	89 c2                	mov    %eax,%edx
f010374b:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010374e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0103753:	3b 81 0c 23 00 00    	cmp    0x230c(%ecx),%eax
f0103759:	0f 83 f6 01 00 00    	jae    f0103955 <mem_init+0x1df2>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010375f:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0103766:	03 03 03 
f0103769:	0f 85 fe 01 00 00    	jne    f010396d <mem_init+0x1e0a>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010376f:	83 ec 08             	sub    $0x8,%esp
f0103772:	68 00 10 00 00       	push   $0x1000
f0103777:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010377a:	ff b0 08 23 00 00    	push   0x2308(%eax)
f0103780:	e8 36 e2 ff ff       	call   f01019bb <page_remove>
	assert(pp2->pp_ref == 0);
f0103785:	83 c4 10             	add    $0x10,%esp
f0103788:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010378d:	0f 85 fc 01 00 00    	jne    f010398f <mem_init+0x1e2c>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103793:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103796:	8b 88 08 23 00 00    	mov    0x2308(%eax),%ecx
f010379c:	8b 11                	mov    (%ecx),%edx
f010379e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f01037a4:	89 f7                	mov    %esi,%edi
f01037a6:	2b b8 04 23 00 00    	sub    0x2304(%eax),%edi
f01037ac:	89 f8                	mov    %edi,%eax
f01037ae:	c1 f8 03             	sar    $0x3,%eax
f01037b1:	c1 e0 0c             	shl    $0xc,%eax
f01037b4:	39 c2                	cmp    %eax,%edx
f01037b6:	0f 85 f5 01 00 00    	jne    f01039b1 <mem_init+0x1e4e>
	kern_pgdir[0] = 0;
f01037bc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01037c2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01037c7:	0f 85 06 02 00 00    	jne    f01039d3 <mem_init+0x1e70>
	pp0->pp_ref = 0;
f01037cd:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01037d3:	83 ec 0c             	sub    $0xc,%esp
f01037d6:	56                   	push   %esi
f01037d7:	e8 16 df ff ff       	call   f01016f2 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01037dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01037df:	8d 83 08 56 f8 ff    	lea    -0x7a9f8(%ebx),%eax
f01037e5:	89 04 24             	mov    %eax,(%esp)
f01037e8:	e8 52 0b 00 00       	call   f010433f <cprintf>
}
f01037ed:	83 c4 10             	add    $0x10,%esp
f01037f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037f3:	5b                   	pop    %ebx
f01037f4:	5e                   	pop    %esi
f01037f5:	5f                   	pop    %edi
f01037f6:	5d                   	pop    %ebp
f01037f7:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037f8:	50                   	push   %eax
f01037f9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01037fc:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f0103802:	50                   	push   %eax
f0103803:	68 f3 00 00 00       	push   $0xf3
f0103808:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010380e:	50                   	push   %eax
f010380f:	e8 dc c8 ff ff       	call   f01000f0 <_panic>
	assert((pp0 = page_alloc(0)));
f0103814:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103817:	8d 83 00 4c f8 ff    	lea    -0x7b400(%ebx),%eax
f010381d:	50                   	push   %eax
f010381e:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103824:	50                   	push   %eax
f0103825:	68 07 04 00 00       	push   $0x407
f010382a:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103830:	50                   	push   %eax
f0103831:	e8 ba c8 ff ff       	call   f01000f0 <_panic>
	assert((pp1 = page_alloc(0)));
f0103836:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103839:	8d 83 16 4c f8 ff    	lea    -0x7b3ea(%ebx),%eax
f010383f:	50                   	push   %eax
f0103840:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103846:	50                   	push   %eax
f0103847:	68 08 04 00 00       	push   $0x408
f010384c:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103852:	50                   	push   %eax
f0103853:	e8 98 c8 ff ff       	call   f01000f0 <_panic>
	assert((pp2 = page_alloc(0)));
f0103858:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010385b:	8d 83 2c 4c f8 ff    	lea    -0x7b3d4(%ebx),%eax
f0103861:	50                   	push   %eax
f0103862:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103868:	50                   	push   %eax
f0103869:	68 09 04 00 00       	push   $0x409
f010386e:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103874:	50                   	push   %eax
f0103875:	e8 76 c8 ff ff       	call   f01000f0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010387a:	52                   	push   %edx
f010387b:	89 cb                	mov    %ecx,%ebx
f010387d:	8d 81 1c 4e f8 ff    	lea    -0x7b1e4(%ecx),%eax
f0103883:	50                   	push   %eax
f0103884:	6a 5c                	push   $0x5c
f0103886:	8d 81 b1 4a f8 ff    	lea    -0x7b54f(%ecx),%eax
f010388c:	50                   	push   %eax
f010388d:	e8 5e c8 ff ff       	call   f01000f0 <_panic>
f0103892:	52                   	push   %edx
f0103893:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103896:	8d 83 1c 4e f8 ff    	lea    -0x7b1e4(%ebx),%eax
f010389c:	50                   	push   %eax
f010389d:	6a 5c                	push   $0x5c
f010389f:	8d 83 b1 4a f8 ff    	lea    -0x7b54f(%ebx),%eax
f01038a5:	50                   	push   %eax
f01038a6:	e8 45 c8 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 1);
f01038ab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01038ae:	8d 83 fd 4c f8 ff    	lea    -0x7b303(%ebx),%eax
f01038b4:	50                   	push   %eax
f01038b5:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01038bb:	50                   	push   %eax
f01038bc:	68 0e 04 00 00       	push   $0x40e
f01038c1:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01038c7:	50                   	push   %eax
f01038c8:	e8 23 c8 ff ff       	call   f01000f0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01038cd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01038d0:	8d 83 94 55 f8 ff    	lea    -0x7aa6c(%ebx),%eax
f01038d6:	50                   	push   %eax
f01038d7:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01038dd:	50                   	push   %eax
f01038de:	68 0f 04 00 00       	push   $0x40f
f01038e3:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01038e9:	50                   	push   %eax
f01038ea:	e8 01 c8 ff ff       	call   f01000f0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01038ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01038f2:	8d 83 b8 55 f8 ff    	lea    -0x7aa48(%ebx),%eax
f01038f8:	50                   	push   %eax
f01038f9:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01038ff:	50                   	push   %eax
f0103900:	68 11 04 00 00       	push   $0x411
f0103905:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010390b:	50                   	push   %eax
f010390c:	e8 df c7 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 1);
f0103911:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103914:	8d 83 1f 4d f8 ff    	lea    -0x7b2e1(%ebx),%eax
f010391a:	50                   	push   %eax
f010391b:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103921:	50                   	push   %eax
f0103922:	68 12 04 00 00       	push   $0x412
f0103927:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010392d:	50                   	push   %eax
f010392e:	e8 bd c7 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 0);
f0103933:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103936:	8d 83 89 4d f8 ff    	lea    -0x7b277(%ebx),%eax
f010393c:	50                   	push   %eax
f010393d:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0103943:	50                   	push   %eax
f0103944:	68 13 04 00 00       	push   $0x413
f0103949:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f010394f:	50                   	push   %eax
f0103950:	e8 9b c7 ff ff       	call   f01000f0 <_panic>
f0103955:	52                   	push   %edx
f0103956:	89 cb                	mov    %ecx,%ebx
f0103958:	8d 81 1c 4e f8 ff    	lea    -0x7b1e4(%ecx),%eax
f010395e:	50                   	push   %eax
f010395f:	6a 5c                	push   $0x5c
f0103961:	8d 81 b1 4a f8 ff    	lea    -0x7b54f(%ecx),%eax
f0103967:	50                   	push   %eax
f0103968:	e8 83 c7 ff ff       	call   f01000f0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010396d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103970:	8d 83 dc 55 f8 ff    	lea    -0x7aa24(%ebx),%eax
f0103976:	50                   	push   %eax
f0103977:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f010397d:	50                   	push   %eax
f010397e:	68 15 04 00 00       	push   $0x415
f0103983:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f0103989:	50                   	push   %eax
f010398a:	e8 61 c7 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 0);
f010398f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103992:	8d 83 57 4d f8 ff    	lea    -0x7b2a9(%ebx),%eax
f0103998:	50                   	push   %eax
f0103999:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f010399f:	50                   	push   %eax
f01039a0:	68 17 04 00 00       	push   $0x417
f01039a5:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01039ab:	50                   	push   %eax
f01039ac:	e8 3f c7 ff ff       	call   f01000f0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01039b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01039b4:	8d 83 e8 50 f8 ff    	lea    -0x7af18(%ebx),%eax
f01039ba:	50                   	push   %eax
f01039bb:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01039c1:	50                   	push   %eax
f01039c2:	68 1a 04 00 00       	push   $0x41a
f01039c7:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01039cd:	50                   	push   %eax
f01039ce:	e8 1d c7 ff ff       	call   f01000f0 <_panic>
	assert(pp0->pp_ref == 1);
f01039d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01039d6:	8d 83 0e 4d f8 ff    	lea    -0x7b2f2(%ebx),%eax
f01039dc:	50                   	push   %eax
f01039dd:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f01039e3:	50                   	push   %eax
f01039e4:	68 1c 04 00 00       	push   $0x41c
f01039e9:	8d 83 6e 4a f8 ff    	lea    -0x7b592(%ebx),%eax
f01039ef:	50                   	push   %eax
f01039f0:	e8 fb c6 ff ff       	call   f01000f0 <_panic>

f01039f5 <tlb_invalidate>:
{
f01039f5:	55                   	push   %ebp
f01039f6:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01039f8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039fb:	0f 01 38             	invlpg (%eax)
}
f01039fe:	5d                   	pop    %ebp
f01039ff:	c3                   	ret    

f0103a00 <user_mem_check>:
}
f0103a00:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a05:	c3                   	ret    

f0103a06 <user_mem_assert>:
}
f0103a06:	c3                   	ret    

f0103a07 <__x86.get_pc_thunk.dx>:
f0103a07:	8b 14 24             	mov    (%esp),%edx
f0103a0a:	c3                   	ret    

f0103a0b <__x86.get_pc_thunk.cx>:
f0103a0b:	8b 0c 24             	mov    (%esp),%ecx
f0103a0e:	c3                   	ret    

f0103a0f <__x86.get_pc_thunk.di>:
f0103a0f:	8b 3c 24             	mov    (%esp),%edi
f0103a12:	c3                   	ret    

f0103a13 <envid2env>:
//   On error, sets *env_store to NULL.
//

int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103a13:	55                   	push   %ebp
f0103a14:	89 e5                	mov    %esp,%ebp
f0103a16:	53                   	push   %ebx
f0103a17:	e8 ef ff ff ff       	call   f0103a0b <__x86.get_pc_thunk.cx>
f0103a1c:	81 c1 50 de 07 00    	add    $0x7de50,%ecx
f0103a22:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103a28:	85 c0                	test   %eax,%eax
f0103a2a:	74 4c                	je     f0103a78 <envid2env+0x65>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103a2c:	89 c2                	mov    %eax,%edx
f0103a2e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103a34:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103a37:	c1 e2 05             	shl    $0x5,%edx
f0103a3a:	03 91 1c 23 00 00    	add    0x231c(%ecx),%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103a40:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103a44:	74 42                	je     f0103a88 <envid2env+0x75>
f0103a46:	39 42 48             	cmp    %eax,0x48(%edx)
f0103a49:	75 49                	jne    f0103a94 <envid2env+0x81>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
	return 0;
f0103a4b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103a50:	84 db                	test   %bl,%bl
f0103a52:	74 2a                	je     f0103a7e <envid2env+0x6b>
f0103a54:	8b 89 18 23 00 00    	mov    0x2318(%ecx),%ecx
f0103a5a:	39 d1                	cmp    %edx,%ecx
f0103a5c:	74 20                	je     f0103a7e <envid2env+0x6b>
f0103a5e:	8b 42 4c             	mov    0x4c(%edx),%eax
f0103a61:	3b 41 48             	cmp    0x48(%ecx),%eax
f0103a64:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103a69:	0f 45 d3             	cmovne %ebx,%edx
f0103a6c:	0f 94 c0             	sete   %al
f0103a6f:	0f b6 c0             	movzbl %al,%eax
f0103a72:	8d 44 00 fe          	lea    -0x2(%eax,%eax,1),%eax
f0103a76:	eb 06                	jmp    f0103a7e <envid2env+0x6b>
		*env_store = curenv;
f0103a78:	8b 91 18 23 00 00    	mov    0x2318(%ecx),%edx
f0103a7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103a81:	89 11                	mov    %edx,(%ecx)
}
f0103a83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a86:	c9                   	leave  
f0103a87:	c3                   	ret    
f0103a88:	ba 00 00 00 00       	mov    $0x0,%edx
		return -E_BAD_ENV;
f0103a8d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a92:	eb ea                	jmp    f0103a7e <envid2env+0x6b>
f0103a94:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a99:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103a9e:	eb de                	jmp    f0103a7e <envid2env+0x6b>

f0103aa0 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103aa0:	e8 93 cc ff ff       	call   f0100738 <__x86.get_pc_thunk.ax>
f0103aa5:	05 c7 dd 07 00       	add    $0x7ddc7,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f0103aaa:	8d 80 94 17 00 00    	lea    0x1794(%eax),%eax
f0103ab0:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103ab3:	b8 23 00 00 00       	mov    $0x23,%eax
f0103ab8:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103aba:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103abc:	b8 10 00 00 00       	mov    $0x10,%eax
f0103ac1:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103ac3:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103ac5:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103ac7:	ea ce 3a 10 f0 08 00 	ljmp   $0x8,$0xf0103ace
	asm volatile("lldt %0" : : "r" (sel));
f0103ace:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ad3:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103ad6:	c3                   	ret    

f0103ad7 <env_init>:
{
f0103ad7:	55                   	push   %ebp
f0103ad8:	89 e5                	mov    %esp,%ebp
f0103ada:	83 ec 08             	sub    $0x8,%esp
f0103add:	e8 29 ff ff ff       	call   f0103a0b <__x86.get_pc_thunk.cx>
f0103ae2:	81 c1 8a dd 07 00    	add    $0x7dd8a,%ecx
		envs[i].env_id = 0;
f0103ae8:	8b 91 1c 23 00 00    	mov    0x231c(%ecx),%edx
f0103aee:	8d 42 48             	lea    0x48(%edx),%eax
f0103af1:	81 c2 48 80 01 00    	add    $0x18048,%edx
f0103af7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		envs[i].env_status = ENV_FREE;
f0103afd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	for (int i = 0; i < NENV; i++)
f0103b04:	83 c0 60             	add    $0x60,%eax
f0103b07:	39 d0                	cmp    %edx,%eax
f0103b09:	75 ec                	jne    f0103af7 <env_init+0x20>
	env_free_list = &envs[0];
f0103b0b:	8b 91 1c 23 00 00    	mov    0x231c(%ecx),%edx
f0103b11:	89 91 20 23 00 00    	mov    %edx,0x2320(%ecx)
f0103b17:	b8 ff 03 00 00       	mov    $0x3ff,%eax
	for (int i = 1; i < NENV; i++)
f0103b1c:	83 e8 01             	sub    $0x1,%eax
f0103b1f:	75 fb                	jne    f0103b1c <env_init+0x45>
		temp_ptr->env_link = &envs[i];
f0103b21:	8d 82 a0 7f 01 00    	lea    0x17fa0(%edx),%eax
f0103b27:	89 42 44             	mov    %eax,0x44(%edx)
	env_init_percpu();
f0103b2a:	e8 71 ff ff ff       	call   f0103aa0 <env_init_percpu>
}
f0103b2f:	c9                   	leave  
f0103b30:	c3                   	ret    

f0103b31 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103b31:	55                   	push   %ebp
f0103b32:	89 e5                	mov    %esp,%ebp
f0103b34:	57                   	push   %edi
f0103b35:	56                   	push   %esi
f0103b36:	53                   	push   %ebx
f0103b37:	83 ec 1c             	sub    $0x1c,%esp
f0103b3a:	e8 67 c6 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0103b3f:	81 c3 2d dd 07 00    	add    $0x7dd2d,%ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103b45:	8b b3 20 23 00 00    	mov    0x2320(%ebx),%esi
f0103b4b:	85 f6                	test   %esi,%esi
f0103b4d:	0f 84 2e 02 00 00    	je     f0103d81 <env_alloc+0x250>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103b53:	83 ec 0c             	sub    $0xc,%esp
f0103b56:	6a 01                	push   $0x1
f0103b58:	e8 f6 da ff ff       	call   f0101653 <page_alloc>
f0103b5d:	89 c1                	mov    %eax,%ecx
f0103b5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103b62:	83 c4 10             	add    $0x10,%esp
f0103b65:	85 c0                	test   %eax,%eax
f0103b67:	0f 84 1b 02 00 00    	je     f0103d88 <env_alloc+0x257>
	return (pp - pages) << PGSHIFT;
f0103b6d:	c7 c0 70 3b 18 f0    	mov    $0xf0183b70,%eax
f0103b73:	2b 08                	sub    (%eax),%ecx
f0103b75:	89 c8                	mov    %ecx,%eax
f0103b77:	c1 f8 03             	sar    $0x3,%eax
f0103b7a:	89 c7                	mov    %eax,%edi
f0103b7c:	c1 e7 0c             	shl    $0xc,%edi
	if (PGNUM(pa) >= npages)
f0103b7f:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0103b84:	c7 c2 78 3b 18 f0    	mov    $0xf0183b78,%edx
f0103b8a:	3b 02                	cmp    (%edx),%eax
f0103b8c:	0f 83 c0 01 00 00    	jae    f0103d52 <env_alloc+0x221>
	return (void *)(pa + KERNBASE);
f0103b92:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	cprintf("user pgdir: 0x%x\n",(u32)dir);
f0103b98:	83 ec 08             	sub    $0x8,%esp
f0103b9b:	57                   	push   %edi
f0103b9c:	8d 83 0e 57 f8 ff    	lea    -0x7a8f2(%ebx),%eax
f0103ba2:	50                   	push   %eax
f0103ba3:	e8 97 07 00 00       	call   f010433f <cprintf>
	p->pp_ref++;
f0103ba8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103bab:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	e->env_pgdir = dir;
f0103bb0:	89 7e 5c             	mov    %edi,0x5c(%esi)
	e->env_pgdir[PDX(UENVS)] = kern_pgdir[PDX(UENVS)] | PTE_U;
f0103bb3:	c7 c0 74 3b 18 f0    	mov    $0xf0183b74,%eax
f0103bb9:	8b 00                	mov    (%eax),%eax
f0103bbb:	8b 90 ec 0e 00 00    	mov    0xeec(%eax),%edx
f0103bc1:	83 ca 04             	or     $0x4,%edx
f0103bc4:	89 97 ec 0e 00 00    	mov    %edx,0xeec(%edi)
	e->env_pgdir[PDX(UPAGES)] = kern_pgdir[PDX(UPAGES)] | PTE_U;
f0103bca:	8b 4e 5c             	mov    0x5c(%esi),%ecx
f0103bcd:	8b 90 f0 0e 00 00    	mov    0xef0(%eax),%edx
f0103bd3:	83 ca 04             	or     $0x4,%edx
f0103bd6:	89 91 f0 0e 00 00    	mov    %edx,0xef0(%ecx)
	e->env_pgdir[PDX(KSTACKTOP-KSTKSIZE)] = kern_pgdir[PDX(KSTACKTOP-KSTKSIZE)] | PTE_W;
f0103bdc:	8b 56 5c             	mov    0x5c(%esi),%edx
f0103bdf:	8b 80 fc 0e 00 00    	mov    0xefc(%eax),%eax
f0103be5:	83 c8 02             	or     $0x2,%eax
f0103be8:	89 82 fc 0e 00 00    	mov    %eax,0xefc(%edx)
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103bee:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103bf1:	83 c4 10             	add    $0x10,%esp
f0103bf4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bf9:	0f 86 69 01 00 00    	jbe    f0103d68 <env_alloc+0x237>
	return (physaddr_t)kva - KERNBASE;
f0103bff:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103c05:	83 ca 05             	or     $0x5,%edx
f0103c08:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	boot_map_region(dir, 0xf0000000, 0x400000, 0x0, PTE_P | PTE_W);
f0103c0e:	83 ec 0c             	sub    $0xc,%esp
f0103c11:	6a 03                	push   $0x3
f0103c13:	6a 00                	push   $0x0
f0103c15:	68 00 00 40 00       	push   $0x400000
f0103c1a:	68 00 00 00 f0       	push   $0xf0000000
f0103c1f:	57                   	push   %edi
f0103c20:	e8 62 dc ff ff       	call   f0101887 <boot_map_region>
	cprintf("env setup vm done\n");
f0103c25:	83 c4 14             	add    $0x14,%esp
f0103c28:	8d 83 2b 57 f8 ff    	lea    -0x7a8d5(%ebx),%eax
f0103c2e:	50                   	push   %eax
f0103c2f:	e8 0b 07 00 00       	call   f010433f <cprintf>
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103c34:	8b 46 48             	mov    0x48(%esi),%eax
f0103c37:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
		generation = 1 << ENVGENSHIFT;
f0103c3c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103c41:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103c46:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103c49:	89 f2                	mov    %esi,%edx
f0103c4b:	2b 93 1c 23 00 00    	sub    0x231c(%ebx),%edx
f0103c51:	c1 fa 05             	sar    $0x5,%edx
f0103c54:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103c5a:	09 d0                	or     %edx,%eax
f0103c5c:	89 46 48             	mov    %eax,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c62:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0103c65:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103c6c:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0103c73:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	cprintf("####memset\n");
f0103c7a:	8d 83 3e 57 f8 ff    	lea    -0x7a8c2(%ebx),%eax
f0103c80:	89 04 24             	mov    %eax,(%esp)
f0103c83:	e8 b7 06 00 00       	call   f010433f <cprintf>
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103c88:	83 c4 0c             	add    $0xc,%esp
f0103c8b:	6a 44                	push   $0x44
f0103c8d:	6a 00                	push   $0x0
f0103c8f:	56                   	push   %esi
f0103c90:	e8 f0 1a 00 00       	call   f0105785 <memset>
	cprintf("####memset done\n");
f0103c95:	8d 83 4a 57 f8 ff    	lea    -0x7a8b6(%ebx),%eax
f0103c9b:	89 04 24             	mov    %eax,(%esp)
f0103c9e:	e8 9c 06 00 00       	call   f010433f <cprintf>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103ca3:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f0103ca9:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f0103caf:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0103cb5:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0103cbc:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	cprintf("####1\n");
f0103cc2:	8d 83 5b 57 f8 ff    	lea    -0x7a8a5(%ebx),%eax
f0103cc8:	89 04 24             	mov    %eax,(%esp)
f0103ccb:	e8 6f 06 00 00       	call   f010433f <cprintf>
	env_free_list = e->env_link;
f0103cd0:	8b 46 44             	mov    0x44(%esi),%eax
f0103cd3:	89 83 20 23 00 00    	mov    %eax,0x2320(%ebx)
	cprintf("e_addr 0x%x, env free 0x%x\n", (u32)e, (u32)env_free_list);
f0103cd9:	83 c4 0c             	add    $0xc,%esp
f0103cdc:	50                   	push   %eax
f0103cdd:	56                   	push   %esi
f0103cde:	8d 83 62 57 f8 ff    	lea    -0x7a89e(%ebx),%eax
f0103ce4:	50                   	push   %eax
f0103ce5:	e8 55 06 00 00       	call   f010433f <cprintf>
	cprintf("####2\n");
f0103cea:	8d 83 7e 57 f8 ff    	lea    -0x7a882(%ebx),%eax
f0103cf0:	89 04 24             	mov    %eax,(%esp)
f0103cf3:	e8 47 06 00 00       	call   f010433f <cprintf>

	*newenv_store = e;
f0103cf8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cfb:	89 30                	mov    %esi,(%eax)
	cprintf("####3\n");
f0103cfd:	8d 83 85 57 f8 ff    	lea    -0x7a87b(%ebx),%eax
f0103d03:	89 04 24             	mov    %eax,(%esp)
f0103d06:	e8 34 06 00 00       	call   f010433f <cprintf>

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103d0b:	8b 4e 48             	mov    0x48(%esi),%ecx
f0103d0e:	8b 83 18 23 00 00    	mov    0x2318(%ebx),%eax
f0103d14:	83 c4 10             	add    $0x10,%esp
f0103d17:	ba 00 00 00 00       	mov    $0x0,%edx
f0103d1c:	85 c0                	test   %eax,%eax
f0103d1e:	74 03                	je     f0103d23 <env_alloc+0x1f2>
f0103d20:	8b 50 48             	mov    0x48(%eax),%edx
f0103d23:	83 ec 04             	sub    $0x4,%esp
f0103d26:	51                   	push   %ecx
f0103d27:	52                   	push   %edx
f0103d28:	8d 83 8c 57 f8 ff    	lea    -0x7a874(%ebx),%eax
f0103d2e:	50                   	push   %eax
f0103d2f:	e8 0b 06 00 00       	call   f010433f <cprintf>
	cprintf("####4\n");
f0103d34:	8d 83 a1 57 f8 ff    	lea    -0x7a85f(%ebx),%eax
f0103d3a:	89 04 24             	mov    %eax,(%esp)
f0103d3d:	e8 fd 05 00 00       	call   f010433f <cprintf>
	
	return 0;
f0103d42:	83 c4 10             	add    $0x10,%esp
f0103d45:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d4d:	5b                   	pop    %ebx
f0103d4e:	5e                   	pop    %esi
f0103d4f:	5f                   	pop    %edi
f0103d50:	5d                   	pop    %ebp
f0103d51:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103d52:	57                   	push   %edi
f0103d53:	8d 83 1c 4e f8 ff    	lea    -0x7b1e4(%ebx),%eax
f0103d59:	50                   	push   %eax
f0103d5a:	6a 5c                	push   $0x5c
f0103d5c:	8d 83 b1 4a f8 ff    	lea    -0x7b54f(%ebx),%eax
f0103d62:	50                   	push   %eax
f0103d63:	e8 88 c3 ff ff       	call   f01000f0 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d68:	50                   	push   %eax
f0103d69:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f0103d6f:	50                   	push   %eax
f0103d70:	68 cc 00 00 00       	push   $0xcc
f0103d75:	8d 83 20 57 f8 ff    	lea    -0x7a8e0(%ebx),%eax
f0103d7b:	50                   	push   %eax
f0103d7c:	e8 6f c3 ff ff       	call   f01000f0 <_panic>
		return -E_NO_FREE_ENV;
f0103d81:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103d86:	eb c2                	jmp    f0103d4a <env_alloc+0x219>
		return -E_NO_MEM;
f0103d88:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103d8d:	eb bb                	jmp    f0103d4a <env_alloc+0x219>

f0103d8f <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103d8f:	55                   	push   %ebp
f0103d90:	89 e5                	mov    %esp,%ebp
f0103d92:	57                   	push   %edi
f0103d93:	56                   	push   %esi
f0103d94:	53                   	push   %ebx
f0103d95:	83 ec 44             	sub    $0x44,%esp
f0103d98:	e8 09 c4 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0103d9d:	81 c3 cf da 07 00    	add    $0x7dacf,%ebx
	// LAB 3: Your code here.
	struct Env *new = NULL;
f0103da3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int ret = env_alloc(&new, 0);
f0103daa:	6a 00                	push   $0x0
f0103dac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103daf:	50                   	push   %eax
f0103db0:	e8 7c fd ff ff       	call   f0103b31 <env_alloc>
	cprintf("env alloc done. new_env: 0x%x\n", (u32)new);
f0103db5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103db8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103dbb:	83 c4 08             	add    $0x8,%esp
f0103dbe:	50                   	push   %eax
f0103dbf:	8d 83 34 56 f8 ff    	lea    -0x7a9cc(%ebx),%eax
f0103dc5:	50                   	push   %eax
f0103dc6:	e8 74 05 00 00       	call   f010433f <cprintf>
	cprintf("entry 0x%x, phoff 0x%x, phnum 0x%x\n", 
f0103dcb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dce:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0103dd2:	50                   	push   %eax
f0103dd3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dd6:	ff 70 1c             	push   0x1c(%eax)
f0103dd9:	ff 70 18             	push   0x18(%eax)
f0103ddc:	8d 83 54 56 f8 ff    	lea    -0x7a9ac(%ebx),%eax
f0103de2:	50                   	push   %eax
f0103de3:	e8 57 05 00 00       	call   f010433f <cprintf>
	temp = (struct Proghdr *)((uint8_t*)elf_ptr + elf_ptr->e_phoff);
f0103de8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103deb:	89 c6                	mov    %eax,%esi
f0103ded:	03 70 1c             	add    0x1c(%eax),%esi
	end = temp+elf_ptr->e_phnum;
f0103df0:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0103df4:	c1 e0 05             	shl    $0x5,%eax
f0103df7:	01 f0                	add    %esi,%eax
f0103df9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (;temp<end;temp++)
f0103dfc:	83 c4 20             	add    $0x20,%esp
			page_insert(kern_pgdir, p, (u32*)(temp->p_va + PGSIZE*i), PTE_W);
f0103dff:	c7 c0 74 3b 18 f0    	mov    $0xf0183b74,%eax
f0103e05:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (;temp<end;temp++)
f0103e08:	eb 15                	jmp    f0103e1f <env_create+0x90>
			cprintf("non load segment\n");
f0103e0a:	83 ec 0c             	sub    $0xc,%esp
f0103e0d:	8d 83 a8 57 f8 ff    	lea    -0x7a858(%ebx),%eax
f0103e13:	50                   	push   %eax
f0103e14:	e8 26 05 00 00       	call   f010433f <cprintf>
			continue;
f0103e19:	83 c4 10             	add    $0x10,%esp
	for (;temp<end;temp++)
f0103e1c:	83 c6 20             	add    $0x20,%esi
f0103e1f:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0103e22:	0f 86 02 01 00 00    	jbe    f0103f2a <env_create+0x19b>
		cprintf("p_type 0x%x, p_offset 0x%x, p_va 0x%x, p_filesz 0x%x\np_memsz 0x%x, p_flags 0x%x, p_align 0x%x\n",
f0103e28:	ff 76 1c             	push   0x1c(%esi)
f0103e2b:	ff 76 18             	push   0x18(%esi)
f0103e2e:	ff 76 14             	push   0x14(%esi)
f0103e31:	ff 76 10             	push   0x10(%esi)
f0103e34:	ff 76 08             	push   0x8(%esi)
f0103e37:	ff 76 04             	push   0x4(%esi)
f0103e3a:	ff 36                	push   (%esi)
f0103e3c:	8d 83 78 56 f8 ff    	lea    -0x7a988(%ebx),%eax
f0103e42:	50                   	push   %eax
f0103e43:	e8 f7 04 00 00       	call   f010433f <cprintf>
		if (temp->p_type != ELF_PROG_LOAD)
f0103e48:	83 c4 20             	add    $0x20,%esp
f0103e4b:	83 3e 01             	cmpl   $0x1,(%esi)
f0103e4e:	75 ba                	jne    f0103e0a <env_create+0x7b>
		cprintf("p_va 0x%x\n", temp->p_va);
f0103e50:	83 ec 08             	sub    $0x8,%esp
f0103e53:	ff 76 08             	push   0x8(%esi)
f0103e56:	8d 83 ba 57 f8 ff    	lea    -0x7a846(%ebx),%eax
f0103e5c:	50                   	push   %eax
f0103e5d:	e8 dd 04 00 00       	call   f010433f <cprintf>
		u32 pg_num = ROUNDUP(temp->p_memsz, PGSIZE)/PGSIZE;
f0103e62:	8b 46 14             	mov    0x14(%esi),%eax
f0103e65:	05 ff 0f 00 00       	add    $0xfff,%eax
f0103e6a:	c1 e8 0c             	shr    $0xc,%eax
f0103e6d:	89 c7                	mov    %eax,%edi
		cprintf("needed page number 0x%x\n", pg_num);
f0103e6f:	83 c4 08             	add    $0x8,%esp
f0103e72:	50                   	push   %eax
f0103e73:	8d 83 c5 57 f8 ff    	lea    -0x7a83b(%ebx),%eax
f0103e79:	50                   	push   %eax
f0103e7a:	e8 c0 04 00 00       	call   f010433f <cprintf>
f0103e7f:	c1 e7 0c             	shl    $0xc,%edi
f0103e82:	89 7d d0             	mov    %edi,-0x30(%ebp)
		for (u32 i = 0; i<pg_num;i++)
f0103e85:	83 c4 10             	add    $0x10,%esp
f0103e88:	bf 00 00 00 00       	mov    $0x0,%edi
f0103e8d:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0103e90:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0103e93:	74 66                	je     f0103efb <env_create+0x16c>
			struct PageInfo *p = page_alloc(ALLOC_ZERO);
f0103e95:	83 ec 0c             	sub    $0xc,%esp
f0103e98:	6a 01                	push   $0x1
f0103e9a:	e8 b4 d7 ff ff       	call   f0101653 <page_alloc>
f0103e9f:	89 c6                	mov    %eax,%esi
			if (!p)
f0103ea1:	83 c4 10             	add    $0x10,%esp
f0103ea4:	85 c0                	test   %eax,%eax
f0103ea6:	74 38                	je     f0103ee0 <env_create+0x151>
			page_insert(kern_pgdir, p, (u32*)(temp->p_va + PGSIZE*i), PTE_W);
f0103ea8:	6a 02                	push   $0x2
f0103eaa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103ead:	89 f8                	mov    %edi,%eax
f0103eaf:	03 42 08             	add    0x8(%edx),%eax
f0103eb2:	50                   	push   %eax
f0103eb3:	56                   	push   %esi
f0103eb4:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103eb7:	ff 30                	push   (%eax)
f0103eb9:	e8 43 db ff ff       	call   f0101a01 <page_insert>
			page_insert(e->env_pgdir, p, (u32*)(temp->p_va + PGSIZE*i), PTE_W | PTE_U);
f0103ebe:	6a 06                	push   $0x6
f0103ec0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103ec3:	89 f8                	mov    %edi,%eax
f0103ec5:	03 42 08             	add    0x8(%edx),%eax
f0103ec8:	50                   	push   %eax
f0103ec9:	56                   	push   %esi
f0103eca:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103ecd:	ff 70 5c             	push   0x5c(%eax)
f0103ed0:	e8 2c db ff ff       	call   f0101a01 <page_insert>
f0103ed5:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0103edb:	83 c4 20             	add    $0x20,%esp
f0103ede:	eb b0                	jmp    f0103e90 <env_create+0x101>
				panic("program page alloc fail");
f0103ee0:	83 ec 04             	sub    $0x4,%esp
f0103ee3:	8d 83 de 57 f8 ff    	lea    -0x7a822(%ebx),%eax
f0103ee9:	50                   	push   %eax
f0103eea:	68 8f 01 00 00       	push   $0x18f
f0103eef:	8d 83 20 57 f8 ff    	lea    -0x7a8e0(%ebx),%eax
f0103ef5:	50                   	push   %eax
f0103ef6:	e8 f5 c1 ff ff       	call   f01000f0 <_panic>
		cprintf("finish\n");
f0103efb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103efe:	83 ec 0c             	sub    $0xc,%esp
f0103f01:	8d 83 a9 4a f8 ff    	lea    -0x7b557(%ebx),%eax
f0103f07:	50                   	push   %eax
f0103f08:	e8 32 04 00 00       	call   f010433f <cprintf>
		memcpy((uint8_t*)temp->p_va, (uint8_t*)elf_ptr + temp->p_offset, temp->p_memsz);
f0103f0d:	83 c4 0c             	add    $0xc,%esp
f0103f10:	ff 76 14             	push   0x14(%esi)
f0103f13:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f16:	03 46 04             	add    0x4(%esi),%eax
f0103f19:	50                   	push   %eax
f0103f1a:	ff 76 08             	push   0x8(%esi)
f0103f1d:	e8 0b 19 00 00       	call   f010582d <memcpy>
f0103f22:	83 c4 10             	add    $0x10,%esp
f0103f25:	e9 f2 fe ff ff       	jmp    f0103e1c <env_create+0x8d>
	cprintf("alloc stack\n");
f0103f2a:	83 ec 0c             	sub    $0xc,%esp
f0103f2d:	8d 83 f6 57 f8 ff    	lea    -0x7a80a(%ebx),%eax
f0103f33:	50                   	push   %eax
f0103f34:	e8 06 04 00 00       	call   f010433f <cprintf>
	struct PageInfo *p_stk = page_alloc(ALLOC_ZERO);
f0103f39:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103f40:	e8 0e d7 ff ff       	call   f0101653 <page_alloc>
	if (!p_stk)
f0103f45:	83 c4 10             	add    $0x10,%esp
f0103f48:	85 c0                	test   %eax,%eax
f0103f4a:	74 50                	je     f0103f9c <env_create+0x20d>
	page_insert(e->env_pgdir, p_stk, (u32*)(USTACKTOP-PGSIZE), PTE_W | PTE_U);
f0103f4c:	6a 06                	push   $0x6
f0103f4e:	68 00 d0 bf ee       	push   $0xeebfd000
f0103f53:	50                   	push   %eax
f0103f54:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103f57:	ff 77 5c             	push   0x5c(%edi)
f0103f5a:	e8 a2 da ff ff       	call   f0101a01 <page_insert>
	e->env_tf.tf_esp = USTACKTOP-16;
f0103f5f:	c7 47 3c f0 df bf ee 	movl   $0xeebfdff0,0x3c(%edi)
	cprintf("alloc stack done\n");
f0103f66:	8d 83 19 58 f8 ff    	lea    -0x7a7e7(%ebx),%eax
f0103f6c:	89 04 24             	mov    %eax,(%esp)
f0103f6f:	e8 cb 03 00 00       	call   f010433f <cprintf>
	e->env_tf.tf_eip = elf_ptr->e_entry; 
f0103f74:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f77:	8b 40 18             	mov    0x18(%eax),%eax
f0103f7a:	89 47 30             	mov    %eax,0x30(%edi)
	load_icode(new, binary);
	cprintf("load icode done\n");
f0103f7d:	8d 83 2b 58 f8 ff    	lea    -0x7a7d5(%ebx),%eax
f0103f83:	89 04 24             	mov    %eax,(%esp)
f0103f86:	e8 b4 03 00 00       	call   f010433f <cprintf>

	(new)->env_type = type;
f0103f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f8e:	89 47 50             	mov    %eax,0x50(%edi)
}
f0103f91:	83 c4 10             	add    $0x10,%esp
f0103f94:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f97:	5b                   	pop    %ebx
f0103f98:	5e                   	pop    %esi
f0103f99:	5f                   	pop    %edi
f0103f9a:	5d                   	pop    %ebp
f0103f9b:	c3                   	ret    
		panic("stack page alloc fail");
f0103f9c:	83 ec 04             	sub    $0x4,%esp
f0103f9f:	8d 83 03 58 f8 ff    	lea    -0x7a7fd(%ebx),%eax
f0103fa5:	50                   	push   %eax
f0103fa6:	68 9e 01 00 00       	push   $0x19e
f0103fab:	8d 83 20 57 f8 ff    	lea    -0x7a8e0(%ebx),%eax
f0103fb1:	50                   	push   %eax
f0103fb2:	e8 39 c1 ff ff       	call   f01000f0 <_panic>

f0103fb7 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103fb7:	55                   	push   %ebp
f0103fb8:	89 e5                	mov    %esp,%ebp
f0103fba:	57                   	push   %edi
f0103fbb:	56                   	push   %esi
f0103fbc:	53                   	push   %ebx
f0103fbd:	83 ec 2c             	sub    $0x2c,%esp
f0103fc0:	e8 e1 c1 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0103fc5:	81 c3 a7 d8 07 00    	add    $0x7d8a7,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103fcb:	8b 93 18 23 00 00    	mov    0x2318(%ebx),%edx
f0103fd1:	3b 55 08             	cmp    0x8(%ebp),%edx
f0103fd4:	74 47                	je     f010401d <env_free+0x66>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103fd6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fd9:	8b 48 48             	mov    0x48(%eax),%ecx
f0103fdc:	b8 00 00 00 00       	mov    $0x0,%eax
f0103fe1:	85 d2                	test   %edx,%edx
f0103fe3:	74 03                	je     f0103fe8 <env_free+0x31>
f0103fe5:	8b 42 48             	mov    0x48(%edx),%eax
f0103fe8:	83 ec 04             	sub    $0x4,%esp
f0103feb:	51                   	push   %ecx
f0103fec:	50                   	push   %eax
f0103fed:	8d 83 3c 58 f8 ff    	lea    -0x7a7c4(%ebx),%eax
f0103ff3:	50                   	push   %eax
f0103ff4:	e8 46 03 00 00       	call   f010433f <cprintf>
f0103ff9:	83 c4 10             	add    $0x10,%esp
f0103ffc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	if (PGNUM(pa) >= npages)
f0104003:	c7 c0 78 3b 18 f0    	mov    $0xf0183b78,%eax
f0104009:	89 45 d8             	mov    %eax,-0x28(%ebp)
	if (PGNUM(pa) >= npages)
f010400c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return &pages[PGNUM(pa)];
f010400f:	c7 c0 70 3b 18 f0    	mov    $0xf0183b70,%eax
f0104015:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104018:	e9 bf 00 00 00       	jmp    f01040dc <env_free+0x125>
		lcr3(PADDR(kern_pgdir));
f010401d:	c7 c0 74 3b 18 f0    	mov    $0xf0183b74,%eax
f0104023:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0104025:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010402a:	76 10                	jbe    f010403c <env_free+0x85>
	return (physaddr_t)kva - KERNBASE;
f010402c:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104031:	0f 22 d8             	mov    %eax,%cr3
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0104034:	8b 45 08             	mov    0x8(%ebp),%eax
f0104037:	8b 48 48             	mov    0x48(%eax),%ecx
f010403a:	eb a9                	jmp    f0103fe5 <env_free+0x2e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010403c:	50                   	push   %eax
f010403d:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f0104043:	50                   	push   %eax
f0104044:	68 c7 01 00 00       	push   $0x1c7
f0104049:	8d 83 20 57 f8 ff    	lea    -0x7a8e0(%ebx),%eax
f010404f:	50                   	push   %eax
f0104050:	e8 9b c0 ff ff       	call   f01000f0 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104055:	57                   	push   %edi
f0104056:	8d 83 1c 4e f8 ff    	lea    -0x7b1e4(%ebx),%eax
f010405c:	50                   	push   %eax
f010405d:	68 d6 01 00 00       	push   $0x1d6
f0104062:	8d 83 20 57 f8 ff    	lea    -0x7a8e0(%ebx),%eax
f0104068:	50                   	push   %eax
f0104069:	e8 82 c0 ff ff       	call   f01000f0 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010406e:	83 c7 04             	add    $0x4,%edi
f0104071:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0104077:	81 fe 00 00 40 00    	cmp    $0x400000,%esi
f010407d:	74 1e                	je     f010409d <env_free+0xe6>
			if (pt[pteno] & PTE_P)
f010407f:	f6 07 01             	testb  $0x1,(%edi)
f0104082:	74 ea                	je     f010406e <env_free+0xb7>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0104084:	83 ec 08             	sub    $0x8,%esp
f0104087:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010408a:	09 f0                	or     %esi,%eax
f010408c:	50                   	push   %eax
f010408d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104090:	ff 70 5c             	push   0x5c(%eax)
f0104093:	e8 23 d9 ff ff       	call   f01019bb <page_remove>
f0104098:	83 c4 10             	add    $0x10,%esp
f010409b:	eb d1                	jmp    f010406e <env_free+0xb7>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f010409d:	8b 45 08             	mov    0x8(%ebp),%eax
f01040a0:	8b 40 5c             	mov    0x5c(%eax),%eax
f01040a3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01040a6:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01040ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01040b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01040b3:	3b 10                	cmp    (%eax),%edx
f01040b5:	73 67                	jae    f010411e <env_free+0x167>
		page_decref(pa2page(pa));
f01040b7:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01040ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01040bd:	8b 00                	mov    (%eax),%eax
f01040bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01040c2:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01040c5:	50                   	push   %eax
f01040c6:	e8 76 d6 ff ff       	call   f0101741 <page_decref>
f01040cb:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01040ce:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01040d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01040d5:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01040da:	74 5a                	je     f0104136 <env_free+0x17f>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01040dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01040df:	8b 40 5c             	mov    0x5c(%eax),%eax
f01040e2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01040e5:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f01040e8:	a8 01                	test   $0x1,%al
f01040ea:	74 e2                	je     f01040ce <env_free+0x117>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01040ec:	89 c7                	mov    %eax,%edi
f01040ee:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f01040f4:	c1 e8 0c             	shr    $0xc,%eax
f01040f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01040fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01040fd:	3b 02                	cmp    (%edx),%eax
f01040ff:	0f 83 50 ff ff ff    	jae    f0104055 <env_free+0x9e>
	return (void *)(pa + KERNBASE);
f0104105:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
f010410b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010410e:	c1 e0 14             	shl    $0x14,%eax
f0104111:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104114:	be 00 00 00 00       	mov    $0x0,%esi
f0104119:	e9 61 ff ff ff       	jmp    f010407f <env_free+0xc8>
		panic("pa2page called with invalid pa");
f010411e:	83 ec 04             	sub    $0x4,%esp
f0104121:	8d 83 70 4f f8 ff    	lea    -0x7b090(%ebx),%eax
f0104127:	50                   	push   %eax
f0104128:	6a 55                	push   $0x55
f010412a:	8d 83 b1 4a f8 ff    	lea    -0x7b54f(%ebx),%eax
f0104130:	50                   	push   %eax
f0104131:	e8 ba bf ff ff       	call   f01000f0 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0104136:	8b 45 08             	mov    0x8(%ebp),%eax
f0104139:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010413c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104141:	76 57                	jbe    f010419a <env_free+0x1e3>
	e->env_pgdir = 0;
f0104143:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104146:	c7 41 5c 00 00 00 00 	movl   $0x0,0x5c(%ecx)
	return (physaddr_t)kva - KERNBASE;
f010414d:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0104152:	c1 e8 0c             	shr    $0xc,%eax
f0104155:	c7 c2 78 3b 18 f0    	mov    $0xf0183b78,%edx
f010415b:	3b 02                	cmp    (%edx),%eax
f010415d:	73 54                	jae    f01041b3 <env_free+0x1fc>
	page_decref(pa2page(pa));
f010415f:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0104162:	c7 c2 70 3b 18 f0    	mov    $0xf0183b70,%edx
f0104168:	8b 12                	mov    (%edx),%edx
f010416a:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010416d:	50                   	push   %eax
f010416e:	e8 ce d5 ff ff       	call   f0101741 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104173:	8b 45 08             	mov    0x8(%ebp),%eax
f0104176:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f010417d:	8b 83 20 23 00 00    	mov    0x2320(%ebx),%eax
f0104183:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104186:	89 41 44             	mov    %eax,0x44(%ecx)
	env_free_list = e;
f0104189:	89 8b 20 23 00 00    	mov    %ecx,0x2320(%ebx)
}
f010418f:	83 c4 10             	add    $0x10,%esp
f0104192:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104195:	5b                   	pop    %ebx
f0104196:	5e                   	pop    %esi
f0104197:	5f                   	pop    %edi
f0104198:	5d                   	pop    %ebp
f0104199:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010419a:	50                   	push   %eax
f010419b:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f01041a1:	50                   	push   %eax
f01041a2:	68 e4 01 00 00       	push   $0x1e4
f01041a7:	8d 83 20 57 f8 ff    	lea    -0x7a8e0(%ebx),%eax
f01041ad:	50                   	push   %eax
f01041ae:	e8 3d bf ff ff       	call   f01000f0 <_panic>
		panic("pa2page called with invalid pa");
f01041b3:	83 ec 04             	sub    $0x4,%esp
f01041b6:	8d 83 70 4f f8 ff    	lea    -0x7b090(%ebx),%eax
f01041bc:	50                   	push   %eax
f01041bd:	6a 55                	push   $0x55
f01041bf:	8d 83 b1 4a f8 ff    	lea    -0x7b54f(%ebx),%eax
f01041c5:	50                   	push   %eax
f01041c6:	e8 25 bf ff ff       	call   f01000f0 <_panic>

f01041cb <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01041cb:	55                   	push   %ebp
f01041cc:	89 e5                	mov    %esp,%ebp
f01041ce:	53                   	push   %ebx
f01041cf:	83 ec 10             	sub    $0x10,%esp
f01041d2:	e8 cf bf ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01041d7:	81 c3 95 d6 07 00    	add    $0x7d695,%ebx
	env_free(e);
f01041dd:	ff 75 08             	push   0x8(%ebp)
f01041e0:	e8 d2 fd ff ff       	call   f0103fb7 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01041e5:	8d 83 d8 56 f8 ff    	lea    -0x7a928(%ebx),%eax
f01041eb:	89 04 24             	mov    %eax,(%esp)
f01041ee:	e8 4c 01 00 00       	call   f010433f <cprintf>
f01041f3:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01041f6:	83 ec 0c             	sub    $0xc,%esp
f01041f9:	6a 00                	push   $0x0
f01041fb:	e8 7b cd ff ff       	call   f0100f7b <monitor>
f0104200:	83 c4 10             	add    $0x10,%esp
f0104203:	eb f1                	jmp    f01041f6 <env_destroy+0x2b>

f0104205 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0104205:	55                   	push   %ebp
f0104206:	89 e5                	mov    %esp,%ebp
f0104208:	53                   	push   %ebx
f0104209:	83 ec 08             	sub    $0x8,%esp
f010420c:	e8 95 bf ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0104211:	81 c3 5b d6 07 00    	add    $0x7d65b,%ebx
	asm volatile(
f0104217:	8b 65 08             	mov    0x8(%ebp),%esp
f010421a:	61                   	popa   
f010421b:	07                   	pop    %es
f010421c:	1f                   	pop    %ds
f010421d:	83 c4 08             	add    $0x8,%esp
f0104220:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0104221:	8d 83 52 58 f8 ff    	lea    -0x7a7ae(%ebx),%eax
f0104227:	50                   	push   %eax
f0104228:	68 0d 02 00 00       	push   $0x20d
f010422d:	8d 83 20 57 f8 ff    	lea    -0x7a8e0(%ebx),%eax
f0104233:	50                   	push   %eax
f0104234:	e8 b7 be ff ff       	call   f01000f0 <_panic>

f0104239 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0104239:	55                   	push   %ebp
f010423a:	89 e5                	mov    %esp,%ebp
f010423c:	56                   	push   %esi
f010423d:	53                   	push   %ebx
f010423e:	e8 63 bf ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0104243:	81 c3 29 d6 07 00    	add    $0x7d629,%ebx
f0104249:	8b 75 08             	mov    0x8(%ebp),%esi
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv)
f010424c:	8b 83 18 23 00 00    	mov    0x2318(%ebx),%eax
f0104252:	85 c0                	test   %eax,%eax
f0104254:	74 06                	je     f010425c <env_run+0x23>
	{
		if (curenv->env_status == ENV_RUNNING)
f0104256:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010425a:	74 3a                	je     f0104296 <env_run+0x5d>
			curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
f010425c:	89 b3 18 23 00 00    	mov    %esi,0x2318(%ebx)
	e->env_status = ENV_RUNNING;	
f0104262:	c7 46 54 03 00 00 00 	movl   $0x3,0x54(%esi)
	e->env_runs++;
f0104269:	83 46 58 01          	addl   $0x1,0x58(%esi)
	lcr3(PADDR(e->env_pgdir));
f010426d:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0104270:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104275:	76 28                	jbe    f010429f <env_run+0x66>
	return (physaddr_t)kva - KERNBASE;
f0104277:	05 00 00 00 10       	add    $0x10000000,%eax
f010427c:	0f 22 d8             	mov    %eax,%cr3
	cprintf("gogogo\n");
f010427f:	83 ec 0c             	sub    $0xc,%esp
f0104282:	8d 83 e2 4d f8 ff    	lea    -0x7b21e(%ebx),%eax
f0104288:	50                   	push   %eax
f0104289:	e8 b1 00 00 00       	call   f010433f <cprintf>
	env_pop_tf(&e->env_tf);
f010428e:	89 34 24             	mov    %esi,(%esp)
f0104291:	e8 6f ff ff ff       	call   f0104205 <env_pop_tf>
			curenv->env_status = ENV_RUNNABLE;
f0104296:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f010429d:	eb bd                	jmp    f010425c <env_run+0x23>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010429f:	50                   	push   %eax
f01042a0:	8d 83 ec 4f f8 ff    	lea    -0x7b014(%ebx),%eax
f01042a6:	50                   	push   %eax
f01042a7:	68 33 02 00 00       	push   $0x233
f01042ac:	8d 83 20 57 f8 ff    	lea    -0x7a8e0(%ebx),%eax
f01042b2:	50                   	push   %eax
f01042b3:	e8 38 be ff ff       	call   f01000f0 <_panic>

f01042b8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01042b8:	55                   	push   %ebp
f01042b9:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01042bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01042be:	ba 70 00 00 00       	mov    $0x70,%edx
f01042c3:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01042c4:	ba 71 00 00 00       	mov    $0x71,%edx
f01042c9:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01042ca:	0f b6 c0             	movzbl %al,%eax
}
f01042cd:	5d                   	pop    %ebp
f01042ce:	c3                   	ret    

f01042cf <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01042cf:	55                   	push   %ebp
f01042d0:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01042d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01042d5:	ba 70 00 00 00       	mov    $0x70,%edx
f01042da:	ee                   	out    %al,(%dx)
f01042db:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042de:	ba 71 00 00 00       	mov    $0x71,%edx
f01042e3:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01042e4:	5d                   	pop    %ebp
f01042e5:	c3                   	ret    

f01042e6 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01042e6:	55                   	push   %ebp
f01042e7:	89 e5                	mov    %esp,%ebp
f01042e9:	53                   	push   %ebx
f01042ea:	83 ec 10             	sub    $0x10,%esp
f01042ed:	e8 b4 be ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01042f2:	81 c3 7a d5 07 00    	add    $0x7d57a,%ebx
	cputchar(ch);
f01042f8:	ff 75 08             	push   0x8(%ebp)
f01042fb:	e8 11 c4 ff ff       	call   f0100711 <cputchar>
	*cnt++;
}
f0104300:	83 c4 10             	add    $0x10,%esp
f0104303:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104306:	c9                   	leave  
f0104307:	c3                   	ret    

f0104308 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0104308:	55                   	push   %ebp
f0104309:	89 e5                	mov    %esp,%ebp
f010430b:	53                   	push   %ebx
f010430c:	83 ec 14             	sub    $0x14,%esp
f010430f:	e8 92 be ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0104314:	81 c3 58 d5 07 00    	add    $0x7d558,%ebx
	int cnt = 0;
f010431a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104321:	ff 75 0c             	push   0xc(%ebp)
f0104324:	ff 75 08             	push   0x8(%ebp)
f0104327:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010432a:	50                   	push   %eax
f010432b:	8d 83 7a 2a f8 ff    	lea    -0x7d586(%ebx),%eax
f0104331:	50                   	push   %eax
f0104332:	e8 d9 0c 00 00       	call   f0105010 <vprintfmt>
	return cnt;
}
f0104337:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010433a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010433d:	c9                   	leave  
f010433e:	c3                   	ret    

f010433f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010433f:	55                   	push   %ebp
f0104340:	89 e5                	mov    %esp,%ebp
f0104342:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104345:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0104348:	50                   	push   %eax
f0104349:	ff 75 08             	push   0x8(%ebp)
f010434c:	e8 b7 ff ff ff       	call   f0104308 <vcprintf>
	va_end(ap);

	return cnt;
}
f0104351:	c9                   	leave  
f0104352:	c3                   	ret    

f0104353 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104353:	55                   	push   %ebp
f0104354:	89 e5                	mov    %esp,%ebp
f0104356:	57                   	push   %edi
f0104357:	56                   	push   %esi
f0104358:	53                   	push   %ebx
f0104359:	83 ec 04             	sub    $0x4,%esp
f010435c:	e8 45 be ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0104361:	81 c3 0b d5 07 00    	add    $0x7d50b,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0104367:	c7 83 58 2b 00 00 00 	movl   $0xf0000000,0x2b58(%ebx)
f010436e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0104371:	66 c7 83 5c 2b 00 00 	movw   $0x10,0x2b5c(%ebx)
f0104378:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f010437a:	66 c7 83 ba 2b 00 00 	movw   $0x68,0x2bba(%ebx)
f0104381:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0104383:	c7 c0 00 e3 11 f0    	mov    $0xf011e300,%eax
f0104389:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f010438f:	8d b3 54 2b 00 00    	lea    0x2b54(%ebx),%esi
f0104395:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0104399:	89 f2                	mov    %esi,%edx
f010439b:	c1 ea 10             	shr    $0x10,%edx
f010439e:	88 50 2c             	mov    %dl,0x2c(%eax)
f01043a1:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f01043a5:	83 e2 f0             	and    $0xfffffff0,%edx
f01043a8:	83 ca 09             	or     $0x9,%edx
f01043ab:	83 e2 9f             	and    $0xffffff9f,%edx
f01043ae:	83 ca 80             	or     $0xffffff80,%edx
f01043b1:	88 55 f3             	mov    %dl,-0xd(%ebp)
f01043b4:	88 50 2d             	mov    %dl,0x2d(%eax)
f01043b7:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f01043bb:	83 e1 c0             	and    $0xffffffc0,%ecx
f01043be:	83 c9 40             	or     $0x40,%ecx
f01043c1:	83 e1 7f             	and    $0x7f,%ecx
f01043c4:	88 48 2e             	mov    %cl,0x2e(%eax)
f01043c7:	c1 ee 18             	shr    $0x18,%esi
f01043ca:	89 f1                	mov    %esi,%ecx
f01043cc:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01043cf:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f01043d3:	83 e2 ef             	and    $0xffffffef,%edx
f01043d6:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f01043d9:	b8 28 00 00 00       	mov    $0x28,%eax
f01043de:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01043e1:	8d 83 9c 17 00 00    	lea    0x179c(%ebx),%eax
f01043e7:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01043ea:	83 c4 04             	add    $0x4,%esp
f01043ed:	5b                   	pop    %ebx
f01043ee:	5e                   	pop    %esi
f01043ef:	5f                   	pop    %edi
f01043f0:	5d                   	pop    %ebp
f01043f1:	c3                   	ret    

f01043f2 <trap_init>:
{
f01043f2:	55                   	push   %ebp
f01043f3:	89 e5                	mov    %esp,%ebp
f01043f5:	56                   	push   %esi
f01043f6:	53                   	push   %ebx
f01043f7:	e8 aa bd ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01043fc:	81 c3 70 d4 07 00    	add    $0x7d470,%ebx
	cprintf("trap init\n");
f0104402:	83 ec 0c             	sub    $0xc,%esp
f0104405:	8d 83 5e 58 f8 ff    	lea    -0x7a7a2(%ebx),%eax
f010440b:	50                   	push   %eax
f010440c:	e8 2e ff ff ff       	call   f010433f <cprintf>
	cprintf("divide handle addr 0x%x\n", (u32)t_divide);
f0104411:	c7 c6 94 4b 10 f0    	mov    $0xf0104b94,%esi
f0104417:	83 c4 08             	add    $0x8,%esp
f010441a:	56                   	push   %esi
f010441b:	8d 83 69 58 f8 ff    	lea    -0x7a797(%ebx),%eax
f0104421:	50                   	push   %eax
f0104422:	e8 18 ff ff ff       	call   f010433f <cprintf>
	SETGATE(idt[T_DIVIDE], 1, GD_KT, t_divide, 0)
f0104427:	66 89 b3 34 23 00 00 	mov    %si,0x2334(%ebx)
f010442e:	66 c7 83 36 23 00 00 	movw   $0x8,0x2336(%ebx)
f0104435:	08 00 
f0104437:	c6 83 38 23 00 00 00 	movb   $0x0,0x2338(%ebx)
f010443e:	c6 83 39 23 00 00 8f 	movb   $0x8f,0x2339(%ebx)
f0104445:	c1 ee 10             	shr    $0x10,%esi
f0104448:	66 89 b3 3a 23 00 00 	mov    %si,0x233a(%ebx)
	SETGATE(idt[T_DEBUG], 1, GD_KT, t_debug, 1)
f010444f:	c7 c0 9a 4b 10 f0    	mov    $0xf0104b9a,%eax
f0104455:	66 89 83 3c 23 00 00 	mov    %ax,0x233c(%ebx)
f010445c:	66 c7 83 3e 23 00 00 	movw   $0x8,0x233e(%ebx)
f0104463:	08 00 
f0104465:	c6 83 40 23 00 00 00 	movb   $0x0,0x2340(%ebx)
f010446c:	c6 83 41 23 00 00 af 	movb   $0xaf,0x2341(%ebx)
f0104473:	c1 e8 10             	shr    $0x10,%eax
f0104476:	66 89 83 42 23 00 00 	mov    %ax,0x2342(%ebx)
	SETGATE(idt[T_NMI], 1, GD_KT, t_nmi, 1)
f010447d:	c7 c0 a0 4b 10 f0    	mov    $0xf0104ba0,%eax
f0104483:	66 89 83 44 23 00 00 	mov    %ax,0x2344(%ebx)
f010448a:	66 c7 83 46 23 00 00 	movw   $0x8,0x2346(%ebx)
f0104491:	08 00 
f0104493:	c6 83 48 23 00 00 00 	movb   $0x0,0x2348(%ebx)
f010449a:	c6 83 49 23 00 00 af 	movb   $0xaf,0x2349(%ebx)
f01044a1:	c1 e8 10             	shr    $0x10,%eax
f01044a4:	66 89 83 4a 23 00 00 	mov    %ax,0x234a(%ebx)
	SETGATE(idt[T_BRKPT], 1, GD_KT, t_brkpt, 1)
f01044ab:	c7 c0 a6 4b 10 f0    	mov    $0xf0104ba6,%eax
f01044b1:	66 89 83 4c 23 00 00 	mov    %ax,0x234c(%ebx)
f01044b8:	66 c7 83 4e 23 00 00 	movw   $0x8,0x234e(%ebx)
f01044bf:	08 00 
f01044c1:	c6 83 50 23 00 00 00 	movb   $0x0,0x2350(%ebx)
f01044c8:	c6 83 51 23 00 00 af 	movb   $0xaf,0x2351(%ebx)
f01044cf:	c1 e8 10             	shr    $0x10,%eax
f01044d2:	66 89 83 52 23 00 00 	mov    %ax,0x2352(%ebx)
	SETGATE(idt[T_OFLOW], 1, GD_KT, t_oflow, 1)
f01044d9:	c7 c0 ac 4b 10 f0    	mov    $0xf0104bac,%eax
f01044df:	66 89 83 54 23 00 00 	mov    %ax,0x2354(%ebx)
f01044e6:	66 c7 83 56 23 00 00 	movw   $0x8,0x2356(%ebx)
f01044ed:	08 00 
f01044ef:	c6 83 58 23 00 00 00 	movb   $0x0,0x2358(%ebx)
f01044f6:	c6 83 59 23 00 00 af 	movb   $0xaf,0x2359(%ebx)
f01044fd:	c1 e8 10             	shr    $0x10,%eax
f0104500:	66 89 83 5a 23 00 00 	mov    %ax,0x235a(%ebx)
	SETGATE(idt[T_BOUND], 1, GD_KT, t_bound, 1)
f0104507:	c7 c0 b2 4b 10 f0    	mov    $0xf0104bb2,%eax
f010450d:	66 89 83 5c 23 00 00 	mov    %ax,0x235c(%ebx)
f0104514:	66 c7 83 5e 23 00 00 	movw   $0x8,0x235e(%ebx)
f010451b:	08 00 
f010451d:	c6 83 60 23 00 00 00 	movb   $0x0,0x2360(%ebx)
f0104524:	c6 83 61 23 00 00 af 	movb   $0xaf,0x2361(%ebx)
f010452b:	c1 e8 10             	shr    $0x10,%eax
f010452e:	66 89 83 62 23 00 00 	mov    %ax,0x2362(%ebx)
	SETGATE(idt[T_ILLOP], 1, GD_KT, t_illop, 1)
f0104535:	c7 c0 b8 4b 10 f0    	mov    $0xf0104bb8,%eax
f010453b:	66 89 83 64 23 00 00 	mov    %ax,0x2364(%ebx)
f0104542:	66 c7 83 66 23 00 00 	movw   $0x8,0x2366(%ebx)
f0104549:	08 00 
f010454b:	c6 83 68 23 00 00 00 	movb   $0x0,0x2368(%ebx)
f0104552:	c6 83 69 23 00 00 af 	movb   $0xaf,0x2369(%ebx)
f0104559:	c1 e8 10             	shr    $0x10,%eax
f010455c:	66 89 83 6a 23 00 00 	mov    %ax,0x236a(%ebx)
	SETGATE(idt[T_DEVICE], 1, GD_KT, t_device, 1)
f0104563:	c7 c0 be 4b 10 f0    	mov    $0xf0104bbe,%eax
f0104569:	66 89 83 6c 23 00 00 	mov    %ax,0x236c(%ebx)
f0104570:	66 c7 83 6e 23 00 00 	movw   $0x8,0x236e(%ebx)
f0104577:	08 00 
f0104579:	c6 83 70 23 00 00 00 	movb   $0x0,0x2370(%ebx)
f0104580:	c6 83 71 23 00 00 af 	movb   $0xaf,0x2371(%ebx)
f0104587:	c1 e8 10             	shr    $0x10,%eax
f010458a:	66 89 83 72 23 00 00 	mov    %ax,0x2372(%ebx)
	SETGATE(idt[T_DBLFLT], 1, GD_KT, t_dblflt, 1)
f0104591:	c7 c0 c4 4b 10 f0    	mov    $0xf0104bc4,%eax
f0104597:	66 89 83 74 23 00 00 	mov    %ax,0x2374(%ebx)
f010459e:	66 c7 83 76 23 00 00 	movw   $0x8,0x2376(%ebx)
f01045a5:	08 00 
f01045a7:	c6 83 78 23 00 00 00 	movb   $0x0,0x2378(%ebx)
f01045ae:	c6 83 79 23 00 00 af 	movb   $0xaf,0x2379(%ebx)
f01045b5:	c1 e8 10             	shr    $0x10,%eax
f01045b8:	66 89 83 7a 23 00 00 	mov    %ax,0x237a(%ebx)
	SETGATE(idt[T_TSS], 1, GD_KT, t_tss, 1)
f01045bf:	c7 c0 c8 4b 10 f0    	mov    $0xf0104bc8,%eax
f01045c5:	66 89 83 84 23 00 00 	mov    %ax,0x2384(%ebx)
f01045cc:	66 c7 83 86 23 00 00 	movw   $0x8,0x2386(%ebx)
f01045d3:	08 00 
f01045d5:	c6 83 88 23 00 00 00 	movb   $0x0,0x2388(%ebx)
f01045dc:	c6 83 89 23 00 00 af 	movb   $0xaf,0x2389(%ebx)
f01045e3:	c1 e8 10             	shr    $0x10,%eax
f01045e6:	66 89 83 8a 23 00 00 	mov    %ax,0x238a(%ebx)
	SETGATE(idt[T_SEGNP], 1, GD_KT, t_segnp, 1)
f01045ed:	c7 c0 cc 4b 10 f0    	mov    $0xf0104bcc,%eax
f01045f3:	66 89 83 8c 23 00 00 	mov    %ax,0x238c(%ebx)
f01045fa:	66 c7 83 8e 23 00 00 	movw   $0x8,0x238e(%ebx)
f0104601:	08 00 
f0104603:	c6 83 90 23 00 00 00 	movb   $0x0,0x2390(%ebx)
f010460a:	c6 83 91 23 00 00 af 	movb   $0xaf,0x2391(%ebx)
f0104611:	c1 e8 10             	shr    $0x10,%eax
f0104614:	66 89 83 92 23 00 00 	mov    %ax,0x2392(%ebx)
	SETGATE(idt[T_STACK], 1, GD_KT, t_stack, 1)
f010461b:	c7 c0 d0 4b 10 f0    	mov    $0xf0104bd0,%eax
f0104621:	66 89 83 94 23 00 00 	mov    %ax,0x2394(%ebx)
f0104628:	66 c7 83 96 23 00 00 	movw   $0x8,0x2396(%ebx)
f010462f:	08 00 
f0104631:	c6 83 98 23 00 00 00 	movb   $0x0,0x2398(%ebx)
f0104638:	c6 83 99 23 00 00 af 	movb   $0xaf,0x2399(%ebx)
f010463f:	c1 e8 10             	shr    $0x10,%eax
f0104642:	66 89 83 9a 23 00 00 	mov    %ax,0x239a(%ebx)
	SETGATE(idt[T_GPFLT], 1, GD_KT, t_gpflt, 1)
f0104649:	c7 c0 d4 4b 10 f0    	mov    $0xf0104bd4,%eax
f010464f:	66 89 83 9c 23 00 00 	mov    %ax,0x239c(%ebx)
f0104656:	66 c7 83 9e 23 00 00 	movw   $0x8,0x239e(%ebx)
f010465d:	08 00 
f010465f:	c6 83 a0 23 00 00 00 	movb   $0x0,0x23a0(%ebx)
f0104666:	c6 83 a1 23 00 00 af 	movb   $0xaf,0x23a1(%ebx)
f010466d:	c1 e8 10             	shr    $0x10,%eax
f0104670:	66 89 83 a2 23 00 00 	mov    %ax,0x23a2(%ebx)
	SETGATE(idt[T_PGFLT], 1, GD_KT, t_pgflt, 1)
f0104677:	c7 c0 d8 4b 10 f0    	mov    $0xf0104bd8,%eax
f010467d:	66 89 83 a4 23 00 00 	mov    %ax,0x23a4(%ebx)
f0104684:	66 c7 83 a6 23 00 00 	movw   $0x8,0x23a6(%ebx)
f010468b:	08 00 
f010468d:	c6 83 a8 23 00 00 00 	movb   $0x0,0x23a8(%ebx)
f0104694:	c6 83 a9 23 00 00 af 	movb   $0xaf,0x23a9(%ebx)
f010469b:	c1 e8 10             	shr    $0x10,%eax
f010469e:	66 89 83 aa 23 00 00 	mov    %ax,0x23aa(%ebx)
	SETGATE(idt[T_FPERR], 1, GD_KT, t_fperr, 1)
f01046a5:	c7 c0 dc 4b 10 f0    	mov    $0xf0104bdc,%eax
f01046ab:	66 89 83 b4 23 00 00 	mov    %ax,0x23b4(%ebx)
f01046b2:	66 c7 83 b6 23 00 00 	movw   $0x8,0x23b6(%ebx)
f01046b9:	08 00 
f01046bb:	c6 83 b8 23 00 00 00 	movb   $0x0,0x23b8(%ebx)
f01046c2:	c6 83 b9 23 00 00 af 	movb   $0xaf,0x23b9(%ebx)
f01046c9:	c1 e8 10             	shr    $0x10,%eax
f01046cc:	66 89 83 ba 23 00 00 	mov    %ax,0x23ba(%ebx)
	SETGATE(idt[T_ALIGN], 1, GD_KT, t_align, 1)
f01046d3:	c7 c0 e2 4b 10 f0    	mov    $0xf0104be2,%eax
f01046d9:	66 89 83 bc 23 00 00 	mov    %ax,0x23bc(%ebx)
f01046e0:	66 c7 83 be 23 00 00 	movw   $0x8,0x23be(%ebx)
f01046e7:	08 00 
f01046e9:	c6 83 c0 23 00 00 00 	movb   $0x0,0x23c0(%ebx)
f01046f0:	c6 83 c1 23 00 00 af 	movb   $0xaf,0x23c1(%ebx)
f01046f7:	c1 e8 10             	shr    $0x10,%eax
f01046fa:	66 89 83 c2 23 00 00 	mov    %ax,0x23c2(%ebx)
	SETGATE(idt[T_MCHK], 1, GD_KT, t_mchk, 1)
f0104701:	c7 c0 e6 4b 10 f0    	mov    $0xf0104be6,%eax
f0104707:	66 89 83 c4 23 00 00 	mov    %ax,0x23c4(%ebx)
f010470e:	66 c7 83 c6 23 00 00 	movw   $0x8,0x23c6(%ebx)
f0104715:	08 00 
f0104717:	c6 83 c8 23 00 00 00 	movb   $0x0,0x23c8(%ebx)
f010471e:	c6 83 c9 23 00 00 af 	movb   $0xaf,0x23c9(%ebx)
f0104725:	c1 e8 10             	shr    $0x10,%eax
f0104728:	66 89 83 ca 23 00 00 	mov    %ax,0x23ca(%ebx)
	SETGATE(idt[T_SIMDERR], 1, GD_KT, t_simderr, 1)
f010472f:	c7 c0 ec 4b 10 f0    	mov    $0xf0104bec,%eax
f0104735:	66 89 83 cc 23 00 00 	mov    %ax,0x23cc(%ebx)
f010473c:	66 c7 83 ce 23 00 00 	movw   $0x8,0x23ce(%ebx)
f0104743:	08 00 
f0104745:	c6 83 d0 23 00 00 00 	movb   $0x0,0x23d0(%ebx)
f010474c:	c6 83 d1 23 00 00 af 	movb   $0xaf,0x23d1(%ebx)
f0104753:	c1 e8 10             	shr    $0x10,%eax
f0104756:	66 89 83 d2 23 00 00 	mov    %ax,0x23d2(%ebx)
	SETGATE(idt[T_SYSCALL], 1, GD_KT, t_syscall, 1)
f010475d:	c7 c0 f2 4b 10 f0    	mov    $0xf0104bf2,%eax
f0104763:	66 89 83 b4 24 00 00 	mov    %ax,0x24b4(%ebx)
f010476a:	66 c7 83 b6 24 00 00 	movw   $0x8,0x24b6(%ebx)
f0104771:	08 00 
f0104773:	c6 83 b8 24 00 00 00 	movb   $0x0,0x24b8(%ebx)
f010477a:	c6 83 b9 24 00 00 af 	movb   $0xaf,0x24b9(%ebx)
f0104781:	c1 e8 10             	shr    $0x10,%eax
f0104784:	66 89 83 ba 24 00 00 	mov    %ax,0x24ba(%ebx)
	SETGATE(idt[T_DEFAULT], 1, GD_KT, t_default, 1)
f010478b:	c7 c0 f8 4b 10 f0    	mov    $0xf0104bf8,%eax
f0104791:	66 89 83 d4 32 00 00 	mov    %ax,0x32d4(%ebx)
f0104798:	66 c7 83 d6 32 00 00 	movw   $0x8,0x32d6(%ebx)
f010479f:	08 00 
f01047a1:	c6 83 d8 32 00 00 00 	movb   $0x0,0x32d8(%ebx)
f01047a8:	c6 83 d9 32 00 00 af 	movb   $0xaf,0x32d9(%ebx)
f01047af:	c1 e8 10             	shr    $0x10,%eax
f01047b2:	66 89 83 da 32 00 00 	mov    %ax,0x32da(%ebx)
	trap_init_percpu();
f01047b9:	e8 95 fb ff ff       	call   f0104353 <trap_init_percpu>
}
f01047be:	83 c4 10             	add    $0x10,%esp
f01047c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01047c4:	5b                   	pop    %ebx
f01047c5:	5e                   	pop    %esi
f01047c6:	5d                   	pop    %ebp
f01047c7:	c3                   	ret    

f01047c8 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01047c8:	55                   	push   %ebp
f01047c9:	89 e5                	mov    %esp,%ebp
f01047cb:	56                   	push   %esi
f01047cc:	53                   	push   %ebx
f01047cd:	e8 d4 b9 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f01047d2:	81 c3 9a d0 07 00    	add    $0x7d09a,%ebx
f01047d8:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01047db:	83 ec 08             	sub    $0x8,%esp
f01047de:	ff 36                	push   (%esi)
f01047e0:	8d 83 82 58 f8 ff    	lea    -0x7a77e(%ebx),%eax
f01047e6:	50                   	push   %eax
f01047e7:	e8 53 fb ff ff       	call   f010433f <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01047ec:	83 c4 08             	add    $0x8,%esp
f01047ef:	ff 76 04             	push   0x4(%esi)
f01047f2:	8d 83 91 58 f8 ff    	lea    -0x7a76f(%ebx),%eax
f01047f8:	50                   	push   %eax
f01047f9:	e8 41 fb ff ff       	call   f010433f <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01047fe:	83 c4 08             	add    $0x8,%esp
f0104801:	ff 76 08             	push   0x8(%esi)
f0104804:	8d 83 a0 58 f8 ff    	lea    -0x7a760(%ebx),%eax
f010480a:	50                   	push   %eax
f010480b:	e8 2f fb ff ff       	call   f010433f <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104810:	83 c4 08             	add    $0x8,%esp
f0104813:	ff 76 0c             	push   0xc(%esi)
f0104816:	8d 83 af 58 f8 ff    	lea    -0x7a751(%ebx),%eax
f010481c:	50                   	push   %eax
f010481d:	e8 1d fb ff ff       	call   f010433f <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104822:	83 c4 08             	add    $0x8,%esp
f0104825:	ff 76 10             	push   0x10(%esi)
f0104828:	8d 83 be 58 f8 ff    	lea    -0x7a742(%ebx),%eax
f010482e:	50                   	push   %eax
f010482f:	e8 0b fb ff ff       	call   f010433f <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104834:	83 c4 08             	add    $0x8,%esp
f0104837:	ff 76 14             	push   0x14(%esi)
f010483a:	8d 83 cd 58 f8 ff    	lea    -0x7a733(%ebx),%eax
f0104840:	50                   	push   %eax
f0104841:	e8 f9 fa ff ff       	call   f010433f <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104846:	83 c4 08             	add    $0x8,%esp
f0104849:	ff 76 18             	push   0x18(%esi)
f010484c:	8d 83 dc 58 f8 ff    	lea    -0x7a724(%ebx),%eax
f0104852:	50                   	push   %eax
f0104853:	e8 e7 fa ff ff       	call   f010433f <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104858:	83 c4 08             	add    $0x8,%esp
f010485b:	ff 76 1c             	push   0x1c(%esi)
f010485e:	8d 83 eb 58 f8 ff    	lea    -0x7a715(%ebx),%eax
f0104864:	50                   	push   %eax
f0104865:	e8 d5 fa ff ff       	call   f010433f <cprintf>
}
f010486a:	83 c4 10             	add    $0x10,%esp
f010486d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104870:	5b                   	pop    %ebx
f0104871:	5e                   	pop    %esi
f0104872:	5d                   	pop    %ebp
f0104873:	c3                   	ret    

f0104874 <print_trapframe>:
{
f0104874:	55                   	push   %ebp
f0104875:	89 e5                	mov    %esp,%ebp
f0104877:	57                   	push   %edi
f0104878:	56                   	push   %esi
f0104879:	53                   	push   %ebx
f010487a:	83 ec 14             	sub    $0x14,%esp
f010487d:	e8 24 b9 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0104882:	81 c3 ea cf 07 00    	add    $0x7cfea,%ebx
f0104888:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f010488b:	56                   	push   %esi
f010488c:	8d 83 21 5a f8 ff    	lea    -0x7a5df(%ebx),%eax
f0104892:	50                   	push   %eax
f0104893:	e8 a7 fa ff ff       	call   f010433f <cprintf>
	print_regs(&tf->tf_regs);
f0104898:	89 34 24             	mov    %esi,(%esp)
f010489b:	e8 28 ff ff ff       	call   f01047c8 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01048a0:	83 c4 08             	add    $0x8,%esp
f01048a3:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f01048a7:	50                   	push   %eax
f01048a8:	8d 83 3c 59 f8 ff    	lea    -0x7a6c4(%ebx),%eax
f01048ae:	50                   	push   %eax
f01048af:	e8 8b fa ff ff       	call   f010433f <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01048b4:	83 c4 08             	add    $0x8,%esp
f01048b7:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f01048bb:	50                   	push   %eax
f01048bc:	8d 83 4f 59 f8 ff    	lea    -0x7a6b1(%ebx),%eax
f01048c2:	50                   	push   %eax
f01048c3:	e8 77 fa ff ff       	call   f010433f <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01048c8:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f01048cb:	83 c4 10             	add    $0x10,%esp
f01048ce:	83 fa 13             	cmp    $0x13,%edx
f01048d1:	0f 86 e2 00 00 00    	jbe    f01049b9 <print_trapframe+0x145>
		return "System call";
f01048d7:	83 fa 30             	cmp    $0x30,%edx
f01048da:	8d 83 fa 58 f8 ff    	lea    -0x7a706(%ebx),%eax
f01048e0:	8d 8b 09 59 f8 ff    	lea    -0x7a6f7(%ebx),%ecx
f01048e6:	0f 44 c1             	cmove  %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01048e9:	83 ec 04             	sub    $0x4,%esp
f01048ec:	50                   	push   %eax
f01048ed:	52                   	push   %edx
f01048ee:	8d 83 62 59 f8 ff    	lea    -0x7a69e(%ebx),%eax
f01048f4:	50                   	push   %eax
f01048f5:	e8 45 fa ff ff       	call   f010433f <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01048fa:	83 c4 10             	add    $0x10,%esp
f01048fd:	39 b3 34 2b 00 00    	cmp    %esi,0x2b34(%ebx)
f0104903:	0f 84 bc 00 00 00    	je     f01049c5 <print_trapframe+0x151>
	cprintf("  err  0x%08x", tf->tf_err);
f0104909:	83 ec 08             	sub    $0x8,%esp
f010490c:	ff 76 2c             	push   0x2c(%esi)
f010490f:	8d 83 83 59 f8 ff    	lea    -0x7a67d(%ebx),%eax
f0104915:	50                   	push   %eax
f0104916:	e8 24 fa ff ff       	call   f010433f <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f010491b:	83 c4 10             	add    $0x10,%esp
f010491e:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0104922:	0f 85 c2 00 00 00    	jne    f01049ea <print_trapframe+0x176>
			tf->tf_err & 1 ? "protection" : "not-present");
f0104928:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f010492b:	a8 01                	test   $0x1,%al
f010492d:	8d 8b 15 59 f8 ff    	lea    -0x7a6eb(%ebx),%ecx
f0104933:	8d 93 20 59 f8 ff    	lea    -0x7a6e0(%ebx),%edx
f0104939:	0f 44 ca             	cmove  %edx,%ecx
f010493c:	a8 02                	test   $0x2,%al
f010493e:	8d 93 2c 59 f8 ff    	lea    -0x7a6d4(%ebx),%edx
f0104944:	8d bb 32 59 f8 ff    	lea    -0x7a6ce(%ebx),%edi
f010494a:	0f 44 d7             	cmove  %edi,%edx
f010494d:	a8 04                	test   $0x4,%al
f010494f:	8d 83 37 59 f8 ff    	lea    -0x7a6c9(%ebx),%eax
f0104955:	8d bb 4c 5a f8 ff    	lea    -0x7a5b4(%ebx),%edi
f010495b:	0f 44 c7             	cmove  %edi,%eax
f010495e:	51                   	push   %ecx
f010495f:	52                   	push   %edx
f0104960:	50                   	push   %eax
f0104961:	8d 83 91 59 f8 ff    	lea    -0x7a66f(%ebx),%eax
f0104967:	50                   	push   %eax
f0104968:	e8 d2 f9 ff ff       	call   f010433f <cprintf>
f010496d:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104970:	83 ec 08             	sub    $0x8,%esp
f0104973:	ff 76 30             	push   0x30(%esi)
f0104976:	8d 83 a0 59 f8 ff    	lea    -0x7a660(%ebx),%eax
f010497c:	50                   	push   %eax
f010497d:	e8 bd f9 ff ff       	call   f010433f <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104982:	83 c4 08             	add    $0x8,%esp
f0104985:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104989:	50                   	push   %eax
f010498a:	8d 83 af 59 f8 ff    	lea    -0x7a651(%ebx),%eax
f0104990:	50                   	push   %eax
f0104991:	e8 a9 f9 ff ff       	call   f010433f <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104996:	83 c4 08             	add    $0x8,%esp
f0104999:	ff 76 38             	push   0x38(%esi)
f010499c:	8d 83 c2 59 f8 ff    	lea    -0x7a63e(%ebx),%eax
f01049a2:	50                   	push   %eax
f01049a3:	e8 97 f9 ff ff       	call   f010433f <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01049a8:	83 c4 10             	add    $0x10,%esp
f01049ab:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f01049af:	75 50                	jne    f0104a01 <print_trapframe+0x18d>
}
f01049b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049b4:	5b                   	pop    %ebx
f01049b5:	5e                   	pop    %esi
f01049b6:	5f                   	pop    %edi
f01049b7:	5d                   	pop    %ebp
f01049b8:	c3                   	ret    
		return excnames[trapno];
f01049b9:	8b 84 93 14 20 00 00 	mov    0x2014(%ebx,%edx,4),%eax
f01049c0:	e9 24 ff ff ff       	jmp    f01048e9 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01049c5:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01049c9:	0f 85 3a ff ff ff    	jne    f0104909 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01049cf:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01049d2:	83 ec 08             	sub    $0x8,%esp
f01049d5:	50                   	push   %eax
f01049d6:	8d 83 74 59 f8 ff    	lea    -0x7a68c(%ebx),%eax
f01049dc:	50                   	push   %eax
f01049dd:	e8 5d f9 ff ff       	call   f010433f <cprintf>
f01049e2:	83 c4 10             	add    $0x10,%esp
f01049e5:	e9 1f ff ff ff       	jmp    f0104909 <print_trapframe+0x95>
		cprintf("\n");
f01049ea:	83 ec 0c             	sub    $0xc,%esp
f01049ed:	8d 83 aa 43 f8 ff    	lea    -0x7bc56(%ebx),%eax
f01049f3:	50                   	push   %eax
f01049f4:	e8 46 f9 ff ff       	call   f010433f <cprintf>
f01049f9:	83 c4 10             	add    $0x10,%esp
f01049fc:	e9 6f ff ff ff       	jmp    f0104970 <print_trapframe+0xfc>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104a01:	83 ec 08             	sub    $0x8,%esp
f0104a04:	ff 76 3c             	push   0x3c(%esi)
f0104a07:	8d 83 d1 59 f8 ff    	lea    -0x7a62f(%ebx),%eax
f0104a0d:	50                   	push   %eax
f0104a0e:	e8 2c f9 ff ff       	call   f010433f <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104a13:	83 c4 08             	add    $0x8,%esp
f0104a16:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0104a1a:	50                   	push   %eax
f0104a1b:	8d 83 e0 59 f8 ff    	lea    -0x7a620(%ebx),%eax
f0104a21:	50                   	push   %eax
f0104a22:	e8 18 f9 ff ff       	call   f010433f <cprintf>
f0104a27:	83 c4 10             	add    $0x10,%esp
}
f0104a2a:	eb 85                	jmp    f01049b1 <print_trapframe+0x13d>

f0104a2c <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104a2c:	55                   	push   %ebp
f0104a2d:	89 e5                	mov    %esp,%ebp
f0104a2f:	57                   	push   %edi
f0104a30:	56                   	push   %esi
f0104a31:	53                   	push   %ebx
f0104a32:	83 ec 0c             	sub    $0xc,%esp
f0104a35:	e8 6c b7 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0104a3a:	81 c3 32 ce 07 00    	add    $0x7ce32,%ebx
f0104a40:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104a43:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104a44:	9c                   	pushf  
f0104a45:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104a46:	f6 c4 02             	test   $0x2,%ah
f0104a49:	74 1f                	je     f0104a6a <trap+0x3e>
f0104a4b:	8d 83 f3 59 f8 ff    	lea    -0x7a60d(%ebx),%eax
f0104a51:	50                   	push   %eax
f0104a52:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0104a58:	50                   	push   %eax
f0104a59:	68 d2 00 00 00       	push   $0xd2
f0104a5e:	8d 83 0c 5a f8 ff    	lea    -0x7a5f4(%ebx),%eax
f0104a64:	50                   	push   %eax
f0104a65:	e8 86 b6 ff ff       	call   f01000f0 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0104a6a:	83 ec 08             	sub    $0x8,%esp
f0104a6d:	56                   	push   %esi
f0104a6e:	8d 83 18 5a f8 ff    	lea    -0x7a5e8(%ebx),%eax
f0104a74:	50                   	push   %eax
f0104a75:	e8 c5 f8 ff ff       	call   f010433f <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0104a7a:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104a7e:	83 e0 03             	and    $0x3,%eax
f0104a81:	83 c4 10             	add    $0x10,%esp
f0104a84:	66 83 f8 03          	cmp    $0x3,%ax
f0104a88:	75 1d                	jne    f0104aa7 <trap+0x7b>
		// Trapped from user mode.
		assert(curenv);
f0104a8a:	c7 c0 84 3b 18 f0    	mov    $0xf0183b84,%eax
f0104a90:	8b 00                	mov    (%eax),%eax
f0104a92:	85 c0                	test   %eax,%eax
f0104a94:	74 68                	je     f0104afe <trap+0xd2>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104a96:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104a9b:	89 c7                	mov    %eax,%edi
f0104a9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104a9f:	c7 c0 84 3b 18 f0    	mov    $0xf0183b84,%eax
f0104aa5:	8b 30                	mov    (%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104aa7:	89 b3 34 2b 00 00    	mov    %esi,0x2b34(%ebx)
	print_trapframe(tf);
f0104aad:	83 ec 0c             	sub    $0xc,%esp
f0104ab0:	56                   	push   %esi
f0104ab1:	e8 be fd ff ff       	call   f0104874 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104ab6:	83 c4 10             	add    $0x10,%esp
f0104ab9:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104abe:	74 5d                	je     f0104b1d <trap+0xf1>
		env_destroy(curenv);
f0104ac0:	83 ec 0c             	sub    $0xc,%esp
f0104ac3:	c7 c6 84 3b 18 f0    	mov    $0xf0183b84,%esi
f0104ac9:	ff 36                	push   (%esi)
f0104acb:	e8 fb f6 ff ff       	call   f01041cb <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0104ad0:	8b 06                	mov    (%esi),%eax
f0104ad2:	83 c4 10             	add    $0x10,%esp
f0104ad5:	85 c0                	test   %eax,%eax
f0104ad7:	74 06                	je     f0104adf <trap+0xb3>
f0104ad9:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104add:	74 59                	je     f0104b38 <trap+0x10c>
f0104adf:	8d 83 98 5b f8 ff    	lea    -0x7a468(%ebx),%eax
f0104ae5:	50                   	push   %eax
f0104ae6:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0104aec:	50                   	push   %eax
f0104aed:	68 ea 00 00 00       	push   $0xea
f0104af2:	8d 83 0c 5a f8 ff    	lea    -0x7a5f4(%ebx),%eax
f0104af8:	50                   	push   %eax
f0104af9:	e8 f2 b5 ff ff       	call   f01000f0 <_panic>
		assert(curenv);
f0104afe:	8d 83 33 5a f8 ff    	lea    -0x7a5cd(%ebx),%eax
f0104b04:	50                   	push   %eax
f0104b05:	8d 83 e4 4a f8 ff    	lea    -0x7b51c(%ebx),%eax
f0104b0b:	50                   	push   %eax
f0104b0c:	68 d8 00 00 00       	push   $0xd8
f0104b11:	8d 83 0c 5a f8 ff    	lea    -0x7a5f4(%ebx),%eax
f0104b17:	50                   	push   %eax
f0104b18:	e8 d3 b5 ff ff       	call   f01000f0 <_panic>
		panic("unhandled trap in kernel");
f0104b1d:	83 ec 04             	sub    $0x4,%esp
f0104b20:	8d 83 3a 5a f8 ff    	lea    -0x7a5c6(%ebx),%eax
f0104b26:	50                   	push   %eax
f0104b27:	68 c1 00 00 00       	push   $0xc1
f0104b2c:	8d 83 0c 5a f8 ff    	lea    -0x7a5f4(%ebx),%eax
f0104b32:	50                   	push   %eax
f0104b33:	e8 b8 b5 ff ff       	call   f01000f0 <_panic>
	env_run(curenv);
f0104b38:	83 ec 0c             	sub    $0xc,%esp
f0104b3b:	50                   	push   %eax
f0104b3c:	e8 f8 f6 ff ff       	call   f0104239 <env_run>

f0104b41 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104b41:	55                   	push   %ebp
f0104b42:	89 e5                	mov    %esp,%ebp
f0104b44:	57                   	push   %edi
f0104b45:	56                   	push   %esi
f0104b46:	53                   	push   %ebx
f0104b47:	83 ec 0c             	sub    $0xc,%esp
f0104b4a:	e8 57 b6 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0104b4f:	81 c3 1d cd 07 00    	add    $0x7cd1d,%ebx
f0104b55:	8b 7d 08             	mov    0x8(%ebp),%edi
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104b58:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104b5b:	ff 77 30             	push   0x30(%edi)
f0104b5e:	50                   	push   %eax
f0104b5f:	c7 c6 84 3b 18 f0    	mov    $0xf0183b84,%esi
f0104b65:	8b 06                	mov    (%esi),%eax
f0104b67:	ff 70 48             	push   0x48(%eax)
f0104b6a:	8d 83 c4 5b f8 ff    	lea    -0x7a43c(%ebx),%eax
f0104b70:	50                   	push   %eax
f0104b71:	e8 c9 f7 ff ff       	call   f010433f <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104b76:	89 3c 24             	mov    %edi,(%esp)
f0104b79:	e8 f6 fc ff ff       	call   f0104874 <print_trapframe>
	env_destroy(curenv);
f0104b7e:	83 c4 04             	add    $0x4,%esp
f0104b81:	ff 36                	push   (%esi)
f0104b83:	e8 43 f6 ff ff       	call   f01041cb <env_destroy>
}
f0104b88:	83 c4 10             	add    $0x10,%esp
f0104b8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b8e:	5b                   	pop    %ebx
f0104b8f:	5e                   	pop    %esi
f0104b90:	5f                   	pop    %edi
f0104b91:	5d                   	pop    %ebp
f0104b92:	c3                   	ret    
f0104b93:	90                   	nop

f0104b94 <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f0104b94:	6a 00                	push   $0x0
f0104b96:	6a 00                	push   $0x0
f0104b98:	eb 67                	jmp    f0104c01 <_alltraps>

f0104b9a <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0104b9a:	6a 00                	push   $0x0
f0104b9c:	6a 01                	push   $0x1
f0104b9e:	eb 61                	jmp    f0104c01 <_alltraps>

f0104ba0 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0104ba0:	6a 00                	push   $0x0
f0104ba2:	6a 02                	push   $0x2
f0104ba4:	eb 5b                	jmp    f0104c01 <_alltraps>

f0104ba6 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f0104ba6:	6a 00                	push   $0x0
f0104ba8:	6a 03                	push   $0x3
f0104baa:	eb 55                	jmp    f0104c01 <_alltraps>

f0104bac <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0104bac:	6a 00                	push   $0x0
f0104bae:	6a 04                	push   $0x4
f0104bb0:	eb 4f                	jmp    f0104c01 <_alltraps>

f0104bb2 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0104bb2:	6a 00                	push   $0x0
f0104bb4:	6a 05                	push   $0x5
f0104bb6:	eb 49                	jmp    f0104c01 <_alltraps>

f0104bb8 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f0104bb8:	6a 00                	push   $0x0
f0104bba:	6a 06                	push   $0x6
f0104bbc:	eb 43                	jmp    f0104c01 <_alltraps>

f0104bbe <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0104bbe:	6a 00                	push   $0x0
f0104bc0:	6a 07                	push   $0x7
f0104bc2:	eb 3d                	jmp    f0104c01 <_alltraps>

f0104bc4 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f0104bc4:	6a 08                	push   $0x8
f0104bc6:	eb 39                	jmp    f0104c01 <_alltraps>

f0104bc8 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f0104bc8:	6a 0a                	push   $0xa
f0104bca:	eb 35                	jmp    f0104c01 <_alltraps>

f0104bcc <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f0104bcc:	6a 0b                	push   $0xb
f0104bce:	eb 31                	jmp    f0104c01 <_alltraps>

f0104bd0 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f0104bd0:	6a 0c                	push   $0xc
f0104bd2:	eb 2d                	jmp    f0104c01 <_alltraps>

f0104bd4 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0104bd4:	6a 0d                	push   $0xd
f0104bd6:	eb 29                	jmp    f0104c01 <_alltraps>

f0104bd8 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f0104bd8:	6a 0e                	push   $0xe
f0104bda:	eb 25                	jmp    f0104c01 <_alltraps>

f0104bdc <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f0104bdc:	6a 00                	push   $0x0
f0104bde:	6a 10                	push   $0x10
f0104be0:	eb 1f                	jmp    f0104c01 <_alltraps>

f0104be2 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f0104be2:	6a 11                	push   $0x11
f0104be4:	eb 1b                	jmp    f0104c01 <_alltraps>

f0104be6 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0104be6:	6a 00                	push   $0x0
f0104be8:	6a 12                	push   $0x12
f0104bea:	eb 15                	jmp    f0104c01 <_alltraps>

f0104bec <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0104bec:	6a 00                	push   $0x0
f0104bee:	6a 13                	push   $0x13
f0104bf0:	eb 0f                	jmp    f0104c01 <_alltraps>

f0104bf2 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0104bf2:	6a 00                	push   $0x0
f0104bf4:	6a 30                	push   $0x30
f0104bf6:	eb 09                	jmp    f0104c01 <_alltraps>

f0104bf8 <t_default>:
TRAPHANDLER_NOEC(t_default, T_DEFAULT)
f0104bf8:	6a 00                	push   $0x0
f0104bfa:	68 f4 01 00 00       	push   $0x1f4
f0104bff:	eb 00                	jmp    f0104c01 <_alltraps>

f0104c01 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
	pushal
f0104c01:	60                   	pusha  
	movw $(GD_KD), %ax
f0104c02:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0104c06:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104c08:	8e c0                	mov    %eax,%es
	pushl %esp
f0104c0a:	54                   	push   %esp
	call trap
f0104c0b:	e8 1c fe ff ff       	call   f0104a2c <trap>

f0104c10 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104c10:	55                   	push   %ebp
f0104c11:	89 e5                	mov    %esp,%ebp
f0104c13:	53                   	push   %ebx
f0104c14:	83 ec 08             	sub    $0x8,%esp
f0104c17:	e8 8a b5 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0104c1c:	81 c3 50 cc 07 00    	add    $0x7cc50,%ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
f0104c22:	8d 83 e7 5b f8 ff    	lea    -0x7a419(%ebx),%eax
f0104c28:	50                   	push   %eax
f0104c29:	6a 49                	push   $0x49
f0104c2b:	8d 83 ff 5b f8 ff    	lea    -0x7a401(%ebx),%eax
f0104c31:	50                   	push   %eax
f0104c32:	e8 b9 b4 ff ff       	call   f01000f0 <_panic>

f0104c37 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104c37:	55                   	push   %ebp
f0104c38:	89 e5                	mov    %esp,%ebp
f0104c3a:	57                   	push   %edi
f0104c3b:	56                   	push   %esi
f0104c3c:	53                   	push   %ebx
f0104c3d:	83 ec 14             	sub    $0x14,%esp
f0104c40:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104c43:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104c46:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104c49:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c4c:	8b 1a                	mov    (%edx),%ebx
f0104c4e:	8b 01                	mov    (%ecx),%eax
f0104c50:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c53:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c5a:	eb 2f                	jmp    f0104c8b <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104c5c:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104c5f:	39 c3                	cmp    %eax,%ebx
f0104c61:	7f 4e                	jg     f0104cb1 <stab_binsearch+0x7a>
f0104c63:	0f b6 0a             	movzbl (%edx),%ecx
f0104c66:	83 ea 0c             	sub    $0xc,%edx
f0104c69:	39 f1                	cmp    %esi,%ecx
f0104c6b:	75 ef                	jne    f0104c5c <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c6d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c70:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c73:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c77:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104c7a:	73 3a                	jae    f0104cb6 <stab_binsearch+0x7f>
			*region_left = m;
f0104c7c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c7f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104c81:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104c84:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104c8b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104c8e:	7f 53                	jg     f0104ce3 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0104c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c93:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0104c96:	89 d0                	mov    %edx,%eax
f0104c98:	c1 e8 1f             	shr    $0x1f,%eax
f0104c9b:	01 d0                	add    %edx,%eax
f0104c9d:	89 c7                	mov    %eax,%edi
f0104c9f:	d1 ff                	sar    %edi
f0104ca1:	83 e0 fe             	and    $0xfffffffe,%eax
f0104ca4:	01 f8                	add    %edi,%eax
f0104ca6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ca9:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104cad:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104caf:	eb ae                	jmp    f0104c5f <stab_binsearch+0x28>
			l = true_m + 1;
f0104cb1:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104cb4:	eb d5                	jmp    f0104c8b <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104cb6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104cb9:	76 14                	jbe    f0104ccf <stab_binsearch+0x98>
			*region_right = m - 1;
f0104cbb:	83 e8 01             	sub    $0x1,%eax
f0104cbe:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104cc1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104cc4:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104cc6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ccd:	eb bc                	jmp    f0104c8b <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104ccf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cd2:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104cd4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104cd8:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104cda:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104ce1:	eb a8                	jmp    f0104c8b <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104ce3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104ce7:	75 15                	jne    f0104cfe <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0104ce9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cec:	8b 00                	mov    (%eax),%eax
f0104cee:	83 e8 01             	sub    $0x1,%eax
f0104cf1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104cf4:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104cf6:	83 c4 14             	add    $0x14,%esp
f0104cf9:	5b                   	pop    %ebx
f0104cfa:	5e                   	pop    %esi
f0104cfb:	5f                   	pop    %edi
f0104cfc:	5d                   	pop    %ebp
f0104cfd:	c3                   	ret    
		for (l = *region_right;
f0104cfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d01:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104d03:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d06:	8b 0f                	mov    (%edi),%ecx
f0104d08:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d0b:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104d0e:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104d12:	39 c1                	cmp    %eax,%ecx
f0104d14:	7d 0f                	jge    f0104d25 <stab_binsearch+0xee>
f0104d16:	0f b6 1a             	movzbl (%edx),%ebx
f0104d19:	83 ea 0c             	sub    $0xc,%edx
f0104d1c:	39 f3                	cmp    %esi,%ebx
f0104d1e:	74 05                	je     f0104d25 <stab_binsearch+0xee>
		     l--)
f0104d20:	83 e8 01             	sub    $0x1,%eax
f0104d23:	eb ed                	jmp    f0104d12 <stab_binsearch+0xdb>
		*region_left = l;
f0104d25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d28:	89 07                	mov    %eax,(%edi)
}
f0104d2a:	eb ca                	jmp    f0104cf6 <stab_binsearch+0xbf>

f0104d2c <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104d2c:	55                   	push   %ebp
f0104d2d:	89 e5                	mov    %esp,%ebp
f0104d2f:	57                   	push   %edi
f0104d30:	56                   	push   %esi
f0104d31:	53                   	push   %ebx
f0104d32:	83 ec 3c             	sub    $0x3c,%esp
f0104d35:	e8 6c b4 ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0104d3a:	81 c3 32 cb 07 00    	add    $0x7cb32,%ebx
f0104d40:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d43:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104d46:	8d 83 0e 5c f8 ff    	lea    -0x7a3f2(%ebx),%eax
f0104d4c:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0104d4e:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0104d55:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0104d58:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0104d5f:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f0104d62:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d69:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104d6f:	0f 87 ea 00 00 00    	ja     f0104e5f <debuginfo_eip+0x133>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104d75:	a1 00 00 20 00       	mov    0x200000,%eax
f0104d7a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104d7d:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104d82:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104d88:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104d8b:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104d91:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104d94:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104d97:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104d9a:	0f 83 56 01 00 00    	jae    f0104ef6 <debuginfo_eip+0x1ca>
f0104da0:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104da4:	0f 85 53 01 00 00    	jne    f0104efd <debuginfo_eip+0x1d1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104daa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104db1:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0104db4:	c1 f8 02             	sar    $0x2,%eax
f0104db7:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104dbd:	83 e8 01             	sub    $0x1,%eax
f0104dc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104dc3:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104dc6:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104dc9:	56                   	push   %esi
f0104dca:	6a 64                	push   $0x64
f0104dcc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104dcf:	e8 63 fe ff ff       	call   f0104c37 <stab_binsearch>
	if (lfile == 0)
f0104dd4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104dd7:	83 c4 08             	add    $0x8,%esp
f0104dda:	85 c9                	test   %ecx,%ecx
f0104ddc:	0f 84 22 01 00 00    	je     f0104f04 <debuginfo_eip+0x1d8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104de2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0104de5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
	rfun = rfile;
f0104de8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104deb:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104dee:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104df1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104df4:	56                   	push   %esi
f0104df5:	6a 24                	push   $0x24
f0104df7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104dfa:	e8 38 fe ff ff       	call   f0104c37 <stab_binsearch>

	if (lfun <= rfun) {
f0104dff:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104e02:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0104e05:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104e08:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0104e0b:	83 c4 08             	add    $0x8,%esp
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
		lline = lfile;
f0104e0e:	8b 75 c8             	mov    -0x38(%ebp),%esi
	if (lfun <= rfun) {
f0104e11:	39 c2                	cmp    %eax,%edx
f0104e13:	7f 25                	jg     f0104e3a <debuginfo_eip+0x10e>
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104e15:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0104e18:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0104e1b:	8d 14 86             	lea    (%esi,%eax,4),%edx
f0104e1e:	8b 02                	mov    (%edx),%eax
f0104e20:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104e23:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104e26:	29 f1                	sub    %esi,%ecx
f0104e28:	39 c8                	cmp    %ecx,%eax
f0104e2a:	73 05                	jae    f0104e31 <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104e2c:	01 f0                	add    %esi,%eax
f0104e2e:	89 47 08             	mov    %eax,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104e31:	8b 42 08             	mov    0x8(%edx),%eax
f0104e34:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfun;
f0104e37:	8b 75 c4             	mov    -0x3c(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104e3a:	83 ec 08             	sub    $0x8,%esp
f0104e3d:	6a 3a                	push   $0x3a
f0104e3f:	ff 77 08             	push   0x8(%edi)
f0104e42:	e8 22 09 00 00       	call   f0105769 <strfind>
f0104e47:	2b 47 08             	sub    0x8(%edi),%eax
f0104e4a:	89 47 0c             	mov    %eax,0xc(%edi)
f0104e4d:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104e50:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104e53:	8d 44 83 04          	lea    0x4(%ebx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e57:	83 c4 10             	add    $0x10,%esp
f0104e5a:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0104e5d:	eb 2c                	jmp    f0104e8b <debuginfo_eip+0x15f>
		stabstr_end = __STABSTR_END__;
f0104e5f:	c7 c0 63 44 11 f0    	mov    $0xf0114463,%eax
f0104e65:	89 45 d0             	mov    %eax,-0x30(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104e68:	c7 c0 d5 07 11 f0    	mov    $0xf01107d5,%eax
f0104e6e:	89 45 cc             	mov    %eax,-0x34(%ebp)
		stab_end = __STAB_END__;
f0104e71:	c7 c0 d4 07 11 f0    	mov    $0xf01107d4,%eax
		stabs = __STAB_BEGIN__;
f0104e77:	c7 c1 78 76 10 f0    	mov    $0xf0107678,%ecx
f0104e7d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104e80:	e9 0f ff ff ff       	jmp    f0104d94 <debuginfo_eip+0x68>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104e85:	83 ee 01             	sub    $0x1,%esi
f0104e88:	83 e8 0c             	sub    $0xc,%eax
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104e8b:	39 f3                	cmp    %esi,%ebx
f0104e8d:	7f 2e                	jg     f0104ebd <debuginfo_eip+0x191>
	       && stabs[lline].n_type != N_SOL
f0104e8f:	0f b6 10             	movzbl (%eax),%edx
f0104e92:	80 fa 84             	cmp    $0x84,%dl
f0104e95:	74 0b                	je     f0104ea2 <debuginfo_eip+0x176>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104e97:	80 fa 64             	cmp    $0x64,%dl
f0104e9a:	75 e9                	jne    f0104e85 <debuginfo_eip+0x159>
f0104e9c:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0104ea0:	74 e3                	je     f0104e85 <debuginfo_eip+0x159>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104ea2:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104ea5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104ea8:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0104eab:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104eae:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0104eb1:	29 d8                	sub    %ebx,%eax
f0104eb3:	39 c2                	cmp    %eax,%edx
f0104eb5:	73 06                	jae    f0104ebd <debuginfo_eip+0x191>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104eb7:	89 d8                	mov    %ebx,%eax
f0104eb9:	01 d0                	add    %edx,%eax
f0104ebb:	89 07                	mov    %eax,(%edi)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ebd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104ec2:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0104ec5:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104ec8:	39 cb                	cmp    %ecx,%ebx
f0104eca:	7d 44                	jge    f0104f10 <debuginfo_eip+0x1e4>
		for (lline = lfun + 1;
f0104ecc:	8d 53 01             	lea    0x1(%ebx),%edx
f0104ecf:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104ed2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104ed5:	8d 44 83 10          	lea    0x10(%ebx,%eax,4),%eax
f0104ed9:	eb 07                	jmp    f0104ee2 <debuginfo_eip+0x1b6>
			info->eip_fn_narg++;
f0104edb:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0104edf:	83 c2 01             	add    $0x1,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104ee2:	39 d1                	cmp    %edx,%ecx
f0104ee4:	74 25                	je     f0104f0b <debuginfo_eip+0x1df>
f0104ee6:	83 c0 0c             	add    $0xc,%eax
f0104ee9:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0104eed:	74 ec                	je     f0104edb <debuginfo_eip+0x1af>
	return 0;
f0104eef:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ef4:	eb 1a                	jmp    f0104f10 <debuginfo_eip+0x1e4>
		return -1;
f0104ef6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104efb:	eb 13                	jmp    f0104f10 <debuginfo_eip+0x1e4>
f0104efd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f02:	eb 0c                	jmp    f0104f10 <debuginfo_eip+0x1e4>
		return -1;
f0104f04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104f09:	eb 05                	jmp    f0104f10 <debuginfo_eip+0x1e4>
	return 0;
f0104f0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f10:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f13:	5b                   	pop    %ebx
f0104f14:	5e                   	pop    %esi
f0104f15:	5f                   	pop    %edi
f0104f16:	5d                   	pop    %ebp
f0104f17:	c3                   	ret    

f0104f18 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104f18:	55                   	push   %ebp
f0104f19:	89 e5                	mov    %esp,%ebp
f0104f1b:	57                   	push   %edi
f0104f1c:	56                   	push   %esi
f0104f1d:	53                   	push   %ebx
f0104f1e:	83 ec 2c             	sub    $0x2c,%esp
f0104f21:	e8 e5 ea ff ff       	call   f0103a0b <__x86.get_pc_thunk.cx>
f0104f26:	81 c1 46 c9 07 00    	add    $0x7c946,%ecx
f0104f2c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104f2f:	89 c7                	mov    %eax,%edi
f0104f31:	89 d6                	mov    %edx,%esi
f0104f33:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f36:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f39:	89 d1                	mov    %edx,%ecx
f0104f3b:	89 c2                	mov    %eax,%edx
f0104f3d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104f40:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104f43:	8b 45 10             	mov    0x10(%ebp),%eax
f0104f46:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104f49:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104f4c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104f53:	39 c2                	cmp    %eax,%edx
f0104f55:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0104f58:	72 41                	jb     f0104f9b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104f5a:	83 ec 0c             	sub    $0xc,%esp
f0104f5d:	ff 75 18             	push   0x18(%ebp)
f0104f60:	83 eb 01             	sub    $0x1,%ebx
f0104f63:	53                   	push   %ebx
f0104f64:	50                   	push   %eax
f0104f65:	83 ec 08             	sub    $0x8,%esp
f0104f68:	ff 75 e4             	push   -0x1c(%ebp)
f0104f6b:	ff 75 e0             	push   -0x20(%ebp)
f0104f6e:	ff 75 d4             	push   -0x2c(%ebp)
f0104f71:	ff 75 d0             	push   -0x30(%ebp)
f0104f74:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104f77:	e8 04 0a 00 00       	call   f0105980 <__udivdi3>
f0104f7c:	83 c4 18             	add    $0x18,%esp
f0104f7f:	52                   	push   %edx
f0104f80:	50                   	push   %eax
f0104f81:	89 f2                	mov    %esi,%edx
f0104f83:	89 f8                	mov    %edi,%eax
f0104f85:	e8 8e ff ff ff       	call   f0104f18 <printnum>
f0104f8a:	83 c4 20             	add    $0x20,%esp
f0104f8d:	eb 13                	jmp    f0104fa2 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104f8f:	83 ec 08             	sub    $0x8,%esp
f0104f92:	56                   	push   %esi
f0104f93:	ff 75 18             	push   0x18(%ebp)
f0104f96:	ff d7                	call   *%edi
f0104f98:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0104f9b:	83 eb 01             	sub    $0x1,%ebx
f0104f9e:	85 db                	test   %ebx,%ebx
f0104fa0:	7f ed                	jg     f0104f8f <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104fa2:	83 ec 08             	sub    $0x8,%esp
f0104fa5:	56                   	push   %esi
f0104fa6:	83 ec 04             	sub    $0x4,%esp
f0104fa9:	ff 75 e4             	push   -0x1c(%ebp)
f0104fac:	ff 75 e0             	push   -0x20(%ebp)
f0104faf:	ff 75 d4             	push   -0x2c(%ebp)
f0104fb2:	ff 75 d0             	push   -0x30(%ebp)
f0104fb5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104fb8:	e8 e3 0a 00 00       	call   f0105aa0 <__umoddi3>
f0104fbd:	83 c4 14             	add    $0x14,%esp
f0104fc0:	0f be 84 03 18 5c f8 	movsbl -0x7a3e8(%ebx,%eax,1),%eax
f0104fc7:	ff 
f0104fc8:	50                   	push   %eax
f0104fc9:	ff d7                	call   *%edi
}
f0104fcb:	83 c4 10             	add    $0x10,%esp
f0104fce:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fd1:	5b                   	pop    %ebx
f0104fd2:	5e                   	pop    %esi
f0104fd3:	5f                   	pop    %edi
f0104fd4:	5d                   	pop    %ebp
f0104fd5:	c3                   	ret    

f0104fd6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104fd6:	55                   	push   %ebp
f0104fd7:	89 e5                	mov    %esp,%ebp
f0104fd9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104fdc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104fe0:	8b 10                	mov    (%eax),%edx
f0104fe2:	3b 50 04             	cmp    0x4(%eax),%edx
f0104fe5:	73 0a                	jae    f0104ff1 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104fe7:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104fea:	89 08                	mov    %ecx,(%eax)
f0104fec:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fef:	88 02                	mov    %al,(%edx)
}
f0104ff1:	5d                   	pop    %ebp
f0104ff2:	c3                   	ret    

f0104ff3 <printfmt>:
{
f0104ff3:	55                   	push   %ebp
f0104ff4:	89 e5                	mov    %esp,%ebp
f0104ff6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104ff9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104ffc:	50                   	push   %eax
f0104ffd:	ff 75 10             	push   0x10(%ebp)
f0105000:	ff 75 0c             	push   0xc(%ebp)
f0105003:	ff 75 08             	push   0x8(%ebp)
f0105006:	e8 05 00 00 00       	call   f0105010 <vprintfmt>
}
f010500b:	83 c4 10             	add    $0x10,%esp
f010500e:	c9                   	leave  
f010500f:	c3                   	ret    

f0105010 <vprintfmt>:
{
f0105010:	55                   	push   %ebp
f0105011:	89 e5                	mov    %esp,%ebp
f0105013:	57                   	push   %edi
f0105014:	56                   	push   %esi
f0105015:	53                   	push   %ebx
f0105016:	83 ec 3c             	sub    $0x3c,%esp
f0105019:	e8 1a b7 ff ff       	call   f0100738 <__x86.get_pc_thunk.ax>
f010501e:	05 4e c8 07 00       	add    $0x7c84e,%eax
f0105023:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105026:	8b 75 08             	mov    0x8(%ebp),%esi
f0105029:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010502c:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010502f:	8d 80 64 20 00 00    	lea    0x2064(%eax),%eax
f0105035:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0105038:	eb 0a                	jmp    f0105044 <vprintfmt+0x34>
			putch(ch, putdat);
f010503a:	83 ec 08             	sub    $0x8,%esp
f010503d:	57                   	push   %edi
f010503e:	50                   	push   %eax
f010503f:	ff d6                	call   *%esi
f0105041:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105044:	83 c3 01             	add    $0x1,%ebx
f0105047:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010504b:	83 f8 25             	cmp    $0x25,%eax
f010504e:	74 0c                	je     f010505c <vprintfmt+0x4c>
			if (ch == '\0')
f0105050:	85 c0                	test   %eax,%eax
f0105052:	75 e6                	jne    f010503a <vprintfmt+0x2a>
}
f0105054:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105057:	5b                   	pop    %ebx
f0105058:	5e                   	pop    %esi
f0105059:	5f                   	pop    %edi
f010505a:	5d                   	pop    %ebp
f010505b:	c3                   	ret    
		padc = ' ';
f010505c:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0105060:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0105067:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010506e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f0105075:	b9 00 00 00 00       	mov    $0x0,%ecx
f010507a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010507d:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105080:	8d 43 01             	lea    0x1(%ebx),%eax
f0105083:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105086:	0f b6 13             	movzbl (%ebx),%edx
f0105089:	8d 42 dd             	lea    -0x23(%edx),%eax
f010508c:	3c 55                	cmp    $0x55,%al
f010508e:	0f 87 c5 03 00 00    	ja     f0105459 <.L20>
f0105094:	0f b6 c0             	movzbl %al,%eax
f0105097:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010509a:	89 ce                	mov    %ecx,%esi
f010509c:	03 b4 81 a4 5c f8 ff 	add    -0x7a35c(%ecx,%eax,4),%esi
f01050a3:	ff e6                	jmp    *%esi

f01050a5 <.L66>:
f01050a5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f01050a8:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f01050ac:	eb d2                	jmp    f0105080 <vprintfmt+0x70>

f01050ae <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f01050ae:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01050b1:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f01050b5:	eb c9                	jmp    f0105080 <vprintfmt+0x70>

f01050b7 <.L31>:
f01050b7:	0f b6 d2             	movzbl %dl,%edx
f01050ba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f01050bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01050c2:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f01050c5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01050c8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01050cc:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01050cf:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01050d2:	83 f9 09             	cmp    $0x9,%ecx
f01050d5:	77 58                	ja     f010512f <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01050d7:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01050da:	eb e9                	jmp    f01050c5 <.L31+0xe>

f01050dc <.L34>:
			precision = va_arg(ap, int);
f01050dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01050df:	8b 00                	mov    (%eax),%eax
f01050e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01050e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01050e7:	8d 40 04             	lea    0x4(%eax),%eax
f01050ea:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01050ed:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01050f0:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01050f4:	79 8a                	jns    f0105080 <vprintfmt+0x70>
				width = precision, precision = -1;
f01050f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01050f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01050fc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0105103:	e9 78 ff ff ff       	jmp    f0105080 <vprintfmt+0x70>

f0105108 <.L33>:
f0105108:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010510b:	85 d2                	test   %edx,%edx
f010510d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105112:	0f 49 c2             	cmovns %edx,%eax
f0105115:	89 45 d0             	mov    %eax,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105118:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010511b:	e9 60 ff ff ff       	jmp    f0105080 <vprintfmt+0x70>

f0105120 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0105120:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0105123:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f010512a:	e9 51 ff ff ff       	jmp    f0105080 <vprintfmt+0x70>
f010512f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105132:	89 75 08             	mov    %esi,0x8(%ebp)
f0105135:	eb b9                	jmp    f01050f0 <.L34+0x14>

f0105137 <.L27>:
			lflag++;
f0105137:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010513b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010513e:	e9 3d ff ff ff       	jmp    f0105080 <vprintfmt+0x70>

f0105143 <.L30>:
			putch(va_arg(ap, int), putdat);
f0105143:	8b 75 08             	mov    0x8(%ebp),%esi
f0105146:	8b 45 14             	mov    0x14(%ebp),%eax
f0105149:	8d 58 04             	lea    0x4(%eax),%ebx
f010514c:	83 ec 08             	sub    $0x8,%esp
f010514f:	57                   	push   %edi
f0105150:	ff 30                	push   (%eax)
f0105152:	ff d6                	call   *%esi
			break;
f0105154:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0105157:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f010515a:	e9 90 02 00 00       	jmp    f01053ef <.L25+0x45>

f010515f <.L28>:
			err = va_arg(ap, int);
f010515f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105162:	8b 45 14             	mov    0x14(%ebp),%eax
f0105165:	8d 58 04             	lea    0x4(%eax),%ebx
f0105168:	8b 10                	mov    (%eax),%edx
f010516a:	89 d0                	mov    %edx,%eax
f010516c:	f7 d8                	neg    %eax
f010516e:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105171:	83 f8 06             	cmp    $0x6,%eax
f0105174:	7f 27                	jg     f010519d <.L28+0x3e>
f0105176:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105179:	8b 14 82             	mov    (%edx,%eax,4),%edx
f010517c:	85 d2                	test   %edx,%edx
f010517e:	74 1d                	je     f010519d <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f0105180:	52                   	push   %edx
f0105181:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105184:	8d 80 f6 4a f8 ff    	lea    -0x7b50a(%eax),%eax
f010518a:	50                   	push   %eax
f010518b:	57                   	push   %edi
f010518c:	56                   	push   %esi
f010518d:	e8 61 fe ff ff       	call   f0104ff3 <printfmt>
f0105192:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105195:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0105198:	e9 52 02 00 00       	jmp    f01053ef <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f010519d:	50                   	push   %eax
f010519e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051a1:	8d 80 30 5c f8 ff    	lea    -0x7a3d0(%eax),%eax
f01051a7:	50                   	push   %eax
f01051a8:	57                   	push   %edi
f01051a9:	56                   	push   %esi
f01051aa:	e8 44 fe ff ff       	call   f0104ff3 <printfmt>
f01051af:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01051b2:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01051b5:	e9 35 02 00 00       	jmp    f01053ef <.L25+0x45>

f01051ba <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f01051ba:	8b 75 08             	mov    0x8(%ebp),%esi
f01051bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01051c0:	83 c0 04             	add    $0x4,%eax
f01051c3:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01051c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01051c9:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01051cb:	85 d2                	test   %edx,%edx
f01051cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051d0:	8d 80 29 5c f8 ff    	lea    -0x7a3d7(%eax),%eax
f01051d6:	0f 45 c2             	cmovne %edx,%eax
f01051d9:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01051dc:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01051e0:	7e 06                	jle    f01051e8 <.L24+0x2e>
f01051e2:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01051e6:	75 0d                	jne    f01051f5 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01051e8:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01051eb:	89 c3                	mov    %eax,%ebx
f01051ed:	03 45 d0             	add    -0x30(%ebp),%eax
f01051f0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01051f3:	eb 58                	jmp    f010524d <.L24+0x93>
f01051f5:	83 ec 08             	sub    $0x8,%esp
f01051f8:	ff 75 d8             	push   -0x28(%ebp)
f01051fb:	ff 75 c8             	push   -0x38(%ebp)
f01051fe:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105201:	e8 0c 04 00 00       	call   f0105612 <strnlen>
f0105206:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105209:	29 c2                	sub    %eax,%edx
f010520b:	89 55 bc             	mov    %edx,-0x44(%ebp)
f010520e:	83 c4 10             	add    $0x10,%esp
f0105211:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0105213:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0105217:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010521a:	eb 0f                	jmp    f010522b <.L24+0x71>
					putch(padc, putdat);
f010521c:	83 ec 08             	sub    $0x8,%esp
f010521f:	57                   	push   %edi
f0105220:	ff 75 d0             	push   -0x30(%ebp)
f0105223:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105225:	83 eb 01             	sub    $0x1,%ebx
f0105228:	83 c4 10             	add    $0x10,%esp
f010522b:	85 db                	test   %ebx,%ebx
f010522d:	7f ed                	jg     f010521c <.L24+0x62>
f010522f:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105232:	85 d2                	test   %edx,%edx
f0105234:	b8 00 00 00 00       	mov    $0x0,%eax
f0105239:	0f 49 c2             	cmovns %edx,%eax
f010523c:	29 c2                	sub    %eax,%edx
f010523e:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105241:	eb a5                	jmp    f01051e8 <.L24+0x2e>
					putch(ch, putdat);
f0105243:	83 ec 08             	sub    $0x8,%esp
f0105246:	57                   	push   %edi
f0105247:	52                   	push   %edx
f0105248:	ff d6                	call   *%esi
f010524a:	83 c4 10             	add    $0x10,%esp
f010524d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0105250:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105252:	83 c3 01             	add    $0x1,%ebx
f0105255:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0105259:	0f be d0             	movsbl %al,%edx
f010525c:	85 d2                	test   %edx,%edx
f010525e:	74 4b                	je     f01052ab <.L24+0xf1>
f0105260:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105264:	78 06                	js     f010526c <.L24+0xb2>
f0105266:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f010526a:	78 1e                	js     f010528a <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f010526c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105270:	74 d1                	je     f0105243 <.L24+0x89>
f0105272:	0f be c0             	movsbl %al,%eax
f0105275:	83 e8 20             	sub    $0x20,%eax
f0105278:	83 f8 5e             	cmp    $0x5e,%eax
f010527b:	76 c6                	jbe    f0105243 <.L24+0x89>
					putch('?', putdat);
f010527d:	83 ec 08             	sub    $0x8,%esp
f0105280:	57                   	push   %edi
f0105281:	6a 3f                	push   $0x3f
f0105283:	ff d6                	call   *%esi
f0105285:	83 c4 10             	add    $0x10,%esp
f0105288:	eb c3                	jmp    f010524d <.L24+0x93>
f010528a:	89 cb                	mov    %ecx,%ebx
f010528c:	eb 0e                	jmp    f010529c <.L24+0xe2>
				putch(' ', putdat);
f010528e:	83 ec 08             	sub    $0x8,%esp
f0105291:	57                   	push   %edi
f0105292:	6a 20                	push   $0x20
f0105294:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105296:	83 eb 01             	sub    $0x1,%ebx
f0105299:	83 c4 10             	add    $0x10,%esp
f010529c:	85 db                	test   %ebx,%ebx
f010529e:	7f ee                	jg     f010528e <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01052a0:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01052a3:	89 45 14             	mov    %eax,0x14(%ebp)
f01052a6:	e9 44 01 00 00       	jmp    f01053ef <.L25+0x45>
f01052ab:	89 cb                	mov    %ecx,%ebx
f01052ad:	eb ed                	jmp    f010529c <.L24+0xe2>

f01052af <.L29>:
	if (lflag >= 2)
f01052af:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01052b2:	8b 75 08             	mov    0x8(%ebp),%esi
f01052b5:	83 f9 01             	cmp    $0x1,%ecx
f01052b8:	7f 1b                	jg     f01052d5 <.L29+0x26>
	else if (lflag)
f01052ba:	85 c9                	test   %ecx,%ecx
f01052bc:	74 63                	je     f0105321 <.L29+0x72>
		return va_arg(*ap, long);
f01052be:	8b 45 14             	mov    0x14(%ebp),%eax
f01052c1:	8b 00                	mov    (%eax),%eax
f01052c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052c6:	99                   	cltd   
f01052c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01052ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01052cd:	8d 40 04             	lea    0x4(%eax),%eax
f01052d0:	89 45 14             	mov    %eax,0x14(%ebp)
f01052d3:	eb 17                	jmp    f01052ec <.L29+0x3d>
		return va_arg(*ap, long long);
f01052d5:	8b 45 14             	mov    0x14(%ebp),%eax
f01052d8:	8b 50 04             	mov    0x4(%eax),%edx
f01052db:	8b 00                	mov    (%eax),%eax
f01052dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01052e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01052e6:	8d 40 08             	lea    0x8(%eax),%eax
f01052e9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01052ec:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01052ef:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f01052f2:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f01052f7:	85 db                	test   %ebx,%ebx
f01052f9:	0f 89 d6 00 00 00    	jns    f01053d5 <.L25+0x2b>
				putch('-', putdat);
f01052ff:	83 ec 08             	sub    $0x8,%esp
f0105302:	57                   	push   %edi
f0105303:	6a 2d                	push   $0x2d
f0105305:	ff d6                	call   *%esi
				num = -(long long) num;
f0105307:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010530a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010530d:	f7 d9                	neg    %ecx
f010530f:	83 d3 00             	adc    $0x0,%ebx
f0105312:	f7 db                	neg    %ebx
f0105314:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105317:	ba 0a 00 00 00       	mov    $0xa,%edx
f010531c:	e9 b4 00 00 00       	jmp    f01053d5 <.L25+0x2b>
		return va_arg(*ap, int);
f0105321:	8b 45 14             	mov    0x14(%ebp),%eax
f0105324:	8b 00                	mov    (%eax),%eax
f0105326:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105329:	99                   	cltd   
f010532a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010532d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105330:	8d 40 04             	lea    0x4(%eax),%eax
f0105333:	89 45 14             	mov    %eax,0x14(%ebp)
f0105336:	eb b4                	jmp    f01052ec <.L29+0x3d>

f0105338 <.L23>:
	if (lflag >= 2)
f0105338:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010533b:	8b 75 08             	mov    0x8(%ebp),%esi
f010533e:	83 f9 01             	cmp    $0x1,%ecx
f0105341:	7f 1b                	jg     f010535e <.L23+0x26>
	else if (lflag)
f0105343:	85 c9                	test   %ecx,%ecx
f0105345:	74 2c                	je     f0105373 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f0105347:	8b 45 14             	mov    0x14(%ebp),%eax
f010534a:	8b 08                	mov    (%eax),%ecx
f010534c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105351:	8d 40 04             	lea    0x4(%eax),%eax
f0105354:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105357:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f010535c:	eb 77                	jmp    f01053d5 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010535e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105361:	8b 08                	mov    (%eax),%ecx
f0105363:	8b 58 04             	mov    0x4(%eax),%ebx
f0105366:	8d 40 08             	lea    0x8(%eax),%eax
f0105369:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010536c:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f0105371:	eb 62                	jmp    f01053d5 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0105373:	8b 45 14             	mov    0x14(%ebp),%eax
f0105376:	8b 08                	mov    (%eax),%ecx
f0105378:	bb 00 00 00 00       	mov    $0x0,%ebx
f010537d:	8d 40 04             	lea    0x4(%eax),%eax
f0105380:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105383:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f0105388:	eb 4b                	jmp    f01053d5 <.L25+0x2b>

f010538a <.L26>:
			putch('X', putdat);
f010538a:	8b 75 08             	mov    0x8(%ebp),%esi
f010538d:	83 ec 08             	sub    $0x8,%esp
f0105390:	57                   	push   %edi
f0105391:	6a 58                	push   $0x58
f0105393:	ff d6                	call   *%esi
			putch('X', putdat);
f0105395:	83 c4 08             	add    $0x8,%esp
f0105398:	57                   	push   %edi
f0105399:	6a 58                	push   $0x58
f010539b:	ff d6                	call   *%esi
			putch('X', putdat);
f010539d:	83 c4 08             	add    $0x8,%esp
f01053a0:	57                   	push   %edi
f01053a1:	6a 58                	push   $0x58
f01053a3:	ff d6                	call   *%esi
			break;
f01053a5:	83 c4 10             	add    $0x10,%esp
f01053a8:	eb 45                	jmp    f01053ef <.L25+0x45>

f01053aa <.L25>:
			putch('0', putdat);
f01053aa:	8b 75 08             	mov    0x8(%ebp),%esi
f01053ad:	83 ec 08             	sub    $0x8,%esp
f01053b0:	57                   	push   %edi
f01053b1:	6a 30                	push   $0x30
f01053b3:	ff d6                	call   *%esi
			putch('x', putdat);
f01053b5:	83 c4 08             	add    $0x8,%esp
f01053b8:	57                   	push   %edi
f01053b9:	6a 78                	push   $0x78
f01053bb:	ff d6                	call   *%esi
			num = (unsigned long long)
f01053bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01053c0:	8b 08                	mov    (%eax),%ecx
f01053c2:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f01053c7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01053ca:	8d 40 04             	lea    0x4(%eax),%eax
f01053cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01053d0:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f01053d5:	83 ec 0c             	sub    $0xc,%esp
f01053d8:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01053dc:	50                   	push   %eax
f01053dd:	ff 75 d0             	push   -0x30(%ebp)
f01053e0:	52                   	push   %edx
f01053e1:	53                   	push   %ebx
f01053e2:	51                   	push   %ecx
f01053e3:	89 fa                	mov    %edi,%edx
f01053e5:	89 f0                	mov    %esi,%eax
f01053e7:	e8 2c fb ff ff       	call   f0104f18 <printnum>
			break;
f01053ec:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01053ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01053f2:	e9 4d fc ff ff       	jmp    f0105044 <vprintfmt+0x34>

f01053f7 <.L21>:
	if (lflag >= 2)
f01053f7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01053fa:	8b 75 08             	mov    0x8(%ebp),%esi
f01053fd:	83 f9 01             	cmp    $0x1,%ecx
f0105400:	7f 1b                	jg     f010541d <.L21+0x26>
	else if (lflag)
f0105402:	85 c9                	test   %ecx,%ecx
f0105404:	74 2c                	je     f0105432 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0105406:	8b 45 14             	mov    0x14(%ebp),%eax
f0105409:	8b 08                	mov    (%eax),%ecx
f010540b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105410:	8d 40 04             	lea    0x4(%eax),%eax
f0105413:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105416:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f010541b:	eb b8                	jmp    f01053d5 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010541d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105420:	8b 08                	mov    (%eax),%ecx
f0105422:	8b 58 04             	mov    0x4(%eax),%ebx
f0105425:	8d 40 08             	lea    0x8(%eax),%eax
f0105428:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010542b:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0105430:	eb a3                	jmp    f01053d5 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0105432:	8b 45 14             	mov    0x14(%ebp),%eax
f0105435:	8b 08                	mov    (%eax),%ecx
f0105437:	bb 00 00 00 00       	mov    $0x0,%ebx
f010543c:	8d 40 04             	lea    0x4(%eax),%eax
f010543f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105442:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0105447:	eb 8c                	jmp    f01053d5 <.L25+0x2b>

f0105449 <.L35>:
			putch(ch, putdat);
f0105449:	8b 75 08             	mov    0x8(%ebp),%esi
f010544c:	83 ec 08             	sub    $0x8,%esp
f010544f:	57                   	push   %edi
f0105450:	6a 25                	push   $0x25
f0105452:	ff d6                	call   *%esi
			break;
f0105454:	83 c4 10             	add    $0x10,%esp
f0105457:	eb 96                	jmp    f01053ef <.L25+0x45>

f0105459 <.L20>:
			putch('%', putdat);
f0105459:	8b 75 08             	mov    0x8(%ebp),%esi
f010545c:	83 ec 08             	sub    $0x8,%esp
f010545f:	57                   	push   %edi
f0105460:	6a 25                	push   $0x25
f0105462:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105464:	83 c4 10             	add    $0x10,%esp
f0105467:	89 d8                	mov    %ebx,%eax
f0105469:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010546d:	74 05                	je     f0105474 <.L20+0x1b>
f010546f:	83 e8 01             	sub    $0x1,%eax
f0105472:	eb f5                	jmp    f0105469 <.L20+0x10>
f0105474:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105477:	e9 73 ff ff ff       	jmp    f01053ef <.L25+0x45>

f010547c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010547c:	55                   	push   %ebp
f010547d:	89 e5                	mov    %esp,%ebp
f010547f:	53                   	push   %ebx
f0105480:	83 ec 14             	sub    $0x14,%esp
f0105483:	e8 1e ad ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0105488:	81 c3 e4 c3 07 00    	add    $0x7c3e4,%ebx
f010548e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105491:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105494:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105497:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010549b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010549e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01054a5:	85 c0                	test   %eax,%eax
f01054a7:	74 2b                	je     f01054d4 <vsnprintf+0x58>
f01054a9:	85 d2                	test   %edx,%edx
f01054ab:	7e 27                	jle    f01054d4 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01054ad:	ff 75 14             	push   0x14(%ebp)
f01054b0:	ff 75 10             	push   0x10(%ebp)
f01054b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01054b6:	50                   	push   %eax
f01054b7:	8d 83 6a 37 f8 ff    	lea    -0x7c896(%ebx),%eax
f01054bd:	50                   	push   %eax
f01054be:	e8 4d fb ff ff       	call   f0105010 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01054c3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01054c6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01054c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01054cc:	83 c4 10             	add    $0x10,%esp
}
f01054cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01054d2:	c9                   	leave  
f01054d3:	c3                   	ret    
		return -E_INVAL;
f01054d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01054d9:	eb f4                	jmp    f01054cf <vsnprintf+0x53>

f01054db <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01054db:	55                   	push   %ebp
f01054dc:	89 e5                	mov    %esp,%ebp
f01054de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01054e1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01054e4:	50                   	push   %eax
f01054e5:	ff 75 10             	push   0x10(%ebp)
f01054e8:	ff 75 0c             	push   0xc(%ebp)
f01054eb:	ff 75 08             	push   0x8(%ebp)
f01054ee:	e8 89 ff ff ff       	call   f010547c <vsnprintf>
	va_end(ap);

	return rc;
}
f01054f3:	c9                   	leave  
f01054f4:	c3                   	ret    

f01054f5 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01054f5:	55                   	push   %ebp
f01054f6:	89 e5                	mov    %esp,%ebp
f01054f8:	57                   	push   %edi
f01054f9:	56                   	push   %esi
f01054fa:	53                   	push   %ebx
f01054fb:	83 ec 1c             	sub    $0x1c,%esp
f01054fe:	e8 a3 ac ff ff       	call   f01001a6 <__x86.get_pc_thunk.bx>
f0105503:	81 c3 69 c3 07 00    	add    $0x7c369,%ebx
f0105509:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010550c:	85 c0                	test   %eax,%eax
f010550e:	74 13                	je     f0105523 <readline+0x2e>
		cprintf("%s", prompt);
f0105510:	83 ec 08             	sub    $0x8,%esp
f0105513:	50                   	push   %eax
f0105514:	8d 83 f6 4a f8 ff    	lea    -0x7b50a(%ebx),%eax
f010551a:	50                   	push   %eax
f010551b:	e8 1f ee ff ff       	call   f010433f <cprintf>
f0105520:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105523:	83 ec 0c             	sub    $0xc,%esp
f0105526:	6a 00                	push   $0x0
f0105528:	e8 05 b2 ff ff       	call   f0100732 <iscons>
f010552d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105530:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105533:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0105538:	8d 83 d4 2b 00 00    	lea    0x2bd4(%ebx),%eax
f010553e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105541:	eb 45                	jmp    f0105588 <readline+0x93>
			cprintf("read error: %e\n", c);
f0105543:	83 ec 08             	sub    $0x8,%esp
f0105546:	50                   	push   %eax
f0105547:	8d 83 fc 5d f8 ff    	lea    -0x7a204(%ebx),%eax
f010554d:	50                   	push   %eax
f010554e:	e8 ec ed ff ff       	call   f010433f <cprintf>
			return NULL;
f0105553:	83 c4 10             	add    $0x10,%esp
f0105556:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010555b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010555e:	5b                   	pop    %ebx
f010555f:	5e                   	pop    %esi
f0105560:	5f                   	pop    %edi
f0105561:	5d                   	pop    %ebp
f0105562:	c3                   	ret    
			if (echoing)
f0105563:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105567:	75 05                	jne    f010556e <readline+0x79>
			i--;
f0105569:	83 ef 01             	sub    $0x1,%edi
f010556c:	eb 1a                	jmp    f0105588 <readline+0x93>
				cputchar('\b');
f010556e:	83 ec 0c             	sub    $0xc,%esp
f0105571:	6a 08                	push   $0x8
f0105573:	e8 99 b1 ff ff       	call   f0100711 <cputchar>
f0105578:	83 c4 10             	add    $0x10,%esp
f010557b:	eb ec                	jmp    f0105569 <readline+0x74>
			buf[i++] = c;
f010557d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105580:	89 f0                	mov    %esi,%eax
f0105582:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0105585:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0105588:	e8 94 b1 ff ff       	call   f0100721 <getchar>
f010558d:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f010558f:	85 c0                	test   %eax,%eax
f0105591:	78 b0                	js     f0105543 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105593:	83 f8 08             	cmp    $0x8,%eax
f0105596:	0f 94 c0             	sete   %al
f0105599:	83 fe 7f             	cmp    $0x7f,%esi
f010559c:	0f 94 c2             	sete   %dl
f010559f:	08 d0                	or     %dl,%al
f01055a1:	74 04                	je     f01055a7 <readline+0xb2>
f01055a3:	85 ff                	test   %edi,%edi
f01055a5:	7f bc                	jg     f0105563 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01055a7:	83 fe 1f             	cmp    $0x1f,%esi
f01055aa:	7e 1c                	jle    f01055c8 <readline+0xd3>
f01055ac:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f01055b2:	7f 14                	jg     f01055c8 <readline+0xd3>
			if (echoing)
f01055b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01055b8:	74 c3                	je     f010557d <readline+0x88>
				cputchar(c);
f01055ba:	83 ec 0c             	sub    $0xc,%esp
f01055bd:	56                   	push   %esi
f01055be:	e8 4e b1 ff ff       	call   f0100711 <cputchar>
f01055c3:	83 c4 10             	add    $0x10,%esp
f01055c6:	eb b5                	jmp    f010557d <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f01055c8:	83 fe 0a             	cmp    $0xa,%esi
f01055cb:	74 05                	je     f01055d2 <readline+0xdd>
f01055cd:	83 fe 0d             	cmp    $0xd,%esi
f01055d0:	75 b6                	jne    f0105588 <readline+0x93>
			if (echoing)
f01055d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01055d6:	75 13                	jne    f01055eb <readline+0xf6>
			buf[i] = 0;
f01055d8:	c6 84 3b d4 2b 00 00 	movb   $0x0,0x2bd4(%ebx,%edi,1)
f01055df:	00 
			return buf;
f01055e0:	8d 83 d4 2b 00 00    	lea    0x2bd4(%ebx),%eax
f01055e6:	e9 70 ff ff ff       	jmp    f010555b <readline+0x66>
				cputchar('\n');
f01055eb:	83 ec 0c             	sub    $0xc,%esp
f01055ee:	6a 0a                	push   $0xa
f01055f0:	e8 1c b1 ff ff       	call   f0100711 <cputchar>
f01055f5:	83 c4 10             	add    $0x10,%esp
f01055f8:	eb de                	jmp    f01055d8 <readline+0xe3>

f01055fa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055fa:	55                   	push   %ebp
f01055fb:	89 e5                	mov    %esp,%ebp
f01055fd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105600:	b8 00 00 00 00       	mov    $0x0,%eax
f0105605:	eb 03                	jmp    f010560a <strlen+0x10>
		n++;
f0105607:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f010560a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010560e:	75 f7                	jne    f0105607 <strlen+0xd>
	return n;
}
f0105610:	5d                   	pop    %ebp
f0105611:	c3                   	ret    

f0105612 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105612:	55                   	push   %ebp
f0105613:	89 e5                	mov    %esp,%ebp
f0105615:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105618:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010561b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105620:	eb 03                	jmp    f0105625 <strnlen+0x13>
		n++;
f0105622:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105625:	39 d0                	cmp    %edx,%eax
f0105627:	74 08                	je     f0105631 <strnlen+0x1f>
f0105629:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010562d:	75 f3                	jne    f0105622 <strnlen+0x10>
f010562f:	89 c2                	mov    %eax,%edx
	return n;
}
f0105631:	89 d0                	mov    %edx,%eax
f0105633:	5d                   	pop    %ebp
f0105634:	c3                   	ret    

f0105635 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105635:	55                   	push   %ebp
f0105636:	89 e5                	mov    %esp,%ebp
f0105638:	53                   	push   %ebx
f0105639:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010563c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010563f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105644:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0105648:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f010564b:	83 c0 01             	add    $0x1,%eax
f010564e:	84 d2                	test   %dl,%dl
f0105650:	75 f2                	jne    f0105644 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105652:	89 c8                	mov    %ecx,%eax
f0105654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105657:	c9                   	leave  
f0105658:	c3                   	ret    

f0105659 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105659:	55                   	push   %ebp
f010565a:	89 e5                	mov    %esp,%ebp
f010565c:	53                   	push   %ebx
f010565d:	83 ec 10             	sub    $0x10,%esp
f0105660:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105663:	53                   	push   %ebx
f0105664:	e8 91 ff ff ff       	call   f01055fa <strlen>
f0105669:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f010566c:	ff 75 0c             	push   0xc(%ebp)
f010566f:	01 d8                	add    %ebx,%eax
f0105671:	50                   	push   %eax
f0105672:	e8 be ff ff ff       	call   f0105635 <strcpy>
	return dst;
}
f0105677:	89 d8                	mov    %ebx,%eax
f0105679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010567c:	c9                   	leave  
f010567d:	c3                   	ret    

f010567e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010567e:	55                   	push   %ebp
f010567f:	89 e5                	mov    %esp,%ebp
f0105681:	56                   	push   %esi
f0105682:	53                   	push   %ebx
f0105683:	8b 75 08             	mov    0x8(%ebp),%esi
f0105686:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105689:	89 f3                	mov    %esi,%ebx
f010568b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010568e:	89 f0                	mov    %esi,%eax
f0105690:	eb 0f                	jmp    f01056a1 <strncpy+0x23>
		*dst++ = *src;
f0105692:	83 c0 01             	add    $0x1,%eax
f0105695:	0f b6 0a             	movzbl (%edx),%ecx
f0105698:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010569b:	80 f9 01             	cmp    $0x1,%cl
f010569e:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f01056a1:	39 d8                	cmp    %ebx,%eax
f01056a3:	75 ed                	jne    f0105692 <strncpy+0x14>
	}
	return ret;
}
f01056a5:	89 f0                	mov    %esi,%eax
f01056a7:	5b                   	pop    %ebx
f01056a8:	5e                   	pop    %esi
f01056a9:	5d                   	pop    %ebp
f01056aa:	c3                   	ret    

f01056ab <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01056ab:	55                   	push   %ebp
f01056ac:	89 e5                	mov    %esp,%ebp
f01056ae:	56                   	push   %esi
f01056af:	53                   	push   %ebx
f01056b0:	8b 75 08             	mov    0x8(%ebp),%esi
f01056b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056b6:	8b 55 10             	mov    0x10(%ebp),%edx
f01056b9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01056bb:	85 d2                	test   %edx,%edx
f01056bd:	74 21                	je     f01056e0 <strlcpy+0x35>
f01056bf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01056c3:	89 f2                	mov    %esi,%edx
f01056c5:	eb 09                	jmp    f01056d0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01056c7:	83 c1 01             	add    $0x1,%ecx
f01056ca:	83 c2 01             	add    $0x1,%edx
f01056cd:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f01056d0:	39 c2                	cmp    %eax,%edx
f01056d2:	74 09                	je     f01056dd <strlcpy+0x32>
f01056d4:	0f b6 19             	movzbl (%ecx),%ebx
f01056d7:	84 db                	test   %bl,%bl
f01056d9:	75 ec                	jne    f01056c7 <strlcpy+0x1c>
f01056db:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01056dd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01056e0:	29 f0                	sub    %esi,%eax
}
f01056e2:	5b                   	pop    %ebx
f01056e3:	5e                   	pop    %esi
f01056e4:	5d                   	pop    %ebp
f01056e5:	c3                   	ret    

f01056e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01056e6:	55                   	push   %ebp
f01056e7:	89 e5                	mov    %esp,%ebp
f01056e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01056ef:	eb 06                	jmp    f01056f7 <strcmp+0x11>
		p++, q++;
f01056f1:	83 c1 01             	add    $0x1,%ecx
f01056f4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01056f7:	0f b6 01             	movzbl (%ecx),%eax
f01056fa:	84 c0                	test   %al,%al
f01056fc:	74 04                	je     f0105702 <strcmp+0x1c>
f01056fe:	3a 02                	cmp    (%edx),%al
f0105700:	74 ef                	je     f01056f1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105702:	0f b6 c0             	movzbl %al,%eax
f0105705:	0f b6 12             	movzbl (%edx),%edx
f0105708:	29 d0                	sub    %edx,%eax
}
f010570a:	5d                   	pop    %ebp
f010570b:	c3                   	ret    

f010570c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010570c:	55                   	push   %ebp
f010570d:	89 e5                	mov    %esp,%ebp
f010570f:	53                   	push   %ebx
f0105710:	8b 45 08             	mov    0x8(%ebp),%eax
f0105713:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105716:	89 c3                	mov    %eax,%ebx
f0105718:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010571b:	eb 06                	jmp    f0105723 <strncmp+0x17>
		n--, p++, q++;
f010571d:	83 c0 01             	add    $0x1,%eax
f0105720:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105723:	39 d8                	cmp    %ebx,%eax
f0105725:	74 18                	je     f010573f <strncmp+0x33>
f0105727:	0f b6 08             	movzbl (%eax),%ecx
f010572a:	84 c9                	test   %cl,%cl
f010572c:	74 04                	je     f0105732 <strncmp+0x26>
f010572e:	3a 0a                	cmp    (%edx),%cl
f0105730:	74 eb                	je     f010571d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105732:	0f b6 00             	movzbl (%eax),%eax
f0105735:	0f b6 12             	movzbl (%edx),%edx
f0105738:	29 d0                	sub    %edx,%eax
}
f010573a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010573d:	c9                   	leave  
f010573e:	c3                   	ret    
		return 0;
f010573f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105744:	eb f4                	jmp    f010573a <strncmp+0x2e>

f0105746 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105746:	55                   	push   %ebp
f0105747:	89 e5                	mov    %esp,%ebp
f0105749:	8b 45 08             	mov    0x8(%ebp),%eax
f010574c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105750:	eb 03                	jmp    f0105755 <strchr+0xf>
f0105752:	83 c0 01             	add    $0x1,%eax
f0105755:	0f b6 10             	movzbl (%eax),%edx
f0105758:	84 d2                	test   %dl,%dl
f010575a:	74 06                	je     f0105762 <strchr+0x1c>
		if (*s == c)
f010575c:	38 ca                	cmp    %cl,%dl
f010575e:	75 f2                	jne    f0105752 <strchr+0xc>
f0105760:	eb 05                	jmp    f0105767 <strchr+0x21>
			return (char *) s;
	return 0;
f0105762:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105767:	5d                   	pop    %ebp
f0105768:	c3                   	ret    

f0105769 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105769:	55                   	push   %ebp
f010576a:	89 e5                	mov    %esp,%ebp
f010576c:	8b 45 08             	mov    0x8(%ebp),%eax
f010576f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105773:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105776:	38 ca                	cmp    %cl,%dl
f0105778:	74 09                	je     f0105783 <strfind+0x1a>
f010577a:	84 d2                	test   %dl,%dl
f010577c:	74 05                	je     f0105783 <strfind+0x1a>
	for (; *s; s++)
f010577e:	83 c0 01             	add    $0x1,%eax
f0105781:	eb f0                	jmp    f0105773 <strfind+0xa>
			break;
	return (char *) s;
}
f0105783:	5d                   	pop    %ebp
f0105784:	c3                   	ret    

f0105785 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105785:	55                   	push   %ebp
f0105786:	89 e5                	mov    %esp,%ebp
f0105788:	57                   	push   %edi
f0105789:	56                   	push   %esi
f010578a:	53                   	push   %ebx
f010578b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010578e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105791:	85 c9                	test   %ecx,%ecx
f0105793:	74 2f                	je     f01057c4 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105795:	89 f8                	mov    %edi,%eax
f0105797:	09 c8                	or     %ecx,%eax
f0105799:	a8 03                	test   $0x3,%al
f010579b:	75 21                	jne    f01057be <memset+0x39>
		c &= 0xFF;
f010579d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01057a1:	89 d0                	mov    %edx,%eax
f01057a3:	c1 e0 08             	shl    $0x8,%eax
f01057a6:	89 d3                	mov    %edx,%ebx
f01057a8:	c1 e3 18             	shl    $0x18,%ebx
f01057ab:	89 d6                	mov    %edx,%esi
f01057ad:	c1 e6 10             	shl    $0x10,%esi
f01057b0:	09 f3                	or     %esi,%ebx
f01057b2:	09 da                	or     %ebx,%edx
f01057b4:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01057b6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01057b9:	fc                   	cld    
f01057ba:	f3 ab                	rep stos %eax,%es:(%edi)
f01057bc:	eb 06                	jmp    f01057c4 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01057be:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057c1:	fc                   	cld    
f01057c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01057c4:	89 f8                	mov    %edi,%eax
f01057c6:	5b                   	pop    %ebx
f01057c7:	5e                   	pop    %esi
f01057c8:	5f                   	pop    %edi
f01057c9:	5d                   	pop    %ebp
f01057ca:	c3                   	ret    

f01057cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01057cb:	55                   	push   %ebp
f01057cc:	89 e5                	mov    %esp,%ebp
f01057ce:	57                   	push   %edi
f01057cf:	56                   	push   %esi
f01057d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01057d3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01057d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01057d9:	39 c6                	cmp    %eax,%esi
f01057db:	73 32                	jae    f010580f <memmove+0x44>
f01057dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01057e0:	39 c2                	cmp    %eax,%edx
f01057e2:	76 2b                	jbe    f010580f <memmove+0x44>
		s += n;
		d += n;
f01057e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057e7:	89 d6                	mov    %edx,%esi
f01057e9:	09 fe                	or     %edi,%esi
f01057eb:	09 ce                	or     %ecx,%esi
f01057ed:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01057f3:	75 0e                	jne    f0105803 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01057f5:	83 ef 04             	sub    $0x4,%edi
f01057f8:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057fb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01057fe:	fd                   	std    
f01057ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105801:	eb 09                	jmp    f010580c <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105803:	83 ef 01             	sub    $0x1,%edi
f0105806:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105809:	fd                   	std    
f010580a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010580c:	fc                   	cld    
f010580d:	eb 1a                	jmp    f0105829 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010580f:	89 f2                	mov    %esi,%edx
f0105811:	09 c2                	or     %eax,%edx
f0105813:	09 ca                	or     %ecx,%edx
f0105815:	f6 c2 03             	test   $0x3,%dl
f0105818:	75 0a                	jne    f0105824 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010581a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010581d:	89 c7                	mov    %eax,%edi
f010581f:	fc                   	cld    
f0105820:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105822:	eb 05                	jmp    f0105829 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0105824:	89 c7                	mov    %eax,%edi
f0105826:	fc                   	cld    
f0105827:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105829:	5e                   	pop    %esi
f010582a:	5f                   	pop    %edi
f010582b:	5d                   	pop    %ebp
f010582c:	c3                   	ret    

f010582d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010582d:	55                   	push   %ebp
f010582e:	89 e5                	mov    %esp,%ebp
f0105830:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105833:	ff 75 10             	push   0x10(%ebp)
f0105836:	ff 75 0c             	push   0xc(%ebp)
f0105839:	ff 75 08             	push   0x8(%ebp)
f010583c:	e8 8a ff ff ff       	call   f01057cb <memmove>
}
f0105841:	c9                   	leave  
f0105842:	c3                   	ret    

f0105843 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105843:	55                   	push   %ebp
f0105844:	89 e5                	mov    %esp,%ebp
f0105846:	56                   	push   %esi
f0105847:	53                   	push   %ebx
f0105848:	8b 45 08             	mov    0x8(%ebp),%eax
f010584b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010584e:	89 c6                	mov    %eax,%esi
f0105850:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105853:	eb 06                	jmp    f010585b <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105855:	83 c0 01             	add    $0x1,%eax
f0105858:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f010585b:	39 f0                	cmp    %esi,%eax
f010585d:	74 14                	je     f0105873 <memcmp+0x30>
		if (*s1 != *s2)
f010585f:	0f b6 08             	movzbl (%eax),%ecx
f0105862:	0f b6 1a             	movzbl (%edx),%ebx
f0105865:	38 d9                	cmp    %bl,%cl
f0105867:	74 ec                	je     f0105855 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0105869:	0f b6 c1             	movzbl %cl,%eax
f010586c:	0f b6 db             	movzbl %bl,%ebx
f010586f:	29 d8                	sub    %ebx,%eax
f0105871:	eb 05                	jmp    f0105878 <memcmp+0x35>
	}

	return 0;
f0105873:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105878:	5b                   	pop    %ebx
f0105879:	5e                   	pop    %esi
f010587a:	5d                   	pop    %ebp
f010587b:	c3                   	ret    

f010587c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010587c:	55                   	push   %ebp
f010587d:	89 e5                	mov    %esp,%ebp
f010587f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105885:	89 c2                	mov    %eax,%edx
f0105887:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010588a:	eb 03                	jmp    f010588f <memfind+0x13>
f010588c:	83 c0 01             	add    $0x1,%eax
f010588f:	39 d0                	cmp    %edx,%eax
f0105891:	73 04                	jae    f0105897 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105893:	38 08                	cmp    %cl,(%eax)
f0105895:	75 f5                	jne    f010588c <memfind+0x10>
			break;
	return (void *) s;
}
f0105897:	5d                   	pop    %ebp
f0105898:	c3                   	ret    

f0105899 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105899:	55                   	push   %ebp
f010589a:	89 e5                	mov    %esp,%ebp
f010589c:	57                   	push   %edi
f010589d:	56                   	push   %esi
f010589e:	53                   	push   %ebx
f010589f:	8b 55 08             	mov    0x8(%ebp),%edx
f01058a2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01058a5:	eb 03                	jmp    f01058aa <strtol+0x11>
		s++;
f01058a7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f01058aa:	0f b6 02             	movzbl (%edx),%eax
f01058ad:	3c 20                	cmp    $0x20,%al
f01058af:	74 f6                	je     f01058a7 <strtol+0xe>
f01058b1:	3c 09                	cmp    $0x9,%al
f01058b3:	74 f2                	je     f01058a7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01058b5:	3c 2b                	cmp    $0x2b,%al
f01058b7:	74 2a                	je     f01058e3 <strtol+0x4a>
	int neg = 0;
f01058b9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01058be:	3c 2d                	cmp    $0x2d,%al
f01058c0:	74 2b                	je     f01058ed <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058c2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01058c8:	75 0f                	jne    f01058d9 <strtol+0x40>
f01058ca:	80 3a 30             	cmpb   $0x30,(%edx)
f01058cd:	74 28                	je     f01058f7 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01058cf:	85 db                	test   %ebx,%ebx
f01058d1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01058d6:	0f 44 d8             	cmove  %eax,%ebx
f01058d9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01058de:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01058e1:	eb 46                	jmp    f0105929 <strtol+0x90>
		s++;
f01058e3:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f01058e6:	bf 00 00 00 00       	mov    $0x0,%edi
f01058eb:	eb d5                	jmp    f01058c2 <strtol+0x29>
		s++, neg = 1;
f01058ed:	83 c2 01             	add    $0x1,%edx
f01058f0:	bf 01 00 00 00       	mov    $0x1,%edi
f01058f5:	eb cb                	jmp    f01058c2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058f7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01058fb:	74 0e                	je     f010590b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f01058fd:	85 db                	test   %ebx,%ebx
f01058ff:	75 d8                	jne    f01058d9 <strtol+0x40>
		s++, base = 8;
f0105901:	83 c2 01             	add    $0x1,%edx
f0105904:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105909:	eb ce                	jmp    f01058d9 <strtol+0x40>
		s += 2, base = 16;
f010590b:	83 c2 02             	add    $0x2,%edx
f010590e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105913:	eb c4                	jmp    f01058d9 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105915:	0f be c0             	movsbl %al,%eax
f0105918:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010591b:	3b 45 10             	cmp    0x10(%ebp),%eax
f010591e:	7d 3a                	jge    f010595a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105920:	83 c2 01             	add    $0x1,%edx
f0105923:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0105927:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0105929:	0f b6 02             	movzbl (%edx),%eax
f010592c:	8d 70 d0             	lea    -0x30(%eax),%esi
f010592f:	89 f3                	mov    %esi,%ebx
f0105931:	80 fb 09             	cmp    $0x9,%bl
f0105934:	76 df                	jbe    f0105915 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0105936:	8d 70 9f             	lea    -0x61(%eax),%esi
f0105939:	89 f3                	mov    %esi,%ebx
f010593b:	80 fb 19             	cmp    $0x19,%bl
f010593e:	77 08                	ja     f0105948 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0105940:	0f be c0             	movsbl %al,%eax
f0105943:	83 e8 57             	sub    $0x57,%eax
f0105946:	eb d3                	jmp    f010591b <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0105948:	8d 70 bf             	lea    -0x41(%eax),%esi
f010594b:	89 f3                	mov    %esi,%ebx
f010594d:	80 fb 19             	cmp    $0x19,%bl
f0105950:	77 08                	ja     f010595a <strtol+0xc1>
			dig = *s - 'A' + 10;
f0105952:	0f be c0             	movsbl %al,%eax
f0105955:	83 e8 37             	sub    $0x37,%eax
f0105958:	eb c1                	jmp    f010591b <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f010595a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010595e:	74 05                	je     f0105965 <strtol+0xcc>
		*endptr = (char *) s;
f0105960:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105963:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0105965:	89 c8                	mov    %ecx,%eax
f0105967:	f7 d8                	neg    %eax
f0105969:	85 ff                	test   %edi,%edi
f010596b:	0f 45 c8             	cmovne %eax,%ecx
}
f010596e:	89 c8                	mov    %ecx,%eax
f0105970:	5b                   	pop    %ebx
f0105971:	5e                   	pop    %esi
f0105972:	5f                   	pop    %edi
f0105973:	5d                   	pop    %ebp
f0105974:	c3                   	ret    
f0105975:	66 90                	xchg   %ax,%ax
f0105977:	66 90                	xchg   %ax,%ax
f0105979:	66 90                	xchg   %ax,%ax
f010597b:	66 90                	xchg   %ax,%ax
f010597d:	66 90                	xchg   %ax,%ax
f010597f:	90                   	nop

f0105980 <__udivdi3>:
f0105980:	f3 0f 1e fb          	endbr32 
f0105984:	55                   	push   %ebp
f0105985:	57                   	push   %edi
f0105986:	56                   	push   %esi
f0105987:	53                   	push   %ebx
f0105988:	83 ec 1c             	sub    $0x1c,%esp
f010598b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010598f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0105993:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105997:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010599b:	85 c0                	test   %eax,%eax
f010599d:	75 19                	jne    f01059b8 <__udivdi3+0x38>
f010599f:	39 f3                	cmp    %esi,%ebx
f01059a1:	76 4d                	jbe    f01059f0 <__udivdi3+0x70>
f01059a3:	31 ff                	xor    %edi,%edi
f01059a5:	89 e8                	mov    %ebp,%eax
f01059a7:	89 f2                	mov    %esi,%edx
f01059a9:	f7 f3                	div    %ebx
f01059ab:	89 fa                	mov    %edi,%edx
f01059ad:	83 c4 1c             	add    $0x1c,%esp
f01059b0:	5b                   	pop    %ebx
f01059b1:	5e                   	pop    %esi
f01059b2:	5f                   	pop    %edi
f01059b3:	5d                   	pop    %ebp
f01059b4:	c3                   	ret    
f01059b5:	8d 76 00             	lea    0x0(%esi),%esi
f01059b8:	39 f0                	cmp    %esi,%eax
f01059ba:	76 14                	jbe    f01059d0 <__udivdi3+0x50>
f01059bc:	31 ff                	xor    %edi,%edi
f01059be:	31 c0                	xor    %eax,%eax
f01059c0:	89 fa                	mov    %edi,%edx
f01059c2:	83 c4 1c             	add    $0x1c,%esp
f01059c5:	5b                   	pop    %ebx
f01059c6:	5e                   	pop    %esi
f01059c7:	5f                   	pop    %edi
f01059c8:	5d                   	pop    %ebp
f01059c9:	c3                   	ret    
f01059ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01059d0:	0f bd f8             	bsr    %eax,%edi
f01059d3:	83 f7 1f             	xor    $0x1f,%edi
f01059d6:	75 48                	jne    f0105a20 <__udivdi3+0xa0>
f01059d8:	39 f0                	cmp    %esi,%eax
f01059da:	72 06                	jb     f01059e2 <__udivdi3+0x62>
f01059dc:	31 c0                	xor    %eax,%eax
f01059de:	39 eb                	cmp    %ebp,%ebx
f01059e0:	77 de                	ja     f01059c0 <__udivdi3+0x40>
f01059e2:	b8 01 00 00 00       	mov    $0x1,%eax
f01059e7:	eb d7                	jmp    f01059c0 <__udivdi3+0x40>
f01059e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01059f0:	89 d9                	mov    %ebx,%ecx
f01059f2:	85 db                	test   %ebx,%ebx
f01059f4:	75 0b                	jne    f0105a01 <__udivdi3+0x81>
f01059f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01059fb:	31 d2                	xor    %edx,%edx
f01059fd:	f7 f3                	div    %ebx
f01059ff:	89 c1                	mov    %eax,%ecx
f0105a01:	31 d2                	xor    %edx,%edx
f0105a03:	89 f0                	mov    %esi,%eax
f0105a05:	f7 f1                	div    %ecx
f0105a07:	89 c6                	mov    %eax,%esi
f0105a09:	89 e8                	mov    %ebp,%eax
f0105a0b:	89 f7                	mov    %esi,%edi
f0105a0d:	f7 f1                	div    %ecx
f0105a0f:	89 fa                	mov    %edi,%edx
f0105a11:	83 c4 1c             	add    $0x1c,%esp
f0105a14:	5b                   	pop    %ebx
f0105a15:	5e                   	pop    %esi
f0105a16:	5f                   	pop    %edi
f0105a17:	5d                   	pop    %ebp
f0105a18:	c3                   	ret    
f0105a19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105a20:	89 f9                	mov    %edi,%ecx
f0105a22:	ba 20 00 00 00       	mov    $0x20,%edx
f0105a27:	29 fa                	sub    %edi,%edx
f0105a29:	d3 e0                	shl    %cl,%eax
f0105a2b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a2f:	89 d1                	mov    %edx,%ecx
f0105a31:	89 d8                	mov    %ebx,%eax
f0105a33:	d3 e8                	shr    %cl,%eax
f0105a35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105a39:	09 c1                	or     %eax,%ecx
f0105a3b:	89 f0                	mov    %esi,%eax
f0105a3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105a41:	89 f9                	mov    %edi,%ecx
f0105a43:	d3 e3                	shl    %cl,%ebx
f0105a45:	89 d1                	mov    %edx,%ecx
f0105a47:	d3 e8                	shr    %cl,%eax
f0105a49:	89 f9                	mov    %edi,%ecx
f0105a4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105a4f:	89 eb                	mov    %ebp,%ebx
f0105a51:	d3 e6                	shl    %cl,%esi
f0105a53:	89 d1                	mov    %edx,%ecx
f0105a55:	d3 eb                	shr    %cl,%ebx
f0105a57:	09 f3                	or     %esi,%ebx
f0105a59:	89 c6                	mov    %eax,%esi
f0105a5b:	89 f2                	mov    %esi,%edx
f0105a5d:	89 d8                	mov    %ebx,%eax
f0105a5f:	f7 74 24 08          	divl   0x8(%esp)
f0105a63:	89 d6                	mov    %edx,%esi
f0105a65:	89 c3                	mov    %eax,%ebx
f0105a67:	f7 64 24 0c          	mull   0xc(%esp)
f0105a6b:	39 d6                	cmp    %edx,%esi
f0105a6d:	72 19                	jb     f0105a88 <__udivdi3+0x108>
f0105a6f:	89 f9                	mov    %edi,%ecx
f0105a71:	d3 e5                	shl    %cl,%ebp
f0105a73:	39 c5                	cmp    %eax,%ebp
f0105a75:	73 04                	jae    f0105a7b <__udivdi3+0xfb>
f0105a77:	39 d6                	cmp    %edx,%esi
f0105a79:	74 0d                	je     f0105a88 <__udivdi3+0x108>
f0105a7b:	89 d8                	mov    %ebx,%eax
f0105a7d:	31 ff                	xor    %edi,%edi
f0105a7f:	e9 3c ff ff ff       	jmp    f01059c0 <__udivdi3+0x40>
f0105a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105a88:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105a8b:	31 ff                	xor    %edi,%edi
f0105a8d:	e9 2e ff ff ff       	jmp    f01059c0 <__udivdi3+0x40>
f0105a92:	66 90                	xchg   %ax,%ax
f0105a94:	66 90                	xchg   %ax,%ax
f0105a96:	66 90                	xchg   %ax,%ax
f0105a98:	66 90                	xchg   %ax,%ax
f0105a9a:	66 90                	xchg   %ax,%ax
f0105a9c:	66 90                	xchg   %ax,%ax
f0105a9e:	66 90                	xchg   %ax,%ax

f0105aa0 <__umoddi3>:
f0105aa0:	f3 0f 1e fb          	endbr32 
f0105aa4:	55                   	push   %ebp
f0105aa5:	57                   	push   %edi
f0105aa6:	56                   	push   %esi
f0105aa7:	53                   	push   %ebx
f0105aa8:	83 ec 1c             	sub    $0x1c,%esp
f0105aab:	8b 74 24 30          	mov    0x30(%esp),%esi
f0105aaf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105ab3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0105ab7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0105abb:	89 f0                	mov    %esi,%eax
f0105abd:	89 da                	mov    %ebx,%edx
f0105abf:	85 ff                	test   %edi,%edi
f0105ac1:	75 15                	jne    f0105ad8 <__umoddi3+0x38>
f0105ac3:	39 dd                	cmp    %ebx,%ebp
f0105ac5:	76 39                	jbe    f0105b00 <__umoddi3+0x60>
f0105ac7:	f7 f5                	div    %ebp
f0105ac9:	89 d0                	mov    %edx,%eax
f0105acb:	31 d2                	xor    %edx,%edx
f0105acd:	83 c4 1c             	add    $0x1c,%esp
f0105ad0:	5b                   	pop    %ebx
f0105ad1:	5e                   	pop    %esi
f0105ad2:	5f                   	pop    %edi
f0105ad3:	5d                   	pop    %ebp
f0105ad4:	c3                   	ret    
f0105ad5:	8d 76 00             	lea    0x0(%esi),%esi
f0105ad8:	39 df                	cmp    %ebx,%edi
f0105ada:	77 f1                	ja     f0105acd <__umoddi3+0x2d>
f0105adc:	0f bd cf             	bsr    %edi,%ecx
f0105adf:	83 f1 1f             	xor    $0x1f,%ecx
f0105ae2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105ae6:	75 40                	jne    f0105b28 <__umoddi3+0x88>
f0105ae8:	39 df                	cmp    %ebx,%edi
f0105aea:	72 04                	jb     f0105af0 <__umoddi3+0x50>
f0105aec:	39 f5                	cmp    %esi,%ebp
f0105aee:	77 dd                	ja     f0105acd <__umoddi3+0x2d>
f0105af0:	89 da                	mov    %ebx,%edx
f0105af2:	89 f0                	mov    %esi,%eax
f0105af4:	29 e8                	sub    %ebp,%eax
f0105af6:	19 fa                	sbb    %edi,%edx
f0105af8:	eb d3                	jmp    f0105acd <__umoddi3+0x2d>
f0105afa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105b00:	89 e9                	mov    %ebp,%ecx
f0105b02:	85 ed                	test   %ebp,%ebp
f0105b04:	75 0b                	jne    f0105b11 <__umoddi3+0x71>
f0105b06:	b8 01 00 00 00       	mov    $0x1,%eax
f0105b0b:	31 d2                	xor    %edx,%edx
f0105b0d:	f7 f5                	div    %ebp
f0105b0f:	89 c1                	mov    %eax,%ecx
f0105b11:	89 d8                	mov    %ebx,%eax
f0105b13:	31 d2                	xor    %edx,%edx
f0105b15:	f7 f1                	div    %ecx
f0105b17:	89 f0                	mov    %esi,%eax
f0105b19:	f7 f1                	div    %ecx
f0105b1b:	89 d0                	mov    %edx,%eax
f0105b1d:	31 d2                	xor    %edx,%edx
f0105b1f:	eb ac                	jmp    f0105acd <__umoddi3+0x2d>
f0105b21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105b28:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105b2c:	ba 20 00 00 00       	mov    $0x20,%edx
f0105b31:	29 c2                	sub    %eax,%edx
f0105b33:	89 c1                	mov    %eax,%ecx
f0105b35:	89 e8                	mov    %ebp,%eax
f0105b37:	d3 e7                	shl    %cl,%edi
f0105b39:	89 d1                	mov    %edx,%ecx
f0105b3b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105b3f:	d3 e8                	shr    %cl,%eax
f0105b41:	89 c1                	mov    %eax,%ecx
f0105b43:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105b47:	09 f9                	or     %edi,%ecx
f0105b49:	89 df                	mov    %ebx,%edi
f0105b4b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105b4f:	89 c1                	mov    %eax,%ecx
f0105b51:	d3 e5                	shl    %cl,%ebp
f0105b53:	89 d1                	mov    %edx,%ecx
f0105b55:	d3 ef                	shr    %cl,%edi
f0105b57:	89 c1                	mov    %eax,%ecx
f0105b59:	89 f0                	mov    %esi,%eax
f0105b5b:	d3 e3                	shl    %cl,%ebx
f0105b5d:	89 d1                	mov    %edx,%ecx
f0105b5f:	89 fa                	mov    %edi,%edx
f0105b61:	d3 e8                	shr    %cl,%eax
f0105b63:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105b68:	09 d8                	or     %ebx,%eax
f0105b6a:	f7 74 24 08          	divl   0x8(%esp)
f0105b6e:	89 d3                	mov    %edx,%ebx
f0105b70:	d3 e6                	shl    %cl,%esi
f0105b72:	f7 e5                	mul    %ebp
f0105b74:	89 c7                	mov    %eax,%edi
f0105b76:	89 d1                	mov    %edx,%ecx
f0105b78:	39 d3                	cmp    %edx,%ebx
f0105b7a:	72 06                	jb     f0105b82 <__umoddi3+0xe2>
f0105b7c:	75 0e                	jne    f0105b8c <__umoddi3+0xec>
f0105b7e:	39 c6                	cmp    %eax,%esi
f0105b80:	73 0a                	jae    f0105b8c <__umoddi3+0xec>
f0105b82:	29 e8                	sub    %ebp,%eax
f0105b84:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0105b88:	89 d1                	mov    %edx,%ecx
f0105b8a:	89 c7                	mov    %eax,%edi
f0105b8c:	89 f5                	mov    %esi,%ebp
f0105b8e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105b92:	29 fd                	sub    %edi,%ebp
f0105b94:	19 cb                	sbb    %ecx,%ebx
f0105b96:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0105b9b:	89 d8                	mov    %ebx,%eax
f0105b9d:	d3 e0                	shl    %cl,%eax
f0105b9f:	89 f1                	mov    %esi,%ecx
f0105ba1:	d3 ed                	shr    %cl,%ebp
f0105ba3:	d3 eb                	shr    %cl,%ebx
f0105ba5:	09 e8                	or     %ebp,%eax
f0105ba7:	89 da                	mov    %ebx,%edx
f0105ba9:	83 c4 1c             	add    $0x1c,%esp
f0105bac:	5b                   	pop    %ebx
f0105bad:	5e                   	pop    %esi
f0105bae:	5f                   	pop    %edi
f0105baf:	5d                   	pop    %ebp
f0105bb0:	c3                   	ret    
