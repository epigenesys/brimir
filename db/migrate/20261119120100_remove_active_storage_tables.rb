class RemoveActiveStorageTables < ActiveRecord::Migration[6.0]
  def up
    %w[active_storage_variant_records active_storage_attachments active_storage_blobs].each do |table|
      next unless table_exists?(table.to_sym)

      drop_table(table)
    end
  end

  def down; end
end
