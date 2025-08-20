# This class is used to calculate the import tax for a given item.
# The import tax is 5% of the item's price.
# The import tax is only applied to items that are imported.

require_relative "base_calculator"

module TaxCalculators
  class ImportTax < BaseCalculator
    TAX_RATE = 0.05 # 5%

    def tax_exempt?
      !item[:description].downcase.include?("import")
    end
  end
end
