# frozen_string_literal: true
# typed: ignore
# rubocop:disable all
# :nocov:

# Context: Bootsnap doesn't work with Ruby 3.3.1
# https://github.com/Shopify/bootsnap/issues/484
# https://github.com/ruby/ruby/pull/10619
# https://bugs.ruby-lang.org/issues/20450
# https://github.com/ruby/ruby/pull/10619#issuecomment-2075896240

if Gem.const_defined?(:BUNDLED_GEMS)
  mod = Gem.send(:remove_const, :BUNDLED_GEMS).dup
  Gem::BUNDLED_GEMS = mod
  def mod.warning?(name, specs: nil)
    # name can be a feature name or a file path with String or Pathname
    feature = File.path(name)
    # bootsnap expands `require "csv"` to `require "#{LIBDIR}/csv.rb"`,
    # and `require "syslog"` to `require "#{ARCHDIR}/syslog.so"`.
    name = feature.delete_prefix(Gem::BUNDLED_GEMS::ARCHDIR)
    name.delete_prefix!(Gem::BUNDLED_GEMS::LIBDIR)
    name.tr!("/", "-")
    name.sub!(Gem::BUNDLED_GEMS::LIBEXT, "")
    return if specs.include?(name)
    _t, path = $:.resolve_feature_path(feature)
    if gem = find_gem(path)
      return if specs.include?(gem)
      caller = caller_locations(3, 3)&.find {|c| c&.absolute_path}
      return if find_gem(caller&.absolute_path)
    elsif Gem::BUNDLED_GEMS::SINCE[name]
      gem = true
    else
      return
    end

    return if Gem::BUNDLED_GEMS::WARNED[name]
    Gem::BUNDLED_GEMS::WARNED[name] = true
    if gem == true
      gem = name
      "#{feature} was loaded from the standard library, but"
    elsif gem
      return if Gem::BUNDLED_GEMS::WARNED[gem]
      Gem::BUNDLED_GEMS::WARNED[gem] = true
      "#{feature} is found in #{gem}, which"
    else
      return
    end + build_message(gem)
  end
end
