import hashlib
import sys

def redact_file(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if line.startswith("REDACT:"):
                # Extract the message after "REDACT:"
                redacted_message = line[len("REDACT:"):].strip()
                
                # Hash the message
                hash_object = hashlib.sha256(redacted_message.encode())
                hashed_message = hash_object.hexdigest()
                
                # Format the redacted line
                unicode_block = "\u2588" * len(redacted_message)
                new_line = f"REDACTED:sha256:{hashed_message}:{unicode_block}\n"
                
                # Write the redacted line to the output
                outfile.write(new_line)
            else:
                # Write the original line to the output
                outfile.write(line)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python redacter.py <input_file> <output_file>")
        sys.exit(1)

    input_filename = sys.argv[1]
    output_filename = sys.argv[2]

    redact_file(input_filename, output_filename)
