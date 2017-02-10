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

  def appraise_sulfuras(adjusted_sell_in, quality)
    quality
  end
  module_function :appraise_sulfuras

  def appraise(adjusted_sell_in, quality)
    new_quality = quality

    new_quality -= 1
    if adjusted_sell_in < 0
      new_quality -= 1
    end

    [new_quality, 0].max
  end
  module_function :appraise
end

