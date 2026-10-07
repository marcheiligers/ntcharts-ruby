# frozen_string_literal: true

require "ffi"
require "json"
require "rbconfig"

# The JRuby backend mirrors the C extension over the same Go API.
# rubocop:disable Metrics/ModuleLength
module Ntcharts
  module Native
    extend FFI::Library

    class << self
      def library_path
        return ENV.fetch("NTCHARTS_LIBRARY_PATH") if ENV.key?("NTCHARTS_LIBRARY_PATH")

        extension = host_os == "darwin" ? "dylib" : "so"
        File.expand_path("../../go/build/#{host_os}_#{host_arch}/libntcharts.#{extension}", __dir__)
      end

      private

      def host_arch
        case RbConfig::CONFIG["host_cpu"]
        when /aarch64|arm64/ then "arm64"
        when /x86_64|amd64/ then "amd64"
        else RbConfig::CONFIG["host_cpu"]
        end
      end

      def host_os
        case RbConfig::CONFIG["host_os"]
        when /darwin/ then "darwin"
        when /linux/ then "linux"
        else
          raise LoadError, "ntcharts does not support JRuby on #{RbConfig::CONFIG["host_os"]}"
        end
      end
    end

    ffi_lib library_path

    attach_function :ntcharts_free, [:pointer], :void
    attach_function :ntcharts_upstream_version, [], :pointer

    attach_function :ntcharts_style_new, [], :ulong_long
    attach_function :ntcharts_style_free, [:ulong_long], :void
    attach_function :ntcharts_style_foreground, [:ulong_long, :string], :ulong_long
    attach_function :ntcharts_style_background, [:ulong_long, :string], :ulong_long
    attach_function :ntcharts_style_bold, [:ulong_long, :int], :ulong_long

    attach_function :ntcharts_sparkline_new, [:int, :int], :ulong_long
    attach_function :ntcharts_sparkline_free, [:ulong_long], :void
    attach_function :ntcharts_sparkline_width, [:ulong_long], :int
    attach_function :ntcharts_sparkline_height, [:ulong_long], :int
    attach_function :ntcharts_sparkline_max_value, [:ulong_long], :double
    attach_function :ntcharts_sparkline_scale, [:ulong_long], :double
    attach_function :ntcharts_sparkline_set_max, [:ulong_long, :double], :void
    attach_function :ntcharts_sparkline_set_style, [:ulong_long, :ulong_long], :void
    attach_function :ntcharts_sparkline_set_auto_max_value, [:ulong_long, :int], :void
    attach_function :ntcharts_sparkline_resize, [:ulong_long, :int, :int], :void
    attach_function :ntcharts_sparkline_clear, [:ulong_long], :void
    attach_function :ntcharts_sparkline_push, [:ulong_long, :double], :void
    attach_function :ntcharts_sparkline_push_all, [:ulong_long, :string], :void
    attach_function :ntcharts_sparkline_draw, [:ulong_long], :void
    attach_function :ntcharts_sparkline_draw_columns_only, [:ulong_long], :void
    attach_function :ntcharts_sparkline_draw_braille, [:ulong_long], :void
    attach_function :ntcharts_sparkline_view, [:ulong_long], :pointer

    attach_function :ntcharts_barchart_new, [:int, :int], :ulong_long
    attach_function :ntcharts_barchart_free, [:ulong_long], :void
    [:width, :height, :bar_width, :bar_gap, :show_axis, :horizontal].each do |name|
      attach_function :"ntcharts_barchart_#{name}", [:ulong_long], :int
    end
    [:max_value, :scale].each do |name|
      attach_function :"ntcharts_barchart_#{name}", [:ulong_long], :double
    end
    attach_function :ntcharts_barchart_set_max, [:ulong_long, :double], :void
    attach_function :ntcharts_barchart_set_bar_width, [:ulong_long, :int], :void
    attach_function :ntcharts_barchart_set_bar_gap, [:ulong_long, :int], :void
    [:horizontal, :show_axis, :auto_max_value, :auto_bar_width].each do |name|
      attach_function :"ntcharts_barchart_set_#{name}", [:ulong_long, :int], :void
    end
    [:axis_style, :label_style].each do |name|
      attach_function :"ntcharts_barchart_set_#{name}", [:ulong_long, :ulong_long], :void
    end
    attach_function :ntcharts_barchart_resize, [:ulong_long, :int, :int], :void
    attach_function :ntcharts_barchart_clear, [:ulong_long], :void
    attach_function :ntcharts_barchart_push, [:ulong_long, :string], :void
    attach_function :ntcharts_barchart_push_all, [:ulong_long, :string], :void
    attach_function :ntcharts_barchart_draw, [:ulong_long], :void
    attach_function :ntcharts_barchart_view, [:ulong_long], :pointer

    attach_function :ntcharts_linechart_new,
                    [:int, :int, :double, :double, :double, :double],
                    :ulong_long
    attach_function :ntcharts_linechart_new_with_auto_range, [:int, :int], :ulong_long
    attach_function :ntcharts_linechart_free, [:ulong_long], :void
    [:width, :height, :graph_width, :graph_height, :x_step, :y_step].each do |name|
      attach_function :"ntcharts_linechart_#{name}", [:ulong_long], :int
    end
    [:min_x, :max_x, :min_y, :max_y, :view_min_x, :view_max_x, :view_min_y, :view_max_y].each do |name|
      attach_function :"ntcharts_linechart_#{name}", [:ulong_long], :double
    end
    [:x_step, :y_step].each do |name|
      attach_function :"ntcharts_linechart_set_#{name}", [:ulong_long, :int], :void
    end
    [:x_range, :y_range].each do |name|
      attach_function :"ntcharts_linechart_set_#{name}", [:ulong_long, :double, :double], :void
      attach_function :"ntcharts_linechart_set_view_#{name}", [:ulong_long, :double, :double], :int
      attach_function :"ntcharts_linechart_set_auto_#{name}", [:ulong_long, :int, :int], :void
    end
    attach_function :ntcharts_linechart_resize, [:ulong_long, :int, :int], :void
    attach_function :ntcharts_linechart_clear, [:ulong_long], :void
    attach_function :ntcharts_linechart_draw_axes, [:ulong_long], :void
    attach_function :ntcharts_linechart_draw_rune, [:ulong_long, :double, :double, :int], :void
    attach_function :ntcharts_linechart_draw_rune_with_style,
                    [:ulong_long, :double, :double, :int, :ulong_long],
                    :void
    attach_function :ntcharts_linechart_draw_line,
                    [:ulong_long, :double, :double, :double, :double, :int],
                    :void
    attach_function :ntcharts_linechart_draw_line_with_style,
                    [:ulong_long, :double, :double, :double, :double, :int, :ulong_long],
                    :void
    attach_function :ntcharts_linechart_draw_braille_line,
                    [:ulong_long, :double, :double, :double, :double],
                    :void
    attach_function :ntcharts_linechart_draw_braille_line_with_style,
                    [:ulong_long, :double, :double, :double, :double, :ulong_long],
                    :void
    [:style, :axis_style, :label_style].each do |name|
      attach_function :"ntcharts_linechart_set_#{name}", [:ulong_long, :ulong_long], :void
    end
    attach_function :ntcharts_linechart_view, [:ulong_long], :pointer

    attach_function :ntcharts_wavelinechart_new, [:int, :int], :ulong_long
    attach_function :ntcharts_wavelinechart_free, [:ulong_long], :void
    [:width, :height, :graph_width, :graph_height].each do |name|
      attach_function :"ntcharts_wavelinechart_#{name}", [:ulong_long], :int
    end
    [:min_x, :max_x, :min_y, :max_y].each do |name|
      attach_function :"ntcharts_wavelinechart_#{name}", [:ulong_long], :double
    end
    [:y_range, :view_x_range, :view_y_range].each do |name|
      attach_function :"ntcharts_wavelinechart_set_#{name}", [:ulong_long, :double, :double], :void
    end
    attach_function :ntcharts_wavelinechart_resize, [:ulong_long, :int, :int], :void
    [:clear, :clear_all_data, :draw, :draw_all].each do |name|
      attach_function :"ntcharts_wavelinechart_#{name}", [:ulong_long], :void
    end
    attach_function :ntcharts_wavelinechart_clear_data_set, [:ulong_long, :string], :void
    attach_function :ntcharts_wavelinechart_plot, [:ulong_long, :double, :double], :void
    attach_function :ntcharts_wavelinechart_plot_data_set, [:ulong_long, :string, :double, :double], :void
    attach_function :ntcharts_wavelinechart_set_styles, [:ulong_long, :int, :ulong_long], :void
    attach_function :ntcharts_wavelinechart_set_data_set_styles,
                    [:ulong_long, :string, :int, :ulong_long],
                    :void
    [:style, :axis_style, :label_style].each do |name|
      attach_function :"ntcharts_wavelinechart_set_#{name}", [:ulong_long, :ulong_long], :void
    end
    attach_function :ntcharts_wavelinechart_view, [:ulong_long], :pointer

    attach_function :ntcharts_streamlinechart_new, [:int, :int], :ulong_long
    attach_function :ntcharts_streamlinechart_free, [:ulong_long], :void
    [:width, :height, :graph_width, :graph_height].each do |name|
      attach_function :"ntcharts_streamlinechart_#{name}", [:ulong_long], :int
    end
    [:min_y, :max_y].each do |name|
      attach_function :"ntcharts_streamlinechart_#{name}", [:ulong_long], :double
    end
    [:y_range, :view_y_range].each do |name|
      attach_function :"ntcharts_streamlinechart_set_#{name}", [:ulong_long, :double, :double], :void
    end
    attach_function :ntcharts_streamlinechart_resize, [:ulong_long, :int, :int], :void
    [:clear, :clear_data, :draw].each do |name|
      attach_function :"ntcharts_streamlinechart_#{name}", [:ulong_long], :void
    end
    attach_function :ntcharts_streamlinechart_push, [:ulong_long, :double], :void
    [:style, :axis_style, :label_style].each do |name|
      attach_function :"ntcharts_streamlinechart_set_#{name}", [:ulong_long, :ulong_long], :void
    end
    attach_function :ntcharts_streamlinechart_view, [:ulong_long], :pointer

    attach_function :ntcharts_timeserieslinechart_new, [:int, :int], :ulong_long
    attach_function :ntcharts_timeserieslinechart_free, [:ulong_long], :void
    [:width, :height, :graph_width, :graph_height].each do |name|
      attach_function :"ntcharts_timeserieslinechart_#{name}", [:ulong_long], :int
    end
    [:min_x, :max_x].each do |name|
      attach_function :"ntcharts_timeserieslinechart_#{name}", [:ulong_long], :long_long
    end
    [:min_y, :max_y].each do |name|
      attach_function :"ntcharts_timeserieslinechart_#{name}", [:ulong_long], :double
    end
    [:time_range, :view_time_range].each do |name|
      attach_function :"ntcharts_timeserieslinechart_set_#{name}",
                      [:ulong_long, :long_long, :long_long],
                      :void
    end
    [:y_range, :view_y_range].each do |name|
      attach_function :"ntcharts_timeserieslinechart_set_#{name}",
                      [:ulong_long, :double, :double],
                      :void
    end
    attach_function :ntcharts_timeserieslinechart_resize, [:ulong_long, :int, :int], :void
    [:clear, :clear_all_data, :draw, :draw_all, :draw_braille, :draw_braille_all].each do |name|
      attach_function :"ntcharts_timeserieslinechart_#{name}", [:ulong_long], :void
    end
    attach_function :ntcharts_timeserieslinechart_clear_data_set, [:ulong_long, :string], :void
    attach_function :ntcharts_timeserieslinechart_push, [:ulong_long, :long_long, :double], :void
    attach_function :ntcharts_timeserieslinechart_push_data_set,
                    [:ulong_long, :string, :long_long, :double],
                    :void
    attach_function :ntcharts_timeserieslinechart_set_line_style, [:ulong_long, :int], :void
    attach_function :ntcharts_timeserieslinechart_set_data_set_line_style,
                    [:ulong_long, :string, :int],
                    :void
    attach_function :ntcharts_timeserieslinechart_set_data_set_style,
                    [:ulong_long, :string, :ulong_long],
                    :void
    [:style, :axis_style, :label_style].each do |name|
      attach_function :"ntcharts_timeserieslinechart_set_#{name}", [:ulong_long, :ulong_long], :void
    end
    attach_function :ntcharts_timeserieslinechart_view, [:ulong_long], :pointer
  end

  module NativeObject
    def self.finalizer(handle, free_function)
      proc { Native.public_send(free_function, handle) }
    end

    private

    attr_reader :native_handle

    def initialize_native(handle, free_function)
      @native_handle = handle
      ObjectSpace.define_finalizer(self, NativeObject.finalizer(handle, free_function))
    end

    def native_get(name)
      Native.public_send("ntcharts_#{native_prefix}_#{name}", native_handle)
    end

    def native_mutate(name, *arguments)
      Native.public_send("ntcharts_#{native_prefix}_#{name}", native_handle, *arguments)
      self
    end

    def native_style(name, style)
      native_mutate(name, Ntcharts.__send__(:style_handle, style))
    end

    def native_view
      Ntcharts.__send__(:native_result, Native.public_send("ntcharts_#{native_prefix}_view", native_handle))
    end

    def native_prefix
      self.class.name.split("::").last.downcase
    end
  end

  class << self
    def upstream_version
      native_result(Native.ntcharts_upstream_version)
    end

    def version
      format(
        "ntcharts v%<version>s (upstream %<upstream>s) [Go native extension]",
        version: VERSION,
        upstream: upstream_version
      )
    end

    private

    def native_integer(value)
      integer = value.to_int
      raise TypeError, "can't convert #{value.class} to Integer" unless integer.is_a?(Integer)
      raise RangeError, "integer #{integer} too big to convert to `int'" unless (-2**31...(2**31)).cover?(integer)

      integer
    rescue NoMethodError
      raise TypeError, "no implicit conversion of #{value.class} into Integer"
    end

    def native_float(value)
      raise TypeError, "no implicit conversion to float from string" if value.is_a?(String)
      raise TypeError, "no implicit conversion to float from nil" if value.nil?

      Float(value)
    end

    def native_long_long(value)
      integer = value.to_int
      raise TypeError, "can't convert #{value.class} to Integer" unless integer.is_a?(Integer)
      raise RangeError, "bignum too big to convert into `long long'" unless (-2**63...(2**63)).cover?(integer)

      integer
    rescue NoMethodError
      raise TypeError, "no implicit conversion of #{value.class} into Integer"
    end

    def native_string(value)
      string = String.try_convert(value)
      raise TypeError, "no implicit conversion of #{value.class} into String" unless string
      raise ArgumentError, "string contains null byte" if string.include?("\0")

      string
    end

    def native_result(pointer)
      raise NoMemoryError, "native function returned a null pointer" if pointer.null?

      pointer.read_string.force_encoding(Encoding::UTF_8)
    ensure
      Native.ntcharts_free(pointer) if pointer && !pointer.null?
    end

    def style_handle(style)
      raise TypeError, "wrong argument type #{style.class} (expected Ntcharts::Style)" unless style.is_a?(Style)

      style.handle
    end

    def truthy(value)
      value ? 1 : 0
    end

    def time_value(value)
      native_long_long(value.is_a?(Time) ? value.to_i : value)
    end
  end

  class Style
    include NativeObject

    def initialize
      initialize_native(Native.ntcharts_style_new, :ntcharts_style_free)
    end

    def foreground(color)
      strict_string(color)
      self.class.__send__(:from_native_handle, Native.ntcharts_style_foreground(handle, color))
    end

    def background(color)
      strict_string(color)
      self.class.__send__(:from_native_handle, Native.ntcharts_style_background(handle, color))
    end

    def bold(value)
      self.class.__send__(:from_native_handle, Native.ntcharts_style_bold(handle, Ntcharts.__send__(:truthy, value)))
    end

    def handle
      native_handle
    end

    class << self
      private

      def from_native_handle(handle)
        allocate.tap { |style| style.__send__(:initialize_native, handle, :ntcharts_style_free) }
      end
    end

    private

    def strict_string(value)
      raise TypeError, "wrong argument type #{value.class} (expected String)" unless value.is_a?(String)
      raise ArgumentError, "string contains null byte" if value.include?("\0")
    end
  end

  class Sparkline
    include NativeObject

    def initialize(width, height)
      initialize_native(
        Native.ntcharts_sparkline_new(Ntcharts.__send__(:native_integer, width), Ntcharts.__send__(:native_integer, height)),
        :ntcharts_sparkline_free
      )
    end

    [:width, :height, :max_value, :scale].each do |name|
      define_method(name) { native_get(name) }
    end

    def max=(value)
      native_mutate(:set_max, Ntcharts.__send__(:native_float, value))
    end

    def _set_style(style)
      native_style(:set_style, style)
    end

    def auto_max_value=(value)
      native_mutate(:set_auto_max_value, Ntcharts.__send__(:truthy, value))
    end

    def resize(width, height)
      native_mutate(:resize, Ntcharts.__send__(:native_integer, width), Ntcharts.__send__(:native_integer, height))
    end

    def clear
      native_mutate(:clear)
    end

    def push(value)
      native_mutate(:push, Ntcharts.__send__(:native_float, value))
    end

    def push_all(values)
      raise TypeError, "wrong argument type #{values.class} (expected Array)" unless values.is_a?(Array)

      native_mutate(:push_all, values.to_json)
    end

    [:draw, :draw_columns_only, :draw_braille].each do |name|
      define_method(name) { native_mutate(name) }
    end

    def view
      native_view
    end

    alias to_s view
  end

  class Barchart
    include NativeObject

    def initialize(width, height)
      initialize_native(
        Native.ntcharts_barchart_new(Ntcharts.__send__(:native_integer, width), Ntcharts.__send__(:native_integer, height)),
        :ntcharts_barchart_free
      )
    end

    [:width, :height, :max_value, :scale, :bar_width, :bar_gap].each do |name|
      define_method(name) { native_get(name) }
    end

    def show_axis?
      native_get(:show_axis) != 0
    end

    def horizontal?
      native_get(:horizontal) != 0
    end

    def max=(value)
      native_mutate(:set_max, Ntcharts.__send__(:native_float, value))
    end

    def bar_width=(value)
      native_mutate(:set_bar_width, Ntcharts.__send__(:native_integer, value))
    end

    def bar_gap=(value)
      native_mutate(:set_bar_gap, Ntcharts.__send__(:native_integer, value))
    end

    [:horizontal, :show_axis, :auto_max_value, :auto_bar_width].each do |name|
      define_method("#{name}=") { |value| native_mutate("set_#{name}", Ntcharts.__send__(:truthy, value)) }
    end

    def _set_axis_style(style)
      native_style(:set_axis_style, style)
    end

    def _set_label_style(style)
      native_style(:set_label_style, style)
    end

    def resize(width, height)
      native_mutate(:resize, Ntcharts.__send__(:native_integer, width), Ntcharts.__send__(:native_integer, height))
    end

    def clear
      native_mutate(:clear)
    end

    def _push(data)
      native_mutate(:push, Ntcharts.__send__(:native_string, data.to_json))
    end

    def _push_all(data)
      raise TypeError, "wrong argument type #{data.class} (expected Array)" unless data.is_a?(Array)

      native_mutate(:push_all, Ntcharts.__send__(:native_string, data.to_json))
    end

    def draw
      native_mutate(:draw)
    end

    def view
      native_view
    end

    alias to_s view
  end

  class Linechart
    include NativeObject

    LINE_STYLE_THIN = 0
    LINE_STYLE_ARC = 1

    def initialize(*arguments)
      handle = case arguments.length
               when 2
                 Native.ntcharts_linechart_new_with_auto_range(
                   Ntcharts.__send__(:native_integer, arguments[0]), Ntcharts.__send__(:native_integer, arguments[1])
                 )
               when 6
                 Native.ntcharts_linechart_new(
                   Ntcharts.__send__(:native_integer, arguments[0]), Ntcharts.__send__(:native_integer, arguments[1]),
                   *arguments.drop(2).map { |value| Ntcharts.__send__(:native_float, value) }
                 )
               else
                 raise ArgumentError,
                       "wrong number of arguments (given #{arguments.length}, expected 2 or 6)"
               end
      initialize_native(handle, :ntcharts_linechart_free)
    end

    [
      :width, :height, :graph_width, :graph_height, :min_x, :max_x, :min_y, :max_y, :view_min_x, :view_max_x, :view_min_y, :view_max_y, :x_step, :y_step
    ].each do |name|
      define_method(name) { native_get(name) }
    end

    [:x_step, :y_step].each do |name|
      define_method("#{name}=") { |value| native_mutate("set_#{name}", Ntcharts.__send__(:native_integer, value)) }
    end

    [:x_range, :y_range].each do |name|
      define_method("set_#{name}") do |minimum, maximum|
        native_mutate("set_#{name}", Ntcharts.__send__(:native_float, minimum), Ntcharts.__send__(:native_float, maximum))
      end

      define_method("set_view_#{name}") do |minimum, maximum|
        native_getter = "ntcharts_linechart_set_view_#{name}"
        Native.public_send(native_getter, native_handle,
                           Ntcharts.__send__(:native_float, minimum), Ntcharts.__send__(:native_float, maximum)) != 0
      end

      define_method("set_auto_#{name}") do |auto_minimum, auto_maximum|
        native_mutate("set_auto_#{name}", Ntcharts.__send__(:truthy, auto_minimum), Ntcharts.__send__(:truthy, auto_maximum))
      end
    end

    def resize(width, height)
      native_mutate(:resize, Ntcharts.__send__(:native_integer, width), Ntcharts.__send__(:native_integer, height))
    end

    [:clear, :draw_axes].each do |name|
      define_method(name) { native_mutate(name) }
    end

    def draw_rune(*arguments)
      check_argument_count(arguments.length, 3, 4)
      x, y, rune, style = arguments
      string = String.try_convert(rune)
      rune = string ? Ntcharts.__send__(:native_string, string).getbyte(0).to_i : Ntcharts.__send__(:native_integer, rune)
      arguments = [Ntcharts.__send__(:native_float, x), Ntcharts.__send__(:native_float, y), rune]
      return native_mutate(:draw_rune, *arguments) if style.nil?

      native_mutate(:draw_rune_with_style, *arguments, Ntcharts.__send__(:style_handle, style))
    end

    def draw_line(*method_arguments)
      check_argument_count(method_arguments.length, 4, 6)
      x1, y1, x2, y2, line_style, style = method_arguments
      arguments = [x1, y1, x2, y2].map { |value| Ntcharts.__send__(:native_float, value) }
      arguments << (line_style.nil? ? LINE_STYLE_THIN : Ntcharts.__send__(:native_integer, line_style))
      return native_mutate(:draw_line, *arguments) if style.nil?

      native_mutate(:draw_line_with_style, *arguments, Ntcharts.__send__(:style_handle, style))
    end

    def draw_braille_line(*method_arguments)
      check_argument_count(method_arguments.length, 4, 5)
      x1, y1, x2, y2, style = method_arguments
      arguments = [x1, y1, x2, y2].map { |value| Ntcharts.__send__(:native_float, value) }
      return native_mutate(:draw_braille_line, *arguments) if style.nil?

      native_mutate(:draw_braille_line_with_style, *arguments, Ntcharts.__send__(:style_handle, style))
    end

    [:style, :axis_style, :label_style].each do |name|
      define_method("_set_#{name}") { |style| native_style("set_#{name}", style) }
    end

    def view
      native_view
    end

    alias to_s view

    private

    def check_argument_count(count, minimum, maximum)
      return if (minimum..maximum).cover?(count)

      raise ArgumentError, "wrong number of arguments (given #{count}, expected #{minimum}..#{maximum})"
    end
  end

  class Wavelinechart
    include NativeObject

    LINE_STYLE_THIN = 0
    LINE_STYLE_ARC = 1

    def initialize(width, height)
      initialize_native(
        Native.ntcharts_wavelinechart_new(Ntcharts.__send__(:native_integer, width), Ntcharts.__send__(:native_integer, height)),
        :ntcharts_wavelinechart_free
      )
    end

    [:width, :height, :graph_width, :graph_height, :min_x, :max_x, :min_y, :max_y].each do |name|
      define_method(name) { native_get(name) }
    end

    [:y_range, :view_x_range, :view_y_range].each do |name|
      define_method("set_#{name}") do |minimum, maximum|
        native_mutate("set_#{name}", Ntcharts.__send__(:native_float, minimum), Ntcharts.__send__(:native_float, maximum))
      end
    end

    def resize(width, height)
      native_mutate(:resize, Ntcharts.__send__(:native_integer, width), Ntcharts.__send__(:native_integer, height))
    end

    [:clear, :clear_all_data].each do |name|
      define_method(name) { native_mutate(name) }
    end

    def clear_data_set(name)
      native_mutate(:clear_data_set, Ntcharts.__send__(:native_string, name))
    end

    def plot(x, y)
      native_mutate(:plot, Ntcharts.__send__(:native_float, x), Ntcharts.__send__(:native_float, y))
    end

    def plot_data_set(name, x, y)
      native_mutate(:plot_data_set, Ntcharts.__send__(:native_string, name),
                    Ntcharts.__send__(:native_float, x), Ntcharts.__send__(:native_float, y))
    end

    def set_styles(line_style, style)
      native_mutate(:set_styles, Ntcharts.__send__(:native_integer, line_style), Ntcharts.__send__(:style_handle, style))
    end

    def set_data_set_styles(name, line_style, style)
      native_mutate(:set_data_set_styles, Ntcharts.__send__(:native_string, name),
                    Ntcharts.__send__(:native_integer, line_style), Ntcharts.__send__(:style_handle, style))
    end

    [:style, :axis_style, :label_style].each do |name|
      define_method("_set_#{name}") { |style| native_style("set_#{name}", style) }
    end

    [:draw, :draw_all].each do |name|
      define_method(name) { native_mutate(name) }
    end

    def view
      native_view
    end

    def render
      draw
      view
    end

    def render_all
      draw_all
      view
    end

    alias to_s view
  end

  class Streamlinechart
    include NativeObject

    LINE_STYLE_THIN = 0
    LINE_STYLE_ARC = 1

    def initialize(width, height)
      initialize_native(
        Native.ntcharts_streamlinechart_new(Ntcharts.__send__(:native_integer, width), Ntcharts.__send__(:native_integer, height)),
        :ntcharts_streamlinechart_free
      )
    end

    [:width, :height, :graph_width, :graph_height, :min_y, :max_y].each do |name|
      define_method(name) { native_get(name) }
    end

    [:y_range, :view_y_range].each do |name|
      define_method("set_#{name}") do |minimum, maximum|
        native_mutate("set_#{name}", Ntcharts.__send__(:native_float, minimum), Ntcharts.__send__(:native_float, maximum))
      end
    end

    def resize(width, height)
      native_mutate(:resize, Ntcharts.__send__(:native_integer, width), Ntcharts.__send__(:native_integer, height))
    end

    [:clear, :clear_data].each do |name|
      define_method(name) { native_mutate(name) }
    end

    def push(value)
      native_mutate(:push, Ntcharts.__send__(:native_float, value))
    end

    [:style, :axis_style, :label_style].each do |name|
      define_method("_set_#{name}") { |style| native_style("set_#{name}", style) }
    end

    def draw
      native_mutate(:draw)
    end

    def view
      native_view
    end

    def render
      draw
      view
    end

    alias to_s view
  end

  class Timeserieslinechart
    include NativeObject

    LINE_STYLE_THIN = 0
    LINE_STYLE_ARC = 1

    def initialize(width, height)
      initialize_native(
        Native.ntcharts_timeserieslinechart_new(
          Ntcharts.__send__(:native_integer, width), Ntcharts.__send__(:native_integer, height)
        ),
        :ntcharts_timeserieslinechart_free
      )
    end

    [:width, :height, :graph_width, :graph_height, :min_y, :max_y].each do |name|
      define_method(name) { native_get(name) }
    end

    def min_x
      Time.at(native_get(:min_x))
    end

    def max_x
      Time.at(native_get(:max_x))
    end

    [:time_range, :view_time_range].each do |name|
      define_method("set_#{name}") do |minimum, maximum|
        native_mutate("set_#{name}", Ntcharts.__send__(:time_value, minimum), Ntcharts.__send__(:time_value, maximum))
      end
    end

    [:y_range, :view_y_range].each do |name|
      define_method("set_#{name}") do |minimum, maximum|
        native_mutate("set_#{name}", Ntcharts.__send__(:native_float, minimum), Ntcharts.__send__(:native_float, maximum))
      end
    end

    def resize(width, height)
      native_mutate(:resize, Ntcharts.__send__(:native_integer, width), Ntcharts.__send__(:native_integer, height))
    end

    [:clear, :clear_all_data].each do |name|
      define_method(name) { native_mutate(name) }
    end

    def clear_data_set(name)
      native_mutate(:clear_data_set, Ntcharts.__send__(:native_string, name))
    end

    def push(time, value)
      native_mutate(:push, Ntcharts.__send__(:time_value, time), Ntcharts.__send__(:native_float, value))
    end

    def push_data_set(name, time, value)
      native_mutate(:push_data_set, Ntcharts.__send__(:native_string, name),
                    Ntcharts.__send__(:time_value, time), Ntcharts.__send__(:native_float, value))
    end

    def line_style=(line_style)
      native_mutate(:set_line_style, Ntcharts.__send__(:native_integer, line_style))
    end

    def _set_style(style)
      native_style(:set_style, style)
    end

    def set_data_set_line_style(name, line_style)
      native_mutate(:set_data_set_line_style, Ntcharts.__send__(:native_string, name), Ntcharts.__send__(:native_integer, line_style))
    end

    def set_data_set_style(name, style)
      native_mutate(:set_data_set_style, Ntcharts.__send__(:native_string, name), Ntcharts.__send__(:style_handle, style))
    end

    [:axis_style, :label_style].each do |name|
      define_method("_set_#{name}") { |style| native_style("set_#{name}", style) }
    end

    [:draw, :draw_all, :draw_braille, :draw_braille_all].each do |name|
      define_method(name) { native_mutate(name) }
    end

    def view
      native_view
    end

    def render
      draw
      view
    end

    def render_all
      draw_all
      view
    end

    def render_braille
      draw_braille
      view
    end

    def render_braille_all
      draw_braille_all
      view
    end

    alias to_s view
  end
end
# rubocop:enable Metrics/ModuleLength
