import subprocess
import time
import sys
import statistics


def run_process(cmd: str) -> float:
    # proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)

    start_time = time.time()

    subprocess.run(cmd, check=True, shell=True)
    
    # (output, error) = proc.communicate()
    # proc_status = proc.wait()
    
    end_time = time.time()

    return end_time - start_time


def run_tests(lang: str, cmd: str, execs: int, show_results: bool = False):
    print("RUNNING %s PROGRAM" % lang)

    all_times: list[float] = []
    
    for i in range(execs):
        exec_time = run_process(cmd)
        all_times.append(exec_time)

    result = {"total":      sum(all_times), 
              "average":    sum(all_times)/len(all_times),
              "deviation":  statistics.pstdev(all_times), 
              "min":        min(all_times),
              "max":        max(all_times)}

    if show_results:
        print("Total execution time...: %.5fs" % result["total"])
        print("Average execution time.: %.5fs" % result["average"])
        print("Standard deviation.....: %.5fs" % result["deviation"])
        print("Shortest execution time: %.5fs" % result["min"])
        print("Longest execution time.: %.5fs" % result["max"])
        print()

    return result

def main():
    n = len(sys.argv)

    if (n != 2):
        print("usage: python run.py number_of_tests")
        exit()

    # final = int(sys.argv[1])
    final = 5000000
    tests = int(sys.argv[1])

    print("\nPERFORMANCE TEST")
    print("Find all prime numbers up to %d:" % final)
    print("Running %d tests on %s" % (tests, sys.platform))

    # -------------------------------------
    # Setting tests up
    
    print("Compiling...")
    run_process("gcc find_primes.c -o findc -O2 -lm")
    # run_process("clang find_primes.c -o findc -O2 -lm")
    run_process("g++ find_primes.cpp -o findcpp -O2")
    run_process("javac find_primes.java")

    langs = [
        "ASM",    "./x86_asm/prog5.elf %d",
        "Python", "python3 find_primes.py %d",
        "JS",     "node find_primes.js %d",
        "Java",   "java FindPrimes %d",
        "C++",    "./findc %d",
        "C",      "./findcpp %d"
    ]

    res = {}
    for i in range(0, len(langs), 2):
        res[langs[i]] = {}
        res[langs[i]]["cmd"] = langs[i+1]

    if sys.platform == "win32":
        for lang in res:
            res[key]["cmd"].replace("/", "\\") # .exe?

    # -------------------------------------
    # Running all tests
                   
    print("Running tests...\n")

    for lang in res:
        res[lang]["result"] = run_tests(lang, res[lang]["cmd"] % final, tests)    

    # -------------------------------------
    # Displaying execution ratios

    print("\nRATIO OF TOTAL EXECUTION TIME")
    
    align = 7#len("%.3f" % (res["JS"]["result"]["total"]/res["ASM"]["result"]["total"]))

    print("| %*s" % (-align, " "), "|", end="")
    for lang in res:
        print("| %*s" % (-align, lang), "|", end="")
    print()

    for row in res:
        print("| %*s" % (-align, row), "|", end="")
        for col in res:
            if row == col:
                print("| %*s" % (-align, "------"), "|", end="")
            else:
                print("| %*.3f" % (align, res[row]["result"]["total"]/res[col]["result"]["total"]), "|", end="")
        print()


if __name__ == "__main__":
    main()