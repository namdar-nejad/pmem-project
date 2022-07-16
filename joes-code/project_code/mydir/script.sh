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
EXTRA_CXXFLAGS="-I/usr/local/include" EXTRA_LDFLAGS="-L/usr/local/lib" make -j5 db_bench
cd ../mydir

# benchmarks for both in DRAM and block cache in PMEM
sudo pcm-memory 1 |& tee /mnt/changjun/result/testset14/K16_T16_R50_none_monitor.txt & pid=$!; LD_LIBRARY_PATH=/usr/local/lib ../rocksdb/db_bench --benchmarks=readrandomwriterandom --value_size=1024 --disable_wal=true --cache_size=2120000  --compression_ratio=1 --readwritepercent=50 --use_existing_db=0 --histogram=1 --statistics=1 --read_random_exp_range=0.0 --max_write_buffer_number=1  --memtable_use_huge_page=true --enable_pipelined_write=false --allow_concurrent_memtable_write=false --write_buffer_size=1024000000 --num=1000000000 --duration=900 --stats_interval_seconds=1 --key_size=16 --threads=16 |& tee /mnt/changjun/result/testset14/K16_T16_R50_none.txt; sudo kill $pid
sudo pcm-memory 1 |& tee /mnt/changjun/result/testset14/K16_T16_R90_none_monitor.txt & pid=$!; LD_LIBRARY_PATH=/usr/local/lib ../rocksdb/db_bench --benchmarks=readrandomwriterandom --value_size=1024 --disable_wal=true --cache_size=2120000  --compression_ratio=1 --readwritepercent=90 --use_existing_db=0 --histogram=1 --statistics=1 --read_random_exp_range=0.0 --max_write_buffer_number=1  --memtable_use_huge_page=true --enable_pipelined_write=false --allow_concurrent_memtable_write=false --write_buffer_size=1024000000 --num=1000000000 --duration=900 --stats_interval_seconds=1 --key_size=16 --threads=16 |& tee /mnt/changjun/result/testset14/K16_T16_R90_none.txt; sudo kill $pid
sudo pcm-memory 1 |& tee /mnt/changjun/result/testset14/K16_T16_R1_none_monitor.txt & pid=$!; LD_LIBRARY_PATH=/usr/local/lib ../rocksdb/db_bench --benchmarks=readrandomwriterandom --value_size=1024 --disable_wal=true --cache_size=2120000  --compression_ratio=1 --readwritepercent=1 --use_existing_db=0 --histogram=1 --statistics=1 --read_random_exp_range=0.0 --max_write_buffer_number=1  --memtable_use_huge_page=true --enable_pipelined_write=false --allow_concurrent_memtable_write=false --write_buffer_size=1024000000 --num=1000000000 --duration=900 --stats_interval_seconds=1 --key_size=16 --threads=16 |& tee /mnt/changjun/result/testset14/K16_T16_R1_none.txt; sudo kill $pid

sudo pcm-memory 1 |& tee /mnt/changjun/result/testset14/K16_T16_R50_cache_monitor.txt & pid=$!; LD_LIBRARY_PATH=/usr/local/lib ../rocksdb/db_bench --benchmarks=readrandomwriterandom --value_size=1024 --disable_wal=true --cache_size=2120000  --compression_ratio=1 --readwritepercent=50 --use_existing_db=0 --histogram=1 --statistics=1 --read_random_exp_range=0.0 --max_write_buffer_number=1  --memtable_use_huge_page=true --enable_pipelined_write=false --allow_concurrent_memtable_write=false --write_buffer_size=1024000000 --num=1000000000 --duration=900 --stats_interval_seconds=1 --key_size=16 --threads=16 --use_cache_memkind_kmem_allocator |& tee /mnt/changjun/result/testset14/K16_T16_R50_cache.txt; sudo kill $pid
sudo pcm-memory 1 |& tee /mnt/changjun/result/testset14/K16_T16_R90_cache_monitor.txt & pid=$!; LD_LIBRARY_PATH=/usr/local/lib ../rocksdb/db_bench --benchmarks=readrandomwriterandom --value_size=1024 --disable_wal=true --cache_size=2120000  --compression_ratio=1 --readwritepercent=90 --use_existing_db=0 --histogram=1 --statistics=1 --read_random_exp_range=0.0 --max_write_buffer_number=1  --memtable_use_huge_page=true --enable_pipelined_write=false --allow_concurrent_memtable_write=false --write_buffer_size=1024000000 --num=1000000000 --duration=900 --stats_interval_seconds=1 --key_size=16 --threads=16 --use_cache_memkind_kmem_allocator |& tee /mnt/changjun/result/testset14/K16_T16_R90_cache.txt; sudo kill $pid
sudo pcm-memory 1 |& tee /mnt/changjun/result/testset14/K16_T16_R1_cache_monitor.txt & pid=$!; LD_LIBRARY_PATH=/usr/local/lib ../rocksdb/db_bench --benchmarks=readrandomwriterandom --value_size=1024 --disable_wal=true --cache_size=2120000  --compression_ratio=1 --readwritepercent=1 --use_existing_db=0 --histogram=1 --statistics=1 --read_random_exp_range=0.0 --max_write_buffer_number=1  --memtable_use_huge_page=true --enable_pipelined_write=false --allow_concurrent_memtable_write=false --write_buffer_size=1024000000 --num=1000000000 --duration=900 --stats_interval_seconds=1 --key_size=16 --threads=16 --use_cache_memkind_kmem_allocator |& tee /mnt/changjun/result/testset14/K16_T16_R1_cache.txt; sudo kill $pid

# change the arena.h, arena.cc, and memtable.cc to enable PMEM allocation for memtable
mv -f ../rocksdb/memory/arena.h ./copied_code
mv -f ../rocksdb/memory/arena.cc ./copied_code
mv -f ../rocksdb/db/memtable.cc ./copied_code
cp ./mycode/new_arena.h ../rocksdb/memory/arena.h
cp ./mycode/new_arena.cc ../rocksdb/memory/arena.cc
cp ./mycode/new_memtable.cc ../rocksdb/db/memtable.cc

# build db_bench
cd ../rocksdb/
EXTRA_CXXFLAGS="-I/usr/local/include" EXTRA_LDFLAGS="-L/usr/local/lib" make -j5 db_bench
cd ../mydir/

# benchmark for memtable in PMEM
sudo pcm-memory 1 |& tee /mnt/changjun/result/testset14/K16_T16_R50_both_monitor.txt & pid=$!; LD_LIBRARY_PATH=/usr/local/lib ../rocksdb/db_bench --benchmarks=readrandomwriterandom --disable_wal=true --cache_size=2120000  --compression_ratio=1 --value_size=1024 --readwritepercent=50 --use_existing_db=0 --histogram=1 --statistics=1 --read_random_exp_range=0.0 --max_write_buffer_number=1  --memtable_use_huge_page=true --enable_pipelined_write=false --allow_concurrent_memtable_write=false --write_buffer_size=1024000000 --num=1000000000 --duration=900 --stats_interval_seconds=1 --key_size=16 --threads=16 --use_cache_memkind_kmem_allocator |& tee /mnt/changjun/result/testset14/K16_T16_R50_both.txt; sudo kill $pid
sudo pcm-memory 1 |& tee /mnt/changjun/result/testset14/K16_T16_R90_both_monitor.txt & pid=$!; LD_LIBRARY_PATH=/usr/local/lib ../rocksdb/db_bench --benchmarks=readrandomwriterandom --disable_wal=true --cache_size=2120000  --compression_ratio=1 --value_size=1024 --readwritepercent=90 --use_existing_db=0 --histogram=1 --statistics=1 --read_random_exp_range=0.0 --max_write_buffer_number=1  --memtable_use_huge_page=true --enable_pipelined_write=false --allow_concurrent_memtable_write=false --write_buffer_size=1024000000 --num=1000000000 --duration=900 --stats_interval_seconds=1 --key_size=16 --threads=16 --use_cache_memkind_kmem_allocator |& tee /mnt/changjun/result/testset14/K16_T16_R90_both.txt; sudo kill $pid
sudo pcm-memory 1 |& tee /mnt/changjun/result/testset14/K16_T16_R1_both_monitor.txt & pid=$!; LD_LIBRARY_PATH=/usr/local/lib ../rocksdb/db_bench --benchmarks=readrandomwriterandom --disable_wal=true --cache_size=2120000  --compression_ratio=1 --value_size=1024 --readwritepercent=1 --use_existing_db=0 --histogram=1 --statistics=1 --read_random_exp_range=0.0 --max_write_buffer_number=1  --memtable_use_huge_page=true --enable_pipelined_write=false --allow_concurrent_memtable_write=false --write_buffer_size=1024000000 --num=1000000000 --duration=900 --stats_interval_seconds=1 --key_size=16 --threads=16 --use_cache_memkind_kmem_allocator |& tee /mnt/changjun/result/testset14/K16_T16_R1_both.txt; sudo kill $pid

# move original files back
mv -f ./copied_code/arena.h ../rocksdb/memory/arena.h
mv -f ./copied_code/arena.cc ../rocksdb/memory/arena.cc
mv -f ./copied_code/memtable.cc ../rocksdb/db/memtable.cc	
mv -f ./copied_code/memkind_kmem_allocator.cc ../rocksdb/memory/memkind_kmem_allocator.cc

# build code
cd ../rocksdb/
EXTRA_CXXFLAGS="-I/usr/local/include" EXTRA_LDFLAGS="-L/usr/local/lib" make -j5 db_bench
cd ../mydir/

# clean env varibles
unset MEM_PMEM_PATH
unset BLOCK_PMEM_PATH
rm -rf "./copied_code"

printf "\n\n ----- Done Benchmarking ----- \n"
printf " See results in ./mydir/results/ \n\n"
