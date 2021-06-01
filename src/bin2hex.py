import sys
from itertools import zip_longest

ALIGN = 4

# https://docs.python.org/3/library/itertools.html
def grouper(iterable, n, fillvalue=None):
    args = [iter(iterable)] * n
    return zip_longest(*args, fillvalue=fillvalue)

def main(filename):
    with open(filename, 'rb') as f:
        data = f.read()

    data = grouper(data, ALIGN, 0)

    for (b0, b1, b2, b3) in data:
        print('{:02x}{:02x}{:02x}{:02x}'.format(b3, b2, b1, b0))

if __name__ == '__main__':
    main(sys.argv[1])
