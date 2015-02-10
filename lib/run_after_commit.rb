
require "run_after_commit/version"

module RunAfterCommit
  def self.included(base)
    base.after_commit :run_after_commit_queue
    base.after_rollback :clear_after_commit_queue
  end

  def run_after_commit(method = nil, &block)
    transaction do
      after_commit_queue << Proc.new { self.send(method) } if method
      after_commit_queue << block if block
    end

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

  def after_commit_transaction
    @after_commit_transaction ||= self.class.connection.current_transaction
  end

  def after_commit_queue
    after_commit_transaction.instance_variable_get("@run_after_commit_queue") || after_commit_transaction.instance_variable_set("@run_after_commit_queue", [])
  end

  def clear_after_commit_queue
    old_transaction = after_commit_transaction

    @after_commit_transaction = nil

    old_transaction.instance_variable_set "@run_after_commit_queue", []
  end
end

