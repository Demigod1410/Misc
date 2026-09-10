import random


numbers = [random.randint(1, 20) for _ in range(10)]
print(f"Original List: {numbers}\n")


mid = len(numbers) // 2
first_half = numbers[:mid]
second_half = numbers[mid:]
print(f"First Half: {first_half}")
print(f"Second Half: {second_half}\n")


lowest_two = sorted(numbers)[:2]
print(f"The two lowest numbers are: {lowest_two}\n")


sorted_numbers = sorted(numbers)
print(f"Sorted List: {sorted_numbers}\n")


target = 15
if target in numbers:
    print(f"Number {target} already exists in the list.")
else:
    numbers.append(target)
    print(f"Number {target} did not exist. Added to end: {numbers}")
print()


first_last_sum = numbers[0] + numbers[-1]
print(f"Sum of 1st ({numbers[0]}) and last ({numbers[-1]}) number: {first_last_sum}\n")


duplicates = list(set([x for x in numbers if numbers.count(x) > 1]))
print(f"Duplicate numbers: {duplicates}\n")


distinct_numbers = list(set(numbers))
print(f"Distinct numbers: {distinct_numbers}\n")


one_digit_numbers = [x for x in numbers if -9 <= x <= 9]
print(f"One-digit numbers: {one_digit_numbers}\n")


total_sum = sum(numbers)
average = total_sum / len(numbers)
print(f"Sum of all numbers: {total_sum}")
print(f"Average of numbers: {average:.2f}")