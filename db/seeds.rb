require "csv"

# Clear existing data
Product.destroy_all
Category.destroy_all

# Path to the CSV file
csv_file = Rails.root.join("db/products.csv")
csv_data = File.read(csv_file)
products = CSV.parse(csv_data, headers: true)

products.each do |row|
  # Find or create category based on column value
  category = Category.find_or_create_by!(name: row["category"])

  # Create product associated with category
  category.products.create!(
    title: row["name"],
    price: row["price"],
    description: row["description"],
    stock_quantity: row["stock quantity"]
  )
end

puts "Created #{Category.count} categories and #{Product.count} products from CSV!"
