import sys

# Convert a binary file (path given as command-line arg) into a
# Verilog "hex" file for inclusion in `ram.hex`.

def main(filename):
    with open(filename, 'rb') as f:
        data = f.read()
    num_words = len(data) // 4
    for i in range(num_words):
        j = i*4
        print('{:02x}{:02x}{:02x}{:02x}'.format(data[j+3], data[j+2], data[j+1], data[j]))

if __name__ == '__main__':
    main(sys.argv[1])
