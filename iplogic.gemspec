Gem::Specification.new do |s|
  s.name = 'iplogic'
  s.version = '0.1.2'

  s.authors = ["Jay Adkisson"]
  s.date = '2010-11-13'
  s.description = <<-desc.strip
    An IPv4 swiss-army chainsaw
  desc

  s.email = %q{jay@causes.com}
  s.extra_rdoc_files = %w(
    LICENSE
    README.md
  )

  s.files = %w(
    Rakefile
    LICENSE
    README.md
    iplogic.gemspec
    lib/iplogic.rb
    lib/core_ext.rb
    lib/core_ext/fixnum.rb
    lib/iplogic/cidr.rb
    lib/iplogic/ip.rb
  )

  s.homepage = 'http://github.com/causes/iplogic'
  s.require_paths = ["lib"]
  s.rubygems_version = '1.3.7'

  s.summary = <<-sum
    Because it's just a 32-bit integer.
  sum

  s.test_files = %w(
    spec/ip_spec.rb
    spec/cidr_spec.rb
    spec/spec_helper.rb
    spec/radix_spec.rb
  )

  s.add_development_dependency('rspec', '~> 1.0')
end

