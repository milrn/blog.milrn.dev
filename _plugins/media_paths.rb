module Jekyll
  module MediaPaths
    def media_paths(html, media_subpath)
      return html if media_subpath.nil? || media_subpath.empty?

      baseurl = @context.registers[:site].config['baseurl'].to_s.sub(%r{/$}, '')
      prefix = "#{baseurl}/#{media_subpath.sub(%r{^/}, '').sub(%r{/$}, '')}/"
      html.gsub(/(<img\b[^>]*\bsrc=["'])(?!\/|https?:|data:)([^"']+)(["'])/i) do
        "#{$1}#{prefix}#{$2}#{$3}"
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::MediaPaths)
