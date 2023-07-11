import argparse
import load
import sys

print(f'Calling {__file__} with args: {sys.argv}')

parser = argparse.ArgumentParser()
parser.add_argument('--image-path', type=str, required=True)

args = parser.parse_args()

tensor = load.image_to_tensor(args.image_path, 2 ,2 )

print(f'Transformed {args.image_path} to tensor[2, 2]: {tensor}')

image_graph = load.load_image_graph(tensor)

print(f'Transformed {args.image_path} to graph : {image_graph}')