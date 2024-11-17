// Encontra os primos até N
// Utiliza o algoritmo Sieves of Eratosthenes
// https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes

#include <iostream>
#include <cmath>

using namespace std;

void print_vector(int vec[], int n);

void find_primes(int n) {
    int* numbers = new int[n+1]();
    
    int num = 2;

    while (num < n/2) {//(int)sqrt(n) + 1) { // num < n/2?
        if (numbers[num] == 0) {
            int multi = num*2;//num;
            while (multi < n+1) {
                numbers[multi] = 1;
                multi += num;
            }
        }
        num += 1;
    }

    //print_vector(numbers, n+1);
    delete[] numbers;
}

void print_vector(int vec[], int n) {
    printf("[");
    
    for (int i = 2; i < n; i++) {
        if (vec[i] == 0)
            printf("%d ", i) ;
    }    
    
    printf("\b]\n");
}


int main(int argc, char* argv[]) {
    if (argc != 2) {
        printf("usage: find_primes final_number\n");
        return 1;
    }

    find_primes(atoi(argv[1]));

    return 0;
}

