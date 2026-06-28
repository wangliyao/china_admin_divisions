# frozen_string_literal: true

require "bundler/gem_tasks"
require "china_admin_divisions"

desc "下载最新行政区划数据"
task :download do
  ChinaAdminDivisions::Downloader.new.call
end

desc "显示数据统计信息"
task :stats do
  puts "中国行政区划数据统计:"
  stats = ChinaAdminDivisions::Query.stats
  puts "  省/直辖市: #{stats[:provinces]}"
  puts "  市/自治州: #{stats[:cities]}"
  puts "  区/县: #{stats[:districts]}"
  puts "  乡镇/街道: #{stats[:towns]}"
  if stats[:version]
    puts ""
    puts "数据版本: #{stats[:version][:source_updated_at]}"
    puts "下载时间: #{stats[:version][:downloaded_at]}"
  end
end

task default: :stats