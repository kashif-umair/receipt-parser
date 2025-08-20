# This module is used to round a value to the nearest 0.05.
# The reason this module exists in the tax_calculators namespace is because
# currently the custom rounding is only applicable to the tax calculations.

module TaxCalculators
  module CustomRounding
    def round_to_nearest_0_05(value)
      (value / 0.05).ceil * 0.05
    end
  end
end