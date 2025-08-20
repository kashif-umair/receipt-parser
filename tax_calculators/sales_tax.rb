require_relative 'base_calculator'

module TaxCalculators
  class SalesTax < BaseCalculator
    TAX_RATE = 0.1 # 10%

    # this is not an exhaustive list of tax exempt words.
    # it's a list of words that are commonly used in the tax exempt items.
    TAX_EXEMPT_WORDS = [
      'book', 'magazine', 'digest', 'newspaper', 'chocolate bar', 'chocolate box',
      'chocolate cookie', 'chocolate syrup', 'chocolate', 'candy bar', 'candy', 'candies',
      'pills', 'tablet', 'syrup', 'capsule', 'injection'
    ].freeze

    def tax_exempt?
      item_description = item[:description].downcase
      TAX_EXEMPT_WORDS.any? { |word| item_description.include?(word) }
    end
  end
end
