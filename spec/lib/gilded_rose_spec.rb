require 'rspec/given'
require 'gilded_rose'

describe GildedRose do
  describe "#adjust_sell_in" do
    subject { described_class.method(:adjust_sell_in) }

    context 'when name is "Sulfuras, Hand of Ragnaros"' do
      let(:name) { "Sulfuras, Hand of Ragnaros" }

      it 'does not adjust the value' do
        expect(subject.call(name, 1)).to eq(1)
      end
    end

    context 'when name is not "Sulfuras, Hand of Ragnaros"' do
      let(:name) { "Lol, the Banhammer" }

      it 'adjusts the value' do
        expect(subject.call(name, 1)).to eq(0)
      end
    end
  end

  describe "#appraise_aged_brie" do
    subject { described_class.method(:appraise_aged_brie) }

    Given(:name)            { "Aged Brie" }
    Given(:initial_sell_in) { 5 }
    Given(:initial_quality) { 10 }

    Given(:adjusted_sell_in) do
      described_class.adjust_sell_in(name, initial_sell_in)
    end

    Given(:new_quality) { subject.call(adjusted_sell_in, initial_quality) }

    context "before sell date" do
      Then { expect(new_quality).to eq(initial_quality + 1) }

      context "with max quality" do
        Given(:initial_quality) { 50 }
        Then { expect(new_quality).to eq(initial_quality) }
      end
    end

    context "on sell date" do
      Given(:initial_sell_in) { 0 }
      Then { expect(new_quality).to eq(initial_quality + 2) }

      context "near max quality" do
        Given(:initial_quality) { 49 }
        Then { expect(new_quality).to eq(50) }
      end

      context "with max quality" do
        Given(:initial_quality) { 50 }
        Then { expect(new_quality).to eq(initial_quality) }
      end
    end

    context "after sell date" do
      Given(:initial_sell_in) { -10 }
      Then { expect(new_quality).to eq(initial_quality + 2) }

      context "with max quality" do
        Given(:initial_quality) { 50 }
        Then { expect(new_quality).to eq(initial_quality) }
      end
    end
  end

  context "#appraise_backstage_passes" do
    subject { described_class.method(:appraise_backstage_passes) }

    Given(:name)            { "Backstage passes to a TAFKAL80ETC concert" }
    Given(:initial_sell_in) { 5 }
    Given(:initial_quality) { 10 }

    Given(:adjusted_sell_in) do
      described_class.adjust_sell_in(name, initial_sell_in)
    end

    Given(:new_quality) { subject.call(adjusted_sell_in, initial_quality) }

    context "long before sell date" do
      Given(:initial_sell_in) { 11 }
      Then { expect(new_quality).to eq(initial_quality + 1) }

      context "at max quality" do
        Given(:initial_quality) { 50 }
      end
    end

    context "medium close to sell date (upper bound)" do
      Given(:initial_sell_in) { 10 }
      Then { expect(new_quality).to eq(initial_quality + 2) }

      context "at max quality" do
        Given(:initial_quality) { 50 }
        Then { expect(new_quality).to eq(initial_quality) }
      end
    end

    context "medium close to sell date (lower bound)" do
      Given(:initial_sell_in) { 6 }
      Then { expect(new_quality).to eq(initial_quality + 2) }

      context "at max quality" do
        Given(:initial_quality) { 50 }
        Then { expect(new_quality).to eq(initial_quality) }
      end
    end

    context "very close to sell date (upper bound)" do
      Given(:initial_sell_in) { 5 }
      Then { expect(new_quality).to eq(initial_quality + 3) }

      context "at max quality" do
        Given(:initial_quality) { 50 }
        Then { expect(new_quality).to eq(initial_quality) }
      end
    end

    context "very close to sell date (lower bound)" do
      Given(:initial_sell_in) { 1 }
      Then { expect(new_quality).to eq(initial_quality + 3) }

      context "at max quality" do
        Given(:initial_quality) { 50 }
        Then { expect(new_quality).to eq(initial_quality) }
      end
    end

    context "on sell date" do
      Given(:initial_sell_in) { 0 }
      Then { expect(new_quality).to eq(0) }
    end

    context "after sell date" do
      Given(:initial_sell_in) { -10 }
      Then { expect(new_quality).to eq(0) }
    end
  end

  describe "#appraise_sulfuras" do
    subject { described_class.method(:appraise_backstage_passes) }

    Given(:adjusted_sell_in) { 5 }
    Given(:initial_quality)  { 50 }

    Given(:new_quality) do
      subject.call(adjusted_sell_in, initial_quality)
    end

    context "before sell date" do
      Then { expect(new_quality).to eq(initial_quality) }
    end

    context "on sell date" do
      Given(:adjusted_sell_in) { 0 }
      Then { expect(new_quality).to eq(initial_quality) }
    end

    context "after sell date" do
      Given(:adjusted_sell_in) { -10 }
      Then { expect(new_quality).to eq(0) }
    end
  end

  context "conjured item" do
    before { pending }

    Given(:name) { "Conjured Mana Cake" }

    Invariant { expect(new_sell_in).to eq(initial_sell_in - 1) }

    context "before the sell date" do
      Given(:initial_sell_in) { 5 }
      Then { expect(new_quality).to eq(initial_quality - 2) }

      context "at zero quality" do
        Given(:initial_quality) { 0 }
        # Then { new_quality.should == initial_quality }
      end
    end

    context "on sell date" do
      Given(:initial_sell_in) { 0 }
      Then { expect(new_quality).to eq(initial_quality - 4) }

      context "at zero quality" do
        Given(:initial_quality) { 0 }
        # Then { new_quality.should == initial_quality }
      end
    end

    context "after sell date" do
      Given(:initial_sell_in) { -10 }
      Then { expect(new_quality).to eq(initial_quality - 4) }

      context "at zero quality" do
        Given(:initial_quality) { 0 }
        # Then { new_quality.should == initial_quality }
      end
    end
  end

  describe "#appraise" do
    subject { described_class.method(:appraise) }

    context "with a single" do
      Given(:adjusted_sell_in) { 5 }
      Given(:initial_quality) { 10 }

      Given(:new_quality) do
        subject.call(adjusted_sell_in, initial_quality)
      end

      context "before sell date" do
        Then { expect(new_quality).to eq(initial_quality - 1) }
      end

      context "on sell date" do
        Given(:adjusted_sell_in) { -1 }
        Then { expect(new_quality).to eq(initial_quality - 2) }
      end

      context "after sell date" do
        Given(:adjusted_sell_in) { -10 }
        Then { expect(new_quality).to eq(initial_quality - 2) }
      end

      context "of zero quality" do
        Given(:initial_quality) { 0 }
        Then { expect(new_quality).to eq(0) }
      end
    end
  end
end

