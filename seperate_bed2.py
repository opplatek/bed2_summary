#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import bb_basic as bb


def main():
    print_help()
    dict_files = []
    dir_out = sys.argv[3].rstrip("/") + "/"
    for l in bb.fun_open_file(sys.argv[2], "r"):
        line = l.strip().split()
        dict_files[line[1]] = bb.fun_open_file(dir_out+line[1]+".bed2", "w")
    for l in bb.fun_open_file(sys.argv[1], "r"):
        line = l.strip().split()
        dict_files[line[3]].write(l)
    for key in dict_files:
        dict_files[key].close()


# --------functions--------
def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", action="version", version="%(prog)s 1.0")
    parser.add_argument("args", help="", nargs="*")
    args = parser.parse_args()
    return args


def print_help():
    if len(sys.argv) < 2:
        bb.fun_print_help("in.bed2", "in.feature.bed", "out.dir")

# --------process--------
if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        bb.fun_print_error("user interrupted, abort!")
        sys.exit(0)