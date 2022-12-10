def nearest_zero(array: str) -> str:
    distance = [0] * len(array)
    distance_zero = float('inf')
    for i, value in enumerate(array):
        if value == 0:
            distance[i] = 0
            distance_zero = 0
            for j in range(i, -1, -1):
                if distance_zero <= distance[j]:
                    distance[j] = distance_zero
                    distance_zero += 1
                else:
                    break
            distance_zero = 0
        else:
            distance_zero += 1
            distance[i] = distance_zero
    return distance

street = [int(house) for house in input().split()]
print(*nearest_zero(street))

