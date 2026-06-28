# frozen_string_literal: true

require_relative "china_admin_divisions/version"
require_relative "china_admin_divisions/query"
require_relative "china_admin_divisions/downloader"
require "json"
require "pathname"

module ChinaAdminDivisions
  class Error < StandardError; end

  class << self
    # 数据文件路径 (gem 根目录下的 data)
    def data_dir
      @data_dir ||= Pathname.new(__dir__).parent.join("data")
    end

    # 省份文件
    def provinces_file
      data_dir.join("provinces.json")
    end

    # 城市文件
    def cities_file
      data_dir.join("cities.json")
    end

    # 区县文件
    def districts_file
      data_dir.join("districts.json")
    end

    # 乡镇街道文件
    def towns_file
      data_dir.join("towns.json")
    end

    # 加载省份数据
    def provinces
      load_json(provinces_file)
    end

    # 加载城市数据
    def cities
      load_json(cities_file)
    end

    # 加载区县数据
    def districts
      load_json(districts_file)
    end

    # 加载乡镇街道数据
    def towns
      load_json(towns_file)
    end

    # 加载 JSON 文件
    def load_json(file_path)
      return [] unless file_path.exist?

      JSON.parse(file_path.read, symbolize_names: true)
    end

    # 获取数据版本信息
    def version_info
      version_file = data_dir.join("version.json")
      return {} unless version_file.exist?

      JSON.parse(version_file.read, symbolize_names: true)
    end

    # 刷新数据缓存
    def refresh
      @provinces = nil
      @cities = nil
      @districts = nil
      @towns = nil
    end
  end
end