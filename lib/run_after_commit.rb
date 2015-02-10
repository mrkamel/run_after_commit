
require "run_after_commit/version"

module RunAfterCommit
  def self.included(base)
    base.after_commit :run_after_commit_queue
    base.after_rollback :clear_after_commit_queue
  end

  def run_after_commit(method = nil, &block)
    after_commit_queue << Proc.new { send method } if method
    after_commit_queue << block if block

    run_after_commit_queue if self.class.connection.open_transactions.zero?

    true
  end

  protected

  def run_after_commit_queue
    after_commit_queue.each do |action|
      self.instance_eval(&action)
    end
  ensure
    clear_after_commit_queue
  end

  def after_commit_queue
    self.class.connection.instance_variable_get("@run_after_commit_queue") || self.class.connection.instance_variable_set("@run_after_commit_queue", [])
  end

  def clear_after_commit_queue
    self.class.connection.instance_variable_set "@run_after_commit_queue", []

    true
  end
end

