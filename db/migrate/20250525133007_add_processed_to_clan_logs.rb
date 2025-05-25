class AddProcessedToClanLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :clan_logs, :processed, :boolean
  end
end
