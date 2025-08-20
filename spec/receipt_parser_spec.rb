require 'spec_helper'
require_relative '../receipt_parser'

RSpec.describe ReceiptParser do
  let(:temp_file) { Tempfile.new(['receipt', '.txt']) }
  let(:parser) { ReceiptParser.new(temp_file.path) }

  after(:each) do
    temp_file.close
    temp_file.unlink
  end

  describe '#parse' do
    context 'with valid receipt items' do
      before do
        temp_file.write("1 book at 12.49\n")
        temp_file.write("1 music CD at 14.99\n")
        temp_file.write("1 chocolate bar at 0.85\n")
        temp_file.rewind
      end

      it 'parses all items from the receipt' do
        result = parser.parse
        expect(result.length).to eq(3)
      end

      it 'returns an array of hashes with correct structure' do
        result = parser.parse
        expect(result.first).to include(:quantity, :description, :price)
      end
    end
  end

  describe '#parse_item' do
    context 'with valid item format' do
      it 'parses item with integer quantity' do
        result = parser.send(:parse_item, "1 book at 12.49")
        expect(result).to eq({
          quantity: 1,
          description: "book",
          price: 12.49
        })
      end

      it 'parses item with decimal quantity' do
        result = parser.send(:parse_item, "1.5 chocolate bars at 0.85")
        expect(result).to eq({
          quantity: 1.5,
          description: "chocolate bars",
          price: 0.85
        })
      end

      it 'parses item with complex description' do
        result = parser.send(:parse_item, "1 imported bottle of perfume at 27.99")
        expect(result).to eq({
          quantity: 1,
          description: "imported bottle of perfume",
          price: 27.99
        })
      end

      it 'parses item with price as integer' do
        result = parser.send(:parse_item, "1 item at 10")
        expect(result).to eq({
          quantity: 1,
          description: "item",
          price: 10.0
        })
      end

      it 'parses item with price as decimal' do
        result = parser.send(:parse_item, "1 item at 10.50")
        expect(result).to eq({
          quantity: 1,
          description: "item",
          price: 10.50
        })
      end
    end

    context 'with invalid item format' do
      it 'returns nil for non-matching line' do
        result = parser.send(:parse_item, "invalid line")
        expect(result).to be_nil
      end

      it 'returns nil for empty line' do
        result = parser.send(:parse_item, "")
        expect(result).to be_nil
      end

      it 'returns nil for line missing "at" keyword' do
        result = parser.send(:parse_item, "1 book 12.49")
        expect(result).to be_nil
      end

      it 'returns nil for line with wrong format' do
        result = parser.send(:parse_item, "book at 12.49")
        expect(result).to be_nil
      end
    end

    context 'with edge cases' do
      it 'handles description with numbers' do
        result = parser.send(:parse_item, "1 2-liter bottle at 5.99")
        expect(result).to eq({
          quantity: 1,
          description: "2-liter bottle",
          price: 5.99
        })
      end

      it 'handles description with special characters' do
        result = parser.send(:parse_item, "1 item-name (special) at 15.99")
        expect(result).to eq({
          quantity: 1,
          description: "item-name (special)",
          price: 15.99
        })
      end
    end
  end
end
