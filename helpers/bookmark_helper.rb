# -*- coding: utf-8 -*-

module BookmarkHelper
  #
  # Below using the all method from DataMapper
  #
  def get_all_bookmarks
    Bookmark.all(:order => :title)
  end

  def hslice(params, *wl)
    wl.inject({}) {|hr, key| hr.merge(key => params[key])}
  end

  # view and controller helpers
  #helpers do

  def h(text)
    Rack::Utils.escape_html(text)
  end

  def add_tags(bookmark)
    #
    labels = (params["tags_as_str"] || "").split(",").map(&:strip).map(&:downcase).sort     # get the tags
    #
    # Next, by iterating over the bookmark’s previously existing tags, we compare
    # with the new list of tags. We’ll keep track of matching tags and delete those
    # that previously existed but were not sent in the current request.
    #
    exist_labels = bookmark.bookmark_taggings.inject([]) do |ary, bktagging|
      if labels.include?(bktagging.tag.label)
        ary.push bktagging.tag.label
      else
        bktagging.destroy
        ary
      end
    end
    #
    (labels - exist_labels).each do |label|
      tag = {:label => label}
      existing = Tag.first tag
      existing = Tag.create tag unless existing
      BookmarkTagging.create tag: existing, bookmark: bookmark
    end
  end

  def my_render(request, html_tmpl, obj=@bookmark)
    request.accept.each do |type|
      case type.to_s
      when 'text/html'
        halt erb html_tmpl # @bookmark or @bookmarks

      when 'text/json'
      when 'application/json'
        halt obj.to_json with_tag_list # obj can be a collection or a single instance
      end

      # and otherwise:
      error 406
    end
  end

end
