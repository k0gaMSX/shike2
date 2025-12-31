How to debug using xdbge
------------------------
- Start it with xdbge /m (enable mapper support)
- Load the binary with ESC I
- Move the debugger to parallel pages.
	- Change the paages for the page 0, 1, 2. Segments 4,5,6 are not used
	  in the game, so they can be used.
	- Press ESC U
- Change the base address of the vram tables with ESC T. AT this moment
  12000 is a good address.
- Change the stack pointer to C400.
