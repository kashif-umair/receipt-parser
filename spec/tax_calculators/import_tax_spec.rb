require 'spec_helper'

RSpec.describe TaxCalculators::ImportTax do
  let(:item) { { description: 'test item', price: 10.00, quantity: 1 } }
  let(:import_tax) { described_class.new(item) }

  describe 'constants' do
    it 'has the correct tax rate of 5%' do
      expect(described_class::TAX_RATE).to eq(0.05)
    end
  end

  describe '#tax_exempt?' do
    context 'when item description contains "import"' do
      it 'returns false for items with "import" in description' do
        item[:description] = 'imported book'
        expect(import_tax.tax_exempt?).to be false
      end

      it 'returns false for uppercase "IMPORT"' do
        item[:description] = 'IMPORTED book'
        expect(import_tax.tax_exempt?).to be false
      end

      it 'returns false for mixed case "import"' do
        item[:description] = 'ImPoRtEd chocolate'
        expect(import_tax.tax_exempt?).to be false
      end
    end

    context 'when item description does not contain "import"' do
      it 'returns true for domestic books' do
        item[:description] = 'book'
        expect(import_tax.tax_exempt?).to be true
      end

      it 'returns true for domestic chocolate' do
        item[:description] = 'chocolate bar'
        expect(import_tax.tax_exempt?).to be true
      end
    end
  end

  describe '#calculate' do
    context 'when item is tax exempt (domestic)' do
      it 'returns 0 for domestic items' do
        item[:description] = 'book'
        item[:price] = 12.49
        item[:quantity] = 1
        expect(import_tax.calculate).to eq(0)
      end

      it 'returns 0 for domestic items with high price' do
        item[:description] = 'perfume'
        item[:price] = 47.50
        item[:quantity] = 1
        expect(import_tax.calculate).to eq(0)
      end
    end

    context 'when item is not tax exempt (imported)' do
      it 'calculates correct tax for single imported item' do
        item[:description] = 'imported book'
        item[:price] = 10.00
        item[:quantity] = 1
        expect(import_tax.calculate).to eq(0.50)
      end

      it 'calculates correct tax for multiple imported items' do
        item[:description] = 'imported chocolate bar'
        item[:price] = 10.00
        item[:quantity] = 2
        expect(import_tax.calculate).to eq(1.00)
      end

      it 'rounds tax to nearest 0.05' do
        item[:description] = 'imported perfume'
        item[:price] = 11.25
        item[:quantity] = 1
        expect(import_tax.calculate).to eq(0.60)
      end

      it 'handles edge case rounding to 0.05' do
        item[:description] = 'imported candy'
        item[:price] = 1.00
        item[:quantity] = 1
        expect(import_tax.calculate).to eq(0.05)
      end
    end
  end
end
