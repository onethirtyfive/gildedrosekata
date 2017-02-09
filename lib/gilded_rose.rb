module GildedRose
  def appraise(name, sell_in, quality)
    new_sell_in = sell_in
    new_quality = quality

    if name != 'Aged Brie' && name != 'Backstage passes to a TAFKAL80ETC concert'
      if new_quality > 0
        if name != 'Sulfuras, Hand of Ragnaros'
          new_quality -= 1
        end
      end
    else
      if new_quality < 50
        new_quality += 1
        if name == 'Backstage passes to a TAFKAL80ETC concert'
          if new_sell_in < 11
            if new_quality < 50
              new_quality += 1
            end
          end
          if new_sell_in < 6
            if new_quality < 50
              new_quality += 1
            end
          end
        end
      end
    end
    if name != 'Sulfuras, Hand of Ragnaros'
      new_sell_in -= 1
    end
    if new_sell_in < 0
      if name != "Aged Brie"
        if name != 'Backstage passes to a TAFKAL80ETC concert'
          if new_quality > 0
            if name != 'Sulfuras, Hand of Ragnaros'
              new_quality -= 1
            end
          end
        else
          new_quality = new_quality - new_quality
        end
      else
        if new_quality < 50
          new_quality += 1
        end
      end
    end

    [new_sell_in, new_quality]
  end
  module_function :appraise
end

