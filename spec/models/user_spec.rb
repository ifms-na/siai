# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string           default(""), not null
#  name                   :string
#  siape                  :integer
#  sector_id              :integer
#

require 'rails_helper'
require "cancan/matchers"

RSpec.describe User, type: :model do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  # Validations
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:sector) }
  it { should validate_presence_of(:username) }

  # Associations
  it { should belong_to(:sector) }

  # Methods
  describe '#it_is_part_of_the_sector?' do
    it 'return true if the sector is currect' do
      expect(@user.it_is_part_of_the_sector?('serti')).to eq(true)
    end

    it 'return false if the sector is not currect' do
      expect(@user.it_is_part_of_the_sector?('wrong_sector')).to eq(false)
    end
  end

  describe '#search' do
    it "find user by name" do
      expect(User.search(@user.name)).to eq([@user])
    end

    it "find user by email" do
      expect(User.search(@user.email)).to eq([@user])
    end

    it "find user by sector" do
      expect(User.search(@user.sector.initial)).to eq([@user])
    end
  end

  describe ".ordenation_attributes" do
    ordenation_attributes = User.ordenation_attributes

    it "should return an array" do
      expect(ordenation_attributes).to be_an_instance_of(Array)

      ordenation_attributes.each do |attribute|
        expect(attribute).to be_an_instance_of(Array)
      end
    end

    ordenation_attributes.each do |attribute|
      it "should return user attribute #{attribute}" do
        expect(User.attribute_names.include?(attribute.last)).to be true
      end
    end
  end

  describe "ability" do
    context "user with sector 'Serti' " do
      sector = 'serti'
      ['Student', 'Course', 'Keypass', 'Sector', 'User'].each do |entity|
        it "should be able to manager entity #{entity}" do
          @ability = Ability.new(create_user_by_sector(sector))
          expect(@ability).to be_able_to(:manager, eval(entity))
        end
      end
    end

    context "user with sector 'Audi' " do
      sector = 'audi'
      it "should be able to manager entity Student" do
        @ability = Ability.new(create_user_by_sector(sector))
        expect(@ability).to be_able_to(:manager, Student)
      end

      ['Course', 'Keypass', 'Sector', 'User'].each do |entity|
        it "should not be able to manager entity #{entity}" do
          @ability = Ability.new(create_user_by_sector(sector))
          expect(@ability).not_to be_able_to(:manager, eval(entity))
        end
      end
    end

    context "user with sector 'Prof' " do
      sector = 'prof'
      it "should be able to read entity Student" do
        @ability = Ability.new(create_user_by_sector(sector))
        expect(@ability).to be_able_to(:read, Student)
      end

      it "should be able to write entity Student" do
        @ability = Ability.new(create_user_by_sector(sector))
        expect(@ability).not_to be_able_to(:write, Student)
      end

      ['Course', 'Keypass', 'Sector', 'User'].each do |entity|
        it "should not be able to manager entity #{entity}" do
          @ability = Ability.new(create_user_by_sector(sector))
          expect(@ability).not_to be_able_to(:manager, eval(entity))
        end
      end
    end

    context "user with sector 'Diren' " do
      sector = 'diren'
      ['Student', 'Course'].each do |entity|
        it "should be able to manager entity #{entity}" do
          @ability = Ability.new(create_user_by_sector(sector))
          expect(@ability).to be_able_to(:manager, eval(entity))
        end
      end

      ['Keypass', 'Sector', 'User'].each do |entity|
        it "should not be able to manager entity #{entity}" do
          @ability = Ability.new(create_user_by_sector(sector))
          expect(@ability).not_to be_able_to(:manager, eval(entity))
        end
      end
    end
  end
end
