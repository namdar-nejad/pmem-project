# **Introducing Persistent Memory to LSM-tree based Key-Value stores**

In the following sections I'll be giving a breif overview of the programming that I have done for this project. This reposotory also contains other recourses related to the project for example the benchmarking results, graphs, and the writen project report.
The coding that I have done is a bit hard to explain in a README file. If there is anything vague about my work please feel free to get in touch with me.


# Steps to run benchmarks

 1. **Clone the rocksdb** code into the **project directory**, if not done already.

    ``` git clone --branch memkind_kmem_allocator_build_fix https://github.com/lucagiac81/rocksdb.git```

2. **Check directory tree** after cloning rocksdb to make sure the rocksdb directory is in the correct place.
    **mydir & rocksdb** should be under the same directory **project_code**
```
    project_code
    │ 
    └─── mydir 
    │ 
    └─── rocksdb
```

3. Run **script.sh** in mydir:
		
 - [ ] cd to mydir
 - [ ] chmod +x script.sh
 - [ ] run ./script.sh: ./script <optional_memtable_pmem_filesystem_path> <optional_blockcache_pmem_filesystem_path>
(more on the optional parameters in the next section)
4. Check the results:
	after the scripts.sh is completed, the results dir in the mydir directory contains the benchmark results.

Check out `@discslab-server1:/data/namdar_ROCKSDB` to see the version I used.

# Structure of the Code
```
	|__ mydir
		|
		|__ mycode
		|__ bench_scripts
		|__ script.sh
```

```
mydir
│   script.sh
└─── mycode
│   │   new_arena.cc
│   │   new_arena.h
│   │   new_memkind_kmem_allocator.cc
│   │   new_memtable.cc
│   │	partition.sh
│   
└─── bench_scripts
|	| 	bench_script_1.py
│   │	bench_script_2.py
```
	
# mydir

directory that contains all the coding that I have done

## mycode

This directory contains the codes that I have written related to RockDB
	

 - The files starting with "new_" are rocksdb files that I have edited
- partition.sh is an example of a bash script that can be used to create a namespace on the PMEM and mount a file system on it. This is according to [[Intel]](https://corpredirect.intel.com/Redirector/404Redirector.aspx?https://software.intel.com/content/www/us/en/develop/articles/use-memkind-to-manage-volatile-memory-on-intel-optane-persistent-memory.html)

### Important Info on RockDB Code Changes

The complete changes made on the rockdb codes have been comneted in the code files in the mycodes directory.
However it is important to note that I am using environment variables to pass the pmem file paths to arena.h and memkind_kmem_allocator.cc. If you are using the script.sh the paths can be passed to the script but if you are interested in using the script you should set the env variables BLOCK_PMEM_PATH and MEM_PMEM_PATH manually. 

## bench_scripts

This directory contains two python scripts used to run benchmarks. The python scripts build the db_bench options and run them with different key-thread permutations. The scripts also save the results on the benchmarks in the results dir and create the Appendix.txt that contains all the db_bench commands that have been run.

## script.sh

This is a bash script that puts everything together and runs all the code. The bash script runs the benchmarking for all three (none, cache, and both) scenarios. The script.sh manages to do this by swapping the new code files in ./mycode with the old code in the rocksdb files for each scenario. After the script.sh is run a result dir will be created that contains the benchmarks, the appendix.txt of the results shows what exact commands have been used for each result file created in the directory. After the benchmarks have been completed the script will replace the rocksdb original codes and leave the environment as it was before.
The scripts takes in two optional arguments, <optional_memtable_pmem_filesystem_path> <optional_blockcache_pmem_filesystem_path>. Both arguments are paths to a DAX-enabled file system mounted on a PMEM partition to use to allocate space for the rocksdb data structures, the first is the path for memtable and the second for the block cache. If the arguments are not provided the paths will default to "/tmp/".


# Other Folders

```
project
|__ results
|__ plot.py
|__ graphs
|-- paper.pdf
	|__ mydir
		|
		|__ mycode
		|__ bench_scripts
		|__ script.sh

	|__ rocksdb
	
```
## paper.pdf
Project Report (Reaserch Paper)

## plot.py
This is a very simple python script that I used to create graphs from the results directory.
## result
A directory contaning the results that I got from the benchmarking, these are the results that I used in the project report.

## graphs
A dircetoy contaning system latancy and throuput and read, write latancy graphs of the benchmark results.
