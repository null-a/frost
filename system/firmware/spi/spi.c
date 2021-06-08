#include "stdlib.h"

int volatile * const input_reg0 = (int*)0x1000C;

int volatile * const output_reg0 = (int*)0x1000C;
int volatile * const output_reg1 = (int*)0x10010;
int volatile * const output_reg2 = (int*)0x10014;
int volatile * const output_reg3 = (int*)0x10018;

#define MISO *input_reg0
#define MOSI *output_reg0
#define SCK  *output_reg1
#define SS   *output_reg2
#define IDLE *output_reg3

#define HI_Z 2

void ack(void) {
  putchar(0xAA);
}

// send_byte/recv_byte are the primary functions used to bit bang the
// SPI protocol.

// They expect SCK to be low on entry. SCK will always then be low on
// exit.

void send_byte(char val) {
  int i;
  char mask = 0x80;
  for(i=0; i<8; i++) {
    MOSI = val & mask ? 1 : 0;
    SCK = 1;
    SCK = 0;
    mask = mask >> 1;
  }
}

char recv_byte(void) {
  char out = 0;
  int i;
  for(i=0; i<8; i++) {
    out = out << 1;
    SCK = 1;
    out = out | MISO;
    SCK = 0;
  }
  return out;
}

void spi_enable(void) {
  IDLE = 0;
  sleep(10);
  // Set the initial state of the SPI bus.
  SS = 1;
  SCK = 0;
  MOSI = 0; // Don't care
  sleep(10);
  // Ensure the flash is not in deep sleep.
  SS = 0;
  send_byte(0xAB);
  SS = 1;
  sleep(1);
}

void spi_disable(void) {
  // Get off the SPI bus.
  sleep(10);
  SS = HI_Z;
  SCK = HI_Z;
  MOSI = HI_Z;
  sleep(10);
  IDLE = 1;
}

void cmd_cli_device_id(void) {
  ack();
  spi_enable();
  SS = 0;
  send_byte(0x9F);
  putchar(recv_byte());
  putchar(recv_byte());
  putchar(recv_byte());
  SS = 1;
  spi_disable();
  ack();
}

void cmd_cli_status(void) {
  ack();
  spi_enable();
  SS = 0;
  send_byte(0x05);
  putchar(recv_byte());
  SS = 1;
  sleep(1);
  SS = 0;
  send_byte(0x35);
  putchar(recv_byte());
  SS = 1;
  spi_disable();
  ack();
}

void cmd_cli_read(void) {
  int i;
  int length = 0;
  int addr[3];
  ack();
  length |= getchar() << 16;
  length |= getchar() << 8;
  length |= getchar();
  addr[0] = getchar();
  addr[1] = getchar();
  addr[2] = getchar();
  ack();
  spi_enable();
  SS = 0;
  send_byte(0x03); // opcode
  send_byte(addr[0]); // addr
  send_byte(addr[1]);
  send_byte(addr[2]);
  for(i=0; i<length; i++) {
    // TODO: I could probably improve throughput by chunking this,
    // which would make better use of the serial tx buffer. (Though
    // that may be small?)
    putchar(recv_byte());
  }
  SS = 1;
  spi_disable();
  ack();
}

void cmd_cli_chip_erase(void) {
  ack();
  spi_enable();
  // write enable
  SS = 0;
  send_byte(0x06); // opcode
  SS = 1;
  sleep(1);
  // chip erase
  SS = 0;
  send_byte(0x60); // opcode
  SS = 1;
  sleep(1);
  // poll the status register until ready
  SS = 0;
  send_byte(0x05); // opcode
  while(recv_byte() & 0x01);
  SS = 1;
  spi_disable();
  ack();
}

void cmd_cli_write(void) {
  int i;
  int length; // max 256
  // `page` is the top 16 bits of 24 bit address, it's hard-coded to
  // start writing at start of flash
  int page = 0;
  ack();
  spi_enable();
  for(;;) {
    if (getchar()) break; // we're done
    // TODO: Without this `ack` (and the corresponding wait in the
    // CLI) I'm seeing intermittent failure while writing, and I have
    // no idea why. It looks like the FPGA always completes the write
    // of a whole page, but then CLI fails on `wait_for_ack`. I don't
    // think this is buffer over run, since (a) this happens even with
    // a large (512 byte) FIFO, and (b) (as mentioned) writes aren't
    // stopping mid-page.
    ack();
    length = getchar() + 1;
    // write enable
    SS = 0;
    send_byte(0x06); // opcode
    SS = 1;
    sleep(1);
    // write data
    SS = 0;
    send_byte(0x02); // opcode
    send_byte(page >> 8 & 0xff); // address
    send_byte(page & 0xff);
    send_byte(0x00); // low 8 bits always equal zero on a 256 byte page boundary
    for(i=0; i<length; i++) {
      send_byte(getchar());
    }
    SS = 1;
    page++;
    ack();
    // Wait for programming to complete.
    SS = 0;
    send_byte(0x05); // opcode
    while(recv_byte() & 0x01);
    SS = 1;
  }
  spi_disable();
  ack();
}

void cmd_cli_erase_132(void) {
  ack();
  spi_enable();
  // write enable
  SS = 0;
  send_byte(0x06); // opcode
  SS = 1;
  // erase 0-64 KBytes
  SS = 0;
  send_byte(0xd8); // opcode
  send_byte(0x00); // address
  send_byte(0x00);
  send_byte(0x00);
  SS = 1;
  // wait until ready
  SS = 0;
  send_byte(0x05); // opcode
  while(recv_byte() & 0x01);
  SS = 1;
  // write enable
  SS = 0;
  send_byte(0x06); // opcode
  SS = 1;
  // erase 64-128 KBytes
  SS = 0;
  send_byte(0xd8); // opcode
  send_byte(0x01); // address
  send_byte(0x00);
  send_byte(0x00);
  SS = 1;
  // wait until ready
  SS = 0;
  send_byte(0x05); // opcode
  while(recv_byte() & 0x01);
  SS = 1;
  // write enable
  SS = 0;
  send_byte(0x06); // opcode
  SS = 1;
  // erase 128-132 KBytes
  SS = 0;
  send_byte(0x20); // opcode
  send_byte(0x02); // address
  send_byte(0x00);
  send_byte(0x00);
  SS = 1;
  // wait until ready
  SS = 0;
  send_byte(0x05); // opcode
  while(recv_byte() & 0x01);
  SS = 1;
  // finish up
  spi_disable();
  ack();
}

void cmd_read_sr(void) {
  int reg, i;
  ack();
  reg = getchar();
  ack();
  spi_enable();
  SS = 0;
  send_byte(0x48); // opcode
  send_byte(0); // address
  send_byte(reg);
  send_byte(0);
  send_byte(0); // dummy
  for(i=0; i<256; i++) {
    putchar(recv_byte());
  }
  SS = 1;
  spi_disable();
  ack();
}

void cmd_erase_sr(void) {
  int reg;
  ack();
  reg = getchar();
  ack();
  spi_enable();
  // write enable
  SS = 0;
  send_byte(0x06); // opcode
  SS = 1;
  // erase register
  SS = 0;
  send_byte(0x44); // opcode
  send_byte(0); // address
  send_byte(reg);
  send_byte(0);
  SS = 1;
  // wait until ready
  SS = 0;
  send_byte(0x05); // opcode
  while(recv_byte() & 0x01);
  SS = 1;
  spi_disable();
  ack();
}

void cmd_write_sr(void) {
  int reg, length, i;
  ack();
  reg = getchar();
  ack();
  length = getchar();
  ack();
  spi_enable();
  // write enable
  SS = 0;
  send_byte(0x06); // opcode
  SS = 1;
  // write data
  SS = 0;
  send_byte(0x42); // opcode
  send_byte(0); // address
  send_byte(reg);
  send_byte(0);
  for(i=0; i<length; i++) {
    send_byte(getchar());
  }
  SS = 1;
  // wait until ready
  SS = 0;
  send_byte(0x05); // opcode
  while(recv_byte() & 0x01);
  SS = 1;
  spi_disable();
  ack();
}

// TODO: I sometimes see junk on the serial connection at FPGA power
// on (e.g. in miniterm), which I think this leads to problems making
// the first connection with the CLI. More investigation is required.

int main(void)
{
  IDLE = 1;
  for(;;) {
    switch(getchar()) {
    case 0xF0:
      ack();
      break;
    case 0xF1:
      cmd_cli_device_id();
      break;
    case 0xF2:
      cmd_cli_status();
      break;
    case 0xF3:
      cmd_cli_read();
      break;
    case 0xF4:
      cmd_cli_write();
      break;
    case 0xF5:
      cmd_cli_chip_erase();
      break;
    case 0xF6:
      cmd_cli_erase_132();
      break;
    case 0xF7:
      cmd_read_sr();
      break;
    case 0xF8:
      cmd_erase_sr();
      break;
    case 0xF9:
      cmd_write_sr();
      break;
    default:
      putchar('?');
      break;
    }
  }

  return 0;
}
