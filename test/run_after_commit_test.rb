
require File.expand_path("../test_helper", __FILE__)

class RunAfterCommitTest < RunAfterCommit::TestCase
  def test_default
    test_model = TestModel.create!(:title => "Title")

    res = []

    test_model.after_save do
      run_after_commit { res << "Block 1" }
      run_after_commit { res << "Block 2" }
    end

    test_model.update_attributes! :title => "Another title"

    assert_equal ["Block 1", "Block 2"], res

    res.clear

     test_model.after_save do
      run_after_commit { res << "Block 3" }
      run_after_commit { res << "Block 4" }
    end

    test_model.update_attributes! :title => "Another new title"

    assert_equal ["Block 3", "Block 4"], res
  end

  def test_empty
    test_model = TestModel.create!(:title => "Title")

    res = []

    test_model.after_save do
      test_model.run_after_commit { res << "Block" }
    end

    test_model.update_attributes! :title => "Another title"

    assert_equal ["Block"], res

    res.clear

    test_model.update_attributes! :title => "Another new title"

    assert_equal [], res
  end

  def test_rollback
    test_model = TestModel.create!(:title => "Title")

    res = []

    ActiveRecord::Base.transaction do
      test_model.run_after_commit { res << "Block" }

      test_model.update_attributes! :title => "Another title"

      raise ActiveRecord::Rollback
    end

    assert_equal "Title", test_model.reload.title
    assert_equal [], res

    test_model.update_attributes! :title => "Another title"

    assert_equal [], res
  end

  def test_nested
    test_model_1 = TestModel.create!(:title => "Title 1")
    test_model_2 = TestModel.create!(:title => "Title 2")

    res = []

    ActiveRecord::Base.transaction do
      test_model_1.run_after_commit { res << "Block 1" }
      test_model_2.run_after_commit { res << "Block 2" }

      test_model_1.update_attributes! :title => "Another title 1"
      test_model_2.update_attributes! :title => "Another title 2"

      assert_equal [], res
    end

    assert_equal ["Block 1", "Block 2"], res

    res.clear

    ActiveRecord::Base.transaction do
      test_model_1.run_after_commit { res << "Block 3" }
      test_model_2.run_after_commit { res << "Block 4" }

      test_model_1.update_attributes! :title => "Another new title 1"
      test_model_2.update_attributes! :title => "Another new title 2"

      assert_equal [], res
    end

    assert_equal ["Block 3", "Block 4"], res
  end

  def test_instances
    test_model = TestModel.create!(:title => "Title")

    instance_1 = TestModel.find(test_model.id)
    instance_2 = TestModel.find(test_model.id)

    res = []

    ActiveRecord::Base.transaction do
      instance_1.run_after_commit { res << "Block 1" }
      instance_2.run_after_commit { res << "Block 2" }

      instance_1.update_attributes! :title => "Title 1"
      instance_2.update_attributes! :title => "Title 2"

      assert_equal [], res
    end

    assert_equal "Title 2", TestModel.find(test_model.id).title
    assert_equal ["Block 1", "Block 2"], res

    res.clear

    instance_1.update_attributes! :title => "Title 1"
    instance_2.update_attributes! :title => "Title 2"

    assert_equal [], res
  end
end

