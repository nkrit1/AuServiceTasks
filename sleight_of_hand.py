def sleight_of_hand(k: int) -> int:
    points = 0
    counter = [0] * 10
    for row in range(4):
        for value in input():
            if value != '.':
                counter[int(value)] += 1
    for value in counter:
        points += 1 if 0 < value <= 2 * k else 0
    return points


k = int(input())
print(sleight_of_hand(k))
