require 'spec_helper'

RSpec.describe TaxCalculators::SalesTax do
  let(:item) { { description: 'test item', price: 10.00, quantity: 1 } }
  let(:sales_tax) { described_class.new(item) }

  describe 'constants' do
    it 'has the correct tax rate of 10%' do
      expect(described_class::TAX_RATE).to eq(0.1)
    end

    it 'has the correct tax exempt words' do
      expected_words = [
        'book', 'magazine', 'digest', 'newspaper', 'chocolate bar', 'chocolate box',
        'chocolate cookie', 'chocolate syrup', 'chocolate', 'candy bar', 'candy', 'candies',
        'pills', 'tablet', 'syrup', 'capsule', 'injection'
      ]
      expect(described_class::TAX_EXEMPT_WORDS).to eq(expected_words)
      expect(described_class::TAX_EXEMPT_WORDS).to be_frozen
    end
  end

  describe '#tax_exempt?' do
    context 'when item description contains tax exempt words' do
      described_class::TAX_EXEMPT_WORDS.each do |word|
        it "returns true for '#{word}'" do
          item[:description] = word
          expect(sales_tax.tax_exempt?).to be true
        end

        it "returns true for partial match with '#{word}'" do
          item[:description] = "some#{word} wrapper"
          expect(sales_tax.tax_exempt?).to be true
        end

        it "returns true for case insensitive match with '#{word.upcase}'" do
          item[:description] = word.upcase
          expect(sales_tax.tax_exempt?).to be true
        end
      end
    end

    context 'when item description does not contain tax exempt words' do
      it 'returns false for regular items' do
        item[:description] = 'perfume'
        expect(sales_tax.tax_exempt?).to be false
      end

      it 'returns false for electronics' do
        item[:description] = 'music CD'
        expect(sales_tax.tax_exempt?).to be false
      end

      it 'returns false for clothing' do
        item[:description] = 'shirt'
        expect(sales_tax.tax_exempt?).to be false
      end

      it 'returns false for food items not in exempt list' do
        item[:description] = 'apple'
        expect(sales_tax.tax_exempt?).to be false
      end
    end
  end

  describe '#calculate' do
    context 'when item is tax exempt' do
      it 'returns 0 for tax exempt items' do
        item[:description] = 'book'
        item[:price] = 12.49
        item[:quantity] = 1
        expect(sales_tax.calculate).to eq(0)
      end
    end

    context 'when item is not tax exempt' do
      it 'calculates correct tax for single item' do
        item[:description] = 'perfume'
        item[:price] = 10.00
        item[:quantity] = 1
        expect(sales_tax.calculate).to eq(1.00)
      end

      it 'calculates correct tax for multiple quantities' do
        item[:description] = 'perfume'
        item[:price] = 10.00
        item[:quantity] = 2
        expect(sales_tax.calculate).to eq(2.00)
      end

      it 'rounds tax to nearest 0.05' do
        item[:description] = 'perfume'
        item[:price] = 11.25
        item[:quantity] = 1
        expect(sales_tax.calculate).to eq(1.15)
      end

      it 'rounds up when closer to higher 0.05' do
        item[:description] = 'perfume'
        item[:price] = 11.30
        item[:quantity] = 1
        expect(sales_tax.calculate).to eq(1.15)
      end

      it 'handles edge case rounding to 0.05' do
        item[:description] = 'perfume'
        item[:price] = 0.50
        item[:quantity] = 1
        expect(sales_tax.calculate).to eq(0.05)
      end
    end
  end
end
