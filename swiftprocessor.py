import csv
import re

# Define file paths
input_file = '/Users/elishuamcpherson/Downloads/10ExamplePayments.txt'
output_csv = '/Users/elishuamcpherson/Documents/swifttransform.csv'

# Initialize storage for extracted data
payments = []

# Regular expression to match a payment block
payment_block_pattern = r'{4:.*?-}'

# Regular expressions to extract specific lines
line_70_pattern = r':70:(.*?)\n'
line_32A_pattern = r':32A:(.*?)\n'
line_50F_pattern = r':50F:(.*?)(?=\n:59F:)'
line_59F_pattern = r':59F:(.*?)(?=\n:70:)'

# Function to extract the line with "/1" and include the name
def extract_name_with_prefix(value):
    if value:
        # Split lines and find the line starting with "1/"
        lines = value.splitlines()
        name_line = [line.strip() for line in lines if line.startswith("1/")]  # Keep "1/" prefix
        return '\n'.join(name_line)
    return None

# Read the input file and process payment blocks
with open(input_file, 'r', encoding='utf-8') as file:
    content = file.read()
    payment_blocks = re.findall(payment_block_pattern, content, re.DOTALL)

    for block in payment_blocks:
        # Extract and clean values for :70, :32A, :50F, and :59F
        line_70 = re.search(line_70_pattern, block)
        line_70 = line_70.group(1).strip() if line_70 else None

        line_32A = re.search(line_32A_pattern, block)
        line_32A = line_32A.group(1).strip() if line_32A else None

        # Process :50F and extract the line with "/1" and name
        line_50F_match = re.search(line_50F_pattern, block, re.DOTALL)
        line_50F = extract_name_with_prefix(line_50F_match.group(1)) if line_50F_match else None

        # Process :59F and extract the line with "/1" and name
        line_59F_match = re.search(line_59F_pattern, block, re.DOTALL)
        line_59F = extract_name_with_prefix(line_59F_match.group(1)) if line_59F_match else None

        # Append cleaned values to the payments list
        payments.append({
            'line70': line_70,
            'line32A': line_32A,
            'line50F': line_50F,  # "/1" and name extracted
            'line59F': line_59F,  # "/1" and name extracted
        })

# Write the extracted data to a CSV file
with open(output_csv, 'w', newline='', encoding='utf-8') as csvfile:
    csv_writer = csv.DictWriter(csvfile, fieldnames=['line70', 'line32A', 'line50F', 'line59F'])
    # Write header row
    csv_writer.writeheader()

    for payment in payments:
        # Write each payment's data
        csv_writer.writerow({
            'line70': payment['line70'],
            'line32A': payment['line32A'],
            'line50F': payment['line50F'],  # "/1" and name written
            'line59F': payment['line59F'],  # "/1" and name written
        })

print(f"Extracted payment data saved to {output_csv}")
