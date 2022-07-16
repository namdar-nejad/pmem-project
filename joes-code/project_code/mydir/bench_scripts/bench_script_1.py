import os

COMMANDS = []
APPENDIX = []

LD_LIBRARY_PATH = "/usr/local/lib"

Default_options = [ "--benchmarks=readrandomwriterandom", "--value_size=1024", "--readwritepercent=50", "--use_existing_db=0", "--histogram=1", "--statistics=1", "--stats_interval=1000", "--read_random_exp_range=0.0", "--max_write_buffer_number=1", "--db_write_buffer_size=0", "--memtable_use_huge_page=true", "--skip_list_lookahead=100", "--enable_pipelined_write=false", "--allow_concurrent_memtable_write=false", "--write_buffer_size=10485760", "--num=10000"]


def build_command(options, use_default, out_file):
    
    command = ""
    command += "LD_LIBRARY_PATH=" + LD_LIBRARY_PATH+" ../rocksdb/db_bench"
    
    if use_default:
        for i in Default_options:
            if not (len(i.split()) == 1):
                print("Didn't include [ " + i + " ]")
            else:
                command += " " + i.split()[0]
                
    for i in options:
        if not (len(i.split()) == 1):
                print("Didn't include [ " + i + " ]")
        else:
                command += " " + i.split()[0]
                
    command += " > " + out_file
    
    APPENDIX.append(out_file + "   --->   " + command) 
    
    COMMANDS.append(command)

def run():
    for i in COMMANDS:
        print(i)
        os.system(i)
    write_appendix()


def build_final():
    global COMMANDS
    COMMANDS=[]
    APPENDIX=[]

    for i in [x for x in (2**p for p in range(4))]:
        build_command(["--key_size=8", "--threads="+str(i)], True, "./results/K8_T"+str(i)+"_none.txt")
        build_command(["--key_size=16", "--threads="+str(i)], True, "./results/K16_T"+str(i)+"_none.txt")
        build_command(["--key_size=8", "--threads="+str(i), "--use_cache_memkind_kmem_allocator"], True, "./results/K8_T"+str(i)+"_cache.txt")
        build_command(["--key_size=16", "--threads="+str(i), "--use_cache_memkind_kmem_allocator"], True, "./results/K16_T"+str(i)+"_cache.txt")


def write_appendix():
    f = open("./results/appendix.txt", "w")
    
    for i in APPENDIX:
        f.write(i + "\n \n")
        
    f.close()


def main():
    build_final()
    run()


if __name__ == '__main__':
    main()



