Spree::Core::Engine.routes.draw do
  get "/autocomplete" =>"products#autocomplete"
end
