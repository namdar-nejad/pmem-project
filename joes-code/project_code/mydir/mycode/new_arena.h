// this file has been modified to work with pmem_allocator
// for more information refer to the memkind manual page:
// http://memkind.github.io/memkind/man_pages/pmemallocator.html

#pragma once
#include <assert.h>
#include <stdint.h>
#include <cerrno>
#include <cstddef>
#include <vector>
#include "memory/allocator.h"
#include "util/mutexlock.h"
#include <iostream>
#include <pmem_allocator.h>


// max size of the temporary file created by memkind on the PMEM
#define PMEM_MAX_SIZE (1024 * 1024 * 1024)

// absolute path to DAX-enabled directory mounted on top a pmem logical device (/dev/pmem{N})
// refer to "file_system_setup.md" for more information
#define DIR_PATH getenv("MEM_PMEM_PATH")


namespace ROCKSDB_NAMESPACE {

class Arena : public Allocator {
 public:
  Arena(const Arena&) = delete;
  void operator=(const Arena&) = delete;

  static const size_t kInlineSize = 2048;
  static const size_t kMinBlockSize;
  static const size_t kMaxBlockSize;

  explicit Arena(size_t block_size = kMinBlockSize,
          AllocTracker* tracker = nullptr, size_t huge_page_size = 0);

  char* Allocate(size_t bytes) override;

  char* AllocateAligned(size_t bytes, size_t huge_page_size = 0,
                        Logger* logger = nullptr) override;

  size_t ApproximateMemoryUsage() const {
    return blocks_memory_ + blocks_.capacity() * sizeof(char*) -
           alloc_bytes_remaining_;
  }

  size_t MemoryAllocatedBytes() const { return blocks_memory_; }
  size_t AllocatedAndUnused() const { return alloc_bytes_remaining_; }
  size_t IrregularBlockNum() const { return irregular_block_num; }
  size_t BlockSize() const override { return kBlockSize; }
  bool IsInInlineBlock() const { return blocks_.empty();}

 private:

  char inline_block_[kInlineSize] __attribute__((__aligned__(alignof(max_align_t))));

  const size_t kBlockSize;

  // max size of the temporary file created by memkind on the PMEM
  const size_t pmem_max_size = PMEM_MAX_SIZE;

  // absolute path to DAX-enabled directory mounted on top a pmem logical device (/dev/pmem{N})
  // refer to "file_system_setup.md" for more information
  const char *pmem_directory = DIR_PATH;

  // creating a allocator to allocate persistent memory
  libmemkind::pmem::allocator<char*> alcvec{pmem_directory, pmem_max_size};

  // use PMEM allocator create to allocate a vector used later on by the memtable
  std::vector<char*, libmemkind::pmem::allocator<char*>> blocks_{alcvec};
  
  struct MmapInfo {
    void* addr_;
    size_t length_;

    MmapInfo(void* addr, size_t length) : addr_(addr), length_(length) {}
  };

  std::vector<MmapInfo> huge_blocks_;

  size_t irregular_block_num = 0;

  size_t alloc_bytes_remaining_ = 0;

  char* AllocateNewBlock(size_t block_bytes);

  size_t blocks_memory_ = 0;
  AllocTracker* tracker_;
};

inline char* Arena::Allocate(size_t bytes) {
  if(bytes > 1) {
    return nullptr;
  }
  return nullptr;
}

extern size_t OptimizeBlockSize(size_t block_size);

}
