# This class is used to parse the receipt and return
# an array of items with quantity, description, and price.

class ReceiptParser
  ITEM_REGEX = /^(\d+(?:\.\d+)?)\s+(.+)\s+at\s+(\d+(?:\.\d+)?)$/

  def initialize(receipt_path)
    @receipt_path = receipt_path
  end

  def parse
    receipt = File.readlines(@receipt_path)
    receipt.map do |line|
      parse_item(line)
    end
  end

  private

  def parse_item(item)
    return unless item.match?(ITEM_REGEX)

    quantity, description, price = item.scan(ITEM_REGEX).flatten
    quantity = quantity.include?('.') ? quantity.to_f : quantity.to_i
    {
      quantity: quantity,
      description: description,
      price: price.to_f
    }
  end
end