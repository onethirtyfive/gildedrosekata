require 'rspec/given'
require 'gilded_rose'

describe GildedRose do
  describe '#next_sell_in' do
    subject { described_class.method(:next_sell_in) }

    [:normal, :vintage, :fleeting, :conjured].each do |characterization|
      it "decrements and returns the input for #{characterization}" do
        random_sell_in = rand(365)
        expect(
          subject.call(characterization, random_sell_in)
        ).to eq(random_sell_in - 1)
      end
    end

    it 'returns the input when :enduring' do
      expect(subject.call(:enduring, 12)).to eq(12)
    end

    it 'raises on unknown characterization' do
      expect {
        subject.call(:foo, 12)
      }.to raise_error(/characterization/)
    end
  end

  describe '#derive_quality_action' do
    subject { described_class.method(:derive_quality_action) }

    context 'with characterization :normal' do
      context 'with negative sell-in' do
        let(:sell_in) { rand(365) * -1 }

        it 'returns an action to subtract 2 from quality' do
          expect(subject.call(:normal, sell_in, 10)).to eq([:-, 2])
        end
      end

      context 'with non-negative sell-in' do
        let(:sell_in) { rand(365) }

        it 'returns an action to subtract 1 from quality' do
          expect(subject.call(:normal, sell_in, 10)).to eq([:-, 1])
        end
      end
    end

    context 'with characterization :conjured' do
      context 'with negative sell-in' do
        let(:sell_in) { rand(365) * -1 }

        it 'returns an action to subtract 4 from quality' do
          expect(subject.call(:conjured, sell_in, 10)).to eq([:-, 4])
        end
      end

      context 'with non-negative sell-in' do
        let(:sell_in) { rand(365) }

        it 'returns an action to subtract 2 from quality' do
          expect(subject.call(:conjured, sell_in, 10)).to eq([:-, 2])
        end
      end
    end

    context 'with characterization :vintage' do
      context 'with negative sell-in' do
        let(:sell_in) { rand(365) * -1 }

        it 'returns an action to add 2 to quality' do
          expect(subject.call(:vintage, sell_in, 10)).to eq([:+, 2])
        end
      end

      context 'with non-negative sell-in' do
        let(:sell_in) { rand(365) }

        it 'returns an action to add 1 to quality' do
          expect(subject.call(:vintage, sell_in, 10)).to eq([:+, 1])
        end
      end
    end

    context 'with characterization :enduring' do
      let(:sell_in) { rand(365) }

      it 'returns an action to assign the same quality' do
        expect(subject.call(:enduring, sell_in, 10)).to eq([:_, 10])
      end
    end

    context 'with characterization :fleeting' do
      context 'with sell-in between 0 and 4, inclusive' do
        let(:sell_in) { rand(0..4) }

        it 'returns an action to add 3 to quality' do
          expect(subject.call(:fleeting, sell_in, 10)).to eq([:+, 3])
        end
      end

      context 'with sell-in between 5 and 9, inclusive' do
        let(:sell_in) { rand(5..9) }

        it 'returns an action to add 2 to quality' do
          expect(subject.call(:fleeting, sell_in, 10)).to eq([:+, 2])
        end
      end

      context 'with sell-in between 10 and 365, inclusive' do
        let(:sell_in) { rand(10..365) }

        it 'returns an action to add 1 to quality' do
          expect(subject.call(:fleeting, sell_in, 10)).to eq([:+, 1])
        end
      end

      context 'with sell-in between -365 and -1, inclusive' do
        let(:sell_in) { rand(1..365) * -1 }

        it 'returns an action to set quality to 0' do
          expect(subject.call(:fleeting, sell_in, 10)).to eq([:_, 0])
        end
      end

      context 'on other value' do
        it 'raises' do
          expect {
            subject.call(:fleeting, 366, 10)
          }.to raise_error(/sell_in/)
        end
      end
    end

    context 'with unknown characterization' do
      it 'raises' do
        expect {
          subject.call(:foo, 366, 10)
        }.to raise_error(/characterization/)
      end
    end
  end

  describe '#apply_quality_action' do
    subject { described_class.method(:apply_quality_action) }

    let(:quality) { rand(1..50) }
    let(:x)       { rand(1..10) }

    it 'returns quality plus x for [:+, x]' do
      expect(subject.call([:+, x], quality)).to eq(quality + x)
    end

    it 'returns quality plus x for [:-, x]' do
      expect(subject.call([:-, x], quality)).to eq(quality - x)
    end

    it 'returns quality at x for [:_, x]' do
      expect(subject.call([:_, x], quality)).to eq(x)
    end

    it 'raises on unknown op' do
      expect {
        subject.call([:foo, 3], 10)
      }.to raise_error(/op/)
    end
  end

  describe '#apply_quality_ceiling' do
    subject { described_class.method(:apply_quality_ceiling) }

    it 'returns the input value for :enduring' do
      quality = rand(1..1000)
      expect(subject.call(:enduring, quality)).to eq(quality)
    end

    it 'raises on unknown characterization' do
      expect {
        subject.call(:foo, 10)
      }.to raise_error(/characterization/)
    end

    [:normal, :fleeting, :vintage, :conjured].each do |characterization|
      context 'with quality 51' do
        let(:quality) { 51 }

        it "returns 50 for #{characterization}" do
          expect(subject.call(characterization, quality)).to eq(50)
        end
      end

      context 'with quality between 1 and 49' do
        let(:quality) { rand(1..49) }

        it "returns the value for #{characterization}" do
          expect(subject.call(characterization, quality)).to eq(quality)
        end
      end
    end
  end

  describe '#apply_quality_floor' do
    subject { described_class.method(:apply_quality_floor) }

    it 'returns the input value for :enduring' do
      quality = rand(1..1000)
      expect(subject.call(:enduring, quality)).to eq(quality)
    end

    it 'raises on unknown characterization' do
      expect {
        subject.call(:foo, 10)
      }.to raise_error(/characterization/)
    end

    [:normal, :fleeting, :vintage, :conjured].each do |characterization|
      context 'with quality -1 (should never happen)' do
        let(:quality) { -1 }

        it "returns 0 for #{characterization}" do
          expect(subject.call(characterization, quality)).to eq(0)
        end
      end

      context 'with positive value' do
        let(:quality) { rand(1..50) }

        it "returns the value for #{characterization}" do
          expect(subject.call(characterization, quality)).to eq(quality)
        end
      end
    end
  end

  describe '#tick' do
    subject { described_class.method(:tick) }

    let(:item) { GildedRose::Item.new('Aged Brie', :vintage, 5, 23) }

    it 'calls #next_sell_in' do
      expect(described_class).to receive(:next_sell_in).and_call_original
      subject.call(item)
    end

    it 'calls #apply_quality_action' do
      expect(described_class).to(
        receive(:apply_quality_action).
        and_call_original
      )
      subject.call(item)
    end

    it 'calls #apply_quality_ceiling' do
      expect(described_class).to(
        receive(:apply_quality_ceiling).
        and_call_original
      )
      subject.call(item)
    end

    it 'calls #apply_quality_floor' do
      expect(described_class).to(
        receive(:apply_quality_floor).
        and_call_original
      )
      subject.call(item)
    end

    it 'returns an Item' do
      expect(subject.call(item)).to be_a(GildedRose::Item)
    end
  end
end

