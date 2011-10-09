class AddMultipleToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :multiple, :boolean, :default => false
  end

  def self.down
    remove_column :items, :multiple
  end
end
