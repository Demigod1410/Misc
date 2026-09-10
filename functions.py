# 1. Accept two numbers using functions and perform addition, subtraction, multiplication

def accept():
    a = int(input("Enter first number: "))
    b = int(input("Enter second number: "))
    return a, b

def add(a, b):
    return a + b

def sub(a, b):
    return a - b

def mult(a, b):
    return a * b

a, b = accept()
print("Addition =", add(a, b))
print("Subtraction =", sub(a, b))
print("Multiplication =", mult(a, b))

# 2. Accept a number and find its square and cube

def square(a):
    return a * a

def cube(b):
    return b * b * b

a = int(input("Enter a number: "))
b = square(a)
print("Square =", b)
print("Cube =", cube(a))

# 3. Check whether a number is palindrome

def display(n):
    temp = n
    rev = 0

    while n > 0:
        digit = n % 10
        rev = rev * 10 + digit
        n = n // 10

    if temp == rev:
        print("Palindrome Number")
    else:
        print("Not a Palindrome Number")

n = int(input("Enter a number: "))
display(n)

# 4. Find total marks and percentage

def marks(subject1, subject2, subject3):
    return subject1 + subject2 + subject3

def percentage(total):
    return total / 3

s1 = float(input("Enter marks of Subject 1: "))
s2 = float(input("Enter marks of Subject 2: "))
s3 = float(input("Enter marks of Subject 3: "))

total = marks(s1, s2, s3)
print("Total Marks =", total)
print("Percentage =", percentage(total))

# 5. Count letters in a word and display the maximum occurring letter

def wordcount(word):
    print("Length of word =", len(word))

    count = {}

    for ch in word:
        if ch in count:
            count[ch] += 1
        else:
            count[ch] = 1

    print("Letter Count:")
    for key in count:
        print(key, "=", count[key])

    maximum = max(count, key=count.get)
    print("Maximum occurring letter =", maximum)

word = input("Enter a word: ")
wordcount(word)

# 6. Check whether a number is perfect

def perfect(no):
    total = 0

    for i in range(1, no):
        if no % i == 0:
            total += i

    if total == no:
        print("Perfect Number")
    else:
        print("Not a Perfect Number")

num = int(input("Enter a number: "))
perfect(num)

# 7. Find maximum of three numbers

def maximum(a, b, c):
    if a >= b and a >= c:
        return a
    elif b >= a and b >= c:
        return b
    else:
        return c

a = int(input("Enter first number: "))
b = int(input("Enter second number: "))
c = int(input("Enter third number: "))

print("Maximum =", maximum(a, b, c))

# 8. Find multiplication of all digits in a 4-digit number

def multiply_digits(num):
    product = 1

    while num > 0:
        digit = num % 10
        product *= digit
        num = num // 10

    return product

number = int(input("Enter a 4-digit number: "))
print("Multiplication of digits =", multiply_digits(number))

# 9. Display multiplication table

def accept():
    n = int(input("Enter number: "))
    limit = int(input("Enter upper limit: "))
    return n, limit

def table(n, limit):
    for i in range(1, limit + 1):
        print(n, "x", i, "=", n * i)

n, limit = accept()
table(n, limit)

# 10. Display numbers and words separately from a list

def accept():
    values = input("Enter list elements separated by space: ").split()
    return values

def display(values):
    numbers = []
    words = []

    for item in values:
        if item.isdigit():
            numbers.append(item)
        else:
            words.append(item)

    print("Numbers:", numbers)
    print("Words:", words)

values = accept()
display(values)