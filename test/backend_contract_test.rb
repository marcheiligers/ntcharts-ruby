# frozen_string_literal: true

require_relative "test_helper"

class BackendContractTest < Minitest::Spec
  it "builds immutable styles" do
    style = Ntcharts::Style.new
    styled = style.foreground("#ff0000").background("#000000").bold(true)

    assert_kind_of Integer, style.handle
    assert_kind_of Ntcharts::Style, styled
    refute_equal style.handle, styled.handle
  end

  it "renders sparklines" do
    chart = Ntcharts::Sparkline.new(20, 6)

    assert_same chart, chart.push(1.0)
    assert_same chart, chart.push_all([2.0, 3.0])
    assert_same chart, chart.draw
    assert_equal 20, chart.width
    assert_equal 6, chart.height
    assert_kind_of String, chart.view
    assert_raises(TypeError) { chart.push("4.0") }
  end

  it "renders bar charts" do
    chart = Ntcharts::Barchart.new(30, 8)
    data = Ntcharts::BarData.new(label: "Ruby", values: [{ value: 10.0 }])

    assert_same chart, chart.push(data)
    assert_same chart, chart.push(label: "Go", values: [{ value: 8.0 }])
    assert_kind_of String, chart.render
  end

  it "draws line charts" do
    style = Ntcharts::Style.new.foreground("#ff0000")
    chart = Ntcharts::Linechart.new(30, 8, 0.0, 10.0, 0.0, 10.0)

    assert_same chart, chart.draw_rune(1.0, 1.0, "*")
    assert_same chart, chart.draw_line(1.0, 1.0, 5.0, 5.0, Ntcharts::Linechart::LINE_STYLE_ARC, style)
    assert_same chart, chart.draw_braille_line(1.0, 1.0, 5.0, 5.0)
    assert_same chart, chart.draw_axes
    assert_kind_of String, chart.view
    assert_raises(ArgumentError) { chart.draw_rune(1.0, 1.0, "*\0") }
    assert_raises(TypeError) { chart.draw_line(1.0, 1.0, 5.0, 5.0, nil, false) }
  end

  it "renders wave and stream line charts" do
    wave = Ntcharts::Wavelinechart.new(30, 8)
    stream = Ntcharts::Streamlinechart.new(30, 8)

    assert_same wave, wave.plot(1.0, 2.0)
    assert_same wave, wave.plot_data_set("other", 1.0, 3.0)
    assert_kind_of String, wave.render_all

    assert_same stream, stream.push(2.0)
    assert_kind_of String, stream.render
  end

  it "renders time-series line charts" do
    chart = Ntcharts::Timeserieslinechart.new(40, 8)
    now = Time.at(1_700_000_000)

    assert_same chart, chart.push(now, 2.0)
    assert_same chart, chart.push_data_set("other", now + 60, 3.0)
    assert_kind_of Time, chart.min_x
    assert_kind_of String, chart.render_braille_all
  end
end
