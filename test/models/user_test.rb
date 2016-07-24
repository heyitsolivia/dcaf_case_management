require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Since this is a devise install, devise is handling
  # general stuff like creation timestamps etc.
  before do
    @user = create :user
  end

  describe 'basic validations' do
    it 'should be able to build an object' do
      assert @user.valid?
    end

    %w(email name).each do |attribute|
      it "should require content in #{attribute}" do
        @user[attribute.to_sym] = nil
        assert_not @user.valid?
        assert_equal "can't be blank",
                     @user.errors.messages[attribute.to_sym].first
      end
    end
  end

  describe 'call list methods' do
    before do
      @pregnancy = create :pregnancy
      @pregnancy_2 = create :pregnancy
      @user.pregnancies << @pregnancy
      @user.pregnancies << @pregnancy_2
      @user_2 = create :user
    end

    it 'should return recently_called_pregnancies accurately' do
      assert_equal 0, @user.recently_called_pregnancies.count
      @call = create :call, pregnancy: @pregnancy, created_by: @user
      assert_equal 1, @user.recently_called_pregnancies.count
    end

    it 'should return call_list_pregnancies accurately' do
      assert_equal 2, @user.call_list_pregnancies.count
      @call = create :call, pregnancy: @pregnancy, created_by: @user
      assert_equal 1, @user.call_list_pregnancies.count
      @call_2 = create :call, pregnancy: @pregnancy_2, created_by: @user_2
      assert_equal 1, @user.call_list_pregnancies.count
    end

    it 'should accurately flag a pregnancy as recently called or not' do
      refute @user.recently_called? @pregnancy
      @call = create :call, pregnancy: @pregnancy, created_by: @user
      assert @user.recently_called? @pregnancy
    end
  end

  describe 'pregnancy methods' do
    before do
      @pregnancy = create :pregnancy
      @pregnancy_2 = create :pregnancy
      @pregnancy_3 = create :pregnancy
    end

    it 'add pregnancy - should add a pregnancy to a set' do
      assert_difference '@user.pregnancies.count', 1 do
        @user.add_pregnancy @pregnancy
      end
    end

    it 'remove pregnancy - should remove a pregnancy from a set' do
      @user.add_pregnancy @pregnancy
      assert_difference '@user.pregnancies.count', -1 do
        @user.remove_pregnancy @pregnancy
      end
    end

    it 'reorder call list - should let you reorder a call list' do
      set_of_pregnancies = [@pregnancy, @pregnancy_2, @pregnancy_3]
      set_of_pregnancies.each { |preg| @user.add_pregnancy preg }
      assert_equal @user.pregnancies.first, @pregnancy

      new_order = [@pregnancy_3._id, @pregnancy._id, @pregnancy_2._id]
      @user.reorder_call_list new_order

      assert_equal @pregnancy_3, @user.ordered_pregnancies.first
      assert_equal @pregnancy, @user.ordered_pregnancies[1]
      assert_equal @pregnancy_2, @user.ordered_pregnancies[2]
    end
  end
end
