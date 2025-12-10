#!/bin/bash
# load_sample_data.sh
# Load the sample_hr database into a local MySQL instance
# Usage: ./load_sample_data.sh -u <user> -p <password> [-h <host>]

set -e

# Default values
HOST="localhost"
USER=""
PASS=""

# Parse command-line arguments
while getopts "u:p:h:" opt; do
  case $opt in
    u) USER="$OPTARG" ;;
    p) PASS="$OPTARG" ;;
    h) HOST="$OPTARG" ;;
    *) echo "Usage: $0 -u user [-p password] [-h host]"; exit 1 ;;
  esac
done

# Validate required arguments
if [ -z "$USER" ]; then
  echo "Error: -u (user) is required"
  echo "Usage: $0 -u user [-p password] [-h host]"
  exit 1
fi

# Build MySQL connection string
if [ -z "$PASS" ]; then
  MYSQL_CMD="mysql -u$USER -h$HOST"
else
  MYSQL_CMD="mysql -u$USER -p$PASS -h$HOST"
fi

# Resolve script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED_FILE="$SCRIPT_DIR/seed_sample_hr.sql"

# Check if seed file exists
if [ ! -f "$SEED_FILE" ]; then
  echo "Error: seed_sample_hr.sql not found at $SEED_FILE"
  exit 1
fi

# Load data
echo "Loading sample_hr database..."
$MYSQL_CMD < "$SEED_FILE"

if [ $? -eq 0 ]; then
  echo "✓ sample_hr database loaded successfully!"
  echo ""
  echo "Verify with:"
  echo "  mysql -u$USER $PASS_DISPLAY -h$HOST sample_hr -e 'SELECT COUNT(*) as employee_count FROM employee;'"
else
  echo "✗ Error loading database. Check MySQL connection and credentials."
  exit 1
fi
