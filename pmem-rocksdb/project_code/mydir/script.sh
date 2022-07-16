# !/bin/bash

if [[ -d "./results" ]];
	then rm -Rf "./results"
fi

if [[ -d "./copied_code" ]];
	then rm -Rf "./copied_code"
fi

# setup env vars
export MEM_PMEM_PATH=$1
export BLOCK_PMEM_PATH=$2

if [[ $# -ne 2 ]]; then
	export MEM_PMEM_PATH="/tmp/"
	export BLOCK_PMEM_PATH="/tmp/"
fi

# create a dir to store the benchmark results
mkdir results
mkdir copied_code

# change memkind_kmem_allocator.cc files
mv -f ../rocksdb/memory/memkind_kmem_allocator.cc ./copied_code/memkind_kmem_allocator.cc 
cp -f ./mycode/new_memkind_kmem_allocator.cc ../rocksdb/memory/memkind_kmem_allocator.cc

# build db_bench
cd ../rocksdb
EXTRA_CXXFLAGS="-I/usr/local/include" EXTRA_LDFLAGS="-L/usr/local/lib" make -j db_bench
cd ../mydir

# benchmarks for both in DRAM and block cache in PMEM
python3 ./bench_scripts/bench_script_1.py

# change the arena.h, arena.cc, and memtable.cc to enable PMEM allocation for memtable
mv -f ../rocksdb/memory/arena.h ./copied_code
mv -f ../rocksdb/memory/arena.cc ./copied_code
mv -f ../rocksdb/db/memtable.cc ./copied_code
cp ./mycode/new_arena.h ../rocksdb/memory/arena.h
cp ./mycode/new_arena.cc ../rocksdb/memory/arena.cc
cp ./mycode/new_memtable.cc ../rocksdb/db/memtable.cc

# build db_bench
cd ../rocksdb/
EXTRA_CXXFLAGS="-I/usr/local/include" EXTRA_LDFLAGS="-L/usr/local/lib" make -j db_bench
cd ../mydir/

# benchmark for memtable in PMEM
python3 ./bench_scripts/bench_script_2.py

# move original files back
mv -f ./copied_code/arena.h ../rocksdb/memory/arena.h
mv -f ./copied_code/arena.cc ../rocksdb/memory/arena.cc
mv -f ./copied_code/memtable.cc ../rocksdb/db/memtable.cc
mv -f ./copied_code/memkind_kmem_allocator.cc ../rocksdb/memory/memkind_kmem_allocator.cc

# build code
cd ../rocksdb/
EXTRA_CXXFLAGS="-I/usr/local/include" EXTRA_LDFLAGS="-L/usr/local/lib" make -j db_bench
cd ../mydir/

# clean env varibles
unset MEM_PMEM_PATH
unset BLOCK_PMEM_PATH
rm -rf "./copied_code"

printf "\n\n ----- Done Benchmarking ----- \n"
printf " See results in ./mydir/results/ \n\n"