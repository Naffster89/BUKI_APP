require "open-uri"

puts "🌱 Seeding database..."

Page.destroy_all
Book.destroy_all
User.destroy_all

puts "📚 Creating books..."

book_data = [
  {
    title: "The Story of a Fierce Bad Rabbit",
    author: "Beatrix Potter",
    description: "This, along with The Tale of Miss Moppet, was intended for very young children...",
    language: "English",
    cover_image: "The Story of a Fierce Bad Rabbit.jpg"
  },
  {
    title: "The Tale of Peter Rabbit",
    author: "Beatrix Potter",
    description: "The classic tale of a mischievous rabbit who gets into trouble...",
    language: "English",
    cover_image: "The Tale of Peter Rabbit.jpg"
  },
  {
    title: "Le Petit Prince",
    author: "Antoine de Saint-Exupéry",
    description: "Un conte poétique et philosophique sous l'apparence d'un conte pour enfants...",
    language: "French",
    cover_image: "Le Petit Prince.jpg"
  },
  {
    title: "Don Quixote",
    author: "Miguel de Cervantes",
    description: "An aging nobleman sets out to revive chivalry, battling imaginary enemies...",
    language: "Spanish",
    cover_image: "Don Quixote.jpg"
  }
]

book_data.each do |attrs|
  image_file = attrs.delete(:cover_image)
  book = Book.create!(attrs)
  puts "✅ Created '#{book.title}' by #{book.author}"

  # Attach cover image to Book
  file = File.open(Rails.root.join("app/assets/images/#{image_file}"))
  book.cover_image.attach(io: file, filename: image_file, content_type: "image/jpeg")

  3.times do |i|
    page = Page.create!(
      book: book,
      text: "This is page #{i + 1} of #{book.title}.",
      page_number: i + 1
    )


    # Use special images for Peter Rabbit
    # Use specific images only for "The Tale of Peter Rabbit"

    if book.title == "The Tale of Peter Rabbit"
      page_image = "Peter P#{i + 1}.jpg"
    else
      page_image = image_file
    end


    image_path = Rails.root.join("app/assets/images", page_image)

    if File.exist?(image_path)
      file = File.open(image_path)
      page.photo.attach(io: file, filename: page_image, content_type: "image/jpeg")
      puts "🖼️ Attached '#{page_image}' to Page #{page.page_number} of '#{book.title}'"
    else
      puts "⚠️ Image '#{page_image}' not found for Page #{page.page_number} of '#{book.title}'"
    end
  end

    file_path = Rails.root.join("app/assets/images", page_image)
    file = File.open(file_path)
    page.photo.attach(io: file, filename: page_image, content_type: "image/jpeg")
  end


end

puts "👤 Creating a test user..."

User.create!(
  email: "test@test.com",
  password: "123123",
  password_confirmation: "123123",
  first_name: "Test",
  last_name: "Tester",
  username: "Testery"
)

puts "🌱 Done seeding!"
