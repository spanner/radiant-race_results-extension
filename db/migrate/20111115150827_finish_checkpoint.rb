class FinishCheckpoint < ActiveRecord::Migration
  def self.up
    Race.all.each do |race|
      race.send :ensure_finish_checkpoint
      race.save
    end
  end
end
