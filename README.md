# Receipt Parser

A Ruby application that parses and calculates taxes for shopping receipts.

## Requirements

- Ruby 3.2 or higher
- Bundler (for managing dependencies)

## Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd receipt-parser
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

## Usage

### Run with default receipts

```bash
ruby main.rb
```

This will process three sample receipts (`receipt1.txt`, `receipt2.txt`, `receipt3.txt`) and display the results.

### Run with a specific receipt file

```bash
ruby main.rb path/to/receipt.txt
```

## Output Format

The program outputs:

- Individual items with quantities, descriptions, and total price including taxes
- Total sales taxes
- Total amount

## Testing

Run the test suite with:

```bash
bundle exec rspec
```

## Project Structure

- `main.rb` - Main application entry point
- `receipt_parser.rb` - Core parsing logic
- `receipt_calculator.rb` - Tax calculation engine
- `tax_calculators/` - Tax calculation implementations
- `spec/` - Test files
- Sample receipt files: `receipt1.txt`, `receipt2.txt`, `receipt3.txt`
