# frozen_string_literal: true

module ChinaAdminDivisions
  # 查询服务 - 基于文件数据
  class Query
    class << self
      # 获取所有省份
      # @return [Array<Hash>] 省份列表 [{ code: "110000", name: "北京市", short_code: "11" }]
      def provinces
        ChinaAdminDivisions.provinces.map do |p|
          { code: p[:code], name: p[:name], short_code: p[:province] }
        end
      end

      # 根据省份代码获取城市列表
      # @param province_code [String] 省份代码 (2位或6位)
      # @return [Array<Hash>] 城市列表
      def cities(province_code)
        short_code = province_code.to_s[0, 2]
        ChinaAdminDivisions.cities
          .select { |c| c[:province].to_s == short_code }
          .map do |c|
            {
              code: c[:code],
              name: c[:name],
              province_code: short_code,
              city_code: c[:city]
            }
          end
      end

      # 根据城市代码获取区县列表
      # @param city_code [String] 城市代码 (4位或6位)
      # @return [Array<Hash>] 区县列表
      def districts(city_code)
        province_code = city_code.to_s[0, 2]
        city_short = city_code.to_s[2, 2] || city_code.to_s[4, 2]

        ChinaAdminDivisions.districts
          .select { |d| d[:province].to_s == province_code && d[:city].to_s == city_short }
          .map do |d|
            {
              code: d[:code],
              name: d[:name],
              province_code: province_code,
              city_code: "#{province_code}#{city_short}",
              area_code: d[:area]
            }
          end
      end

      # 根据区县代码获取乡镇街道列表
      # @param district_code [String] 区县代码 (6位)
      # @return [Array<Hash>] 乡镇街道列表
      def towns(district_code)
        province_code = district_code.to_s[0, 2]
        city_code = district_code.to_s[2, 2]
        area_code = district_code.to_s[4, 2]

        ChinaAdminDivisions.towns
          .select do |t|
            t[:province].to_s == province_code &&
            t[:city].to_s == city_code &&
            t[:area].to_s == area_code
          end
          .map do |t|
            full_code = "#{district_code}#{t[:town]}"
            {
              code: full_code,
              name: t[:name],
              province_code: province_code,
              city_code: "#{province_code}#{city_code}",
              district_code: district_code,
              town_code: t[:town]
            }
          end
      end

      # 根据完整代码获取地址链
      # @param code [String] 行政区划代码 (6位区县或12位乡镇)
      # @return [Hash] 完整地址信息
      def chain(code)
        code_str = code.to_s

        province_code = code_str[0, 2]
        city_short = code_str[2, 2]
        area_code = code_str[4, 2]
        town_code = code_str.length >= 12 ? code_str[6, 6] : nil

        result = {}

        # 省
        province_data = ChinaAdminDivisions.provinces.find { |p| p[:province].to_s == province_code }
        result[:province] = province_data ? { code: province_data[:code], name: province_data[:name] } : nil

        # 市
        city_data = ChinaAdminDivisions.cities.find { |c| c[:province].to_s == province_code && c[:city].to_s == city_short }
        result[:city] = city_data ? { code: city_data[:code], name: city_data[:name] } : nil

        # 区县
        district_data = ChinaAdminDivisions.districts.find { |d| d[:province].to_s == province_code && d[:city].to_s == city_short && d[:area].to_s == area_code }
        result[:district] = district_data ? { code: district_data[:code], name: district_data[:name] } : nil

        # 乡镇街道
        if town_code
          town_data = ChinaAdminDivisions.towns.find { |t| t[:province].to_s == province_code && t[:city].to_s == city_short && t[:area].to_s == area_code && t[:town].to_s == town_code }
          if town_data
            result[:town] = {
              code: "#{district_data&.dig(:code)}#{town_data[:town]}",
              name: town_data[:name]
            }
          end
        end

        result
      end

      # 搜索地址 (模糊匹配名称)
      # @param keyword [String] 搜索关键词
      # @param limit [Integer] 返回数量限制
      # @return [Array<Hash>] 搜索结果
      def search(keyword, limit: 50)
        results = []
        keyword_lower = keyword.to_s.downcase

        # 搜索省份
        ChinaAdminDivisions.provinces.each do |p|
          if p[:name].to_s.downcase.include?(keyword_lower)
            results << { level: :province, code: p[:code], name: p[:name], short_code: p[:province] }
          end
        end

        # 搜索城市
        ChinaAdminDivisions.cities.each do |c|
          if c[:name].to_s.downcase.include?(keyword_lower)
            results << { level: :city, code: c[:code], name: c[:name], province_code: c[:province] }
          end
        end

        # 搜索区县
        ChinaAdminDivisions.districts.each do |d|
          if d[:name].to_s.downcase.include?(keyword_lower)
            results << { level: :district, code: d[:code], name: d[:name], province_code: d[:province], city_code: d[:city] }
          end
        end

        # 搜索乡镇街道
        ChinaAdminDivisions.towns.each do |t|
          if t[:name].to_s.downcase.include?(keyword_lower)
            results << {
              level: :town,
              code: "#{t[:province]}#{t[:city]}#{t[:area]}#{t[:town]}",
              name: t[:name],
              province_code: t[:province],
              city_code: t[:city],
              district_code: "#{t[:province]}#{t[:city]}#{t[:area]}"
            }
          end
        end

        results.take(limit)
      end

      # 根据名称查找代码
      # @param name [String] 名称
      # @param level [Symbol] 层级 (:province, :city, :district, :town)
      # @return [String, nil] 代码
      def find_code(name, level: nil)
        name_lower = name.to_s.downcase

        case level
        when :province
          ChinaAdminDivisions.provinces.find { |p| p[:name].to_s.downcase == name_lower }&.dig(:code)
        when :city
          ChinaAdminDivisions.cities.find { |c| c[:name].to_s.downcase == name_lower }&.dig(:code)
        when :district
          ChinaAdminDivisions.districts.find { |d| d[:name].to_s.downcase == name_lower }&.dig(:code)
        when :town
          t = ChinaAdminDivisions.towns.find { |t| t[:name].to_s.downcase == name_lower }
          t ? "#{t[:province]}#{t[:city]}#{t[:area]}#{t[:town]}" : nil
        else
          # 不指定层级时，从底层向上查找
          find_code(name, level: :town) ||
          find_code(name, level: :district) ||
          find_code(name, level: :city) ||
          find_code(name, level: :province)
        end
      end

      # 验证代码是否存在
      # @param code [String] 行政区划代码
      # @return [Boolean]
      def valid?(code)
        code_str = code.to_s

        # 6位省级代码
        if code_str.length == 6 && code_str.end_with?("0000")
          ChinaAdminDivisions.provinces.any? { |p| p[:code].to_s == code_str }
        # 6位市级代码
        elsif code_str.length == 6 && code_str[2, 4].end_with?("00")
          ChinaAdminDivisions.cities.any? { |c| c[:code].to_s == code_str }
        # 6位区县级代码
        elsif code_str.length == 6
          ChinaAdminDivisions.districts.any? { |d| d[:code].to_s == code_str }
        # 12位乡镇街道代码
        elsif code_str.length == 12
          province = code_str[0, 2]
          city = code_str[2, 2]
          area = code_str[4, 2]
          town = code_str[6, 6]
          ChinaAdminDivisions.towns.any? { |t| t[:province].to_s == province && t[:city].to_s == city && t[:area].to_s == area && t[:town].to_s == town }
        else
          false
        end
      end

      # 统计信息
      # @return [Hash] 统计数据
      def stats
        {
          provinces: ChinaAdminDivisions.provinces.size,
          cities: ChinaAdminDivisions.cities.size,
          districts: ChinaAdminDivisions.districts.size,
          towns: ChinaAdminDivisions.towns.size,
          version: ChinaAdminDivisions.version_info
        }
      end
    end
  end
end