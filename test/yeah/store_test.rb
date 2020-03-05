require 'test_helper'
require 'fileutils'

describe Yeah::Store do
  include TestHelpers::FakeFS

  let(:filename) { 'filename' }
  let(:store) do
    FileUtils.mkdir_p(Yeah::STORE_DIR)
    Yeah::Store.new(filename: filename)
  end

  before do
    store.set(one: '1', two: '2')
  end

  describe ".keys" do
    it 'should get keys' do
      assert_equal([:one, :two], store.keys)
    end
  end

  describe ".exists?" do
    it 'should return true if key exists' do
      assert(store.exists?(:one))
    end

    it 'should return false if key doesnt exists' do
      refute(store.exists?(:nothing))
    end
  end

  describe ".empty?" do
    it 'should return true if db is empty' do
      store.clear
      assert(store.empty?)
    end

    it 'should return false if db is not empty' do
      refute(store.empty?)
    end
  end

  describe ".delete" do
    it 'deletes entry with key' do
      assert(store.delete(:one))
      refute(store.exists?(:one))
      assert(store.exists?(:two))
    end
  end

  describe ".clear" do
    it 'should clear all entries' do
      assert(store.clear)
      refute(store.exists?(:one))
      refute(store.exists?(:two))
    end
  end

  describe ".get" do
    it 'should get values' do
      assert_equal('1', store.get(:one))
      assert_equal('2', store.get(:two))
    end
  end

  describe ".set" do
    it 'should set values' do
      store.db.transaction do
        assert_equal('1', store.db[:one])
        assert_equal('2', store.db[:two])
      end
    end
  end
end
