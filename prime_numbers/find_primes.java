// Encontra os primos até N
// Utiliza o algoritmo Sieves of Eratosthenes
// https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes


class FindPrimes {
    public static void main(String[] args) {
        if (args.length != 1) {
            System.out.println("usage: java FindPrimes final_number\n");
            return;
        }
    
        find_primes(Integer.parseInt(args[0]));
    }

    public static void find_primes(int n) {
        int[] numbers = new int[n+1];
        
        int num = 2;

        while (num < n/2) {//(int)Math.sqrt(n) + 1) { // num < n/2?
            if (numbers[num] == 0) {
                int multi = num*2;//num;
                while (multi < n+1) {
                    numbers[multi] = 1;
                    multi += num;
                }
            }
            num += 1;
        }

        //print_vector(numbers);
    }

    public static void print_vector(int[] vec) {
        System.out.print("[");
        
        for (int i = 2; i < vec.length; i++) {
            if (vec[i] == 0)
                System.out.print(i + " ") ;
        }    
        
        System.out.print("\b]\n");
    }
}