// Encontra os primos até N
// Utiliza o algoritmo Sieves of Eratosthenes
// https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes

function find_primes(n) {
    let numbers = new Array();
    for (let i = 0; i < n+1; i++) {
        numbers.push(0) // numbers[i] = 0
    }
    
    let num = 2;

    while (num < n/2) {//Math.sqrt(n) + 1) { // num < n/2?
        if (numbers[num] == 0) {
            let multi = num*2;//num;
            while (multi < n+1) {
                numbers[multi] = 1;
                multi += num;
            }
        }
        num += 1;
    }

    //print_vector(numbers);
}

function print_vector(vec) {
    process.stdout.write("[");
    
    for (let i = 2; i < vec.length; i++) {
        if (vec[i] == 0)
            process.stdout.write(i + " ");
    }    
    
    process.stdout.write("\b]\n");
}


function main() {
    if (process.argv.length != 3) {
         console.log("usage: node find_primes.js final_number\n");
         return;
    }
    find_primes(parseInt(process.argv[2]))
}

if (require.main == module) {
    main()
}