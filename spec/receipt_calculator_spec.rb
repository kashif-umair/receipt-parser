require 'spec_helper'
require_relative '../receipt_calculator'

RSpec.describe ReceiptCalculator do
  let(:temp_file) { Tempfile.new(['receipt', '.txt']) }
  let(:calculator) { ReceiptCalculator.new(temp_file.path) }

  after(:each) do
    temp_file.close
    temp_file.unlink
  end

  describe '#calculate' do
    context 'with tax-exempt items only' do
      before do
        temp_file.write("1 book at 12.49\n")
        temp_file.write("1 chocolate bar at 0.85\n")
        temp_file.rewind
      end

      it 'calculates correct item totals without taxes' do
        result = calculator.calculate

        expect(result[:items].length).to eq(2)
        
        book_item = result[:items].find { |item| item[:description] == 'book' }
        expect(book_item[:quantity]).to eq(1)
        expect(book_item[:item_total]).to eq(12.49)
        
        chocolate_item = result[:items].find { |item| item[:description] == 'chocolate bar' }
        expect(chocolate_item[:quantity]).to eq(1)
        expect(chocolate_item[:item_total]).to eq(0.85)
      end

      it 'calculates correct totals' do
        result = calculator.calculate
        
        expect(result[:total]).to eq(13.34)  # 12.49 + 0.85
        expect(result[:taxes]).to eq(0.0)
      end
    end

    context 'with taxable items only' do
      before do
        temp_file.write("1 music CD at 14.99\n")
        temp_file.write("1 bottle of perfume at 18.99\n")
        temp_file.rewind
      end

      it 'calculates correct item totals with sales tax only' do
        result = calculator.calculate
        
        cd_item = result[:items].find { |item| item[:description] == 'music CD' }
        expect(cd_item[:item_total]).to eq(16.49)  # 14.99 + 1.50 (10% tax)
        
        perfume_item = result[:items].find { |item| item[:description] == 'bottle of perfume' }
        expect(perfume_item[:item_total]).to eq(20.89)  # 18.99 + 1.90 (10% tax)
      end

      it 'calculates correct totals' do
        result = calculator.calculate
        
        expect(result[:total]).to eq(37.38)  # 16.49 + 20.89
        expect(result[:taxes]).to eq(3.40)  # 1.50 + 1.90
      end
    end

    context 'with imported items' do
      before do
        temp_file.write("1 imported bottle of perfume at 27.99\n")
        temp_file.write("1 imported box of chocolates at 11.25\n")
        temp_file.rewind
      end

      it 'calculates correct item totals with correct taxes' do
        result = calculator.calculate
        
        perfume_item = result[:items].find { |item| item[:description] == 'imported bottle of perfume' }
        expect(perfume_item[:item_total]).to eq(32.19)  # 27.99 + 1.40 (5% import tax) + 2.80 (10% sales tax)
        
        chocolate_item = result[:items].find { |item| item[:description] == 'imported box of chocolates' }
        expect(chocolate_item[:item_total]).to eq(11.85)  # 11.25 + 0.60 (5% import tax only, no sales tax)
      end

      it 'calculates correct totals with correct taxes' do
        result = calculator.calculate
        
        expect(result[:total]).to eq(44.04)  # 32.19 + 11.85
        expect(result[:taxes]).to eq(4.8)  # 1.40 + 2.80 + 0.60
      end
    end

    context 'with mixed items (taxable, tax-exempt, imported)' do
      before do
        temp_file.write("1 book at 12.49\n")
        temp_file.write("1 music CD at 14.99\n")
        temp_file.write("1 chocolate bar at 0.85\n")
        temp_file.rewind
      end

      it 'calculates correct item totals for each type' do
        result = calculator.calculate
        
        book_item = result[:items].find { |item| item[:description] == 'book' }
        expect(book_item[:item_total]).to eq(12.49)  # No tax
        
        cd_item = result[:items].find { |item| item[:description] == 'music CD' }
        expect(cd_item[:item_total]).to eq(16.49)  # 14.99 + 1.50 (10% tax)
        
        chocolate_item = result[:items].find { |item| item[:description] == 'chocolate bar' }
        expect(chocolate_item[:item_total]).to eq(0.85)  # No tax
      end

      it 'calculates correct totals' do
        result = calculator.calculate
        
        expect(result[:total]).to eq(29.83)  # 12.49 + 16.49 + 0.85
        expect(result[:taxes]).to eq(1.50)  # Only CD tax
      end
    end

    context 'with items having decimal quantities' do
      before do
        temp_file.write("2.5 chocolate bars at 0.85\n")
        temp_file.write("1.5 music CDs at 14.99\n")
        temp_file.rewind
      end

      it 'calculates correct item totals with decimal quantities' do
        result = calculator.calculate
        
        chocolate_item = result[:items].find { |item| item[:description] == 'chocolate bars' }
        expect(chocolate_item[:quantity]).to eq(2.5)
        expect(chocolate_item[:item_total]).to eq(2.13)  # 0.85 * 2.5 (no tax)
        
        cd_item = result[:items].find { |item| item[:description] == 'music CDs' }
        expect(cd_item[:quantity]).to eq(1.5)
        expect(cd_item[:item_total]).to eq(24.74)  # (14.99 * 1.5) + (2.25 tax * 1.5)
      end

      it 'calculates correct totals' do
        result = calculator.calculate
        
        expect(result[:total]).to eq(26.87)  # 2.13 + 24.74
        expect(result[:taxes]).to eq(2.25)
      end
    end
  end

  describe 'TAXES constant' do
    it 'contains the correct tax calculator classes' do
      expect(ReceiptCalculator::TAXES).to eq([
        TaxCalculators::SalesTax,
        TaxCalculators::ImportTax
      ])
    end

    it 'is frozen' do
      expect(ReceiptCalculator::TAXES).to be_frozen
    end
  end

  describe 'integration with tax calculators' do
    it 'applies both sales tax and import tax when applicable' do
      temp_file.write("1 imported music CD at 14.99\n")
      temp_file.rewind
      
      result = calculator.calculate
      
      # Sales tax: 14.99 * 0.10 = 1.50
      # Import tax: 14.99 * 0.05 = 0.75
      # Total tax: 2.25
      # Item total: 14.99 + 2.25 = 17.24
      expect(result[:items].first[:item_total]).to eq(17.24)
      expect(result[:taxes]).to eq(2.25)
    end

    it 'applies only import tax for tax-exempt imported items' do
      temp_file.write("1 imported chocolate bar at 0.85\n")
      temp_file.rewind
      
      result = calculator.calculate
      
      # No sales tax (chocolate is exempt)
      # Import tax: 0.85 * 0.05 = 0.05
      # Item total: 0.85 + 0.05 = 0.90
      expect(result[:items].first[:item_total]).to eq(0.90)
      expect(result[:taxes]).to eq(0.05)
    end
  end
end
