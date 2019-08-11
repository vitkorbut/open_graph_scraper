class OpenGraphService
  attr_accessor *%i(title type url images description site_name audios locales videos)

  def initialize(document)
    self.images = []
    self.audios = []
    self.locales = []
    self.videos = []

    parse_attributes(document)
  end

  def metadata
    {
      title: title,
      type: type,
      url: url,
      images: images,
      description: description,
      site_name: site_name,
      audios: audios,
      locales: locales,
      videos: videos
    }.compact.delete_if {|_, v| v.is_a?(Array) && v.empty? }
  end

  private

  def parse_attributes(document)
    document.xpath('//head/meta[starts-with(@property, \'og:\')]').each do |node|
      attribute_name = node.attribute('property').to_s.downcase.gsub('og:', '').tr('-', '_')
      content = node.attribute('content').to_s
      case attribute_name
        when /^image$/i
          images << {url: content}
        when /^image:(.+)/i
          images << {} unless images.last
          images.last[Regexp.last_match[1]] = content
        when /^audio$/i
          audios << {url: content}
        when /^audio:(.+)/i
          audios << {} unless audios.last
          audios.last[Regexp.last_match[1]] = content
        when /^locale/i
          locales << content
        when /^video$/i
          videos << {url: content}
        when /^video:(.+)/i
          videos << {} unless videos.last
          videos.last[Regexp.last_match[1]] = content
        else
          attribute_name.tr!(':', '_')
          instance_variable_set("@#{attribute_name}", content)
      end
    end
  end

  def attribute_exists(document, name)
    document.xpath("boolean(//head/meta[@property='og:#{name}'])")
  end
end
