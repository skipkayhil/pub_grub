module PubGrub
  class Strategy
    def initialize(source)
      @source = source

      @root_package = Package.root
      @root_version = Package.root_version

      @version_indexes = Hash.new do |h,k|
        if k == @root_package
          h[k] = { @root_version => 0 }
        else
          h[k] = @source.all_versions_for(k).each.with_index.to_h
        end
      end
    end

    def next_package_and_version(unsatisfied)
      package, range = next_term_to_try_from(unsatisfied)

      [package, most_preferred_version_of(package, range)]
    end

    private

    def most_preferred_version_of(package, range)
      versions = @source.partitioned_versions_for(package, range)[1]

      indexes = @version_indexes[package]
      versions.min_by { |version| indexes[version] }
    end

    def next_term_to_try_from(unsatisfied)
      unsatisfied.min_by do |package, range|
        _, matching, higher = @source.partitioned_versions_for(package, range)

        [matching.count <= 1 ? 0 : 1, higher.count]
      end
    end
  end
end
