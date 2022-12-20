import functools


def mycmp(a, b):
    return -1 if (a[0] * 10 ** len(b[1]) + b[0]) > (b[0] * 10 ** len(a[1]) + a[0]) else 1


flag = True
n = int(input())
if n != 0:
    array = [[int(float(x)), str(int(float(x)))] for x in input().split(' ')]
    for el in array:
        if el[0] < 0:
            flag = False
    if flag:
        array.sort(key=functools.cmp_to_key(mycmp))
        print(''.join([x[1] for x in array]), end='')

