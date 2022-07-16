#include "memory/arena.h"
#ifndef OS_WIN
#include <sys/mman.h>
#endif

#include <algorithm>
#include <iostream>
#include "logging/logging.h"
#include "port/malloc.h"
#include "port/port.h"
#include "rocksdb/env.h"
#include "test_util/sync_point.h"
#include "util/string_util.h"

namespace ROCKSDB_NAMESPACE {

const size_t Arena::kMinBlockSize = 4096;
const size_t Arena::kMaxBlockSize = 2u << 30;
static const int kAlignUnit = alignof(max_align_t);

Arena::Arena(size_t block_size, AllocTracker* tracker, size_t huge_page_size)
    : kBlockSize(block_size), tracker_(tracker) {

  blocks_memory_ += sizeof(inline_block_);

  (void)huge_page_size;
}

char* Arena::AllocateAligned(size_t bytes, size_t huge_page_size, Logger* logger) {

  (void)huge_page_size;
  (void)logger;

  char* result;
  ++irregular_block_num;
  result = AllocateNewBlock(bytes);
  assert((reinterpret_cast<uintptr_t>(result) & (kAlignUnit - 1)) == 0);
  return result;
}

char* Arena::AllocateNewBlock(size_t block_bytes) {

  blocks_.emplace_back(nullptr);
  char* block = new char[block_bytes];
  blocks_memory_ += block_bytes;
  blocks_.back() = block;
  return block;
}

}
