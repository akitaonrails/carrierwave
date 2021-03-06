# encoding: utf-8

require 'spec_helper'

describe CarrierWave::Uploader do

  before do
    @uploader_class = Class.new(CarrierWave::Uploader::Base)
    @uploader = @uploader_class.new
  end

  after do
    FileUtils.rm_rf(public_path)
  end

  describe '#remove!' do
    before do
      @file = File.open(file_path('test.jpg'))

      CarrierWave.stub(:generate_cache_id).and_return('1390890634-26112-2122')

      @cached_file = double('a cached file')
      @cached_file.stub(:delete)

      @stored_file = double('a stored file')
      @stored_file.stub(:path).and_return('/path/to/somewhere')
      @stored_file.stub(:url).and_return('http://www.example.com')
      @stored_file.stub(:identifier).and_return('this-is-me')
      @stored_file.stub(:delete)

      @storage = double('a storage engine')
      @storage.stub(:store!).and_return(@stored_file)
      @storage.stub(:cache!).and_return(@cached_file)
      @storage.stub(:delete_dir!).with("uploads/tmp/#{CarrierWave.generate_cache_id}")

      @uploader_class.storage.stub(:new).and_return(@storage)
      @uploader.store!(@file)
    end

    it "should reset the current path" do
      @uploader.remove!
      @uploader.current_path.should be_nil
    end

    it "should not be cached" do
      @uploader.remove!
      @uploader.should_not be_cached
    end

    it "should reset the url" do
      @uploader.cache!(@file)
      @uploader.remove!
      @uploader.url.should be_nil
    end

    it "should reset the identifier" do
      @uploader.remove!
      @uploader.identifier.should be_nil
    end

    it "should delete the file" do
      @stored_file.should_receive(:delete)
      @uploader.remove!
    end

    it "should reset the cache_name" do
      @uploader.cache!(@file)
      @uploader.remove!
      @uploader.cache_name.should be_nil
    end

    it "should do nothing when trying to remove an empty file" do
      running { @uploader.remove! }.should_not raise_error
    end
  end

end
