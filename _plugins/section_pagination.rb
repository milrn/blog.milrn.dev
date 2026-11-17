# frozen_string_literal: true

module SectionPagination
  class Generator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      post_limit = site.config.fetch("paginate", 5).to_i
      term_limit = site.config.fetch("paginate_terms", 20).to_i
      raise ArgumentError, "Pagination sizes must be positive" if post_limit <= 0 || term_limit <= 0

      tabs = site.collections.fetch("tabs").docs
      paginate_tab(site, tabs, "categories", site.categories.to_a.sort_by { |name, _| name.downcase }, term_limit, "paged_terms")
      paginate_tab(site, tabs, "tags", site.tags.to_a.sort_by { |name, _| name.downcase }, term_limit, "paged_terms")

      site.pages.grep(Jekyll::Archives::Archive).each do |archive|
        next unless %w[tag category].include?(archive.type)

        base = archive.url
        posts = archive.posts
        total = page_count(posts, post_limit)
        archive.posts = posts.first(post_limit)
        archive.data["pagination"] = pagination(base, 1, total)

        (2..total).each do |number|
          add_page(site, url(base, number), {
            "layout" => "taxonomy",
            "title" => archive.title,
            "type" => archive.type,
            "posts" => posts.slice((number - 1) * post_limit, post_limit),
            "pagination" => pagination(base, number, total),
          })
        end
      end
    end

    private

    def paginate_tab(site, tabs, name, items, per_page, field)
      source = tabs.find { |tab| tab.basename_without_ext == name }
      return unless source

      base = "/#{name}/"
      total = page_count(items, per_page)
      source.data[field] = items.first(per_page)
      source.data["pagination"] = pagination(base, 1, total)

      (2..total).each do |number|
        add_page(site, url(base, number), {
          "layout" => name,
          "title" => source.data["title"],
          field => items.slice((number - 1) * per_page, per_page),
          "pagination" => pagination(base, number, total),
        })
      end
    end

    def add_page(site, path, data)
      directory = path.delete_prefix("/").delete_suffix("/")
      page = Jekyll::PageWithoutAFile.new(site, site.source, directory, "index.html")
      page.data.update(data)
      site.pages << page
    end

    def page_count(items, per_page)
      [(items.length + per_page - 1) / per_page, 1].max
    end

    def url(base, number)
      number == 1 ? base : "#{base}#{number}/"
    end

    def pagination(base, current, total)
      {
        "current" => current,
        "total_pages" => total,
        "previous_url" => current > 1 ? url(base, current - 1) : nil,
        "next_url" => current < total ? url(base, current + 1) : nil,
        "pages" => (1..total).map { |number| { "number" => number, "url" => url(base, number) } },
      }
    end
  end
end
