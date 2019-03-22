require 'xcodeproj'
require 'pathname'

# Generate xcodeproj with Swift PM
%x(swift package generate-xcodeproj)

project = Xcodeproj::Project.open('parrot.xcodeproj')

parrot_target = project.targets.detect { |p| p.display_name == "parrot" }
parrot_test_target = project.targets.detect { |p| p.display_name == "parrotTests" }

if parrot_target.nil? or parrot_test_target.nil?
	raise "No parrot or parrot test target found."
end

# Add step to copy "test data" files
copy_build_phase = parrot_test_target.new_copy_files_build_phase
compile_sources_phase = parrot_test_target.source_build_phase

test_data_group = project.main_group['Tests'].new_group('testData')
bad_group = test_data_group.new_group('bad')
good_group = test_data_group.new_group('good')

test_data_files = Pathname.glob('Tests/bootTests/testData/**/*.*').map { |file|
	group = bad_group if file.realpath.to_s.include? '/bad/'
	group = good_group if file.realpath.to_s.include? '/good/'

	ref = group.new_file(file.to_s)
	copy_build_phase.add_file_reference(ref)
}

# Adding Objective-C files
boot_test_group = project.main_group['Tests'].new_group('bootTests')
test_data_files = Pathname.glob('Tests/bootTests/FunctionalBootTests*').map { |file|
	ref = boot_test_group.new_file(file.to_s)
	compile_sources_phase.add_file_reference(ref)
}

project.save