SECTIONS {
  .text : {

    /* I want the contents of crt0 to appear at the beginning of the
    binary, regardless of where it appears in the list of files given
    on the command line. I could use STARTUP for this, but I want to
    leave crt0.o as a dependency in the Makefile, so rather than
    figure out how to tell make to not pass `crt0.o` to the linker,
    I'll do this instead. */

    crt0.o (.text);

    /* With e.g. -O2 GCC puts main in ".text.startup". It's convenient
    to have main near the beginning of the binary, hence this. */

    * (.text.startup);
    * (.text);
  }
}
