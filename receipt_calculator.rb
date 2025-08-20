# This class is used to calculate the total taxes and the total amount of the items.
# It uses the ReceiptParser to parse the receipt and the TaxCalculators to calculate the taxes.
# It takes the receipt path as an argument and returns a hash with the items, total, and taxes.

require_relative "receipt_parser"
require_relative "tax_calculators/sales_tax"
require_relative "tax_calculators/import_tax"

class ReceiptCalculator
  attr_reader :receipt_path, :parsed_items

  TAXES = [TaxCalculators::SalesTax, TaxCalculators::ImportTax].freeze

  def initialize(receipt_path)
    @receipt_path = receipt_path
    @parsed_items = ReceiptParser.new(@receipt_path).parse
  end

  def calculate
    total_taxes = 0
    items = parsed_items.map do |item|
      item_taxes = TAXES.map do |tax|
        tax.new(item).calculate
      end.sum.round(2)

      total_taxes += item_taxes

      {
        description: item[:description],
        quantity: item[:quantity],
        item_total: ((item[:price] * item[:quantity]) + item_taxes).round(2),
      }
    end

    {
      items: items,
      total: items.map { |item| item[:item_total] }.sum.round(2),
      taxes: total_taxes.round(2)
    }
  end
end