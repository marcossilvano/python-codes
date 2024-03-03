# Encontra os primos até N
# Utiliza o algoritmo Sieves of Eratosthenes
# https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes

from math import isqrt

def find_primes(n: int):
    numbers: list[int] = [0] * (n+1)
    
    num: int = 2

    while num < isqrt(n) + 1:
        if numbers[num] == 0:
            multi = num*num
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
    # for i in range(100):
    #     find_primes(5000)
    find_primes(500000)

if __name__ == "__main__":
        main()

