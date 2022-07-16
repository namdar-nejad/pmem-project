
// this file has been modified to work with memkind
// for more information refer to the memkind manual page:
// http://memkind.github.io/memkind/man_pages/memkind.html

#ifdef MEMKIND

#include "memkind_kmem_allocator.h"
#include <iostream>
#include <stdlib.h>

// max size of the temporary file created by memkind on the PMEM
#define PMEM_MAX_SIZE (1024 * 1024 * 32)

// absolute path to DAX-enabled directory mounted on top a pmem logical device (/dev/pmem{N})
// set to the env value of PMEM_PATH
// set to "/tmp/" if PMEM_PATH has not been set
// refer to "file_system_setup.md" for more information
#define DIR_PATH getenv("BLOCK_PMEM_PATH")

// setting up PMEM partition, global pointer held in pmem_kind
struct memkind *pmem_kind = NULL;
int err = memkind_create_pmem(DIR_PATH, PMEM_MAX_SIZE, &pmem_kind);


// function to print memkind related error messages
static void print_err_message(int err_num){
    char error_message[MEMKIND_ERROR_MESSAGE_SIZE];
    memkind_error_message(err_num, error_message, MEMKIND_ERROR_MESSAGE_SIZE);
    std::cout << error_message << std::endl;
}

static int check_dax(char * dir){
  // checking if the DIR_PATH is DAX-enabled
  int status = memkind_check_dax_path(dir);

  // check if the DIR_PATH is a DAX-enabled file system
  // we can only set up a PMEM partition on a DAX-enabled file system
  if(status){
    std::cout << "[ATTENTION] " << dir << " is not a DAX-enabled file system.\n" << std::endl;
  }

  return status;
}

int status = check_dax(DIR_PATH);

namespace ROCKSDB_NAMESPACE {

void* MemkindKmemAllocator::Allocate(size_t size) {

  // check if the PMEM partition is correctly setup
  if (err) {
    std::cout << "[ERROR] error with memkind_create_pmem(): " << std::endl;
    print_err_message(err);
    // throw std::bad_alloc();
  }

  // allocate space of size bytes in the pmem_kind PMEM space
  void* p = memkind_malloc(pmem_kind, size);

  // check if the space is correctly allocated
  if (p == NULL) {
    std::cout << "Unable to allocate pmem space: " << std::endl;
    throw std::bad_alloc();
  }
  return p;
}

void MemkindKmemAllocator::Deallocate(void* p) {

  // deallocate space used for pointer p, from the PMEM partition
	memkind_free(pmem_kind, p);
}

#ifdef ROCKSDB_MALLOC_USABLE_SIZE
size_t MemkindKmemAllocator::UsableSize(void* p,
                                        size_t /*allocation_size*/) const {

	size_t rtn = memkind_malloc_usable_size(pmem_kind, p);

  return rtn;
}
#endif  // ROCKSDB_MALLOC_USABLE_SIZE

}  // namespace ROCKSDB_NAMESPACE
#endif  // MEMKIND


