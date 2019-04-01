Spree::OptionType.class_eval do
  scope :clothe_size, -> {where(name: ["size", "Taille", "Size", "taille","tshirt-size"])}
  scope :color, -> {where(name: ["Color", "Couleur", "color", "couleur","tshirt-color"])}
end