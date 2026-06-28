# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "china_admin_divisions"
  spec.version = "1.0.0"
  spec.authors = ["OMS Team"]
  spec.email = ["oms@example.com"]
  spec.summary = "中国行政区划数据 (省/市/区/乡镇街道四级联动)"
  spec.description = "中国行政区划数据 gem，提供省/市/区县/乡镇街道四级联动查询。数据来源于民政部、国家统计局、腾讯地图、高德地图。"
  spec.homepage = "https://github.com/example/china_admin_divisions"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata = {
    "source_code_uri" => "https://github.com/example/china_admin_divisions"
  }

  spec.files = Dir["lib/**/*", "data/**/*", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]
end