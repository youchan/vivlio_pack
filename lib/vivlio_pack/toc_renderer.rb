module VivlioPack
  class TocRenderer < Redcarpet::Render::Base
    def initialize
      super
      @sec = 0
      @ch = 0
    end

    def header(c, level)
      case level
      when 1
        @sec += 1
        @ch = 0

        "<a href='#sec#{@sec}'>#{c}</a>\n<ol>"
      when 2
        @ch += 1
        "<li><a href='#ch#{@sec}-#{@ch}'>#{c}</a></li>\n"
      end
    end

    def self.render(files)
      renderer = TocRenderer.new
      markdown = Redcarpet::Markdown.new(renderer, fenced_code_blocks: true)

      toc = []
      files.each do |path|
        File.open(path, "r") do |file|
          toc << markdown.render(file.read)
        end
      end
      <<~TOC
        <nav class="toc">
          <ol>
          #{toc.map{|c| "<li>#{c}</li>\n</ol>"}.join("\n")}
          </ol>
        </nav>
      TOC
    end
  end
end
