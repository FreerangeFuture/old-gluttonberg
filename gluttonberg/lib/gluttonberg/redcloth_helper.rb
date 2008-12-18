
# extends the link textile markup to accept urls in the format of
#
#   asset:<id>
#   asset:<id>/thumb
#   asset:<id>/preview
#
#   where <id> is the id of a Gluttonberg::Asset object
#
#   the url is then replaced with the URL to the assets file. if the
#   thumb modifier is used then the url is the the assets thumbnail image,
#   if the preview modifier is used the url is to the assets large thumb image.
#
module RedCloth::Formatters::HTML
  alias_method :original_link, :link

  def link(opts)
    asset_patch_href(opts)
    original_link(opts)
  end

  def asset_patch_href(opts)
    # modify opts[:href] if it is asset:
    r = /(^asset:)(.[^\/]*)(\/(.*))?$/.match(opts[:href].downcase)
    if r then
      # r[0] = entire matched string
      # r[1] = asset id
      # r[4] = parameter passed

      # it's an asset link so get the number
      asset_id = r[2]
      param = r[4]
      asset = Gluttonberg::Asset.get(asset_id)
      if asset then
        if param == 'thumb' then
          opts[:href] = asset.thumb_small_url
        elsif param == 'preview' then
          opts[:href] = asset.thumb_large_url
        else
          opts[:href] = asset.url
        end
      end
    end
  end
end