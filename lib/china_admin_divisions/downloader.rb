# frozen_string_literal: true

require "net/http"
require "json"
require "fileutils"
require "time"

module ChinaAdminDivisions
  # 从网络下载最新行政区划数据
  class Downloader
    # 使用 jsdelivr CDN 加速访问 GitHub 数据
    DATA_SOURCES = {
      province: "https://cdn.jsdelivr.net/npm/province-city-china@latest/dist/province.json",
      city: "https://cdn.jsdelivr.net/npm/province-city-china@latest/dist/city.json",
      district: "https://cdn.jsdelivr.net/npm/province-city-china@latest/dist/area.json",
      town: "https://cdn.jsdelivr.net/npm/province-city-china@latest/dist/town.json"
    }.freeze

    attr_reader :output_dir

    def initialize(output_dir: nil)
      @output_dir = output_dir || ChinaAdminDivisions.data_dir
    end

    def call
      FileUtils.mkdir_p(@output_dir)

      puts "正在下载行政区划数据..."

      DATA_SOURCES.each do |key, url|
        puts "下载 #{key} 数据..."
        data = fetch_json(url)
        save_data(key, data)
      end

      save_version_info
      puts "下载完成! 数据保存至: #{@output_dir}"

      { success: true, output_dir: @output_dir }
    end

    private

    def fetch_json(url)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == "https"
      http.read_timeout = 30

      response = http.get(uri.request_uri)

      raise Error, "下载失败 #{url}: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def save_data(key, data)
      file_path = @output_dir.join("#{key_to_filename(key)}.json")
      file_path.write(JSON.pretty_generate(data))
    end

    def key_to_filename(key)
      case key
      when :province then "provinces"
      when :city then "cities"
      when :district then "districts"
      when :town then "towns"
      else key.to_s
      end
    end

    def save_version_info
      version_info = {
        downloaded_at: Time.now.iso8601,
        source: "province-city-china npm package (https://github.com/uiwjs/province-city-china)",
        data_source: "民政部、国家统计局、腾讯地图、高德地图",
        description: "中国行政区划数据，省/市/区县/乡镇街道四级联动"
      }

      @output_dir.join("version.json").write(JSON.pretty_generate(version_info))
    end
  end
end