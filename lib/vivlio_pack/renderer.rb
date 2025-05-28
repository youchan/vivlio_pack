require "redcarpet"
require "rouge"
require "rouge/plugins/redcarpet"

module VivlioPack
  class Renderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet

    def initialize
      super
      @sec = 0
      @ch = 0
      @para = 0
    end

    def header(c, level)
      case level
      when 1
        @sec += 1
        @ch = 0
        @para = 0
        "<h1 id='sec#{@sec}'>#{c}</h1>\n\n"
      when 2
        @ch += 1
        @para = 0
        "<h2 id='ch#{@sec}-#{@ch}'>#{c}</h2>\n\n"
      when 3
        @para += 1
        "<h3 id='para#{@sec}-#{@ch}-#{@para}'>#{c}</h3>\n\n"
      when 4
        "<h4>#{c}</h4>\n\n"
      end
    end

    def paragraph(text)
      case text.strip
      when "[begin dialog]"
        @in_dialog = true
        return "<div class='dialog'>\n"
      when "[end dialog]"
        @in_dialog = false
        return "</div>\n"
      when "[page break]"
        return "<div class='page-break'></div>\n"
      when "[begin one-point]"
        return "<div><img src='images/onepoint_before.png' class='one-point'>\n"
      when "[end one-point]"
        return "<img src='images/onepoint_after.png' class='one-point'></div>\n"
      when /\A%([a-z][a-z0-9\-]*):(.*)/m
        return "<div class='#{$1}'>#{$2}</div>\n"
      end

      if @in_dialog
        case text
        when /^わかばちゃん「(.+)」$/
          return <<~HTML
            <div class="speech shinra">
            <div class="icon"></div>
            <div class="baloon">
            <p>#{$1}</p>
            </div>
            </div>
          HTML
        when /^黒猫先生「(.+)」$/
          return <<~HTML
            <div class="speech kuroneko">
            <div class="icon"></div>
            <div class="baloon">
            <p>#{$1}</p>
            </div>
            </div>
          HTML
        end
      end

      text = text.strip.gsub(/%([a-z][a-z0-9\-]*){(.*)}/, "<span class='\\1'>\\2</span>")
      "<p>#{text.gsub(/  $/, "<br>\n")}</p>\n"
    end

    def footnotes(content)
      content
    end

    def footnote_def(content, number)
      "<span class='footnote'>#{content}</span>"
    end

    def image(link, title, alt_text)
      name = File.basename(link, ".*")
      <<~HTML
        <figure>
          <img src="#{link}" alt="#{alt_text}" />
          <figcaption id="#{name}">#{alt_text}</figcaption>
        </figure>
      HTML
    end

    def onepoint(text)
      case text.strip
      when "[begin one-point]"
        return "<img src='images/onepoint_before.png' class='onepoint'>\n"
      when "[end one-point]"
        return "<img src='images/onepoint_after.png' class='onepoint'>\n"
      end
    end
  end
end
