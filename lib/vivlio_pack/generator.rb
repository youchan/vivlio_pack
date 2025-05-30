require "psych"
require "redcarpet"

require_relative "./renderer"
require_relative "./toc_renderer"

module VivlioPack
  class Generator
    def initialize(workdir)
      @workdir = File.expand_path(workdir)
      @names = Psych.load_file("articles.yaml")
      @markdown = Redcarpet::Markdown.new(Renderer, autolink: true, tables: true, fenced_code_blocks: true, footnotes: true)
    end

    def generate(html_path)
      file_paths = @names.map{|name| "#{@workdir}/articles/#{name}.md"}
      File.open(html_path, "w") do |html|
        html.write <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8">
            <link rel="stylesheet" type="text/css" href="contents/css/style.css">
            <link rel="stylesheet" type="text/css" href="contents/css/bw.css">
            <link href="https://fonts.googleapis.com/css?family=M+PLUS+Rounded+1c" rel="stylesheet">
          </head>
          <body>
        HTML

        html.write <<~HTML
            <div class="toc">
              <h1>目次</h1>
              #{TocRenderer.render(file_paths)}
            </div>
            <div class="page-break"></div>
        HTML

        file_paths.each do |path|
          File.open(path, "r") do |file|
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
