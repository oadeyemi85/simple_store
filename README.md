# Simple Store

Simple Store is a small web app for browsing products. It has a page showing all
products and a page showing the details of one product. Product information is
saved in a SQLite database, and each product belongs to a category.

This guide explains how the app is put together and how to run it. It is written
for a first-time Rails reader: think of Rails as a set of helpers for building
web pages, and the database as a set of organized tables.

## What you will see

- Open `/products` to see the **All Products** page.
- Choose a product name to open `/products/1` (the number depends on the product)
  and see its category, price, stock quantity, and description.
- Use **Back to all products** to return to the list.

The checked-in CSV contains **300 products** in **10 categories**, with 30
products per category. The names, descriptions, prices, stock quantities, and
categories come from that file.

## Tools this version uses

- Ruby **3.4.11** — the programming language Rails runs on.
- Rails **8.1.4** — the web framework. The locked dependency versions are in
  `Gemfile.lock`.
- SQLite — a small database stored as a file on your computer.
- Bundler — installs the Ruby libraries listed in `Gemfile`.

You need Ruby and its RubyGems package manager installed. On Windows, use a Ruby
installation that can install gems, and open PowerShell in the project folder.
The supplied `.ruby-version` says `3.4.11`. If you use a Ruby version manager,
select Ruby 3.4.11 before following the commands below.

## Run this copy of Simple Store

In PowerShell, change to the folder containing this README. If you are starting
from the parent folder of `simple_store`, run:

```powershell
cd simple_store
```

Then install the project's libraries, prepare the database, load the sample
products, and start Rails:

```powershell
gem install bundler
bundle install
bundle exec rails db:prepare
bundle exec rails db:seed
bundle exec rails server
```

Keep the server window open. In a web browser, visit
<http://localhost:3000/products>. Stop the server by returning to PowerShell and
pressing **Ctrl+C**.

The first command installs Bundler. The second installs the exact compatible
libraries recorded in `Gemfile.lock`. Database preparation creates the
development database at `storage/development.sqlite3` and applies the
migrations. Seeding reads the CSV and puts its products and categories into
that database.

> **Important:** `db:seed` replaces the current products and categories with the
> rows from the CSV. It is safe to rerun when you want to reload the sample
> dataset, but it deletes any product or category records you added yourself.

If the `rails` command is not found, use the app's Rails launcher instead:

```powershell
.\bin\rails db:prepare
.\bin\rails db:seed
.\bin\rails server
```

## How the app was built

The app follows the usual Rails pattern: a browser requests a URL, a **route**
chooses a **controller** action, the action gets records from **models**, and a
**view** turns those records into HTML for the browser.

### 1. Start with a Rails application

This project uses the standard Rails application layout and configuration. To
make a new Rails project with SQLite, a matching Rails setup can be started
with:

```powershell
gem install rails -v 8.1.4
rails _8.1.4_ new simple_store --database=sqlite3
cd simple_store
```

For the exact same app, use the supplied project files rather than generating a
new app: Rails generators and defaults may change between versions. The
`Gemfile` and `Gemfile.lock` describe the dependencies used here.

### 2. Create the database tables

The database has two tables:

| Table | What it stores |
| --- | --- |
| `categories` | One category name, such as “Shoes” |
| `products` | A product's title, description, price, stock quantity, and category ID |

Rails migrations are instructions for creating or changing database tables.
The migrations in `db/migrate/` create products, create categories, and then
connect each product to a category. That connection is called a relationship:
one category can have many products, and each product belongs to one category.
The generated table description is kept in `db/schema.rb`.

The equivalent table-building commands when starting over are:

```powershell
.\bin\rails generate model Product title:string description:text price:decimal stock_quantity:integer
.\bin\rails generate model Category name:string
```

The product-to-category connection is added as a migration. The migration
should make `category_id` required and add a database foreign key, as in
`db/migrate/20261006153320_add_category_to_products.rb`. Then apply the
migrations:

```powershell
.\bin\rails db:migrate
```

### 3. Describe what a valid record looks like

The models are Ruby classes that represent database rows:

- `app/models/product.rb` says that a product belongs to a category and must
  have a title, price, and stock quantity.
- `app/models/category.rb` says that a category can have many products and
  must have a name.

These checks help stop incomplete records from being saved.

### 4. Add the fixed sample data

`db/products.csv` is the source list. Its first row names the columns:

```text
name,price,description,stock quantity,category
```

Every later row describes one product. For example:

```text
Gorgeous Wooden Lamp,38.38,Molestiae commodi autem ducimus ut possimus.,4317,Shoes
```

The seed script in `db/seeds.rb` uses Ruby's CSV reader to open that file. For
each row, it finds or creates the category, then creates the product inside
that category. When it finishes, it prints the number of categories and
products it created.

The `faker` library is included in the dependencies, but the seed script does
**not** generate new random products. It imports the fixed CSV instead. That is
why keeping `db/products.csv` unchanged is the key to getting the same product
names, descriptions, prices, stock, and categories every time.

### 5. Connect web addresses to page actions

`config/routes.rb` defines two store addresses:

| Address | Rails action | What it does |
| --- | --- | --- |
| `/products` | `ProductsController#index` | Finds all products and displays the list |
| `/products/:id` | `ProductsController#show` | Finds one product by its ID and displays it |

The `:id` part is a placeholder. For example, `/products/1` asks for the
product whose database ID is 1.

### 6. Fetch the right products and show them

`app/controllers/products_controller.rb` contains the two actions:

- `index` fetches products and their categories for the list.
- `show` finds one product using the ID from the address.

The matching HTML templates live in `app/views/products/`:

- `index.html.erb` loops through the products and prints each name, price,
  stock quantity, category, and description.
- `show.html.erb` prints the selected product's details and a link back to the
  list.

The templates use a shared page frame in
`app/views/layouts/application.html.erb`. Rails fills in the layout's `yield`
with whichever product page was requested.

## Make a fresh copy and get the same product results

To reproduce the data and pages from this project:

1. Copy or download the **whole `simple_store` folder**. The CSV is part of the
   project; it is not recreated by the seed command.
2. Use Ruby 3.4.11 and install dependencies with `bundle install`.
3. From the `simple_store` folder, run:

   ```powershell
   bundle exec rails db:prepare
   bundle exec rails db:seed
   bundle exec rails server
   ```

4. Open <http://localhost:3000/products>.

Do not edit or regenerate `db/products.csv` if you want the same product data.
The database's internal IDs and timestamps are created when you seed, so those
are not part of the promised matching output. The visible product information
comes from the CSV.

## Useful commands

Run the test suite:

```powershell
bundle exec rails test
```

See the available routes:

```powershell
bundle exec rails routes
```

Open a Rails console to inspect records:

```powershell
bundle exec rails console
```

For example, in the console, `Product.count` should return `300` and
`Category.count` should return `10`. Type `exit` to leave the console.

## Troubleshooting

- **`bundle` or `rails` is not recognized:** Check that Ruby is installed and
  available in PowerShell's `PATH`. You can run the app's launcher as
  `.\bin\rails`.
- **A library is missing:** From this folder, run `bundle install` again and
  check for the first error it reports.
- **The database has no products or old products:** Run
  `bundle exec rails db:prepare` and then `bundle exec rails db:seed`. Remember
  that seeding replaces existing product and category records.
- **The page does not open:** Make sure the server is still running and visit
  `http://localhost:3000/products` (not just the site root `/`).
- **There are fewer or different products:** Check that `db/products.csv` is
  the original file and that the seed command completed successfully.
