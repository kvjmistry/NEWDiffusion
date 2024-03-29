#!/usr/env/python
import os
import sys
import glob
import argparse

from functools import reduce

import tables as tb


def is_leaf(node):
    return not isinstance(node, tb.Group)


def is_indexed_table(node):
    return isinstance(node, tb.Table) and node.indexed


parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input-folder", type=os.path.abspath)
parser.add_argument("-o", "--output-file" , type=os.path.abspath, default="merged.h5")
parser.add_argument("--overwrite"   , action="store_true")
parser.add_argument("--ignore-empty", action="store_true")
parser.add_argument("-f", "--file-wildcard", type=os.path.abspath, nargs='*')

args = parser.parse_args(sys.argv[1:])

# Input folder given
if (args.input_folder != None):
    first, *rest = sorted(glob.glob(os.path.join(args.input_folder, "*")))

# File wildcard given
if (args.file_wildcard != None):
    first, *rest = sorted(args.file_wildcard)

print(first)
print("")
print(rest)

tb.copy_file(first, args.output_file, overwrite=args.overwrite)

to_index = {}
with tb.open_file(args.output_file, "a") as h5out:
    for filename in rest:
        print(filename)
        with tb.open_file(filename) as h5in:
            for node_out in filter(is_leaf, h5out.walk_nodes()):
                path_tokens = node_out._v_pathname.split("/")[1:]
                try:
                    node_in = reduce(getattr, path_tokens, h5in.root)
                except tb.exceptions.NoSuchNodeError:
                    if   args.ignore_empty: continue
                    else                  : raise

                node_out.append(node_in[:])

                if is_indexed_table(node_in):
                    to_index[node_out] = node_in.indexedcolpathnames

    for node, columns in to_index.items():
        for column in columns:
            node.colinstances[column].create_index()

    h5out.flush() # crashes without explicitly flushing
