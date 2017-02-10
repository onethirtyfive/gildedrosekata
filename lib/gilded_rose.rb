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

  def appraise_backstage_passes(adjusted_sell_in, quality)
    new_quality = quality

    new_quality += 1

    if adjusted_sell_in < 10
      new_quality += 1
    end

    if adjusted_sell_in < 5
      new_quality += 1
    end

    if adjusted_sell_in < 0
      new_quality = 0
    end

    [new_quality, 50].min
  end
  module_function :appraise_backstage_passes

  def appraise(name, sell_in, quality)
    new_quality = quality

    if new_quality > 0
      if name != 'Sulfuras, Hand of Ragnaros'
        new_quality -= 1
      end
    end

    new_sell_in = adjust_sell_in(name, sell_in)

    if new_sell_in < 0
      if new_quality > 0
        if name != 'Sulfuras, Hand of Ragnaros'
          new_quality -= 1
        end
      end
    end

    [new_sell_in, new_quality]
  end
  module_function :appraise
end

