# Encontra os primos até N
# Utiliza o algoritmo Sieves of Eratosthenes
# https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes

from math import isqrt
import sys

def find_primes(n: int):
    numbers: list[int] = [0] * (n+1)
    
    num: int = 2

    while num < n/2:#isqrt(n) + 1:
        if numbers[num] == 0:
            multi = num*2#num
            while multi < n+1:
                numbers[multi] = 1
                multi += num
        
        num += 1
    
    #print_vector(numbers)


def print_vector(vec: list[int]):
    print("[", end="")     
    
    for i in range(2, len(vec)):
         if (vec[i] == 0):
            print("%d " % i, end="")     
    
    print("\b]")


def main():
    if (len(sys.argv) != 2):
        print("usage: python find_primes.py final_number")
        exit()

    find_primes(int(sys.argv[1]))

if __name__ == "__main__":
    main()

