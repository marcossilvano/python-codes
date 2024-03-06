import subprocess
import time
import sys
import statistics


def run_process(cmd: str) -> float:
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)

    start_time = time.time()
    
    (output, error) = proc.communicate()
    proc_status = proc.wait()
    
    finish_time = time.time()

    #print("Command output:", output)
    #print("Execution time:", finish_time - start_time)
    #print("Command exit with code:", proc_status)
    return finish_time - start_time


def run_tests(cmd: str, execs: int):

    all_times: list[float] = []
    
    for i in range(execs):
        exec_time = run_process(cmd)
        all_times.append(exec_time)

    print("Total execution time...: %.3fs" % sum(all_times))
    print("Average execution time.: %.3fs" % (sum(all_times)/len(all_times)))
    print("Standard deviation.....: %.3fs" % statistics.pstdev(all_times))
    print("Shortest execution time: %.3fs" % min(all_times))
    print("Longest execution time.: %.3fs" % max(all_times))


def main():
    n = len(sys.argv)

    if (n != 3):
        print("usage: python run.py final_number number_of_tests")
        exit()

    final = int(sys.argv[1])
    tests = int(sys.argv[2])

    print("\nPERFORMANCE TEST")
    print("Find all prime numbers up to %d:" % final)
    print("Running %d tests on %s" % (tests, sys.platform))

    cmd_cpp = ""
    if sys.platform == "win32":
        cmd_cpp = ".\\a.exe %d"
    elif sys.platform == "linux":
        cmd_cpp = "./a.out %d"
    else:
        return

    print("\nRUNNING PYTHON PROGRAM")
    run_tests("python3 find_primes.py %d" % final, tests)

    print("\nRUNNING C++ PROGRAM")
    run_tests(cmd_cpp % final, tests)


if __name__ == "__main__":
    main();