require "psych"
require "redcarpet"

require_relative "./renderer"
require_relative "./toc_renderer"

module VivlioPack
  class Generator
    def initialize(workdir)
      @workdir = File.expand_path(workdir)
      puts @workdir
      @files = Psych.load_file("articles.yaml")
      @markdown = Redcarpet::Markdown.new(Renderer, autolink: true, tables: true, fenced_code_blocks: true, footnotes: true)
    end

    def generate(filepath)
      names = @files.map{|name| File.basename(name, ".md") }
      File.open(filepath, "w") do |html|
        html.write <<~HTML
          <html>
          <head>
            <link rel="stylesheet" type="text/css" href="css/style.css">
            <link rel="stylesheet" type="text/css" href="bw.css">
            <link href="https://fonts.googleapis.com/css?family=M+PLUS+Rounded+1c" rel="stylesheet">
          </head>
          <body>
        HTML

        html.write <<~HTML
            <div class="toc">
              <h1>目次</h1>
              #{TocRenderer.render(@files)}
            </div>
            <div class="page-break"></div>
        HTML

        @files.each do |name|
          File.open(@workdir + "/" + name, "r") do |file|
            html.write(@markdown.render(file.read))
          end
        end

        html.write <<~HTML
          </body>
          </html>
        HTML
      end
    end
  end
end
