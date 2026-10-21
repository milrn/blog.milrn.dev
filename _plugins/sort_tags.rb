module SortTags
  def sort_tags(tags)
    tags.to_a.sort_by { |name, _posts| name.to_s.downcase }
  end
end

Liquid::Template.register_filter(SortTags)
