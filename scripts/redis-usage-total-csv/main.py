import redis
import csv
from typing import Dict

REDIS_HOST = 'localhost'

def get_redis_memory_usage() -> Dict[str, int]:
    """
    Connect to Redis and get memory usage for all keys
    Returns a dictionary mapping key names to their memory usage in bytes
    """
    # Initialize Redis connection
    # Note: Update these parameters based on your Redis configuration
    r = redis.Redis(
        host=REDIS_HOST,
        port=6379,
        decode_responses=True
    )

    # Get all keys
    keys = r.keys('*')

    # Get memory usage for each key
    memory_usage = {}
    for key in keys:
        try:
            # MEMORY USAGE command returns the number of bytes used to store the key
            mem = r.memory_usage(key)
            if mem is not None:
                memory_usage[key] = mem
        except redis.exceptions.ResponseError as e:
            print(f"Error getting memory usage for key {key}: {e}")

    return memory_usage

def save_to_csv(memory_usage: Dict[str, int], output_file: str = 'redis_memory_usage.csv'):
    """
    Save the memory usage data to a CSV file
    Args:
        memory_usage: Dictionary mapping keys to their memory usage
        output_file: Path to the output CSV file
    """
    with open(output_file, 'w', newline='') as f:
        writer = csv.writer(f)
        # Write header
        writer.writerow(['Key', 'Memory Usage (bytes)'])
        # Write data
        for key, usage in memory_usage.items():
            writer.writerow([key, usage])

def main():
    try:
        # Get memory usage for all keys
        memory_usage = get_redis_memory_usage()

        # Save results to CSV
        save_to_csv(memory_usage)

        print(f"Successfully saved memory usage data for {len(memory_usage)} keys")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
