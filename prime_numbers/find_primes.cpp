// Encontra os primos até N
// Utiliza o algoritmo Sieves of Eratosthenes
// https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes

#include <iostream>
#include <cmath>

using namespace std;

void print_vector(int vec[], int n);

void find_primes(int n) {
    int numbers[n+1] = {0};
    // for (int i = 0; i < n+1; i++) {
    //     numbers[i] = 0;
    // }    
    
    int num = 2;

    while (num < (int)sqrt(n) + 1) {
        if (numbers[num] == 0) {
            int multi = num*num;
            while (multi < n+1) {
                numbers[multi] = 1;
                multi += num;
            }
        }
        num += 1;
    }

    //print_vector(numbers, n+1);
}

void print_vector(int vec[], int n) {
    printf("[");
    
    for (int i = 2; i < n; i++) {
        if (vec[i] == 0)
            printf("%d ", i) ;
    }    
    
    printf("\b]\n");
}


int main() {
    // for (int i = 0; i < 100; i++)
    //     find_primes(5000);
    find_primes(500000);
}

