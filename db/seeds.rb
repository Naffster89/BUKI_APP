puts "🌱 Seeding database..."

Page.destroy_all
Book.destroy_all

puts "📚 Creating books..."

books = [
  {
    title: "The Story of a Fierce Bad Rabbit",
    author: "Beatrix Potter",
    description: "This, along with The Tale of Miss Moppet, was intended for very young children. It is a simple tale of what befalls a rude little rabbit that doesn't say 'please' before he takes something that belongs to someone else.",
    language: "English",
    image_url: "https://www.gutenberg.org/files/45265/45265-h/images/cover.jpg"
  },
  {
    title: "The Tale of Peter Rabbit",
    author: "Beatrix Potter",
    description: "The classic tale of a mischievous rabbit who gets into trouble in Mr. McGregor's garden. A timeless story loved by generations.",
    language: "English",
    image_url: "https://cdn2.penguin.com.au/covers/original/9780241545379.jpg"
  },
  {
    title: "Le Petit Prince",
    author: "Antoine de Saint-Exupéry",
    description: "Un conte poétique et philosophique sous l'apparence d'un conte pour enfants, 'Le Petit Prince' aborde des thèmes profonds sur l'amitié, la solitude, et le sens de la vie.",
    language: "French",
    image_url: "https://images.epagine.fr/054/9782070581054_1_75.jpg"
  },
  {
    title: "Don Quixote",
    author: "Miguel de Cervantes",
    description: "An aging nobleman sets out to revive chivalry, battling imaginary enemies and misunderstanding the world around him. A foundational work of Western literature.",
    language: "Spanish",
    image_url: "https://www.kobo.com/bd0c907a-a00f-4f7d-b373-bd42567e61f4"
  }
]

books.each do |attrs|
  book = Book.create!(attrs)
  puts "✅ Created '#{book.title}' by #{book.author}"

  3.times do |i|
    Page.create!(
      book: book,
      text: {en: "This is page #{i + 1} of #{book.title}."},
      page_number: i + 1
    )
  end
end

puts "👤 Creating a test user..."

user = User.create!(
  email: "test@test.com",
  encrypted_password: "123123",
  password_confirmation: "123123",
  first_name: "Natherniel",
  last_name: "Smith",
  username: "Naffster",
)

puts "🌱 Done seeding!"
