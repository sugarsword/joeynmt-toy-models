#! /usr/bin/python3   #adapted from special_subsample in ex4 branch

import random
import argparse
import logging


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--src-input", type=str, help="Source lines input", required=True)
    parser.add_argument("--trg-input", type=str, help="Target lines input", required=True)

    parser.add_argument("--src-output", type=str, help="Source lines output", required=True)
    parser.add_argument("--trg-output", type=str, help="Target lines output", required=True)

    parser.add_argument("--size", type=int, help="Subsample to this many lines", required=True)
    parser.add_argument("--seed", type=int, help="Random seed", required=False, default=13)

    parser.add_argument("--memory-efficient", action="store_true", help="Use less memory (much slower)",
                        required=False, default=False)

    args = parser.parse_args()

    return args


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    random.seed(args.seed)

    num_lines = sum(1 for _ in open(args.src_input, "r"))
    assert num_lines >= args.size

    random_indexes = random.sample(range(num_lines), args.size)
    random_indexes.sort()

    with open(args.src_input, "r") as src_input_handle, open(args.src_output, "w") as src_output_handle:
        src_lines = src_input_handle.readlines()

        for random_index in random_indexes:
            src_line = src_lines[random_index]
            src_output_handle.write(src_line)

    del src_lines

    with open(args.trg_input, "r") as trg_input_handle, open(args.trg_output, "w") as trg_output_handle:
        trg_lines = trg_input_handle.readlines()

        for random_index in random_indexes:
            trg_line = trg_lines[random_index]
            trg_output_handle.write(trg_line)

    del trg_lines

if __name__ == '__main__':
        main()

