import pandas as pd
import argparse
import matplotlib.pyplot as plt

def generate_bleu_visualisation(input_file, output_dir):
    data = pd.read_csv(input_file)
    # Create a scatter plot
    plt.figure(figsize=(8, 6))
    plt.scatter(data['Beam size'], data['BLEU'], color='blue', alpha=0.5)
    plt.xticks(range(2, 21, 2)) # set x-axis step

    # Add title and labels
    plt.title('Beam Size vs. BLEU Score')
    plt.xlabel('Beam size')
    plt.ylabel('BLEU score')

    # Save the plot
    plt.savefig(f'{output_dir}/bleu_scatter_plot.png')

def generate_time_visualisation(input_file, output_dir):
    data = pd.read_csv(input_file)
    # Create a scatter plot
    plt.figure(figsize=(8, 6))
    plt.scatter(data['Beam size'], data['Generation time'], color='blue', alpha=0.5)
    plt.xticks(range(2, 21, 2)) # set x-axis step

    # Add title and labels
    plt.title('Beam Size vs. Time Taken to Generate Translation')
    plt.xlabel('Beam size')
    plt.ylabel('Generation time')

    # Save the plot
    plt.savefig(f'{output_dir}/time_scatter_plot.png')

def main():
    parser = argparse.ArgumentParser(description='Create visualisations from a CSV file.')
    parser.add_argument('input_file', type=str, help='The input file to process')
    parser.add_argument('output_directory', type=str, help='The directory the output plots should be saved in')
    
    args = parser.parse_args()
    
    generate_bleu_visualisation(args.input_file, args.output_directory)
    generate_time_visualisation(args.input_file, args.output_directory)

if __name__ == "__main__":
    main()
