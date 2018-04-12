
Pod::Spec.new do |s|

  s.name         = "PDFAuthor"
  s.version      = "0.0.6"

  s.summary      = "A pure Swift library for generating PDF documents on iOS and MacOS"
  s.description  = <<-DESC
                    A library designed for generating PDF documents. It supports using constraints to specify layout, provided by Cassowary.
                   DESC

  s.homepage     = "https://github.com/tribalworldwidelondon/PDFAuthor"

  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author    = "Tribal Worldwide London"

  s.ios.deployment_target = "8.0"
  
  s.source       = { :git => "https://github.com/tribalworldwidelondon/PDFAuthor.git", :tag => "0.0.6" }
  s.source_files  = "Sources/PDFAuthor/**/*.{swift}"
  
  s.dependency "Cassowary", "~> 1.0.0"

end
