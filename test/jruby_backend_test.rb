# frozen_string_literal: true

require_relative "test_helper"

return unless RUBY_ENGINE == "jruby"

class JrubyBackendTest < Minitest::Spec
  it "loads the bundled shared library" do
    assert File.file?(Ntcharts::Native.library_path)
    assert_match(/\Antcharts v/, Ntcharts.version)
    refute_empty Ntcharts.upstream_version
  end

  it "retains native argument checks" do
    assert_raises(TypeError) { Ntcharts::Style.new.foreground(:red) }
    assert_raises(TypeError) { Ntcharts::Sparkline.new("20", 6) }
    assert_raises(TypeError) { Ntcharts::Sparkline.new(20, 6).push_all(:values) }
  end
end
