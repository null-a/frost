#!/usr/bin/env python3

import os
import sys
import serial
import argparse

BAUD_RATE = 250000

VERBOSE = False

def log(s):
    if VERBOSE:
       print(s)

def connect():
    ser = serial.Serial('/dev/cu.usbserial', BAUD_RATE, timeout=1)
    # It's possible the device transmitting data from a previous
    # failed interaction. We discard any such data to hopefully get to
    # a known state.
    while True:
        n = ser.in_waiting
        if n == 0:
            break
        log('slurping {} byte(s) from input\n'.format(n))
        ser.read(n)
    # Call the test command to confirm the device is in the expected
    # state.
    ser.write(b'\xf0')
    wait_for_ack(ser);
    return ser

def wait_for_ack(ser):
    data = ser.read(1)
    assert len(data) == 1 and data[0] == 0xaa, 'ack not received, got: {}'.format(data)
    log('ack')

def cmd_test():
    log('enter test command')
    connect()

def cmd_device_id():
    log('enter device_id command')
    ser = connect()
    ser.write(b'\xf1')
    wait_for_ack(ser)
    recv = ser.read(3)
    log(recv)
    print('Manufacturer ID: 0x{:02X}\nDevice ID 1:     0x{:02X}\nDevice ID 2:     0x{:02X}'.format(*recv))
    wait_for_ack(ser)

def cmd_status():
    log('enter status command')
    ser = connect()
    ser.write(b'\xf2')
    wait_for_ack(ser)
    recv = ser.read(2)
    log(recv)
    print('Status register byte 1: 0x{:02X}\nStatus register byte 2: 0x{:02X}'.format(*recv))
    wait_for_ack(ser)

READ_BUF_SIZE = 8

def encode(val):
    assert 0 <= val < 2**24 - 1
    return bytes([val >> 16 & 0xff, val >> 8 & 0xff, val & 0xff])

def cmd_read(offset, length):
    log('enter read command')
    log('offset={}, length={}'.format(offset, length))

    ser = connect()
    ser.write(b'\xf3')
    wait_for_ack(ser)

    # Send length and offset.
    length_enc = encode(length)
    offset_enc = encode(offset)
    log(length_enc)
    log(offset_enc)
    ser.write(length_enc)
    ser.write(offset_enc)
    wait_for_ack(ser)

    # Note that reads aren't currently chunked on the FPGA.
    bytes_recv = 0
    with os.fdopen(sys.stdout.fileno(), "wb", closefd=False) as stdout:
        while bytes_recv < length:
            n = min(length - bytes_recv, READ_BUF_SIZE)
            log('will receive {} bytes'.format(n))
            recv = ser.read(n)
            log(recv)
            if not VERBOSE:
                stdout.write(recv)
                stdout.flush()
            bytes_recv += n

    wait_for_ack(ser)

def hexdump(bs):
    return '[' + ', '.join(['0x{:02x}'] * len(bs)).format(*bs) + ']'

# TODO: Have the FPGA erase the page before programming?

def cmd_write():
    log('enter write command')
    ser = connect()
    ser.write(b'\xf4')
    wait_for_ack(ser);
    # TODO: Warn/error if we receive so much data that we wrap around
    # to the first page?
    while True:
        data = sys.stdin.buffer.read(256)
        num_bytes = len(data)
        if num_bytes == 0:
            break
        ser.write(b'\x00') # signal we have more data
        wait_for_ack(ser);
        log('len={} bytes'.format(num_bytes))
        # We send length-1 to ensure that the value we're sending fits
        # in a single byte. (Otherwise, the max length of 256 would
        # need 2 bytes.) Crucially, we know that the minimum length is
        # one, so doing this is unambiguous.
        length_enc = bytes([num_bytes - 1])
        log(hexdump(length_enc))
        ser.write(length_enc)
        ser.write(data)
        wait_for_ack(ser);
        if not VERBOSE:
            print('.', end='', flush=True)

    if not VERBOSE:
        print('')

    ser.write(b'\x01') # signal we're done
    wait_for_ack(ser)

def cmd_chip_erase():
    log('enter chip_erase command')
    ser = connect()
    ser.write(b'\xf5')
    wait_for_ack(ser)
    # Chip erase happens here. We receive an ack once the flash
    # returns to the ready state.
    old_timeout = ser.timeout
    ser.timeout = 25 # The data sheet says chip erase can take upto 20 seconds, we add a margin.
    wait_for_ack(ser)
    ser.timeout = old_timeout

def cmd_erase_132():
    log('enter erase_132 command')
    ser = connect()
    ser.write(b'\xf6')
    wait_for_ack(ser)
    # Erase happens here. The data sheet says this sequence of erase
    # commands can take upto ~6.3 seconds to complete.
    old_timeout = ser.timeout
    ser.timeout = 7
    wait_for_ack(ser)
    ser.timeout = old_timeout

REGS = [1, 2, 3]

def cmd_read_sr(register):
    assert register in REGS
    log('enter read_sr command')
    log('register: {}'.format(register))
    ser = connect()
    ser.write(b'\xf7')
    wait_for_ack(ser)
    ser.write(bytes([register]))
    wait_for_ack(ser)
    recv = ser.read(256)
    log(hexdump(recv))
    if not VERBOSE:
        with os.fdopen(sys.stdout.fileno(), "wb", closefd=False) as stdout:
            stdout.write(recv)
            stdout.flush()
    wait_for_ack(ser)

def cmd_erase_sr(register):
    assert register in REGS
    log('enter erase_sr command')
    log('register: {}'.format(register))
    ser = connect()
    ser.write(b'\xf8')
    wait_for_ack(ser)
    ser.write(bytes([register]))
    wait_for_ack(ser)
    # erase happens here
    wait_for_ack(ser)

def cmd_write_sr(register):
    assert register in REGS
    log('enter write_sr command')
    log('register: {}'.format(register))
    data = sys.stdin.buffer.read(256)
    num_bytes = len(data)
    log('len={} bytes'.format(num_bytes))
    ser = connect()
    ser.write(b'\xf9')
    wait_for_ack(ser)
    ser.write(bytes([register]))
    wait_for_ack(ser)
    ser.write(bytes([num_bytes]))
    wait_for_ack(ser)
    ser.write(data)
    # write happens here
    wait_for_ack(ser);

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--verbose', action='store_true', help='Be more verbose.')
    subparsers = parser.add_subparsers(dest='command', required=True)

    parser_test = subparsers.add_parser('test', help='Test serial connection to FPGA.')
    parser_test.set_defaults(fn=cmd_test)

    parser_device_id = subparsers.add_parser('device_id', help='Read the device ID of the flash.')
    parser_device_id.set_defaults(fn=cmd_device_id)

    parser_status = subparsers.add_parser('status', help='Read the status registers of the flash.')
    parser_status.set_defaults(fn=cmd_status)

    parser_read = subparsers.add_parser('read', help='Read data from the flash. Data is written to stdout.')
    parser_read.add_argument('length', type=int, help='Read this many bytes.')
    parser_read.add_argument('-o', '--offset', type=int, default=0, help='Start reading data from this byte.')
    parser_read.set_defaults(fn=cmd_read)

    parser_write = subparsers.add_parser('write', help='Write data to flash. Data is read from stdin.')
    parser_write.set_defaults(fn=cmd_write)

    parser_chip_erase = subparsers.add_parser('chip_erase', help='Erase all data from the flash.')
    parser_chip_erase.set_defaults(fn=cmd_chip_erase)

    parser_erase_132 = subparsers.add_parser('erase_132', help='Erase the first 132 KBytes of the flash')
    parser_erase_132.set_defaults(fn=cmd_erase_132)

    parser_read_sr = subparsers.add_parser('read_sr', help='Read the contents of a security register.')
    parser_read_sr.add_argument('register', type=int, choices=REGS, help='Register to read from.')
    parser_read_sr.set_defaults(fn=cmd_read_sr)

    parser_erase_sr = subparsers.add_parser('erase_sr', help='Erase a security register.')
    parser_erase_sr.add_argument('register', type=int, choices=REGS, help='Register to erase.')
    parser_erase_sr.set_defaults(fn=cmd_erase_sr)

    parser_write_sr = subparsers.add_parser('write_sr', help='Write to a security register. Data is read from stdin.')
    parser_write_sr.add_argument('register', type=int, choices=REGS, help='Register to write to.')
    parser_write_sr.set_defaults(fn=cmd_write_sr)

    args = parser.parse_args()
    VERBOSE = args.verbose
    args.fn(**{k:v for k,v in vars(args).items() if not k in ['command', 'fn', 'verbose']})
    log('bye')
