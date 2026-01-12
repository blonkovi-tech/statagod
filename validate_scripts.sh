#!/bin/bash
# Validation script for Stata .do files
# Checks for common syntax issues

echo "Validating Stata .do files..."
echo "================================"

files=(
    "hypothesis_testing.do"
    "construct_ac_index.do"
    "visualization.do"
    "generate_example_data.do"
)

errors=0

for file in "${files[@]}"; do
    echo ""
    echo "Checking $file..."
    
    if [ ! -f "$file" ]; then
        echo "  ERROR: File not found!"
        errors=$((errors + 1))
        continue
    fi
    
    # Check for common syntax issues
    
    # Check for unmatched braces
    open_braces=$(grep -o '{' "$file" | wc -l)
    close_braces=$(grep -o '}' "$file" | wc -l)
    if [ "$open_braces" != "$close_braces" ]; then
        echo "  WARNING: Unmatched braces (${open_braces} open, ${close_braces} close)"
    fi
    
    # Check for unmatched quotes (basic check - limited accuracy)
    # Note: This is a simplified check that may produce false positives for
    # escaped quotes or quotes within comments. For thorough validation, run in Stata.
    quote_count=$(grep -o '"' "$file" | wc -l)
    if [ $((quote_count % 2)) != 0 ]; then
        echo "  INFO: Odd number of quotes ($quote_count) - may indicate unmatched quote (or escaped quotes)"
    fi
    
    # Check for common Stata commands are present
    if grep -q "clear all" "$file" || grep -q "use " "$file" || grep -q "gen " "$file" || grep -q "reg " "$file" || grep -q "logit " "$file"; then
        echo "  ✓ Contains Stata commands"
    else
        echo "  WARNING: No common Stata commands found"
    fi
    
    # Check file is not empty
    if [ ! -s "$file" ]; then
        echo "  ERROR: File is empty!"
        errors=$((errors + 1))
    else
        lines=$(wc -l < "$file")
        echo "  ✓ File has $lines lines"
    fi
    
    # Check for proper line endings (no mixed endings)
    if file "$file" | grep -q "CRLF"; then
        echo "  INFO: Uses Windows line endings (CRLF)"
    elif file "$file" | grep -q "ASCII"; then
        echo "  ✓ Uses Unix line endings (LF)"
    fi
    
done

echo ""
echo "================================"
if [ $errors -eq 0 ]; then
    echo "✓ All files passed basic validation"
    echo ""
    echo "Note: This is a basic syntax check."
    echo "To fully test the scripts, run them in Stata:"
    echo "  do generate_example_data.do"
    echo "  do hypothesis_testing.do"
    echo "  do visualization.do"
    exit 0
else
    echo "✗ Found $errors error(s)"
    exit 1
fi
