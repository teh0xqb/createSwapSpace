#!/usr/bin/env ruby




# ------------------------------ Add swap script -------------------------------
# Author: Joel Quiles
# Dependencies: Ruby 1.9.x



# ---------------------------------- Imports -----------------------------------
require 'sys/filesystem'


puts "Swap creation script."


# ---------------------------- GLOBAL HELPER FUNS ------------------------------
def checkSuccess
	result = $?
  if result.exitstatus != 0
		puts "Error code #{result.exitstatus} in running last command. Aborting script."
		puts "Called by #{caller(0)}"
		exit 100
	end
end

def errorExit(exitCode)
	return nil # for now
	return exit exitCode
end



# -------------------------------- START SCRIPT --------------------------------


totalLinesForSwap = `swapon -s | wc -l`              # swapon shows total swap space allocated
# If swapon output is just one line, there is not swap space being used
puts "Current lines on swapon file: #{totalLinesForSwap}"


if totalLinesForSwap.to_i > 1 or File.directory?("/swapfile")
	puts "Swap space has already been allocated for this environment"
	errorExit 1
end

checkSuccess

# Check the results of the free -m command, to see how much memory there is, plus to double-check swap
output = `free -m`

checkSuccess

swapWord = output.split(" ")[17]
totalSwap = output.split(" ")[18]

if swapWord != "Swap:"
	puts "Free output in an unexpeted format"
	errorExit 2
end

puts "Total swap: #{totalSwap}"

puts "Let's verify that there is enough space on drive to add swap space"

stat = Sys::Filesystem.stat("/")
gb_available = stat.block_size * stat.blocks_available / 1024 / 1024 / 1024

puts gb_available.to_s + "G"

if gb_available > 10
	puts "Enough disk space available to allocate 4G of swap space"
else
	puts "Less than 10G available, won't allocate swap space."
	errorExit 3
end

checkSuccess

# Create file for allocate swap space
# `fallocate -l 4G /swapfile`

checkSuccess

# Add correct rights to swap file
# `chmod 600 /swapfile`

# Tell system this newly allocated should be of type swap
#  `mkswap /swapfile`

checkSuccess

# Actually tell environment to use is swap!
#  `swapon /swapfile`

checkSuccess

# Verify that swapon's new output contains the right swap params

totalLinesForSwap = `swapon -s | wc -l`              # swapon shows total swap space allocated
# If swapon output is just one line, there is not swap space being used
puts "Current lines from swapon -s, after swap creation: #{totalLinesForSwap}"

if totalLinesForSwap.to_i != 1
	errorExit 4
end

# TODO: double check free to see that there is actually swap here
output = `free -m`

checkSuccess

totalSwap = output.split(" ")[18]
puts "Total swap: #{totalSwap}"

if totalSwap.to_i == 0
	errorExit 5
end

# TODO: Make the Swap File Permanent

# Append the following line:
# /swapfile   none    swap    sw    0   0
# to this file: /etc/fstab

# TODO: verify swapiness of swap space (on kernel)

# cat /proc/sys/vm/swappiness

# TODO: set swapiness of system

#  sysctl vm.swappiness=10

# TODO: check that this variable `vm.swappiness` is not set in `/etc/sysctl.conf` file

# TODO: Add the swappines to /etc/sysctl.conf to make swapiness permanent on next boot

# vm.swappiness=10

# TODO: verify the swap cache pressue
# cat /proc/sys/vm/vfs_cache_pressure... is it 100? 50? should be 50...

# TODO: if cache pressure is not 50, set to 50:

#  sysctl vm.vfs_cache_pressure=50

# TODO: verify that the pressure is not set in /etc/sysctl.conf
# vm.vfs_cache_pressure?

# TODO: if it isnt' set:

# vm.vfs_cache_pressure = 50 # in that file
