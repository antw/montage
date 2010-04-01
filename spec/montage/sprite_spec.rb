require File.expand_path('../../spec_helper', __FILE__)

describe Montage::Sprite do
  subject { Montage::Sprite }

  it { should have_public_method_defined(:paths) }

  describe '#paths' do
    describe 'when the source files exist' do
      before(:all) do
        project = Montage::Project.new(
          fixture_path(:root_config),
          fixture_path(:root_config, 'montage.yml'))

        @paths = Montage::Sprite.new(
          'sprite', %w( source_one source_two source_three ),
          project.paths.sources).paths
      end

      it 'should return an array' do
        @paths.should be_kind_of(Array)
        @paths.should have(3).paths
      end

      it 'return the correct path when the source is a PNG' do
        @paths[0].should == Pathname.new(fixture_path(:root_config,
          'public/images/sprites/src/source_one.png'))
      end

      it 'return the correct path when the source has no extension' do
        @paths[1].should == Pathname.new(fixture_path(:root_config,
          'public/images/sprites/src/source_two'))
      end

      it 'return the correct path when the source is a JPG' do
        @paths[2].should == Pathname.new(fixture_path(:root_config,
          'public/images/sprites/src/source_three.jpg'))
      end
    end # when the source files exist

    describe 'when a source file is missing' do
      before(:all) do
        project = Montage::Project.new(
          fixture_path(:missing_source),
          fixture_path(:missing_source, 'montage.yml'))

        @sprite = Montage::Sprite.new(
          'sprite', %w( source_one ),
          project.paths.sources)
      end

      it 'should raise an error' do
        running = lambda { @sprite.paths }
        running.should raise_error(Montage::MissingSource, /source_one/)
      end
    end # when a source file is missing

    describe 'when the source directory is missing' do
      before(:all) do
        project = Montage::Project.new(
          fixture_path(:missing_source_dir),
          fixture_path(:missing_source_dir, 'montage.yml'))

        @sprite = Montage::Sprite.new(
          'sprite', %w( source_one ),
          project.paths.sources)
      end

      it 'should raise an error' do
        running = lambda { @sprite.paths }
        running.should raise_error(Montage::MissingSource, /source directory/)
      end
    end # when the source directory is missing

  end # paths

  it { should have_public_method_defined(:images) }

  describe '#images' do
    describe 'when the sprite contains no sources' do
      before(:all) do
        project = Montage::Project.new(
          fixture_path(:root_config),
          fixture_path(:root_config, 'montage.yml'))

        @sprite = Montage::Sprite.new('sprite', %w( ), project.paths.sources)
      end

      it 'should return an array' do
        @sprite.images.should be_kind_of(Array)
      end

      it 'should be empty' do
        @sprite.images.should be_empty
      end
    end

    describe 'when the sprite contains three sources' do
      before(:all) do
        project = Montage::Project.new(
          fixture_path(:root_config),
          fixture_path(:root_config, 'montage.yml'))

        @sprite = Montage::Sprite.new(
          'sprite', %w( source_one source_two source_three ),
          project.paths.sources)
      end

      it 'should return an array' do
        @sprite.images.should be_kind_of(Array)
        @sprite.images.should have(3).images
      end

      it 'should contain Magick::Image instances' do
        @sprite.images.each { |i| i.should be_kind_of(Magick::Image) }
      end
    end
  end # images

  it { should have_public_method_defined(:position_of) }

  describe '#images' do
    before(:all) do
      project = Montage::Project.new(
        fixture_path(:root_config),
        fixture_path(:root_config, 'montage.yml'))

      @sprite = Montage::Sprite.new(
        'sprite', %w( source_one source_two source_three ),
        project.paths.sources)
    end

    it 'should raise a MissingSource when the given source is not present' do
      running = lambda { @sprite.position_of('__invalid__') }
      running.should raise_error(Montage::MissingSource,
        "Source image '__invalid__' is not present in the 'sprite' sprite")
    end

    it 'should return an integer' do
      @sprite.position_of('source_one').should == 0
    end

    it 'should account for the padding' do
      # 1px source, plus 20px padding
      @sprite.position_of('source_two').should   == 21
      @sprite.position_of('source_three').should == 42
    end
  end # position_of

end
