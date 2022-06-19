#!/usr/bin/env python3
#
# https://github.com/dmuth/tarsplit
#
# This script will take a tarball and split it into 2 or more parts.
# Most importantly, these parts WILL BE ALONG FILE BOUNDARIES.
# The reason for splitting along file foundaries is to that extraction
# can be done with plain old tar.
#
# The advantage of this approach is that things like larger Docker images can
# now be broken down into smaller layers, which each layer extracting a subset
# of the original tarball's directory structure.
#
#


import argparse
import os
import tarfile

import humanize
from tqdm import tqdm


parser = argparse.ArgumentParser(description = "Split up a tarball into 2 more chunks of roughly equal size.")
parser.add_argument("file", type = str,
	help = "The tarball to split up")
parser.add_argument("num", type = int, 
	help = "How many chunks to split into?")
parser.add_argument("--dry-run", action = "store_true",
	help = "Perform a dry run and tell what we WOULD do.")

args = parser.parse_args()
#print(args) # Debugging

#
# Check our arguments.
#
def check_args(args):
	if args.num < 2:
		raise ValueError("Number of chunks cannot be less than 2!")


#
# Calculate the size per chunk.
# This is based on uncompressed values, the resulting tarballs may vary in size.
#
def get_chunk_size(t, num):

	total_file_size = 0
	for f in t.getmembers():
		total_file_size += f.size

	retval = (total_file_size, int(total_file_size / args.num))

	return(retval)


#
# Get our filename for a specific part.
#
def open_chunkfile(file, part, num, dry_run = False):

	out = None

	num_len = len(str(num))
	part_formatted = str(part).zfill(num_len)

	filename = f"{os.path.basename(file)}-part-{part_formatted}-of-{num}"
	if not dry_run:
		out = tarfile.open(filename, "w:gz")

	return(filename, out)


#
# Our main entrypoint.
#
def main(args):

	check_args(args)

	t = tarfile.open(args.file, "r")

	print(f"Welcome to Tarsplit! Reading file {args.file}...")
	(total_file_size, chunk_size) = get_chunk_size(t, args.num)

	print(f"Total uncompressed file size: {humanize.naturalsize(total_file_size, binary = True)} bytes, "
		+ f"num chunks: {args.num}, chunk size: {humanize.naturalsize(chunk_size, binary = True)} bytes")

	(filename, out) = open_chunkfile(args.file, 1, args.num, dry_run = args.dry_run)

	size = 0
	current_chunk = 1
	num_files_in_current_chunk = 0

	num_files = len(t.getmembers())
	pbar = tqdm(total = num_files)

	#
	# Loop through our files, and write them out to separate tarballs.
	#
	for f in t.getmembers():

		name = f.name
		size += f.size

		if name[len(name) - 1] == "/":
			print(f"File {name} ends in Slash, skipping due to a bug in the tarfile module. (Directory will still be created by files within that directory)")
			continue

		f = t.extractfile(name)
		info = t.getmember(name)
		if not args.dry_run:
			out.addfile(info, f)

		num_files_in_current_chunk += 1
		pbar.update(1)

		if current_chunk < args.num:
			if size >= chunk_size:

				if not args.dry_run:
					out.close()
					print(f"Successfully wrote {humanize.naturalsize(size, binary = True)}"
						+ f" bytes in {num_files_in_current_chunk} files to {filename}")
				else:
					print(f"Would have written {humanize.naturalsize(size, binary = True)}"
						+ f" bytes in {num_files_in_current_chunk} files to {filename}")

				size = 0
				current_chunk += 1
				num_files_in_current_chunk = 0

				(filename, out) = open_chunkfile(args.file, current_chunk, args.num, 
					dry_run = args.dry_run)

			pbar.set_description(f"Writing split tarfile: {current_chunk} of {args.num}")

	t.close()
	pbar.close()

	if not args.dry_run:
		print(f"Successfully wrote {humanize.naturalsize(size, binary = True)} bytes in"
			+ f" {num_files_in_current_chunk} files to {filename}")
		out.close()
	else:
		print(f"Would have written {humanize.naturalsize(size, binary = True)} bytes in"
			+ f" {num_files_in_current_chunk} files to {filename}")

	print(f"Tarsplit complete on {args.file}!")

main(args)


