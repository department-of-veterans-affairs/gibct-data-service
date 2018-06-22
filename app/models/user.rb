# frozen_string_literal: true

class User < ActiveRecord::Base
  has_many :versions, inverse_of: :user
  has_many :uploads, inverse_of: :user
  has_many :storages, inverse_of: :user

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :omniauthable and
  # :registerable
  devise :database_authenticatable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.from_saml_callback(response_attrs)
    email = response_attrs[:va_eauth_emailaddress]
    return if email.blank?
    find_by(email: email.downcase)
  end
end
