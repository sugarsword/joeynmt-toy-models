#! /usr/bin/python3

import argparse
import matplotlib.pyplot as plt
import numpy as np


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--beam_size', type=str, help='input file for beam_size', required=True)
    parser.add_argument('--score', type=str, help='input file for BLEU score', required=True)
    parser.add_argument('--time', type=str, help='input file for translation and evaluation time', required=True)
    parser.add_argument('--graph', type=str, help='output graph name', required=True)
    args = parser.parse_args()
    return args


def main():
    args = parse_args()
    
    x = np.loadtxt(args.beam_size)
    y1 = np.loadtxt(args.score)
    y2 = np.loadtxt(args.time)

    fig, ax1 = plt.subplots()

    color = 'tab:olive'
    ax1.set_xlabel('Beam Size')
    ax1.set_ylabel('BLEU score', color=color)
    ax1.plot(x, y1, marker='o', color=color)
    ax1.tick_params(axis='y', labelcolor=color)

    ax2 = ax1.twinx()  # instantiate a second axes that shares the same x-axis

    color = 'tab:purple'
    ax2.set_ylabel('Evaluation time', color=color)  # we already handled the x-label with ax1
    ax2.plot(x, y2, marker='o', color=color)
    ax2.tick_params(axis='y', labelcolor=color)

    fig.tight_layout()  # otherwise the right y-label is slightly clipped
    plt.savefig(args.graph)


if __name__ == main():
    main()
