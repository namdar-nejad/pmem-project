
# reate the logical device /dev/pmem on PMEM
ndctl create-namespace -v -m fsdax -n "test_pmem_device"  -M dev -t pmem

# format the new logical PMEM partition with the ext4
sudo mkfs.ext4 /dev/pmem0

# create new dir to test on
mkdir ./test_mount

# mount new dir on new logical PMEM partition
sudo mount -o dax /dev/pmem0 ./test_mount

# print results
sudo mount -v | grep ./test_mount
