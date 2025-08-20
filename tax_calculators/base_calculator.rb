# The base calculator is used to calculate the tax for a given item.
# This class will have subclasses for each type of tax.
# Each subclass will have different implementation of the tax_exempt? method
# that's why we need separate class for each type of tax.

require_relative "custom_rounding"

module TaxCalculators
  class BaseCalculator
    include CustomRounding

    attr_reader :item

    def initialize(item)
      @item = item
    end

    def calculate
      return 0 if tax_exempt?

      tax_amount = item[:price] * self.class::TAX_RATE

      (round_to_nearest_0_05(tax_amount) * item[:quantity])
        .round(2) # to 2 decimal places to avoid floating point precision issues
    end

    def tax_exempt?
      false
    end
  end
end