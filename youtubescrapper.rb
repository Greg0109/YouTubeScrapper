
require 'httparty'
require 'nokogiri'
require 'json'

Youtubescrapper = ''

class YouTubeScrapper
  def get_url_content(url)
      unparsed_page = HTTParty.get(url, {
                                    headers: { 'User-Agent' => 'Mozilla/5.0 (Windows NT x.y; rv:10.0) Gecko/20100101 Firefox/10.0' }
                                  })
      if !unparsed_page.body.nil? || !unparsed_page.body.empty?
        parsed_page = Nokogiri::HTML(unparsed_page.body)
        parsed_page
      else
        'Cannot retrieve content from the web. Please try again later'
      end
  end

  def get_videos_from_youtuber(youtuber)
    begin
      url = "https://youtube.com/user/#{youtuber}/videos"
      video_array = []
      xml_content = get_url_content(url).to_s.split('ytInitialData')
      filter_initial_data = xml_content[1].to_s.split(';</script><link rel="canonical"')
      data_filtered = filter_initial_data[0].to_s.sub! ' = {','{'
    rescue
      url = "https://youtube.com/c/#{youtuber}/videos"
      video_array = []
      xml_content = get_url_content(url).to_s.split('ytInitialData')
      filter_initial_data = xml_content[1].to_s.split(';</script><link rel="canonical"')
      data_filtered = filter_initial_data[0].to_s.sub! ' = {','{'
    end
    data = JSON.parse(data_filtered)
    data.each do |key, value|
      if key == 'contents'
        value.each do |renderer, rendervalues|
          rendervalues.each do |tabs, separation|
            separation.each do |link|
              link.each do |stuff|
                stuff[1].each do |morestuff, morestuffdes|
                  if morestuff == 'content'
                    morestuffdes.each do |title, des|
                      des.each do |item, itemsectionrenderer|
                        if item == 'contents'
                          itemsectionrenderer.each do |section|
                            section['itemSectionRenderer']['contents'].each do |video|
                              video.each do |videotitle, videodesc|
                                videodesc.each do |categories, items|
                                  if categories == 'items'
                                    items.each do |videospecs|
                                      videospecs.each do |stuffs, specs|
                                        if stuffs == 'continuationItemRenderer'
                                          break
                                        end
                                        video_hash = {}
                                        thumbnail = specs['thumbnail']['thumbnails'][0]['url']
                                        video_hash.store('thumbnail', thumbnail)
                                        title = specs['title']['runs'][0]['text']
                                        video_hash.store('title', title)
                                        videoId = specs['videoId']
                                        video_hash.store('videoid', videoId)
                                        videourl = "https://www.youtube.com/watch?v=#{videoId}"
                                        video_hash.store('videourl', videourl)
                                        published = specs['publishedTimeText']['simpleText']
                                        video_hash.store('publishedTimeText', published)
                                        duration = specs['thumbnailOverlays'][0]['thumbnailOverlayTimeStatusRenderer']['text']['simpleText']
                                        video_hash.store('duration', duration)    
                                        video_array.push(video_hash)
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    video_array
  end

  def get_search_videos(search_input)
    search_input = search_input.sub! ' ','+'
    search_input = "https://www.youtube.com/results?search_query=#{search_input}"
    video_array = []
    xml_content = get_url_content(search_input).to_s.split('ytInitialData')
    filter_initial_data = xml_content[-2].to_s.split(';</script>')
    data_filtered = filter_initial_data[0].to_s.sub! ' = {','{'
    data = JSON.parse(data_filtered)
    data.each do |key, value|
      if key == 'contents'
        value.each do |renderer, rendervalues|
          rendervalues.each do |tabs, separation|
            separation.each do |separations|
              separations.each do |key|
                if key != 'sectionListRenderer'
                  key.each do |list|
                    if list.to_s['video']
                      list[1].each do |morestuff|
                        morestuff.each do |title, des|
                          des.each do |item, itemcontentss|
                            if item == 'contents'
                              itemcontentss.each do |section|
                                section.each do |video, specs|
                                  begin
                                    video_hash = {}
                                    thumbnail = specs['thumbnail']['thumbnails'][0]['url']
                                    video_hash.store('thumbnail', thumbnail)
                                    title = specs['title']['runs'][0]['text']
                                    video_hash.store('title', title)
                                    videoId = specs['videoId']
                                    video_hash.store('videoid', videoId)
                                    videourl = "https://www.youtube.com/watch?v=#{videoId}"
                                    video_hash.store('videourl', videourl)
                                    published = specs['publishedTimeText']['simpleText']
                                    video_hash.store('publishedTimeText', published)
                                    duration = specs['thumbnailOverlays'][0]['thumbnailOverlayTimeStatusRenderer']['text']['simpleText']
                                    video_hash.store('duration', duration)    
                                    video_array.push(video_hash)
                                  rescue
                                    break
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    video_array
  end
end