# Instructions:
# 1. Run the script with the path to the receipt file as an argument
# 2. If no argument is provided, the script will use the default receipts
# 3. The script will print the processed receipt to the console
# 4. The script will also print the total sales taxes and the total amount due

require_relative "receipt_calculator"

def print_receipt(result)
  result[:items].each do |item|
    puts "#{item[:quantity]} #{item[:description]}: #{sprintf('%.2f', item[:item_total])}"
  end
  puts "Sales Taxes: #{sprintf('%.2f', result[:taxes])}"
  puts "Total: #{sprintf('%.2f', result[:total])}"
  puts '-' * 50
end

if ARGV.length > 0
  receipt_calculator = ReceiptCalculator.new(ARGV[0])
  print_receipt(receipt_calculator.calculate)
else
  receipt_calculator = ReceiptCalculator.new("receipt1.txt")
  print_receipt(receipt_calculator.calculate)

  receipt_calculator = ReceiptCalculator.new("receipt2.txt")
  print_receipt(receipt_calculator.calculate)

  receipt_calculator = ReceiptCalculator.new("receipt3.txt")
  print_receipt(receipt_calculator.calculate)
end
