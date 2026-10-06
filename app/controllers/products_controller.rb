class ProductsController < ApplicationRecord
  def index
    @products = Product.includes(:category).all
  end

  def show
    @product = Product.find(params[:id])
  end
end