# frozen_string_literal: true
class User < ActiveRecord::Base
  has_many :versions, inverse_of: :user
  has_many :uploads, inverse_of: :user
  has_many :storages, inverse_of: :user

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable and
  # :registerable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
end
