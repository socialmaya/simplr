class Test < ApplicationRecord
  def self.char_bits items
    bits = []; for item in items
      for char in (item.body.present? ? item.body : item.image.to_s).split("")
        for bit in ("%04b" % char.codepoints.first).split("")
          bits << bit.to_i
        end
      end
    end
    return bits
  end
end
