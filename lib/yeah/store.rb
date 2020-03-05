require 'pstore'

module Yeah
  class Store
    attr_reader :db

    def initialize(filename:)
      path = File.join(Yeah::STORE_DIR, filename)
      @db = PStore.new(path)
    end

    def keys
      db.transaction(true) { db.roots }
    end

    def exists?(key)
      db.transaction(true) { db.root?(key) }
    end

    def empty?
      db.transaction(true) { !db.roots.any? }
    end

    def delete(*args)
      db.transaction { args.each { |key| db.delete(key) } }
    end

    def clear
      delete(*keys)
    end

    def get(key)
      val = db.transaction(true) { db[key] }
      val = yield if val.nil? && block_given?
      val
    end

    def set(**args)
      db.transaction do
        args.each do |key, val|
          if val.nil?
            db.delete(key)
          else
            db[key] = val
          end
        end
      end
    end

    def each
      db.transaction do
        db.roots.each do |key|
          yield(key, db[key])
        end
      end
    end
  end
end
