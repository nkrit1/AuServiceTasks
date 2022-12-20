lst = []


def brackets_generator(n, seq='', left=0, right=0):
    if left == n and right == n:
        lst.append(seq)
    else:
        if left < n:
            brackets_generator(n, seq + '(', left + 1, right)
        if right < left:
            brackets_generator(n, seq + ')', left, right + 1)


n = int(input())
brackets_generator(n)
for i, seq in enumerate(lst):
    e = '\n'
    if i == len(lst)-1:
        e = ''
    print(seq, end=e)
