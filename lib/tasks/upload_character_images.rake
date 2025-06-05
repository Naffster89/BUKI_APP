namespace :character_images do
  desc "Upload character images from app/assets/images/characters to Cloudinary"
  task upload: :environment do
    require "open-uri"

    image_dir = Rails.root.join("app/assets/images/characters")
    output_mapping = {}

    Dir.glob("#{image_dir}/*.jpg") do |image_path|
      filename = File.basename(image_path)
      species = filename.split(".").first.downcase

      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(image_path),
        filename: filename,
        content_type: "image/jpeg"
      )

      # Replace with your actual production host if needed
      url = Rails.application.routes.url_helpers.rails_blob_url(blob, host: "http://localhost:3000")
      output_mapping[species] = url

      puts "✅ Uploaded #{species}: #{url}"
    end

    puts "\nPaste this into character_reference_images.rb:\n\n"
    puts "CHARACTER_REFERENCE_IMAGES = {\n" +
         output_mapping.map { |k, v| %Q{  "#{k}" => "#{v}"} }.join(",\n") +
         "\n}.freeze"
  end
end
