require "open-uri"
require 'csv'

puts "🌱 Seeding database..."

Page.destroy_all
Book.destroy_all
User.destroy_all

puts "📚 Creating books..."

book_data = [
  {
    title: "Peter's Bizarre Adventures",
    author: "Harry Potter",
    description: "Peter goes on a batshit crazy journey in his sleep.",
    language: "English",
    cover_image: "Peter's Bizarre Adventures.jpg"
  },
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
  },
  {
    title: "About Bunnies",
    author: "Gladys Nelson Muter",
    description: "Un conte poétique et philosophique sous l'apparence d'un conte pour enfants...",
    language: "French",
    cover_image: "bunnies01.jpg"
  },
  {
    title: "The Adventures of Squirrel Fluffytail",
    author: "Dolores McKenna",
    description: "Un conte poétique et philosophique sous l'apparence d'un conte pour enfants...",
    language: "French",
    cover_image: "01_Adventures_Squirrel_Fluffytail.jpg"
  },
    {
    title: "Adventures of the Teenie Weenies",
    author: "Wm.  Donahey",
    description: "Un conte poétique et philosophique sous l'apparence d'un conte pour enfants...",
    language: "French",
    cover_image: "01_Adventures_of_the_Teenie_Weenies.jpg"
  },
    {
    title: "Aesop's Fables Book 1",
    author: "",
    description: "Un conte poétique et philosophique sous l'apparence d'un conte pour enfants...",
    language: "French",
    cover_image: "01_Aesops_Fables_Bk1.jpg"
  },
    {
    title: "De Avonturen Van Kleinen Piet",
    author: "J.J.A. Goevernor",
    description: "Un conte poétique et philosophique sous l'apparence d'un conte pour enfants...",
    language: "French",
    cover_image: "01_de_avonturen_va_klienen_piet.jpg"
  }
]

real_pages = {
  "Peter's Bizarre Adventures" => [
    "Peter woke up in a marshmallow forest, unsure how he got there.",
    "A talking fish offered him a ride on a jellybean submarine.",
    "The sky turned purple and rained custard as Peter floated by.",
    "A crab wearing sunglasses handed Peter a mysterious envelope.",
    "Inside was a map of a hidden donut planet.",
    "Peter followed the trail of sprinkles left by flying squirrels.",
    "He tripped over a disco ball and fell into a time portal.",
    "Back in time, he saw himself eating a taco with a unicorn.",
    "Peter asked his past self how to get home, but only got riddles.",
    "A grumpy owl offered Peter a lift on his air-scooter.",
    "They crashed into a cheese fountain guarded by marshmallow men.",
    "Peter used the envelope as a parachute to escape the chaos.",
    "A portal opened above a pie mountain and sucked him in.",
    "He woke up in bed, unsure if it was all a dream—until he coughed up glitter."
  ],
  "The Tale of Peter Rabbit" => [
    "Once upon a time there were four little Rabbits, and their names were—Flopsy, Mopsy, Cotton-tail, and Peter.",
    "They lived with their mother in a sand-bank, underneath the root of a very big fir-tree.",
    "'Now, my dears,' said old Mrs. Rabbit one morning, 'you may go into the fields or down the lane, but don't go into Mr. McGregor's garden.'",
    "Flopsy, Mopsy, and Cotton-tail, who were good little bunnies, went down the lane to gather blackberries.",
    "But Peter, who was very naughty, ran straight away to Mr. McGregor's garden and squeezed under the gate!",
    "First he ate some lettuces and some French beans; and then he ate some radishes.",
    "But round the end of a cucumber frame, whom should he meet but Mr. McGregor!",
    "Mr. McGregor jumped up and ran after Peter, waving a rake and calling out, 'Stop thief!'",
    "Peter was most dreadfully frightened; he rushed all over the garden, for he had forgotten the way back to the gate.",
    "He lost one of his shoes among the cabbages, and the other shoe amongst the potatoes.",
    "After losing them, he ran on four legs and went faster, so that he might have gotten away altogether.",
    "But unfortunately, he ran into a gooseberry net, and got caught by the large buttons on his jacket.",
    "Peter gave himself up for lost, and shed big tears; but his sobs were overheard by some friendly sparrows.",
    "They implored him to exert himself, and he wriggled out just in time, leaving his jacket behind him."
  ]
}

book_data.each do |attrs|
  image_file = attrs.delete(:cover_image)
  book = Book.create!(attrs)
  puts "✅ Created '#{book.title}' by #{book.author}"

  # Attach cover image to Book
  file = File.open(Rails.root.join("app/assets/images/#{image_file}"))
  book.cover_image.attach(io: file, filename: image_file, content_type: "image/jpeg")

  # Select either 14 real or 5 placeholder pages
  pages = real_pages[book.title] || Array.new(5) { |i| "This is page #{i + 1} of #{book.title}." }

  pages.each_with_index do |text, i|
    page = Page.create!(
      book: book,
      text: { en: text },
      page_number: i + 1
    )

    # Choose image for page
    page_image = if book.title == "Peter's Bizarre Adventures"
                   "PBA P#{i + 1}.jpg"
                 else
                   image_file
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
end

# Create more books, images from Cloudinary and text from another file (csv)
puts "📚 Creating more books..."

# Kaho's Google Spreadsheet URL for book data
CSV_URL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTyQJYghIl3iILrQ0Ss4xQL_BGK_3-Z8uabPv2_1e0WTdJER_h_QV-Y86D8A8Mr10O7Ky2pN85IPRMs/pub?gid=0&single=true&output=csv"
csv_data = URI.open(CSV_URL).read
books_csv = CSV.parse(csv_data, headers: true)

books_csv.each do |row|
  title = row["Title"]
  author = row["Author"]
  description = row["Description"]
  language = row["Language"]
  cover_url = row["CoverImageURL"]

  book = Book.create!(
    title: title,
    author: author,
    description: description,
    language: language,
  )
  puts "✅ Created book: #{title}"

# Attach cover from Cloudinary
  file = URI.open(cover_url)
  book.cover_image.attach(io: file, filename: File.basename(cover_url), content_type: "image/jpeg")

  # Add page texts and images
  row.headers.select { |h| h.match?(/\d+$/) }.each do |page_column|
  page_number = page_column[/\d+/].to_i
  text = row[page_column]
  next unless text.present?

    page = Page.create!(
      book: book,
      text: { en: text },
      page_number: page_number
    )

    # Example of attaching an image if your naming matches (e.g. "book_title_P1.jpg")
   image_column = "#{page_number}ImageURL"
    if row[image_column].present?
      page_image_url = row[image_column]
      file = URI.open(page_image_url)
      page.photo.attach(io: file, filename: File.basename(page_image_url), content_type: "image/jpeg")
      puts "🖼️ Attached Cloudinary image to Page #{page_number} of '#{book.title}'"
    else
      puts "⚠️ No image URL for Page #{page_number} of '#{book.title}'"
    end
  end
end


puts "👤 Creating a test user..."

User.create!(
  email: "test@test.com",
  password: "123123",
  password_confirmation: "123123",
  first_name: "Test",
  last_name: "Tester",
  username: "Testery",
  languages: ["EN", "JA", "ES"]
)

puts "🌱 Done seeding!"
