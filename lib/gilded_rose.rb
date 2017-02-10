module GildedRose
  # n.b. I know I'm breaking the rules by adding characterization, but I think
  #      that using a name is stupid, and that part of the kata is stupid.
  Item = Struct.new(:name, :characterization, :sell_in, :quality)

  def next_sell_in(characterization, sell_in)
    case characterization
    when :normal, :vintage, :fleeting, :conjured; sell_in - 1
    when :enduring;                               sell_in
    else
      raise "unknown characterization: #{characterization}"
    end
  end
  module_function :next_sell_in

  def derive_quality_action(characterization, sell_in, quality)
    case characterization
    when :normal;   sell_in < 0 ? [:-, 2] : [:-, 1]
    when :conjured; sell_in < 0 ? [:-, 4] : [:-, 2]
    when :vintage;  sell_in < 0 ? [:+, 2] : [:+, 1]
    when :enduring; [:_, quality]
    when :fleeting
      case sell_in
      when (0..4);     [:+, 3]
      when (5..9);     [:+, 2]
      when (10..365);  [:+, 1] # only support new inventory for one year
      when (-365..-1); [:_, 0] # only support old inventory for one year
      else
        raise "sell_in value #{sell_in} out of range"
      end
    else
      raise "unknown characterization: #{characterization}"
    end
  end
  module_function :derive_quality_action

  def apply_quality_action(action, quality)
    op, value = *action
    case op
    when :+; quality + value
    when :-; quality - value
    when :_; value
    else
      raise "unknown op: #{op}"
    end
  end
  module_function :apply_quality_action

  def apply_quality_ceiling(characterization, quality)
    case characterization
    when :normal, :fleeting, :vintage, :conjured; [quality, 50].min
    when :enduring;                               quality
    else
      raise "unknown characterization: #{characterization}"
    end
  end
  module_function :apply_quality_ceiling

  def apply_quality_floor(characterization, quality)
    case characterization
    when :normal, :fleeting, :vintage, :conjured; [quality, 0].max
    when :enduring;                               quality
    else
      raise "unknown characterization: #{characterization}"
    end
  end
  module_function :apply_quality_floor

  def tick(item)
    name, characterization, sell_in, quality = *item

    sell_in = next_sell_in(characterization, sell_in)
    quality =
      apply_quality_action(
        derive_quality_action(characterization, sell_in, quality),
        quality
      )

    Item.new(name, characterization, sell_in, quality)
  end
  module_function :tick
end

