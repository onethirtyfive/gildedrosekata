module GildedRose
  def adjust_sell_in(name, sell_in)
    if name != 'Sulfuras, Hand of Ragnaros'
      sell_in - 1
    else
      sell_in
    end
  end
  module_function :adjust_sell_in

  def appraise_aged_brie(adjusted_sell_in, quality)
    new_quality = quality

    new_quality += 1
    if adjusted_sell_in < 0
      new_quality += 1
    end

    [new_quality, 50].min
  end
  module_function :appraise_aged_brie

  def appraise(name, sell_in, quality)
    new_quality = quality

    if name != 'Backstage passes to a TAFKAL80ETC concert'
      if new_quality > 0
        if name != 'Sulfuras, Hand of Ragnaros'
          new_quality -= 1
        end
      end
    else
      if new_quality < 50
        new_quality += 1
        if name == 'Backstage passes to a TAFKAL80ETC concert'
          if sell_in < 11
            if new_quality < 50
              new_quality += 1
            end
          end
          if sell_in < 6
            if new_quality < 50
              new_quality += 1
            end
          end
        end
      end
    end

    new_sell_in = adjust_sell_in(name, sell_in)

    if new_sell_in < 0
      if name != 'Backstage passes to a TAFKAL80ETC concert'
        if new_quality > 0
          if name != 'Sulfuras, Hand of Ragnaros'
            new_quality -= 1
          end
        end
      else
        new_quality = new_quality - new_quality
      end
    end

    [new_sell_in, new_quality]
  end
  module_function :appraise
end

